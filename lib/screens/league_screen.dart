import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../logic/league.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/share_cards.dart';
import '../widgets/share_sheet.dart';

/// 家族リーグ: 今週の得点ランキングと、先週の優勝者。この端末の中だけで集計する。
class LeagueScreen extends ConsumerWidget {
  const LeagueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final today = ref.watch(nowProvider);
    // 週がかわっていたら、見かけ上も新しい週にする（保存は次の対戦のとき）。
    final data = rollWeek(ref.watch(settingsProvider.select((s) => s.league)), today);
    final rows = data.scores.entries.toList()
      ..sort((a, b) {
        final c = b.value.points.compareTo(a.value.points);
        return c != 0 ? c : a.key.compareTo(b.key);
      });

    return Scaffold(
      appBar: AppBar(
        title: Text(l.leagueTitle),
        actions: [
          if (rows.isNotEmpty)
            ShareButton(
              buttonKey: const Key('league_share'),
              compact: true,
              text: '${l.appName} ${l.leagueTitle}\n${rows.first.key} ${l.battlePoints(rows.first.value.points)}\n#${l.appName}',
              card: ShareFrame(appName: l.appName, children: [
                bigEmoji('🏆'),
                gap8,
                cardTitle(l.leagueThisWeek),
                gap12,
                for (var i = 0; i < rows.length && i < 4; i++)
                  cardRow('${i == 0 ? '🥇' : (i == 1 ? '🥈' : (i == 2 ? '🥉' : '${i + 1}'))}  ${rows[i].key}',
                      l.battlePoints(rows[i].value.points)),
              ]),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.leagueNote, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            if (data.lastWinner != null)
              Card(
                key: const Key('league_last_winner'),
                color: theme.colorScheme.primaryContainer,
                child: ListTile(
                  leading: const Text('👑', style: TextStyle(fontSize: 32)),
                  title: Text(l.leagueLastWinner(data.lastWinner!)),
                  subtitle: Text(l.battlePoints(data.lastPoints)),
                ),
              ),
            const SizedBox(height: 8),
            Text(l.leagueThisWeek, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(l.leagueEmpty,
                    key: const Key('league_empty'), textAlign: TextAlign.center),
              )
            else
              for (var i = 0; i < rows.length; i++)
                Card(
                  key: Key('league_row_${rows[i].key}'),
                  child: ListTile(
                    leading: Text(i == 0 ? '🥇' : (i == 1 ? '🥈' : (i == 2 ? '🥉' : '${i + 1}')),
                        style: const TextStyle(fontSize: 28)),
                    title: Text(rows[i].key),
                    subtitle: Text(l.leagueGames(rows[i].value.games, rows[i].value.wins)),
                    trailing: Text(l.battlePoints(rows[i].value.points),
                        style: theme.textTheme.titleMedium),
                  ),
                ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('league_play'),
              icon: const Icon(Icons.sports_esports),
              label: Text(l.leaguePlay),
              onPressed: () => context.push('/quiz'),
            ),
            if (rows.isNotEmpty)
              TextButton(
                key: const Key('league_clear'),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(l.leagueClearTitle),
                      content: Text(l.leagueClearBody),
                      actions: [
                        TextButton(
                          key: const Key('league_clear_cancel'),
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(l.privacyDeleteCancel),
                        ),
                        FilledButton(
                          key: const Key('league_clear_confirm'),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(l.privacyDeleteConfirm),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    ref.read(settingsProvider.notifier).clearLeagueWeek(ref.read(nowProvider));
                  }
                },
                child: Text(l.leagueClear),
              ),
          ],
        ),
      ),
    );
  }
}
