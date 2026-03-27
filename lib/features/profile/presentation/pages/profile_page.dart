import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:votera/features/profile/presentation/widgets/profile_actions_section.dart';
import 'package:votera/features/profile/presentation/widgets/profile_header_section.dart';

/// User profile screen showing personal info, voting stats,
/// and account actions.
/// On tablet/desktop, uses a two-column layout.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load profile data if not already loaded
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is! ProfileLoaded) {
      context.read<ProfileCubit>().loadProfile().ignore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AppBreakpoints.isMobile(context)) {
      return _buildMobileLayout();
    }
    return _buildWideLayout();
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<ProfileCubit>().forceRefresh(),
          color: context.colors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const ProfileHeaderSection(),
                SizedBox(height: AppSpacing.lg),
                const ProfileActionsSection(),
                SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: CenteredContent(
          child: RefreshIndicator(
            onRefresh: () => context.read<ProfileCubit>().forceRefresh(),
            color: context.colors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column: header + stats
                  SizedBox(
                    width: 360,
                    child: const Column(
                      children: [
                        ProfileHeaderSection(),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.lg),
                  // Right column: actions
                  Expanded(
                    child: Column(
                      children: [
                        const ProfileActionsSection(),
                        SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
