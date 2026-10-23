import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import '../data/trivia_repository.dart';
import '../logic/daily_pick.dart';
import '../logic/interests.dart';
import '../logic/search.dart';
import '../logic/timing.dart';
import '../models/age_band.dart';
import '../models/calendar_event.dart';
import '../models/myth.dart';
import '../models/project.dart';
import '../models/trivia.dart';
import '../services/entitlement.dart';
import 'settings.dart';

final triviaRepositoryProvider =
    Provider<TriviaRepository>((ref) => throw UnimplementedError());

/// 「今日」の基準。テストで差し替える。
final nowProvider = Provider<DateTime>((ref) => DateTime.now());

final isPremiumNowProvider =
    Provider<bool>((ref) => ref.watch(isPremiumProvider).valueOrNull ?? false);

/// 端末のタイムゾーン名（Asia/Tokyo など）。取れなければ null。
final timezoneIdProvider = FutureProvider<String?>((ref) async {
  try {
    return (await FlutterTimezone.getLocalTimezone()).identifier;
  } catch (_) {
    return null;
  }
});

/// 国限定の雑学の判定に使う国。`any` が true のときは、国の制限を使わない（すべての国）。
final regionProvider = Provider<({String? code, bool any})>((ref) {
  final mode = ref.watch(settingsProvider.select((s) => s.regionMode));
  if (mode == 'all') return (code: null, any: true);
  if (mode != 'auto') return (code: mode, any: false);
  final device = ref.watch(deviceRegionProvider);
  if (device != null && device.isNotEmpty) return (code: device.toUpperCase(), any: false);
  // 端末に地域がないときは、日本語の端末を日本とみなす。
  return (code: ref.watch(deviceLanguageProvider) == 'ja' ? 'JP' : null, any: false);
});

/// 南半球の主な国。国を選んだときの半球の推定に使う。
const _southernRegions = {'AU', 'NZ', 'BR', 'AR', 'CL', 'ZA', 'PE', 'UY', 'PY', 'BO'};

/// 季節に使う半球。null は「季節を使わない」。
final hemisphereProvider = Provider<Hemisphere?>((ref) {
  final settings = ref.watch(settingsProvider);
  switch (settings.seasonMode) {
    case 'off':
      return null;
    case 'north':
      return Hemisphere.north;
    case 'south':
      return Hemisphere.south;
  }
  if (_southernRegions.contains(settings.regionMode)) return Hemisphere.south;
  return hemisphereFromTimezone(ref.watch(timezoneIdProvider).valueOrNull);
});

/// 「今日の雑学」を選ぶ関数。季節外れを避け、記念日の当日はその雑学にする。
/// フィード・通知・鍵の判定のすべてで同じものを使う（同じ日に同じ雑学になるように）。
final dayPickerProvider = Provider<DayPicker>((ref) {
  final hemisphere = ref.watch(hemisphereProvider);
  return (pool, day) => pickTodayFact(
        pool,
        day,
        season: hemisphere == null ? null : seasonFor(day, hemisphere),
      );
});

final feedFilterProvider = Provider<FeedFilter>((ref) {
  final s = ref.watch(settingsProvider);
  return FeedFilter(categories: s.categories, scenes: s.scenes);
});

/// 現在の年代・言語・絞り込みで配信できる雑学。
/// Kids は一覧がなく1枚ずつ見るので、登録した「すきなもの」（ジャンル）で絞る。
final poolProvider = Provider<List<Trivia>>((ref) {
  final band = ref.watch(settingsProvider.select((s) => s.ageBand));
  if (band == null) return const [];
  final filter = band == AgeBand.kids
      ? FeedFilter(categories: ref.watch(settingsProvider.select((s) => s.interestCategories)))
      : ref.watch(feedFilterProvider);
  final region = ref.watch(regionProvider);
  return ref.watch(triviaRepositoryProvider).eligible(
        band,
        ref.watch(contentLanguageProvider),
        filter: filter,
        region: region.code,
        anyRegion: region.any,
      );
});

/// 絞り込みなしで、この年代・言語で配信できる雑学すべて（検索・ライブラリ・関心事の候補）。
final allEligibleProvider = Provider<List<Trivia>>((ref) {
  final band = ref.watch(settingsProvider.select((s) => s.ageBand));
  if (band == null) return const [];
  final region = ref.watch(regionProvider);
  return ref.watch(triviaRepositoryProvider).eligible(
        band,
        ref.watch(contentLanguageProvider),
        region: region.code,
        anyRegion: region.any,
      );
});

