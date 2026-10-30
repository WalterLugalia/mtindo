import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mtindo_app/features/feed/models/pending_vote.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../../core/errors/failure.dart';
import '../../../core/network/network_providers.dart';
import '../../../core/storage/hive_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../repositories/vote_repository.dart';
import '../services/vote_queue_service.dart';
import '../services/vote_service.dart';

// ---------------------------------------------------------------------
// Dependency chain (same idea as auth and feed)
// ---------------------------------------------------------------------

final voteServiceProvider = Provider<VoteService>((ref) {
  return VoteService(Supabase.instance.client);
});

final voteQueueServiceProvider = Provider<VoteQueueService>((ref) {
  return VoteQueueService(HiveService.pendingVotesBox);
});

final voteRepositoryProvider = Provider<VoteRepository>((ref) {
  return VoteRepository(
    ref.watch(voteServiceProvider),
    ref.watch(voteQueueServiceProvider),
    ref.watch(networkInfoProvider),
  );
});

// ---------------------------------------------------------------------
// What the server says
// ---------------------------------------------------------------------

/// How many votes a product has. The int parameter is the product ID.
final voteCountProvider = FutureProvider.family<int, int>((ref, productId) {
  return ref.watch(voteRepositoryProvider).getVoteCount(productId);
});

/// Whether the current user has voted for this product, as the server
/// knows it.
final hasVotedProvider = FutureProvider.family<bool, int>((ref, productId) {
  // Watch only the user's ID, so this re-runs when a different person
  // signs in, not every time Supabase refreshes the login token.
  final userId = ref.watch(currentUserProvider.select((user) => user?.id));
  if (userId == null) return false;

  return ref.watch(voteRepositoryProvider).hasVoted(productId);
});

// ---------------------------------------------------------------------
// What the user did that the server may not know yet
// ---------------------------------------------------------------------

/// Holds the current user's unconfirmed votes, keyed by product ID. This
/// is the overlay that makes votes appear instantly and survive offline.
final pendingVotesProvider =
    NotifierProvider<PendingVotesController, Map<int, PendingVote>>(
  PendingVotesController.new,
);

class PendingVotesController extends Notifier<Map<int, PendingVote>> {
  /// Products being sent right now, by a tap or by the sync loop. It stops
  /// two things acting on the same product at once.
  final Set<int> _inFlight = {};

  @override
  Map<int, PendingVote> build() {
    final userId = ref.watch(currentUserProvider.select((user) => user?.id));
    if (userId == null) return {};

    // Send queued votes whenever the connection comes back.
    ref.listen<AsyncValue<bool>>(connectivityProvider, (previous, next) {
      final isOnline = next.whenOrNull(data: (value) => value) ?? false;
      if (isOnline) syncQueued();
    });

    final queued = ref.read(voteRepositoryProvider).queuedFor(userId);

    // Votes left over from last time (for example, the app was closed
    // while offline). Try them once build() has finished.
    if (queued.isNotEmpty) Future.microtask(syncQueued);

    return {for (final vote in queued) vote.productId: vote};
  }

  /// Called when the user taps Vote or Voted. Returns what happened, or
  /// null if a vote for this product is already being sent.
  Future<VoteOutcome?> toggleVote(int productId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) throw const AuthFailure('Please sign in to vote.');

    // Set.add returns false when the value is already in the set.
    if (!_inFlight.add(productId)) return null;

    final previous = state[productId];
    try {
      final wantsVote = !ref.read(voteDisplayProvider(productId)).hasVoted;
      final vote = PendingVote(
        productId: productId,
        userId: user.id,
        wantsVote: wantsVote,
        createdAt: DateTime.now(),
      );

      // Optimistic update: the screen changes right now.
      state = {...state, productId: vote};

      final outcome = await ref.read(voteRepositoryProvider).setVote(vote);

      if (outcome == VoteOutcome.queued) {
        state = {...state, productId: vote.asQueued()};
      } else {
        await _refreshAndClear(productId);
      }
      return outcome;
    } catch (_) {
      // A real failure, not just being offline: undo the optimistic update.
      _restore(productId, previous);
      rethrow;
    } finally {
      _inFlight.remove(productId);
    }
  }

  /// Sends every queued vote for the current user. Safe to call from
  /// several places at once, because products already being handled are
  /// skipped.
  Future<void> syncQueued() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final repository = ref.read(voteRepositoryProvider);

    for (final vote in repository.queuedFor(user.id)) {
      if (!_inFlight.add(vote.productId)) continue;

      try {
        final sent = await repository.sendQueued(vote);
        if (sent) await _refreshAndClear(vote.productId);
      } finally {
        _inFlight.remove(vote.productId);
      }
    }
  }

  /// After a vote reaches the server: re-read the real count and vote
  /// state, and only then drop the overlay, so the screen never flashes
  /// back to the old values in between.
  Future<void> _refreshAndClear(int productId) async {
    try {
      ref.invalidate(voteCountProvider(productId));
      ref.invalidate(hasVotedProvider(productId));
      await ref.read(voteCountProvider(productId).future);
      await ref.read(hasVotedProvider(productId).future);
      _clear(productId);
    } catch (_) {
      // Could not re-read right now. Keep the overlay so the screen still
      // shows the vote the user just cast.
    }
  }

  void _clear(int productId) {
    state = {...state}..remove(productId);
  }

  void _restore(int productId, PendingVote? previous) {
    if (previous == null) {
      _clear(productId);
    } else {
      state = {...state, productId: previous};
    }
  }
}

// ---------------------------------------------------------------------
// What the screen shows: server values plus the overlay, combined
// ---------------------------------------------------------------------

class VoteDisplay {
  /// Null when the count can't be known right now (shown as "-").
  final int? count;
  final bool hasVoted;

  /// True when the vote is saved on the device, waiting for a connection.
  final bool isQueued;

  const VoteDisplay({
    required this.count,
    required this.hasVoted,
    required this.isQueued,
  });
}

final voteDisplayProvider = Provider.family<VoteDisplay, int>((ref, productId) {
  final serverCount = _lastKnown(ref.watch(voteCountProvider(productId)));
  final serverVoted = _lastKnown(ref.watch(hasVotedProvider(productId)));
  final pending = ref.watch(
    pendingVotesProvider.select((votes) => votes[productId]),
  );

  // The user's own unconfirmed choice wins over what the server last said.
  final hasVoted = pending?.wantsVote ?? (serverVoted ?? false);

  var count = serverCount;
  if (pending != null && serverCount != null) {
    if (serverVoted == null) {
      // We don't know whether the server already counts this user, so any
      // adjustment could be wrong by one. Better to show "-" than a lie.
      count = null;
    } else {
      final delta = (pending.wantsVote ? 1 : 0) - (serverVoted ? 1 : 0);
      count = serverCount + delta;
    }
  }

  return VoteDisplay(
    count: count,
    hasVoted: hasVoted,
    isQueued: pending?.isQueued ?? false,
  );
});

/// The latest value an AsyncValue has, even while it is reloading, and
/// null when there isn't one (still first-loading, or failed).
T? _lastKnown<T>(AsyncValue<T> value) {
  return value.when<T?>(
    skipLoadingOnReload: true,
    skipLoadingOnRefresh: true,
    data: (data) => data,
    loading: () => null,
    error: (_, __) => null,
  );
}