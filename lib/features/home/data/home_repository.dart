import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/api_error.dart';
import '../../../core/network/endpoints.dart';
import '../domain/user_profile.dart';
import '../domain/doctor.dart';
import '../domain/specialization.dart';

class HomeRepository {
  HomeRepository._();
  static final HomeRepository instance = HomeRepository._();

  final Dio _dio = DioClient.instance.dio;

  Future<UserProfile> fetchProfile() async {
    try {
      final res = await _dio.get(Endpoints.userProfile);
      final data = res.data as Map<String, dynamic>;
      final list = data['data'];
      if (list is List && list.isNotEmpty) {
        return UserProfile.fromApi(list.first as Map<String, dynamic>);
      }
      if (data['user'] is Map<String, dynamic>) {
        return UserProfile.fromApi(data['user'] as Map<String, dynamic>);
      }
      throw ApiError('Invalid profile response');
    } catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  Future<UserProfile> updateProfilePartial(Map<String, dynamic> body) async {
    try {
      final res = await _dio.post(Endpoints.userUpdate, data: body);
      final data = res.data as Map<String, dynamic>;
      final payload = data['data'] is Map<String, dynamic> ? data['data'] as Map<String, dynamic> : data;
      return UserProfile.fromApi(payload);
    } catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  Future<UserProfile> updateProfile({
    required String name,
    required String email,
    String? password,
    required String phoneE164,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'name': name,
        'email': email,
        'phone': phoneE164,
        if (password != null && password.isNotEmpty) 'password': password,
      };
      final res = await _dio.post(Endpoints.userUpdate, data: body);
      final data = res.data as Map<String, dynamic>;
      final payload = data['data'] is Map<String, dynamic> ? data['data'] as Map<String, dynamic> : data;
      return UserProfile.fromApi(payload);
    } catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  Future<List<Doctor>> fetchRecommendedDoctors() async {
    try {
      final res = await _dio.get(Endpoints.homeIndex);
      final data = res.data as Map<String, dynamic>;
      final list = data['data'];
      final doctors = <Doctor>[];
      if (list is List) {
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            final docs = item['doctors'];
            if (docs is List) {
              for (final d in docs) {
                if (d is Map<String, dynamic>) {
                  doctors.add(Doctor.fromApi(d));
                }
              }
            }
          }
        }
      }
      return doctors;
    } catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  Future<List<Specialization>> fetchSpecializations() async {
    try {
      final res = await _dio.get(Endpoints.specializationIndex);
      final data = res.data as Map<String, dynamic>;
      final list = data['data'];
      final specs = <Specialization>[];
      if (list is List) {
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            specs.add(Specialization.fromApi(item));
          }
        }
      }
      return specs;
    } catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  Future<List<Doctor>> fetchDoctorsBySpecialization(int id, {int? page, int? limit}) async {
    try {
      final res = await _dio.get(
        '${Endpoints.specializationShow}/$id',
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
        },
      );
      final data = res.data as Map<String, dynamic>;
      final doctors = <Doctor>[];
      final payload = data['data'];
      if (payload is List) {
        for (final d in payload) {
          if (d is Map<String, dynamic>) doctors.add(Doctor.fromApi(d));
        }
      } else if (payload is Map<String, dynamic>) {
        final docs = payload['doctors'];
        if (docs is List) {
          for (final d in docs) {
            if (d is Map<String, dynamic>) doctors.add(Doctor.fromApi(d));
          }
        }
      }
      return doctors;
    } catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  Future<List<Doctor>> fetchAllDoctors({int? page, int? limit}) async {
    try {
      final res = await _dio.get(
        Endpoints.doctorIndex,
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
        },
      );
      final data = res.data as Map<String, dynamic>;
      final list = data['data'];
      final doctors = <Doctor>[];
      if (list is List) {
        for (final d in list) {
          if (d is Map<String, dynamic>) doctors.add(Doctor.fromApi(d));
        }
      }
      return doctors;
    } catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  Future<List<Doctor>> fetchDoctorsByCity(int cityId, {int? page, int? limit}) async {
    try {
      final res = await _dio.get(
        Endpoints.doctorFilter,
        queryParameters: {
          'city': cityId,
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
        },
      );
      final data = res.data as Map<String, dynamic>;
      final list = data['data'];
      final doctors = <Doctor>[];
      if (list is List) {
        for (final d in list) {
          if (d is Map<String, dynamic>) doctors.add(Doctor.fromApi(d));
        }
      }
      return doctors;
    } catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  Future<List<Doctor>> fetchDoctorsSearch(String name, {int? page, int? limit}) async {
    try {
      final res = await _dio.get(
        Endpoints.doctorSearch,
        queryParameters: {
          'name': name,
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
        },
      );
      final data = res.data as Map<String, dynamic>;
      final list = data['data'];
      final doctors = <Doctor>[];
      if (list is List) {
        for (final d in list) {
          if (d is Map<String, dynamic>) doctors.add(Doctor.fromApi(d));
        }
      }
      return doctors;
    } catch (e) {
      throw ApiError.fromDio(e);
    }
  }
}
