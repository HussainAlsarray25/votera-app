import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';

/// A search bar with filter chips for narrowing project results.
class SearchBarSection extends StatelessWidget {
  const SearchBarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: AppSpacing.md),
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search projects...',
        prefixIcon:
            const Icon(Icons.search, color: AppColors.textHint, size: 20),
        suffixIcon: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: const Icon(Icons.tune, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Mobile', 'Web', 'AI', 'IoT', 'Games'];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final isSelected = index == 0;

          return ChoiceChip(
            label: Text(filters[index]),
            selected: isSelected,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            showCheckmark: false,
            onSelected: (_) {},
          );
        },
      ),
    );
  }
}
