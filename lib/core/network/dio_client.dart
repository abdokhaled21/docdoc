import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'endpoints.dart';
import '../storage/local_storage.dart';

class DioClient {
  DioClient._();
  static final DioClient instance = DioClient._();

  late final Dio dio = _create();

  Dio _create() {
    final options = BaseOptions(
      baseUrl: Endpoints.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
      headers: {
        'Accept': 'application/json',
      },
    );
    final d = Dio(options);

    d.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) {
        if (kDebugMode) {
          debugPrint(obj.toString());
        }
      },
    ));

    // Attach Authorization bearer token if available (skip auth endpoints)
    d.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final path = options.path;
          final isAuth = path.endsWith(Endpoints.login) || path.endsWith(Endpoints.register) ||
              path.contains(Endpoints.login) || path.contains(Endpoints.register);
          if (!isAuth) {
            final token = await LocalStorage.instance.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
        } catch (_) {}
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token invalid/expired; clear it so Splash can redirect next launch
          await LocalStorage.instance.clearToken();
        }
        handler.next(e);
      },
    ));

    return d;
  }
}
