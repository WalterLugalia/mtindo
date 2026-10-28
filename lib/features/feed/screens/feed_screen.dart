import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../item_detail/screens/item_detail_screen.dart';
import '../providers/feed_provider.dart';
import '../widgets/product_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);

    // True only when the feed finished loading AND is a saved copy.
    // whenOrNull handles just the data case and returns null for
    // loading and error, so "?? false" covers those.
    final showCachedBanner =
        feedState.whenOrNull(data: (result) => result.isFromCache) ?? false;

    return Scaffold(
      appBar: AppBar(title: Text('Mtindo', style: AppTextStyles.brandWordmark)),
      body: Column(
        children: [
          if (showCachedBanner) const _CachedBanner(),
          Expanded(
            child: RefreshIndicator(
              color: Theme.of(context).colorScheme.primary,
              onRefresh: () => ref.read(feedProvider.notifier).refresh(),
              child: feedState.when(
                loading: () =>
                    const AppLoader(message: 'Loading the latest styles...'),
                error: (error, stackTrace) => ListView(
                  children: [
                    SizedBox(
                      height: 400,
                      child: AppErrorView(
                        message: error.toString(),
                        onRetry: () =>
                            ref.read(feedProvider.notifier).refresh(),
                      ),
                    ),
                  ],
                ),
                data: (result) {
                  final products = result.products;

                  if (products.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(
                          height: 400,
                          child: AppEmptyState(
                            message: 'No fashion items found right now.',
                            icon: Icons.checkroom_outlined,
                          ),
                        ),
                      ],
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.58,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        showOutdatedBadge: result.isStale,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ItemDetailScreen(product: product),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The small "Showing cached styles while offline" line from the mockup:
/// a dot and muted text, not a loud warning.
class _CachedBanner extends StatelessWidget {
  const _CachedBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('Showing cached styles while offline',
              style: AppTextStyles.caption),
        ],
      ),
    );
  }
}