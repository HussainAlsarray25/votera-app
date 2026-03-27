import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/comments/presentation/cubit/comments_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/animated_star_rating.dart';

/// Lets the user rate a project and optionally attach a written review.
/// Submits both together via [CommentsCubit.addComment], which accepts a
/// score (1-5) alongside the comment text.
class ProjectRatingSection extends StatefulWidget {
  const ProjectRatingSection({required this.projectId, super.key});

  final String projectId;

  @override
  State<ProjectRatingSection> createState() => _ProjectRatingSectionState();
}

class _ProjectRatingSectionState extends State<ProjectRatingSection> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectStarFirst),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    unawaited(
      context.read<CommentsCubit>().addComment(
            projectId: widget.projectId,
            text: _commentController.text.trim(),
            score: _selectedRating,
          ),
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _selectedRating = 0;
        _commentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.colors.border),
        boxShadow: AppShadows.card(Theme.of(context).brightness),
      ),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Header row: gradient score badge + title + instruction --
            Row(
              children: [
                // Gradient badge mirrors the old community-rating style.
                // Shows the selected score, or a star icon when nothing is picked.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72.r,
                  height: 72.r,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, Color(0xFFF59E0B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Center(
                    child: _selectedRating == 0
                        ? Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: AppSizes.iconLg,
                          )
                        : Text(
                            '$_selectedRating',
                            style: AppTypography.h1.copyWith(
                              color: Colors.white,
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.rateThisProject,
                        style: AppTypography.labelLarge.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      // Animated star picker — same widget and animation as before.
                      AnimatedStarRating(
                        rating: _selectedRating,
                        size: AppSizes.iconMd,
                        onRatingChanged: (rating) {
                          setState(() => _selectedRating = rating);
                        },
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.tapStarToRate,
                        style: AppTypography.caption.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.md),
            Divider(height: 1, color: context.colors.divider),
            SizedBox(height: AppSpacing.md),

            // -- Comment text field --
            TextField(
              controller: _commentController,
              maxLines: 3,
              textInputAction: TextInputAction.newline,
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: l10n.writeYourReview,
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: context.colors.textHint,
                ),
                filled: true,
                fillColor: context.colors.background,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide(
                    color: context.colors.accent,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            SizedBox(height: AppSpacing.md),

            // -- Submit button --
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : () => _submit(context),
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.accent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: AppSizes.iconSm,
                        height: AppSizes.iconSm,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.submit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
