import '../../feed/models/product.dart';

/// One row of the leaderboard: a ranked product and its vote count.
class LeaderboardItem {
  final int rank;
  final int productId;
  final int voteCount;

  /// Null when this device has no details for the product. The votes
  /// still count; only the name and picture are missing.
  final Product? product;

  const LeaderboardItem({
    required this.rank,
    required this.productId,
    required this.voteCount,
    required this.product,
  });

  bool get hasDetails => product != null;
}