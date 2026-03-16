import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/project_details/presentation/widgets/project_comments_section.dart';
import 'package:votera/features/project_details/presentation/widgets/project_header_section.dart';
import 'package:votera/features/project_details/presentation/widgets/project_info_section.dart';
import 'package:votera/features/project_details/presentation/widgets/project_rating_section.dart';
import 'package:votera/shared/widgets/vote_button.dart';

/// Full details screen for a single project.
/// Shows the image, author info, rating, description, and comments.
/// On desktop, constrains content width and places the vote button inline.
class ProjectDetailsPage extends StatelessWidget {
  const ProjectDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = !AppBreakpoints.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CenteredContent(
        maxWidth: 900,
        child: CustomScrollView(
          slivers: [
            const ProjectHeaderSection(),
            SliverToBoxAdapter(child: _buildBody(showInlineVote: isWide)),
          ],
        ),
      ),
      // Only show the floating bottom bar on mobile
      bottomNavigationBar: isWide ? null : _buildBottomBar(),
    );
  }

  Widget _buildBody({required bool showInlineVote}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          const ProjectInfoSection(),
          const SizedBox(height: AppSpacing.lg),
          const ProjectRatingSection(),
          if (showInlineVote) ...[
            const SizedBox(height: AppSpacing.lg),
            VoteButton(voteCount: 48, onVote: () {}),
          ],
          const SizedBox(height: AppSpacing.lg),
          const ProjectCommentsSection(),
          const SizedBox(height: 100),
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
