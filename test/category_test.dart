import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/data/trivia_repository.dart';
import 'package:knowly/models/category.dart';
import 'package:knowly/models/trivia.dart';

TriviaCategory _c(String id, int order, {String? parent}) => TriviaCategory(
  id: id,
  order: order,
  emoji: '💡',
  parent: parent,
  labels: {'en': id},
);

void main() {
  final repo = TriviaRepository(
    const [],
    categories: [
      _c('nature', 20),
      _c('animals', 10),
      _c('ocean', 40, parent: 'nature'),
      _c('weather', 30, parent: 'nature'),
      _c('bugs', 15, parent: 'animals'),
    ],
  );

  test('カテゴリーの並びは、親の次に子（それぞれ order の順）', () {
    expect(repo.categoryIds, ['animals', 'bugs', 'nature', 'weather', 'ocean']);
  });

  test('親を選ぶと、子のカテゴリーの雑学もふくむ', () {
    expect(CategoryRegistry.matches({'nature'}, 'ocean'), isTrue);
    expect(CategoryRegistry.matches({'nature'}, 'nature'), isTrue);
    expect(CategoryRegistry.matches({'ocean'}, 'nature'), isFalse);
    expect(CategoryRegistry.matches({'animals'}, 'ocean'), isFalse);
    expect(CategoryRegistry.matches({'weather', 'bugs'}, 'bugs'), isTrue);
  });

  test('親がループしていても止まる', () {
    TriviaRepository(
      const [],
      categories: [
        _c('a', 1, parent: 'b'),
        _c('b', 2, parent: 'a'),
      ],
    );
    expect(CategoryRegistry.ancestors('a').length, lessThan(8));
  });

  test('categories.json がない（空）ときは、雑学に出てくるカテゴリーを並べる', () {
    final empty = TriviaRepository(const []);
    expect(empty.categoryIds, isEmpty);
  });

  test('hasShippableContent: 下書きを出せない配信では、レビュー済みの翻訳がある言語だけ true', () {
    final r = TriviaRepository([
      Trivia.fromJson({
        'id': 'a',
        'category': 'x',
        'minAgeBand': 'kids',
        'translations': {
          'ja': {
            'reviewStatus': 'reviewed',
            'levels': {
              'kids': {'title': 't', 'body': 'b'},
            },
          },
          'zh': {
            'reviewStatus': 'draft',
            'levels': {
              'kids': {'title': 't', 'body': 'b'},
            },
          },
        },
      }),
    ]);
    expect(r.hasShippableContent('ja', allowDraft: false), isTrue);
    expect(r.hasShippableContent('zh', allowDraft: false), isFalse);
    expect(r.hasShippableContent('zh', allowDraft: true), isTrue);
    expect(r.hasShippableContent('ko', allowDraft: true), isFalse);
  });
}
