import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtindo_app/core/errors/failure.dart';
import 'package:mtindo_app/features/feed/models/feed_result.dart';
import 'package:mtindo_app/features/feed/models/product.dart';
import 'package:mtindo_app/features/feed/providers/feed_provider.dart';
import 'package:mtindo_app/features/feed/screens/feed_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/widget_helpers.dart';

void main() {
  final products = [
    makeProduct(1, name: 'Boot', imageUrl: ''),
    makeProduct(2, name: 'Sandal', imageUrl: ''),
  ];

  FeedResult feed(
    List<Product> items, {
    bool fromCache = false,
    Duration age = Duration.zero,
  }) {
    return FeedResult(
      products: items,
      isFromCache: fromCache,
      cachedAt: DateTime.now().subtract(age),
    );
  }

  Future<FakeFeedController> pumpFeed(
    WidgetTester tester,
    Future<FeedResult> Function() answer,
  ) async {
    useTallScreen(tester);
    final controller = FakeFeedController(answer);
    await pumpScreen(
      tester,
      const FeedScreen(),
      overrides: [feedProvider.overrideWith(() => controller)],
    );
    return controller;
  }

  testWidgets('shows a loading message while the feed loads', (tester) async {
    // A Future that never completes keeps the screen in its loading state.
    await pumpFeed(tester, () => Completer<FeedResult>().future);
    await tester.pump();

    expect(find.text('Loading the latest styles...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the products once loaded, with no banner or badge', (tester) async {
    await pumpFeed(tester, () async => feed(products));
    await tester.pumpAndSettle();

    expect(find.text('Boot'), findsOneWidget);
    expect(find.text('Sandal'), findsOneWidget);
    expect(find.text('Showing cached styles while offline'), findsNothing);
    expect(find.text('May be outdated'), findsNothing);
  });

  testWidgets('shows the offline banner, but no badge, for a recent saved copy', (tester) async {
    await pumpFeed(
      tester,
      () async => feed(products, fromCache: true, age: const Duration(hours: 1)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Showing cached styles while offline'), findsOneWidget);
    expect(find.text('May be outdated'), findsNothing);
  });

  testWidgets('adds the "May be outdated" badge to every card of a stale saved copy', (tester) async {
    await pumpFeed(
      tester,
      () async => feed(products, fromCache: true, age: const Duration(days: 1)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Showing cached styles while offline'), findsOneWidget);
    expect(find.text('May be outdated'), findsNWidgets(2));
  });

  testWidgets('never calls a fresh result stale, however old its timestamp', (tester) async {
    await pumpFeed(
      tester,
      () async => feed(products, fromCache: false, age: const Duration(days: 3)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Showing cached styles while offline'), findsNothing);
    expect(find.text('May be outdated'), findsNothing);
  });

  testWidgets('shows an empty-state message when there are no products', (tester) async {
    await pumpFeed(tester, () async => feed([]));
    await tester.pumpAndSettle();

    expect(find.text('No fashion items found right now.'), findsOneWidget);
  });

  testWidgets('shows the failure message, and Try Again asks for a refresh', (tester) async {
    final controller = await pumpFeed(
      tester,
      () => Future<FeedResult>.error(const NetworkFailure()),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No internet connection. Check your network and try again.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Try Again'));
    await tester.pump();

    expect(controller.refreshCalls, 1);
  });

  testWidgets('opens the item screen for the tapped product', (tester) async {
    await pumpFeed(tester, () async => feed(products));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sandal'));
    await tester.pumpAndSettle();

    expect(find.text('STUB ITEM 2'), findsOneWidget);
  });

  testWidgets('pulling down asks for a refresh', (tester) async {
    final controller = await pumpFeed(tester, () async => feed(products));
    await tester.pumpAndSettle();

    await tester.fling(find.byType(GridView), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    expect(controller.refreshCalls, 1);
  });
}