import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/age_band.dart';
import '../models/calendar_event.dart';
import '../models/category.dart';
import '../models/glossary.dart';
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
      (categories.isEmpty || CategoryRegistry.matches(categories, t.category)) &&
      (scenes.isEmpty || t.scenes.any(scenes.contains));
}

class TriviaRepository {
  TriviaRepository(
    this.items, {
    List<QuizItem> quizzes = const [],
    this.choiceQuizzes = const [],
    this.glossary = const [],
    List<WhyLink> whyLinks = const [],
    this.myths = const [],
    this.events = const [],
    this.projects = const [],
    List<TriviaCategory> categories = const [],
  })  : categories = _sortedCategories(categories),
         _quizzes = {for (final q in quizzes) q.factId: q},
        _whyLinks = {for (final w in whyLinks) w.from: w} {
    if (this.categories.isNotEmpty) CategoryRegistry.set(this.categories);
  }

  final List<Trivia> items;
  final List<Myth> myths;
  final List<ChoiceQuiz> choiceQuizzes;

  /// 難しいことばの説明。
  final List<GlossaryEntry> glossary;
  final List<CalendarEvent> events;
  final List<Project> projects;

  /// カテゴリー（表示順）。categories.json がなければ、雑学に出てくるカテゴリーを並べる。
  final List<TriviaCategory> categories;

  static List<TriviaCategory> _sortedCategories(List<TriviaCategory> c) =>
      c.where((e) => e.active).toList()..sort((a, b) => a.order.compareTo(b.order));

  /// この言語の雑学が、この配信で出せる（レビュー済み、または開発中の下書き可）ものが1つでもあるか。
  bool hasShippableContent(String lang, {bool allowDraft = kAllowDraftContent}) =>
      items.any((t) => t.translations[lang]?.isShippable(allowDraft: allowDraft) ?? false);

  /// 選択肢に出すカテゴリーの id（表示順）。
  List<String> get categoryIds {
    if (categories.isEmpty) return items.map((t) => t.category).toSet().toList()..sort();
    // 親の次に子が並ぶ順（それぞれ order の順）。
    final ids = {for (final c in categories) c.id};
    final out = <String>[];
    void add(TriviaCategory c) {
      if (out.contains(c.id)) return;
      out.add(c.id);
      for (final k in categories) {
        if (k.parent == c.id) add(k);
      }
    }
    for (final c in categories) {
      if (c.parent == null || !ids.contains(c.parent)) add(c);
    }
    return out;
  }
  final Map<String, QuizItem> _quizzes;
  final Map<String, WhyLink> _whyLinks;

  static const assetPath = 'assets/trivia/trivia.json';
  static const quizAssetPath = 'assets/trivia/quiz.json';
  static const choiceQuizAssetPath = 'assets/trivia/quiz_choice.json';
  static const glossaryAssetPath = 'assets/trivia/glossary.json';
  static const whyAssetPath = 'assets/trivia/why_chains.json';
  static const mythAssetPath = 'assets/trivia/myths.json';
  static const calendarAssetPath = 'assets/trivia/calendar.json';
  static const projectAssetPath = 'assets/trivia/projects.json';
  static const categoryAssetPath = 'assets/trivia/categories.json';

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
    final choiceDecoded =
        jsonDecode(await b.loadString(choiceQuizAssetPath)) as Map<String, dynamic>;
    final choiceQuizzes = (choiceDecoded['items'] as List)
        .map((e) => ChoiceQuiz.fromJson(e as Map<String, dynamic>))
        .toList();
    final glossaryDecoded =
        jsonDecode(await b.loadString(glossaryAssetPath)) as Map<String, dynamic>;
    final glossary = (glossaryDecoded['items'] as List)
        .map((e) => GlossaryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    final whyDecoded = jsonDecode(await b.loadString(whyAssetPath)) as Map<String, dynamic>;
    final whyLinks = (whyDecoded['items'] as List)
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
    var categories = <TriviaCategory>[];
    try {
      final catDecoded =
          jsonDecode(await b.loadString(categoryAssetPath)) as Map<String, dynamic>;
      categories = (catDecoded['items'] as List)
          .map((e) => TriviaCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('categories.json を読めませんでした: $e');
    }
    return TriviaRepository(list,
        categories: categories,
        quizzes: quizzes,
        choiceQuizzes: choiceQuizzes,
        glossary: glossary,
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

  GlossaryEntry? glossaryEntry(String id) {
    for (final g in glossary) {
      if (g.id == id) return g;
    }
    return null;
  }

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
