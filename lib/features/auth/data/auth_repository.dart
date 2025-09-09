import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/endpoints.dart';
import '../../../core/network/api_error.dart';

class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  final Dio _dio = DioClient.instance.dio;

  Future<(String token, Map<String, dynamic>? user)> login({
    required String email,
    required String password,
  }) async {
    try {
      final form = FormData.fromMap({
        'email': email,
        'password': password,
      });
      final res = await _dio.post(Endpoints.login, data: form);
      final data = res.data as Map<String, dynamic>;
      final token = (data['token'] ?? data['access_token'] ?? data['data']?['token'])?.toString();
      if (token == null) {
        throw ApiError('Missing token in response', statusCode: res.statusCode);
      }
      final user = (data['user'] ?? data['data']?['user']);
      return (token, user is Map<String, dynamic> ? user : null);
    } catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  Future<(String token, Map<String, dynamic>? user)> register({
    required String name,
    required String email,
    required String phone,
    required String gender,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      // Map gender string to numeric code and include both per backend requirement (English only)
      // Spec: male=0, female=1
      final normalized = gender.toLowerCase().trim();
      final int genderCode = (normalized == 'female' || normalized == 'f') ? 1 : 0; // male default 0
      final form = FormData.fromMap({
        'name': name,
        'email': email,
        'phone': phone,
        'gender': genderCode,
        'gender_text': gender,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
      final res = await _dio.post(Endpoints.register, data: form);
      final data = res.data as Map<String, dynamic>;
      final token = (data['token'] ?? data['access_token'] ?? data['data']?['token'])?.toString();
      if (token == null) {
        throw ApiError('Missing token in response', statusCode: res.statusCode);
      }
      final user = (data['user'] ?? data['data']?['user']);
      return (token, user is Map<String, dynamic> ? user : null);
    } catch (e) {
      throw ApiError.fromDio(e);
    }
  }
}
