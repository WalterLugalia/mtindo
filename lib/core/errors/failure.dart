import 'exceptions.dart';

sealed class Failure {
  final String message;
  const Failure(this.message);
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

Failure mapExceptionToFailure(Object error) {
  return switch (error) {
    NetworkException() => const NetworkFailure(),
    ApiException() => const ApiFailure(),
    CacheException() => const CacheFailure(),
    AuthException(message: final m) => AuthFailure(m),
    SupabaseException() => const VoteFailure(),
    _ => const UnknownFailure(),
  };
}