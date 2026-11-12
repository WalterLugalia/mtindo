// lib/app/router/app_router.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_constants.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/feed/models/product.dart';
import '../../features/feed/screens/feed_screen.dart';
import '../../features/item_detail/screens/item_detail_screen.dart';
import '../../features/leaderboard/screens/leaderboard_screen.dart';
import 'main_shell.dart';
import 'not_found_screen.dart';

/// A bell the router listens to. Ringing it makes go_router run its
/// redirect rule again. go_router only re-checks a redirect when the
/// address changes or when a listenable like this one fires.
class _RouterRefresh extends ChangeNotifier {
  void ring() => notifyListeners();
}

/// The app's single router, created once and shared.
///
/// It is a provider (not a global variable, and not created inside a
/// build method) so there is exactly one for the app's lifetime. If it
/// were rebuilt with the widget tree, navigation would reset on every
/// rebuild.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();

  // Ring the bell when someone signs in or out. Only the user's ID is
  // watched, so the routine token refreshes Supabase does in the
  // background (which hand out a new AppUser object each time) don't
  // trigger a pointless redirect check.
  ref.listen<String?>(
    currentUserProvider.select((user) => user?.id),
    (previous, next) => refresh.ring(),
  );

  final router = GoRouter(
    initialLocation: RouteConstants.feed,
    refreshListenable: refresh,

    // Runs before every navigation, and again whenever the bell rings.
    // Returning an address sends the user there instead. Returning null
    // lets them go where they asked.
    redirect: (context, state) {
      final signedIn = ref.read(currentUserProvider) != null;
      final location = state.matchedLocation;
      final onAuthPage =
          location == RouteConstants.login || location == RouteConstants.signup;

      // Signed out and trying to see anything but the login or signup
      // pages: send them to log in.
      if (!signedIn && !onAuthPage) return RouteConstants.login;

      // Signed in but on the login or signup page, which happens right
      // after a successful sign-in or sign-up: send them to the Feed.
      if (signedIn && onAuthPage) return RouteConstants.feed;

      return null;
    },

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

  // Release the router and its bell when the provider is torn down.
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });

  return router;
});