import 'dart:typed_data';

import 'package:campus_notify/data/api_client.dart';
import 'package:campus_notify/data/api_errors.dart';
import 'package:campus_notify/data/auth_repository.dart';
import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/providers/auth_provider.dart';
import 'package:campus_notify/routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Notification routes', () {
    test('empty route resolves to home', () {
      expect(routeFromMessage({'route': ''}), AppRoutes.home);
      expect(routeFromMessage(const {}), AppRoutes.home);
    });

    test('route without leading slash is normalized', () {
      expect(
        routeFromMessage({'route': 'pengumuman/3'}),
        AppRoutes.announcement('3'),
      );
    });

    test('valid announcement route is preserved', () {
      expect(
        routeFromMessage({'route': '/pengumuman/3'}),
        AppRoutes.announcement('3'),
      );
    });

    test('invalid route safely resolves to home', () {
      expect(routeFromMessage({'route': '/route-tidak-valid'}), AppRoutes.home);
      expect(routeFromMessage({'route': '/pengumuman/abc'}), AppRoutes.home);
    });

    test('announcement payload preserves its ID', () {
      final route = routeFromMessage({'route': 'pengumuman/3'});

      expect(route, '/pengumuman/3');
      expect(route.split('/').last, '3');
    });
  });

  group('Authentication session', () {
    test('access token determines authenticated state', () async {
      final store = _FakeTokenStore(access: 'access-token');
      final container = ProviderContainer(
        overrides: [
          tokenStoreProvider.overrideWithValue(store),
          authRepositoryProvider.overrideWithValue(AuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      expect(await container.read(authStateProvider.future), isTrue);
    });

    test('missing or empty access token is unauthenticated', () async {
      final store = _FakeTokenStore(access: '');
      final container = ProviderContainer(
        overrides: [
          tokenStoreProvider.overrideWithValue(store),
          authRepositoryProvider.overrideWithValue(AuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      expect(await container.read(authStateProvider.future), isFalse);
    });

    test(
      'failed refresh clears tokens and marks session unauthenticated',
      () async {
        final store = _FakeTokenStore(
          access: 'access-token',
          refresh: 'expired-refresh-token',
        );
        final container = ProviderContainer(
          overrides: [
            tokenStoreProvider.overrideWithValue(store),
            authRepositoryProvider.overrideWithValue(
              _FailingRefreshRepository(),
            ),
          ],
        );
        addTearDown(container.dispose);

        expect(await container.read(authStateProvider.future), isTrue);

        final adapter = _UnauthorizedAdapter();
        final client = buildApiClient(
          store,
          _FailingRefreshRepository(),
          onSessionExpired: () {
            container.read(authStateProvider.notifier).sessionExpired();
          },
          httpClientAdapter: adapter,
        );
        addTearDown(() => client.close(force: true));

        await expectLater(
          client.get<void>('/private'),
          throwsA(isA<DioException>()),
        );

        expect(store.access, isNull);
        expect(store.refresh, isNull);
        expect(store.clearCount, 1);
        expect(adapter.authorizationHeaders, ['Bearer access-token']);
        expect(container.read(authStateProvider).asData?.value, isFalse);
      },
    );
  });

  group('API error messages', () {
    test('401 asks the user to sign in again', () {
      final request = RequestOptions(path: '/private');
      final error = DioException(
        requestOptions: request,
        response: Response<void>(requestOptions: request, statusCode: 401),
      );

      expect(apiErrorMessage(error), contains('login kembali'));
    });

    test('timeout and connection errors have friendly messages', () {
      final request = RequestOptions(path: '/');
      final timeout = DioException(
        requestOptions: request,
        type: DioExceptionType.connectionTimeout,
      );
      final connection = DioException(
        requestOptions: request,
        type: DioExceptionType.connectionError,
      );

      expect(apiErrorMessage(timeout), contains('terlalu lama'));
      expect(apiErrorMessage(connection), contains('koneksi internet'));
    });
  });
}

class _FakeTokenStore extends TokenStore {
  _FakeTokenStore({this.access, this.refresh});

  String? access;
  String? refresh;
  int clearCount = 0;

  @override
  Future<String?> readAccess() async => access;

  @override
  Future<String?> readRefresh() async => refresh;

  @override
  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
    clearCount++;
  }
}

class _FailingRefreshRepository extends AuthRepository {
  @override
  Future<String> refresh(String refreshToken) async {
    throw StateError('Refresh token rejected');
  }
}

class _UnauthorizedAdapter implements HttpClientAdapter {
  final authorizationHeaders = <String?>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    authorizationHeaders.add(options.headers['Authorization'] as String?);
    return ResponseBody.fromString(
      '{}',
      401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
