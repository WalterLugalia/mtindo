
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../auth/providers/auth_provider.dart';
import '../repositories/vote_repository.dart';
import '../services/vote_service.dart';

final voteServiceProvider = Provider<VoteService>((ref) {
  return VoteService(Supabase.instance.client);
});

final voteRepositoryProvider = Provider<VoteRepository>((ref) {
  return VoteRepository(ref.watch(voteServiceProvider));
});

/// How many votes a product has. The int parameter is the product ID.
final voteCountProvider = FutureProvider.family<int, int>((ref, productId) {
  return ref.watch(voteRepositoryProvider).getVoteCount(productId);
});

/// Whether the current user has voted for this product.
final hasVotedProvider = FutureProvider.family<bool, int>((ref, productId) {
  // Re-evaluates when the user signs in or out.
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;

  return ref.watch(voteRepositoryProvider).hasVoted(productId);
});

/// Performs the vote action and tracks its loading and error state.
final voteActionProvider =
    AsyncNotifierProvider<VoteActionController, void>(VoteActionController.new);

class VoteActionController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No initial action. This only tracks the last vote attempt.
  }

  Future<void> toggleVote(int productId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(voteRepositoryProvider);

      final alreadyVoted = await repository.hasVoted(productId);
      if (alreadyVoted) {
        await repository.removeVote(productId);
      } else {
        await repository.addVote(productId);
      }

      // The data changed on the server, so throw away the cached
      // answers and let the UI fetch fresh ones.
      ref.invalidate(voteCountProvider(productId));
      ref.invalidate(hasVotedProvider(productId));
    });
  }
}