/// 検索用の索引。タイトル・本文を日本語と英語の両方連結して、そろえた文字で持つ（どちらの言語でも探せる）。
/// カテゴリーのキー名（animals など）も含める。
final searchIndexProvider = Provider<Map<String, SearchEntry>>((ref) {
  final band = ref.watch(settingsProvider.select((s) => s.ageBand));
  if (band == null) return const {};
  final out = <String, SearchEntry>{};
  for (final t in ref.watch(triviaRepositoryProvider).items) {
    final titles = StringBuffer('${t.category} ${t.keywords.join(' ')}');
    final bodies = StringBuffer();
    for (final lang in ['ja', 'en']) {
      final level = t.levelFor(band, lang, allowDraft: kAllowDraftContent);
      if (level == null) continue;
      titles.write(' ${level.title}');
      bodies.write(' ${level.body}');
    }
    out[t.id] = SearchEntry(
      title: foldText(titles.toString()),
      body: foldText(bodies.toString()),
    );
  }
  return out;
});

/// 「いまのおすすめ」。季節・時間帯・記念日・週末に合う雑学を、理由つきで出す。無料は1件、プレミアムは3件。
/// Kids には出さない（1枚ずつ見る画面のため）。今日の雑学とは重複させない。
final timingPicksProvider = Provider<List<TimingPick>>((ref) {
  final band = ref.watch(settingsProvider.select((s) => s.ageBand));
  if (band == null || band == AgeBand.kids) return const [];
  final hemisphere = ref.watch(hemisphereProvider);
  final now = ref.watch(nowProvider);
  final today = ref.watch(feedProvider).firstOrNull;
  return pickTiming(
    pool: ref.watch(allEligibleProvider),
    ctx: TimingContext(
      now: now,
      season: hemisphere == null ? null : seasonFor(now, hemisphere),
    ),
    exclude: {if (today != null) today.id},
    count: ref.watch(isPremiumNowProvider) ? 3 : 1,
  );
});

/// 「あなたの関心」に出す雑学。無料は2件、プレミアムは5件。今日の雑学・いまのおすすめとは重複させない。
final interestPicksProvider = Provider<List<Trivia>>((ref) {
  final settings = ref.watch(settingsProvider);
  final band = settings.ageBand;
  if (band == null || band == AgeBand.kids) return const [];
  final today = ref.watch(feedProvider).firstOrNull;
  final timing = ref.watch(timingPicksProvider);
  return pickInterests(
    pool: ref.watch(allEligibleProvider),
    interests: settings.interests,
    index: ref.watch(searchIndexProvider),
    day: ref.watch(nowProvider),
    exclude: {if (today != null) today.id, for (final p in timing) p.fact.id},
    count: ref.watch(isPremiumNowProvider) ? 5 : 2,
  );
});

/// 開いてよい雑学のID。null は「すべて」（Kids/Junior とプレミアム）。
/// 無料の Teen/Adult は、日替わりの無料の日数ぶん・今日の関心のおすすめ・保存した雑学だけ。
final unlockedIdsProvider = Provider<Set<String>?>((ref) {
  final band = ref.watch(settingsProvider.select((s) => s.ageBand));
  if (band == null || band.isChild || ref.watch(isPremiumNowProvider)) return null;
  final pool = ref.watch(allEligibleProvider);
  return {
    for (final t in feedFor(pool, ref.watch(nowProvider), freeFeedDays,
        picker: ref.watch(dayPickerProvider)))
      t.id,
    for (final t in ref.watch(interestPicksProvider)) t.id,
    for (final p in ref.watch(timingPicksProvider)) p.fact.id,
    ...ref.watch(settingsProvider.select((s) => s.saved)),
  };
});

/// 読める日数。Kids/Junior は全て無料、Teen/Adult は無料7日・プレミアム30日。
final feedDaysProvider = Provider<int>((ref) {
  final band = ref.watch(settingsProvider.select((s) => s.ageBand));
  if (band == null) return freeFeedDays;
  if (band.isChild) return premiumFeedDays;
  return ref.watch(isPremiumNowProvider) ? premiumFeedDays : freeFeedDays;
});

final feedProvider = Provider<List<Trivia>>((ref) => feedFor(
      ref.watch(poolProvider),
      ref.watch(nowProvider),
      ref.watch(feedDaysProvider),
      picker: ref.watch(dayPickerProvider),
    ));

/// 画面に出す本文（年代・言語に合わせたもの）。
final levelResolverProvider = Provider<TriviaLevel? Function(Trivia)>((ref) {
  final band = ref.watch(settingsProvider.select((s) => s.ageBand)) ?? AgeBand.adult;
  final lang = ref.watch(contentLanguageProvider);
  return (t) => t.levelFor(band, lang, allowDraft: kAllowDraftContent);
});

/// 「なぜ？」チェーンの次の一歩（次の雑学と質問文）。
class WhyStep {
  const WhyStep({required this.target, required this.question});
  final Trivia target;
  final String question;
}

