import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/models/age_band.dart';
import 'package:knowly/models/trivia.dart';

/// 漢字（CJK統合漢字）を含むか。
final _kanji = RegExp(r'[一-鿿々]');

List<Trivia> _load() {
  final raw = jsonDecode(File('assets/trivia/trivia.json').readAsStringSync())
      as Map<String, dynamic>;
  return (raw['items'] as List)
      .map((e) => Trivia.fromJson(e as Map<String, dynamic>))
      .toList();
}

Map<String, dynamic> _loadQuiz() =>
    jsonDecode(File('assets/trivia/quiz.json').readAsStringSync()) as Map<String, dynamic>;

void main() {
  final items = _load();

  test('id が一意で、必須項目がある', () {
    expect(items.map((t) => t.id).toSet().length, items.length);
    for (final t in items) {
      expect(t.category, isNotEmpty, reason: t.id);
      expect(t.illustration, isNotEmpty, reason: t.id);
      expect(t.scenes, isNotEmpty, reason: t.id);
    }
  });

  test('ja と en で同じ年代の本文が揃っている', () {
    for (final t in items) {
      expect(t.translations['ja']!.levels.keys.toSet(),
          t.translations['en']!.levels.keys.toSet(),
          reason: t.id);
    }
  });

  test('minAgeBand 以上の全年代に本文がある', () {
    for (final t in items) {
      for (final lang in ['ja', 'en']) {
        final levels = t.translations[lang]!.levels;
        for (var i = t.minAgeBand.index; i < AgeBand.values.length; i++) {
          expect(levels.containsKey(AgeBand.values[i]), isTrue,
              reason: '${t.id}/$lang/${AgeBand.values[i].name}');
        }
      }
    }
  });

  test('空の文章がない', () {
    for (final t in items) {
      for (final tr in t.translations.values) {
        for (final l in tr.levels.values) {
          expect(l.title.trim(), isNotEmpty, reason: t.id);
          expect(l.body.trim(), isNotEmpty, reason: t.id);
        }
      }
    }
  });

  test('Kids/Junior の日本語はひらがな中心（漢字を含まない）', () {
    for (final t in items) {
      for (final b in [AgeBand.kids, AgeBand.junior]) {
        final l = t.translations['ja']!.levels[b];
        if (l == null) continue;
        expect(_kanji.hasMatch(l.title), isFalse, reason: '${t.id}/${b.name} title');
        expect(_kanji.hasMatch(l.body), isFalse, reason: '${t.id}/${b.name} body');
      }
    }
  });

  test('Kids の文章は短い', () {
    for (final t in items) {
      final ja = t.translations['ja']!.levels[AgeBand.kids];
      if (ja != null) expect(ja.body.length, lessThanOrEqualTo(60), reason: t.id);
      final en = t.translations['en']!.levels[AgeBand.kids];
      if (en != null) expect(en.body.length, lessThanOrEqualTo(120), reason: t.id);
    }
  });

  test('未レビュー(draft)であることを明示している（人手の確認前に出荷しない）', () {
    for (final t in items) {
      for (final tr in t.translations.values) {
        expect(['draft', 'reviewed', 'published'], contains(tr.reviewStatus));
      }
    }
  });

  group('クイズ', () {
    final quiz = (_loadQuiz()['items'] as List).cast<Map<String, dynamic>>();
    final byId = {for (final t in items) t.id: t};

    test('全問が実在する Kids/Junior 向けの雑学に紐づく', () {
      expect(quiz, isNotEmpty);
      expect(quiz.map((q) => q['factId']).toSet().length, quiz.length);
      for (final q in quiz) {
        final t = byId[q['factId']];
        expect(t, isNotNull, reason: '${q['factId']}');
        expect(t!.minAgeBand.index, lessThanOrEqualTo(AgeBand.junior.index),
            reason: t.id);
      }
    });

    test('日英が揃い、日本語はひらがな中心', () {
      for (final q in quiz) {
        for (final lang in ['ja', 'en']) {
          final m = q[lang] as Map<String, dynamic>;
          expect((m['statement'] as String).trim(), isNotEmpty, reason: '${q['factId']}');
          expect(m['answer'], isA<bool>());
        }
        expect(q['ja']['answer'], q['en']['answer'], reason: '${q['factId']}');
        expect(_kanji.hasMatch(q['ja']['statement'] as String), isFalse,
            reason: '${q['factId']}');
      }
    });

    test('○と×が両方ある', () {
      final answers = quiz.map((q) => q['ja']['answer'] as bool).toSet();
      expect(answers, {true, false});
    });
  });
}
