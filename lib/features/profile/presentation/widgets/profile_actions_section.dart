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
              backgroundColor: context.colors.error,
            ),
          );
        }
      },
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
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
                      context: context,
                      icon: Icons.verified_user_outlined,
                      label: 'Verify Account',
                      onTap: () => context.push('/verify-account'),
                    ),
                    Divider(height: 1, color: context.colors.divider),
                  ],
                  _buildActionTile(
                    context: context,
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Comments',
                    onTap: () => context.push('/comments'),
                  ),
                  Divider(height: 1, color: context.colors.divider),
                  _buildActionTile(
                    context: context,
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () {},
                  ),
                  Divider(height: 1, color: context.colors.divider),
                  _buildActionTile(
                    context: context,
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
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? context.colors.error : context.colors.textPrimary;

    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: AppTypography.bodyLarge.copyWith(color: color),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDestructive ? context.colors.error : context.colors.textHint,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
    );
  }
}
