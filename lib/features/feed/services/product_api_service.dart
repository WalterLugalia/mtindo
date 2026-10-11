// lib/features/feed/services/product_api_service.dart
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/product.dart';

/// Fetches raw product data from the ASOS API (via RapidAPI) and
/// converts it into Product models. No caching, no business logic,
/// just the network call and JSON-to-model mapping.
class ProductApiService {
  final ApiClient _apiClient;

  ProductApiService(this._apiClient);

  Future<List<Product>> getProducts({
    required String categoryId,
    String store = 'US',
    int offset = 0,
    int limit = ApiConstants.defaultPageSize,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.productsList,
      queryParameters: {
        'categoryId': categoryId,
        'store': store,
        'offset': offset,
        'limit': limit,
      },
    );

    // The category name appears once at the top level of the response
    // (e.g. "Shoes, Boots & Sneakers"), not inside each product.
    final category = (response['categoryName'] as String?) ?? '';

    final productsJson = (response['products'] as List?) ?? [];
    return productsJson
        .map(
          (item) => Product.fromJson(
            item as Map<String, dynamic>,
            category: category,
          ),
        )
        .toList();
  }
}