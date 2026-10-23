/// 検索用に文字をそろえる: 英字は小文字、全角の英数字は半角、カタカナはひらがなにする。
/// （「ラッコ」「らっこ」「ＲＡＴ」「rat」のどれでも同じように探せる。漢字とかなの変換はしない。）
String foldText(String input) {
  final out = StringBuffer();
  for (final rune in input.runes) {
    var c = rune;
    // 全角の英数字・記号（！〜～）→ 半角
    if (c >= 0xFF01 && c <= 0xFF5E) c -= 0xFEE0;
    // カタカナ → ひらがな
    if (c >= 0x30A1 && c <= 0x30F6) c -= 0x60;
    out.writeCharCode(c);
  }
  return out.toString().toLowerCase();
}

/// 検索語を空白（半角・全角）で分けて、そろえた語のリストにする。すべての語を含むものだけが一致する（AND）。
List<String> queryTokens(String query) => foldText(query)
    .split(RegExp(r'[\s　]+'))
    .where((t) => t.isNotEmpty)
    .toList();

/// 検索の対象になる文章（そろえ済み）。タイトルと本文は、日本語・英語の両方を連結してある。
class SearchEntry {
  const SearchEntry({required this.title, required this.body});
  final String title;
  final String body;
}

/// 一致の強さ。0 = 一致しない、1 = 本文にだけある、2 = すべての語がタイトルにある。
int searchScore(SearchEntry entry, List<String> tokens) {
  if (tokens.isEmpty) return 1;
  final all = '${entry.title} ${entry.body}';
  if (!tokens.every(all.contains)) return 0;
  return tokens.every(entry.title.contains) ? 2 : 1;
}
