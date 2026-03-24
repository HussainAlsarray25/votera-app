import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/verified_badge.dart';

/// The top section of the profile page: avatar, name, role, and edit button.
/// Uses a clean card-style layout with a subtle gradient avatar ring.
class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, AppSpacing.lg, 20, 0),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final name = state is ProfileLoaded
              ? state.profile.fullName
              : null;
          final subtitle = state is ProfileLoaded && state.profile.roles.isNotEmpty
              ? state.profile.roles.first
              : null;
          final isLoading = state is ProfileLoading;

          return Column(
            children: [
              _buildAvatar(context),
              const SizedBox(height: 16),
              _buildNameAndRole(
                context: context,
                name: name,
                subtitle: subtitle,
                isLoading: isLoading,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final avatarUrl = state is ProfileLoaded ? state.profile.avatarUrl : null;
        final isUploading = state is ProfileAvatarUploading;

        return GestureDetector(
          onTap: isUploading ? null : () => _pickAndUploadAvatar(context),
          child: Stack(
            // Allow the badge to render slightly outside the circle bounds.
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: context.colors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.surface,
                  ),
                  // Show the remote avatar image if available, otherwise show
                  // the default person icon.
                  child: ClipOval(
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: avatarUrl,
                            width: 134,
                            height: 134,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              width: 134,
                              height: 134,
                              color: context.colors.border,
                            ),
                            errorWidget: (_, __, ___) => Icon(
                              Icons.person_rounded,
                              size: 64,
                              color: context.colors.primary,
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 64,
                              color: context.colors.primary,
                            ),
                          ),
                  ),
                ),
              ),
              // Center the badge on the circle's outer ring at ~45 deg
              // (bottom-right). For a 140px circle the ring edge at 45 deg is
              // at (120, 120) from the top-left, so right=6/bottom=6 places
              // the 28px badge centered exactly on the border.
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.primary,
                    border: Border.all(
                      color: context.colors.surface,
                      width: 2,
                    ),
                  ),
                  child: isUploading
                      ? Padding(
                          padding: const EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colors.surface,
                          ),
                        )
                      : Icon(
                          Icons.edit_rounded,
                          size: 16,
                          color: context.colors.surface,
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Opens a file picker, lets the user choose an image, then triggers the
  /// avatar upload via the cubit.
  Future<void> _pickAndUploadAvatar(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      // withData loads file bytes into memory — required on web where
      // file.path is unavailable.
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;

    // On web, file.path is null and the data lives in file.bytes.
    // On mobile/desktop, file.path is available. The cubit handles both cases.
    if (file.path == null && file.bytes == null) return;

    if (context.mounted) {
      context.read<ProfileCubit>().uploadAvatar(file);
    }
  }

  Widget _buildNameAndRole({
    required BuildContext context,
    required String? name,
    required String? subtitle,
    required bool isLoading,
  }) {
    if (isLoading) {
      return Column(
        children: [
          Container(
            width: 140,
            height: 20,
            decoration: BoxDecoration(
              color: context.colors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 180,
            height: 14,
            decoration: BoxDecoration(
              color: context.colors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name ?? AppLocalizations.of(context)!.userFallback,
              style: AppTypography.h2.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            const VerifiedBadge(size: 20),
          ],
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
