import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/leaderboard/providers/leaderboard_provider.dart';
import '../theme/app_colors.dart';

/// The frame around the two tab screens: the bottom navigation bar, plus
/// whichever tab is currently selected as the body.
///
/// go_router builds this once and hands it a StatefulNavigationShell. The
/// shell is the tab content itself, and also the remote control for
/// switching tabs.
class MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  static const int _leaderboardTab = 1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // A thin line above the bar, like the mockup.
          const Divider(height: 1, color: AppColors.border),
          BottomNavigationBar(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) => _onTabSelected(ref, index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.surface,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textMuted,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_outlined),
                activeIcon: Icon(Icons.grid_view_rounded),
                label: 'Feed',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events_outlined),
                activeIcon: Icon(Icons.emoji_events),
                label: 'Top Voted',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onTabSelected(WidgetRef ref, int index) {
    // Tab screens stay alive while you are on the other tab, so the
    // leaderboard would otherwise show counts from the first time it was
    // opened. Reload it whenever its tab is selected.
    if (index == _leaderboardTab) {
      ref.invalidate(leaderboardProvider);
    }

    navigationShell.goBranch(
      index,
      // Tapping the tab you are already on jumps back to that tab's first
      // screen (the usual behavior of bottom bars).
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}