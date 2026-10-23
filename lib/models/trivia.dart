import 'age_band.dart';
import 'content_flags.dart';

/// 年代別の本文。
class TriviaLevel {
  const TriviaLevel({required this.title, required this.body});
  final String title;
  final String body;
}

/// 雑学に出てくることばの対訳（英語 ↔ 日本語）。日本語は、ひらがな・カタカナの読み（[ja]）と、
/// あれば漢字の表記（[kanji]）を持つ。Teen/Adult には漢字も添え、Kids/Junior はかなだけを出す。
class VocabEntry {
  const VocabEntry({required this.en, required this.ja, this.kanji = ''});
  final String en;
  final String ja;
  final String kanji;

  factory VocabEntry.fromJson(Map<String, dynamic> json) => VocabEntry(
        en: json['en'] as String,
        ja: json['ja'] as String,
        kanji: json['kanji'] as String? ?? '',
      );
}

/// 雑学の出典。
class TriviaSource {
  const TriviaSource({required this.title, this.publisher = '', this.url = ''});
  final String title;
  final String publisher;
  final String url;

  factory TriviaSource.fromJson(Map<String, dynamic> json) => TriviaSource(
        title: json['title'] as String? ?? '',
        publisher: json['publisher'] as String? ?? '',
        url: json['url'] as String? ?? '',
      );
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
    this.seasons = const {},
    this.dates = const [],
    this.timeOfDay = const {},
    this.status = 'active',
    this.excludeRegions = const [],
    this.keywords = const [],
    this.related = const [],
    this.contentFlags = const {},
    this.vocab = const [],
    this.sources = const [],
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

  /// 季節（spring/summer/autumn/winter。北半球の季節で記述）。空なら一年中。
  final Set<String> seasons;

  /// 記念日（MM-DD）。その前後の日に「記念日のおすすめ」に出る。
  final List<String> dates;

  /// 時間帯（morning/day/evening/night）。空ならいつでも。
  final Set<String> timeOfDay;

  /// 公開状態。active のみ表示する。hidden（一時的に非表示）・retired（削除済み）は配信しない
  /// （誤りが見つかったときなど、アプリの更新を待たずに止められるようにするため）。
  final String status;

  /// `regions` は「表示してよい国」（空なら世界中）。`excludeRegions` は「表示しない国」。
  /// 国コードは ISO 3166-1 の2文字（JP、US など）。
  final List<String> excludeRegions;

  /// 検索用の別名（読み・漢字・英語・類義語）。タイトルと同じ重みで検索に使う。
  final List<String> keywords;

  /// 関連する雑学のID（詳細画面の「関連する雑学」）。
  final List<String> related;

  /// 話題の種類のタグ（[validContentFlags]）。年代ごとに配信を止める話題の判定に使う。
  final Set<String> contentFlags;

  /// 「雑学で英語」: この雑学に出てくることばの対訳。
  final List<VocabEntry> vocab;

  /// 出典（Teen/Adult の詳細画面に表示する）。
  final List<TriviaSource> sources;

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
      seasons: Set<String>.from(json['seasons'] as List? ?? const []),
      dates: List<String>.from(json['dates'] as List? ?? const []),
      timeOfDay: Set<String>.from(json['timeOfDay'] as List? ?? const []),
      status: json['status'] as String? ?? 'active',
      excludeRegions: List<String>.from(json['excludeRegions'] as List? ?? const []),
      keywords: List<String>.from(json['keywords'] as List? ?? const []),
      related: List<String>.from(json['related'] as List? ?? const []),
      contentFlags: Set<String>.from(json['contentFlags'] as List? ?? const []),
      vocab: [
        for (final v in json['vocab'] as List? ?? const [])
          VocabEntry.fromJson(v as Map<String, dynamic>),
      ],
      sources: [
        for (final v in json['sources'] as List? ?? const [])
          TriviaSource.fromJson(v as Map<String, dynamic>),
      ],
    );
  }

  /// この国で表示してよいか。国が分からない（null）ときは、国限定の雑学は出さない。
  /// 全世界の表示を選んだとき（[anyRegion] が true）は、国の制限を無視する。
  bool allowedInRegion(String? region, {bool anyRegion = false}) {
    if (status != 'active') return false;
    if (anyRegion) return true;
    final r = region?.toUpperCase();
    if (r != null && excludeRegions.contains(r)) return false;
    if (regions.isEmpty) return true;
    return r != null && regions.contains(r);
  }

  /// 年代に対して配信してよい内容か（感度・最小年代）。
  bool allowedFor(AgeBand band) {
    if (band.index < minAgeBand.index) return false;
    // 話題のタグ: その年代で止める話題を含むものは出さない。
    final blocked = blockedFlagsFor(band);
    if (contentFlags.any(blocked.contains)) return false;
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
