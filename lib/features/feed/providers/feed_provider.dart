import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/network_providers.dart';
import '../../../core/storage/hive_service.dart';
import '../models/feed_result.dart';
import '../repositories/product_repository.dart';
import '../services/product_api_service.dart';
import '../services/product_cache_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(networkInfoProvider));
});

final productApiServiceProvider = Provider<ProductApiService>((ref) {
  return ProductApiService(ref.watch(apiClientProvider));
});

final productCacheServiceProvider = Provider<ProductCacheService>((ref) {
  return ProductCacheService(HiveService.productCacheBox);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(
    ref.watch(productApiServiceProvider),
    ref.watch(productCacheServiceProvider),
  );
});

final feedProvider = AsyncNotifierProvider<FeedController, FeedResult>(
  FeedController.new,
);

class FeedController extends AsyncNotifier<FeedResult> {
  static const String _categoryId = '4209';

  @override
  Future<FeedResult> build() {
    return ref.read(productRepositoryProvider).getProducts(
          categoryId: _categoryId,
        );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(productRepositoryProvider).getProducts(
            categoryId: _categoryId,
          ),
    );
  }
}