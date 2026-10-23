import 'dart:convert';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../logic/activity.dart';
import '../logic/interests.dart';
import '../logic/league.dart';
import '../logic/review.dart';
import '../logic/search.dart';
import '../logic/streak.dart';
import '../models/age_band.dart';
import 'providers.dart' show nowProvider;

/// 画面の言語。
const supportedLanguageCodes = ['ja', 'en', 'zh', 'ko', 'es'];

/// 雑学の本文がある言語。ほかの言語の画面では、本文は英語で出す。
const contentLanguageCodes = ['ja', 'en'];

/// 端末の言語から対応言語を選ぶ。対応外は英語。
String resolveLanguage(String? code) =>
    supportedLanguageCodes.contains(code) ? code! : 'en';

/// 雑学の本文の言語（日本語または英語）。本文のない言語は英語にする。
String resolveContentLanguage(String? code) => code == 'ja' ? 'ja' : 'en';

/// 関心事のキーワードの上限（個数・1つあたりの文字数）。
const maxInterestKeywords = 10;
const maxInterestKeywordLength = 20;

/// 無料プランで保存できる件数。
const freeSaveLimit = 20;

/// 無料プランで読める過去の日数（今日を含む）。プレミアムは [premiumFeedDays]。
const freeFeedDays = 7;
const premiumFeedDays = 30;

/// 評価の種類。Kids/Junior の評価は端末内にのみ保存し、送信しない。
enum Rating { heh, useful, wow }

/// 「知ってた」「知らなかった」。端末内にのみ保存し、送信しない。
enum Knowledge { knew, learned }

class AppSettings {
  const AppSettings({
    this.ageBand,
    this.uiLanguage,
    this.contentLanguage,
    this.categories = const {},
    this.scenes = const {},
    this.saved = const [],
    this.ratings = const {},
    this.knowledge = const {},
    this.readDays = const [],
    this.notifyEnabled = false,
    this.notifyHour = 7,
    this.notifyMinute = 0,
    this.interestCategories = const {},
    this.interestScenes = const {},
    this.interestKeywords = const [],
    this.regionMode = 'auto',
    this.seasonMode = 'auto',
    this.reviews = const {},
    this.quizAnswered = 0,
    this.quizCorrect = 0,
    this.dailyResults = const {},
    this.seen = const {},
    this.celebratedStage,
    this.celebratedBadges,
    this.capsule,
    this.words = const {},
    this.league = const LeagueData(),
    this.activity = const {},
  });

  /// 生まれた年そのものは保存せず、年代だけを端末内に保存する。
  final AgeBand? ageBand;
  final String? uiLanguage;
  final String? contentLanguage;
  final Set<String> categories;
  final Set<String> scenes;
  final List<String> saved;
  final Map<String, Set<Rating>> ratings;
  final Map<String, Knowledge> knowledge;

  /// 雑学を読んだ日（yyyy-MM-dd）。Teen/Adult のストリーク用。
  final List<String> readDays;

  /// 毎日の通知（端末内の予定通知）。Kids はなし、Junior は保護者が設定したときだけ。
  final bool notifyEnabled;
  final int notifyHour;
  final int notifyMinute;

  /// 登録した関心事（ホームの「あなたの関心」に使う）。端末内にだけ保存する。
  /// `categories` / `scenes` は、一覧を一時的に絞り込む条件（関心事とは別）。
  final Set<String> interestCategories;
  final Set<String> interestScenes;
  final List<String> interestKeywords;

  /// 国・地域の設定。auto = 端末の地域、all = すべての国、それ以外は国コード（JP など）。
  /// 国限定の雑学（`regions` タグつき）は、この設定の国でだけ出す。
  final String regionMode;

  /// 季節の設定。auto = タイムゾーンから北半球・南半球を推定、north / south = 固定、off = 季節を使わない。
  final String seasonMode;

  /// 「知らなかった」雑学の復習の予定（id → 箱と期限）。端末内にだけ保存する。
  final Map<String, ReviewEntry> reviews;

