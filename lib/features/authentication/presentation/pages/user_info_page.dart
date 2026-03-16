import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/authentication/presentation/widgets/role_selector_section.dart';
import 'package:votera/features/authentication/presentation/widgets/user_info_form_section.dart';

/// Collects additional user info after registration:
/// role (student, professor, visitor), department, and university ID.
class UserInfoPage extends StatelessWidget {
  const UserInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CenteredContent(
          maxWidth: AppBreakpoints.formPanelMax,
          child: SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xl),
                _buildHeader(),
                const SizedBox(height: AppSpacing.xl),
                const RoleSelectorSection(),
                const SizedBox(height: AppSpacing.lg),
                const UserInfoFormSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -- Section: Page header --
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tell Us About You', style: AppTypography.h1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Help us personalize your exhibition experience',
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }
}
