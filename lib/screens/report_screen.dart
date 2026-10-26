import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/trivia_repository.dart';
import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../logic/activity.dart';
import '../state/providers.dart';
import '../state/settings.dart';

/// 保護者向けの学習のようす。端末内の記録だけから作り、送信しない。
class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = ref.watch(settingsProvider);
    final repo = ref.watch(triviaRepositoryProvider);
    final lang = ref.watch(contentLanguageProvider);
    final band = s.ageBand;

    final learnedIds = [
      for (final e in s.knowledge.entries)
        if (e.value == Knowledge.learned) e.key,
    ];
    final knewCount = s.knowledge.values.where((k) => k == Knowledge.knew).length;

    // よく見たジャンル（「知ってた／知らなかった」を付けた雑学から数える）
    final byCategory = <String, int>{};
    for (final id in s.knowledge.keys) {
      final t = repo.byId(id);
      if (t != null) byCategory[t.category] = (byCategory[t.category] ?? 0) + 1;
    }
    final topCategories = byCategory.entries.toList()
      ..sort((a, b) => b.value != a.value ? b.value.compareTo(a.value) : a.key.compareTo(b.key));

    // 最近まなんだこと（直近に「知らなかった」を付けた5件）
    final recent = <String>[];
    if (band != null) {
      for (final id in learnedIds.reversed) {
        final level = repo.byId(id)?.levelFor(band, lang, allowDraft: kAllowDraftContent);
        if (level != null) recent.add(level.title);
        if (recent.length == 5) break;
      }
    }

    final accuracy =
        s.quizAnswered == 0 ? null : (s.quizCorrect * 100 / s.quizAnswered).round();

    Widget stat(Key key, String label, String value) => ListTile(
          key: key,
          title: Text(label),
          trailing: Text(value, style: theme.textTheme.titleMedium),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.reportTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.reportNote, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            // 今週（きょうをふくむ7日）のようす
            Builder(builder: (context) {
              final week = sumActivity(s.activity, ref.watch(nowProvider), 7);
              return ListTile(
                key: const Key('report_week'),
                leading: const Icon(Icons.date_range),
                title: Text(l.reportThisWeek(week.seen, week.answered)),
              );
            }),
            stat(const Key('report_learned'), l.reportLearned, '${learnedIds.length}'),
            stat(const Key('report_knew'), l.reportKnew, '$knewCount'),
            stat(const Key('report_quiz'), l.reportQuiz,
                accuracy == null ? l.reportNoQuiz : '${s.quizCorrect} / ${s.quizAnswered} ($accuracy%)'),
            stat(const Key('report_review'), l.reportReviewPending, '${s.reviews.length}'),
            const SizedBox(height: 12),
            Text(l.reportFavorite, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            if (topCategories.isEmpty)
              Text(l.reportEmpty, key: const Key('report_empty'))
            else
              Wrap(
                spacing: 8,
                children: [
                  for (final c in topCategories.take(3))
                    Chip(
                      key: Key('report_cat_${c.key}'),
                      label: Text('${categoryLabel(l, c.key)} ${c.value}'),
                    ),
                ],
              ),
            if (recent.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(l.reportRecent, style: theme.textTheme.titleSmall),
              for (final t in recent)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('・$t'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
