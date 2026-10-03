class EnvConfig {
  EnvConfig._();

  static const String rapidApiKey = String.fromEnvironment(
    'RAPID_API_KEY',
    defaultValue: '',
  );

  static const String rapidApiHost = String.fromEnvironment(
    'RAPID_API_HOST',
    defaultValue: '',
  );

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static void validate() {
    final missing = <String>[
      if (rapidApiKey.isEmpty) 'RAPID_API_KEY',
      if (rapidApiHost.isEmpty) 'RAPID_API_HOST',
      if (supabaseUrl.isEmpty) 'SUPABASE_URL',
      if (supabaseAnonKey.isEmpty) 'SUPABASE_ANON_KEY',
    ];
    if (missing.isNotEmpty) {
      throw StateError(
        'Missing required environment configuration: ${missing.join(', ')}.\n'
        'Pass them with --dart-define when running the app.',
      );
    }
  }
}