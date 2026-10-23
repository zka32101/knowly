import 'age_band.dart';
import 'content_flags.dart';

/// 「今日は何の日」の記念日。国際デー・国の行事など。国限定のものは `regions` で管理する。
/// 文章は、子ども向け（ひらがな）と一般向けの2種類を言語ごとに持つ。
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.month,
    required this.day,
    required this.minAgeBand,
    required this.factId,
    required this.status,
    required this.regions,
    required this.excludeRegions,
    required this.contentFlags,
    required this.translations,
  });

  final String id;
  final int month;
  final int day;
  final AgeBand minAgeBand;

  /// 詳しく読める雑学のID（なければ null）。
  final String? factId;
  final String status;
  final List<String> regions;
  final List<String> excludeRegions;
  final Set<String> contentFlags;
  final Map<String, EventTranslation> translations;

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    final parts = (json['date'] as String).split('-');
    EventText text(Map<String, dynamic> m, String key) {
      final t = m[key] as Map<String, dynamic>;
      return EventText(title: t['title'] as String, body: t['body'] as String);
    }

    final translations = <String, EventTranslation>{};
    (json['translations'] as Map<String, dynamic>).forEach((lang, value) {
      final m = value as Map<String, dynamic>;
      translations[lang] = EventTranslation(
        reviewStatus: m['reviewStatus'] as String? ?? 'draft',
        child: text(m, 'child'),
        standard: text(m, 'default'),
      );
    });
    return CalendarEvent(
      id: json['id'] as String,
      month: int.parse(parts[0]),
      day: int.parse(parts[1]),
      minAgeBand: AgeBand.parse(json['minAgeBand'] as String?) ?? AgeBand.adult,
      factId: json['factId'] as String?,
      status: json['status'] as String? ?? 'active',
      regions: List<String>.from(json['regions'] as List? ?? const []),
      excludeRegions: List<String>.from(json['excludeRegions'] as List? ?? const []),
      contentFlags: Set<String>.from(json['contentFlags'] as List? ?? const []),
      translations: translations,
    );
  }

  bool occursOn(DateTime d) => d.month == month && d.day == day;

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

  EventText? textFor(AgeBand band, String lang, {required bool allowDraft}) {
    if (!allowedFor(band)) return null;
    for (final code in {lang, 'en'}) {
      final t = translations[code];
      if (t == null || !t.isShippable(allowDraft: allowDraft)) continue;
      return band.isChild ? t.child : t.standard;
    }
    return null;
  }
}

class EventText {
  const EventText({required this.title, required this.body});
  final String title;
  final String body;
}

class EventTranslation {
  const EventTranslation({
    required this.reviewStatus,
    required this.child,
    required this.standard,
  });

  final String reviewStatus;
  final EventText child;
  final EventText standard;

  bool isShippable({required bool allowDraft}) =>
      reviewStatus == 'published' ||
      reviewStatus == 'reviewed' ||
      (allowDraft && reviewStatus == 'draft');
}

/// 画面に出す1日ぶんの記念日（カレンダーの記念日、または記念日つきの雑学）。
class DayEvent {
  const DayEvent({
    required this.id,
    required this.date,
    required this.title,
    required this.body,
    required this.factId,
    required this.isCountrySpecific,
  });

  final String id;
  final DateTime date;
  final String title;
  final String body;
  final String? factId;

  /// 国限定の行事（日本の行事など）。
  final bool isCountrySpecific;
}
