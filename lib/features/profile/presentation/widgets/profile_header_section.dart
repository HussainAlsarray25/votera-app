import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/profile/domain/entities/user_profile.dart';
import 'package:votera/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/app_snack_bar.dart';
import 'package:votera/shared/widgets/app_text_field.dart';
import 'package:votera/shared/widgets/gradient_button.dart';

// Official Telegram brand color used for the Telegram-verified card.
const _telegramBlue = Color(0xFF2CA5E0);

/// The top section of the profile page: avatar, name, role, and edit button.
/// Uses a clean card-style layout with a subtle gradient avatar ring.
class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        // Extract profile from any state that carries one, so the UI never
        // blanks out during an in-flight update, avatar upload, or after an error.
        final profile = switch (state) {
          ProfileLoaded(:final profile) => profile,
          ProfileUpdating(:final profile) => profile,
          ProfileAvatarUploading(:final profile) => profile,
          ProfileError(:final profile) => profile,
          _ => null,
        };
        final name = profile?.fullName;
        final handle = profile?.handle;
        // Show the skeleton only when we have no profile data at all.
        final isLoading = state is ProfileLoading;
        final roles = profile?.roles ?? [];
        final identifiers = profile?.identifiers ?? [];

        // Determine the label and accent color for the verification card.
        // Priority: participant > supervisor > telegram login > none.
        final l10n = AppLocalizations.of(context)!;

        final telegramId =
            identifiers.where((i) => i.type == 'telegram').firstOrNull;
        final emailId = identifiers
            .where((i) =>
                i.type == 'institutional_email' || i.type == 'email')
            .firstOrNull;

        final String? verifiedLabel;
        final Color? verifiedColor;
        if (roles.contains('participant')) {
          verifiedLabel = l10n.studentVerified;
          verifiedColor = context.colors.success;
        } else if (roles.contains('supervisor')) {
          verifiedLabel = l10n.teacherVerified;
          verifiedColor = context.colors.primary;
        } else if (telegramId != null) {
          // User signed in via Telegram but has not yet obtained a role.
          // Show a Telegram-verified card so they know their account is linked.
          verifiedLabel = l10n.telegramVerified;
          verifiedColor = _telegramBlue;
        } else if (emailId != null) {
          // User signed in with email. Show their email on the profile card
          // so they can confirm which account is active.
          verifiedLabel = l10n.email;
          verifiedColor = context.colors.primary;
        } else {
          verifiedLabel = null;
          verifiedColor = null;
        }

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, AppSpacing.lg, 20.w, 0),
              child: Column(
                children: [
                  _buildAvatar(context),
                  SizedBox(height: 16.h),
                  _buildNameAndRole(
                    context: context,
                    name: name,
                    handle: handle,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
            if (verifiedLabel != null && verifiedColor != null) ...[
              SizedBox(height: 14.h),
              Padding(
                padding: AppSpacing.pagePadding,
                child: _buildVerificationCard(
                  context: context,
                  label: verifiedLabel,
                  color: verifiedColor,
                  telegramId: telegramId,
                  emailId: emailId,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final avatarUrl = switch (state) {
          ProfileLoaded(:final profile) => profile.avatarUrl,
          ProfileUpdating(:final profile) => profile.avatarUrl,
          ProfileAvatarUploading(:final profile) => profile.avatarUrl,
          ProfileError(:final profile) => profile?.avatarUrl,
          _ => null,
        };
        final isUploading = state is ProfileAvatarUploading;

        return GestureDetector(
          onTap: isUploading ? null : () => _pickAndUploadAvatar(context),
          child: Stack(
            // Allow the badge to render slightly outside the circle bounds.
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 140.r,
                height: 140.r,
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
                            width: 134.r,
                            height: 134.r,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              width: 134.r,
                              height: 134.r,
                              color: context.colors.border,
                            ),
                            errorWidget: (_, __, ___) => Icon(
                              Icons.person_rounded,
                              size: 64.r,
                              color: context.colors.primary,
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 64.r,
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
                  width: AppSizes.avatarSm,
                  height: AppSizes.avatarSm,
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
                          padding: EdgeInsets.all(8.r),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colors.surface,
                          ),
                        )
                      : Icon(
                          Icons.edit_rounded,
                          size: AppSizes.iconSm,
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
  /// avatar upload via the cubit. Ensures bytes are loaded from picker.
  Future<void> _pickAndUploadAvatar(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      // withData=true loads file bytes into memory for all platforms,
      // including web where file.path is unavailable.
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;

    // Bytes must be loaded by the picker for all platforms.
    // If bytes are null/empty, the picker failed to load the file.
    if (file.bytes == null || file.bytes!.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load image. Please try another file.'),
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      context.read<ProfileCubit>().uploadAvatar(file);
    }
  }

  Widget _buildNameAndRole({
    required BuildContext context,
    required String? name,
    required String? handle,
    required bool isLoading,
  }) {
    if (isLoading) {
      return Column(
        children: [
          Container(
            width: 140.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: context.colors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: 180.w,
            height: 14.h,
            decoration: BoxDecoration(
              color: context.colors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      );
    }

    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name ?? l10n.userFallback,
              style: AppTypography.h2.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(width: 6.w),
            // Pencil icon to open the edit name bottom sheet.
            GestureDetector(
              onTap: () => _showEditNameSheet(context, name),
              child: Icon(
                Icons.edit_rounded,
                size: AppSizes.iconSm,
                color: context.colors.textHint,
              ),
            ),
          ],
        ),
        if (handle != null && handle.isNotEmpty) ...[
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () => _copyHandle(context, handle),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(color: context.colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tag_rounded,
                    size: AppSizes.iconSm,
                    color: context.colors.textHint,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    handle,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.textHint,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.copy_rounded,
                    size: AppSizes.iconSm,
                    color: context.colors.textHint,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Opens a bottom sheet with a text field to edit the user's full name.
  /// Submitting calls [ProfileCubit.updateProfile] and shows a snackbar on success.
  void _showEditNameSheet(BuildContext context, String? currentName) {
    final cubit = context.read<ProfileCubit>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: _EditNameSheet(
          currentName: currentName,
          pageContext: context,
        ),
      ),
    );
  }

  Widget _buildVerificationCard({
    required BuildContext context,
    required String label,
    required Color color,
    required ProfileIdentifier? telegramId,
    required ProfileIdentifier? emailId,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.card(Theme.of(context).brightness),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: verified badge + role label
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.verified_rounded, size: AppSizes.iconXs, color: color),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Divider(height: 1, color: context.colors.divider),
          SizedBox(height: 14.h),
          // Telegram row — uses the real Telegram SVG logo asset.
          if (telegramId != null)
            _buildIdentifierRow(
              context: context,
              iconWidget: SvgPicture.asset(
                'assets/images/features/profile/telegram.svg',
                width: AppSizes.iconLg,
                height: AppSizes.iconLg,
              ),
              label: 'Telegram',
              labelColor: context.colors.textPrimary,
            ),
          if (telegramId != null && emailId != null)
            SizedBox(height: 10.h),
          // Email row — uses a custom red circle SVG matching the email icon style.
          if (emailId != null)
            _buildIdentifierRow(
              context: context,
              iconWidget: SvgPicture.asset(
                'assets/images/features/profile/email.svg',
                width: AppSizes.iconMd,
                height: AppSizes.iconMd,
              ),
              label: emailId.value,
              labelColor: context.colors.textSecondary,
            ),
        ],
      ),
    );
  }

  Widget _buildIdentifierRow({
    required BuildContext context,
    required Widget iconWidget,
    required String label,
    required Color labelColor,
  }) {
    return Row(
      children: [
        SizedBox(width: AppSizes.avatarSm, child: Center(child: iconWidget)),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _copyHandle(BuildContext context, String handle) {
    Clipboard.setData(ClipboardData(text: handle));
    showAppSnackBar(
      context,
      AppLocalizations.of(context)!.copiedToClipboard,
      type: AppSnackBarType.success,
      duration: const Duration(seconds: 2),
    );
  }
}

/// Bottom sheet content for editing the user's full name.
/// Uses a local [_isSaving] flag so the BlocListener only reacts to state
/// transitions triggered by the save action — not to the initial profile load.
class _EditNameSheet extends StatefulWidget {
  const _EditNameSheet({
    required this.currentName,
    required this.pageContext,
  });

  final String? currentName;
  // The context of the profile page, used to show snackbars above the sheet.
  final BuildContext pageContext;

  @override
  State<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<_EditNameSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      context.read<ProfileCubit>().updateProfile(
            fullName: _controller.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (_, state) {
        if (!_isSaving) return;

        if (state is ProfileLoaded) {
          Navigator.of(context).pop();
          showAppSnackBar(
            widget.pageContext,
            l10n.profileUpdated,
            type: AppSnackBarType.success,
            duration: const Duration(seconds: 2),
          );
        } else if (state is ProfileError) {
          setState(() => _isSaving = false);
          showAppSnackBar(
            widget.pageContext,
            state.message,
            type: AppSnackBarType.error,
          );
        }
      },
      builder: (_, state) {
        // The cubit emits ProfileUpdating (not ProfileLoading) during a name save,
        // so check for that state to drive the button's loading indicator.
        final isLoading = _isSaving && state is ProfileUpdating;

        return Padding(
          // Push the sheet above the soft keyboard when it appears.
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: context.colors.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      l10n.editProfile,
                      style: AppTypography.h3.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: l10n.fullName,
                      controller: _controller,
                      hint: l10n.enterFullName,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.nameRequired;
                        }
                        if (value.trim().length > 100) {
                          return l10n.fullNameTooLong;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSpacing.xl),
                    GradientButton(
                      text: l10n.saveChanges,
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
