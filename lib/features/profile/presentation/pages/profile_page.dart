import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/profile/presentation/widgets/profile_actions_section.dart';
import 'package:votera/features/profile/presentation/widgets/profile_header_section.dart';
import 'package:votera/features/profile/presentation/widgets/profile_stats_section.dart';
import 'package:votera/features/profile/presentation/widgets/profile_voted_projects_section.dart';

/// User profile screen showing personal info, voting stats,
/// and a list of projects the user has voted for.
/// On tablet/desktop, uses a two-column layout.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (AppBreakpoints.isMobile(context)) {
      return _buildMobileLayout();
    }
    return _buildWideLayout();
  }

  Widget _buildMobileLayout() {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ProfileHeaderSection(),
              SizedBox(height: AppSpacing.lg),
              ProfileStatsSection(),
              SizedBox(height: AppSpacing.lg),
              ProfileVotedProjectsSection(),
              SizedBox(height: AppSpacing.lg),
              ProfileActionsSection(),
              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CenteredContent(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column: header + stats
                SizedBox(
                  width: 360,
                  child: Column(
                    children: [
                      ProfileHeaderSection(),
                      SizedBox(height: AppSpacing.lg),
                      ProfileStatsSection(),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                // Right column: voted projects + actions
                Expanded(
                  child: Column(
                    children: [
                      ProfileVotedProjectsSection(),
                      SizedBox(height: AppSpacing.lg),
                      ProfileActionsSection(),
                      SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
