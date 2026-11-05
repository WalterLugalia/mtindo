import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_constants.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/feed/models/product.dart';
import '../../features/feed/screens/feed_screen.dart';
import '../../features/item_detail/screens/item_detail_screen.dart';
import '../../features/leaderboard/screens/leaderboard_screen.dart';
import 'main_shell.dart';
import 'not_found_screen.dart';

/// The app's single router, created once and shared.
///
/// It is a provider (not a global variable, and not created inside a
/// build method) so there is exactly one for the app's lifetime. If it
/// were rebuilt with the widget tree, navigation would reset to the Feed
/// on every rebuild.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: RouteConstants.feed,

    // Any address that matches no route lands here.
    errorBuilder: (context, state) => const NotFoundScreen(),

    routes: [
      // The two tabs. Each branch is a separate stack of screens, and
      // indexedStack keeps every visited tab alive in the background.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.feed,
                builder: (context, state) => const FeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.leaderboard,
                builder: (context, state) => const LeaderboardScreen(),
              ),
            ],
          ),
        ],
      ),

      // Everything below sits outside the tab bar, so these screens
      // cover it (as in the mockup) and Back returns to the same tab.
      GoRoute(
        path: RouteConstants.itemDetailPattern,
        builder: (context, state) {
          final extra = state.extra;
          final idInAddress = state.pathParameters['id'];

          // The Product travels in `extra`, which is lost if the app is
          // opened straight at this address. Check it is really the
          // product named in the address before trusting it.
          if (extra is Product && '${extra.id}' == idInAddress) {
            return ItemDetailScreen(product: extra);
          }

          return const NotFoundScreen(
            message: 'That item can only be opened from the Feed or the '
                'Top Voted list.',
          );
        },
      ),
      GoRoute(
        path: RouteConstants.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.signup,
        builder: (context, state) => const SignupScreen(),
      ),
    ],
  );

  // Release the router's listeners when the provider is torn down.
  ref.onDispose(router.dispose);

  return router;
});