import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import 'models/app_user.dart';

class AuthRepository {
  AuthRepository(this._dio, this._tokens);

  final Dio _dio;
  final TokenStorage _tokens;

  static final _noAuth = Options(extra: {kSkipAuth: true});

  /// POST /api/auth/register  (the backend creates the username itself)
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      await _dio.post<dynamic>(
        '/api/auth/register',
        data: {
          'displayName': fullName,
          'email': email,
          'password': password,
        },
        options: _noAuth,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /api/auth/login  -> saves both tokens, returns the user
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post<dynamic>(
        '/api/auth/login',
        data: {'email': email, 'password': password},
        options: _noAuth,
      );

      final body = res.data as Map<String, dynamic>;
      await _tokens.saveTokens(
        accessToken: body['accessToken'] as String,
        refreshToken: body['refreshToken'] as String,
      );
      return AppUser.fromJson(body['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// App launch: is the saved session still valid?
  /// Returns the user, or null when there is no valid session.
  /// (If the access token expired, the Dio interceptor refreshes it.)
  Future<AppUser?> restoreSession() async {
    final refreshToken = await _tokens.readRefreshToken();
    if (refreshToken == null) return null;

    try {
      final res = await _dio.get<dynamic>('/api/auth/me');
      final body = res.data as Map<String, dynamic>;
      return AppUser.fromJson(body['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokens.clear();
        return null;
      }
      // Server unreachable: keep the tokens, report the problem.
      throw ApiException.fromDio(e);
    }
  }

  /// POST /api/auth/logout, then forget the tokens (even if offline).
  Future<void> logout() async {
    try {
      final refreshToken = await _tokens.readRefreshToken();
      if (refreshToken != null) {
        await _dio.post<dynamic>(
          '/api/auth/logout',
          data: {'refreshToken': refreshToken},
          options: _noAuth,
        );
      }
    } on DioException catch (_) {
      // Best effort: the local logout below is what matters.
    } finally {
      await _tokens.clear();
    }
  }
}
