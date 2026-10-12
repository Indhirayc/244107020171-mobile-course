import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/api_client.dart';
import '../../data/datasources/token_store.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final loginProvider = Provider<Login>((ref) {
  return Login(ref.watch(authRepositoryProvider));
});

final apiClientProvider = Provider<Dio>((ref) {
  final store = ref.watch(tokenStoreProvider);
  final auth = ref.watch(authRepositoryProvider);

  return buildApiClient(
    store,
    auth,
    onSessionExpired: () {
      ref.read(authStateProvider.notifier).sessionExpired();
    },
  );
});

final authStateProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(tokenStoreProvider).readAccess();
    return token?.isNotEmpty ?? false;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final result = await ref.read(loginProvider).call(
        email: email,
        password: password,
      );

      if (result.failure != null) {
        throw AuthFailureException(result.failure!.message);
      }

      final session = result.session;
      if (session == null) {
        throw const AuthFailureException('Login gagal, silakan coba lagi');
      }

      try {
        await ref.read(tokenStoreProvider).save(
          access: session.access,
          refresh: session.refresh,
        );
      } catch (_) {
        throw const AuthFailureException(
          'Gagal menyimpan sesi, silakan coba lagi',
        );
      }

      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(false);
  }

  void sessionExpired() {
    state = const AsyncData(false);
  }
}

class AuthFailureException implements Exception {
  const AuthFailureException(this.message);

  final String message;

  @override
  String toString() => message;
}
