import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../storage/token_storage.dart';

/// Add `Options(extra: {kSkipAuth: true})` to a request that must NOT carry
/// a token or trigger a refresh (login, register, logout).
const String kSkipAuth = 'skipAuth';

class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    required void Function() onSessionExpired,
  }) {
    final options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );

    dio = Dio(options);

    // Separate instance WITHOUT interceptors, used only for /refresh,
    // so a failing refresh can never trigger another refresh.
    final refreshDio = Dio(options.copyWith());

    dio.interceptors.add(
      _AuthInterceptor(
        dio: dio,
        refreshDio: refreshDio,
        tokenStorage: tokenStorage,
        onSessionExpired: onSessionExpired,
      ),
    );
  }

  late final Dio dio;
}

/// - attaches the access token to every request
/// - on 401 TOKEN_EXPIRED: refreshes ONCE, then retries the request
///
/// It is a QueuedInterceptor, so if several requests expire at the same
/// moment they wait in line and only the first one performs the refresh.
class _AuthInterceptor extends QueuedInterceptor {
  _AuthInterceptor({
    required this.dio,
    required this.refreshDio,
    required this.tokenStorage,
    required this.onSessionExpired,
  });

  final Dio dio;
  final Dio refreshDio;
  final TokenStorage tokenStorage;
  final void Function() onSessionExpired;

  static const _retried = 'retried';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[kSkipAuth] != true) {
      final token = await tokenStorage.readAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final data = err.response?.data;

    final isExpired = err.response?.statusCode == 401 &&
        data is Map &&
        data['code'] == 'TOKEN_EXPIRED';

    if (!isExpired ||
        request.extra[kSkipAuth] == true ||
        request.extra[_retried] == true) {
      handler.next(err);
      return;
    }

    try {
      // An earlier queued request may already have refreshed the tokens.
      final current = await tokenStorage.readAccessToken();
      final alreadyRefreshed = current != null &&
          request.headers['Authorization'] != 'Bearer $current';

      if (!alreadyRefreshed) {
        final refreshed = await _refreshTokens();
        if (!refreshed) {
          onSessionExpired();
          handler.next(err);
          return;
        }
      }

      request.extra[_retried] = true;
      final response = await dio.fetch<dynamic>(request);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    } catch (_) {
      handler.next(err);
    }
  }

  /// Returns true if new tokens were saved, false if the session is over.
  /// Network/server errors are rethrown (tokens are kept, user stays logged in).
  Future<bool> _refreshTokens() async {
    final refreshToken = await tokenStorage.readRefreshToken();
    if (refreshToken == null) return false;

    try {
      final res = await refreshDio.post<dynamic>(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final body = res.data as Map<String, dynamic>;
      // The backend rotates refresh tokens: ALWAYS save the new one.
      await tokenStorage.saveTokens(
        accessToken: body['accessToken'] as String,
        refreshToken: body['refreshToken'] as String,
      );
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await tokenStorage.clear();
        return false;
      }
      rethrow;
    }
  }
}
