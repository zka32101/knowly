import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.fireAt,
    required this.title,
    required this.body,
  });

  final int id;
  final DateTime fireAt;
  final String title;
  final String body;
}

/// 端末内の予定通知。サーバー・トークン・通信は使わない。
abstract class NotificationService {
  /// 通知の許可を求める。許可されたら true。
  Future<bool> requestPermission();

  /// 既存の予定を消して、[items] を予定する。
  Future<void> schedule(List<NotificationItem> items, {required String channelName});

  Future<void> cancelAll();
}

class LocalNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  Future<bool>? _initialized;

  Future<bool> _init() => _initialized ??= _doInit();

  Future<bool> _doInit() async {
    try {
      tz_data.initializeTimeZones();
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          // 許可は設定画面でスイッチを入れたときに求める（起動時には求めない）。
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      return true;
    } catch (e) {
      debugPrint('notifications init failed: $e');
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    if (!await _init()) return false;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? true;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        return await ios.requestPermissions(alert: true, sound: true) ?? false;
      }
    } catch (e) {
      debugPrint('notification permission failed: $e');
    }
    return false;
  }

  @override
  Future<void> schedule(List<NotificationItem> items, {required String channelName}) async {
    if (!await _init()) return;
    try {
      await _plugin.cancelAll();
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_fact',
          channelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      );
      for (final item in items) {
        final at = tz.TZDateTime(tz.local, item.fireAt.year, item.fireAt.month,
            item.fireAt.day, item.fireAt.hour, item.fireAt.minute);
        await _plugin.zonedSchedule(
          id: item.id,
          title: item.title,
          body: item.body,
          scheduledDate: at,
          notificationDetails: details,
          // 正確な時刻の権限（exact alarm）は使わない。数分ずれることがある。
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (e) {
      debugPrint('notification schedule failed: $e');
    }
  }

  @override
  Future<void> cancelAll() async {
    if (!await _init()) return;
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('notification cancel failed: $e');
    }
  }
}

final notificationServiceProvider =
    Provider<NotificationService>((ref) => LocalNotificationService());
