import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../voting/providers/vote_provider.dart';
import '../../voting/repositories/vote_repository.dart';

/// The white card at the bottom of the detail screen: the community vote
/// count on the left, the Vote button on the right.
class VoteSection extends ConsumerWidget {
  final int productId;

  const VoteSection({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = ref.watch(voteDisplayProvider(productId));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    display.count?.toString() ?? '-',
                    style: AppTextStyles.headlineLarge.copyWith(fontSize: 28),
                  ),
                  Text('community votes', style: AppTextStyles.bodyMedium),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 140,
                child: AppButton(
                  label: display.hasVoted ? 'Voted' : 'Vote',
                  icon: display.hasVoted
                      ? Icons.favorite
                      : Icons.favorite_border,
                  onPressed: () => _onVotePressed(context, ref),
                ),
              ),
            ],
          ),
          if (display.isQueued) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Saved on this device. It will be sent once you are back online.',
              style: AppTextStyles.caption,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _onVotePressed(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);

    if (user == null) {
      // Signed out: send them to log in. LoginScreen pops itself after a
      // successful sign-in, and they land back on this item.
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    // Grab this before the await. Using `context` after an async gap is
    // unsafe, because the screen may be gone by then.
    final messenger = ScaffoldMessenger.of(context);

    try {
      final outcome =
          await ref.read(pendingVotesProvider.notifier).toggleVote(productId);

      if (outcome == VoteOutcome.queued) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Saved. Your vote will be sent once you are back online.'),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}