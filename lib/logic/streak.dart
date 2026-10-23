/// 連続日数（ストリーク）。Teen/Adult だけが使う。
///
/// - その日に雑学を1つ読んだら、その日が「読んだ日」。
/// - 7日続くごとに「お休み券」を1枚もらえる（最大1枚、自動で使われる）。
///   1日だけ読めなかった日は、お休み券があれば連続が途切れない。
/// - 今日まだ読んでいなくても、昨日まで続いていれば連続は途切れていない。
class StreakInfo {
  const StreakInfo({required this.current, required this.hasFreeze, required this.readToday});

  final int current;

  /// 次に1日休んでも途切れない（お休み券を持っている）。
  final bool hasFreeze;
  final bool readToday;
}

String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime _parse(String key) {
  final p = key.split('-').map(int.parse).toList();
  return DateTime.utc(p[0], p[1], p[2]);
}

StreakInfo computeStreak(Iterable<String> readDays, DateTime today) {
  final todayUtc = DateTime.utc(today.year, today.month, today.day);
  final days = readDays.map(_parse).where((d) => !d.isAfter(todayUtc)).toSet().toList()
    ..sort();
  if (days.isEmpty) {
    return const StreakInfo(current: 0, hasFreeze: false, readToday: false);
  }

  var streak = 0;
  var freezes = 0;
  DateTime? prev;
  for (final d in days) {
    if (prev == null) {
      streak = 1;
    } else {
      final gap = d.difference(prev).inDays - 1;
      if (gap == 0) {
        streak++;
      } else if (gap == 1 && freezes >= 1) {
        freezes--;
        streak++;
      } else {
        streak = 1;
        freezes = 0;
      }
    }
    if (streak % 7 == 0) freezes = 1;
    prev = d;
  }

  final sinceLast = todayUtc.difference(prev!).inDays;
  final alive = sinceLast <= 1 || (sinceLast == 2 && freezes >= 1);
  return StreakInfo(
    current: alive ? streak : 0,
    hasFreeze: alive && freezes >= 1,
    readToday: sinceLast == 0,
  );
}
