import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:votera/features/profile/presentation/cubit/profile_cubit.dart';

/// Settings and account actions at the bottom of the profile page.
class ProfileActionsSection extends StatelessWidget {
  const ProfileActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          context.go('/auth');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: AppShadows.card,
          ),
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              final isVisitor = profileState is ProfileLoaded &&
                  profileState.profile.isVisitorOnly;
              return Column(
                children: [
                  if (isVisitor) ...[
                    _buildActionTile(
                      icon: Icons.verified_user_outlined,
                      label: 'Verify Account',
                      onTap: () => context.push('/verify-account'),
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                  ],
                  _buildActionTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Comments',
                    onTap: () => context.push('/comments'),
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
                    onTap: () => context.read<AuthCubit>().logout(),
                  ),
                ],
              );
            },
          ),
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
