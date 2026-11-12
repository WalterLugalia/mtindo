import 'package:mtindo_app/features/feed/models/product.dart';

Product makeProduct(int id, {String name = 'Item', String? imageUrl}) {
  return Product(
    id: id,
    name: name,
    brandName: 'Brand',
    colour: 'Black',
    priceValue: 10,
    priceDisplay: r'$10.00',
    currency: 'USD',
    // Passing '' gives a product with no image, which widget tests need.
    imageUrl: imageUrl ?? 'https://images.example.com/$id',
    additionalImageUrls: const [],
    productUrl: 'https://www.asos.com/$id',
    category: 'Shoes',
  );
}