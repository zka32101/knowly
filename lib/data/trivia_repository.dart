import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/age_band.dart';
import '../models/calendar_event.dart';
import '../models/myth.dart';
import '../models/project.dart';
import '../models/quiz.dart';
import '../models/trivia.dart';
import '../models/why_link.dart';

/// 未レビュー(draft)の翻訳を配信してよいか。
/// デバッグビルドでは常に true。リリースビルドは既定で false（レビュー済みだけを配信）。
/// 例: `flutter build appbundle --dart-define=ALLOW_DRAFT_CONTENT=false`
const bool kAllowDraftContent =
    kDebugMode || bool.fromEnvironment('ALLOW_DRAFT_CONTENT', defaultValue: false);

/// 絞り込み条件。カテゴリ同士・シーン同士は OR、カテゴリとシーンは AND。
class FeedFilter {
  const FeedFilter({this.categories = const {}, this.scenes = const {}});
  final Set<String> categories;
  final Set<String> scenes;

  bool matches(Trivia t) =>
      (categories.isEmpty || categories.contains(t.category)) &&
      (scenes.isEmpty || t.scenes.any(scenes.contains));
}

class TriviaRepository {
  TriviaRepository(
    this.items, {
    List<QuizItem> quizzes = const [],
    List<WhyLink> whyLinks = const [],
    this.myths = const [],
    this.events = const [],
    this.projects = const [],
  })  : _quizzes = {for (final q in quizzes) q.factId: q},
        _whyLinks = {for (final w in whyLinks) w.from: w};

  final List<Trivia> items;
  final List<Myth> myths;
  final List<CalendarEvent> events;
  final List<Project> projects;
  final Map<String, QuizItem> _quizzes;
  final Map<String, WhyLink> _whyLinks;

  static const assetPath = 'assets/trivia/trivia.json';
  static const quizAssetPath = 'assets/trivia/quiz.json';
  static const whyAssetPath = 'assets/trivia/why_chains.json';
  static const mythAssetPath = 'assets/trivia/myths.json';
  static const calendarAssetPath = 'assets/trivia/calendar.json';
  static const projectAssetPath = 'assets/trivia/projects.json';

  static Future<TriviaRepository> load({AssetBundle? bundle}) async {
    final b = bundle ?? rootBundle;
    final decoded = jsonDecode(await b.loadString(assetPath)) as Map<String, dynamic>;
    final list = (decoded['items'] as List)
        .map((e) => Trivia.fromJson(e as Map<String, dynamic>))
        .toList();
    final quizDecoded =
        jsonDecode(await b.loadString(quizAssetPath)) as Map<String, dynamic>;
    final quizzes = (quizDecoded['items'] as List)
        .map((e) => QuizItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final whyDecoded = jsonDecode(await b.loadString(whyAssetPath)) as Map<String, dynamic>;
    final whyLinks = (whyDecoded['links'] as List)
        .map((e) => WhyLink.fromJson(e as Map<String, dynamic>))
        .toList();
    final mythDecoded = jsonDecode(await b.loadString(mythAssetPath)) as Map<String, dynamic>;
    final myths = (mythDecoded['items'] as List)
        .map((e) => Myth.fromJson(e as Map<String, dynamic>))
        .toList();
    final calDecoded = jsonDecode(await b.loadString(calendarAssetPath)) as Map<String, dynamic>;
    final events = (calDecoded['items'] as List)
        .map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>))
        .toList();
    final projDecoded = jsonDecode(await b.loadString(projectAssetPath)) as Map<String, dynamic>;
    final projects = (projDecoded['items'] as List)
        .map((e) => Project.fromJson(e as Map<String, dynamic>))
        .toList();
    return TriviaRepository(list,
        quizzes: quizzes,
        whyLinks: whyLinks,
        myths: myths,
        events: events,
        projects: projects);
  }

  /// この年代・言語・国で遊べる「ほんと？うそ？」。
  List<Myth> eligibleMyths(
    AgeBand band,
    String lang, {
    bool allowDraft = kAllowDraftContent,
    String? region,
    bool anyRegion = true,
  }) =>
      myths
          .where((m) =>
              m.allowedInRegion(region, anyRegion: anyRegion) &&
              m.textFor(band, lang, allowDraft: allowDraft) != null)
          .toList();

  /// この年代・言語・国で表示できる自由研究。
  List<Project> eligibleProjects(
    AgeBand band,
    String lang, {
    bool allowDraft = kAllowDraftContent,
    String? region,
    bool anyRegion = true,
  }) =>
      projects
          .where((p) =>
              p.allowedInRegion(region, anyRegion: anyRegion) &&
              p.textFor(band, lang, allowDraft: allowDraft) != null)
          .toList();

  /// この年代・言語・国で表示できる記念日。
  List<CalendarEvent> eligibleEvents(
    AgeBand band,
    String lang, {
    bool allowDraft = kAllowDraftContent,
    String? region,
    bool anyRegion = true,
  }) =>
      events
          .where((e) =>
              e.allowedInRegion(region, anyRegion: anyRegion) &&
              e.textFor(band, lang, allowDraft: allowDraft) != null)
          .toList();

  /// この雑学から「なぜ？」でつながる次の輪。なければ null。
  WhyLink? whyFrom(String factId) => _whyLinks[factId];

  QuizItem? quizFor(String factId) => _quizzes[factId];

  Trivia? byId(String id) {
    for (final t in items) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// この年代・言語・国で配信できる雑学。非公開（hidden/retired）のものは出さない。
  List<Trivia> eligible(
    AgeBand band,
    String locale, {
    FeedFilter filter = const FeedFilter(),
    bool allowDraft = kAllowDraftContent,
    String? region,
    bool anyRegion = true,
  }) =>
      items
          .where((t) =>
              t.allowedInRegion(region, anyRegion: anyRegion) &&
              t.levelFor(band, locale, allowDraft: allowDraft) != null &&
              filter.matches(t))
          .toList();
}
