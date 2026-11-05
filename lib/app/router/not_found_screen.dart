import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_constants.dart';
import '../../shared/widgets/app_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Shown when the app is asked to open a page that doesn't exist, or an
/// item screen without the product it needs. It always offers a way home.
class NotFoundScreen extends StatelessWidget {
  final String message;

  const NotFoundScreen({
    super.key,
    this.message = "We couldn't find that page.",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.explore_off_outlined,
                  size: 48,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: 180,
                  child: AppButton(
                    label: 'Back to Feed',
                    // go() replaces the whole navigation stack. That is
                    // right here, because the stack is in a bad state.
                    onPressed: () => context.go(RouteConstants.feed),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}