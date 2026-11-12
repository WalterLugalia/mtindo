import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtindo_app/core/errors/failure.dart';
import 'package:mtindo_app/features/auth/models/app_user.dart';
import 'package:mtindo_app/features/item_detail/widgets/vote_section.dart';
import 'package:mtindo_app/features/voting/providers/vote_provider.dart';
import 'package:mtindo_app/features/voting/repositories/vote_repository.dart';

import '../../helpers/widget_helpers.dart';

const _productId = 5;
const _signedInUser = AppUser(id: 'user-1', email: 'a@b.co', name: '');

void main() {
  /// Shows a VoteSection with the given display state and returns the
  /// fake that records what the tap did.
  Future<FakePendingVotes> pumpSection(
    WidgetTester tester, {
    VoteDisplay display = const VoteDisplay(count: 12, hasVoted: false, isQueued: false),
    AppUser? user = _signedInUser,
    FakePendingVotes? votes,
  }) async {
    final fake = votes ?? FakePendingVotes();
    await pumpScreen(
      tester,
      const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: VoteSection(productId: _productId),
        ),
      ),
      overrides: voteOverrides(display: display, user: user, votes: fake),
    );
    return fake;
  }

  group('what it shows', () {
    testWidgets('shows the count and an unvoted button', (tester) async {
      await pumpSection(tester);

      expect(find.text('12'), findsOneWidget);
      expect(find.text('community votes'), findsOneWidget);
      expect(find.text('Vote'), findsOneWidget);
      expect(find.text('Voted'), findsNothing);
    });

    testWidgets('shows "Voted" once the user has voted', (tester) async {
      await pumpSection(
        tester,
        display: const VoteDisplay(count: 13, hasVoted: true, isQueued: false),
      );

      expect(find.text('Voted'), findsOneWidget);
      expect(find.text('Vote'), findsNothing);
    });

    testWidgets('shows a dash when the count is unknown', (tester) async {
      await pumpSection(
        tester,
        display: const VoteDisplay(count: null, hasVoted: false, isQueued: false),
      );

      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('shows the "saved on this device" hint only for a queued vote', (tester) async {
      const hint = 'Saved on this device. It will be sent once you are back online.';

      await pumpSection(tester);
      expect(find.text(hint), findsNothing);

      await pumpSection(
        tester,
        display: const VoteDisplay(count: 13, hasVoted: true, isQueued: true),
      );
      expect(find.text(hint), findsOneWidget);
    });
  });

  group('tapping the button', () {
    testWidgets('sends a signed-out user to the login screen and casts no vote', (tester) async {
      final votes = await pumpSection(tester, user: null);

      await tester.tap(find.text('Vote'));
      await tester.pumpAndSettle();

      expect(find.text('STUB LOGIN'), findsOneWidget);
      expect(votes.toggled, isEmpty);
    });

    testWidgets('toggles the vote for this product when signed in', (tester) async {
      final votes = await pumpSection(tester);

      await tester.tap(find.text('Vote'));
      await tester.pump();

      expect(votes.toggled, [_productId]);
      expect(find.text('STUB LOGIN'), findsNothing);
    });

    testWidgets('tells the user when the vote was saved for later', (tester) async {
      final votes = FakePendingVotes()..outcome = VoteOutcome.queued;
      await pumpSection(tester, votes: votes);

      await tester.tap(find.text('Vote'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('Saved. Your vote will be sent once you are back online.'),
        findsOneWidget,
      );
    });

    testWidgets('shows no message when the vote reached the server', (tester) async {
      await pumpSection(tester);

      await tester.tap(find.text('Vote'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('shows the failure message when voting fails', (tester) async {
      final votes = FakePendingVotes()..error = const VoteFailure('The server said no.');
      await pumpSection(tester, votes: votes);

      await tester.tap(find.text('Vote'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('The server said no.'), findsOneWidget);
    });
  });
}