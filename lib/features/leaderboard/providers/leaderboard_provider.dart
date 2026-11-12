import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../feed/providers/feed_provider.dart';
import '../models/leaderboard_item.dart';
import '../repositories/leaderboard_repository.dart';
import '../services/leaderboard_service.dart';

final leaderboardServiceProvider = Provider<LeaderboardService>((ref) {
  return LeaderboardService(Supabase.instance.client);
});

/// Reuses the feed's productRepositoryProvider, so the leaderboard looks
/// products up through the same repository the feed uses.
final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository(
    ref.watch(leaderboardServiceProvider),
    ref.watch(productRepositoryProvider),
  );
});

/// The ranked list the screen shows.
///
/// FutureProvider is enough here (no custom actions like the feed's
/// refresh), and `autoDispose` throws the data away when nobody is
/// watching, so opening the screen later always fetches fresh counts.
final leaderboardProvider =
    FutureProvider.autoDispose<List<LeaderboardItem>>((ref) {
  return ref.watch(leaderboardRepositoryProvider).getTopVoted();
});