import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/features/force_update/presentation/cubit/force_update_cubit.dart';
import 'package:votera/features/force_update/presentation/widgets/force_update_dialog.dart';

/// Wraps the entire app content and overlays a non-dismissible update dialog
/// when [ForceUpdateCubit] emits [ForceUpdateRequired].
///
/// The overlay sits above the Navigator so it blocks all routes uniformly
/// and cannot be bypassed by back gestures or deep links.
class ForceUpdateGuard extends StatelessWidget {
  const ForceUpdateGuard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForceUpdateCubit, ForceUpdateState>(
      builder: (context, state) {
        if (state is ForceUpdateRequired) {
          return Stack(
            children: [
              // Render the app content behind the overlay so the user can
              // see it but cannot interact with it.
              child,
              // Frosted-glass blur layer over the entire screen.
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: const ColoredBox(color: Colors.black45),
                ),
              ),
              // Full-screen modal barrier that blocks all touch input.
              const ModalBarrier(dismissible: false),
              // Centered dialog overlay.
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ForceUpdateDialog(
                    updateUrl: state.updateUrl,
                    latestVersionName: state.latestVersionName,
                    messageEn: state.messageEn,
                    messageAr: state.messageAr,
                  ),
                ),
              ),
            ],
          );
        }
        // All other states: render the app normally.
        return child;
      },
    );
  }
}
