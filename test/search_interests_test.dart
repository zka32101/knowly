import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/logic/daily_pick.dart';
import 'package:knowly/logic/interests.dart';
import 'package:knowly/logic/search.dart';
import 'package:knowly/models/age_band.dart';
import 'package:knowly/models/trivia.dart';

Trivia _t(String id, String category, {List<String> scenes = const ['friends']}) => Trivia(
      id: id,
      category: category,
      scenes: scenes,
      minAgeBand: AgeBand.kids,
      sensitivity: 'none',
      regions: const [],
      illustration: '',
      translations: const {},
    );

SearchEntry _e(String title, String body) =>
    SearchEntry(title: foldText(title), body: foldText(body));

void main() {
  group('foldText', () {
    test('カタカナはひらがな、全角英数は半角、英字は小文字', () {
      expect(foldText('ラッコ'), 'らっこ');
      expect(foldText('ＲＡＴ１２３'), 'rat123');
      expect(foldText('Octopus'), 'octopus');
      expect(foldText('ゾウ'), 'ぞう');
    });
    test('漢字・記号・長音はそのまま', () {
      expect(foldText('宇宙！'), '宇宙!');
      expect(foldText('ラーメン'), 'らーめん');
    });
  });

  group('mix32', () {
    test('固定値と、近い入力でも大きく変わること', () {
      expect(mix32(0), 0);
      final a = mix32(fnv1a('a'));
      final b = mix32(fnv1a('b'));
      expect(a, isNot(b));
    });
  });

  group('検索', () {
    test('語は空白（全角も）で分け、すべて含むものだけが一致（AND）', () {
      expect(queryTokens('  ラッコ　 海 '), ['らっこ', '海']);
      expect(queryTokens('   '), isEmpty);
      final e = _e('ラッコの手つなぎ行動', 'ラッコは海上で休む際に手をつなぐ');
      expect(searchScore(e, queryTokens('ラッコ 海')), greaterThan(0));
      expect(searchScore(e, queryTokens('ラッコ 山')), 0);
    });
    test('ひらがなでもカタカナでも一致する', () {
      final e = _e('ラッコの手つなぎ行動', '');
      expect(searchScore(e, queryTokens('らっこ')), 2);
      expect(searchScore(e, queryTokens('ラッコ')), 2);
    });
    test('タイトルに一致するほうが強い', () {
      final inTitle = _e('タコの血は青い', 'ヘモシアニンという物質');
      final inBody = _e('心臓の話', 'タコの心臓は3つある');
      expect(searchScore(inTitle, queryTokens('タコ')), 2);
      expect(searchScore(inBody, queryTokens('タコ')), 1);
    });
    test('日本語と英語の連結した本文で、どちらのことばでも探せる', () {
      final e = _e('タコの血は青い octopus blood is blue', '');
      expect(searchScore(e, queryTokens('octopus')), 2);
      expect(searchScore(e, queryTokens('OCTOPUS')), 2);
      expect(searchScore(e, queryTokens('タコ')), 2);
    });
    test('検索語が空なら全件が対象', () {
      expect(searchScore(_e('a', 'b'), const []), 1);
    });
  });

  group('関心事', () {
    final pool = [
      _t('a', 'animals'),
      _t('b', 'space', scenes: const ['work']),
      _t('c', 'food', scenes: const ['family']),
      _t('d', 'bugs'),
    ];
    final index = {
      'a': _e('ラッコ', 'うみ'),
      'b': _e('月', 'ちきゅうから遠ざかる'),
      'c': _e('スイカ', '水分が多い'),
      'd': _e('アリ', 'ちから持ち'),
    };
    final day = DateTime(2026, 10, 23);

    test('空の関心事は何も出さない', () {
      expect(
          pickInterests(
              pool: pool, interests: const Interests(), index: index, day: day, exclude: {}, count: 5),
          isEmpty);
    });
    test('ジャンルに当てはまるものだけ', () {
      final r = pickInterests(
          pool: pool,
          interests: const Interests(categories: {'animals', 'space'}),
          index: index, day: day, exclude: {}, count: 5);
      expect(r.map((t) => t.id).toSet(), {'a', 'b'});
    });
    test('シーンに当てはまるもの', () {
      final r = pickInterests(
          pool: pool, interests: const Interests(scenes: {'work'}),
          index: index, day: day, exclude: {}, count: 5);
      expect(r.map((t) => t.id), ['b']);
    });
    test('キーワード（かな・英字をそろえて一致）', () {
      final r = pickInterests(
          pool: pool, interests: const Interests(keywords: ['ラッコ']),
          index: index, day: day, exclude: {}, count: 5);
      expect(r.map((t) => t.id), ['a']);
      final r2 = pickInterests(
          pool: pool, interests: const Interests(keywords: ['らっこ']),
          index: index, day: day, exclude: {}, count: 5);
      expect(r2.map((t) => t.id), ['a']);
    });
    test('ジャンルとキーワードはどちらかに当てはまればよい（OR）', () {
      final r = pickInterests(
          pool: pool,
          interests: const Interests(categories: {'food'}, keywords: ['アリ']),
          index: index, day: day, exclude: {}, count: 5);
      expect(r.map((t) => t.id).toSet(), {'c', 'd'});
    });
    test('除外・件数の上限を守る', () {
      final r = pickInterests(
          pool: pool, interests: const Interests(categories: {'animals', 'space', 'food', 'bugs'}),
          index: index, day: day, exclude: {'a'}, count: 2);
      expect(r, hasLength(2));
      expect(r.map((t) => t.id), isNot(contains('a')));
    });
    test('同じ日・同じ条件なら同じ結果、入力順に依存しない', () {
      const i = Interests(categories: {'animals', 'space', 'food', 'bugs'});
      final r1 = pickInterests(pool: pool, interests: i, index: index, day: day, exclude: {}, count: 3);
      final r2 = pickInterests(pool: pool.reversed.toList(), interests: i, index: index, day: day, exclude: {}, count: 3);
      expect(r1.map((t) => t.id), r2.map((t) => t.id));
    });
    test('日が変わると顔ぶれの順序が変わりうる', () {
      const i = Interests(categories: {'animals', 'space', 'food', 'bugs'});
      final orders = {
        for (var d = 0; d < 10; d++)
          pickInterests(pool: pool, interests: i, index: index, day: DateTime(2026, 10, 1 + d), exclude: {}, count: 4)
              .map((t) => t.id)
              .join(),
      };
      expect(orders.length, greaterThan(1));
    });
  });
}
