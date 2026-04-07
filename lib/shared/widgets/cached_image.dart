import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';

/// A cached network image widget used across the app.
///
/// Wraps [CachedNetworkImage] to provide a consistent shimmer placeholder
/// and error fallback. Use this instead of [Image.network] everywhere so
/// images are cached to disk and load instantly on repeat visits.
class CachedImage extends StatelessWidget {
  const CachedImage({
    required this.url,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorIcon = Icons.broken_image_outlined,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData errorIcon;

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, _) => _Shimmer(width: width, height: height),
      errorWidget: (context, _, __) => _ErrorPlaceholder(
        width: width,
        height: height,
        icon: errorIcon,
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}

/// A cached avatar — circular, with an initials fallback when the URL is
/// empty or fails to load.
class CachedAvatar extends StatelessWidget {
  const CachedAvatar({
    required this.radius,
    super.key,
    this.url,
    this.initial,
  });

  final double radius;
  /// Remote avatar URL. Null or empty string falls back to [initial].
  final String? url;
  /// Single character shown when no image is available.
  final String? initial;

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.isNotEmpty;
    final size = radius * 2;

    return CircleAvatar(
      radius: radius,
      backgroundColor: context.colors.secondaryLight,
      child: ClipOval(
        child: hasUrl
            ? CachedNetworkImage(
                imageUrl: url!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (context, _) => _Shimmer(
                  width: size,
                  height: size,
                  isCircle: true,
                ),
                errorWidget: (context, _, __) => _InitialsFallback(
                  initial: initial,
                  radius: radius,
                ),
              )
            : _InitialsFallback(initial: initial, radius: radius),
      ),
    );
  }
}

// -- Private helpers --

class _Shimmer extends StatelessWidget {
  const _Shimmer({this.width, this.height, this.isCircle = false});

  final double? width;
  final double? height;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.border,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({this.width, this.height, required this.icon});

  final double? width;
  final double? height;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: context.colors.border,
      child: Icon(icon, color: context.colors.textSecondary, size: AppSizes.iconLg),
    );
  }
}

class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({required this.initial, required this.radius});

  final String? initial;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final letter =
        initial != null && initial!.isNotEmpty ? initial![0].toUpperCase() : '?';
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Center(
        child: Text(
          letter,
          style: AppTypography.labelMedium.copyWith(
            color: context.colors.secondary,
          ),
        ),
      ),
    );
  }
}
