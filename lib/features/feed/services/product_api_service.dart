// lib/features/feed/services/product_api_service.dart
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/product.dart';
import '../models/product_lookup.dart';

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

  /// ASOS's error code for "no product with this ID" (seen in the real
  /// response when asking for ID 999999999).
  static const String _notFoundCode = 'pdt_015';

  /// Asks ASOS for one product by ID.
  ///
  /// It returns a ProductLookup instead of throwing for "removed" and
  /// "couldn't check", because those are normal outcomes the caller must
  /// tell apart, not exceptions.
  Future<ProductLookup> getProductById(int id) async {
    final Map<String, dynamic> response;

    try {
      // Only id is required. lang, store, sizeSchema and currency all
      // default to the same values the feed uses.
      response = await _apiClient.get(
        ApiConstants.productDetailV4,
        queryParameters: {'id': id},
      );
    } on Exception {
      // No connection, timeout, rate limit, server error. We know
      // nothing about the product.
      return const ProductLookupFailed();
    }

    // A missing product comes back as 200 OK with a LIST of error
    // objects. ApiClient wraps any list body as {'data': [...]}.
    final data = response['data'];
    if (data is List) {
      final isNotFound = data.any(
        (item) => item is Map && item['errorCode'] == _notFoundCode,
      );
      return isNotFound ? const ProductRemoved() : const ProductLookupFailed();
    }

    // A discontinued product can still be returned, flagged as such.
    if (response['isDiscontinued'] == true) return const ProductRemoved();

    // A real product: it should be an object with an id.
    if (response['id'] is! int) return const ProductLookupFailed();

    try {
      return ProductFound(Product.fromDetailJson(response));
    } catch (_) {
      // The shape was not what we expected. A parsing failure is not
      // proof the product is gone.
      return const ProductLookupFailed();
    }
  }
}