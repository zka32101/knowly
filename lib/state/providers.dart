import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/trivia_repository.dart';
import '../logic/daily_pick.dart';
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
final poolProvider = Provider<List<Trivia>>((ref) {
  final band = ref.watch(settingsProvider.select((s) => s.ageBand));
  if (band == null) return const [];
  return ref.watch(triviaRepositoryProvider).eligible(
        band,
        ref.watch(contentLanguageProvider),
        filter: ref.watch(feedFilterProvider),
      );
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
