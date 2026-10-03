import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import 'network_info.dart';

class ApiClient {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  ApiClient(this._networkInfo)
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: ApiConstants.connectTimeout,
            receiveTimeout: ApiConstants.receiveTimeout,
            headers: ApiConstants.defaultHeaders,
          ),
        );

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    if (!await _networkInfo.isConnected) {
      throw const NetworkException();
    }

    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _asMap(response.data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    return {'data': data};
  }

  ApiException _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const ApiException('Request timed out');
    }
    if (statusCode == 401 || statusCode == 403) {
      return ApiException('Invalid or missing API key', statusCode: statusCode);
    }
    if (statusCode == 429) {
      return ApiException('API rate limit reached. Try again later.', statusCode: statusCode);
    }
    if (statusCode != null && statusCode >= 500) {
      return ApiException('Fashion data service is unavailable', statusCode: statusCode);
    }
    return ApiException(e.message ?? 'Unexpected API error', statusCode: statusCode);
  }
}