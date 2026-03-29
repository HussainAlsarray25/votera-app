import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/notification/presentation/cubit/unread_count_cubit.dart';
import 'package:votera/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

// Navigation destination descriptor — bundles icon, route, and label together
// so the dynamic items list can be built without hard-coded index math.
class _NavItem {
  const _NavItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class ShellPage extends StatelessWidget {
  const ShellPage({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        // Hide Teams until the profile is loaded and the role is confirmed.
        // Defaulting to false prevents the tab from flashing for visitors.
        // Show Teams for any user who holds at least one non-visitor role
        // (participant, admin, organizer, etc.).
        final canViewTeams = state is ProfileLoaded
            ? !state.profile.isVisitorOnly
            : false;

        final homeItem = _NavItem(
          route: '/home',
          label: l10n.home,
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
        );

        final teamsItem = _NavItem(
          route: '/teams',
          label: l10n.teams,
          icon: Icons.group_outlined,
          selectedIcon: Icons.group_rounded,
        );

        final profileItem = _NavItem(
          route: '/profile',
          label: l10n.profile,
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
        );

        final items = [
          homeItem,
          if (canViewTeams) teamsItem,
          profileItem,
        ];

        final selectedIndex = _resolveIndex(context, items);
        final showRail = AppBreakpoints.useNavigationRail(context);

        if (showRail) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  extended: AppBreakpoints.isDesktop(context),
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) =>
                      _onTap(context, items, index),
                  destinations: items
                      .map(
                        (item) => NavigationRailDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: Text(item.label),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: child),
              ],
            ),
          );
        }

        // Mobile: bottom navigation bar
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: selectedIndex,
            onTap: (index) => _onTap(context, items, index),
            items: items
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    activeIcon: Icon(item.selectedIcon),
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  /// Maps the current route to the visible items list index.
  /// Defaults to 0 (home) if no item matches.
  int _resolveIndex(BuildContext context, List<_NavItem> items) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < items.length; i++) {
      if (location.startsWith(items[i].route)) return i;
    }
    return 0;
  }

  void _onTap(BuildContext context, List<_NavItem> items, int index) {
    context.go(items[index].route);
  }
}

/// Notification icon button with a glowing red dot when there are unread
/// notifications. Use in app bars to navigate to the notifications page.
class NotificationIconButton extends StatelessWidget {
  const NotificationIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UnreadCountCubit, UnreadCountState>(
      builder: (context, state) {
        return IconButton(
          onPressed: () => context.push('/notifications'),
          icon: state.count > 0
              ? Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined),
                    Positioned(
                      top: -1,
                      right: -1,
                      child: _UnreadDot(),
                    ),
                  ],
                )
              : const Icon(Icons.notifications_outlined),
        );
      },
    );
  }
}

class _UnreadDot extends StatefulWidget {
  @override
  State<_UnreadDot> createState() => _UnreadDotState();
}

class _UnreadDotState extends State<_UnreadDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _glow = Tween<double>(begin: 2, end: 7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const dotSize = 8.0;
    final dotColor = context.colors.error;

    return AnimatedBuilder(
      animation: _glow,
      builder: (context, _) {
        return Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: dotColor.withValues(alpha: 0.7),
                blurRadius: _glow.value,
                spreadRadius: _glow.value * 0.3,
              ),
            ],
          ),
        );
      },
    );
  }
}
