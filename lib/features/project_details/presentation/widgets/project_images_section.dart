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

            // Cover image
            if (hasCover) ...[
              _CoverTile(url: project.coverUrl!),
              if (hasExtras) SizedBox(height: AppSpacing.sm),
            ],

            // Extra images row
            if (hasExtras)
              _ExtraImagesRow(images: project.images),
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

// -- Cover image tile --

class _CoverTile extends StatelessWidget {
  const _CoverTile({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFullScreen(context, url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: CachedImage(
          url: url,
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
        ),
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

// -- Extra images horizontal row --

class _ExtraImagesRow extends StatelessWidget {
  const _ExtraImagesRow({required this.images});

  final List<ExtraImageEntity> images;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          return _ExtraImageTile(image: images[index]);
        },
      ),
    );
  }
}

class _ExtraImageTile extends StatelessWidget {
  const _ExtraImageTile({required this.image});

  final ExtraImageEntity image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFullScreen(context, image.url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: CachedImage(
          url: image.url,
          width: 110,
          height: 110,
          fit: BoxFit.cover,
        ),
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
