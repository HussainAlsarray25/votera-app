import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/categories/domain/entities/category_entity.dart';
import 'package:votera/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/app_loading_indicator.dart';
import 'package:votera/shared/widgets/empty_state.dart';

/// Rotating color palette for category cards.
const _categoryGradients = [
  [Color(0xFF3B82F6), Color(0xFF6366F1)],
  [Color(0xFF22C55E), Color(0xFF10B981)],
  [Color(0xFFF59E0B), Color(0xFFEF4444)],
  [Color(0xFFEC4899), Color(0xFF8B5CF6)],
  [Color(0xFF10B981), Color(0xFF059669)],
  [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
];

/// Reusable body content for the Categories display.
/// Shows a header and a 2-column grid of category cards.
/// Used inside ExhibitionDetailPage as a tab body.
class CategoriesBody extends StatefulWidget {
  const CategoriesBody({required this.eventId, super.key});

  final String eventId;

  @override
  State<CategoriesBody> createState() => _CategoriesBodyState();
}

class _CategoriesBodyState extends State<CategoriesBody> {
  @override
  void initState() {
    super.initState();
    context.read<CategoriesCubit>().loadCategories(page: 1, size: 50);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: AppSpacing.lg),
          Expanded(child: _buildContent(context)),
        ],
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

  Future<void> _refresh() async {
    await context
        .read<CategoriesCubit>()
        .loadCategories(page: 1, size: 50);
  }

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading || state is CategoriesInitial) {
          return const Center(child: AppLoadingIndicator());
        }

        if (state is CategoriesError) {
          return _buildErrorState(context, state.message);
        }

        if (state is CategoriesLoaded) {
          final categories = state.response.items;
          if (categories.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: [
                  SizedBox(height: 80.r),
                  EmptyState(
                    icon: Icons.category_outlined,
                    title: AppLocalizations.of(context)!.noCategoriesYet,
                    subtitle: AppLocalizations.of(context)!.noCategoriesDesc,
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: _buildGrid(categories),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildGrid(List<CategoryEntity> categories) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.3,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _CategoryCard(
          category: categories[index],
          colors: _categoryGradients[index % _categoryGradients.length],
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: AppSizes.iconXxl, color: context.colors.error),
          SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => context
                .read<CategoriesCubit>()
                .loadCategories(page: 1, size: 50),
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.colors});

  final CategoryEntity category;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final initial =
        category.name.isNotEmpty ? category.name[0].toUpperCase() : '?';

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
          _buildIcon(initial),
          SizedBox(height: AppSpacing.sm),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              category.name,
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (category.description.isNotEmpty) ...[
            SizedBox(height: 2.r),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                category.description,
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon(String initial) {
    return Container(
      width: 52.r,
      height: 52.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: colors),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
