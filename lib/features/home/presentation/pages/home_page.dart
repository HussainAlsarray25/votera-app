import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';

/// Legacy standalone home page.
/// Not currently used in the routing -- the app now uses ExhibitionsPage
/// at /home and ExhibitionDetailPage for project browsing.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CenteredContent(
          child: Center(
            child: Text(
              'Projects are now shown inside exhibition details.',
              style: AppTypography.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}
