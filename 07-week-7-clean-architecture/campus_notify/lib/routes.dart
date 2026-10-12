class AppRoutes {
  AppRoutes._();

  static const login = '/login';
  static const home = '/';
  static const debug = '/debug';
  static const announcementPrefix = '/pengumuman';
  static const announcementPattern = '$announcementPrefix/:id';

  static String announcement(String id) => '$announcementPrefix/$id';
}

String routeFromMessage(Map<String, dynamic> data) {
  return routeFromPath(data['route']);
}

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
