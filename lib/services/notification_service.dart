import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    await _plugin
        .resolvePlatformSpecificImplementation
            <AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> tampilSekarang({
    required int id,
    required String judul,
    required String pesan,
  }) async {
    const detail = NotificationDetails(
      android: AndroidNotificationDetails(
        'pamdes_channel',
        'PAMDes Notifikasi',
        channelDescription: 'Notifikasi tagihan PAMDes',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(id, judul, pesan, detail);
  }

  static Future<void> jadwalkanPengingat({
    required int id,
    required String judul,
    required String pesan,
    required DateTime jatuhTempo,
  }) async {
    await _plugin.cancel(id);

    final hMinus3  = jatuhTempo.subtract(const Duration(days: 3));
    final sekarang = DateTime.now();

    if (hMinus3.isAfter(sekarang)) {
      const detail = NotificationDetails(
        android: AndroidNotificationDetails(
          'pamdes_reminder_channel',
          'PAMDes Pengingat Tagihan',
          channelDescription: 'Pengingat jatuh tempo tagihan PAMDes',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      );

      await _plugin.zonedSchedule(
        id,
        judul,
        pesan,
        tz.TZDateTime.from(hMinus3, tz.local),
        detail,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> batalkanSemua() async => _plugin.cancelAll();
}