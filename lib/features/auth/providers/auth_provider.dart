import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../models/app_user.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';

/// The one place allowed to reach for the raw Supabase singleton.
/// Everything above this only ever sees AuthService/AuthRepository.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(Supabase.instance.client);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(authServiceProvider));
});

/// Exposes the session as a stream, so the UI reacts automatically
/// to sign-in and sign-out, not just at app launch.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// The signed-in user right now, or null. Other providers watch this
/// instead of reaching into the auth repository themselves.
final currentUserProvider = Provider<AppUser?>((ref) {
  // Watched only to trigger a rebuild when someone signs in or out.
  // The value itself comes from the synchronous getter below.
  ref.watch(authStateProvider);
  return ref.read(authRepositoryProvider).currentUser;
});

/// Tracks the in-progress state of a sign-in, sign-up, or sign-out
/// action itself (loading, error), separate from the session above.
final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No initial action. This only tracks the last attempt.
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signIn(email: email, password: password),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signUp(email: email, password: password, name: name),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
  }
}