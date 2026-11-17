import 'package:dio/dio.dart';

import '../../session/session_events.dart';
import '../../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._sessionEvents);

  static const String _authorization = 'Authorization';

  final SecureStorage _storage;
  final SessionEvents _sessionEvents;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.readToken();
    if (token != null) options.headers[_authorization] = 'Bearer $token';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final wasAuthenticated = err.requestOptions.headers.containsKey(
      _authorization,
    );
    if (err.response?.statusCode == 401 && wasAuthenticated) {
      _sessionEvents.notifyExpired();
    }
    handler.next(err);
  }
}
