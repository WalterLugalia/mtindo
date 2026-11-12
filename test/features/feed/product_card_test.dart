import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtindo_app/app/theme/app_theme.dart';
import 'package:mtindo_app/features/feed/models/product.dart';
import 'package:mtindo_app/features/feed/widgets/product_card.dart';

import '../../helpers/test_helpers.dart';

void main() {
  /// Shows one card in a fixed 200 x 400 box, a typical grid cell.
  Future<void> pumpCard(
    WidgetTester tester, {
    required Product product,
    VoidCallback? onTap,
    bool showOutdatedBadge = false,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 400,
              child: ProductCard(
                product: product,
                onTap: onTap ?? () {},
                showOutdatedBadge: showOutdatedBadge,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows the name, brand and price', (tester) async {
    await pumpCard(
      tester,
      product: makeProduct(1, name: 'Chelsea boot', imageUrl: ''),
    );

    expect(find.text('Chelsea boot'), findsOneWidget);
    expect(find.text('Brand'), findsOneWidget);
    expect(find.text(r'$10.00'), findsOneWidget);
  });

  testWidgets('shows a placeholder icon when the product has no image', (tester) async {
    await pumpCard(tester, product: makeProduct(1, imageUrl: ''));

    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
  });

  testWidgets('shows the "May be outdated" badge only when asked to', (tester) async {
    final product = makeProduct(1, imageUrl: '');

    await pumpCard(tester, product: product);
    expect(find.text('May be outdated'), findsNothing);

    await pumpCard(tester, product: product, showOutdatedBadge: true);
    expect(find.text('May be outdated'), findsOneWidget);
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var taps = 0;
    await pumpCard(
      tester,
      product: makeProduct(1, name: 'Boot', imageUrl: ''),
      onTap: () => taps++,
    );

    await tester.tap(find.text('Boot'));

    expect(taps, 1);
  });

  testWidgets('copes with a very long name without overflowing', (tester) async {
    // Regression test for the "BOTTOM OVERFLOWED" error from the first
    // version of the Feed grid.
    await pumpCard(
      tester,
      product: makeProduct(
        1,
        name: 'An extremely long product name that goes on and on ' * 4,
        imageUrl: '',
      ),
      showOutdatedBadge: true,
    );

    expect(tester.takeException(), isNull);
  });
}