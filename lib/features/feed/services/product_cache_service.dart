
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/storage_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../models/product.dart';

/// A saved feed: the products and the moment they were saved.
class CachedProducts {
  final List<Product> products;
  final DateTime savedAt;

  const CachedProducts({required this.products, required this.savedAt});
}

/// Saves and reads the product list in Hive.
///
/// Like the API service, it knows nothing about screens or providers. It
/// takes products in and hands products back. Deciding when to use the
/// cache is the repository's job.
class ProductCacheService {
  final Box _box;

  ProductCacheService(this._box);

  String _productsKey(String categoryId) =>
      '${StorageConstants.cachedProductsKey}_$categoryId';

  String _timestampKey(String categoryId) =>
      '${StorageConstants.cacheTimestampKey}_$categoryId';

  Future<void> saveProducts(String categoryId, List<Product> products) async {
    try {
      final json = jsonEncode(products.map((p) => p.toMap()).toList());
      await _box.put(_productsKey(categoryId), json);
      await _box.put(
        _timestampKey(categoryId),
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {
      throw const CacheException('Could not save products locally.');
    }
  }

  CachedProducts? readProducts(String categoryId) {
    try {
      final json = _box.get(_productsKey(categoryId)) as String?;
      final savedAtMillis = _box.get(_timestampKey(categoryId)) as int?;
      if (json == null || savedAtMillis == null) return null;

      final decoded = jsonDecode(json) as List;
      final products = decoded
          .map((item) => Product.fromMap(item as Map<String, dynamic>))
          .toList();

      return CachedProducts(
        products: products,
        savedAt: DateTime.fromMillisecondsSinceEpoch(savedAtMillis),
      );
    } catch (_) {
      throw const CacheException('Saved products could not be read.');
    }
  }
}