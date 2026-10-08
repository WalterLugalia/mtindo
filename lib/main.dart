import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mtindo_app/features/auth/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/config/env_config.dart';
import 'app/theme/app_theme.dart';
import 'features/feed/screens/feed_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  await Hive.initFlutter();

  runApp(
    const ProviderScope(
      child: MtindoApp(),
    ),
  );
}

class MtindoApp extends StatelessWidget {
  const MtindoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mtindo',
      theme: AppTheme.light,
      home: const FeedScreen()
    );
  }
}

/// Temporary screen to visually confirm the theme and shared widgets
/// render correctly — replaced once real screens exist (Feed, Auth, etc.)
class _ThemePreviewScreen extends StatelessWidget {
  const _ThemePreviewScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mtindo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back.', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () {}, child: const Text('Log in')),
          ],
        ),
      ),
    );
  }
}