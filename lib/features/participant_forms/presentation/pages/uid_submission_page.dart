import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/participant_forms/domain/entities/participant_request.dart';
import 'package:votera/features/participant_forms/presentation/cubit/forms_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/app_snack_bar.dart';
import 'package:votera/shared/widgets/app_text_field.dart';
import 'package:votera/shared/widgets/gradient_button.dart';

/// Allows the user to submit a university ID card for admin review.
/// Shows existing requests at the top and the submission form below.
class UidSubmissionPage extends StatefulWidget {
  const UidSubmissionPage({super.key});

  @override
  State<UidSubmissionPage> createState() => _UidSubmissionPageState();
}

class _UidSubmissionPageState extends State<UidSubmissionPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _universityIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _stageController = TextEditingController();

  // Stored after a successful document pick (not uploaded yet).
  List<int>? _documentBytes;
  String? _documentFileName;

  @override
  void dispose() {
    _fullNameController.dispose();
    _universityIdController.dispose();
    _departmentController.dispose();
    _stageController.dispose();
    super.dispose();
  }

  /// Picks a document and stores it locally in state.
  /// The document is uploaded along with form fields when user submits.
  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() {
      _documentBytes = file.bytes!;
      _documentFileName = file.name;
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_documentBytes == null || _documentFileName == null) {
        showAppSnackBar(context, AppLocalizations.of(context)!.uploadIdDesc);
        return;
      }
      context.read<FormsCubit>().submitUid(
            fullName: _fullNameController.text.trim(),
            universityId: _universityIdController.text.trim(),
            department: _departmentController.text.trim(),
            stage: _stageController.text.trim(),
            documentBytes: _documentBytes!,
            documentFileName: _documentFileName!,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: context.colors.textPrimary),
        title: Text(
          AppLocalizations.of(context)!.universityIdCard,
          style: AppTypography.labelLarge.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ),
      backgroundColor: context.colors.background,
      body: BlocListener<FormsCubit, FormsState>(
        listener: (context, state) {
          if (state is FormsUidSubmitted) {
            showAppSnackBar(
              context,
              AppLocalizations.of(context)!.requestPending,
              type: AppSnackBarType.success,
            );
            // Reload the requests list.
            context.read<FormsCubit>().loadMyUidRequests();
            // Reset the form.
            _formKey.currentState?.reset();
            setState(() {
              _documentBytes = null;
              _documentFileName = null;
            });
          } else if (state is FormsError) {
            showAppSnackBar(
              context,
              state.message,
              type: AppSnackBarType.error,
            );
          }
        },
        child: FormCardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppSpacing.md),
              _buildRequestsList(context),
              SizedBox(height: AppSpacing.xl),
              _buildSubmitForm(context),
              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  // -- Section: Existing requests --
  Widget _buildRequestsList(BuildContext context) {
    return BlocBuilder<FormsCubit, FormsState>(
      buildWhen: (_, state) =>
          state is FormsUidRequestsLoaded || state is FormsLoading,
      builder: (context, state) {
        if (state is FormsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is! FormsUidRequestsLoaded || state.requests.isEmpty) {
          return const SizedBox.shrink();
        }
        final l10n = AppLocalizations.of(context)!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.myRequests,
              style: AppTypography.labelLarge.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            ...state.requests.map(
              (r) => _buildRequestCard(context, r),
            ),
            SizedBox(height: AppSpacing.md),
            Divider(color: context.colors.divider),
          ],
        );
      },
    );
  }

  Widget _buildRequestCard(BuildContext context, ParticipantRequest request) {
    final l10n = AppLocalizations.of(context)!;
    final (chipColor, chipLabel) = switch (request.status) {
      'approved' => (context.colors.success, l10n.approved),
      'rejected' => (context.colors.error, l10n.rejected),
      _ => (context.colors.warning, l10n.pending),
    };

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppShadows.card(Theme.of(context).brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.fullName,
                  style: AppTypography.labelMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  chipLabel,
                  style: AppTypography.caption.copyWith(
                    color: chipColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            '${request.department} • ${request.stage}',
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          if (request.isRejected && request.reviewNote != null) ...[
            SizedBox(height: AppSpacing.xs),
            Text(
              AppLocalizations.of(context)!.noteLabel(request.reviewNote!),
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // -- Section: Submission form --
  Widget _buildSubmitForm(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.submitNewRequest,
          style: AppTypography.labelLarge.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          l10n.fillIdForm,
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                label: l10n.fullName,
                controller: _fullNameController,
                hint: l10n.nameAsOnId,
                prefixIcon: Icons.person_outline,
                validator: (v) =>
                    (v == null || v.isEmpty) ? l10n.nameRequired : null,
              ),
              SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l10n.universityId,
                controller: _universityIdController,
                hint: l10n.universityIdExample,
                prefixIcon: Icons.badge_outlined,
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.universityIdRequired;
                  if (v.length < 3) return l10n.universityIdTooShort;
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l10n.department,
                controller: _departmentController,
                hint: l10n.departmentHint,
                prefixIcon: Icons.school_outlined,
                validator: (v) =>
                    (v == null || v.isEmpty) ? l10n.departmentRequired : null,
              ),
              SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l10n.stageYear,
                controller: _stageController,
                hint: l10n.stageYearExample,
                prefixIcon: Icons.layers_outlined,
                validator: (v) =>
                    (v == null || v.isEmpty) ? l10n.stageRequired : null,
              ),
              SizedBox(height: AppSpacing.md),
              _buildDocumentField(context),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.xl),
        BlocBuilder<FormsCubit, FormsState>(
          builder: (context, state) {
            final l10n = AppLocalizations.of(context)!;
            final isLoading = state is FormsLoading;
            return GradientButton(
              text: isLoading ? l10n.submitting : l10n.submitRequest,
              onPressed: isLoading ? null : _handleSubmit,
            );
          },
        ),
      ],
    );
  }

  Widget _buildDocumentField(BuildContext context) {
    return InkWell(
      onTap: _pickDocument,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          color: context.colors.surface,
        ),
        child: Row(
          children: [
            Icon(
              _documentBytes != null
                  ? Icons.check_circle_outline
                  : Icons.upload_file_outlined,
              color: _documentBytes != null
                  ? context.colors.success
                  : context.colors.textHint,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                _documentFileName ?? AppLocalizations.of(context)!.tapToUploadId,
                style: AppTypography.bodyMedium.copyWith(
                  color: _documentBytes != null
                      ? context.colors.textPrimary
                      : context.colors.textHint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
