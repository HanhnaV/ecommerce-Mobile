import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../models/user_model.dart';

class ProfileService {
  ProfileService();

  Future<UserModel> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? gender,
    String? dateOfBirth,
    String? avatarPath,
  }) async {
    try {
      final formData = FormData();

      if (fullName != null && fullName.isNotEmpty) {
        formData.fields.add(MapEntry('fullName', fullName));
      }
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        formData.fields.add(MapEntry('phoneNumber', phoneNumber));
      }
      if (gender != null && gender.isNotEmpty) {
        formData.fields.add(MapEntry('gender', gender));
      }
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
        formData.fields.add(MapEntry('dateOfBirth', dateOfBirth));
      }
      if (avatarPath != null && avatarPath.isNotEmpty) {
        formData.files.add(MapEntry(
          'avatarFile',
          await MultipartFile.fromFile(avatarPath),
        ));
      }

      final response = await apiClient.put(
        '/api/v1/user/profile',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

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
