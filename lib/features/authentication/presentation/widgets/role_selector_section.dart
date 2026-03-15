import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';

/// Lets the user pick their role: Student, Professor, or Visitor.
/// Each option is a tappable card with an icon and label.
class RoleSelectorSection extends StatefulWidget {
  const RoleSelectorSection({super.key});

  @override
  State<RoleSelectorSection> createState() => _RoleSelectorSectionState();
}

class _RoleSelectorSectionState extends State<RoleSelectorSection> {
  int _selectedIndex = -1;

  static const _roles = [
    _RoleOption(icon: Icons.school, label: 'Student'),
    _RoleOption(icon: Icons.science, label: 'Professor'),
    _RoleOption(icon: Icons.person, label: 'Visitor'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Role', style: AppTypography.labelLarge),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: List.generate(_roles.length, (index) {
            final role = _roles[index];
            final isSelected = _selectedIndex == index;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < _roles.length - 1 ? AppSpacing.sm : 0,
                ),
                child: _buildRoleCard(role, isSelected, index),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRoleCard(_RoleOption role, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              role.icon,
              size: 32,
              color: isSelected ? AppColors.primary : AppColors.textHint,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              role.label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleOption {
  const _RoleOption({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
