
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ==================== LOCAL NOTIFICATIONS ====================

final _local = FlutterLocalNotificationsPlugin();

String? pendingDeepLink;

Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();

  await _local.initialize(
    settings: const InitializationSettings(
      android: android,
      iOS: ios,
    ),
    onDidReceiveNotificationResponse: (response) {
      pendingDeepLink = response.payload;
    },
  );
}

// ==================== FCM TOKEN STATE ====================

final fcmTokenPreview = ValueNotifier<String>('Belum tersedia');
final fcmTokenSource = ValueNotifier<String>('Belum ada event token');
final fcmTopicStatus = ValueNotifier<String>('Belum berlangganan');

StreamSubscription<String>? _tokenSubscription;

// ==================== NOTIFICATION PERMISSION ====================

Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
  );

  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

// ==================== TOKEN LIFECYCLE ====================

String _shortenToken(String token) {
  final length = token.length < 12 ? token.length : 12;
  return '${token.substring(0, length)}...';
}

Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  await _tokenSubscription?.cancel();

  Future<void> handleToken(String token, String source) async {
    fcmTokenPreview.value = _shortenToken(token);
    fcmTokenSource.value = source;

    // Jangan mencetak token lengkap.
    debugPrint('FCM [$source]: ${fcmTokenPreview.value}');

    // Kirim token lengkap ke callback backend.
    await onToken(token);
  }

  // Pantau perubahan token.
  _tokenSubscription =
      FirebaseMessaging.instance.onTokenRefresh.listen(
    (token) async {
      try {
        await handleToken(token, 'onTokenRefresh');
      } catch (e) {
        debugPrint('Callback pembaruan token FCM gagal: $e');
      }
    },
    onError: (Object error) {
      debugPrint('Listener token FCM mengalami kesalahan: $error');
    },
  );

  // Ambil token perangkat saat ini.
  final token = await FirebaseMessaging.instance.getToken();

  if (token != null) {
    await handleToken(token, 'getToken');
  } else {
    fcmTokenPreview.value = 'Token belum tersedia';
  }

  // Langganan topik pengumuman kampus.
  await FirebaseMessaging.instance.subscribeToTopic(
    'pengumuman-kampus',
  );

  fcmTopicStatus.value = 'Berlangganan pengumuman-kampus';
}

Future<void> disposeFcmToken() async {
  await _tokenSubscription?.cancel();
  _tokenSubscription = null;
}
