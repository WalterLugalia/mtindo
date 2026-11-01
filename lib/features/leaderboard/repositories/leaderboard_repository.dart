import '../../../core/errors/failure.dart';
import '../../feed/repositories/product_repository.dart';
import '../models/leaderboard_item.dart';
import '../services/leaderboard_service.dart';

/// Joins the two data sources: vote counts from Supabase, product
/// details from the product repository.
class LeaderboardRepository {
  final LeaderboardService _service;
  final ProductRepository _products;

  LeaderboardRepository(this._service, this._products);

  Future<List<LeaderboardItem>> getTopVoted() async {
    try {
      final tallies = await _service.getTopVoted();
      if (tallies.isEmpty) return [];

      final products = await _products.findProducts(
        tallies.map((tally) => tally.productId),
      );

      final items = <LeaderboardItem>[];
      for (var i = 0; i < tallies.length; i++) {
        final tally = tallies[i];
        items.add(
          LeaderboardItem(
            rank: i + 1,
            productId: tally.productId,
            voteCount: tally.voteCount,
            // Null if this device has never loaded that product.
            product: products[tally.productId],
          ),
        );
      }
      return items;
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
  }
}