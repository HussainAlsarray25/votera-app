import 'package:flutter/widgets.dart';

/// Holds the real (unclamped) screen dimensions for use by layout code.
///
/// The app clamps the MediaQuery passed to ScreenUtil so that token values
/// (.r, .sp, .w, .h) never scale above 1× on wide screens. But that same
/// clamping would break AppBreakpoints, CenteredContent, and NavigationRail
/// logic, which all need the real viewport width to choose the right layout.
///
/// This InheritedWidget is inserted above MaterialApp and stores the true
/// screen size before any clamping. AppBreakpoints reads from here instead
/// of from MediaQuery so responsive layout decisions are always correct.
class RealViewport extends InheritedWidget {
  const RealViewport({
    required this.size,
    required super.child,
    super.key,
  });

  final Size size;

  /// Returns the real unclamped screen size.
  /// Falls back to MediaQuery if no RealViewport ancestor exists (e.g. in
  /// tests or before the widget is inserted).
  static Size sizeOf(BuildContext context) {
    final viewport = context.dependOnInheritedWidgetOfExactType<RealViewport>();
    return viewport?.size ?? MediaQuery.sizeOf(context);
  }

  @override
  bool updateShouldNotify(RealViewport old) => size != old.size;
}
