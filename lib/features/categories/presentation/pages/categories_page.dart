import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

/// Grid page showing all project categories with emoji, name, and count.
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

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
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: CenteredContent(
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: AppSpacing.lg),
                Expanded(child: _buildGrid()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.categories,
          style: AppTypography.h1.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: context.colors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          l10n.browseByCategory,
          style: AppTypography.bodyMedium.copyWith(
            color: context.colors.textSecondary,
          ),
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
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
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
          SizedBox(height: AppSpacing.sm),
          Text(
            category.name,
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: 2.r),
          Text(
            AppLocalizations.of(context)!.projectCount(category.count),
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 52.r,
      height: 52.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: category.colors),
      ),
      child: Center(
        child: Text(
          category.emoji,
          style: TextStyle(fontSize: 24.sp),
        ),
      ),
    );
  }
}
