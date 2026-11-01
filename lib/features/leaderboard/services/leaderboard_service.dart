// lib/features/leaderboard/services/leaderboard_service.dart
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/errors/exceptions.dart';

/// One row of the view: a product ID and how many votes it has.
class VoteTally {
  final int productId;
  final int voteCount;

  const VoteTally({required this.productId, required this.voteCount});
}

/// Reads the vote counts from the product_vote_counts view. It knows
/// about Supabase and nothing about products or screens.
class LeaderboardService {
  final supabase.SupabaseClient _client;

  LeaderboardService(this._client);

  static const String _view = 'product_vote_counts';

  Future<List<VoteTally>> getTopVoted({int limit = 20}) async {
    try {
      final rows = await _client
          .from(_view)
          .select('product_id, vote_count')
          .order('vote_count', ascending: false)
          .order('first_voted_at', ascending: true)
          .limit(limit);

      return rows
          .map((row) => VoteTally(
                productId: row['product_id'] as int,
                voteCount: row['vote_count'] as int,
              ))
          .toList();
    } on supabase.PostgrestException catch (e) {
      // The server answered, but refused or failed the request.
      throw SupabaseException(e.message);
    } on Exception {
      // The request never completed (no connection, timeout).
      throw const NetworkException();
    }
  }
}