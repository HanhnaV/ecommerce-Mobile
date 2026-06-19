import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../data/models/user_model.dart';

class AuthService {
  AuthService();

  Future<({String token, UserModel user})> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/v1/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = UserModel.fromLoginResponse(data);

      return (token: token, user: user);
    } on DioException catch (e) {
      final msg = _extractError(e);
      throw Exception(msg);
    }
  }

  Future<({String id, String username, String email, String phoneNumber})> register({
    required String username,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/v1/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return (
        id: data['id'].toString(),
        username: data['username'] as String,
        email: data['email'] as String,
        phoneNumber: data['phoneNumber'] as String,
      );
    } on DioException catch (e) {
      final msg = _extractError(e);
      throw Exception(msg);
    }
  }

  Future<void> verify({
    required String email,
    required String otp,
  }) async {
    try {
      await apiClient.post(
        '/api/v1/auth/verify',
        data: {
          'email': email,
          'otp': otp,
        },
      );
    } on DioException catch (e) {
      final msg = _extractError(e);
      throw Exception(msg);
    }
  }

  Future<void> resendOtp({required String email}) async {
    try {
      await apiClient.post(
        '/api/v1/auth/resend-otp',
        data: {'email': email},
      );
    } on DioException catch (e) {
      final msg = _extractError(e);
      throw Exception(msg);
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.get('/api/v1/user/me');
      final data = response.data as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      final msg = _extractError(e);
      throw Exception(msg);
    }
  }

  String _extractError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map) {
        return data['message'] ?? data['error'] ?? data.toString();
      }
      if (data is String) return data;
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Ket noi qua lau. Vui long thu lai.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Khong the ket noi server. Kiem tra mang.';
    }
    return 'Da xay ra loi. Vui long thu lai.';
  }
}
