import 'dart:convert';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../logic/interests.dart';
import '../logic/search.dart';
import '../logic/streak.dart';
import '../models/age_band.dart';

const supportedLanguageCodes = ['ja', 'en'];

/// 端末の言語から対応言語を選ぶ。対応外は英語。
String resolveLanguage(String? code) =>
    supportedLanguageCodes.contains(code) ? code! : 'en';

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
      );
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._prefs) : super(_read(_prefs));

  final SharedPreferences _prefs;

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

  void setKnowledge(String id, Knowledge value) {
    final map = {...state.knowledge};
    map[id] == value ? map.remove(id) : map[id] = value;
    state = state.copyWith(knowledge: map);
    _prefs.setStringList(
        'knowledge', [for (final e in map.entries) '${e.key}:${e.value.name}']);
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
  (ref) => SettingsNotifier(ref.watch(sharedPreferencesProvider)),
);

/// 端末の言語。テストで差し替える。
final deviceLanguageProvider =
    Provider<String>((ref) => PlatformDispatcher.instance.locale.languageCode);

/// 端末の地域（ja_JP の JP）。分からないときは null。
final deviceRegionProvider =
    Provider<String?>((ref) => PlatformDispatcher.instance.locale.countryCode);

final uiLanguageProvider = Provider<String>((ref) =>
    resolveLanguage(ref.watch(settingsProvider).uiLanguage ?? ref.watch(deviceLanguageProvider)));

final contentLanguageProvider = Provider<String>((ref) =>
    resolveLanguage(ref.watch(settingsProvider).contentLanguage ?? ref.watch(uiLanguageProvider)));
