import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/logic/activity.dart';

void main() {
  test('保存形式の往復と、壊れた行の無視', () {
    const a = DayActivity(seen: 3, learned: 1, answered: 10, correct: 7);
    final (day, back) = DayActivity.decode(a.encode('2026-10-23'))!;
    expect(day, '2026-10-23');
    expect(back.seen, 3);
    expect(back.correct, 7);
    expect(DayActivity.decode('x:1:2'), isNull);
    expect(DayActivity.decode('2026-10-23:a:1:1:1'), isNull);
  });

  test('sumActivity: その日を含む7日ぶんを足す', () {
    final map = {
      '2026-10-23': const DayActivity(seen: 2),
      '2026-10-17': const DayActivity(seen: 5), // 7日前の端（含む）
      '2026-10-16': const DayActivity(seen: 100), // 範囲の外
    };
    expect(sumActivity(map, DateTime(2026, 10, 23), 7).seen, 7);
    expect(sumActivity(map, DateTime(2026, 10, 16), 7).seen, 100);
  });

  test('dailyActivity: 古い順に7日、ない日は空', () {
    final d = dailyActivity({'2026-10-22': const DayActivity(seen: 1)}, DateTime(2026, 10, 23), 7);
    expect(d.first.$1, '2026-10-17');
    expect(d.last.$1, '2026-10-23');
    expect(d.length, 7);
    expect(d[5].$2.seen, 1);
    expect(d.last.$2.isEmpty, isTrue);
  });

  test('activeDays: 何かした日だけ数える', () {
    final map = {
      '2026-10-21': const DayActivity(seen: 1),
      '2026-10-22': const DayActivity(answered: 3),
      '2026-10-23': const DayActivity(),
    };
    expect(activeDays(map, DateTime(2026, 10, 23), 7), 2);
  });

  test('月またぎでも、日付が正しい', () {
    final d = dailyActivity(const {}, DateTime(2026, 3, 2), 7);
    expect(d.first.$1, '2026-02-24');
  });
}
