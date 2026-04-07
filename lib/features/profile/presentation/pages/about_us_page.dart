import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:votera/core/config/app_config.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

/// Displays information about the Votera app:
/// the app icon, name, version, tagline, and a brief description.
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  // App version shown statically until package_info is added.
  static const String _version = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        title: Text(
          l10n.aboutUs,
          style: AppTypography.h3.copyWith(color: context.colors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: AppSpacing.xxl),
            _buildAppIcon(context),
            SizedBox(height: AppSpacing.lg),
            _buildAppName(context, l10n),
            SizedBox(height: AppSpacing.xxl),
            _buildInfoCard(context, l10n),
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon(BuildContext context) {
    return Center(
      child: Container(
        width: 96.r,
        height: 96.r,
        decoration: BoxDecoration(
          color: context.colors.primary,
          borderRadius: BorderRadius.circular(26.r),
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.30),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            'V',
            style: AppTypography.h1.copyWith(
              fontSize: 46.sp,
              color: context.colors.textOnPrimary,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppName(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          AppConfig.instance.appName,
          style: AppTypography.h1.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: context.colors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          l10n.appMotto,
          style: AppTypography.bodyMedium.copyWith(
            color: context.colors.textHint,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            '${l10n.version} $_version',
            style: AppTypography.caption.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.card(Theme.of(context).brightness),
      ),
      child: Column(
        children: [
          _buildInfoTile(
            context: context,
            icon: Icons.info_outline_rounded,
            title: l10n.appTitle,
            subtitle: l10n.appTagline,
          ),
          Divider(height: 1, color: context.colors.divider),
          _buildInfoTile(
            context: context,
            icon: Icons.rocket_launch_outlined,
            title: l10n.version,
            subtitle: _version,
          ),
          Divider(height: 1, color: context.colors.divider),
          _buildInfoTile(
            context: context,
            icon: Icons.language_outlined,
            title: 'Website',
            subtitle: 'votera.space',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              icon,
              size: AppSizes.iconMd,
              color: context.colors.primary,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
