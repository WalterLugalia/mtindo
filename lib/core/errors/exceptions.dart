class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Local cache error']);
}

class SupabaseException implements Exception {
  final String message;
  const SupabaseException(this.message);
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class UnknownException implements Exception {
  final String message;
  const UnknownException([this.message = 'Something went wrong']);
}