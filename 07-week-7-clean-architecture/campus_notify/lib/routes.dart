export 'core/format.dart' show routeFromMessage, routeFromPath;

class AppRoutes {
  AppRoutes._();

  static const login = '/login';
  static const home = '/';
  static const debug = '/debug';
  static const notes = '/notes';
  static const announcementPrefix = '/pengumuman';
  static const announcementPattern = '$announcementPrefix/:id';

  static String announcement(String id) => '$announcementPrefix/$id';
}
