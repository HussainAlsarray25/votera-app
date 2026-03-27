import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/app/view/shell_page.dart';
import 'package:votera/core/di/injection_container.dart';
import 'package:votera/core/domain/services/auth_token_provider.dart';
import 'package:votera/features/authentication/presentation/pages/auth_page.dart';
import 'package:votera/features/authentication/presentation/pages/confirm_reset_page.dart';
import 'package:votera/features/authentication/presentation/pages/forgot_password_page.dart';
import 'package:votera/features/authentication/presentation/pages/otp_verification_page.dart';
import 'package:votera/features/authentication/presentation/pages/user_info_page.dart';
import 'package:votera/features/participant_forms/presentation/cubit/forms_cubit.dart';
import 'package:votera/features/participant_forms/presentation/pages/email_verification_page.dart';
import 'package:votera/features/participant_forms/presentation/pages/supervisor_email_verification_page.dart';
import 'package:votera/features/participant_forms/presentation/pages/uid_submission_page.dart';
import 'package:votera/features/participant_forms/presentation/pages/verify_account_page.dart';
import 'package:votera/features/exhibitions/presentation/pages/exhibition_detail_page.dart';
import 'package:votera/features/exhibitions/presentation/pages/exhibitions_page.dart';
import 'package:votera/features/notification/presentation/pages/notification_page.dart';
import 'package:votera/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:votera/features/profile/presentation/pages/profile_page.dart';
import 'package:votera/features/project_details/presentation/pages/project_details_page.dart';
import 'package:votera/features/splash/presentation/pages/splash_page.dart';
import 'package:votera/features/categories/presentation/pages/category_projects_page.dart';
import 'package:votera/features/projects/presentation/cubit/projects_cubit.dart';
import 'package:votera/features/teams/presentation/pages/team_detail_page.dart';
import 'package:votera/features/teams/presentation/pages/teams_page.dart';

class AppRouter {
  GoRouter get router => _router;

  late final GoRouter _router = GoRouter(
    initialLocation: '/',
    redirect: _authRedirect,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
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
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return OtpVerificationPage(
            identifier: extra['identifier'] as String,
            isRegistration: extra['isRegistration'] as bool,
          );
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/confirm-reset',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ConfirmResetPage(
            email: extra['email'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: '/verify-account',
        builder: (context, state) => const VerifyAccountPage(),
      ),
      GoRoute(
        path: '/verify-account/email',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<FormsCubit>(),
          child: const EmailVerificationPage(),
        ),
      ),
      GoRoute(
        path: '/verify-account/supervisor-email',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<FormsCubit>(),
          child: const SupervisorEmailVerificationPage(),
        ),
      ),
      GoRoute(
        path: '/verify-account/uid',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<FormsCubit>()..loadMyUidRequests(),
          child: const UidSubmissionPage(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellPage(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const ExhibitionsPage(),
          ),
          GoRoute(
            path: '/teams',
            builder: (context, state) => const TeamsPage(),
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
        path: '/teams/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TeamDetailPage(teamId: id);
        },
      ),
      GoRoute(
        path: '/exhibition/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ExhibitionDetailPage(exhibitionId: id);
        },
      ),
      GoRoute(
        path: '/project/:eventId/:projectId',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId'] ?? '';
          final projectId = state.pathParameters['projectId'] ?? '';
          return ProjectDetailsPage(
            eventId: eventId,
            projectId: projectId,
          );
        },
      ),
      GoRoute(
        path: '/exhibition/:eventId/category/:categoryId',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId'] ?? '';
          final categoryId = state.pathParameters['categoryId'] ?? '';
          final categoryName = state.extra as String? ?? '';
          return BlocProvider(
            create: (_) => sl<ProjectsCubit>()
              ..loadProjects(
                eventId: eventId,
                categoryId: categoryId,
              ),
            child: CategoryProjectsPage(
              eventId: eventId,
              categoryId: categoryId,
              categoryName: categoryName,
            ),
          );
        },
      ),
    ],
  );

  Future<String?> _authRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final location = state.matchedLocation;

    // Allow splash, onboarding, auth, user-info, otp, and forgot-password without authentication.
    const publicRoutes = {'/', '/onboarding', '/auth', '/user-info', '/otp', '/forgot-password', '/confirm-reset'};
    if (publicRoutes.contains(location)) return null;

    final authProvider = sl<AuthTokenProvider>();
    final isAuthenticated = await authProvider.isAuthenticated();

    if (!isAuthenticated) return '/auth';

    return null;
  }
}
