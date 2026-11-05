
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/voting/providers/vote_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// The root widget: applies the theme and hands navigation to go_router.
class MtindoApp extends ConsumerWidget {
  const MtindoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   
    ref.read(pendingVotesProvider);

    return MaterialApp.router(
      title: 'Mtindo',
      theme: AppTheme.light,
      routerConfig: ref.watch(routerProvider),
    );
  }
}