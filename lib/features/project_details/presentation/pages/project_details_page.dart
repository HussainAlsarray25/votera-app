import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/project_details/presentation/widgets/project_comments_section.dart';
import 'package:votera/features/project_details/presentation/widgets/project_header_section.dart';
import 'package:votera/features/project_details/presentation/widgets/project_info_section.dart';
import 'package:votera/features/project_details/presentation/widgets/project_rating_section.dart';
import 'package:votera/shared/widgets/vote_button.dart';

/// Full details screen for a single project.
/// Shows the image, author info, rating, description, and comments.
class ProjectDetailsPage extends StatelessWidget {
  const ProjectDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const ProjectHeaderSection(),
          SliverToBoxAdapter(child: _buildBody()),
        ],
      ),
      // Floating vote button pinned at the bottom
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSpacing.md),
          ProjectInfoSection(),
          SizedBox(height: AppSpacing.lg),
          ProjectRatingSection(),
          SizedBox(height: AppSpacing.lg),
          ProjectCommentsSection(),
          SizedBox(height: 100), // space for bottom bar
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: VoteButton(
          voteCount: 48,
          onVote: () {},
        ),
      ),
    );
  }
}
