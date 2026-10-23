import 'age_band.dart';
import 'content_flags.dart';

/// 「ほんと？うそ？」のうわさ検証。よくある勘違い（または意外な本当の話）を○×で確かめる。
/// 文章は、子ども向け（ひらがな）と一般向けの2種類を言語ごとに持つ。
class Myth {
  const Myth({
    required this.id,
    required this.category,
    required this.minAgeBand,
    required this.answer,
    required this.factId,
    required this.status,
    required this.regions,
    required this.excludeRegions,
    required this.contentFlags,
    required this.translations,
  });

  final String id;
  final String category;
  final AgeBand minAgeBand;

  /// 主張が本当なら true（「はちみつは腐らない」）。勘違いなら false。
  final bool answer;

  /// 詳しく読める雑学のID（なければ null）。
  final String? factId;
  final String status;
  final List<String> regions;
  final List<String> excludeRegions;
  final Set<String> contentFlags;
  final Map<String, MythTranslation> translations;

  factory Myth.fromJson(Map<String, dynamic> json) {
    final translations = <String, MythTranslation>{};
    (json['translations'] as Map<String, dynamic>).forEach((lang, value) {
      final m = value as Map<String, dynamic>;
      MythText text(String key) {
        final t = m[key] as Map<String, dynamic>;
        return MythText(statement: t['statement'] as String, explanation: t['explanation'] as String);
      }

      translations[lang] = MythTranslation(
        reviewStatus: m['reviewStatus'] as String? ?? 'draft',
        child: text('child'),
        standard: text('default'),
      );
    });
    return Myth(
      id: json['id'] as String,
      category: json['category'] as String,
      minAgeBand: AgeBand.parse(json['minAgeBand'] as String?) ?? AgeBand.adult,
      answer: json['answer'] as bool,
      factId: json['factId'] as String?,
      status: json['status'] as String? ?? 'active',
      regions: List<String>.from(json['regions'] as List? ?? const []),
      excludeRegions: List<String>.from(json['excludeRegions'] as List? ?? const []),
      contentFlags: Set<String>.from(json['contentFlags'] as List? ?? const []),
      translations: translations,
    );
  }

  bool allowedFor(AgeBand band) =>
      band.index >= minAgeBand.index &&
      !contentFlags.any(blockedFlagsFor(band).contains);

  bool allowedInRegion(String? region, {bool anyRegion = false}) {
    if (status != 'active') return false;
    if (anyRegion) return true;
    final r = region?.toUpperCase();
    if (r != null && excludeRegions.contains(r)) return false;
    if (regions.isEmpty) return true;
    return r != null && regions.contains(r);
  }

  /// この年代・言語での文章。指定言語に無い・未レビューなら英語にフォールバックする。
  MythText? textFor(AgeBand band, String lang, {required bool allowDraft}) {
    if (!allowedFor(band)) return null;
    for (final code in {lang, 'en'}) {
      final t = translations[code];
      if (t == null || !t.isShippable(allowDraft: allowDraft)) continue;
      return band.isChild ? t.child : t.standard;
    }
    return null;
  }
}

class MythText {
  const MythText({required this.statement, required this.explanation});
  final String statement;
  final String explanation;
}

class MythTranslation {
  const MythTranslation({
    required this.reviewStatus,
    required this.child,
    required this.standard,
  });

  final String reviewStatus;
  final MythText child;
  final MythText standard;

  bool isShippable({required bool allowDraft}) =>
      reviewStatus == 'published' ||
      reviewStatus == 'reviewed' ||
      (allowDraft && reviewStatus == 'draft');
}
