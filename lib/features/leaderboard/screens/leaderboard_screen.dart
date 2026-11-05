import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/route_constants.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../feed/models/product.dart';
import '../providers/leaderboard_provider.dart';
import '../widgets/leaderboard_item_card.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Mtindo', style: AppTextStyles.brandWordmark)),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: () async {
          try {
            await ref.refresh(leaderboardProvider.future);
          } catch (_) {
            // The provider already shows its own error state.
          }
        },
        child: leaderboard.when(
          loading: () => const AppLoader(message: 'Counting the votes...'),
          error: (error, stackTrace) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: 400,
                child: AppErrorView(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(leaderboardProvider),
                ),
              ),
            ],
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 400,
                    child: AppEmptyState(
                      message:
                          'No votes yet. Vote for a style you love and it will show up here.',
                      icon: Icons.emoji_events_outlined,
                    ),
                  ),
                ],
              );
            }

            return ListView(
              // Without this, a short list can't be pulled down to refresh.
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text('Top Voted', style: AppTextStyles.headlineLarge),
                const SizedBox(height: AppSpacing.md),
                for (final item in items) ...[
                  LeaderboardItemCard(
                    item: item,
                    onTap: item.hasDetails
                        ? () => _openDetail(context, ref, item.product!)
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openDetail(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    // push() returns a Future that completes when the user comes back
    // from the detail screen, so we can wait for it.
    await context.push<void>(
      RouteConstants.itemDetail(product.id),
      extra: product,
    );

    // They may have voted or un-voted there, so reload the counts. The
    // list stays visible while it reloads.
    if (!context.mounted) return;
    ref.invalidate(leaderboardProvider);
  }
}