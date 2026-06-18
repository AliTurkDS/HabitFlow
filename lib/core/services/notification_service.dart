import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_constants.dart';

/// Wraps flutter_local_notifications for scheduling daily habit reminders.
///
/// NOTE: Android 13+ needs POST_NOTIFICATIONS permission and the
/// SCHEDULE_EXACT_ALARM permission for exact daily reminders — add them to
/// android/app/src/main/AndroidManifest.xml (see project README/TODO).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Schedules a daily reminder at [minutesSinceMidnight]. The habit id is
  /// hashed to a stable notification id so re-scheduling replaces the old one.
  Future<void> scheduleDaily({
    required String habitId,
    required String title,
    required int minutesSinceMidnight,
  }) async {
    await init();
    final id = habitId.hashCode & 0x7fffffff;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        AppConstants.notifChannelId,
        AppConstants.notifChannelName,
        channelDescription: AppConstants.notifChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: 'HabitFlow',
        body: "Time for: $title 🎯",
        scheduledDate: _nextInstanceOf(minutesSinceMidnight),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Failed to schedule reminder for $title: $e');
    }
  }

  Future<void> cancel(String habitId) async {
    final id = habitId.hashCode & 0x7fffffff;
    await _plugin.cancel(id: id);
  }

  tz.TZDateTime _nextInstanceOf(int minutesSinceMidnight) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minutesSinceMidnight ~/ 60,
      minutesSinceMidnight % 60,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
