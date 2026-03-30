import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/shared/widgets/cached_image.dart';

// ---------------------------------------------------------------------------
// Accent palette — each project gets a consistent pair derived from its title
// ---------------------------------------------------------------------------

const _accentPalette = [
  [Color(0xFF3ECF8E), Color(0xFF059669)],
  [Color(0xFF6366F1), Color(0xFF4338CA)],
  [Color(0xFFF59E0B), Color(0xFFD97706)],
  [Color(0xFFEC4899), Color(0xFFBE185D)],
  [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
  [Color(0xFF14B8A6), Color(0xFF0F766E)],
];

List<Color> _accentFor(String title) =>
    _accentPalette[title.hashCode.abs() % _accentPalette.length];

// ---------------------------------------------------------------------------
// Card
// ---------------------------------------------------------------------------

/// Full-bleed project card. The gradient (or image) covers the entire surface;
/// content floats at the bottom over a dark scrim.
///
/// Used in both the 2-column grid and the trending horizontal carousel.
/// Pass [width] to constrain for horizontal layouts.
class ProjectEntityCard extends StatelessWidget {
  const ProjectEntityCard({
    required this.project,
    required this.eventId,
    this.width,
    super.key,
  });

  final ProjectEntity project;
  final String eventId;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(project.title);
    // Prefer the cover image; fall back to the first extra image if no cover.
    final imageUrl = (project.coverUrl ?? '').isNotEmpty
        ? project.coverUrl!
        : (project.images.isNotEmpty ? project.images.first.url : null);
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: () => context.push(
        '/project/$eventId/${project.id}',
        // Pass the visible image URL so the detail page can display it
        // immediately via Hero before the API response arrives.
        extra: imageUrl,
      ),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: accent.first.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // -- Layer 1: background (image or gradient) wrapped in Hero --
              // The Hero tag matches the one in ProjectHeaderSection so Flutter
              // animates the image from the card into the detail page header.
              Hero(
                tag: 'project-cover-${project.id}',
                transitionOnUserGestures: true,
                child: hasImage
                    ? CachedImage(
                        url: imageUrl,
                        width: double.infinity,
                        errorIcon: Icons.code,
                      )
                    : _buildGradientBackground(accent),
              ),

              // -- Layer 2: watermark initial (gradient cards only) --
              if (!hasImage) _buildWatermark(),

              // -- Layer 3: dark scrim from bottom --
              _buildScrim(),

              // -- Layer 4: content pinned to bottom --
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildContent(context, accent),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientBackground(List<Color> accent) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent[0],
            accent[1],
            Color.lerp(accent[1], Colors.black, 0.4)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }

  // Large semi-transparent letter that bleeds off the top-right corner
  Widget _buildWatermark() {
    final initial =
        project.title.isNotEmpty ? project.title[0].toUpperCase() : '?';
    return Positioned(
      top: -16,
      right: -12,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 120.sp,
          fontWeight: FontWeight.w900,
          color: Colors.white.withValues(alpha: 0.1),
          letterSpacing: -6,
          height: 1,
        ),
      ),
    );
  }

  // Gradient scrim: transparent at top → dark at bottom
  Widget _buildScrim() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.15),
              Colors.black.withValues(alpha: 0.72),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
      ),
    );
  }

  // Title + description + bottom row, all on top of the scrim
  Widget _buildContent(BuildContext context, List<Color> accent) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.sm + 4,
        0,
        AppSpacing.sm + 4,
        AppSpacing.sm + 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            project.title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.3,
              letterSpacing: -0.2,
              shadows: const [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 8,
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (project.description != null &&
              project.description!.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              project.description!,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white.withValues(alpha: 0.65),
                height: 1.4,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: AppSpacing.sm),
          _buildBottomRow(accent),
        ],
      ),
    );
  }

  Widget _buildBottomRow(List<Color> accent) {
    final hasTech =
        project.techStack != null && project.techStack!.isNotEmpty;
    final firstTag = hasTech
        ? project.techStack!.split(RegExp('[,/| ]')).first.trim()
        : null;

    return Row(
      children: [
        if (firstTag != null) ...[
          // Frosted tech pill
          Container(
            constraints: const BoxConstraints(maxWidth: 96),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              firstTag,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        const Spacer(),
        // Accent arrow circle
        Container(
          width: AppSizes.iconLg + 2,
          height: AppSizes.iconLg + 2,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: AppSizes.iconXs,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
