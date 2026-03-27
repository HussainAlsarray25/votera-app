import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + bottomInset,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
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
                margin: EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
            ),
            Text(
              _isEditing ? l10n.editTeamTitle : l10n.createATeam,
              style: AppTypography.h3.copyWith(color: context.colors.textPrimary),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              _isEditing ? l10n.editTeamDesc : l10n.createTeamDesc,
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: l10n.teamName,
              controller: _nameController,
              hint: l10n.teamNameHint,
              prefixIcon: Icons.group_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.teamNameRequired;
                }
                if (value.trim().length < 3) {
                  return l10n.teamNameTooShort;
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l10n.teamDescriptionOptional,
              controller: _descController,
              hint: l10n.teamDescriptionHint,
              prefixIcon: Icons.notes_rounded,
              maxLines: 3,
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: AppSpacing.xl),
            GradientButton(
              text: _isEditing ? l10n.saveChanges : l10n.createTeamButton,
              onPressed: _save,
            ),
            SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  l10n.cancel,
                  style: AppTypography.labelMedium.copyWith(
                    color: context.colors.textSecondary,
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
