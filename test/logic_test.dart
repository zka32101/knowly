import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/logic/daily_pick.dart';
import 'package:knowly/models/age_band.dart';
import 'package:knowly/models/trivia.dart';

Trivia _t(String id, {AgeBand min = AgeBand.kids, String sens = 'none'}) => Trivia(
      id: id,
      category: 'animals',
      scenes: const [],
      minAgeBand: min,
      sensitivity: sens,
      regions: const [],
      illustration: '',
      translations: {
        'en': TriviaTranslation(reviewStatus: 'reviewed', levels: {
          for (final b in AgeBand.values.skip(min.index))
            b: TriviaLevel(title: '$id-${b.name}', body: 'b'),
        }),
      },
    );

void main() {
  group('AgeBand.fromBirthYear（若いほうに見積もる）', () {
    final now = DateTime(2026, 6, 1);
    test('境界', () {
      expect(AgeBand.fromBirthYear(2026, now: now), AgeBand.kids);
      expect(AgeBand.fromBirthYear(2019, now: now), AgeBand.kids); // 6〜7歳 → 6歳
      expect(AgeBand.fromBirthYear(2018, now: now), AgeBand.junior); // 7〜8歳 → 7歳
      expect(AgeBand.fromBirthYear(2013, now: now), AgeBand.junior); // 12〜13歳 → 12歳
      expect(AgeBand.fromBirthYear(2012, now: now), AgeBand.teen); // 13〜14歳 → 13歳
      expect(AgeBand.fromBirthYear(2009, now: now), AgeBand.teen); // 16〜17歳
      expect(AgeBand.fromBirthYear(2008, now: now), AgeBand.teen); // 17〜18歳 → 17歳（安全側）
      expect(AgeBand.fromBirthYear(2007, now: now), AgeBand.adult); // 18〜19歳
      expect(AgeBand.fromBirthYear(1980, now: now), AgeBand.adult);
    });
    test('未来の年でも落ちない', () {
      expect(AgeBand.fromBirthYear(2030, now: now), AgeBand.kids);
    });
  });

  group('Trivia', () {
    test('minAgeBand 未満には出さない', () {
      final t = _t('a', min: AgeBand.teen);
      expect(t.levelFor(AgeBand.kids, 'en', allowDraft: false), isNull);
      expect(t.levelFor(AgeBand.junior, 'en', allowDraft: false), isNull);
      expect(t.levelFor(AgeBand.teen, 'en', allowDraft: false)!.title, 'a-teen');
    });
    test('感度: adult-only は大人だけ、mild は Teen 以上', () {
      expect(_t('a', sens: 'adult-only').allowedFor(AgeBand.teen), isFalse);
      expect(_t('a', sens: 'adult-only').allowedFor(AgeBand.adult), isTrue);
      expect(_t('a', sens: 'mild').allowedFor(AgeBand.junior), isFalse);
      expect(_t('a', sens: 'mild').allowedFor(AgeBand.teen), isTrue);
    });
    test('指定言語が無ければ英語にフォールバック', () {
      expect(_t('a').levelFor(AgeBand.kids, 'ja', allowDraft: false)!.title, 'a-kids');
    });
    test('下位年代の本文を上位年代が使う', () {
      final t = Trivia(
        id: 'x', category: 'c', scenes: const [], minAgeBand: AgeBand.kids,
        sensitivity: 'none', regions: const [], illustration: '',
        translations: {
          'en': const TriviaTranslation(reviewStatus: 'published', levels: {
            AgeBand.kids: TriviaLevel(title: 'k', body: 'b'),
          }),
        },
      );
      expect(t.levelFor(AgeBand.adult, 'en', allowDraft: false)!.title, 'k');
    });
    test('draft は allowDraft=false だと配信しない', () {
      final t = Trivia(
        id: 'x', category: 'c', scenes: const [], minAgeBand: AgeBand.kids,
        sensitivity: 'none', regions: const [], illustration: '',
        translations: {
          'en': const TriviaTranslation(reviewStatus: 'draft', levels: {
            AgeBand.kids: TriviaLevel(title: 'k', body: 'b'),
          }),
        },
      );
      expect(t.levelFor(AgeBand.kids, 'en', allowDraft: false), isNull);
      expect(t.levelFor(AgeBand.kids, 'en', allowDraft: true), isNotNull);
    });
  });

  group('daily pick', () {
    final pool = [for (var i = 0; i < 10; i++) _t('t$i')];
    test('同じ日は同じ結果（入力順に依存しない）', () {
      final day = DateTime(2026, 10, 23);
      expect(pickForDay(pool, day)!.id, pickForDay(pool.reversed.toList(), day)!.id);
    });
    test('候補数ぶんの連続日は重複しない', () {
      final feed = feedFor(pool, DateTime(2026, 10, 23), 10);
      expect(feed.map((t) => t.id).toSet().length, 10);
    });
    test('候補が日数より少なくても重複を除く', () {
      expect(feedFor(pool.take(3).toList(), DateTime(2026, 10, 23), 7).length, 3);
    });
    test('空なら null / 空', () {
      expect(pickForDay(const [], DateTime(2026, 1, 1)), isNull);
      expect(feedFor(const [], DateTime(2026, 1, 1), 7), isEmpty);
    });
    test('FNV-1a は固定値', () {
      expect(fnv1a(''), 0x811c9dc5);
      expect(fnv1a('a'), 0xe40c292c);
    });
  });
}
