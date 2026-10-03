import 'package:mtindo_app/core/config/env_config.dart';

class ApiConstants {
ApiConstants._();

static String get baseUrl => 'https://${EnvConfig.rapidApiHost}';

static const String productsList = '/products/v2/list';
static const String  productsDetails = '/products/v2/get-details';

static Map<String, String> get defaultHeaders => {
  'X-RapidAPI-Key': EnvConfig.rapidApiKey,
        'X-RapidAPI-Host': EnvConfig.rapidApiHost,
        'Content-Type': 'application/json'
};

 static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const int defaultPageSize = 20;

}