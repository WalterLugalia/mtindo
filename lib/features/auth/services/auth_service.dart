import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/errors/exceptions.dart';
import '../models/app_user.dart';

/// Wraps Supabase Auth so the rest of the app never imports
/// supabase_flutter directly. Only this service does.
class AuthService {
  final supabase.SupabaseClient _client;

  AuthService(this._client);

  AppUser? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _toAppUser(user);
  }

  Stream<AppUser?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((state) {
      final user = state.session?.user;
      if (user == null) return null;
      return _toAppUser(user);
    });
  }

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
  }) {
    return _run(() async {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      final user = response.user;
      if (user == null) {
        throw const AuthException('Sign up failed. Please try again.');
      }
      return _toAppUser(user);
    });
  }

  Future<AppUser> signIn({required String email, required String password}) {
    return _run(() async {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthException(
          'Sign in failed. Please check your credentials.',
        );
      }
      return _toAppUser(user);
    });
  }

  Future<void> signOut() {
    return _run(() async {
      await _client.auth.signOut();
    });
  }

  /// Runs a Supabase auth call and translates whatever goes wrong into
  /// our own exception types. The order of the catch clauses matters:
  /// Dart uses the first one that matches.
  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthException {
      // Already one of ours (for example "Sign up failed"). Pass it on
      // unchanged. Without this clause the last one below would catch it
      // and wrongly call it a network problem.
      rethrow;
    } on supabase.AuthException catch (e) {
      // Supabase answered, or reported a failed request as an auth error.
      if (_looksLikeNetworkProblem(e.message)) throw const NetworkException();
      throw AuthException(_mapSupabaseAuthError(e));
    } on Exception {
      // The request never completed and no auth error came back (no
      // signal, DNS failure, timeout). Dart separates Exceptions
      // (runtime events like this) from Errors (programming bugs), so a
      // real bug still surfaces instead of being hidden here.
      throw const NetworkException();
    }
  }

  /// Depending on the library version, an offline sign-in arrives as an
  /// auth error whose message contains the underlying network error, or
  /// as a plain network exception. This recognizes the first kind by
  /// its text, and the last clause in _run handles the second.
  bool _looksLikeNetworkProblem(String message) {
    final lower = message.toLowerCase();
    const hints = [
      'socketexception',
      'failed host lookup',
      'network is unreachable',
      'clientexception',
      'connection refused',
      'connection closed',
      'connection reset',
      'timed out',
      'timeout',
    ];
    return hints.any((hint) => lower.contains(hint));
  }

  /// Converts a Supabase User into our own AppUser, reading the name back
  /// out of user metadata set during signUp().
  AppUser _toAppUser(supabase.User user) {
    return AppUser(
      id: user.id,
      email: user.email,
      name: user.userMetadata?['name'] as String?,
    );
  }

  String _mapSupabaseAuthError(supabase.AuthException e) {
    final message = e.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (message.contains('already registered') ||
        message.contains('user already exists')) {
      return 'An account with this email already exists.';
    }
    if (message.contains('password') && message.contains('least')) {
      return 'Password is too short. Use at least 6 characters.';
    }
    if (message.contains('email') && message.contains('invalid')) {
      return 'Please enter a valid email address.';
    }
    return e.message;
  }
}