import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/trivia_repository.dart';
import '../logic/daily_pick.dart';
import '../logic/interests.dart';
import '../logic/search.dart';
import '../models/age_band.dart';
import '../models/trivia.dart';
import '../services/entitlement.dart';
import 'settings.dart';

final triviaRepositoryProvider =
    Provider<TriviaRepository>((ref) => throw UnimplementedError());

/// 「今日」の基準。テストで差し替える。
final nowProvider = Provider<DateTime>((ref) => DateTime.now());

final isPremiumNowProvider =
    Provider<bool>((ref) => ref.watch(isPremiumProvider).valueOrNull ?? false);

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
  return ref.watch(triviaRepositoryProvider).eligible(
        band,
        ref.watch(contentLanguageProvider),
        filter: filter,
      );
});

/// 絞り込みなしで、この年代・言語で配信できる雑学すべて（検索・ライブラリ・関心事の候補）。
final allEligibleProvider = Provider<List<Trivia>>((ref) {
  final band = ref.watch(settingsProvider.select((s) => s.ageBand));
  if (band == null) return const [];
  return ref
      .watch(triviaRepositoryProvider)
      .eligible(band, ref.watch(contentLanguageProvider));
});

/// 検索用の索引。タイトル・本文を日本語と英語の両方連結して、そろえた文字で持つ（どちらの言語でも探せる）。
/// カテゴリーのキー名（animals など）も含める。
final searchIndexProvider = Provider<Map<String, SearchEntry>>((ref) {
  final band = ref.watch(settingsProvider.select((s) => s.ageBand));
  if (band == null) return const {};
  final out = <String, SearchEntry>{};
  for (final t in ref.watch(triviaRepositoryProvider).items) {
    final titles = StringBuffer(t.category);
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

/// 「あなたの関心」に出す雑学。無料は2件、プレミアムは5件。今日の雑学とは重複させない。
final interestPicksProvider = Provider<List<Trivia>>((ref) {
  final settings = ref.watch(settingsProvider);
  final band = settings.ageBand;
  if (band == null || band == AgeBand.kids) return const [];
  final today = ref.watch(feedProvider).firstOrNull;
  return pickInterests(
    pool: ref.watch(allEligibleProvider),
    interests: settings.interests,
    index: ref.watch(searchIndexProvider),
    day: ref.watch(nowProvider),
    exclude: {if (today != null) today.id},
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
    for (final t in feedFor(pool, ref.watch(nowProvider), freeFeedDays)) t.id,
    for (final t in ref.watch(interestPicksProvider)) t.id,
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
    ));

/// 画面に出す本文（年代・言語に合わせたもの）。
final levelResolverProvider = Provider<TriviaLevel? Function(Trivia)>((ref) {
  final band = ref.watch(settingsProvider.select((s) => s.ageBand)) ?? AgeBand.adult;
  final lang = ref.watch(contentLanguageProvider);
  return (t) => t.levelFor(band, lang, allowDraft: kAllowDraftContent);
});
