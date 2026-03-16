import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';

/// Collapsible app bar with the project image, back button,
/// and share action. Height scales up on wider screens.
class ProjectHeaderSection extends StatelessWidget {
  const ProjectHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final expandedHeight = AppBreakpoints.isMobile(context) ? 260.0 : 360.0;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      backgroundColor: AppColors.surface,
      leading: _buildBackButton(context),
      actions: [_buildShareButton()],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildImage(),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CircleAvatar(
        backgroundColor: Colors.black26,
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CircleAvatar(
        backgroundColor: Colors.black26,
        child: IconButton(
          icon: const Icon(Icons.share, color: Colors.white, size: 20),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildImage() {
    return const ColoredBox(
      color: AppColors.border,
      child: Center(
        child: Icon(Icons.code, size: 64, color: AppColors.textHint),
      ),
    );
  }
}
