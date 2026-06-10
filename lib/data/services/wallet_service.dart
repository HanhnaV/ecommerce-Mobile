import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../models/wallet_model.dart';

class WalletService {
  WalletService();

  Future<WalletModel> getMyWallet() async {
    try {
      final response = await apiClient.get('/api/v1/wallet/me');
      final data = response.data as Map<String, dynamic>;
      return WalletModel.fromJson(data);
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
