import '../../feed/models/product.dart';

/// Why a leaderboard row has no product details.
enum MissingReason {
  /// ASOS confirmed the product is gone. The votes still count.
  removed,

  /// We couldn't find out (offline, rate limit, lookup limit reached).
  /// Pulling to refresh tries again.
  unknown,
}

/// One row of the leaderboard: a ranked product and its vote count.
class LeaderboardItem {
  final int rank;
  final int productId;
  final int voteCount;

  /// Null when this device has no details for the product.
  final Product? product;

  /// Set only when [product] is null.
  final MissingReason? missingReason;

  const LeaderboardItem({
    required this.rank,
    required this.productId,
    required this.voteCount,
    required this.product,
    this.missingReason,
  });

  bool get hasDetails => product != null;
  bool get isRemoved => missingReason == MissingReason.removed;
}