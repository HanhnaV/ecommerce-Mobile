import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:ecommerce_mobile/core/api/api_interceptors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  group('AuthInterceptor', () {
    tearDownAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('adds Authorization header when token exists in storage', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'read') {
          return 'test-token-123';
        }
        return null;
      });

      final interceptor = AuthInterceptor();
      RequestOptions? capturedOptions;
      final completer = Completer<void>();

      interceptor.onRequest(
        RequestOptions(path: '/test', headers: <String, Object>{}),
        _FakeRequestHandler(
          onNext: (opts) {
            capturedOptions = opts;
            completer.complete();
          },
        ),
      );

      await completer.future;
      expect(capturedOptions!.headers['Authorization'], 'Bearer test-token-123');
    });

    test('does not add Authorization header when no token in storage', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'read') return null;
        return null;
      });

      final interceptor = AuthInterceptor();
      RequestOptions? capturedOptions;
      final completer = Completer<void>();

      interceptor.onRequest(
        RequestOptions(path: '/test', headers: <String, Object>{}),
        _FakeRequestHandler(
          onNext: (opts) {
            capturedOptions = opts;
            completer.complete();
          },
        ),
      );

      await completer.future;
      expect(capturedOptions!.headers.containsKey('Authorization'), false);
    });

    test('onError 401 triggers token cleanup', () async {
      String? storedToken = 'old-token';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'read') return storedToken;
        if (methodCall.method == 'delete') {
          storedToken = null;
          return null;
        }
        return null;
      });

      final interceptor = AuthInterceptor();
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      final completer = Completer<void>();

      interceptor.onError(error, _FakeErrorHandler(
        onNext: (err) {
          completer.complete();
        },
      ));

      await completer.future;

      expect(storedToken, null);
    });
  });
}

class _FakeRequestHandler implements RequestInterceptorHandler {
  final void Function(RequestOptions) onNext;
  _FakeRequestHandler({required this.onNext});

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #next) {
      return Function.apply(onNext, [invocation.positionalArguments.first]);
    }
    return super.noSuchMethod(invocation);
  }
}

class _FakeErrorHandler implements ErrorInterceptorHandler {
  final void Function(DioException) onNext;
  _FakeErrorHandler({required this.onNext});

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #next) {
      return Function.apply(onNext, [invocation.positionalArguments.first]);
    }
    return super.noSuchMethod(invocation);
  }
}
