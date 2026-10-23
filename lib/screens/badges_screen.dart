import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../logic/badges.dart';
import '../models/age_band.dart';
import '../state/settings.dart';

/// バッジの集計。子ども（Kids/Junior）には連続日数の記録がないので、そのバッジは出さない。
final badgeStatsProvider = Provider<BadgeStats>((ref) {
  final s = ref.watch(settingsProvider);
  return BadgeStats(
    streak: bestStreak(s.readDays),
    readDays: s.readDays.toSet().length,
    learned: s.knowledge.values.where((k) => k == Knowledge.learned).length,
    quizCorrect: s.quizCorrect,
    dailyDays: s.dailyResults.length,
    dailyPerfect: s.dailyResults.values.where((r) => !r.contains('0')).length,
  );
});

List<BadgeDef> badgesFor(AgeBand band) => [
      for (final b in badgeDefs)
        if (band.isTeenOrAdult ||
            (b.metric != BadgeMetric.streak && b.metric != BadgeMetric.readDays))
          b,
    ];

String badgeLabel(AppLocalizations l, BadgeDef b) => switch (b.metric) {
      BadgeMetric.streak => l.badgeStreak(b.target),
      BadgeMetric.readDays => l.badgeReadDays(b.target),
      BadgeMetric.learned => l.badgeLearned(b.target),
      BadgeMetric.quizCorrect => l.badgeQuiz(b.target),
      BadgeMetric.dailyDays => l.badgeDaily(b.target),
      BadgeMetric.dailyPerfect => l.badgePerfect,
    };

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final band = ref.watch(settingsProvider.select((s) => s.ageBand)) ?? AgeBand.adult;
    final stats = ref.watch(badgeStatsProvider);
    final defs = badgesFor(band);
    final earned = defs.where((b) => isEarned(b, stats)).length;
    return Scaffold(
      appBar: AppBar(title: Text(l.badgesTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.badgesCount(earned, defs.length),
                key: const Key('badges_count'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                for (final b in defs)
                  _BadgeCard(
                    key: Key('badge_${b.id}'),
                    def: b,
                    earned: isEarned(b, stats),
                    value: stats.valueOf(b.metric),
                    label: badgeLabel(l, b),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    super.key,
    required this.def,
    required this.earned,
    required this.value,
    required this.label,
  });

  final BadgeDef def;
  final bool earned;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Opacity(
            opacity: earned ? 1 : 0.25,
            child: Text(def.emoji, style: const TextStyle(fontSize: 44)),
          ),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium
                  ?.copyWith(fontWeight: earned ? FontWeight.bold : FontWeight.normal)),
          if (!earned)
            Text('${value.clamp(0, def.target)} / ${def.target}',
                style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
