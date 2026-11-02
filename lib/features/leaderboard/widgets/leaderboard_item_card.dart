import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/product_image.dart';
import '../models/leaderboard_item.dart';

/// One ranked row: rank, thumbnail, name and brand, vote count. Purely
/// presentational, like ProductCard: it receives data and an onTap.
class LeaderboardItemCard extends StatelessWidget {
  final LeaderboardItem item;

  /// Null makes the row non-tappable (used when details are missing).
  final VoidCallback? onTap;

  const LeaderboardItemCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(
                item.rank.toString().padLeft(2, '0'),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: SizedBox(
                width: 56,
                height: 72,
                // An empty URL makes ProductImage show its placeholder.
                child: ProductImage(url: product?.imageUrl ?? ''),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product?.name ?? 'Details unavailable',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product?.brandName ?? 'Not loaded on this device',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.voteCount}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  item.voteCount == 1 ? 'vote' : 'votes',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}