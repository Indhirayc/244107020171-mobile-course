import 'package:dio/dio.dart';

import 'auth_repository.dart';
import 'token_store.dart';

const _authRetryKey = 'authRetry';

Dio buildApiClient(
  TokenStore store,
  AuthRepository auth, {
  void Function()? onSessionExpired,
  HttpClientAdapter? httpClientAdapter,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example-campus-api.test'));
  if (httpClientAdapter != null) {
    dio.httpClientAdapter = httpClientAdapter;
  }

  Future<void> expireSession() async {
    await store.clear();
    onSessionExpired?.call();
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccess();
        if (access != null && access.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode != 401) {
          return handler.next(error);
        }

        final request = error.requestOptions;
        if (request.extra[_authRetryKey] == true) {
          await expireSession();
          return handler.next(error);
        }

        final refresh = await store.readRefresh();
        if (refresh == null || refresh.isEmpty) {
          await expireSession();
          return handler.next(error);
        }

        late final String renewed;
        try {
          renewed = await auth.refresh(refresh);
          await store.save(access: renewed, refresh: refresh);
        } catch (_) {
          await expireSession();
          return handler.next(error);
        }

        request
          ..extra[_authRetryKey] = true
          ..headers['Authorization'] = 'Bearer $renewed';

        try {
          final retry = await dio.fetch<dynamic>(request);
          return handler.resolve(retry);
        } on DioException catch (retryError) {
          return handler.next(retryError);
        }
      },
    ),
  );
  return dio;
}
