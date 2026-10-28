import '../../../core/constants/storage_constants.dart';
import 'product.dart';

/// What the Feed screen receives: the products plus where they came from.
///
/// Before the cache existed the Feed only needed a List<Product>. Now it
/// also needs to know whether the list is fresh from the API or a saved
/// copy, so it can show the offline banner and the "May be outdated" badge.
class FeedResult {
  final List<Product> products;
  final bool isFromCache;
  final DateTime cachedAt;

  const FeedResult({
    required this.products,
    required this.isFromCache,
    required this.cachedAt,
  });

  /// True only for a saved copy older than the stale window (6 hours,
  /// defined in StorageConstants). Fresh API results are never stale.
  bool get isStale =>
      isFromCache &&
      DateTime.now().difference(cachedAt) > StorageConstants.cacheStaleAfter;
}