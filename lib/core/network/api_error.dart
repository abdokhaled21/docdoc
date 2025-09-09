import 'package:dio/dio.dart';

class ApiError implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, List<String>>? fieldErrors;

  ApiError(this.message, {this.statusCode, this.fieldErrors});

  factory ApiError.fromDio(Object error) {
    if (error is DioException) {
      final res = error.response;
      final status = res?.statusCode;
      String msg = 'Request failed';
      Map<String, List<String>>? fieldErrors;
      final data = res?.data;
      if (data is Map<String, dynamic>) {
        // Common Laravel-style error formats
        if (data['message'] is String) {
          msg = data['message'] as String;
        } else if (data['error'] is String) {
          msg = data['error'] as String;
        }
        // errors at root
        if (data['errors'] is Map) {
          fieldErrors = (data['errors'] as Map).map((k, v) => MapEntry(k.toString(), _asStringList(v)));
        }
        // errors under data
        if (data['data'] is Map && (data['data'] as Map)['errors'] is Map) {
          final errs = ((data['data'] as Map)['errors']) as Map;
          fieldErrors = errs.map((k, v) => MapEntry(k.toString(), _asStringList(v)));
        }
        // validation messages directly under data (e.g., {data:{phone:[...]}})
        if (data['data'] is Map && fieldErrors == null) {
          final d = (data['data'] as Map);
          // Only map string->list keys
          final mapped = <String, List<String>>{};
          d.forEach((key, val) {
            final list = _asStringList(val);
            if (list.isNotEmpty) mapped[key.toString()] = list;
          });
          if (mapped.isNotEmpty) fieldErrors = mapped;
        }
        // Prefer first field error as message if present
        final fe = fieldErrors;
        if (fe != null && fe.isNotEmpty) {
          final first = fe.values.firstOrNull;
          if (first != null && first.isNotEmpty) msg = first.first;
        }
      } else if (data is String && data.isNotEmpty) {
        msg = data;
      } else if (error.message != null) {
        msg = error.message!;
      }
      return ApiError(msg, statusCode: status, fieldErrors: fieldErrors);
    }
    return ApiError(error.toString(), fieldErrors: null);
  }
}

extension _IterableExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

List<String> _asStringList(Object? v) {
  if (v is List) {
    return v.map((e) => e.toString()).toList();
  }
  if (v is String) return [v];
  return [];
}
