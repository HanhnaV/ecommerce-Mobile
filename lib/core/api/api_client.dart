import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'api_interceptors.dart';

final apiClient = Dio(
  BaseOptions(
    baseUrl: dotenv.get('API_BASE_URL', fallback: 'http://localhost:8080'),
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ),
)..interceptors.addAll([AuthInterceptor(), LogInterceptor(requestBody: true, responseBody: true)]);
