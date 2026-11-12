import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtindo_app/app/theme/app_theme.dart';
import 'package:mtindo_app/features/leaderboard/models/leaderboard_item.dart';
import 'package:mtindo_app/features/leaderboard/widgets/leaderboard_item_card.dart';

import '../../helpers/test_helpers.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester,
    LeaderboardItem item, {
    VoidCallback? onTap,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          // Align loosens the Scaffold's tight constraints, so the card is
          // only as tall as it needs to be.
          body: Align(
            alignment: Alignment.topCenter,
            child: LeaderboardItemCard(item: item, onTap: onTap),
          ),
        ),
      ),
    );
  }

  testWidgets('shows rank with a leading zero, details and the vote count', (tester) async {
    await pumpCard(
      tester,
      LeaderboardItem(
        rank: 3,
        productId: 1,
        voteCount: 12,
        product: makeProduct(1, name: 'Chelsea boot', imageUrl: ''),
      ),
    );

    expect(find.text('03'), findsOneWidget);
    expect(find.text('Chelsea boot'), findsOneWidget);
    expect(find.text('Brand'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('votes'), findsOneWidget);
  });

  testWidgets('says "vote" for exactly one vote', (tester) async {
    await pumpCard(
      tester,
      LeaderboardItem(
        rank: 1,
        productId: 1,
        voteCount: 1,
        product: makeProduct(1, imageUrl: ''),
      ),
    );

    expect(find.text('vote'), findsOneWidget);
    expect(find.text('votes'), findsNothing);
  });

  testWidgets('explains a removed product and keeps its votes visible', (tester) async {
    await pumpCard(
      tester,
      const LeaderboardItem(
        rank: 2,
        productId: 2,
        voteCount: 9,
        product: null,
        missingReason: MissingReason.removed,
      ),
    );

    expect(find.text('No longer available'), findsOneWidget);
    expect(find.text('This item was removed from ASOS. Its votes still count.'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
  });

  testWidgets('tells the user to pull down when details could not load', (tester) async {
    await pumpCard(
      tester,
      const LeaderboardItem(
        rank: 4,
        productId: 4,
        voteCount: 2,
        product: null,
        missingReason: MissingReason.unknown,
      ),
    );

    expect(find.text('Details unavailable'), findsOneWidget);
    expect(find.text('Pull down to try loading it again'), findsOneWidget);
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var taps = 0;
    await pumpCard(
      tester,
      LeaderboardItem(
        rank: 1,
        productId: 1,
        voteCount: 1,
        product: makeProduct(1, name: 'Boot', imageUrl: ''),
      ),
      onTap: () => taps++,
    );

    await tester.tap(find.text('Boot'));

    expect(taps, 1);
  });
}