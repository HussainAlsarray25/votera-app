import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

/// Top section of the home page: app title, subtitle, and notification bell.
class HomeHeaderSection extends StatelessWidget {
  const HomeHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, AppSpacing.md, 20.w, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context),
          _buildNotificationButton(context),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.appTitle,
          style: AppTypography.h1.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          l10n.appMotto,
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/notifications'),
      child: Container(
        width: 42.r,
        height: 42.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: context.colors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.notifications_rounded,
          color: Colors.white,
          size: AppSizes.iconMd,
        ),
      ),
    );
  }
}
