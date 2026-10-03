class StorageConstants {
  StorageConstants._();

  static const String productCacheBox = 'product_cache_box';
  static const String pendingVotesBox = 'pending_votes_box';
  static const String appSettingsBox = 'app_settings_box';

  static const String cachedProductsKey = 'cached_products';
  static const String cacheTimestampKey = 'cache_timestamp';

  static const Duration cacheStaleAfter = Duration(hours: 6);
}