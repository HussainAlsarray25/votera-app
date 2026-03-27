import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

/// Lets the user pick their role: Student, Professor, or Visitor.
/// Each option is a tappable card with an icon and label.
class RoleSelectorSection extends StatefulWidget {
  const RoleSelectorSection({super.key});

  @override
  State<RoleSelectorSection> createState() => _RoleSelectorSectionState();
}

class _RoleSelectorSectionState extends State<RoleSelectorSection> {
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Built inside build() because role labels depend on localized strings.
    final roles = [
      _RoleOption(icon: Icons.school, label: l10n.student),
      _RoleOption(icon: Icons.science, label: l10n.professor),
      _RoleOption(icon: Icons.person, label: l10n.visitor),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.yourRole,
          style: AppTypography.labelLarge.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: List.generate(roles.length, (index) {
            final role = roles[index];
            final isSelected = _selectedIndex == index;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < roles.length - 1 ? AppSpacing.sm : 0,
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
              ? context.colors.primary.withValues(alpha: 0.08)
              : context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? context.colors.primary : context.colors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              role.icon,
              size: 32,
              color: isSelected
                  ? context.colors.primary
                  : context.colors.textHint,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              role.label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected
                    ? context.colors.primary
                    : context.colors.textSecondary,
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
