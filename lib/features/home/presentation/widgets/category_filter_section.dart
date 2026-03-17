import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/home/presentation/demo_data.dart';

/// Horizontal scrollable row of category filter chips.
/// The active chip uses a dark filled style; inactive chips are outlined.
class CategoryFilterSection extends StatelessWidget {
  const CategoryFilterSection({
    required this.selectedCategory,
    required this.onCategorySelected,
    super.key,
  });

  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        itemCount: projectCategories.length,
        itemBuilder: (context, index) {
          final category = projectCategories[index];
          final isActive = selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _buildChip(category, isActive: isActive),
          );
        },
      ),
    );
  }

  Widget _buildChip(String category, {required bool isActive}) {
    const activeColor = Color(0xFF1A1D2E);

    return GestureDetector(
      onTap: () => onCategorySelected(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: isActive ? activeColor : AppColors.border,
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          category,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
