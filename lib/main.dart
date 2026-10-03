import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mtindo_app/core/config/env_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  await Hive.initFlutter();

  runApp(
    const ProviderScope(
      child: MtindoAPP(),
    ),
  );
}

class MtindoAPP extends StatelessWidget {
  const MtindoAPP({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mtindo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Text('Hello, World!'),
    );
  }
}