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
