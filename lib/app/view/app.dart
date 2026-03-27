import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:votera/core/design_system/theme/app_theme.dart';
import 'package:votera/core/di/injection_container.dart' as di;
import 'package:votera/core/router/app_router.dart';
import 'package:votera/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:votera/features/notification/presentation/cubit/push_notification_cubit.dart';
import 'package:votera/features/notification/presentation/cubit/unread_count_cubit.dart';
import 'package:votera/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:votera/features/settings/presentation/cubit/locale_cubit.dart';
import 'package:votera/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = di.sl<AppRouter>();
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: di.sl<AuthCubit>()),
        BlocProvider<ProfileCubit>(
          create: (_) => di.sl<ProfileCubit>(),
        ),
        BlocProvider.value(value: di.sl<PushNotificationCubit>()),
        BlocProvider<UnreadCountCubit>(
          create: (_) => di.sl<UnreadCountCubit>()..loadUnreadCount(),
        ),
        BlocProvider.value(value: di.sl<ThemeCubit>()),
        BlocProvider.value(value: di.sl<LocaleCubit>()),
      ],
      child: _AuthStateListener(
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                // Clamp the MediaQuery that ScreenUtil reads to a max mobile
                // width so that .r/.w/.h/.sp values don't over-scale on web
                // or tablet. CenteredContent and AppBreakpoints handle the
                // wider layout separately; this only affects token scaling.
                final rawMq = MediaQuery.of(context);
                // Cap the size ScreenUtil reads to the design dimensions so
                // that tokens (.r/.w/.h/.sp) never scale larger than 1:1 on
                // wide screens (tablet/web). Scaling down for small phones
                // (< 375 px) is still allowed. Layout adaption for wide
                // viewports is handled separately by CenteredContent and
                // AppBreakpoints, not by token scaling.
                final clampedMq = rawMq.copyWith(
                  size: Size(
                    rawMq.size.width.clamp(0.0, 375.0),
                    rawMq.size.height.clamp(0.0, 812.0),
                  ),
                );

                return MediaQuery(
                  data: clampedMq,
                  child: ScreenUtilInit(
                    designSize: const Size(375, 812),
                    minTextAdapt: true,
                    splitScreenMode: true,
                    useInheritedMediaQuery: true,
                    builder: (context, child) {
                      return MaterialApp.router(
                        title: 'Votera',
                        theme: AppTheme.lightTheme,
                        darkTheme: AppTheme.darkTheme,
                        themeMode: themeMode,
                        locale: locale,
                        localizationsDelegates:
                            AppLocalizations.localizationsDelegates,
                        supportedLocales: AppLocalizations.supportedLocales,
                        debugShowCheckedModeBanner: false,
                        routerConfig: appRouter.router,
                        builder: (context, child) {
                          return MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaler: TextScaler.linear(
                                MediaQuery.of(context)
                                    .textScaler
                                    .scale(1)
                                    .clamp(0.8, 1.2),
                              ),
                            ),
                            child: child ?? const SizedBox.shrink(),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Listens to auth state changes and manages session data.
/// On login: loads fresh profile and unread notification count.
/// On logout: resets all user-scoped cubits so stale data is cleared.
///
/// Also triggers checkAuthStatus() on the first frame so that the profile
/// is loaded on every app start, regardless of which route is entered first.
/// Without this, GoRouter's redirect can bypass the SplashPage and the
/// profile would never load (leaving Teams and MyProject tabs empty).
class _AuthStateListener extends StatefulWidget {
  const _AuthStateListener({required this.child});

  final Widget child;

  @override
  State<_AuthStateListener> createState() => _AuthStateListenerState();
}

class _AuthStateListenerState extends State<_AuthStateListener> {
  @override
  void initState() {
    super.initState();
    // Defer until the first frame so the BlocListener is fully subscribed
    // before the state change fires.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthCubit>().checkAuthStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.read<ProfileCubit>().loadProfile();
          context.read<UnreadCountCubit>().loadUnreadCount();
        } else if (state is AuthInitial) {
          context.read<ProfileCubit>().reset();
          context.read<UnreadCountCubit>().reset();
        }
      },
      child: widget.child,
    );
  }
}
