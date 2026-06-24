import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final _storage = const FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _storage.delete(key: 'access_token');
    }
    handler.next(err);
  }
}

class SessionInterceptor extends Interceptor {
  static String? _sessionId;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (_sessionId != null) {
      options.headers['Cookie'] = 'JSESSIONID=$_sessionId';
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    final rawCookies = response.headers['set-cookie'];
    if (rawCookies != null && rawCookies.isNotEmpty) {
      for (final cookie in rawCookies) {
        if (cookie.contains('JSESSIONID=')) {
          final match = RegExp(r'JSESSIONID=([^;]+)').firstMatch(cookie);
          if (match != null) {
            _sessionId = match.group(1);
            break;
          }
        }
      }
    }
    handler.next(response);
  }
}
