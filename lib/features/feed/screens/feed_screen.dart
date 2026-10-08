import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../providers/feed_provider.dart';
import '../widgets/product_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Mtindo', style: AppTextStyles.brandWordmark)),
      body: RefreshIndicator(
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
                  onRetry: () => ref.read(feedProvider.notifier).refresh(),
                ),
              ),
            ],
          ),
          data: (products) {
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                  onTap: () {
                    // Navigation to Item Detail wired in Phase 9.
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
