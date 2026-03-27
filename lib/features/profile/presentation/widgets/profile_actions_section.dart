import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:votera/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:votera/features/settings/presentation/cubit/locale_cubit.dart';
import 'package:votera/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

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
            boxShadow: AppShadows.card(Theme.of(context).brightness),
          ),
          child: BlocBuilder<AuthCubit, AuthState>(
            buildWhen: (previous, current) =>
                (previous is AuthLoading) != (current is AuthLoading),
            builder: (context, authState) {
              final isLoggingOut = authState is AuthLoading;
              return BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, profileState) {
                  final isVisitor = profileState is ProfileLoaded &&
                      profileState.profile.isVisitorOnly;
                  final l10n = AppLocalizations.of(context)!;
                  return Column(
                    children: [
                      _buildThemeToggle(context, l10n),
                      Divider(height: 1, color: context.colors.divider),
                      _buildLanguageTile(context, l10n),
                      Divider(height: 1, color: context.colors.divider),
                      _buildActionTile(
                        context: context,
                        icon: Icons.help_outline,
                        label: l10n.helpSupport,
                        onTap: () {},
                      ),
                      Divider(height: 1, color: context.colors.divider),
                      _buildActionTile(
                        context: context,
                        icon: Icons.logout,
                        label: l10n.signOut,
                        isDestructive: true,
                        isLoading: isLoggingOut,
                        // Disable while logout is in progress to prevent double calls.
                        onTap: isLoggingOut
                            ? null
                            : () => context.read<AuthCubit>().logout(),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        final isDark = mode == ThemeMode.dark;
        return SwitchListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          secondary: Icon(
            isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            color: context.colors.primary,
            size: AppSizes.iconMd,
          ),
          title: Text(
            l10n.darkMode,
            style: AppTypography.bodyLarge
                .copyWith(color: context.colors.textPrimary),
          ),
          value: isDark,
          activeThumbColor: context.colors.primary,
          onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        );
      },
    );
  }

  Widget _buildLanguageTile(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        final isArabic = locale.languageCode == 'ar';
        final currentLanguageName = isArabic ? l10n.arabic : l10n.english;

        return ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          leading: Icon(
            Icons.language,
            color: context.colors.primary,
            size: AppSizes.iconMd,
          ),
          title: Text(
            l10n.language,
            style: AppTypography.bodyLarge
                .copyWith(color: context.colors.textPrimary),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentLanguageName,
                style: AppTypography.bodyMedium
                    .copyWith(color: context.colors.textHint),
              ),
              SizedBox(width: AppSpacing.xs),
              Icon(Icons.chevron_right, color: context.colors.textHint),
            ],
          ),
          onTap: () => _showLanguageSheet(context, l10n, locale),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        );
      },
    );
  }

  void _showLanguageSheet(
    BuildContext context,
    AppLocalizations l10n,
    Locale currentLocale,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sheet drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.colors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  l10n.language,
                  style: AppTypography.h3
                      .copyWith(color: context.colors.textPrimary),
                ),
                SizedBox(height: AppSpacing.sm),
                _buildLanguageOption(
                  context: context,
                  label: l10n.english,
                  languageCode: 'en',
                  currentLocale: currentLocale,
                ),
                _buildLanguageOption(
                  context: context,
                  label: l10n.arabic,
                  languageCode: 'ar',
                  currentLocale: currentLocale,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String label,
    required String languageCode,
    required Locale currentLocale,
  }) {
    final isSelected = currentLocale.languageCode == languageCode;

    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? context.colors.primary : context.colors.textHint,
      ),
      title: Text(
        label,
        style: AppTypography.bodyLarge.copyWith(
          color: isSelected
              ? context.colors.primary
              : context.colors.textPrimary,
        ),
      ),
      onTap: () {
        context.read<LocaleCubit>().setLocale(Locale(languageCode));
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isDestructive = false,
    bool isLoading = false,
  }) {
    final color =
        isDestructive ? context.colors.error : context.colors.textPrimary;

    return ListTile(
      leading: Icon(icon, color: color, size: AppSizes.iconMd),
      title: Text(
        label,
        style: AppTypography.bodyLarge.copyWith(color: color),
      ),
      trailing: isLoading
          ? SizedBox(
              width: AppSizes.iconMd,
              height: AppSizes.iconMd,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            )
          : Icon(
              Icons.chevron_right,
              color: isDestructive
                  ? context.colors.error
                  : context.colors.textHint,
            ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
    );
  }

}
