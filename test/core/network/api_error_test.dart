import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docdoc/core/network/api_error.dart';

void main() {
  group('ApiError.fromDio', () {
    test('picks first field error from data.phone and maps fieldErrors', () {
      final response = Response(
        requestOptions: RequestOptions(path: '/auth/register'),
        statusCode: 422,
        data: {
          'message': 'Unprocessable Entity',
          'data': {
            'phone': ['The phone has already been taken.']
          },
          'status': false,
          'code': 422,
        },
      );
      final ex = DioException(requestOptions: response.requestOptions, response: response, type: DioExceptionType.badResponse);
      final err = ApiError.fromDio(ex);
      expect(err.message, 'The phone has already been taken.');
      expect(err.statusCode, 422);
      expect(err.fieldErrors, isNotNull);
      expect(err.fieldErrors!['phone'], isNotNull);
      expect(err.fieldErrors!['phone']!.first, 'The phone has already been taken.');
    });

    test('picks first field error from errors{} root', () {
      final response = Response(
        requestOptions: RequestOptions(path: '/auth/register'),
        statusCode: 422,
        data: {
          'message': 'Validation failed',
          'errors': {
            'email': ['The email has already been taken.']
          },
        },
      );
      final ex = DioException(requestOptions: response.requestOptions, response: response, type: DioExceptionType.badResponse);
      final err = ApiError.fromDio(ex);
      expect(err.message, 'The email has already been taken.');
      expect(err.fieldErrors, isNotNull);
      expect(err.fieldErrors!['email']!.first, 'The email has already been taken.');
    });

    test('handles plain string response', () {
      final response = Response(
        requestOptions: RequestOptions(path: '/auth/login'),
        statusCode: 400,
        data: 'Invalid credentials',
      );
      final ex = DioException(requestOptions: response.requestOptions, response: response, type: DioExceptionType.badResponse);
      final err = ApiError.fromDio(ex);
      expect(err.message, 'Invalid credentials');
      expect(err.fieldErrors, isNull);
    });
  });
}
