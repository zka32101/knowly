import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../logic/badges.dart';
import '../logic/mascot.dart';
import '../logic/streak.dart';
import '../models/age_band.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/mascot_card.dart';
import 'badges_screen.dart';
import 'solo_quiz_screens.dart';

/// ハブ（あそぶ・あつめる・さがす）に並べる大きなカード。
class HubTile extends StatelessWidget {
  const HubTile({
    super.key,
    required this.emoji,
    required this.title,
    this.subtitle,
    this.badge,
    required this.route,
  });

  final String emoji;
  final String title;
  final String? subtitle;

  /// 右上に出す小さな印（件数・✓ など）。
  final String? badge;
  final String route;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push(route),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 120),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 40)),
                    if (badge != null)
                      Positioned(
                        right: -14,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(badge!,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimary)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                if (subtitle != null)
                  Text(subtitle!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ハブの共通の枠: 見出し・説明と、2列に並ぶカード。
class _Hub extends StatelessWidget {
  const _Hub({required this.title, this.intro, required this.tiles});
  final String title;
  final String? intro;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 32 - 8) / 2;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (intro != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(intro!, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final t in tiles) SizedBox(width: width, child: t)],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// あそぶ: クイズ・スワイプ・今日のチャレンジ・おさらい・ほんと？うそ？
class PlayHub extends ConsumerWidget {
  const PlayHub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final band = ref.watch(settingsProvider.select((s) => s.ageBand)) ?? AgeBand.adult;
    final due = ref.watch(reviewQuestionsProvider).length;
    final today = ref.watch(nowProvider);
    final wordsOn = ref.watch(wordsEnabledProvider);
    final doneToday =
        ref.watch(settingsProvider.select((s) => s.dailyResults)).containsKey(dayKey(today));
    return _Hub(
      title: l.tabPlay,
      intro: l.hubPlayIntro,
      tiles: [
        HubTile(
            key: const Key('open_quiz'),
            emoji: '🎮',
            title: l.battleTitle,
            subtitle: l.hubQuizSub,
            route: '/quiz'),
        HubTile(
            key: const Key('open_league'),
            emoji: '🏆',
            title: l.leagueTitle,
            subtitle: l.leagueSub,
            route: '/league'),
        HubTile(
            key: const Key('open_swipe'),
            emoji: '👆',
            title: l.swipeChip,
            subtitle: l.hubSwipeSub,
            route: '/swipe'),
        HubTile(
            key: const Key('open_voicequiz'),
            emoji: '👂',
            title: l.voiceQuizTitle,
            subtitle: l.voiceQuizSub,
            route: '/voicequiz'),
        HubTile(
            key: const Key('open_daily'),
            emoji: '🚩',
            title: l.dailyChip,
            subtitle: l.hubDailySub,
            badge: doneToday ? '✓' : null,
            route: '/daily'),
        if (wordsOn)
          HubTile(
              key: const Key('open_wordquiz'),
              emoji: '💡',
              title: l.wordQuizTitle,
              route: '/wordquiz'),
        if (due > 0)
          HubTile(
              key: const Key('open_review'),
              emoji: '🔁',
              title: l.reviewChip,
              subtitle: l.hubReviewSub,
              badge: '$due',
              route: '/review'),
        HubTile(
            key: const Key('open_myths'),
            emoji: '🤔',
            title: l.mythsTitle,
            subtitle: l.hubMythsSub,
            route: '/myths'),
        if (band == AgeBand.kids)
          HubTile(
              key: const Key('open_today'),
              emoji: '📅',
              title: l.todayHome,
              route: '/today'),
      ],
    );
  }
}

/// あつめる: 相棒・ずかん・カプセル・バッジ
class CollectHub extends ConsumerWidget {
  const CollectHub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final band = ref.watch(settingsProvider.select((s) => s.ageBand)) ?? AgeBand.adult;
    final all = ref.watch(allEligibleProvider);
    final seen = ref.watch(settingsProvider.select((s) => s.seen));
    final found = all.where((t) => seen.contains(t.id)).length;
    final stats = ref.watch(badgeStatsProvider);
    final defs = badgesFor(band);
    final earned = defs.where((b) => isEarned(b, stats)).length;
    final stage = mascotStageFor(ref.watch(mascotPointsProvider));
    final capsule = ref.watch(settingsProvider.select((s) => s.capsule));
    final wordsOn = ref.watch(wordsEnabledProvider);
    final wordsFound = ref.watch(settingsProvider.select((s) => s.words)).length;
    final wordsTotal = ref.watch(glossaryListProvider).length;
    final openedToday = capsule != null && capsule.startsWith('${dayKey(ref.watch(nowProvider))}:');
    return _Hub(
      title: l.tabCollect,
      intro: l.hubCollectIntro,
      tiles: [
        HubTile(
            key: const Key('open_mascot'),
            emoji: stage.emoji,
            title: l.mascotTitle,
            subtitle: mascotName(l, stage.id),
            route: '/mascot'),
        HubTile(
            key: const Key('open_zukan'),
            emoji: '📖',
            title: l.zukanChip,
            subtitle: '$found / ${all.length}',
            route: '/zukan'),
        HubTile(
            key: const Key('open_capsule'),
            emoji: '🎁',
            title: l.capsuleChip,
            subtitle: openedToday ? l.capsuleDone : l.capsuleOpen,
            badge: openedToday ? null : '!',
            route: '/capsule'),
        HubTile(
            key: const Key('open_map'),
            emoji: '🕸️',
            title: l.mapTitle,
            route: '/map'),
        if (wordsOn)
          HubTile(
              key: const Key('open_words'),
              emoji: '📚',
              title: l.wordsTitle,
              subtitle: '$wordsFound / $wordsTotal',
              route: '/words'),
        HubTile(
            key: const Key('open_recap'),
            emoji: '📊',
            title: l.recapChip,
            route: '/recap'),
        HubTile(
            key: const Key('open_badges'),
            emoji: '🏅',
            title: l.badgesChip,
            subtitle: '$earned / ${defs.length}',
            route: '/badges'),
      ],
    );
  }
}

/// さがす: ライブラリ・保存・関心事・今日は何の日・ながら聞き・自由研究
class ExploreHub extends ConsumerWidget {
  const ExploreHub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final band = ref.watch(settingsProvider.select((s) => s.ageBand)) ?? AgeBand.adult;
    final hasProjects = ref.watch(projectsProvider).isNotEmpty;
    return _Hub(
      title: l.tabExplore,
      intro: l.hubExploreIntro,
      tiles: [
        HubTile(
            key: const Key('open_library'),
            emoji: '🔍',
            title: l.libraryOpen,
            subtitle: l.hubLibrarySub,
            route: '/library'),
        HubTile(
            key: const Key('open_saved'),
            emoji: '🔖',
            title: l.savedTitle,
            route: '/saved'),
        HubTile(
            key: const Key('open_interests'),
            emoji: '💛',
            title: l.settingsInterests,
            route: '/interests'),
        HubTile(
            key: const Key('open_today'),
            emoji: '📅',
            title: l.todayHome,
            route: '/today'),
        if (band.isTeenOrAdult)
          HubTile(
              key: const Key('open_listen'),
              emoji: '🎧',
              title: l.listenOpen,
              subtitle: l.hubListenSub,
              route: '/listen'),
        if (hasProjects)
          HubTile(
              key: const Key('open_projects'),
              emoji: '🔬',
              title: l.projectsTitle,
              route: '/projects'),
      ],
    );
  }
}
