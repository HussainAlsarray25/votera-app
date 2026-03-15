import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';

/// Top section of the home page: greeting and notification bell.
class HomeHeaderSection extends StatelessWidget {
  const HomeHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.md, AppSpacing.md, 0,
      ),
      child: Row(
        children: [
          Expanded(child: _buildGreeting()),
          _buildNotificationButton(context),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Software Exhibition', style: AppTypography.h2),
        const SizedBox(height: 2),
        Text(
          'Vote for the best projects',
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return IconButton(
      onPressed: () => context.push('/notifications'),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      icon: const Icon(
        Icons.notifications_outlined,
        color: AppColors.textPrimary,
      ),
    );
  }
}