/// ある雑学から「なぜ？」でつながる次の一歩。次の雑学が、この年代・言語・国で表示できないときは null。
final whyStepProvider = Provider.family<WhyStep?, String>((ref, factId) {
  final band = ref.watch(settingsProvider.select((s) => s.ageBand));
  if (band == null) return null;
  final repo = ref.watch(triviaRepositoryProvider);
  final link = repo.whyFrom(factId);
  if (link == null) return null;
  final target = repo.byId(link.to);
  if (target == null) return null;
  if (!ref.watch(allEligibleProvider).any((t) => t.id == target.id)) return null;
  final question = link.question(band, ref.watch(contentLanguageProvider));
  return question == null ? null : WhyStep(target: target, question: question);
});

/// 「ほんと？うそ？」の問題。この年代・言語・国で遊べるものを、日替わりの順に並べる（毎日違う順番）。
final mythDeckProvider = Provider<List<Myth>>((ref) {
  final band = ref.watch(settingsProvider.select((s) => s.ageBand));
  if (band == null) return const [];
  final region = ref.watch(regionProvider);
  final deck = ref.watch(triviaRepositoryProvider).eligibleMyths(
        band,
        ref.watch(contentLanguageProvider),
        region: region.code,
        anyRegion: region.any,
      );
  final seed = fnv1a('myth-${dayNumber(ref.watch(nowProvider))}');
  deck.sort((a, b) {
    final c = mix32(fnv1a(a.id) ^ seed).compareTo(mix32(fnv1a(b.id) ^ seed));
    return c != 0 ? c : a.id.compareTo(b.id);
  });
  return deck;
});

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// その日の記念日。カレンダーの記念日と、記念日つきの雑学（`dates` の当日）をまとめる。
/// 同じ雑学につながるカレンダーの記念日があれば、雑学の側は重ねて出さない。
final dayEventsProvider = Provider.family<List<DayEvent>, DateTime>((ref, day) {
  final band = ref.watch(settingsProvider.select((s) => s.ageBand));
  if (band == null) return const [];
  final lang = ref.watch(contentLanguageProvider);
  final region = ref.watch(regionProvider);
  final repo = ref.watch(triviaRepositoryProvider);
  final out = <DayEvent>[];
  final linkedFacts = <String>{};
  for (final e in repo.eligibleEvents(band, lang, region: region.code, anyRegion: region.any)) {
    if (!e.occursOn(day)) continue;
    final text = e.textFor(band, lang, allowDraft: kAllowDraftContent)!;
    out.add(DayEvent(
      id: e.id,
      date: day,
      title: text.title,
      body: text.body,
      factId: e.factId,
      isCountrySpecific: e.regions.isNotEmpty,
    ));
    if (e.factId != null) linkedFacts.add(e.factId!);
  }
  for (final t in ref.watch(allEligibleProvider)) {
    if (linkedFacts.contains(t.id)) continue;
    if (dateOffset(t.dates, day, window: 0) != 0) continue;
    final level = t.levelFor(band, lang, allowDraft: kAllowDraftContent);
    if (level == null) continue;
    out.add(DayEvent(
      id: 'fact:${t.id}',
      date: day,
      title: level.title,
      body: level.body,
      factId: t.id,
      isCountrySpecific: t.regions.isNotEmpty,
    ));
  }
  return out;
});

/// 今日の記念日。
final todayEventsProvider =
    Provider<List<DayEvent>>((ref) => ref.watch(dayEventsProvider(dateOnly(ref.watch(nowProvider)))));

/// これから14日以内の記念日（今日は含まない）。日付の近い順。
final upcomingEventsProvider = Provider<List<DayEvent>>((ref) {
  final today = dateOnly(ref.watch(nowProvider));
  return [
    for (var i = 1; i <= 14; i++)
      ...ref.watch(dayEventsProvider(DateTime(today.year, today.month, today.day + i))),
  ];
});

/// 自由研究のテーマ。この年代・言語・国で表示できるもの。
final projectsProvider = Provider<List<Project>>((ref) {
  final band = ref.watch(settingsProvider.select((s) => s.ageBand));
  if (band == null) return const [];
  final region = ref.watch(regionProvider);
  return ref.watch(triviaRepositoryProvider).eligibleProjects(
        band,
        ref.watch(contentLanguageProvider),
        region: region.code,
        anyRegion: region.any,
      );
});

/// ある雑学につながる自由研究（なければ null）。
final projectForFactProvider = Provider.family<Project?, String>((ref, factId) {
  for (final p in ref.watch(projectsProvider)) {
    if (p.factId == factId) return p;
  }
  return null;
});
