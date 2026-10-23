import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../logic/activity.dart';
import '../logic/mascot.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/mascot_card.dart';

/// 直近7日と、その前の7日のまとめ。
class Recap {
  const Recap({
    required this.week,
    required this.previous,
    required this.days,
    required this.activeDays,
    required this.previousActiveDays,
  });
  final DayActivity week;
  final DayActivity previous;
  final List<(String, DayActivity)> days;
  final int activeDays;
  final int previousActiveDays;
}

final recapProvider = Provider<Recap>((ref) {
  final map = ref.watch(settingsProvider.select((s) => s.activity));
  final now = ref.watch(nowProvider);
  final prevEnd = DateTime(now.year, now.month, now.day - 7);
  return Recap(
    week: sumActivity(map, now, 7),
    previous: sumActivity(map, prevEnd, 7),
    days: dailyActivity(map, now, 7),
    activeDays: activeDays(map, now, 7),
    previousActiveDays: activeDays(map, prevEnd, 7),
  );
});

/// 週のふりかえり: 読んだ数・知れた数・クイズの正解・活動した日。前の週との差と、1日ごとの棒グラフつき。
class RecapScreen extends ConsumerWidget {
  const RecapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final recap = ref.watch(recapProvider);
    final stage = mascotStageFor(ref.watch(mascotPointsProvider));
    final w = recap.week;

    final message = recap.activeDays == 0
        ? l.recapMsgNone
        : (recap.activeDays <= 3 ? l.recapMsgSome : l.recapMsgGreat);

    Widget stat(String id, String emoji, String label, String value, int delta) => Card(
          key: Key('recap_$id'),
          child: ListTile(
            leading: Text(emoji, style: const TextStyle(fontSize: 28)),
            title: Text(label),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value, style: theme.textTheme.titleLarge),
                if (delta != 0)
                  Text(delta > 0 ? '▲ $delta' : '▼ ${-delta}',
                      key: Key('recap_${id}_delta'),
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: delta > 0 ? Colors.green.shade700 : theme.colorScheme.outline)),
              ],
            ),
          ),
        );

    final maxBar = recap.days
        .map((d) => d.$2.seen + d.$2.answered)
        .fold<int>(1, (a, b) => b > a ? b : a);

    return Scaffold(
      appBar: AppBar(title: Text(l.recapTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: MascotFace(
                stage: stage,
                size: 72,
                mood: recap.activeDays >= 4
                    ? MascotMood.happy
                    : (recap.activeDays == 0 ? MascotMood.sad : MascotMood.idle),
              ),
            ),
            const SizedBox(height: 8),
            Text(message,
                key: const Key('recap_message'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l.recapNote, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            stat('seen', '📖', l.recapSeen, '${w.seen}',
                w.seen - recap.previous.seen),
            stat('learned', '💡', l.recapLearned, '${w.learned}',
                w.learned - recap.previous.learned),
            stat('quiz', '🎯', l.recapQuiz,
                w.answered == 0 ? '-' : '${w.correct} / ${w.answered}',
                w.correct - recap.previous.correct),
            stat('days', '📅', l.recapActiveDays, '${recap.activeDays} / 7',
                recap.activeDays - recap.previousActiveDays),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final (day, a) in recap.days)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            key: Key('recap_bar_$day'),
                            height: 6 + 70.0 * (a.seen + a.answered) / maxBar,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: a.isEmpty
                                  ? theme.colorScheme.surfaceContainerHighest
                                  : theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(DateFormat.E(l.localeName).format(DateTime.parse(day)),
                              style: theme.textTheme.labelSmall),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
