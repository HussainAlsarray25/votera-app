import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/app/view/shell_page.dart';
import 'package:votera/core/di/injection_container.dart';
import 'package:votera/core/domain/services/auth_token_provider.dart';
import 'package:votera/features/authentication/presentation/pages/auth_page.dart';
import 'package:votera/features/authentication/presentation/pages/user_info_page.dart';
import 'package:votera/features/home/presentation/pages/home_page.dart';
import 'package:votera/features/notification/presentation/pages/notification_page.dart';
import 'package:votera/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:votera/features/profile/presentation/pages/profile_page.dart';
import 'package:votera/features/project_details/presentation/pages/project_details_page.dart';

class AppRouter {
  GoRouter get router => _router;

  late final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: '/user-info',
        builder: (context, state) => const UserInfoPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellPage(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationPage(),
      ),
      GoRoute(
        path: '/project/:id',
        builder: (context, state) {
          return const ProjectDetailsPage();
        },
      ),
    ],
  );

  Future<String?> _authRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final authProvider = sl<AuthTokenProvider>();
    final isAuthenticated = await authProvider.isAuthenticated();

    final isOnAuthPage = state.matchedLocation == '/auth';
    final isOnOnboarding = state.matchedLocation == '/';

    if (!isAuthenticated && !isOnAuthPage && !isOnOnboarding) {
      return '/auth';
    }

    return null;
  }
}
