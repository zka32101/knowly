import 'age_band.dart';

/// 年代別の本文。
class TriviaLevel {
  const TriviaLevel({required this.title, required this.body});
  final String title;
  final String body;
}

/// 言語ごとの翻訳。`reviewStatus` が published / reviewed のものだけを配信する。
class TriviaTranslation {
  const TriviaTranslation({required this.reviewStatus, required this.levels});
  final String reviewStatus;
  final Map<AgeBand, TriviaLevel> levels;

  bool isShippable({required bool allowDraft}) =>
      reviewStatus == 'published' ||
      reviewStatus == 'reviewed' ||
      (allowDraft && reviewStatus == 'draft');
}

class Trivia {
  const Trivia({
    required this.id,
    required this.category,
    required this.scenes,
    required this.minAgeBand,
    required this.sensitivity,
    required this.regions,
    required this.illustration,
    required this.translations,
  });

  final String id;
  final String category;
  final List<String> scenes;
  final AgeBand minAgeBand;

  /// none / mild / adult-only
  final String sensitivity;
  final List<String> regions;
  final String illustration;
  final Map<String, TriviaTranslation> translations;

  factory Trivia.fromJson(Map<String, dynamic> json) {
    final translations = <String, TriviaTranslation>{};
    (json['translations'] as Map<String, dynamic>).forEach((locale, value) {
      final map = value as Map<String, dynamic>;
      final levels = <AgeBand, TriviaLevel>{};
      (map['levels'] as Map<String, dynamic>).forEach((band, level) {
        final parsed = AgeBand.parse(band);
        if (parsed == null) return;
        final l = level as Map<String, dynamic>;
        levels[parsed] = TriviaLevel(
          title: l['title'] as String,
          body: l['body'] as String,
        );
      });
      translations[locale] = TriviaTranslation(
        reviewStatus: map['reviewStatus'] as String? ?? 'draft',
        levels: levels,
      );
    });
    return Trivia(
      id: json['id'] as String,
      category: json['category'] as String,
      scenes: List<String>.from(json['scenes'] as List? ?? const []),
      minAgeBand: AgeBand.parse(json['minAgeBand'] as String?) ?? AgeBand.adult,
      sensitivity: json['sensitivity'] as String? ?? 'adult-only',
      regions: List<String>.from(json['regions'] as List? ?? const []),
      illustration: json['illustration'] as String? ?? '',
      translations: translations,
    );
  }

  /// 年代に対して配信してよい内容か（感度・最小年代）。
  bool allowedFor(AgeBand band) {
    if (band.index < minAgeBand.index) return false;
    switch (sensitivity) {
      case 'none':
        return true;
      case 'mild':
        return band.isTeenOrAdult;
      default:
        return band == AgeBand.adult;
    }
  }

  /// 表示する本文。指定言語に無い・未レビューなら英語にフォールバックする。
  /// 該当年代の本文が無いときは、その下の年代の本文を使う（最小年代まで）。
  TriviaLevel? levelFor(AgeBand band, String locale, {required bool allowDraft}) {
    if (!allowedFor(band)) return null;
    for (final code in {locale, 'en'}) {
      final translation = translations[code];
      if (translation == null || !translation.isShippable(allowDraft: allowDraft)) {
        continue;
      }
      for (var i = band.index; i >= minAgeBand.index; i--) {
        final level = translation.levels[AgeBand.values[i]];
        if (level != null) return level;
      }
    }
    return null;
  }
}
