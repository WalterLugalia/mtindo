
import '../../../core/errors/failure.dart';
import '../models/product.dart';
import '../services/product_api_service.dart';

/// Sits between ProductApiService and the provider layer — converts
/// raw exceptions into Failures, matching the pattern used in auth.
class ProductRepository {
  final ProductApiService _apiService;

  ProductRepository(this._apiService);

  Future<List<Product>> getProducts({required String categoryId}) async {
    try {
      return await _apiService.getProducts(categoryId: categoryId);
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
  }
}