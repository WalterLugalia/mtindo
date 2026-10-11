import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Network image with all three failure/loading states handled in one
/// place: empty URL, still downloading, and failed to load.
///
/// It has no width or height of its own. It fills whatever space its
/// parent gives it (a SizedBox, AspectRatio, etc.), so each caller
/// decides the size.
class ProductImage extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const ProductImage({super.key, required this.url, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const _ImagePlaceholder(icon: Icons.image_not_supported_outlined);
    }

    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const _ImagePlaceholder(showSpinner: true);
      },
      errorBuilder: (context, error, stackTrace) =>
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