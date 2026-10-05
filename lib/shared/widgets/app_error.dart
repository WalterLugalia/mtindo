import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_button.dart';

/// Full-screen or inline error state with an optional retry action.
class AppErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 40),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: 160,
                child: AppButton(label: 'Try Again', onPressed: onRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small inline banner — matches "Showing cached styles while offline"
/// and "May be outdated" labels seen in the Feed mockup.
class AppInfoBanner extends StatelessWidget {
  final String message;
  final IconData icon;

  const AppInfoBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.warning),
        const SizedBox(width: AppSpacing.xs),
        Text(message, style: AppTextStyles.caption.copyWith(color: AppColors.warning)),
      ],
    );
  }
}