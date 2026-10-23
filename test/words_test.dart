import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/models/glossary.dart';
import 'package:knowly/screens/words_screen.dart';

List<(GlossaryEntry, GlossaryText)> _all(String lang) {
  final raw = jsonDecode(File('assets/trivia/glossary.json').readAsStringSync())
      as Map<String, dynamic>;
  return [
    for (final e in raw['items'] as List)
      if (GlossaryEntry.fromJson(e as Map<String, dynamic>) case final g)
        if (g.forLanguage(lang) case final t?) (g, t),
  ];
}

void main() {
  final ja = _all('ja');

  test('今日のことば: 日付で決まり、日がかわると変わる', () {
    final a = wordOfTheDay(ja, DateTime(2026, 10, 23))!;
    expect(wordOfTheDay(ja, DateTime(2026, 10, 23))!.$1.id, a.$1.id);
    final ids = {for (var d = 1; d <= 20; d++) wordOfTheDay(ja, DateTime(2026, 11, d))!.$1.id};
    expect(ids.length, greaterThan(5));
    expect(wordOfTheDay(const [], DateTime(2026, 1, 1)), isNull);
  });

  test('ことばクイズ: 4択で、正解は自分の説明、選択肢は重ならない', () {
    final qs = buildWordQuiz(ja, Random(1), question: (t) => 'Q:$t');
    expect(qs, hasLength(10));
    for (final q in qs) {
      expect(q.options, hasLength(4));
      expect(q.options.toSet().length, 4);
      expect(q.statement, startsWith('Q:'));
      final term = q.statement.substring(2);
      final entry = ja.firstWhere((w) => w.$2.term == term);
      expect(q.options[q.correct], entry.$2.simple);
      expect(q.isTrueFalse, isFalse);
    }
    expect(qs.map((q) => q.factId).toSet().length, 10); // 同じことばは重ならない
  });

  test('ことばクイズ: 正解の位置がかたよらない', () {
    final qs = buildWordQuiz(ja, Random(2), question: (t) => t);
    expect(qs.map((q) => q.correct).toSet().length, greaterThan(1));
  });

  test('ことばが4つ未満なら、出題しない', () {
    expect(buildWordQuiz(ja.take(3).toList(), Random(1), question: (t) => t), isEmpty);
  });
}
