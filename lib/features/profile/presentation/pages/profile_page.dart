import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/profile/presentation/widgets/profile_actions_section.dart';
import 'package:votera/features/profile/presentation/widgets/profile_header_section.dart';
import 'package:votera/features/profile/presentation/widgets/profile_stats_section.dart';
import 'package:votera/features/profile/presentation/widgets/profile_voted_projects_section.dart';

/// User profile screen showing personal info, voting stats,
/// and a list of projects the user has voted for.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
}
