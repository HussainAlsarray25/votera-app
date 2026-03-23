import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/participant_forms/domain/entities/participant_request.dart';
import 'package:votera/features/participant_forms/presentation/cubit/forms_cubit.dart';
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

  // Stored after a successful document upload.
  String? _documentUrl;
  String? _documentFileName;

  @override
  void dispose() {
    _fullNameController.dispose();
    _universityIdController.dispose();
    _departmentController.dispose();
    _stageController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadDocument() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    context.read<FormsCubit>().uploadDocument(
          fileName: file.name,
          bytes: file.bytes!,
        );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_documentUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload your university ID document.'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }
      context.read<FormsCubit>().submitUid(
            fullName: _fullNameController.text.trim(),
            universityId: _universityIdController.text.trim(),
            department: _departmentController.text.trim(),
            stage: _stageController.text.trim(),
            documentUrl: _documentUrl!,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppColors.textPrimary),
        title: Text('University ID Card', style: AppTypography.labelLarge),
      ),
      backgroundColor: AppColors.background,
      body: BlocListener<FormsCubit, FormsState>(
        listener: (context, state) {
          if (state is FormsDocumentUploaded) {
            setState(() {
              _documentUrl = state.publicUrl;
              _documentFileName = state.fileName;
            });
          } else if (state is FormsUidSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Request submitted — pending review.'),
                backgroundColor: AppColors.success,
              ),
            );
            // Reload the requests list.
            context.read<FormsCubit>().loadMyUidRequests();
            // Reset the form.
            _formKey.currentState?.reset();
            setState(() {
              _documentUrl = null;
              _documentFileName = null;
            });
          } else if (state is FormsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.md),
                _buildRequestsList(),
                const SizedBox(height: AppSpacing.xl),
                _buildSubmitForm(),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -- Section: Existing requests --
  Widget _buildRequestsList() {
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Requests', style: AppTypography.labelLarge),
            const SizedBox(height: AppSpacing.md),
            ...state.requests.map(_buildRequestCard),
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.divider),
          ],
        );
      },
    );
  }

  Widget _buildRequestCard(ParticipantRequest request) {
    final (chipColor, chipLabel) = switch (request.status) {
      'approved' => (AppColors.success, 'Approved'),
      'rejected' => (AppColors.error, 'Rejected'),
      _ => (AppColors.warning, 'Pending'),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(request.fullName, style: AppTypography.labelMedium),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
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
          const SizedBox(height: 4),
          Text(
            '${request.department} • ${request.stage}',
            style: AppTypography.bodySmall,
          ),
          if (request.isRejected && request.reviewNote != null) ...[
            const SizedBox(height: 6),
            Text(
              'Note: ${request.reviewNote}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }

  // -- Section: Submission form --
  Widget _buildSubmitForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Submit New Request', style: AppTypography.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Fill in your details and upload a clear photo of your university ID card.',
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                label: 'Full Name',
                controller: _fullNameController,
                hint: 'As shown on your ID',
                prefixIcon: Icons.person_outline,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Full name is required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'University ID',
                controller: _universityIdController,
                hint: 'e.g. CS2021001',
                prefixIcon: Icons.badge_outlined,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'University ID is required';
                  if (v.length < 3) return 'ID must be at least 3 characters';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Department',
                controller: _departmentController,
                hint: 'e.g. Computer Science',
                prefixIcon: Icons.school_outlined,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Department is required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Stage / Year',
                controller: _stageController,
                hint: 'e.g. 3rd Year',
                prefixIcon: Icons.layers_outlined,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Stage is required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildDocumentField(),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        BlocBuilder<FormsCubit, FormsState>(
          builder: (context, state) {
            final isLoading = state is FormsLoading;
            return GradientButton(
              text: isLoading ? 'Submitting...' : 'Submit Request',
              onPressed: isLoading ? null : _handleSubmit,
            );
          },
        ),
      ],
    );
  }

  Widget _buildDocumentField() {
    return InkWell(
      onTap: _pickAndUploadDocument,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          color: AppColors.surface,
        ),
        child: Row(
          children: [
            Icon(
              _documentUrl != null
                  ? Icons.check_circle_outline
                  : Icons.upload_file_outlined,
              color: _documentUrl != null ? AppColors.success : AppColors.textHint,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                _documentFileName ?? 'Tap to upload ID document',
                style: AppTypography.bodyMedium.copyWith(
                  color: _documentUrl != null
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
