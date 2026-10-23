import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/logic/streak.dart';

void main() {
  final today = DateTime(2026, 10, 23);
  String d(int daysAgo) => dayKey(DateTime(2026, 10, 23 - daysAgo));

  test('読んだ日がなければ 0', () {
    final s = computeStreak(const [], today);
    expect((s.current, s.hasFreeze, s.readToday), (0, false, false));
  });

  test('今日だけ読んだ → 1', () {
    final s = computeStreak([d(0)], today);
    expect((s.current, s.readToday), (1, true));
  });

  test('今日まだ読んでいなくても、昨日まで続いていれば途切れない', () {
    final s = computeStreak([d(3), d(2), d(1)], today);
    expect((s.current, s.readToday), (3, false));
  });

  test('2日以上空くと 0 に戻る（お休み券がないとき）', () {
    expect(computeStreak([d(5), d(4), d(3)], today).current, 0);
  });

  test('7日続くとお休み券がもらえる', () {
    final days = [for (var i = 6; i >= 0; i--) d(i)];
    final s = computeStreak(days, today);
    expect((s.current, s.hasFreeze), (7, true));
  });

  test('お休み券は1日だけ読めなかった日を埋める', () {
    // 7日連続(お休み券を獲得) → 1日休む → 再開
    final days = [for (var i = 9; i >= 3; i--) d(i), d(1), d(0)];
    final s = computeStreak(days, today);
    expect(s.current, 9); // 7 + 2（休んだ日は数えない）
    expect(s.hasFreeze, isFalse); // 使い切った
  });

  test('お休み券があっても、2日休むと途切れる', () {
    final days = [for (var i = 10; i >= 4; i--) d(i), d(0)];
    expect(computeStreak(days, today).current, 1);
  });

  test('お休み券があれば、今日まで1日空いても連続は生きている', () {
    final days = [for (var i = 8; i >= 2; i--) d(i)]; // 7日連続、昨日は休み
    final s = computeStreak(days, today);
    expect(s.current, 7);
    expect(s.hasFreeze, isTrue);
  });

  test('未来の日付は無視、重複は1日として数える', () {
    final s = computeStreak([d(0), d(0), dayKey(DateTime(2026, 11, 1))], today);
    expect(s.current, 1);
  });
}
