import 'streak.dart';

/// 復習の間隔（日）。正解するごとに次の間隔へ進み、最後まで正解したら復習は卒業。
const reviewIntervals = [1, 3, 7, 14, 30];

class ReviewEntry {
  const ReviewEntry({required this.box, required this.due});

  /// 0 から。正解するごとに +1。
  final int box;

  /// 次に復習する日（yyyy-MM-dd）。
  final String due;

  String encode(String id) => '$id:$box:$due';

  static (String, ReviewEntry)? decode(String raw) {
    final p = raw.split(':');
    if (p.length != 3) return null;
    final box = int.tryParse(p[1]);
    if (box == null || box < 0) return null;
    return (p[0], ReviewEntry(box: box, due: p[2]));
  }
}

String _addDays(DateTime today, int days) =>
    dayKey(DateTime(today.year, today.month, today.day + days));

/// 「知らなかった」を覚えたとき: 明日に復習する。
ReviewEntry firstReview(DateTime today) =>
    ReviewEntry(box: 0, due: _addDays(today, reviewIntervals[0]));

/// 復習の結果を反映する。卒業したら null。
ReviewEntry? afterReview(ReviewEntry e, {required bool correct, required DateTime today}) {
  if (!correct) return firstReview(today);
  final next = e.box + 1;
  if (next >= reviewIntervals.length) return null;
  return ReviewEntry(box: next, due: _addDays(today, reviewIntervals[next]));
}

/// 今日復習する雑学の id（期限が来ているもの。古い順）。
List<String> dueReviewIds(Map<String, ReviewEntry> entries, DateTime today) {
  final key = dayKey(today);
  final due = [for (final e in entries.entries) if (e.value.due.compareTo(key) <= 0) e];
  due.sort((a, b) => a.value.due.compareTo(b.value.due));
  return [for (final e in due) e.key];
}
