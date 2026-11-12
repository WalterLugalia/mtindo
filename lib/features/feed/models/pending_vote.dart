/// A vote the user has cast that the server may not know about yet.
///
/// It records an intent ("I want to have voted for this product" or "I
/// want to have un-voted"), not a click. One exists per user and product,
/// so toggling twice overwrites it instead of stacking up.
class PendingVote {
  final int productId;
  final String userId;
  final bool wantsVote;
  final DateTime createdAt;

  /// True once this vote is saved in the on-device queue, waiting for a
  /// connection. False while it is only the on-screen optimistic update
  /// for a request still in flight. Not saved to disk: anything read back
  /// from disk is, by definition, queued.
  final bool isQueued;

  const PendingVote({
    required this.productId,
    required this.userId,
    required this.wantsVote,
    required this.createdAt,
    this.isQueued = false,
  });

  PendingVote asQueued() => PendingVote(
        productId: productId,
        userId: userId,
        wantsVote: wantsVote,
        createdAt: createdAt,
        isQueued: true,
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'userId': userId,
        'wantsVote': wantsVote,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory PendingVote.fromMap(Map<String, dynamic> map) => PendingVote(
        productId: map['productId'] as int,
        userId: map['userId'] as String,
        wantsVote: map['wantsVote'] as bool,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
        isQueued: true,
      );
}