import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

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
          await LocalStorage.instance.clearToken();
        }
        if (e.response?.statusCode == 429) {
          final req = e.requestOptions;
          final prev = (req.extra['retry_count'] as int?) ?? 0;
          if (prev < 3) {
            final delayMs = 500 * (1 << prev);
            if (kDebugMode) debugPrint('429 received. Retrying in ${delayMs}ms (attempt ${prev + 1})');
            await Future<void>.delayed(Duration(milliseconds: delayMs));
            final newReq = RequestOptions(
              path: req.path,
              baseUrl: req.baseUrl,
              queryParameters: req.queryParameters,
              data: req.data,
              headers: req.headers,
              method: req.method,
              sendTimeout: req.sendTimeout,
              receiveTimeout: req.receiveTimeout,
              extra: {...req.extra, 'retry_count': prev + 1},
            );
            try {
              final response = await d.fetch(newReq);
              return handler.resolve(response);
            } catch (err) {
              return handler.next(err as DioException);
            }
          }
        }
        handler.next(e);
      },
    ));

    return d;
  }
}
