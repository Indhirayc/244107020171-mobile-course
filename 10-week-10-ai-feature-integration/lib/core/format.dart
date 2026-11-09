import '../routes.dart';

/// Mengubah DateTime menjadi format DD/MM/YYYY.
/// Contoh: 12/10/2026.
String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();

  return '$day/$month/$year';
}

/// Mengubah payload notifikasi menjadi route yang valid.
String routeFromMessage(Map<String, dynamic> data) {
  return routeFromPath(data['route']);
}

/// Memvalidasi dan menormalisasi route.
/// Route tidak valid akan diarahkan ke halaman Home.
String routeFromPath(Object? value) {
  if (value is! String || value.trim().isEmpty) {
    return AppRoutes.home;
  }

  var route = value.trim();

  if (!route.startsWith('/')) {
    route = '/$route';
  }

  final announcementRoute =
      route.startsWith('${AppRoutes.announcementPrefix}/') &&
      RegExp(r'^[0-9]+$')
          .hasMatch(route.substring(AppRoutes.announcementPrefix.length + 1));

  if (route == AppRoutes.home || announcementRoute) {
    return route;
  }

  return AppRoutes.home;
}
