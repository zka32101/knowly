import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/logic/glossary.dart';
import 'package:knowly/models/glossary.dart';

GlossaryEntry _e(String id, {String? ja, String? en, List<String>? jaMatch, List<String>? enMatch}) =>
    GlossaryEntry(id: id, texts: {
      if (ja != null) 'ja': GlossaryText(term: ja, match: jaMatch ?? [ja], simple: 'x'),
      if (en != null) 'en': GlossaryText(term: en, match: enMatch ?? [en], simple: 'x'),
    });

List<GlossaryEntry> _data() {
  final raw = jsonDecode(File('assets/trivia/glossary.json').readAsStringSync())
      as Map<String, dynamic>;
  return (raw['items'] as List)
      .map((e) => GlossaryEntry.fromJson(e as Map<String, dynamic>))
      .toList();
}

List<String> _bodies(String lang) {
  final raw = jsonDecode(File('assets/trivia/trivia.json').readAsStringSync())
      as Map<String, dynamic>;
  return [
    for (final i in raw['items'] as List)
      for (final l in ((i['translations'][lang]['levels']) as Map<String, dynamic>).values)
        (l as Map<String, dynamic>)['body'] as String,
  ];
}

void main() {
  group('segmentGlossary', () {
    test('日本語: 用語の前後と用語に分かれる', () {
      final s = segmentGlossary('血液は銅を含みます。', [_e('cu', ja: '銅')], 'ja');
      expect(s.map((x) => x.text), ['血液は', '銅', 'を含みます。']);
      expect(s.map((x) => x.entryId), [null, 'cu', null]);
    });

    test('同じ用語は最初の1か所だけ', () {
      final s = segmentGlossary('銅と銅', [_e('cu', ja: '銅')], 'ja');
      expect(s.where((x) => x.entryId != null), hasLength(1));
      expect(s.map((x) => x.text).join(), '銅と銅');
    });

    test('長い方を優先し、重ならない', () {
      final s = segmentGlossary('自転周期は', [
        _e('rot', ja: '自転周期'),
        _e('short', ja: '自転'),
      ], 'ja');
      expect(s.where((x) => x.entryId != null).map((x) => x.entryId), ['rot']);
    });

    test('英語: 大文字小文字を区別せず、単語の途中は一致しない', () {
      final entries = [_e('ph', en: 'pH'), _e('ach', en: 'achene', enMatch: ['achenes', 'achene'])];
      expect(segmentGlossary('The PH is low', entries, 'en').where((x) => x.entryId == 'ph'),
          hasLength(1));
      expect(segmentGlossary('phone', entries, 'en').any((x) => x.entryId != null), isFalse);
      expect(segmentGlossary('Many achenes here', entries, 'en').map((x) => x.entryId),
          [null, 'ach', null]);
    });

    test('その言語の説明がなければ、リンクにしない', () {
      final only = [_e('x', ja: '銅')];
      expect(segmentGlossary('copper 銅', only, 'en').every((s) => s.entryId == null), isTrue);
    });

    test('見つからなければ、本文がそのまま1つ。空文字は空', () {
      expect(segmentGlossary('なし', [_e('cu', ja: '銅')], 'ja').single.text, 'なし');
      expect(segmentGlossary('', [_e('cu', ja: '銅')], 'ja'), isEmpty);
    });
  });

  group('glossary.json', () {
    final data = _data();

    test('id が重複せず、少なくとも1言語の説明がある', () {
      expect(data.map((e) => e.id).toSet().length, data.length);
      for (final e in data) {
        expect(e.texts, isNotEmpty, reason: e.id);
      }
    });

    test('見出し・一致する表記・やさしい説明が空でない', () {
      for (final e in data) {
        for (final entry in e.texts.entries) {
          final t = entry.value;
          expect(t.term.trim(), isNotEmpty, reason: '${e.id}/${entry.key}');
          expect(t.match, isNotEmpty, reason: '${e.id}/${entry.key}');
          expect(t.simple.trim(), isNotEmpty, reason: '${e.id}/${entry.key}');
        }
      }
    });

    test('どの用語も、いずれかの雑学の本文に出てくる（言語ごと）', () {
      for (final lang in ['ja', 'en']) {
        final bodies = _bodies(lang);
        for (final e in data) {
          if (e.forLanguage(lang) == null) continue;
          final hit = bodies.any((b) =>
              segmentGlossary(b, [e], lang).any((s) => s.entryId == e.id));
          expect(hit, isTrue, reason: '${e.id}/$lang はどの本文にも出てこない');
        }
      }
    });

    test('やさしい説明に、子どもに不向きなことばがない', () {
      const ja = ['殺', '死', '戦争', '兵器', '爆弾', '銃', '宗教', '性的', '酒', 'たばこ', '賭', '麻薬', '暴力'];
      final en = RegExp(
          r'\b(kill|death|dead|die|war|weapon|gun|bomb|sex|sexual|drug|drugs|alcohol|beer|wine|religion|gambling|suicide|violence)\b',
          caseSensitive: false);
      for (final e in data) {
        for (final entry in e.texts.entries) {
          final s = entry.value.simple;
          for (final w in ja) {
            expect(s.contains(w), isFalse, reason: '${e.id}: $w');
          }
          expect(en.hasMatch(s), isFalse, reason: '${e.id}: $s');
        }
      }
    });
  });
}
