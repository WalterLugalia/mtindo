
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/network_info.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../services/product_api_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(Connectivity());
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(networkInfoProvider));
});

final productApiServiceProvider = Provider<ProductApiService>((ref) {
  return ProductApiService(ref.watch(apiClientProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(productApiServiceProvider));
});

/// Holds the fetched feed. AsyncNotifier gives us loading/error/data
/// states automatically via AsyncValue.
final feedProvider = AsyncNotifierProvider<FeedController, List<Product>>(
  FeedController.new,
);

class FeedController extends AsyncNotifier<List<Product>> {
  // ASOS category ID for "Shoes, Boots & Sneakers" — the category we
  // tested against. Swap this for whatever category fits the app.
  static const String _categoryId = '4209';

  @override
  Future<List<Product>> build() {
    return ref.read(productRepositoryProvider).getProducts(categoryId: _categoryId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(productRepositoryProvider).getProducts(categoryId: _categoryId),
    );
  }
}