import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
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
    return Column(
      children: [
        AppTextField(
          label: 'Department',
          controller: _departmentController,
          hint: 'e.g. Computer Science',
          prefixIcon: Icons.apartment,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'University ID (optional)',
          controller: _universityIdController,
          hint: 'e.g. 2024001234',
          prefixIcon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Phone Number (optional)',
          controller: _phoneController,
          hint: '+964 xxx xxx xxxx',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppSpacing.xl),
        GradientButton(
          text: 'Continue',
          onPressed: () {
            // Navigate to home
          },
        ),
      ],
    );
  }
}
