import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/shared/widgets/app_text_field.dart';
import 'package:votera/shared/widgets/gradient_button.dart';

/// Shows a modal bottom sheet for creating or editing a team.
///
/// Returns a record with [name] and optional [description] when the user
/// saves, or null if the user cancels.
Future<({String name, String? description})?> showCreateEditTeamSheet(
  BuildContext context, {
  String? initialName,
  String? initialDescription,
}) {
  return showModalBottomSheet<({String name, String? description})>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CreateEditTeamSheet(
      initialName: initialName,
      initialDescription: initialDescription,
    ),
  );
}

class _CreateEditTeamSheet extends StatefulWidget {
  const _CreateEditTeamSheet({
    this.initialName,
    this.initialDescription,
  });

  final String? initialName;
  final String? initialDescription;

  @override
  State<_CreateEditTeamSheet> createState() => _CreateEditTeamSheetState();
}

class _CreateEditTeamSheetState extends State<_CreateEditTeamSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;

  bool get _isEditing => widget.initialName != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _descController =
        TextEditingController(text: widget.initialDescription ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    final description = _descController.text.trim();
    Navigator.of(context).pop((
      name: name,
      description: description.isEmpty ? null : description,
    ),);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
            ),
            Text(
              _isEditing ? 'Edit Team' : 'Create a Team',
              style: AppTypography.h3,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _isEditing
                  ? 'Update your team details below.'
                  : 'Give your team a name and an optional description.',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Team Name',
              controller: _nameController,
              hint: 'e.g. The Innovators',
              prefixIcon: Icons.group_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Team name is required';
                }
                if (value.trim().length < 3) {
                  return 'Name must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Description (optional)',
              controller: _descController,
              hint: 'What is your team about?',
              prefixIcon: Icons.notes_rounded,
              maxLines: 3,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: AppSpacing.xl),
            GradientButton(
              text: _isEditing ? 'Save Changes' : 'Create Team',
              onPressed: _save,
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
