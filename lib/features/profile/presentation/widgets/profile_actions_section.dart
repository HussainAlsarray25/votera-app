import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';

/// Settings and account actions at the bottom of the profile page.
class ProfileActionsSection extends StatelessWidget {
  const ProfileActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            _buildActionTile(
              icon: Icons.person_outline,
              label: 'Edit Profile',
              onTap: () {},
            ),
            const Divider(height: 1, color: AppColors.divider),
            _buildActionTile(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () {},
            ),
            const Divider(height: 1, color: AppColors.divider),
            _buildActionTile(
              icon: Icons.help_outline,
              label: 'Help & Support',
              onTap: () {},
            ),
            const Divider(height: 1, color: AppColors.divider),
            _buildActionTile(
              icon: Icons.logout,
              label: 'Sign Out',
              isDestructive: true,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;

    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: AppTypography.bodyLarge.copyWith(color: color),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDestructive ? AppColors.error : AppColors.textHint,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
    );
  }
}
