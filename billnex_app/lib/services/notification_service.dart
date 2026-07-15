import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'license_service.dart';

/// Local (on-device) notifications for subscription expiry reminders. Everything
/// is best-effort and guarded — a notification failure must never affect the app.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  /// When to remind, in days-before-expiry (plus 0 = on expiry day).
  static const _remindDaysBefore = [15, 7, 3, 1, 0];

  Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation((await FlutterTimezone.getLocalTimezone()).identifier));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // India-first fallback
      }
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: android);
      await _plugin.initialize(settings: settings);
      // Android 13+ runtime permission (no-op below 13).
      await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
      _ready = true;
    } catch (e) {
      if (kDebugMode) print('Notification init failed: $e');
      _ready = false;
    }
  }

  static const _channel = AndroidNotificationDetails(
    'subscription',
    'Subscription',
    channelDescription: 'BillNex subscription expiry reminders',
    importance: Importance.high,
    priority: Priority.high,
  );

  /// Reschedule expiry reminders from the current licence state. Cancels any
  /// previous ones first so activation/renewal keeps them accurate.
  Future<void> syncFromLicense() async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
      final lic = LicenseService.instance;
      if (!lic.isLoaded) return;
      final expiry = DateTime.fromMillisecondsSinceEpoch(lic.expiryMs);
      final now = DateTime.now();
      var id = 1000;
      for (final d in _remindDaysBefore) {
        // Fire at 10:00 on the reminder day.
        final day = DateTime(expiry.year, expiry.month, expiry.day - d, 10);
        if (day.isBefore(now)) continue;
        final body = d == 0
            ? 'Your BillNex subscription expires today. Renew to keep billing.'
            : 'Your BillNex subscription expires in $d ${d == 1 ? 'day' : 'days'}. Renew to avoid interruption.';
        await _plugin.zonedSchedule(
          id: id++,
          title: 'BillNex subscription',
          body: body,
          scheduledDate: tz.TZDateTime.from(day, tz.local),
          notificationDetails: const NotificationDetails(android: _channel),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (e) {
      if (kDebugMode) print('Notification sync failed: $e');
    }
  }
}
