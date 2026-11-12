import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/product_image.dart';
import '../models/product.dart';

/// A single product tile shown in the Feed grid. Purely presentational:
/// it receives a Product, an onTap callback, and whether to show the
/// "May be outdated" badge. It doesn't know where any of that came from.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool showOutdatedBadge;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.showOutdatedBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Space reserved for the text block (name, brand, price).
            // The image gets whatever height is left over.
            const detailsHeight = 112.0;
            final imageHeight = (constraints.maxHeight - detailsHeight)
                .clamp(0.0, constraints.maxWidth * (4 / 3))
                .toDouble();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: constraints.maxWidth,
                  height: imageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ProductImage(url: product.imageUrl),
                      if (showOutdatedBadge)
                        const Positioned(
                          left: AppSpacing.sm,
                          bottom: AppSpacing.sm,
                          child: _OutdatedBadge(),
                        ),
                    ],
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          product.brandName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          product.priceDisplay,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The small white pill from the mockup, shown over the image when the
/// feed is a saved copy older than the stale window.
class _OutdatedBadge extends StatelessWidget {
  const _OutdatedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Text(
        'May be outdated',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}