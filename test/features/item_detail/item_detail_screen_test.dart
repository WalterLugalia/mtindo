import 'package:flutter_test/flutter_test.dart';
import 'package:mtindo_app/features/feed/models/product.dart';
import 'package:mtindo_app/features/item_detail/screens/item_detail_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/widget_helpers.dart';

void main() {
  testWidgets('shows brand, name, price and category', (tester) async {
    useTallScreen(tester);
    await pumpScreen(
      tester,
      ItemDetailScreen(
        product: makeProduct(1, name: 'Chelsea boot', imageUrl: ''),
      ),
      overrides: voteOverrides(),
    );

    expect(find.text('Item details'), findsOneWidget);
    expect(find.text('Brand'), findsOneWidget);
    expect(find.text('Chelsea boot'), findsOneWidget);
    expect(find.text(r'$10.00'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Shoes'), findsOneWidget);
    expect(find.text('community votes'), findsOneWidget);
  });

  testWidgets('hides the price and category rows when the product has none', (tester) async {
    // A product fetched by ID has neither (the v4 detail endpoint returns
    // no price), so the screen must not leave blank gaps for them.
    final product = Product.fromDetailJson({
      'id': 1,
      'name': 'No price boot',
      'brand': {'name': 'Brand'},
    });

    useTallScreen(tester);
    await pumpScreen(
      tester,
      ItemDetailScreen(product: product),
      overrides: voteOverrides(),
    );

    expect(find.text('No price boot'), findsOneWidget);
    expect(find.text('Category'), findsNothing);
    // An empty Text would match find.text(''), so none should exist.
    expect(find.text(''), findsNothing);
  });
}