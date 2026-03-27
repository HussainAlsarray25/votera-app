import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/animated_star_rating.dart';
import 'package:votera/shared/widgets/cached_image.dart';
import 'package:votera/shared/widgets/verified_badge.dart';

/// A card that displays a project summary: image, title, author, rating,
/// vote count, and optional trending/winner indicators.
class ProjectCard extends StatefulWidget {
  const ProjectCard({
    required this.title,
    required this.authorName,
    required this.imageUrl,
    required this.rating,
    required this.voteCount,
    this.isVerifiedAuthor = false,
    this.isTrending = false,
    this.isWinner = false,
    this.onTap,
    super.key,
  });

  final String title;
  final String authorName;
  final String imageUrl;
  final int rating;
  final int voteCount;
  final bool isVerifiedAuthor;
  final bool isTrending;
  final bool isWinner;
  final VoidCallback? onTap;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _elevationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: _elevationAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: context.colors.cardBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: widget.isWinner
                  ? AppShadows.goldenGlow
                  : (_elevationAnimation.value > 0.5
                      ? AppShadows.cardHover
                      : AppShadows.card(Theme.of(context).brightness)),
              // Golden border for the winner
              border: widget.isWinner
                  ? Border.all(color: context.colors.accent, width: 2)
                  : null,
            ),
            child: child,
          );
        },
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(context),
                  SizedBox(height: AppSpacing.md),
                  _buildTitleRow(context),
                  SizedBox(height: AppSpacing.xs),
                  _buildAuthorRow(context),
                  SizedBox(height: AppSpacing.sm),
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -- Section: Project thumbnail with optional badges --
  Widget _buildImage(BuildContext context) {
    return Stack(
      children: [
        CachedImage(
          url: widget.imageUrl,
          height: AppSizes.cardImageHeight,
          width: double.infinity,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          errorIcon: Icons.code,
        ),
        if (widget.isTrending) _buildTrendingBadge(context),
        if (widget.isWinner) _buildWinnerBadge(),
      ],
    );
  }

  Widget _buildTrendingBadge(BuildContext context) {
    return Positioned(
      top: AppSpacing.sm,
      left: AppSpacing.sm,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: context.colors.error,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              size: AppSizes.iconXs,
              color: Colors.white,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              AppLocalizations.of(context)!.trending,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnerBadge() {
    return Positioned(
      top: AppSpacing.sm,
      right: AppSpacing.sm,
      child: Builder(
        builder: (context) => Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 2,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            gradient: AppColorScheme.goldGradient,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events,
                size: AppSizes.iconXs,
                color: Colors.white,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                AppLocalizations.of(context)!.winner,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -- Section: Title --
  Widget _buildTitleRow(BuildContext context) {
    return Text(
      widget.title,
      style: AppTypography.labelLarge.copyWith(
        color: context.colors.textPrimary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  // -- Section: Author with optional verified badge --
  Widget _buildAuthorRow(BuildContext context) {
    return Row(
      children: [
        Text(
          widget.authorName,
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        if (widget.isVerifiedAuthor) ...[
          SizedBox(width: AppSpacing.xs),
          const VerifiedBadge(),
        ],
      ],
    );
  }

  // -- Section: Rating and vote count --
  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        AnimatedStarRating(
          rating: widget.rating,
          size: AppSizes.iconSm,
          isInteractive: false,
        ),
        const Spacer(),
        Icon(
          Icons.how_to_vote_outlined,
          size: AppSizes.iconSm,
          color: context.colors.primary,
        ),
        SizedBox(width: AppSpacing.xs),
        Text(
          AppLocalizations.of(context)!.voteCount(widget.voteCount),
          style: AppTypography.caption.copyWith(color: context.colors.primary),
        ),
      ],
    );
  }
}
