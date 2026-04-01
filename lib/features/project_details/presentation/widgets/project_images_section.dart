import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/projects/domain/entities/extra_image_entity.dart';
import 'package:votera/features/projects/presentation/cubit/projects_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/cached_image.dart';

/// Shows the project's cover image and extra gallery images.
///
/// Reads the current project from [ProjectsCubit] and renders:
/// - A large cover image when present.
/// - A horizontal scrollable row of extra images below.
///
/// Both the cover and each extra image are tappable to open a full-screen
/// viewer. The section is hidden entirely when the project has no images.
class ProjectImagesSection extends StatelessWidget {
  const ProjectImagesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsCubit, ProjectsState>(
      builder: (context, state) {
        final project =
            state is ProjectDetailLoaded ? state.project : null;

        if (project == null) return const SizedBox.shrink();

        final hasCover =
            project.coverUrl != null && project.coverUrl!.isNotEmpty;
        final hasExtras = project.images.isNotEmpty;

        // Nothing to render.
        if (!hasCover && !hasExtras) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            _SectionHeader(
              label: AppLocalizations.of(context)!.projectGallery,
            ),
            SizedBox(height: AppSpacing.sm),

            // All images in one horizontal scrollable row.
            // Cover is always first so the user sees it in context with
            // the extra images without needing to scroll past a large tile.
            _GalleryRow(
              coverUrl: hasCover ? project.coverUrl : null,
              images: project.images,
            ),
          ],
        );
      },
    );
  }
}

// -- Section header --

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTypography.h3.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(child: Divider(color: context.colors.border)),
      ],
    );
  }
}

// -- Single gallery tile (cover or extra image) --

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({required this.url, this.isCover = false});

  final String url;

  // When true a small "Cover" badge is shown so the user can tell which
  // image is the project cover at a glance.
  final bool isCover;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFullScreen(context, url),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: CachedImage(
              url: url,
              width: 110,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),
          if (isCover)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  AppLocalizations.of(context)!.coverImage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openFullScreen(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => _FullScreenImage(url: imageUrl),
      ),
    );
  }
}

// -- Unified gallery row: cover first, then extra images --

class _GalleryRow extends StatelessWidget {
  const _GalleryRow({
    required this.images,
    this.coverUrl,
  });

  final String? coverUrl;
  final List<ExtraImageEntity> images;

  @override
  Widget build(BuildContext context) {
    // Build a flat list: cover tile (if any) followed by extra image tiles.
    final tiles = <Widget>[
      if (coverUrl != null)
        _GalleryTile(url: coverUrl!, isCover: true),
      ...images.map((img) => _GalleryTile(url: img.url)),
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tiles.length,
        separatorBuilder: (_, __) => SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, index) => tiles[index],
      ),
    );
  }
}

// -- Full-screen image viewer --

/// Simple full-screen image overlay. Tap anywhere to dismiss.
class _FullScreenImage extends StatelessWidget {
  const _FullScreenImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Center(
        child: InteractiveViewer(
          child: CachedImage(url: url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
