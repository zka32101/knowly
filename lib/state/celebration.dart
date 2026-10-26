import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/badges.dart';
import '../logic/mascot.dart';
import '../logic/stamps.dart';
import '../logic/timing.dart';
import '../screens/badges_screen.dart';
import 'providers.dart';
import 'settings.dart';

enum CelebrationKind { stage, badge, outfit }

class Celebration {
  const Celebration(this.kind, this.id, this.emoji);
  final CelebrationKind kind;

  /// 段階の id、またはバッジの id。
  final String id;
  final String emoji;
}

/// まだお祝いしていない、相棒の成長とバッジ。最初の起動では基準を決めるだけで、お祝いしない。
final pendingCelebrationsProvider = Provider<List<Celebration>>((ref) {
  final s = ref.watch(settingsProvider);
  final band = s.ageBand;
  if (band == null) return const [];
  final out = <Celebration>[];

  final stage = mascotStageFor(ref.watch(mascotPointsProvider));
  final stageIndex = mascotStages.indexOf(stage);
  final celebratedStage = s.celebratedStage;
  if (celebratedStage != null && stageIndex > celebratedStage) {
    out.add(Celebration(CelebrationKind.stage, stage.id, stage.emoji));
  }

  final stats = ref.watch(badgeStatsProvider);
  final celebratedBadges = s.celebratedBadges;
  if (celebratedBadges != null) {
    for (final b in badgesFor(band)) {
      if (isEarned(b, stats) && !celebratedBadges.contains(b.id)) {
        out.add(Celebration(CelebrationKind.badge, b.id, b.emoji));
      }
    }
  }

  final celebratedOutfits = s.celebratedOutfits;
  if (celebratedOutfits != null) {
    for (final book in completedBooks(s.stamps)) {
      if (!celebratedOutfits.contains(book)) {
        // 保存データに知らない季節があっても、アプリ全体を止めない。
        final season = Season.values.where((x) => book.endsWith('-${x.name}')).firstOrNull;
        if (season == null) continue;
        out.add(Celebration(CelebrationKind.outfit, book, seasonAccessory[season]!));
      }
    }
  }
  return out;
});

/// 基準が未設定のとき、いまの状態を基準にする（既存の記録を一度にお祝いしないため）。
void ensureCelebrationBaseline(WidgetRef ref) {
  final s = ref.read(settingsProvider);
  final band = s.ageBand;
  if (band == null) return;
  final notifier = ref.read(settingsProvider.notifier);
  if (s.celebratedStage == null) {
    notifier.ackStage(mascotStages.indexOf(mascotStageFor(ref.read(mascotPointsProvider))));
  }
  if (s.celebratedOutfits == null) {
    notifier.ackOutfits(completedBooks(s.stamps));
  }
  if (s.celebratedBadges == null) {
    final stats = ref.read(badgeStatsProvider);
    notifier.ackBadges([
      for (final b in badgesFor(band))
        if (isEarned(b, stats)) b.id,
    ]);
  }
}
