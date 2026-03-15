import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/shared/widgets/verified_badge.dart';

/// The top section of the profile page: avatar, name, role, and edit button.
class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSpacing.radiusXl),
          bottomRight: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          _buildAvatar(),
          const SizedBox(height: AppSpacing.md),
          _buildNameAndRole(),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          child: const CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.surface,
            child: Icon(Icons.person, size: 44, color: AppColors.primary),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit, size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildNameAndRole() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ahmed Ali',
              style: AppTypography.h3.copyWith(color: Colors.white),
            ),
            const SizedBox(width: 6),
            const VerifiedBadge(size: 18),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Professor - Computer Science',
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
