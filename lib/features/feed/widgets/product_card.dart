import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../models/product.dart';

/// A single product tile shown in the Feed grid. Purely presentational —
/// it receives a Product and an onTap callback, and has no knowledge of
/// where the data came from or what happens when it's tapped.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

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
                  child: product.imageUrl.isEmpty
                      ? Container(
                          color: AppColors.surfaceMuted,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.textMuted,
                          ),
                        )
                      : Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          width: constraints.maxWidth,
                          height: imageHeight,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: AppColors.surfaceMuted,
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.surfaceMuted,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                color: AppColors.textMuted,
                              ),
                            );
                          },
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
