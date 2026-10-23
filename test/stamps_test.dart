import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/logic/stamps.dart';
import 'package:knowly/logic/timing.dart';

void main() {
  test('冬は12〜2月にまたがる: 北半球の1〜2月は前の年の冬', () {
    expect(stampYear(DateTime(2027, 1, 15), Season.winter, Hemisphere.north), 2026);
    expect(stampYear(DateTime(2026, 12, 20), Season.winter, Hemisphere.north), 2026);
    expect(stampYear(DateTime(2026, 7, 15), Season.winter, Hemisphere.south), 2026);
    expect(stampYear(DateTime(2026, 4, 1), Season.spring, Hemisphere.north), 2026);
  });

  test('スタンプの印と、季節ごとの取り出し', () {
    expect(stampKey(2026, Season.autumn, 'apple_floats'), '2026-autumn:apple_floats');
    final stamps = {'2026-autumn:b', '2026-autumn:a', '2026-summer:x', '2025-autumn:z'};
    expect(stampsFor(stamps, 2026, Season.autumn), ['a', 'b']);
    expect(stampsFor(stamps, 2026, Season.winter), isEmpty);
  });

  test('3つで完成。完成した帳を数える', () {
    final stamps = {
      '2026-autumn:a', '2026-autumn:b', '2026-autumn:c',
      '2026-summer:a', '2026-summer:b',
    };
    expect(isBookComplete(stamps, 2026, Season.autumn), isTrue);
    expect(isBookComplete(stamps, 2026, Season.summer), isFalse);
    expect(completedBooks(stamps), {'2026-autumn'});
  });

  test('相棒の飾り: いまの季節の今年の帳が完成していれば着る', () {
    final stamps = {'2026-autumn:a', '2026-autumn:b', '2026-autumn:c'};
    expect(currentAccessory(stamps, DateTime(2026, 10, 23), Hemisphere.north), '🍂');
    // 南半球では10月は春。秋の帳は関係ない
    expect(currentAccessory(stamps, DateTime(2026, 10, 23), Hemisphere.south), isNull);
    // 来年の秋には、もう着ていない（また集める）
    expect(currentAccessory(stamps, DateTime(2027, 10, 23), Hemisphere.north), isNull);
    // 半球が不明（季節オフ）でも、北半球として扱う
    expect(currentAccessory(stamps, DateTime(2026, 10, 23), null), '🍂');
  });

  test('季節ごとに飾りと絵文字がある', () {
    for (final s in Season.values) {
      expect(seasonAccessory[s], isNotNull);
      expect(seasonEmoji[s], isNotNull);
    }
  });
}
