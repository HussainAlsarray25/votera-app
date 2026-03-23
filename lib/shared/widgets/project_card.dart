import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/shared/widgets/animated_star_rating.dart';
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
                      : AppShadows.card),
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
                  const SizedBox(height: AppSpacing.md),
                  _buildTitleRow(context),
                  const SizedBox(height: AppSpacing.xs),
                  _buildAuthorRow(context),
                  const SizedBox(height: AppSpacing.sm),
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
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            height: 160,
            width: double.infinity,
            color: context.colors.border,
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(
                  Icons.code,
                  size: 48,
                  color: context.colors.textHint,
                ),
              ),
            ),
          ),
        ),
        if (widget.isTrending) _buildTrendingBadge(context),
        if (widget.isWinner) _buildWinnerBadge(),
      ],
    );
  }

  Widget _buildTrendingBadge(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: context.colors.error,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department, size: 14, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'Trending',
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
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          gradient: AppColorScheme.goldGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, size: 14, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'Winner',
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
          const SizedBox(width: 4),
          const VerifiedBadge(size: 14),
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
          size: 18,
          isInteractive: false,
        ),
        const Spacer(),
        Icon(
          Icons.how_to_vote_outlined,
          size: 16,
          color: context.colors.primary,
        ),
        const SizedBox(width: 4),
        Text(
          '${widget.voteCount} votes',
          style: AppTypography.caption.copyWith(color: context.colors.primary),
        ),
      ],
    );
  }
}
