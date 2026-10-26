import 'age_band.dart';

/// 「なぜ？」チェーンの1つの輪。ある雑学（[from]）から、次の雑学（[to]）へつなぐ質問。
/// 質問は、子ども向け（ひらがな）と一般向けの2種類を言語ごとに持つ。
class WhyLink {
  const WhyLink({required this.from, required this.to, required this.questions});

  final String from;
  final String to;

  /// 言語 → (child, default)
  final Map<String, ({String child, String standard})> questions;

  factory WhyLink.fromJson(Map<String, dynamic> json) {
    final questions = <String, ({String child, String standard})>{};
    for (final lang in const ['ja', 'en', 'zh', 'ko', 'es']) {
      final m = json[lang] as Map<String, dynamic>?;
      if (m != null) {
        questions[lang] = (child: m['child'] as String, standard: m['default'] as String);
      }
    }
    return WhyLink(from: json['from'] as String, to: json['to'] as String, questions: questions);
  }

  /// この年代・言語での質問文。Kids/Junior は子ども向け（ひらがな）。
  String? question(AgeBand band, String lang) {
    final q = questions[lang] ?? questions['en'];
    if (q == null) return null;
    return band.isChild ? q.child : q.standard;
  }
}

/// チェーンを何回つなげたかに応じた、ほめことば（3回以上）。
const whyChainCheerAt = 3;
