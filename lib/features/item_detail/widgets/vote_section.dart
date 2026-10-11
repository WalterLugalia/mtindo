import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';

/// The white card at the bottom of the detail screen: vote count on the
/// left, Vote button on the right (matches the approved mockup).
///
/// Browsing is open to everyone, but voting requires an account. So the
/// button's behavior depends on whether someone is signed in.
class VoteSection extends ConsumerWidget {
  const VoteSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              // TODO(Phase 11): replace the static 0 with the real count
              // from Supabase.
              Text(
                '0',
                style: AppTextStyles.headlineLarge.copyWith(fontSize: 28),
              ),
              Text('community votes', style: AppTextStyles.bodyMedium),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 140,
            child: AppButton(
              label: 'Vote',
              icon: Icons.favorite_border,
              onPressed: () => _onVotePressed(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  void _onVotePressed(BuildContext context, WidgetRef ref) {
    final user = ref.read(authRepositoryProvider).currentUser;

    if (user == null) {
      // Signed out: send them to log in. LoginScreen pops itself after a
      // successful sign-in, so they land back on this item.
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    // Signed in: the real vote submission is built in Phase 11.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voting arrives in a later phase.')),
    );
  }
}