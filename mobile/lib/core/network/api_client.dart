import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/app_exception.dart';
import '../../config/constants.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));
  
  // TODO: Add Auth Interceptor here in later step
  
  return ApiClient(dio);
});

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getJson(String path, {String? token}) async {
    try {
      final response = await _dio.get(
        path,
        options: Options(headers: token != null ? {'Authorization': 'Bearer $token'} : null),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: body,
        options: Options(headers: token != null ? {'Authorization': 'Bearer $token'} : null),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(DioException e) {
    final message = e.response?.data?['message'] as String? ?? e.message ?? 'Request failed.';
    final code = e.response?.data?['error'] as String?;
    return AppException(message, code: code);
  }
}
