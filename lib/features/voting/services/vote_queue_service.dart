import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:mtindo_app/features/feed/models/pending_vote.dart';

import '../../../core/errors/exceptions.dart';


/// Saves and reads the on-device queue of votes waiting to be sent.
/// Like the product cache service, it only stores and fetches. Deciding
/// when to queue or send is the repository's job.
class VoteQueueService {
  final Box _box;

  VoteQueueService(this._box);

  /// One entry per user and product: toggling again replaces the old one.
  String _key(String userId, int productId) => '${userId}_$productId';

  Future<void> save(PendingVote vote) async {
    try {
      await _box.put(_key(vote.userId, vote.productId), jsonEncode(vote.toMap()));
    } catch (_) {
      throw const CacheException('Could not save your vote on this device.');
    }
  }

  Future<void> remove(String userId, int productId) async {
    try {
      await _box.delete(_key(userId, productId));
    } catch (_) {
      throw const CacheException('Could not update the saved votes.');
    }
  }

  /// Every queued vote for this user, oldest first.
  List<PendingVote> readForUser(String userId) {
    final votes = <PendingVote>[];

    for (final key in _box.keys) {
      if (key is! String || !key.startsWith('${userId}_')) continue;

      try {
        final raw = _box.get(key) as String;
        votes.add(PendingVote.fromMap(jsonDecode(raw) as Map<String, dynamic>));
      } catch (_) {
        // A damaged entry is skipped instead of breaking the whole queue.
      }
    }

    votes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return votes;
  }
}