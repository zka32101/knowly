import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../logic/stamps.dart';
import '../logic/timing.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/illustration.dart';

String seasonName(AppLocalizations l, Season s) => switch (s) {
      Season.spring => l.stampsSpring,
      Season.summer => l.stampsSummer,
      Season.autumn => l.stampsAutumn,
      Season.winter => l.stampsWinter,
    };

/// 季節のスタンプ帳: いまの季節にぴったりの雑学を読むとスタンプが1つ。3つで完成して、相棒がその季節の飾りをつける。
class StampsScreen extends ConsumerWidget {
  const StampsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final stamps = ref.watch(settingsProvider.select((s) => s.stamps));
    final now = ref.watch(nowProvider);
    final hemisphere = ref.watch(hemisphereProvider) ?? Hemisphere.north;
    final repo = ref.watch(triviaRepositoryProvider);
    final current = seasonFor(now, hemisphere);

    return Scaffold(
      appBar: AppBar(title: Text(l.stampsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.stampsHint(stampGoal), style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            for (final season in Season.values)
              Builder(builder: (context) {
                final year = stampYear(now, season, hemisphere);
                final ids = stampsFor(stamps, year, season);
                final done = ids.length >= stampGoal;
                final isNow = season == current;
                return Card(
                  key: Key('stamp_book_${season.name}'),
                  color: isNow ? theme.colorScheme.primaryContainer : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(seasonEmoji[season]!, style: const TextStyle(fontSize: 32)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(seasonName(l, season),
                                  style: theme.textTheme.titleMedium),
                            ),
                            if (isNow) Chip(label: Text(l.stampsNow), visualDensity: VisualDensity.compact),
                            const SizedBox(width: 8),
                            Text('${ids.length.clamp(0, stampGoal)} / $stampGoal',
                                key: Key('stamp_progress_${season.name}'),
                                style: theme.textTheme.titleMedium),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            for (var i = 0; i < stampGoal; i++)
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Container(
                                  key: Key('stamp_${season.name}_$i'),
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: i < ids.length
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.outlineVariant,
                                      width: 2,
                                    ),
                                    color: i < ids.length
                                        ? theme.colorScheme.surface
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: i < ids.length
                                      ? TriviaIllustration(
                                          id: repo.byId(ids[i])?.illustration ?? '', size: 28)
                                      : Text('·',
                                          style: TextStyle(
                                              fontSize: 28,
                                              color: theme.colorScheme.outlineVariant)),
                                ),
                              ),
                          ],
                        ),
                        if (done) ...[
                          const SizedBox(height: 8),
                          Text('${seasonAccessory[season]} ${l.stampsOutfit}',
                              key: Key('stamp_outfit_${season.name}'),
                              style: theme.textTheme.titleSmall),
                        ],
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
