// test/helpers/widget_helpers.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved the Override type here. If your analyzer says this
// import is unnecessary, delete the line.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mtindo_app/app/theme/app_theme.dart';
import 'package:mtindo_app/features/auth/models/app_user.dart';
import 'package:mtindo_app/features/auth/providers/auth_provider.dart';
import 'package:mtindo_app/features/feed/models/feed_result.dart';
import 'package:mtindo_app/features/feed/models/pending_vote.dart';
import 'package:mtindo_app/features/feed/providers/feed_provider.dart';

import 'package:mtindo_app/features/voting/providers/vote_provider.dart';
import 'package:mtindo_app/features/voting/repositories/vote_repository.dart';

/// Makes the fake screen tall enough that long forms and grids need no
/// scrolling. The size is restored automatically when the test ends.
void useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Shows [screen] at "/" inside the real theme and a stub router.
///
/// The stub routes show recognisable text, so a test can check that a tap
/// navigated to the right place without building the real destination.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  List<Override> overrides = const [],
}) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => screen),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(body: Text('STUB LOGIN')),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const Scaffold(body: Text('STUB SIGNUP')),
      ),
      GoRoute(
        path: '/item/:id',
        builder: (context, state) => Scaffold(
          body: Text('STUB ITEM ${state.pathParameters['id']}'),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      // No automatic retries: a retry leaves a timer pending at the end of
      // the test, and a failing provider should simply show its error.
      retry: (retryCount, error) => null,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pump();
}

// ---------------------------------------------------------------------
// Fake controllers. Each extends the real class and replaces the parts
// that would talk to Supabase, Hive or the network.
// ---------------------------------------------------------------------

/// Records sign-in and sign-up attempts instead of calling Supabase.
class FakeAuthController extends AuthController {
  final List<({String email, String password})> signIns = [];
  final List<({String name, String email, String password})> signUps = [];

  /// If set, the next sign-in or sign-up moves the controller to this
  /// state, which is how a test makes a failure or a spinner appear.
  AsyncValue<void>? nextState;

  @override
  Future<void> signIn({required String email, required String password}) async {
    signIns.add((email: email, password: password));
    final next = nextState;
    if (next != null) state = next;
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    signUps.add((name: name, email: email, password: password));
    final next = nextState;
    if (next != null) state = next;
  }
}

/// A feed controller whose answer the test decides, and which counts how
/// often a refresh was requested.
class FakeFeedController extends FeedController {
  FakeFeedController(this._answer);

  final Future<FeedResult> Function() _answer;
  int refreshCalls = 0;

  @override
  Future<FeedResult> build() => _answer();

  @override
  Future<void> refresh() async {
    refreshCalls++;
  }
}

/// Stands in for the vote queue controller. Records which products were
/// toggled and returns whatever outcome (or error) the test chose.
class FakePendingVotes extends PendingVotesController {
  final List<int> toggled = [];
  VoteOutcome? outcome = VoteOutcome.synced;
  Object? error;

  // The real build() reads storage and starts listening for connectivity.
  @override
  Map<int, PendingVote> build() => {};

  @override
  Future<VoteOutcome?> toggleVote(int productId) async {
    toggled.add(productId);
    final failure = error;
    if (failure != null) throw failure;
    return outcome;
  }
}

/// The three provider overrides every screen containing a VoteSection
/// needs: what it displays, who is signed in, and who handles the tap.
List<Override> voteOverrides({
  VoteDisplay display = const VoteDisplay(
    count: 0,
    hasVoted: false,
    isQueued: false,
  ),
  AppUser? user,
  FakePendingVotes? votes,
}) {
  final fake = votes ?? FakePendingVotes();
  return [
    voteDisplayProvider.overrideWith((ref, productId) => display),
    currentUserProvider.overrideWith((ref) => user),
    pendingVotesProvider.overrideWith(() => fake),
  ];
}