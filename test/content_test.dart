import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/models/age_band.dart';
import 'package:knowly/models/content_flags.dart';
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

  test('Kids の日本語はひらがなのみ（漢字を含まない）', () {
    for (final t in items) {
      final l = t.translations['ja']!.levels[AgeBand.kids];
      if (l == null) continue;
      expect(_kanji.hasMatch(l.title), isFalse, reason: '${t.id} title');
      expect(_kanji.hasMatch(l.body), isFalse, reason: '${t.id} body');
    }
  });

  test('Junior の日本語は、漢字のあとに必ず「（よみ）」を添える（漢字（かんじ）の形）', () {
    final note = RegExp(r'[\u4E00-\u9FFF々]+（[ぁ-んー]+）');
    var withKanji = 0;
    for (final t in items) {
      final l = t.translations['ja']!.levels[AgeBand.junior];
      if (l == null) continue;
      for (final text in [l.title, l.body]) {
        // 読みつきの漢字を除いたあとに漢字が残らないこと
        expect(_kanji.hasMatch(text.replaceAll(note, '')), isFalse,
            reason: '${t.id}: $text');
        // 読みだけが孤立していないこと（かっこは必ず漢字の直後）
        expect(RegExp(r'(?<![\u4E00-\u9FFF々])（[ぁ-んー]+）').hasMatch(text), isFalse,
            reason: '${t.id}: $text');
        if (_kanji.hasMatch(text)) withKanji++;
      }
    }
    expect(withKanji, greaterThan(50)); // 漢字を使っている（ひらがなだけではない）
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

  group('Kids/Junior に出してはいけない話題', () {
    // 性・暴力・戦争・死・宗教・賭け事・薬物などを思わせることば（日本語は部分一致、英語は単語一致）。
    const jaWords = [
      '殺', '死', '戦争', '戦い', '兵器', '爆弾', '銃', '宗教', '神様', '神話', 'キリスト', 'イスラム',
      '仏教', '性的', 'セックス', 'エロ', '酒', 'ビール', 'タバコ', 'たばこ', '賭', 'ギャンブル',
      '麻薬', '自殺', '暴力', 'テロ', '虐待', '犯罪', '事故', 'せんそう', 'しゅうきょう', 'ころす',
      'しぬ', 'ばくだん', 'じさつ', 'ぼうりょく',
    ];
    final enWords = RegExp(
      r'\b(kill|killed|killing|death|dead|die|died|war|weapon|weapons|gun|guns|bomb|sex|sexual|drug|drugs|alcohol|beer|wine|cigarette|religion|religious|god|gods|church|gambling|suicide|violence|violent|terror|terrorist|abuse|crime|murder)\b',
      caseSensitive: false,
    );

    List<String> childTexts() {
      final out = <String>[];
      for (final t in items) {
        for (final lang in ['ja', 'en']) {
          for (final b in [AgeBand.kids, AgeBand.junior]) {
            final l = t.translations[lang]!.levels[b];
            if (l != null) out.addAll(['${t.id}/$lang/${b.name}: ${l.title}', '${t.id}/$lang/${b.name}: ${l.body}']);
          }
        }
      }
      final quiz = (_loadQuiz()['items'] as List).cast<Map<String, dynamic>>();
      for (final q in quiz) {
        for (final lang in ['ja', 'en']) {
          out.add('quiz ${q['factId']}/$lang: ${q[lang]['statement']}');
        }
      }
      return out;
    }

    test('Kids/Junior の文章とクイズに、不適切なことばがない', () {
      for (final text in childTexts()) {
        for (final w in jaWords) {
          expect(text.contains(w), isFalse, reason: '「$w」を含む: $text');
        }
        expect(enWords.hasMatch(text), isFalse, reason: text);
      }
    });

    test('Kids/Junior に出る雑学は、話題のタグがなく、感度も none', () {
      for (final t in items) {
        final visibleToChildren = t.minAgeBand.index <= AgeBand.junior.index;
        if (!visibleToChildren) continue;
        expect(t.contentFlags, isEmpty, reason: t.id);
        expect(t.sensitivity, 'none', reason: t.id);
        expect(t.allowedFor(AgeBand.kids), isTrue, reason: t.id);
      }
    });

    test('話題のタグつきの雑学は、Kids/Junior に出ない（タグがあれば止まる）', () {
      for (final flag in validContentFlags) {
        final t = Trivia(
          id: 'x', category: 'c', scenes: const [], minAgeBand: AgeBand.kids,
          sensitivity: 'none', regions: const [], illustration: '',
          translations: const {}, contentFlags: {flag},
        );
        expect(t.allowedFor(AgeBand.kids), isFalse, reason: flag);
        expect(t.allowedFor(AgeBand.junior), isFalse, reason: flag);
      }
    });
  });

  group('なぜ？チェーン', () {
    final doc = jsonDecode(File('assets/trivia/why_chains.json').readAsStringSync())
        as Map<String, dynamic>;
    final links = (doc['links'] as List).cast<Map<String, dynamic>>();
    final byId = {for (final t in items) t.id: t};

    test('つなぐ先の雑学が実在し、自分自身につながらず、1つの雑学から1本だけ', () {
      expect(links, isNotEmpty);
      final froms = <String>{};
      for (final l in links) {
        expect(byId, contains(l['from']), reason: '${l['from']}');
        expect(byId, contains(l['to']), reason: '${l['to']}');
        expect(l['from'], isNot(l['to']));
        expect(froms.add(l['from'] as String), isTrue, reason: '重複: ${l['from']}');
      }
    });

    test('輪がぐるぐる回らない（どこから始めても必ず終わる）', () {
      final next = {for (final l in links) l['from'] as String: l['to'] as String};
      for (final start in next.keys) {
        final seen = <String>{start};
        var cur = start;
        while (next.containsKey(cur)) {
          cur = next[cur]!;
          expect(seen.add(cur), isTrue, reason: '$start からの輪が戻ってくる: $cur');
        }
      }
    });

    test('子ども向けの質問は、日本語はひらがなのみ・不適切なことばなし・英語も空でない', () {
      for (final l in links) {
        final ja = l['ja'] as Map<String, dynamic>;
        final en = l['en'] as Map<String, dynamic>;
        final child = ja['child'] as String;
        expect(_kanji.hasMatch(child), isFalse, reason: child);
        for (final text in [child, ja['default'] as String, en['child'] as String, en['default'] as String]) {
          expect(text.trim(), isNotEmpty, reason: '${l['from']}');
        }
        for (final w in ['殺', '死', '戦争', '宗教', '性的', '酒', '賭', 'せんそう', 'しゅうきょう']) {
          expect(child.contains(w), isFalse, reason: child);
        }
      }
    });

    test('Kids に出る雑学から、Kids に出せない雑学へはつながない', () {
      for (final l in links) {
        final from = byId[l['from']]!;
        final to = byId[l['to']]!;
        if (from.minAgeBand == AgeBand.kids) {
          expect(to.minAgeBand, AgeBand.kids, reason: '${l['from']} → ${l['to']}');
        }
      }
    });
  });
}
