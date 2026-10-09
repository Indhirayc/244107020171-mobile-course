
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/debug_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase.
  await Firebase.initializeApp();

  // Inisialisasi notifikasi lokal.
  await initLocalNotifications();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final GoRouter router;

  @override
  void initState() {
    super.initState();

    router = GoRouter(
      initialLocation: '/login',

      // Redirect berdasarkan status autentikasi.
      redirect: (context, state) {
        final authState = ref.read(authStateProvider);

        if (authState.isLoading) {
          return null;
        }

        final loggedIn = authState.asData?.value ?? false;
        final goingLogin = state.matchedLocation == '/login';

        if (!loggedIn && !goingLogin) {
          return '/login';
        }

        if (loggedIn && goingLogin) {
          return '/';
        }

        return null;
      },

      routes: [
        // Halaman login.
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),

        // Halaman utama.
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),

        // Halaman detail pengumuman.
        GoRoute(
          path: '/pengumuman/:id',
          builder: (context, state) {
            return AnnouncementPage(
              id: state.pathParameters['id'] ?? '',
            );
          },
        ),

        // Halaman Debug FCM.
        GoRoute(
          path: '/debug',
          builder: (context, state) => const DebugPage(),
        ),
      ],
    );

    // Minta izin notifikasi setelah frame pertama.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _requestPermission();
    });
  }

  
  Future<void> _requestPermission() async {
    try {
      // Meminta izin notifikasi.
      final granted = await requestNotificationPermission();

      if (!mounted) return;

      debugPrint(
        granted
            ? 'Izin notifikasi diberikan.'
            : 'Izin notifikasi belum diberikan.',
      );

      // Inisialisasi FCM Token Lifecycle.
      await initFcmToken(
        onToken: (token) async {
          // Backend belum tersedia pada praktikum ini.
          // Token tidak dicetak secara penuh.
          debugPrint('FCM token berhasil diterima.');
        },
      );

      debugPrint('FCM Token Lifecycle berhasil diinisialisasi.');
    } catch (e) {
      debugPrint('Gagal menginisialisasi FCM: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    // Refresh GoRouter ketika status login berubah.
    ref.listen(authStateProvider, (previous, next) {
      router.refresh();
    });

    return MaterialApp.router(
      title: 'Campus Notify',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }

  @override
  void dispose() {
    router.dispose();
    super.dispose();
  }
}
