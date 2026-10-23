import 'streak.dart';

/// その日にしたこと（端末内の記録。週のふりかえりに使う）。
class DayActivity {
  const DayActivity({this.seen = 0, this.learned = 0, this.answered = 0, this.correct = 0});
  final int seen;
  final int learned;
  final int answered;
  final int correct;

  bool get isEmpty => seen == 0 && learned == 0 && answered == 0;

  DayActivity operator +(DayActivity o) => DayActivity(
        seen: seen + o.seen,
        learned: learned + o.learned,
        answered: answered + o.answered,
        correct: correct + o.correct,
      );

  DayActivity copyWith({int? seen, int? learned, int? answered, int? correct}) => DayActivity(
        seen: seen ?? this.seen,
        learned: learned ?? this.learned,
        answered: answered ?? this.answered,
        correct: correct ?? this.correct,
      );

  String encode(String day) => '$day:$seen:$learned:$answered:$correct';

  static (String, DayActivity)? decode(String raw) {
    final f = raw.split(':');
    if (f.length != 5) return null;
    final n = [for (final x in f.skip(1)) int.tryParse(x)];
    if (n.any((x) => x == null)) return null;
    return (f[0], DayActivity(seen: n[0]!, learned: n[1]!, answered: n[2]!, correct: n[3]!));
  }
}

/// 記録は直近の [keepDays] 日ぶんだけ残す。
const activityKeepDays = 60;

/// [end]（その日を含む）から [days] 日ぶんの合計。
DayActivity sumActivity(Map<String, DayActivity> map, DateTime end, int days) {
  var total = const DayActivity();
  for (var i = 0; i < days; i++) {
    final d = DateTime(end.year, end.month, end.day - i);
    total += map[dayKey(d)] ?? const DayActivity();
  }
  return total;
}

/// 直近 [days] 日（古い順）の1日ごとの記録。
List<(String, DayActivity)> dailyActivity(Map<String, DayActivity> map, DateTime end, int days) => [
      for (var i = days - 1; i >= 0; i--)
        (
          dayKey(DateTime(end.year, end.month, end.day - i)),
          map[dayKey(DateTime(end.year, end.month, end.day - i))] ?? const DayActivity(),
        ),
    ];

/// 何かした日の数。
int activeDays(Map<String, DayActivity> map, DateTime end, int days) =>
    dailyActivity(map, end, days).where((e) => !e.$2.isEmpty).length;
