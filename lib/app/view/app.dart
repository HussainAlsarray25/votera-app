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
                return ScreenUtilInit(
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
class _AuthStateListener extends StatelessWidget {
  const _AuthStateListener({required this.child});

  final Widget child;

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
      child: child,
    );
  }
}
