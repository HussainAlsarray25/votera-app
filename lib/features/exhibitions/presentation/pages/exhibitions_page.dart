import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/exhibitions/presentation/demo_data.dart';
import 'package:votera/features/exhibitions/presentation/widgets/exhibition_card.dart';

/// Main home page showing a list of exhibitions/events.
/// Replaces the old project-centric home page in the bottom nav shell.
class ExhibitionsPage extends StatelessWidget {
  const ExhibitionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final exhibitions = createDemoExhibitions();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CenteredContent(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final exhibition = exhibitions[index];
                      return ExhibitionCard(
                        exhibition: exhibition,
                        onTap: () =>
                            context.push('/exhibition/${exhibition.id}'),
                      );
                    },
                    childCount: exhibitions.length,
                  ),
                ),
              ),
              // Bottom padding so the last card is not hidden by the nav bar
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, AppSpacing.md, 20, AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Votera',
                style: AppTypography.h1.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Explore exhibitions & events',
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
          GestureDetector(
            onTap: () => context.push('/notifications'),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
