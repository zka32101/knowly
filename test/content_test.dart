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

  group('選択式クイズ', () {
    final choice = (jsonDecode(File('assets/trivia/quiz_choice.json').readAsStringSync())
            as Map<String, dynamic>)['items'] as List;
    final byId = {for (final t in items) t.id: t};

    test('実在する Kids/Junior 向けの雑学に紐づき、id が重複しない', () {
      expect(choice, isNotEmpty);
      expect(choice.map((c) => c['id']).toSet().length, choice.length);
      for (final c in choice) {
        final t = byId[c['factId']];
        expect(t, isNotNull, reason: '${c['id']}');
        expect(t!.minAgeBand.index, lessThanOrEqualTo(AgeBand.junior.index), reason: t.id);
      }
    });

    test('日英が揃い、選択肢は2〜4個で重複なし・正解の番号が有効', () {
      for (final c in choice) {
        for (final lang in ['ja', 'en']) {
          final m = c[lang] as Map<String, dynamic>;
          final opts = (m['options'] as List).cast<String>();
          expect(opts.length, inInclusiveRange(2, 4), reason: '${c['id']}');
          expect(opts.toSet().length, opts.length, reason: '${c['id']}/$lang');
          expect(m['answer'] as int, inInclusiveRange(0, opts.length - 1), reason: '${c['id']}');
          expect((m['question'] as String).trim(), isNotEmpty);
        }
        expect(c['ja']['answer'], c['en']['answer'], reason: '${c['id']}');
        expect((c['ja']['options'] as List).length, (c['en']['options'] as List).length);
        expect(_kanji.hasMatch(c['ja']['question'] as String), isFalse, reason: '${c['id']}');
        for (final o in c['ja']['options'] as List) {
          expect(_kanji.hasMatch(o as String), isFalse, reason: '${c['id']}: $o');
        }
      }
    });

    test('正解の位置が偏っていない（全部同じ番号ではない）', () {
      expect(choice.map((c) => c['ja']['answer']).toSet().length, greaterThan(2));
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
      final choice = (jsonDecode(File('assets/trivia/quiz_choice.json').readAsStringSync())
              as Map<String, dynamic>)['items'] as List;
      for (final c in choice) {
        for (final lang in ['ja', 'en']) {
          out.add('choice ${c['id']}/$lang: ${c[lang]['question']} ${(c[lang]['options'] as List).join(' ')}');
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

  group('ほんと？うそ？（うわさ検証）', () {
    final doc = jsonDecode(File('assets/trivia/myths.json').readAsStringSync())
        as Map<String, dynamic>;
    final myths = (doc['items'] as List).cast<Map<String, dynamic>>();
    final factIds = {for (final t in items) t.id};

    test('十分な数があり、IDが一意で、「本当」と「勘違い」の両方がある', () {
      expect(myths.length, greaterThanOrEqualTo(15));
      expect(myths.map((m) => m['id']).toSet().length, myths.length);
      final answers = myths.map((m) => m['answer'] as bool).toSet();
      expect(answers, {true, false});
    });

    test('つなぐ雑学は実在する', () {
      for (final m in myths) {
        if (m['factId'] != null) expect(factIds, contains(m['factId']), reason: '${m['id']}');
      }
    });

    test('日英・子ども向け/一般向けの文章が揃っていて、空でない', () {
      for (final m in myths) {
        final tr = m['translations'] as Map<String, dynamic>;
        for (final lang in ['ja', 'en']) {
          for (final variant in ['child', 'default']) {
            final t = tr[lang][variant] as Map<String, dynamic>;
            expect((t['statement'] as String).trim(), isNotEmpty, reason: '${m['id']}/$lang/$variant');
            expect((t['explanation'] as String).trim(), isNotEmpty, reason: '${m['id']}/$lang/$variant');
          }
        }
      }
    });

    test('子ども向けの日本語は、ひらがな・カタカナだけ（漢字なし）', () {
      for (final m in myths) {
        final c = m['translations']['ja']['child'] as Map<String, dynamic>;
        for (final k in ['statement', 'explanation']) {
          expect(_kanji.hasMatch(c[k] as String), isFalse, reason: '${m['id']}: ${c[k]}');
        }
      }
    });

    test('子ども向けの文章に、不適切なことばがない', () {
      const jaWords = ['殺', '死', '戦争', '兵器', '爆弾', '銃', '宗教', '性的', 'セックス', '酒', 'ビール', '賭', '麻薬', '暴力', 'テロ', 'せんそう', 'しゅうきょう', 'ころす', 'しぬ'];
      final en = RegExp(
        r'\b(kill|killed|death|dead|die|died|war|weapon|gun|bomb|sex|sexual|drug|drugs|alcohol|beer|wine|religion|god|church|gambling|suicide|violence|terror|abuse|crime|murder)\b',
        caseSensitive: false,
      );
      for (final m in myths) {
        final tr = m['translations'] as Map<String, dynamic>;
        for (final text in [
          for (final k in ['statement', 'explanation']) tr['ja']['child'][k] as String,
          for (final k in ['statement', 'explanation']) tr['en']['child'][k] as String,
        ]) {
          for (final w in jaWords) {
            expect(text.contains(w), isFalse, reason: '${m['id']}: $text');
          }
          expect(en.hasMatch(text), isFalse, reason: '${m['id']}: $text');
        }
      }
    });

    test('Kids に出る問題には、話題のタグがない', () {
      for (final m in myths) {
        if (m['minAgeBand'] == 'kids') {
          expect(m['contentFlags'], isEmpty, reason: '${m['id']}');
        }
      }
    });
  });

  group('今日は何の日（calendar.json）', () {
    final doc = jsonDecode(File('assets/trivia/calendar.json').readAsStringSync())
        as Map<String, dynamic>;
    final events = (doc['items'] as List).cast<Map<String, dynamic>>();
    final factIds = {for (final t in items) t.id};

    test('IDが一意で、日付が正しく、つなぐ雑学が実在する', () {
      expect(events.length, greaterThanOrEqualTo(15));
      expect(events.map((e) => e['id']).toSet().length, events.length);
      for (final e in events) {
        final p = (e['date'] as String).split('-');
        final m = int.parse(p[0]);
        final d = int.parse(p[1]);
        expect(DateTime.utc(2024, m, d).month, m, reason: '${e['id']}: ${e['date']}');
        if (e['factId'] != null) expect(factIds, contains(e['factId']), reason: '${e['id']}');
      }
    });

    test('同じ日付・同じ国の記念日が重ならない（1日に1つ）', () {
      final seen = <String>{};
      for (final e in events) {
        final regions = ((e['regions'] as List).isEmpty ? ['*'] : (e['regions'] as List).cast<String>());
        for (final r in regions) {
          expect(seen.add('${e['date']}/$r'), isTrue, reason: '${e['date']}/$r');
        }
      }
    });

    test('国の行事は国タグ（regions）がつき、国際デーは国タグなし', () {
      final jp = events.where((e) => (e['regions'] as List).contains('JP'));
      expect(jp.map((e) => e['id']), containsAll(['hinamatsuri', 'tanabata', 'kodomo_no_hi']));
      final intl = events.where((e) => (e['regions'] as List).isEmpty);
      expect(intl.map((e) => e['id']), containsAll(['earth_day', 'pi_day', 'new_year']));
    });

    test('子ども向けの日本語はひらがな中心（漢字なし）、不適切なことばなし', () {
      const bad = ['殺', '死', '戦争', '宗教', '性的', '酒', '賭', '兵器', 'せんそう', 'しゅうきょう'];
      for (final e in events) {
        final c = e['translations']['ja']['child'] as Map<String, dynamic>;
        for (final k in ['title', 'body']) {
          final text = c[k] as String;
          expect(_kanji.hasMatch(text), isFalse, reason: '${e['id']}: $text');
          for (final w in bad) {
            expect(text.contains(w), isFalse, reason: '${e['id']}: $text');
          }
        }
        expect((e['translations']['en']['child']['body'] as String).trim(), isNotEmpty);
        expect((e['translations']['en']['default']['body'] as String).trim(), isNotEmpty);
      }
    });

    test('Kids に出る記念日には、話題のタグがない', () {
      for (final e in events) {
        if (e['minAgeBand'] == 'kids') expect(e['contentFlags'], isEmpty, reason: '${e['id']}');
      }
    });
  });

  group('雑学で英語（vocab）', () {
    final raw = (jsonDecode(File('assets/trivia/trivia.json').readAsStringSync())
        as Map<String, dynamic>)['items'] as List;
    final facts = raw.cast<Map<String, dynamic>>();
    final kana = RegExp(r'^[ぁ-んァ-ヶー ]+$');
    final english = RegExp(r'^[A-Za-z ]+$');

    test('すべての雑学に、2〜4語の対訳がある', () {
      for (final f in facts) {
        final v = (f['vocab'] as List).cast<Map<String, dynamic>>();
        expect(v.length, inInclusiveRange(2, 4), reason: f['id'] as String);
        expect(v.map((e) => (e['en'] as String).toLowerCase()).toSet().length, v.length,
            reason: '${f['id']}: 重複');
      }
    });

    test('英語は英字、日本語はかなだけ（漢字は kanji に分ける）', () {
      for (final f in facts) {
        for (final e in (f['vocab'] as List).cast<Map<String, dynamic>>()) {
          final id = '${f['id']}: ${e['en']}';
          expect(e['en'], matches(english), reason: id);
          expect(e['ja'], matches(kana), reason: id);
          expect(_kanji.hasMatch(e['ja'] as String), isFalse, reason: id);
          final kanji = e['kanji'] as String;
          if (kanji.isNotEmpty) expect(_kanji.hasMatch(kanji), isTrue, reason: id);
        }
      }
    });

    test('Kids/Junior に出る雑学のことばに、不適切なことばがない', () {
      const bad = ['殺', '死', '戦争', '宗教', '性', '酒', '賭', '銃', '兵器', 'せんそう', 'しゅうきょう'];
      final en = RegExp(r'\b(kill|death|dead|die|war|weapon|gun|bomb|sex|sexual|drug|alcohol|beer|religion|god|gambling|violence|crime)\b', caseSensitive: false);
      for (final f in facts) {
        if (f['minAgeBand'] == 'teen' || f['minAgeBand'] == 'adult') continue;
        for (final e in (f['vocab'] as List).cast<Map<String, dynamic>>()) {
          for (final w in bad) {
            expect((e['ja'] as String).contains(w) || (e['kanji'] as String).contains(w), isFalse,
                reason: '${f['id']}: $w');
          }
          expect(en.hasMatch(e['en'] as String), isFalse, reason: '${f['id']}: ${e['en']}');
        }
      }
    });
  });

  group('自由研究ネタ帳（projects.json）', () {
    final doc = jsonDecode(File('assets/trivia/projects.json').readAsStringSync())
        as Map<String, dynamic>;
    final projects = (doc['items'] as List).cast<Map<String, dynamic>>();
    final factIds = {for (final t in items) t.id};
    final markup = RegExp(r'\{([^|{}]+)\|([^|{}]+)\}');

    Map<String, dynamic> ja(Map<String, dynamic> p) => p['translations']['ja'] as Map<String, dynamic>;
    Map<String, dynamic> en(Map<String, dynamic> p) => p['translations']['en'] as Map<String, dynamic>;
    List<String> jaTexts(Map<String, dynamic> p) => [
          ja(p)['title'] as String,
          ja(p)['summary'] as String,
          ja(p)['observe'] as String,
          ja(p)['safety'] as String,
          ...(ja(p)['materials'] as List).cast<String>(),
          ...(ja(p)['steps'] as List).cast<String>(),
        ];

    test('十分な数があり、IDが一意で、つなぐ雑学が実在する', () {
      expect(projects.length, greaterThanOrEqualTo(10));
      expect(projects.map((p) => p['id']).toSet().length, projects.length);
      for (final p in projects) {
        expect(factIds, contains(p['factId']), reason: '${p['id']}');
        expect(p['difficulty'], inInclusiveRange(1, 3), reason: '${p['id']}');
        expect(p['minutes'] as int, greaterThan(0), reason: '${p['id']}');
        expect(p['needsAdult'], isA<bool>(), reason: '${p['id']}');
      }
    });

    test('材料・手順・観察・安全上の注意がそろっている（日英）', () {
      for (final p in projects) {
        for (final t in [ja(p), en(p)]) {
          expect((t['materials'] as List).length, greaterThanOrEqualTo(2), reason: '${p['id']}');
          expect((t['steps'] as List).length, greaterThanOrEqualTo(3), reason: '${p['id']}');
          expect((t['observe'] as String).trim(), isNotEmpty, reason: '${p['id']}');
          expect((t['safety'] as String).trim(), isNotEmpty, reason: '${p['id']}');
        }
      }
    });

    test('日本語は {漢字|よみ} の記法だけで漢字を書く（読みはひらがな）', () {
      for (final p in projects) {
        for (final x in jaTexts(p)) {
          final rest = x.replaceAll(markup, '');
          expect(_kanji.hasMatch(rest), isFalse, reason: '${p['id']}: $x');
          expect(rest.contains('{') || rest.contains('}') || rest.contains('|'), isFalse,
              reason: '${p['id']}: $x');
          for (final m in markup.allMatches(x)) {
            expect(RegExp(r'^[ぁ-んー]+$').hasMatch(m.group(2)!), isTrue,
                reason: '${p['id']}: ${m.group(0)}');
          }
        }
      }
    });

    test('Junior 向けに直すと、漢字はすべて読みつき', () {
      final note = RegExp(r'[\u4E00-\u9FFF々]+（[ぁ-んー]+）');
      for (final p in projects) {
        for (final x in jaTexts(p)) {
          final junior = x.replaceAllMapped(markup, (m) => '${m.group(1)}（${m.group(2)}）');
          expect(_kanji.hasMatch(junior.replaceAll(note, '')), isFalse, reason: '${p['id']}: $junior');
        }
      }
    });

    test('刃物・熱・あなあけなどの危険なことばがあるテーマは、おとなといっしょ', () {
      const danger = ['包丁', 'ほうちょう', '火', 'コンロ', '針', 'つまようじ', '熱湯', 'カッター', '風船', 'ふうせん', 'ナイフ', '切って', '切る'];
      for (final p in projects) {
        // 「方位磁針」「秒針」は、危険なものではないので除いて調べる。
        final all = [...jaTexts(p).map((x) => x.replaceAllMapped(markup, (m) => m.group(1)!))]
            .join()
            .replaceAll('方位磁針', '')
            .replaceAll('秒針', '');
        if (danger.any(all.contains)) {
          expect(p['needsAdult'], isTrue, reason: '${p['id']} は危険なことばを含む');
        }
      }
    });

    test('不適切なことばがない（日英）', () {
      const bad = ['殺', '死', '戦争', '宗教', '性的', '酒', '賭', '爆発', '毒', '薬品'];
      final enBad = RegExp(r'\b(kill|death|dead|war|weapon|gun|bomb|explode|explosion|poison|alcohol|fire|flame)\b', caseSensitive: false);
      for (final p in projects) {
        for (final x in jaTexts(p).map((x) => x.replaceAllMapped(markup, (m) => m.group(1)!))) {
          for (final w in bad) {
            expect(x.contains(w), isFalse, reason: '${p['id']}: $x');
          }
        }
        for (final x in [en(p)['title'], en(p)['summary'], en(p)['observe'], en(p)['safety'],
            ...(en(p)['materials'] as List), ...(en(p)['steps'] as List)]) {
          expect(enBad.hasMatch(x as String), isFalse, reason: '${p['id']}: $x');
        }
      }
    });
  });
}
