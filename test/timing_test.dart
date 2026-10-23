import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/logic/readings.dart';
import 'package:knowly/logic/timing.dart';
import 'package:knowly/models/age_band.dart';
import 'package:knowly/models/trivia.dart';

Trivia _t(
  String id, {
  Set<String> seasons = const {},
  List<String> dates = const [],
  Set<String> timeOfDay = const {},
  List<String> scenes = const ['friends'],
}) =>
    Trivia(
      id: id,
      category: 'animals',
      scenes: scenes,
      minAgeBand: AgeBand.kids,
      sensitivity: 'none',
      regions: const [],
      illustration: '',
      translations: const {},
      seasons: seasons,
      dates: dates,
      timeOfDay: timeOfDay,
    );

void main() {
  group('半球', () {
    test('南半球のタイムゾーン', () {
      for (final id in [
        'Australia/Sydney', 'Pacific/Auckland', 'America/Sao_Paulo',
        'America/Argentina/Buenos_Aires', 'Africa/Johannesburg', 'America/Santiago',
      ]) {
        expect(hemisphereFromTimezone(id), Hemisphere.south, reason: id);
      }
    });
    test('北半球・不明は北半球', () {
      for (final id in ['Asia/Tokyo', 'America/New_York', 'Europe/London', 'Asia/Kolkata', null]) {
        expect(hemisphereFromTimezone(id), Hemisphere.north, reason: '$id');
      }
    });
  });

  group('季節', () {
    test('北半球（3〜5月が春）', () {
      expect(seasonFor(DateTime(2026, 3, 1), Hemisphere.north), Season.spring);
      expect(seasonFor(DateTime(2026, 5, 31), Hemisphere.north), Season.spring);
      expect(seasonFor(DateTime(2026, 6, 1), Hemisphere.north), Season.summer);
      expect(seasonFor(DateTime(2026, 8, 31), Hemisphere.north), Season.summer);
      expect(seasonFor(DateTime(2026, 9, 1), Hemisphere.north), Season.autumn);
      expect(seasonFor(DateTime(2026, 11, 30), Hemisphere.north), Season.autumn);
      expect(seasonFor(DateTime(2026, 12, 1), Hemisphere.north), Season.winter);
      expect(seasonFor(DateTime(2027, 2, 28), Hemisphere.north), Season.winter);
    });
    test('南半球は半年ずれる', () {
      expect(seasonFor(DateTime(2026, 7, 15), Hemisphere.south), Season.winter);
      expect(seasonFor(DateTime(2026, 1, 15), Hemisphere.south), Season.summer);
      expect(seasonFor(DateTime(2026, 4, 15), Hemisphere.south), Season.autumn);
      expect(seasonFor(DateTime(2026, 10, 15), Hemisphere.south), Season.spring);
    });
    test('12か月すべてで、北と南が必ず反対の季節になる', () {
      const opposite = {
        Season.spring: Season.autumn, Season.summer: Season.winter,
        Season.autumn: Season.spring, Season.winter: Season.summer,
      };
      for (var m = 1; m <= 12; m++) {
        final d = DateTime(2026, m, 15);
        expect(seasonFor(d, Hemisphere.south), opposite[seasonFor(d, Hemisphere.north)], reason: '$m月');
      }
    });
  });

  test('時間帯', () {
    expect(timeBandFor(4), TimeBand.night);
    expect(timeBandFor(5), TimeBand.morning);
    expect(timeBandFor(10), TimeBand.morning);
    expect(timeBandFor(11), TimeBand.day);
    expect(timeBandFor(16), TimeBand.day);
    expect(timeBandFor(17), TimeBand.evening);
    expect(timeBandFor(20), TimeBand.evening);
    expect(timeBandFor(21), TimeBand.night);
    expect(timeBandFor(0), TimeBand.night);
  });

  group('記念日（MM-DD）', () {
    test('当日・前後1日', () {
      expect(dateOffset(['10-01'], DateTime(2026, 10, 1)), 0);
      expect(dateOffset(['10-01'], DateTime(2026, 9, 30)), -1);
      expect(dateOffset(['10-01'], DateTime(2026, 10, 2)), 1);
      expect(dateOffset(['10-01'], DateTime(2026, 10, 3)), isNull);
    });
    test('年をまたぐ（12/31 と 1/1）', () {
      expect(dateOffset(['01-01'], DateTime(2026, 12, 31)), -1);
      expect(dateOffset(['12-31'], DateTime(2027, 1, 1)), 1);
    });
    test('window=0 は当日だけ', () {
      expect(dateOffset(['10-01'], DateTime(2026, 10, 2), window: 0), isNull);
      expect(dateOffset(['10-01'], DateTime(2026, 10, 1), window: 0), 0);
    });
    test('不正な形式は無視する', () {
      expect(dateOffset(['abc', '13-40', '1001'], DateTime(2026, 10, 1)), isNull);
    });
    test('複数のうち一番近いもの', () {
      expect(dateOffset(['10-05', '10-01'], DateTime(2026, 10, 2)), 1);
    });
  });

  group('いまのおすすめの合致', () {
    final summerNoon = TimingContext(now: DateTime(2026, 7, 15, 13), season: Season.summer);
    test('記念日 > 季節 > 時間帯 > 週末の順', () {
      final all = _t('a', seasons: {'summer'}, dates: ['07-15'], timeOfDay: {'day'});
      expect(timingMatch(all, summerNoon)!.reason, TimingReason.date);
      final seasonal = _t('b', seasons: {'summer'}, timeOfDay: {'day'});
      expect(timingMatch(seasonal, summerNoon)!.reason, TimingReason.season);
    });
    test('季節が違えば合わない', () {
      expect(timingMatch(_t('a', seasons: {'winter'}), summerNoon), isNull);
    });
    test('季節をオフ（null）にすると季節は使わない', () {
      final ctx = TimingContext(now: DateTime(2026, 7, 15, 13), season: null);
      expect(timingMatch(_t('a', seasons: {'summer'}), ctx), isNull);
    });
    test('夜・朝の時間帯', () {
      final night = TimingContext(now: DateTime(2026, 7, 15, 22), season: null);
      expect(timingMatch(_t('a', timeOfDay: {'night'}), night)!.reason, TimingReason.night);
      final morning = TimingContext(now: DateTime(2026, 7, 15, 7), season: null);
      expect(timingMatch(_t('a', timeOfDay: {'morning'}), morning)!.reason, TimingReason.morning);
      expect(timingMatch(_t('a', timeOfDay: {'night'}), morning), isNull);
    });
    test('週末は「家族」「こども」のシーンだけ', () {
      final saturday = TimingContext(now: DateTime(2026, 10, 24, 13), season: null);
      expect(timingMatch(_t('a', scenes: ['family']), saturday)!.reason, TimingReason.weekend);
      expect(timingMatch(_t('a', scenes: ['kids']), saturday)!.reason, TimingReason.weekend);
      expect(timingMatch(_t('a', scenes: ['work']), saturday), isNull);
      final monday = TimingContext(now: DateTime(2026, 10, 26, 13), season: null);
      expect(timingMatch(_t('a', scenes: ['family']), monday), isNull);
    });
    test('何のタグもなければ合わない', () {
      expect(timingMatch(_t('a'), summerNoon), isNull);
    });
  });

  group('pickTiming', () {
    final ctx = TimingContext(now: DateTime(2026, 7, 15, 22), season: Season.summer);
    final pool = [
      _t('s1', seasons: {'summer'}),
      _t('s2', seasons: {'summer'}),
      _t('n1', timeOfDay: {'night'}),
      _t('d1', dates: ['07-15']),
      _t('w1', seasons: {'winter'}),
      _t('x'),
    ];
    test('点数の高い順（記念日 → 季節 → 夜）', () {
      final r = pickTiming(pool: pool, ctx: ctx, exclude: {}, count: 10);
      expect(r.map((p) => p.fact.id).first, 'd1');
      expect(r.map((p) => p.fact.id).last, 'n1');
      expect(r.map((p) => p.fact.id).toSet(), {'d1', 's1', 's2', 'n1'});
    });
    test('除外・件数の上限・決定的', () {
      final r = pickTiming(pool: pool, ctx: ctx, exclude: {'d1'}, count: 2);
      expect(r, hasLength(2));
      expect(r.any((p) => p.fact.id == 'd1'), isFalse);
      final again = pickTiming(pool: pool.reversed.toList(), ctx: ctx, exclude: {'d1'}, count: 2);
      expect(again.map((p) => p.fact.id), r.map((p) => p.fact.id));
    });
    test('同点（季節）は日によって入れ替わる', () {
      final seasonal = [for (var i = 0; i < 6; i++) _t('s$i', seasons: {'summer'})];
      final firsts = {
        for (var d = 1; d <= 12; d++)
          pickTiming(
            pool: seasonal,
            ctx: TimingContext(now: DateTime(2026, 7, d, 13), season: Season.summer),
            exclude: {},
            count: 1,
          ).first.fact.id,
      };
      expect(firsts.length, greaterThan(1));
    });
    test('何も合わなければ空', () {
      expect(pickTiming(pool: [_t('x')], ctx: ctx, exclude: {}, count: 3), isEmpty);
    });
  });

  group('pickTodayFact（今日の雑学）', () {
    final pool = [
      _t('winter1', seasons: {'winter'}),
      _t('summer1', seasons: {'summer'}),
      _t('summer2', seasons: {'summer'}),
      _t('allyear'),
      _t('anniv', dates: ['10-01']),
    ];
    test('記念日の当日は、その雑学になる（前後の日にはならない）', () {
      expect(pickTodayFact(pool, DateTime(2026, 10, 1))!.id, 'anniv');
      expect(pickTodayFact(pool, DateTime(2026, 10, 2))!.id, isNot('anniv') );
    });
    test('季節外れは選ばない', () {
      for (var d = 1; d <= 28; d++) {
        final picked = pickTodayFact(pool, DateTime(2026, 7, d), season: Season.summer)!;
        expect(picked.id, isNot('winter1'), reason: '7/$d');
      }
    });
    test('季節をオフ（null）なら季節外れも選ぶ', () {
      final ids = {
        for (var d = 1; d <= 60; d++) pickTodayFact(pool, DateTime(2026, 7, d))!.id,
      };
      expect(ids, contains('winter1'));
    });
    test('合うものがなければ全体から選ぶ（空にならない）', () {
      final onlyWinter = [_t('w1', seasons: {'winter'}), _t('w2', seasons: {'winter'})];
      expect(pickTodayFact(onlyWinter, DateTime(2026, 7, 1), season: Season.summer), isNotNull);
    });
    test('空なら null、同じ日は同じ結果', () {
      expect(pickTodayFact(const [], DateTime(2026, 7, 1)), isNull);
      expect(pickTodayFact(pool, DateTime(2026, 7, 5), season: Season.summer)!.id,
          pickTodayFact(pool.reversed.toList(), DateTime(2026, 7, 5), season: Season.summer)!.id);
    });
  });

  group('stripReadings（読み上げ用）', () {
    test('漢字のあとの読みを取り除く', () {
      expect(stripReadings('タコの血（ち）は青（あお）い'), 'タコの血は青い');
      expect(stripReadings('心臓（しんぞう）は3つ'), '心臓は3つ');
    });
    test('読みでないかっこは残す', () {
      expect(stripReadings('（かっこ）はそのまま'), '（かっこ）はそのまま');
      expect(stripReadings('ABC（abc）'), 'ABC（abc）');
    });
    test('長音を含む読み', () {
      expect(stripReadings('東京（とうきょう）'), '東京');
      expect(stripReadings('球（きゅー）'), '球');
    });
  });
}
