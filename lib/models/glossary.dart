/// 用語の説明（1言語ぶん）。[simple] はやさしい説明、[detail] はくわしい説明（なくてもよい）。
class GlossaryText {
  const GlossaryText({
    required this.term,
    required this.match,
    required this.simple,
    this.detail = '',
  });

  /// 見出しに出すことば。
  final String term;

  /// 本文の中で、このことばとして扱う表記（複数形・別の書き方など）。
  final List<String> match;
  final String simple;
  final String detail;

  factory GlossaryText.fromJson(Map<String, dynamic> json) => GlossaryText(
        term: json['term'] as String,
        match: List<String>.from(json['match'] as List),
        simple: json['simple'] as String,
        detail: json['detail'] as String? ?? '',
      );
}

/// 難しいことばの説明。本文のそのことばをタップすると、説明の画面が開く。
class GlossaryEntry {
  const GlossaryEntry({required this.id, required this.texts});

  final String id;

  /// 言語 → 説明。その言語の説明がなければ、その言語の本文ではリンクにしない。
  final Map<String, GlossaryText> texts;

  factory GlossaryEntry.fromJson(Map<String, dynamic> json) {
    final texts = <String, GlossaryText>{};
    for (final lang in ['ja', 'en']) {
      final m = json[lang] as Map<String, dynamic>?;
      if (m != null) texts[lang] = GlossaryText.fromJson(m);
    }
    return GlossaryEntry(id: json['id'] as String, texts: texts);
  }

  GlossaryText? forLanguage(String lang) => texts[lang];
}
