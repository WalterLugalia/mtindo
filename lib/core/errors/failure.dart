import 'exceptions.dart';

/// A UI-safe representation of an error. Providers hold a Failure in
/// their error state, never a raw Exception, so screens can always show a
/// clean, human-readable message regardless of what went wrong underneath.
sealed class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Check your network and try again.']);
}

class ApiFailure extends Failure {
  const ApiFailure([super.message = 'Could not load fashion items right now. Please try again.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not load saved data.']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class VoteFailure extends Failure {
  const VoteFailure([super.message = 'Could not register your vote. Please try again.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong.']);
}

/// Maps a caught exception (from a service) into a Failure (for a
/// provider). Call this once, inside each repository's catch block.
Failure mapExceptionToFailure(Object error) {
  // A repository may already have converted the error. Don't re-map it.
  if (error is Failure) return error;

  return switch (error) {
    NetworkException() => const NetworkFailure(),
    ApiException(:final statusCode) =>
      ApiFailure(_apiFailureMessage(statusCode)),
    CacheException() => const CacheFailure(),
    AuthException(message: final m) => AuthFailure(m),
    SupabaseException(message: final m) => VoteFailure(m),
    _ => const UnknownFailure(),
  };
}

/// Picks a user-facing sentence for a failed API call, based on the HTTP
/// status the server answered with. Technical details such as "invalid
/// API key" are deliberately not shown to users.
String _apiFailureMessage(int? statusCode) {
  if (statusCode == 429) {
    // RapidAPI's free plan has a limited quota. This is the realistic one.
    return 'Too many requests right now. Please try again in a few minutes.';
  }
  if (statusCode == 401 || statusCode == 403) {
    return 'Fashion data is temporarily unavailable. Please try again later.';
  }
  if (statusCode != null && statusCode >= 500) {
    return 'The fashion service is having trouble. Please try again soon.';
  }
  return 'Could not load fashion items right now. Please try again.';
}