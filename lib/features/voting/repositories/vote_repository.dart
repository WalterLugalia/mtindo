// lib/features/voting/repositories/vote_repository.dart
import 'package:mtindo_app/features/feed/models/pending_vote.dart';

import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failure.dart';
import '../../../core/network/network_info.dart';

import '../services/vote_queue_service.dart';
import '../services/vote_service.dart';

/// What happened to a vote: reached the server, or saved on the device to
/// be sent later.
enum VoteOutcome { synced, queued }

/// Decides where a vote goes: straight to the server when possible, into
/// the on-device queue when the server can't be reached. Same role the
/// ProductRepository plays for the feed.
class VoteRepository {
  final VoteService _service;
  final VoteQueueService _queue;
  final NetworkInfo _networkInfo;

  VoteRepository(this._service, this._queue, this._networkInfo);

  Future<int> getVoteCount(int productId) =>
      _guard(() => _service.getVoteCount(productId));

  Future<bool> hasVoted(int productId) =>
      _guard(() => _service.hasVoted(productId));

  /// Sends the vote now, or queues it if the server can't be reached.
  /// Any other failure (not signed in, request refused) is thrown as a
  /// Failure, because retrying later wouldn't fix it.
  Future<VoteOutcome> setVote(PendingVote vote) async {
    try {
      await _send(vote);
      await _tryRemoveQueued(vote);
      return VoteOutcome.synced;
    } on NetworkException {
      try {
        await _queue.save(vote);
      } catch (e) {
        throw mapExceptionToFailure(e);
      }
      return VoteOutcome.queued;
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
  }

  /// Votes saved on this device for this user, still waiting to be sent.
  List<PendingVote> queuedFor(String userId) => _queue.readForUser(userId);

  /// Tries to send one queued vote. True means it was sent and removed.
  /// False means it stays queued and will be tried again later.
  Future<bool> sendQueued(PendingVote vote) async {
    try {
      await _send(vote);
      await _queue.remove(vote.userId, vote.productId);
      return true;
    } on Exception {
      return false;
    }
  }

  Future<void> _send(PendingVote vote) async {
    // Checking first avoids waiting for a timeout when the device is
    // plainly offline.
    if (!await _networkInfo.isConnected) throw const NetworkException();

    if (vote.wantsVote) {
      await _service.addVote(vote.productId);
    } else {
      await _service.removeVote(vote.productId);
    }
  }

  /// A fresh vote replaces any older queued intent for the same product.
  /// Best effort: the vote itself already reached the server.
  Future<void> _tryRemoveQueued(PendingVote vote) async {
    try {
      await _queue.remove(vote.userId, vote.productId);
    } on CacheException {
      // Ignored on purpose.
    }
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
  }
}