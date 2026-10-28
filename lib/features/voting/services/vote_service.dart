import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/errors/exceptions.dart';

class VoteService {
  final supabase.SupabaseClient _client;

  VoteService(this._client);

  static const String _table = 'votes';

  Future<int> getVoteCount(int productId) async {
    try {
      final response = await _client
          .from(_table)
          .select('id')
          .eq('product_id', productId)
          .count(supabase.CountOption.exact);
      return response.count;
    } on supabase.PostgrestException catch (e) {
      throw SupabaseException(e.message);
    }
  }

  Future<bool> hasVoted(int productId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      final row = await _client
          .from(_table)
          .select('id')
          .eq('product_id', productId)
          .eq('user_id', userId)
          .maybeSingle();
      return row != null;
    } on supabase.PostgrestException catch (e) {
      throw SupabaseException(e.message);
    }
  }

  Future<void> addVote(int productId) async {
    _requireUserId();

    try {
      // user_id is not sent. The database fills it in from the signed-in
      // user's token (default auth.uid()), so it can't be forged.
      await _client.from(_table).insert({'product_id': productId});
    } on supabase.PostgrestException catch (e) {
      // 23505 is Postgres's "unique violation" code, which is our
      // one-vote-per-user rule firing.
      if (e.code == '23505') {
        throw const SupabaseException('You have already voted for this item.');
      }
      throw SupabaseException(e.message);
    }
  }

  Future<void> removeVote(int productId) async {
    final userId = _requireUserId();

    try {
      await _client
          .from(_table)
          .delete()
          .eq('product_id', productId)
          .eq('user_id', userId);
    } on supabase.PostgrestException catch (e) {
      throw SupabaseException(e.message);
    }
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('Please sign in to vote.');
    }
    return userId;
  }
}