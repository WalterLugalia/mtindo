import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/errors/exceptions.dart';

class VoteService {
  final supabase.SupabaseClient _client;

  VoteService(this._client);

  static const String _table = 'votes';

  Future<int> getVoteCount(int productId) {
    return _run(() async {
      final response = await _client
          .from(_table)
          .select('id')
          .eq('product_id', productId)
          .count(supabase.CountOption.exact);
      return response.count;
    });
  }

  Future<bool> hasVoted(int productId) {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return Future.value(false);

    return _run(() async {
      final row = await _client
          .from(_table)
          .select('id')
          .eq('product_id', productId)
          .eq('user_id', userId)
          .maybeSingle();
      return row != null;
    });
  }

  Future<void> addVote(int productId) async {
    _requireUserId();

    try {
      await _client.from(_table).insert({'product_id': productId});
    } on supabase.PostgrestException catch (e) {
      // 23505 means this vote already exists. The state the caller wanted
      // ("I have voted") is already true, so that counts as success. This
      // also makes sending the same queued vote twice harmless.
      if (e.code == '23505') return;
      throw SupabaseException(e.message);
    } on Exception {
      throw const NetworkException();
    }
  }

  Future<void> removeVote(int productId) async {
    final userId = _requireUserId();

    // Deleting a row that doesn't exist also succeeds, for the same reason.
    return _run(() async {
      await _client
          .from(_table)
          .delete()
          .eq('product_id', productId)
          .eq('user_id', userId);
    });
  }

  /// Runs a Supabase call and translates anything that goes wrong into our
  /// own exception types.
  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on supabase.PostgrestException catch (e) {
      // The server answered, but refused the request.
      throw SupabaseException(e.message);
    } on Exception {
      // The request never completed: no signal, DNS failure, timeout.
      // Dart separates Exceptions (things that happen at runtime) from
      // Errors (programming bugs), so real bugs still surface.
      throw const NetworkException();
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