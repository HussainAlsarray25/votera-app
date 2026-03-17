import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';

/// Reusable body content for the Categories display.
/// Shows a header and a 2-column grid of category cards.
/// Used both in the standalone CategoriesPage and inside ExhibitionDetailPage.
class CategoriesBody extends StatelessWidget {
  const CategoriesBody({super.key});

  static const _categories = [
    _CategoryItem(
      name: 'AI / ML',
      emoji: '\u{1F916}',
      count: 24,
      colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
    ),
    _CategoryItem(
      name: 'Web Dev',
      emoji: '\u{1F310}',
      count: 31,
      colors: [Color(0xFF22C55E), Color(0xFF10B981)],
    ),
    _CategoryItem(
      name: 'Mobile Apps',
      emoji: '\u{1F4F1}',
      count: 18,
      colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    ),
    _CategoryItem(
      name: 'Game',
      emoji: '\u{1F3AE}',
      count: 15,
      colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
    ),
    _CategoryItem(
      name: 'IoT',
      emoji: '\u{1F33F}',
      count: 12,
      colors: [Color(0xFF10B981), Color(0xFF059669)],
    ),
    _CategoryItem(
      name: 'Data',
      emoji: '\u{1F4CA}',
      count: 20,
      colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.lg),
          Expanded(child: _buildGrid()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: AppTypography.h1.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Browse projects by category',
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.3,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        return _CategoryCard(category: _categories[index]);
      },
    );
  }
}

class _CategoryItem {
  const _CategoryItem({
    required this.name,
    required this.emoji,
    required this.count,
    required this.colors,
  });

  final String name;
  final String emoji;
  final int count;
  final List<Color> colors;
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final _CategoryItem category;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(),
          const SizedBox(height: 10),
          Text(
            category.name,
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${category.count} projects',
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: category.colors),
      ),
      child: Center(
        child: Text(
          category.emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
