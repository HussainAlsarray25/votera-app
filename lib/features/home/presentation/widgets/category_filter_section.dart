import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:votera/core/design_system/design_system.dart';

/// Horizontal scrollable row of category filter chips.
/// The active chip uses a dark filled style; inactive chips are outlined.
class CategoryFilterSection extends StatelessWidget {
  const CategoryFilterSection({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    super.key,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isActive = selectedCategory == category;

          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: _buildChip(context, category, isActive: isActive),
          );
        },
      ),
    );
  }

  Widget _buildChip(BuildContext context, String category, {required bool isActive}) {
    const activeColor = Color(0xFF1A1D2E);

    return GestureDetector(
      onTap: () => onCategorySelected(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? activeColor : context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: isActive ? activeColor : context.colors.border,
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
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
