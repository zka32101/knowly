import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/logic/daily_pick.dart';
import 'package:knowly/logic/notification_plan.dart';
import 'package:knowly/models/age_band.dart';
import 'package:knowly/models/trivia.dart';

Trivia _t(String id) => Trivia(
      id: id,
      category: 'animals',
      scenes: const ['friends'],
      minAgeBand: AgeBand.kids,
      sensitivity: 'none',
      regions: const [],
      illustration: '',
      translations: const {},
    );

void main() {
  final pool = [for (var i = 0; i < 20; i++) _t('t$i')];

  test('通知時刻の前なら、今日から14日ぶん', () {
    final plan = planNotifications(
        pool: pool, now: DateTime(2026, 10, 23, 6, 0), hour: 7, minute: 30);
    expect(plan, hasLength(14));
    expect(plan.first.fireAt, DateTime(2026, 10, 23, 7, 30));
    expect(plan.last.fireAt, DateTime(2026, 11, 5, 7, 30));
  });

  test('通知時刻をすぎていたら、明日から', () {
    final plan = planNotifications(
        pool: pool, now: DateTime(2026, 10, 23, 8, 0), hour: 7, minute: 30);
    expect(plan.first.fireAt, DateTime(2026, 10, 24, 7, 30));
  });

  test('ちょうど通知時刻なら、明日から（すでに鳴る時刻）', () {
    final plan = planNotifications(
        pool: pool, now: DateTime(2026, 10, 23, 7, 30), hour: 7, minute: 30);
    expect(plan.first.fireAt, DateTime(2026, 10, 24, 7, 30));
  });

  test('各日の通知は、その日の「今日の雑学」と同じ', () {
    final plan = planNotifications(
        pool: pool, now: DateTime(2026, 10, 23, 6, 0), hour: 7, minute: 0);
    for (final p in plan) {
      expect(p.fact.id, pickForDay(pool, p.fireAt)!.id);
    }
  });

  test('IDは重複しない', () {
    final plan = planNotifications(
        pool: pool, now: DateTime(2026, 10, 23, 6, 0), hour: 7, minute: 0);
    expect(plan.map((p) => p.id).toSet().length, plan.length);
  });

  test('候補がなければ空', () {
    expect(
        planNotifications(
            pool: const [], now: DateTime(2026, 10, 23), hour: 7, minute: 0),
        isEmpty);
  });

  test('月またぎ・年またぎ', () {
    final plan = planNotifications(
        pool: pool, now: DateTime(2026, 12, 25, 6, 0), hour: 7, minute: 0);
    expect(plan.last.fireAt, DateTime(2027, 1, 7, 7, 0));
  });
}
