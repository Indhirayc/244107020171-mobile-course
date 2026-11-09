import 'package:dio/dio.dart';

String apiErrorMessage(DioException error) {
  if (error.response?.statusCode == 401) {
    return 'Sesi Anda telah berakhir. Silakan login kembali.';
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return 'Permintaan terlalu lama. Periksa koneksi Anda dan coba lagi.';
    case DioExceptionType.connectionError:
      return 'Tidak dapat terhubung. Periksa koneksi internet Anda.';
    case DioExceptionType.badCertificate:
      return 'Koneksi aman gagal dibuat. Silakan coba lagi nanti.';
    case DioExceptionType.badResponse:
    case DioExceptionType.cancel:
    case DioExceptionType.unknown:
      return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
