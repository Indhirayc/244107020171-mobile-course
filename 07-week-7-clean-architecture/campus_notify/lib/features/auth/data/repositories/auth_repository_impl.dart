import '../../../../core/failures.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      if (!email.contains('@') || password.length < 6) {
        return (
          session: null,
          failure: const LocalFailure('Email atau kata sandi tidak valid'),
        );
      }

      return (
        session: AuthSession(
          access: 'mock-access-for-$email',
          refresh: 'mock-refresh-for-$email',
        ),
        failure: null,
      );
    } catch (_) {
      return (
        session: null,
        failure: const LocalFailure('Gagal melakukan login'),
      );
    }
  }

  @override
  Future<({String? access, Failure? failure})> refresh(
    String refreshToken,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      if (refreshToken.isEmpty) {
        return (
          access: null,
          failure: const LocalFailure('Sesi tidak valid, silakan login kembali'),
        );
      }

      return (
        access: 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}',
        failure: null,
      );
    } catch (_) {
      return (
        access: null,
        failure: const LocalFailure('Gagal memperbarui sesi'),
      );
    }
  }
}