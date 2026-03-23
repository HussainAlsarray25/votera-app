import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/verified_badge.dart';

/// The top section of the profile page: avatar, name, role, and edit button.
/// Uses a clean card-style layout with a subtle gradient avatar ring.
class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, AppSpacing.lg, 20, 0),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final name = state is ProfileLoaded
              ? state.profile.fullName
              : null;
          final subtitle = state is ProfileLoaded && state.profile.roles.isNotEmpty
              ? state.profile.roles.first
              : null;
          final isLoading = state is ProfileLoading;

          return Column(
            children: [
              _buildAvatar(context),
              const SizedBox(height: 16),
              _buildNameAndRole(
                context: context,
                name: name,
                subtitle: subtitle,
                isLoading: isLoading,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: context.colors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.surface,
        ),
        child: Center(
          child: Icon(
            Icons.person_rounded,
            size: 48,
            color: context.colors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildNameAndRole({
    required BuildContext context,
    required String? name,
    required String? subtitle,
    required bool isLoading,
  }) {
    if (isLoading) {
      return Column(
        children: [
          Container(
            width: 140,
            height: 20,
            decoration: BoxDecoration(
              color: context.colors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 180,
            height: 14,
            decoration: BoxDecoration(
              color: context.colors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name ?? AppLocalizations.of(context)!.userFallback,
              style: AppTypography.h2.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            const VerifiedBadge(size: 20),
          ],
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
