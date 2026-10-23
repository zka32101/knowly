/// ○×クイズ（読んだ雑学の復習）。1つの雑学に1問。
class QuizItem {
  const QuizItem({required this.factId, required this.statements});

  final String factId;

  /// 言語 → (文, 正解)。
  final Map<String, ({String statement, bool answer})> statements;

  factory QuizItem.fromJson(Map<String, dynamic> json) {
    final statements = <String, ({String statement, bool answer})>{};
    for (final lang in ['ja', 'en']) {
      final m = json[lang] as Map<String, dynamic>?;
      if (m != null) {
        statements[lang] = (
          statement: m['statement'] as String,
          answer: m['answer'] as bool,
        );
      }
    }
    return QuizItem(factId: json['factId'] as String, statements: statements);
  }

  ({String statement, bool answer})? forLanguage(String lang) =>
      statements[lang] ?? statements['en'];
}

/// 選択式クイズ（4択、2択の比べっこ）。1つの雑学に複数あってもよい。
class ChoiceQuiz {
  const ChoiceQuiz({required this.id, required this.factId, required this.texts});

  final String id;
  final String factId;

  /// 言語 → 問題・選択肢・正解の番号。
  final Map<String, ({String question, List<String> options, int answer})> texts;

  factory ChoiceQuiz.fromJson(Map<String, dynamic> json) {
    final texts = <String, ({String question, List<String> options, int answer})>{};
    for (final lang in ['ja', 'en']) {
      final m = json[lang] as Map<String, dynamic>?;
      if (m != null) {
        texts[lang] = (
          question: m['question'] as String,
          options: List<String>.from(m['options'] as List),
          answer: m['answer'] as int,
        );
      }
    }
    return ChoiceQuiz(
      id: json['id'] as String,
      factId: json['factId'] as String,
      texts: texts,
    );
  }

  ({String question, List<String> options, int answer})? forLanguage(String lang) =>
      texts[lang] ?? texts['en'];
}
