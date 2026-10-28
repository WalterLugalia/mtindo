import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failure.dart';
import '../models/feed_result.dart';
import '../models/product.dart';
import '../services/product_api_service.dart';
import '../services/product_cache_service.dart';

/// Decides where the feed comes from: the API when possible, the saved
/// copy when not. This is the class the Phase 4 plan was reserving for
/// this job: it coordinates two data sources so nothing above it has to.
class ProductRepository {
  final ProductApiService _apiService;
  final ProductCacheService _cacheService;

  ProductRepository(this._apiService, this._cacheService);

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

  CachedProducts? _tryReadFromCache(String categoryId) {
    try {
      return _cacheService.readProducts(categoryId);
    } on CacheException {
      return null;
    }
  }
}