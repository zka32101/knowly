import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/age_band.dart';
import '../models/quiz.dart';
import '../models/trivia.dart';

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
  TriviaRepository(this.items, {List<QuizItem> quizzes = const []})
      : _quizzes = {for (final q in quizzes) q.factId: q};

  final List<Trivia> items;
  final Map<String, QuizItem> _quizzes;

  static const assetPath = 'assets/trivia/trivia.json';
  static const quizAssetPath = 'assets/trivia/quiz.json';

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
    return TriviaRepository(list, quizzes: quizzes);
  }

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
