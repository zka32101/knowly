import 'age_band.dart';
import 'content_flags.dart';

/// 自由研究ネタ帳の1テーマ。雑学から、家でできる実験・観察につなげる。
/// 日本語の文章は {漢字|よみ} の記法で持つ。Junior は「漢字（よみ）」、Teen/Adult は漢字だけで表示する。
class Project {
  const Project({
    required this.id,
    required this.factId,
    required this.minAgeBand,
    required this.difficulty,
    required this.minutes,
    required this.needsAdult,
    required this.seasons,
    required this.status,
    required this.regions,
    required this.excludeRegions,
    required this.contentFlags,
    required this.translations,
  });

  final String id;
  final String factId;
  final AgeBand minAgeBand;

  /// むずかしさ（1〜3）。
  final int difficulty;
  final int minutes;

  /// おとなといっしょにやる（刃物・熱・あなあけなど）。
  final bool needsAdult;
  final Set<String> seasons;
  final String status;
  final List<String> regions;
  final List<String> excludeRegions;
  final Set<String> contentFlags;
  final Map<String, ProjectTranslation> translations;

  factory Project.fromJson(Map<String, dynamic> json) {
    final translations = <String, ProjectTranslation>{};
    (json['translations'] as Map<String, dynamic>).forEach((lang, value) {
      final m = value as Map<String, dynamic>;
      translations[lang] = ProjectTranslation(
        reviewStatus: m['reviewStatus'] as String? ?? 'draft',
        text: ProjectText(
          title: m['title'] as String,
          summary: m['summary'] as String,
          materials: List<String>.from(m['materials'] as List),
          steps: List<String>.from(m['steps'] as List),
          observe: m['observe'] as String,
          safety: m['safety'] as String,
        ),
      );
    });
    return Project(
      id: json['id'] as String,
      factId: json['factId'] as String,
      minAgeBand: AgeBand.parse(json['minAgeBand'] as String?) ?? AgeBand.adult,
      difficulty: json['difficulty'] as int,
      minutes: json['minutes'] as int,
      needsAdult: json['needsAdult'] as bool,
      seasons: Set<String>.from(json['seasons'] as List? ?? const []),
      status: json['status'] as String? ?? 'active',
      regions: List<String>.from(json['regions'] as List? ?? const []),
      excludeRegions: List<String>.from(json['excludeRegions'] as List? ?? const []),
      contentFlags: Set<String>.from(json['contentFlags'] as List? ?? const []),
      translations: translations,
    );
  }

  bool allowedFor(AgeBand band) =>
      band.index >= minAgeBand.index && !contentFlags.any(blockedFlagsFor(band).contains);

  bool allowedInRegion(String? region, {bool anyRegion = false}) {
    if (status != 'active') return false;
    if (anyRegion) return true;
    final r = region?.toUpperCase();
    if (r != null && excludeRegions.contains(r)) return false;
    if (regions.isEmpty) return true;
    return r != null && regions.contains(r);
  }

  /// この年代・言語での文章。日本語は、Junior なら「漢字（よみ）」、それ以外は漢字だけに直して返す。
  ProjectText? textFor(AgeBand band, String lang, {required bool allowDraft}) {
    if (!allowedFor(band)) return null;
    for (final code in {lang, 'en'}) {
      final t = translations[code];
      if (t == null || !t.isShippable(allowDraft: allowDraft)) continue;
      return code == 'ja' ? t.text.rendered(showReadings: band.isChild) : t.text;
    }
    return null;
  }
}

class ProjectText {
  const ProjectText({
    required this.title,
    required this.summary,
    required this.materials,
    required this.steps,
    required this.observe,
    required this.safety,
  });

  final String title;
  final String summary;
  final List<String> materials;
  final List<String> steps;
  final String observe;
  final String safety;

  ProjectText rendered({required bool showReadings}) {
    String r(String s) => renderRuby(s, showReadings: showReadings);
    return ProjectText(
      title: r(title),
      summary: r(summary),
      materials: [for (final m in materials) r(m)],
      steps: [for (final s in steps) r(s)],
      observe: r(observe),
      safety: r(safety),
    );
  }
}

class ProjectTranslation {
  const ProjectTranslation({required this.reviewStatus, required this.text});
  final String reviewStatus;
  final ProjectText text;

  bool isShippable({required bool allowDraft}) =>
      reviewStatus == 'published' ||
      reviewStatus == 'reviewed' ||
      (allowDraft && reviewStatus == 'draft');
}

/// {漢字|よみ} を「漢字（よみ）」（[showReadings] が true）または「漢字」に直す。
String renderRuby(String text, {required bool showReadings}) => text.replaceAllMapped(
      RegExp(r'\{([^|{}]+)\|([^|{}]+)\}'),
      (m) => showReadings ? '${m.group(1)}（${m.group(2)}）' : m.group(1)!,
    );
