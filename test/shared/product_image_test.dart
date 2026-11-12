import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtindo_app/shared/widgets/product_image.dart';

void main() {
  testWidgets('shows a placeholder icon instead of crashing on an empty URL', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SizedBox(width: 100, height: 100, child: ProductImage(url: ''))),
      ),
    );

    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
  });
}