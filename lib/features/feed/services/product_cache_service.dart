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

/// Saves and reads products in Hive. It stores and fetches only;
/// deciding when to use the cache is the repository's job.
class ProductCacheService {
  final Box _box;

  ProductCacheService(this._box);

  /// The known-products index never grows past this many entries.
  static const int _maxKnownProducts = 300;

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
      await _rememberProducts(products);
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

  /// Every product this device has ever loaded, by ID. Unlike the feed
  /// cache (replaced on each fetch), this index keeps products that later
  /// drop out of the feed, so the leaderboard can still describe them.
  /// Never throws: "nothing known" is an acceptable answer.
  Map<int, Product> readKnownProducts() {
    final known = <int, Product>{};

    for (final entry in _readKnownMaps().entries) {
      try {
        known[int.parse(entry.key)] =
            Product.fromMap(entry.value as Map<String, dynamic>);
      } catch (_) {
        // Skip a damaged entry instead of losing the rest.
      }
    }

    return known;
  }

    /// Saves one product into the known-products index, so the leaderboard
  /// can describe it later without another API call.
  Future<void> rememberProduct(Product product) async {
    try {
      await _rememberProducts([product]);
    } catch (_) {
      throw const CacheException('Could not save the product locally.');
    }
  }
  

  Future<void> _rememberProducts(List<Product> products) async {
    final known = _readKnownMaps();

    for (final product in products) {
      // Remove, then add: a re-seen product moves to the end, so the
      // front of the map always holds the least recently seen ones.
      known.remove('${product.id}');
      known['${product.id}'] = product.toMap();
    }

    // Dart maps keep insertion order, so keys.first is the oldest entry.
    while (known.length > _maxKnownProducts) {
      known.remove(known.keys.first);
    }

    await _box.put(StorageConstants.knownProductsKey, jsonEncode(known));
  }

  /// The index as raw maps, keyed by product ID as a string (JSON object
  /// keys must be strings).
  Map<String, dynamic> _readKnownMaps() {
    final raw = _box.get(StorageConstants.knownProductsKey) as String?;
    if (raw == null) return {};

    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {};
    }
  }

    /// IDs ASOS has confirmed are gone. Remembering them stops the app
  /// asking the API about the same removed product on every refresh.
  Set<int> readRemovedProductIds() {
    final raw = _box.get(StorageConstants.removedProductIdsKey) as String?;
    if (raw == null) return {};

    try {
      return (jsonDecode(raw) as List).map((e) => e as int).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> markProductRemoved(int productId) async {
    try {
      final removed = readRemovedProductIds()..add(productId);
      await _box.put(
        StorageConstants.removedProductIdsKey,
        jsonEncode(removed.toList()),
      );
    } catch (_) {
      throw const CacheException('Could not save the product status locally.');
    }
  }
}