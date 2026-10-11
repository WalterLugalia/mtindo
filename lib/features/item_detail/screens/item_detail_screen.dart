import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/product_image.dart';
import '../../feed/models/product.dart';
import '../widgets/vote_section.dart';

/// Full-page view of one product. It receives the Product directly from
/// the Feed (which already has every field needed), so it makes no
/// network call of its own.
class ItemDetailScreen extends StatelessWidget {
  final Product product;

  const ItemDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item details'),
        titleTextStyle: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: ProductImage(url: product.imageUrl),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(product.brandName, style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.xs),
              Text(
                product.name,
                style: AppTextStyles.headlineLarge.copyWith(fontSize: 24),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                product.priceDisplay,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (product.category.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Category', style: AppTextStyles.bodyMedium),
                      Flexible(
                        child: Text(
                          product.category,
                          textAlign: TextAlign.end,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
              ],
              const SizedBox(height: AppSpacing.md),
              const VoteSection(),
            ],
          ),
        ),
      ),
    );
  }
}