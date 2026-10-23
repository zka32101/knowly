import '../models/trivia.dart';
import 'daily_pick.dart';

class PlannedNotification {
  const PlannedNotification({required this.id, required this.fireAt, required this.fact});

  final int id;

  /// 端末の現地時刻での発火日時。
  final DateTime fireAt;
  final Trivia fact;
}

/// 先の [days] 日ぶんの通知を計画する。各日の通知は、その日の「今日の雑学」と同じものにする
/// （フィードと同じ [pickForDay] で選ぶ）。今日の通知時刻をすぎていれば、明日から始める。
List<PlannedNotification> planNotifications({
  required List<Trivia> pool,
  required DateTime now,
  required int hour,
  required int minute,
  int days = 14,
  DayPicker? picker,
}) {
  final pick = picker ?? pickForDay;
  if (pool.isEmpty) return const [];
  final firstDay = DateTime(now.year, now.month, now.day);
  final todayFire = DateTime(now.year, now.month, now.day, hour, minute);
  final start = now.isBefore(todayFire) ? firstDay : firstDay.add(const Duration(days: 1));
  final out = <PlannedNotification>[];
  for (var i = 0; i < days; i++) {
    final day = DateTime(start.year, start.month, start.day + i);
    final fact = pick(pool, day);
    if (fact == null) continue;
    out.add(PlannedNotification(
      id: i,
      fireAt: DateTime(day.year, day.month, day.day, hour, minute),
      fact: fact,
    ));
  }
  return out;
}
