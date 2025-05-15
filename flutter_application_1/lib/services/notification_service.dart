import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidInitializationSettings androidInitializationSettings;
  late InitializationSettings initializationSettings;

  Future<void> initialize() async {
    tz.initializeTimeZones();
    androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    initializationSettings = InitializationSettings(android: androidInitializationSettings);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    // Nota: requestPermission se omite; configura permisos manualmente en Android si es necesario
  }

  Future<void> scheduleRoutineNotification(String routineName, DateTime scheduledDate) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'routine_channel',
      'Rutinas',
      channelDescription: 'Notificaciones para rutinas programadas',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    final now = DateTime.now().toUtc();
    final scheduledTime = tz.TZDateTime.from(
      now.add(const Duration(minutes: 1)), // 11:36 PM hoy
      tz.getLocation('America/Bogota'),
    );

    if (scheduledTime.isAfter(now)) {
      final message = '¡Es hora de entrenar! Tienes programada la rutina "$routineName" hoy, '
          '${DateFormat('dd \'de\' MMMM \'de\' yyyy', 'es').format(scheduledTime)}. ¡Prepárate para darlo todo!';
      await flutterLocalNotificationsPlugin.zonedSchedule(
        scheduledTime.millisecondsSinceEpoch ~/ 1000, // Unique ID
        'Recordatorio de Rutina',
        message,
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exact,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }
}