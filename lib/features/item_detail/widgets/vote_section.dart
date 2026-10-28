
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../voting/providers/vote_provider.dart';

/// The white card at the bottom of the detail screen: the community vote
/// count on the left, the Vote button on the right.
class VoteSection extends ConsumerWidget {
  final int productId;

  const VoteSection({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show a failed vote (for example "already voted") as a snackbar.
    ref.listen<AsyncValue<void>>(voteActionProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    final countText = ref.watch(voteCountProvider(productId)).when(
          data: (count) => '$count',
          loading: () => '-',
          error: (_, __) => '-',
        );

    final hasVoted = ref.watch(hasVotedProvider(productId)).when(
          data: (voted) => voted,
          loading: () => false,
          error: (_, __) => false,
        );

    final isSubmitting = ref.watch(voteActionProvider).isLoading;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                countText,
                style: AppTextStyles.headlineLarge.copyWith(fontSize: 28),
              ),
              Text('community votes', style: AppTextStyles.bodyMedium),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 140,
            child: AppButton(
              label: hasVoted ? 'Voted' : 'Vote',
              icon: hasVoted ? Icons.favorite : Icons.favorite_border,
              isLoading: isSubmitting,
              onPressed: () => _onVotePressed(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  void _onVotePressed(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider);

    if (user == null) {
      // Signed out: send them to log in. LoginScreen pops itself after a
      // successful sign-in, and they land back on this item.
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    ref.read(voteActionProvider.notifier).toggleVote(productId);
  }
}