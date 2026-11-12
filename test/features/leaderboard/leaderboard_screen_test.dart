import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtindo_app/core/errors/failure.dart';
import 'package:mtindo_app/features/leaderboard/models/leaderboard_item.dart';
import 'package:mtindo_app/features/leaderboard/providers/leaderboard_provider.dart';
import 'package:mtindo_app/features/leaderboard/screens/leaderboard_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/widget_helpers.dart';

void main() {
  final items = [
    LeaderboardItem(
      rank: 1,
      productId: 1,
      voteCount: 12,
      product: makeProduct(1, name: 'Boot', imageUrl: ''),
    ),
    const LeaderboardItem(
      rank: 2,
      productId: 2,
      voteCount: 5,
      product: null,
      missingReason: MissingReason.removed,
    ),
    const LeaderboardItem(
      rank: 3,
      productId: 3,
      voteCount: 1,
      product: null,
      missingReason: MissingReason.unknown,
    ),
  ];

  testWidgets('shows a loading message while counting the votes', (tester) async {
    useTallScreen(tester);
    await pumpScreen(
      tester,
      const LeaderboardScreen(),
      overrides: [
        leaderboardProvider.overrideWith((ref) => Completer<List<LeaderboardItem>>().future),
      ],
    );
    await tester.pump();

    expect(find.text('Counting the votes...'), findsOneWidget);
  });

  testWidgets('shows the ranked rows, including removed and unknown products', (tester) async {
    useTallScreen(tester);
    await pumpScreen(
      tester,
      const LeaderboardScreen(),
      overrides: [leaderboardProvider.overrideWith((ref) async => items)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Top Voted'), findsOneWidget);
    expect(find.text('01'), findsOneWidget);
    expect(find.text('02'), findsOneWidget);
    expect(find.text('03'), findsOneWidget);
    expect(find.text('Boot'), findsOneWidget);
    expect(find.text('No longer available'), findsOneWidget);
    expect(find.text('Details unavailable'), findsOneWidget);
  });

  testWidgets('shows an empty-state message when nobody has voted', (tester) async {
    useTallScreen(tester);
    await pumpScreen(
      tester,
      const LeaderboardScreen(),
      overrides: [leaderboardProvider.overrideWith((ref) async => <LeaderboardItem>[])],
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('No votes yet'), findsOneWidget);
  });

  testWidgets('shows the failure message, and Try Again loads it again', (tester) async {
    var loads = 0;
    useTallScreen(tester);
    await pumpScreen(
      tester,
      const LeaderboardScreen(),
      overrides: [
        leaderboardProvider.overrideWith((ref) async {
          loads++;
          throw const NetworkFailure();
        }),
      ],
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No internet connection. Check your network and try again.'),
      findsOneWidget,
    );
    expect(loads, 1);

    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();

    expect(loads, 2);
  });

  testWidgets('opens the item screen for a row that has details', (tester) async {
    useTallScreen(tester);
    await pumpScreen(
      tester,
      const LeaderboardScreen(),
      overrides: [leaderboardProvider.overrideWith((ref) async => items)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Boot'));
    await tester.pumpAndSettle();

    expect(find.text('STUB ITEM 1'), findsOneWidget);
  });

  testWidgets('does nothing when a row without details is tapped', (tester) async {
    useTallScreen(tester);
    await pumpScreen(
      tester,
      const LeaderboardScreen(),
      overrides: [leaderboardProvider.overrideWith((ref) async => items)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Details unavailable'));
    await tester.pumpAndSettle();

    expect(find.textContaining('STUB ITEM'), findsNothing);
    expect(find.text('Top Voted'), findsOneWidget);
  });

  testWidgets('pulling down loads the leaderboard again', (tester) async {
    var loads = 0;
    useTallScreen(tester);
    await pumpScreen(
      tester,
      const LeaderboardScreen(),
      overrides: [
        leaderboardProvider.overrideWith((ref) async {
          loads++;
          return items;
        }),
      ],
    );
    await tester.pumpAndSettle();
    expect(loads, 1);

    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    expect(loads, 2);
  });
}