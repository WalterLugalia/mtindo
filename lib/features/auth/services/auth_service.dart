import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/errors/exceptions.dart';
import '../models/app_user.dart';

/// Wraps Supabase Auth so the rest of the app never imports
/// supabase_flutter directly — only this service does.
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
  }) async {
    try {
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
    } on supabase.AuthException catch (e) {
      throw AuthException(_mapSupabaseAuthError(e));
    }
  }

  Future<AppUser> signIn({required String email, required String password}) async {
    try {
      final response = await _client.auth.signInWithPassword(email: email, password: password);
      final user = response.user;
      if (user == null) {
        throw const AuthException('Sign in failed. Please check your credentials.');
      }
      return _toAppUser(user);
    } on supabase.AuthException catch (e) {
      throw AuthException(_mapSupabaseAuthError(e));
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on supabase.AuthException catch (e) {
      throw AuthException(_mapSupabaseAuthError(e));
    }
  }

  /// Converts a Supabase User into our own AppUser, reading the
  /// name back out of user metadata set during signUp().
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
    if (message.contains('already registered') || message.contains('user already exists')) {
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