  /// 1人用クイズ（ひとり・復習・今日のチャレンジ）の通算の回答数・正解数。
  final int quizAnswered;
  final int quizCorrect;

  /// 今日のチャレンジの結果（日付 → 正誤の並び。例 "101"）。
  final Map<String, String> dailyResults;

  /// 開いたことのある雑学の id（相棒の成長に使う）。端末内にだけ保存する。
  final Set<String> seen;

  /// お祝いを出し終えた相棒の段階（番号）と、バッジの id。null は「まだ基準を決めていない」。
  final int? celebratedStage;
  final Set<String>? celebratedBadges;

  /// 今日のカプセル（"yyyy-MM-dd:雑学のid"）。1日1回。
  final String? capsule;

  /// 説明を見たことのある用語の id（ことばずかん用）。
  final Set<String> words;

  /// 家族リーグ（この端末で遊んだ対戦の、週ごとの得点）。
  final LeagueData league;

  /// 1日ごとの記録（週のふりかえり用。直近60日）。
  final Map<String, DayActivity> activity;

  Interests get interests => Interests(
        categories: interestCategories,
        scenes: interestScenes,
        keywords: interestKeywords,
      );

  bool get onboarded => ageBand != null;

  AppSettings copyWith({
    AgeBand? ageBand,
    String? uiLanguage,
    bool clearUiLanguage = false,
    String? contentLanguage,
    bool clearContentLanguage = false,
    Set<String>? categories,
    Set<String>? scenes,
    List<String>? saved,
    Map<String, Set<Rating>>? ratings,
    Map<String, Knowledge>? knowledge,
    List<String>? readDays,
    bool? notifyEnabled,
    int? notifyHour,
    int? notifyMinute,
    Set<String>? interestCategories,
    Set<String>? interestScenes,
    List<String>? interestKeywords,
    String? regionMode,
    String? seasonMode,
    Map<String, ReviewEntry>? reviews,
    int? quizAnswered,
    int? quizCorrect,
    Map<String, String>? dailyResults,
    Set<String>? seen,
    int? celebratedStage,
    Set<String>? celebratedBadges,
    String? capsule,
    Set<String>? words,
    LeagueData? league,
    Map<String, DayActivity>? activity,
  }) =>
      AppSettings(
        ageBand: ageBand ?? this.ageBand,
        uiLanguage: clearUiLanguage ? null : (uiLanguage ?? this.uiLanguage),
        contentLanguage:
            clearContentLanguage ? null : (contentLanguage ?? this.contentLanguage),
        categories: categories ?? this.categories,
        scenes: scenes ?? this.scenes,
        saved: saved ?? this.saved,
        ratings: ratings ?? this.ratings,
        knowledge: knowledge ?? this.knowledge,
        readDays: readDays ?? this.readDays,
        notifyEnabled: notifyEnabled ?? this.notifyEnabled,
        notifyHour: notifyHour ?? this.notifyHour,
        notifyMinute: notifyMinute ?? this.notifyMinute,
        interestCategories: interestCategories ?? this.interestCategories,
        interestScenes: interestScenes ?? this.interestScenes,
        interestKeywords: interestKeywords ?? this.interestKeywords,
        regionMode: regionMode ?? this.regionMode,
        seasonMode: seasonMode ?? this.seasonMode,
        reviews: reviews ?? this.reviews,
        quizAnswered: quizAnswered ?? this.quizAnswered,
        quizCorrect: quizCorrect ?? this.quizCorrect,
        dailyResults: dailyResults ?? this.dailyResults,
        seen: seen ?? this.seen,
        celebratedStage: celebratedStage ?? this.celebratedStage,
        celebratedBadges: celebratedBadges ?? this.celebratedBadges,
        capsule: capsule ?? this.capsule,
        words: words ?? this.words,
        league: league ?? this.league,
        activity: activity ?? this.activity,
      );
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._prefs, {DateTime Function()? now})
      : _now = now ?? DateTime.now,
        super(_read(_prefs));

  final SharedPreferences _prefs;

  /// 「いま」。テストでは差し替える。
  final DateTime Function() _now;

  /// 今日の記録に [f] を加える（週のふりかえり用）。
  void _bump(DayActivity Function(DayActivity) f) {
    final today = _now();
    final key = dayKey(today);
    final map = {...state.activity};
    map[key] = f(map[key] ?? const DayActivity());
    final keys = map.keys.toList()..sort();
    if (keys.length > activityKeepDays) {
      for (final k in keys.take(keys.length - activityKeepDays)) {
        map.remove(k);
      }
    }
    state = state.copyWith(activity: map);
    _prefs.setStringList('activity', [for (final e in map.entries) e.value.encode(e.key)]);
  }

  /// 端末に保存した設定・保存・記録をすべて消して、初期状態に戻す。
  Future<void> resetAll() async {
    await _prefs.clear();
    state = _read(_prefs);
  }

  static LeagueData _readLeague(SharedPreferences p) {
    final scores = <String, LeagueEntry>{};
    for (final raw in p.getStringList('leagueScores') ?? const <String>[]) {
      final f = raw.split('|');
      if (f.length != 4) continue;
      final pts = int.tryParse(f[1]);
      final games = int.tryParse(f[2]);
      final wins = int.tryParse(f[3]);
      if (pts == null || games == null || wins == null) continue;
      scores[f[0]] = LeagueEntry(points: pts, games: games, wins: wins);
    }
    return LeagueData(
      week: p.getString('leagueWeek'),
      scores: scores,
      lastWinner: p.getString('leagueLastWinner'),
      lastPoints: p.getInt('leagueLastPoints') ?? 0,
    );
  }

  void _saveLeague(LeagueData d) {
    if (d.week != null) {
      _prefs.setString('leagueWeek', d.week!);
    } else {
      _prefs.remove('leagueWeek');
    }
    _prefs.setStringList('leagueScores', [
      for (final e in d.scores.entries)
        '${e.key.replaceAll('|', ' ')}|${e.value.points}|${e.value.games}|${e.value.wins}',
    ]);
    if (d.lastWinner != null) {
      _prefs.setString('leagueLastWinner', d.lastWinner!);
    } else {
      _prefs.remove('leagueLastWinner');
    }
    _prefs.setInt('leagueLastPoints', d.lastPoints);
  }

  static AppSettings _read(SharedPreferences p) {
    final ratings = <String, Set<Rating>>{};
    final raw = p.getString('ratings');
    if (raw != null) {
      try {
        (jsonDecode(raw) as Map<String, dynamic>).forEach((id, list) {
          ratings[id] = {
            for (final n in list as List)
              ...Rating.values.where((r) => r.name == n),
          };
        });
      } catch (_) {}
    }
    return AppSettings(
      ageBand: AgeBand.parse(p.getString('ageBand')),
      uiLanguage: p.getString('uiLanguage'),
      contentLanguage: p.getString('contentLanguage'),
      categories: (p.getStringList('categories') ?? const []).toSet(),
      scenes: (p.getStringList('scenes') ?? const []).toSet(),
      saved: p.getStringList('saved') ?? const [],
      ratings: ratings,
      knowledge: {
        for (final e in (p.getStringList('knowledge') ?? const []))
          if (e.split(':') case [final id, final k])
            for (final v in Knowledge.values)
              if (v.name == k) id: v,
      },
      readDays: p.getStringList('readDays') ?? const [],
      notifyEnabled: p.getBool('notifyEnabled') ?? false,
      notifyHour: p.getInt('notifyHour') ?? 7,
      notifyMinute: p.getInt('notifyMinute') ?? 0,
      interestCategories: (p.getStringList('interestCategories') ?? const []).toSet(),
      interestScenes: (p.getStringList('interestScenes') ?? const []).toSet(),
      interestKeywords: p.getStringList('interestKeywords') ?? const [],
      regionMode: p.getString('regionMode') ?? 'auto',
      seasonMode: p.getString('seasonMode') ?? 'auto',
      reviews: {
        for (final raw in (p.getStringList('reviews') ?? const []))
          if (ReviewEntry.decode(raw) case (final id, final e)?) id: e,
      },
      quizAnswered: p.getInt('quizAnswered') ?? 0,
      quizCorrect: p.getInt('quizCorrect') ?? 0,
      seen: (p.getStringList('seen') ?? const []).toSet(),
      capsule: p.getString('capsule'),
      words: (p.getStringList('words') ?? const []).toSet(),
      league: _readLeague(p),
      activity: {
        for (final raw in (p.getStringList('activity') ?? const <String>[]))
          if (DayActivity.decode(raw) case (final day, final a)?) day: a,
      },
      celebratedStage: p.getInt('celebratedStage'),
      celebratedBadges: p.getStringList('celebratedBadges')?.toSet(),
      dailyResults: {
        for (final raw in (p.getStringList('dailyResults') ?? const []))
          if (raw.split(':') case [final day, final r]) day: r,
      },
    );
  }

  void setAgeBand(AgeBand band) {
    // 年代が変わったら、年代で使えない絞り込みを外す。
    // 子どもモードに切り替えたら通知はオフ（Junior では保護者が改めて設定する）。
    state = state.copyWith(
      ageBand: band,
      scenes: band.isTeenOrAdult ? state.scenes : const {},
      notifyEnabled: band.isChild ? false : state.notifyEnabled,
    );
    _prefs.setString('ageBand', band.name);
    _prefs.setStringList('scenes', state.scenes.toList());
    _prefs.setBool('notifyEnabled', state.notifyEnabled);
  }

  void setRegionMode(String mode) {
    state = state.copyWith(regionMode: mode);
    _prefs.setString('regionMode', mode);
  }

  void setSeasonMode(String mode) {
    state = state.copyWith(seasonMode: mode);
    _prefs.setString('seasonMode', mode);
  }

  void toggleInterestCategory(String category) {
    final next = {...state.interestCategories};
    next.contains(category) ? next.remove(category) : next.add(category);
    state = state.copyWith(interestCategories: next);
    _prefs.setStringList('interestCategories', next.toList());
  }

  void toggleInterestScene(String scene) {
    final next = {...state.interestScenes};
    next.contains(scene) ? next.remove(scene) : next.add(scene);
    state = state.copyWith(interestScenes: next);
    _prefs.setStringList('interestScenes', next.toList());
  }

  /// キーワードを追加する。空・長すぎる・重複・上限超えは追加せず false を返す。
  bool addInterestKeyword(String keyword) {
    final k = keyword.trim();
    if (k.isEmpty || k.length > maxInterestKeywordLength) return false;
    if (state.interestKeywords.length >= maxInterestKeywords) return false;
    final folded = foldText(k);
    if (state.interestKeywords.any((e) => foldText(e) == folded)) return false;
    final next = [...state.interestKeywords, k];
    state = state.copyWith(interestKeywords: next);
    _prefs.setStringList('interestKeywords', next);
    return true;
  }

  void removeInterestKeyword(String keyword) {
    final next = [...state.interestKeywords]..remove(keyword);
    state = state.copyWith(interestKeywords: next);
    _prefs.setStringList('interestKeywords', next);
  }

  void setNotifyEnabled(bool enabled) {
    state = state.copyWith(notifyEnabled: enabled);
    _prefs.setBool('notifyEnabled', enabled);
  }

  void setNotifyTime(int hour, int minute) {
    state = state.copyWith(notifyHour: hour, notifyMinute: minute);
    _prefs.setInt('notifyHour', hour);
    _prefs.setInt('notifyMinute', minute);
  }

  void setUiLanguage(String? code) {
    state = code == null
        ? state.copyWith(clearUiLanguage: true)
        : state.copyWith(uiLanguage: code);
    code == null ? _prefs.remove('uiLanguage') : _prefs.setString('uiLanguage', code);
  }

  void setContentLanguage(String? code) {
    state = code == null
        ? state.copyWith(clearContentLanguage: true)
        : state.copyWith(contentLanguage: code);
    code == null
        ? _prefs.remove('contentLanguage')
        : _prefs.setString('contentLanguage', code);
  }

  void toggleCategory(String category) {
    final next = {...state.categories};
    next.contains(category) ? next.remove(category) : next.add(category);
    state = state.copyWith(categories: next);
    _prefs.setStringList('categories', next.toList());
  }

  void toggleScene(String scene) {
    final next = {...state.scenes};
    next.contains(scene) ? next.remove(scene) : next.add(scene);
    state = state.copyWith(scenes: next);
    _prefs.setStringList('scenes', next.toList());
  }

  void clearFilters() {
    state = state.copyWith(categories: const {}, scenes: const {});
    _prefs.setStringList('categories', const []);
    _prefs.setStringList('scenes', const []);
  }

  /// 保存/解除。無料プランの上限を超える保存は false を返す。
  bool toggleSaved(String id, {required bool isPremium}) {
    final list = [...state.saved];
    if (list.remove(id)) {
      state = state.copyWith(saved: list);
      _prefs.setStringList('saved', list);
      return true;
    }
    if (!isPremium && list.length >= freeSaveLimit) return false;
    list.insert(0, id);
    state = state.copyWith(saved: list);
    _prefs.setStringList('saved', list);
    return true;
  }

  /// 「知ってた／知らなかった」。「知らなかった」は、明日からの復習の予定に入る。
  void setKnowledge(String id, Knowledge value, {DateTime? today}) {
    final map = {...state.knowledge};
    map[id] == value ? map.remove(id) : map[id] = value;
    final reviews = {...state.reviews};
    if (map[id] == Knowledge.learned) {
      reviews.putIfAbsent(id, () => firstReview(today ?? DateTime.now()));
    } else {
      reviews.remove(id);
    }
    final becameLearned = map[id] == Knowledge.learned;
    state = state.copyWith(knowledge: map, reviews: reviews);
    if (becameLearned) _bump((a) => a.copyWith(learned: a.learned + 1));
    _prefs.setStringList(
        'knowledge', [for (final e in map.entries) '${e.key}:${e.value.name}']);
    _saveReviews(reviews);
  }

  void _saveReviews(Map<String, ReviewEntry> reviews) => _prefs.setStringList(
      'reviews', [for (final e in reviews.entries) e.value.encode(e.key)]);

  /// 復習の結果を記録する（予定を進める／戻す）。
  void recordReview(String id, {required bool correct, required DateTime today}) {
    final entry = state.reviews[id];
    if (entry == null) return;
    final reviews = {...state.reviews};
    final next = afterReview(entry, correct: correct, today: today);
    next == null ? reviews.remove(id) : reviews[id] = next;
    state = state.copyWith(reviews: reviews);
    _saveReviews(reviews);
  }

  /// 雑学を開いたことを記録する（相棒の成長用）。初めて開いたときだけ状態が変わる。
  void markSeen(String id) {
    if (state.seen.contains(id)) return;
    final seen = {...state.seen, id};
    state = state.copyWith(seen: seen);
    _prefs.setStringList('seen', seen.toList());
    _bump((a) => a.copyWith(seen: a.seen + 1));
  }

  /// 対戦（2人以上）の結果を、家族リーグに加える。
  void recordLeagueGame(DateTime today,
      {required List<String> names, required List<int> scores, required List<int> winners}) {
    final next = addGame(state.league, today,
        names: [for (final n in names) n.replaceAll('|', ' ')],
        scores: scores,
        winners: winners);
    state = state.copyWith(league: next);
    _saveLeague(next);
  }

  /// 今週のリーグの記録を消す（先週の優勝者は残す）。
  void clearLeagueWeek(DateTime today) {
    final base = rollWeek(state.league, today);
    final next = LeagueData(
        week: base.week, lastWinner: base.lastWinner, lastPoints: base.lastPoints);
    state = state.copyWith(league: next);
    _saveLeague(next);
  }

  /// 用語の説明を見たことを記録する（ことばずかん用）。
  void markWordSeen(String id) {
    if (state.words.contains(id)) return;
    final words = {...state.words, id};
    state = state.copyWith(words: words);
    _prefs.setStringList('words', words.toList());
  }

  /// 今日のカプセルで出た雑学を記録する（見た雑学にもなる）。
  void recordCapsule(DateTime today, String id) {
    final value = '${dayKey(today)}:$id';
    state = state.copyWith(capsule: value);
    _prefs.setString('capsule', value);
    markSeen(id);
  }

  /// 相棒の段階のお祝いを出し終えた（または、最初の基準にした）ことを記録する。
  void ackStage(int index) {
    state = state.copyWith(celebratedStage: index);
    _prefs.setInt('celebratedStage', index);
  }

  /// バッジのお祝いを出し終えた（または、最初の基準にした）ことを記録する。
  void ackBadges(Iterable<String> ids) {
    final set = {...?state.celebratedBadges, ...ids};
    state = state.copyWith(celebratedBadges: set);
    _prefs.setStringList('celebratedBadges', set.toList());
  }

  /// 1人用クイズの回答を通算に加える。
  void recordQuizAnswer({required bool correct}) {
    final answered = state.quizAnswered + 1;
    final right = state.quizCorrect + (correct ? 1 : 0);
    state = state.copyWith(quizAnswered: answered, quizCorrect: right);
    _prefs.setInt('quizAnswered', answered);
    _prefs.setInt('quizCorrect', right);
    _bump((a) => a.copyWith(answered: a.answered + 1, correct: a.correct + (correct ? 1 : 0)));
  }

  /// 今日のチャレンジの結果（正誤を "101" のように並べた文字列）を記録する。
  void recordDaily(DateTime today, String result) {
    final key = dayKey(today);
    if (state.dailyResults.containsKey(key)) return;
    final map = {...state.dailyResults, key: result};
    // 保存は直近400日だけ。
    final keys = map.keys.toList()..sort();
    for (final k in keys.take(keys.length > 400 ? keys.length - 400 : 0)) {
      map.remove(k);
    }
    state = state.copyWith(dailyResults: map);
    _prefs.setStringList('dailyResults', [for (final e in map.entries) '${e.key}:${e.value}']);
  }

  /// 今日、雑学を読んだことを記録する（Teen/Adult のストリーク用）。
  void markRead(DateTime today) {
    final key = dayKey(today);
    if (state.readDays.contains(key)) return;
    final days = [...state.readDays, key]..sort();
    // 保存は直近400日だけ。
    final trimmed = days.length > 400 ? days.sublist(days.length - 400) : days;
    state = state.copyWith(readDays: trimmed);
    _prefs.setStringList('readDays', trimmed);
  }

  void toggleRating(String id, Rating rating) {
    final map = {...state.ratings};
    final set = {...(map[id] ?? const <Rating>{})};
    set.contains(rating) ? set.remove(rating) : set.add(rating);
    set.isEmpty ? map.remove(id) : map[id] = set;
    state = state.copyWith(ratings: map);
    _prefs.setString(
      'ratings',
      jsonEncode({
        for (final e in map.entries) e.key: e.value.map((r) => r.name).toList(),
      }),
    );
  }
}

final sharedPreferencesProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(ref.watch(sharedPreferencesProvider), now: () => ref.read(nowProvider)),
);

/// 端末の言語。テストで差し替える。
final deviceLanguageProvider =
    Provider<String>((ref) => PlatformDispatcher.instance.locale.languageCode);

/// 端末の地域（ja_JP の JP）。分からないときは null。
final deviceRegionProvider =
    Provider<String?>((ref) => PlatformDispatcher.instance.locale.countryCode);

final uiLanguageProvider = Provider<String>((ref) =>
    resolveLanguage(ref.watch(settingsProvider).uiLanguage ?? ref.watch(deviceLanguageProvider)));

final contentLanguageProvider = Provider<String>((ref) => resolveContentLanguage(
    ref.watch(settingsProvider).contentLanguage ?? ref.watch(uiLanguageProvider)));
