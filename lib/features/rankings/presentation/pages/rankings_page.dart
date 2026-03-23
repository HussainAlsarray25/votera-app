import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';

/// Legacy standalone rankings page.
/// Not currently used in the routing -- rankings are shown inside
/// ExhibitionDetailPage via the RankingsBody widget.
class RankingsPage extends StatelessWidget {
  const RankingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: CenteredContent(
          child: Center(
            child: Text(
              'Rankings are now shown inside exhibition details.',
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
