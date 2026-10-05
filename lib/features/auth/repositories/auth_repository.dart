import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failure.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

/// Sits between AuthService (talks to Supabase) and the rest of the
/// app. Converts raw exceptions into Failures, so providers and UI
/// never depend on Supabase-specific error types.
class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  AppUser? get currentUser => _authService.currentUser;

  Stream<AppUser?> get authStateChanges => _authService.authStateChanges;

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      return await _authService.signUp(email: email, password: password, name: name);
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
  }

  Future<AppUser> signIn({required String email, required String password}) async {
    try {
      return await _authService.signIn(email: email, password: password);
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
  }
}