import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failure.dart';
import '../models/feed_result.dart';
import '../models/product.dart';
import '../models/product_lookup.dart';
import '../services/product_api_service.dart';
import '../services/product_cache_service.dart';

/// What the repository knows about one product ID.
sealed class ProductStatus {
  const ProductStatus();
}

/// Details are available (from the device or from the API).
class ProductKnown extends ProductStatus {
  final Product product;
  const ProductKnown(this.product);
}

/// ASOS confirmed the product no longer exists.
class ProductGone extends ProductStatus {
  const ProductGone();
}

/// Not known, and we couldn't find out (offline, rate limit, or we hit
/// the per-refresh lookup limit). Worth trying again later.
class ProductUnknown extends ProductStatus {
  const ProductUnknown();
}

/// Decides where product data comes from: the API when possible, the
/// saved copy when not.
class ProductRepository {
  final ProductApiService _apiService;
  final ProductCacheService _cacheService;

  ProductRepository(this._apiService, this._cacheService);

  /// How many products one refresh may look up by ID. The free RapidAPI
  /// plan has a monthly quota and each lookup spends some of it, so the
  /// rest wait for the next refresh.
  static const int _maxLookupsPerRefresh = 5;

  Future<FeedResult> getProducts({required String categoryId}) async {
    try {
      final products = await _apiService.getProducts(categoryId: categoryId);
      await _trySaveToCache(categoryId, products);

      return FeedResult(
        products: products,
        isFromCache: false,
        cachedAt: DateTime.now(),
      );
    } catch (error) {
      // The API failed. Use the saved copy if there is one.
      final cached = _tryReadFromCache(categoryId);
      if (cached != null) {
        return FeedResult(
          products: cached.products,
          isFromCache: true,
          cachedAt: cached.savedAt,
        );
      }

      // No saved copy either, so this is a real error for the user.
      throw mapExceptionToFailure(error);
    }
  }

.
  Future<Map<int, ProductStatus>> findProducts(Iterable<int> ids) async {
    final known = _cacheService.readKnownProducts();
    final removed = _cacheService.readRemovedProductIds();
    final result = <int, ProductStatus>{};
    var lookups = 0;

    for (final id in ids) {
      final saved = known[id];
      if (saved != null) {
        result[id] = ProductKnown(saved);
        continue;
      }

      if (removed.contains(id)) {
        result[id] = const ProductGone();
        continue;
      }

      if (lookups >= _maxLookupsPerRefresh) {
        result[id] = const ProductUnknown();
        continue;
      }

      lookups++;
      final lookup = await _apiService.getProductById(id);

      switch (lookup) {
        case ProductFound(:final product):
          await _tryRemember(product);
          result[id] = ProductKnown(product);
        case ProductRemoved():
          await _tryMarkRemoved(id);
          result[id] = const ProductGone();
        case ProductLookupFailed():
          result[id] = const ProductUnknown();
      }
    }

    return result;
  }

  /// Saving is best effort. A cache that can't be written must never
  /// break a feed that loaded fine, so cache errors are swallowed here.
  Future<void> _trySaveToCache(String categoryId, List<Product> products) async {
    // Never overwrite a good saved list with an empty one.
    if (products.isEmpty) return;

    try {
      await _cacheService.saveProducts(categoryId, products);
    } on CacheException {
      // Ignored on purpose.
    }
  }

  Future<void> _tryRemember(Product product) async {
    try {
      await _cacheService.rememberProduct(product);
    } on CacheException {
      // Ignored on purpose: the product still shows this time.
    }
  }

  Future<void> _tryMarkRemoved(int id) async {
    try {
      await _cacheService.markProductRemoved(id);
    } on CacheException {
      // Ignored on purpose.
    }
  }

  CachedProducts? _tryReadFromCache(String categoryId) {
    try {
      return _cacheService.readProducts(categoryId);
    } on CacheException {
      return null;
    }
  }
}