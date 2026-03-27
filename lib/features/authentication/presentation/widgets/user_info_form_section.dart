import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/app_text_field.dart';
import 'package:votera/shared/widgets/gradient_button.dart';

/// Additional info fields: department, university ID, and phone number.
class UserInfoFormSection extends StatefulWidget {
  const UserInfoFormSection({super.key});

  @override
  State<UserInfoFormSection> createState() => _UserInfoFormSectionState();
}

class _UserInfoFormSectionState extends State<UserInfoFormSection> {
  final _departmentController = TextEditingController();
  final _universityIdController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _departmentController.dispose();
    _universityIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        AppTextField(
          label: l10n.department,
          controller: _departmentController,
          hint: l10n.departmentHint,
          prefixIcon: Icons.apartment,
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          label: l10n.universityIdOptional,
          controller: _universityIdController,
          hint: l10n.universityIdHint,
          prefixIcon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          label: l10n.phoneOptional,
          controller: _phoneController,
          hint: l10n.phoneHint,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: AppSpacing.xl),
        GradientButton(
          text: l10n.continueButton,
          onPressed: () {
            // Navigate to home
          },
        ),
      ],
    );
  }
}
