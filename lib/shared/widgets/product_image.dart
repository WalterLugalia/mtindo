import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Network image with all three states handled in one place: empty URL,
/// still downloading, and failed to load. Images are saved on disk after
/// the first load, so they also work offline.
///
/// It has no width or height of its own. It fills whatever space its
/// parent gives it, so each caller decides the size.
class ProductImage extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const ProductImage({super.key, required this.url, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const _ImagePlaceholder(icon: Icons.image_not_supported_outlined);
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (context, url) => const _ImagePlaceholder(showSpinner: true),
      errorWidget: (context, url, error) =>
          const _ImagePlaceholder(icon: Icons.broken_image_outlined),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final IconData? icon;
  final bool showSpinner;

  const _ImagePlaceholder({this.icon, this.showSpinner = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceMuted,
      child: Center(
        child: showSpinner
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Icon(icon, color: AppColors.textMuted),
      ),
    );
  }
}