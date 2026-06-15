import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pamdes/services/api_service.dart';
import 'package:pamdes/services/notification_service.dart';

class FCMService {
  static final _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    // Minta izin notifikasi
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Ambil token FCM lalu kirim ke backend
    final token = await _messaging.getToken();
    if (token != null) {
      print('FCM Token: $token');
      await ApiService.simpanFcmToken(token);
    }

    // Token bisa berubah sewaktu-waktu, pantau perubahannya
    _messaging.onTokenRefresh.listen((newToken) {
      ApiService.simpanFcmToken(newToken);
    });

    // Notif masuk saat app FOREGROUND — tampilkan manual via local notif
    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? '';
      final body  = message.notification?.body  ?? '';
      if (title.isNotEmpty) {
        NotificationService.tampilSekarang(
          id: 99,
          judul: title,
          pesan: body,
        );
      }
    });

    // User tap notif saat app BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Notif dibuka: ${message.notification?.title}');
      // Bisa tambahkan navigasi ke halaman tertentu di sini
    });
  }
}