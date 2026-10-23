import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../logic/daily_pick.dart';
import '../logic/quiz_game.dart';
import '../logic/streak.dart';
import '../models/glossary.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/quiz_play.dart';
import 'quiz_battle_screen.dart';

/// 今日のことば: 日付で決まる（同じ言語なら、みんな同じことば）。
(GlossaryEntry, GlossaryText)? wordOfTheDay(List<(GlossaryEntry, GlossaryText)> all, DateTime day) {
  if (all.isEmpty) return null;
  final sorted = [...all]..sort((a, b) => a.$1.id.compareTo(b.$1.id));
  return sorted[mix32(fnv1a('word:${dayKey(day)}')) % sorted.length];
}

/// ことばクイズの出題（「○○」の意味は？の4択）。ことばが4つ未満なら出せない。
List<BattleQuestion> buildWordQuiz(
  List<(GlossaryEntry, GlossaryText)> all,
  Random random, {
  required String Function(String term) question,
  int count = 10,
}) {
  if (all.length < 4) return const [];
  final picked = pickQuestions(all, count, random);
  return [
    for (final (entry, text) in picked)
      () {
        final others = pickQuestions([for (final o in all) if (o.$1.id != entry.id) o], 3, random);
        final options = <(String, bool)>[
          (text.simple, true),
          for (final o in others) (o.$2.simple, false),
        ]..shuffle(random);
        return BattleQuestion(
          factId: 'word:${entry.id}',
          statement: question(text.term),
          options: [for (final o in options) o.$1],
          correct: options.indexWhere((o) => o.$2),
          explanation: text.detail.isEmpty ? text.simple : text.detail,
          illustration: 'words',
          category: 'words',
        );
      }(),
  ];
}

/// ことばずかん: 説明を見たことばが貯まる。まだのことばは「？？？」。今日のことばと、ことばクイズへの入口つき。
class WordsScreen extends ConsumerWidget {
  const WordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final all = ref.watch(glossaryListProvider);
    final seen = ref.watch(settingsProvider.select((s) => s.words));
    final today = wordOfTheDay(all, ref.watch(nowProvider));
    final found = all.where((w) => seen.contains(w.$1.id)).length;
    final sorted = [...all]..sort((a, b) => a.$2.term.compareTo(b.$2.term));

    return Scaffold(
      appBar: AppBar(title: Text(l.wordsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.wordsFound(found, all.length),
                key: const Key('words_progress'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: all.isEmpty ? 0 : found / all.length, minHeight: 8),
            const SizedBox(height: 12),
            if (today != null)
              Card(
                key: const Key('word_of_day'),
                color: theme.colorScheme.primaryContainer,
                child: ListTile(
                  title: Text(l.wordOfDay),
                  subtitle: Text(today.$2.term,
                      key: const Key('word_of_day_term'),
                      style: theme.textTheme.titleLarge),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => context.push('/word/${today.$1.id}'),
                ),
              ),
            FilledButton.icon(
              key: const Key('open_wordquiz_from_words'),
              icon: const Icon(Icons.quiz_outlined),
              label: Text(l.wordQuizTitle),
              onPressed: all.length < 4 ? null : () => context.push('/wordquiz'),
            ),
            const SizedBox(height: 12),
            Text(l.wordsHint, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            for (final (entry, text) in sorted)
              Card(
                key: Key('words_item_${entry.id}'),
                child: seen.contains(entry.id)
                    ? ListTile(
                        title: Text(text.term),
                        subtitle: Text(text.simple, maxLines: 2, overflow: TextOverflow.ellipsis),
                        onTap: () => context.push('/word/${entry.id}'),
                      )
                    : ListTile(
                        title: Text(l.mascotLocked,
                            style: TextStyle(color: theme.colorScheme.outline)),
                        enabled: false,
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ことばクイズ: 「○○」の意味は？（4択・10問）。
class WordQuizScreen extends ConsumerStatefulWidget {
  const WordQuizScreen({super.key});

  @override
  ConsumerState<WordQuizScreen> createState() => _WordQuizScreenState();
}

class _WordQuizScreenState extends ConsumerState<WordQuizScreen> {
  QuizGame? _game;
  int _gameId = 0;

  void _start(AppLocalizations l) {
    final qs = buildWordQuiz(ref.read(glossaryListProvider), ref.read(quizRandomProvider),
        question: l.wordQuizQuestion);
    setState(() {
      _gameId++;
      _game = qs.isEmpty ? null : QuizGame(names: const ['-'], questions: qs);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _start(AppLocalizations.of(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final game = _game;
    return Scaffold(
      appBar: AppBar(title: Text(l.wordQuizTitle)),
      body: SafeArea(
        child: game == null
            ? Center(child: Text(l.battleNoQuestions))
            : QuizPlay(
                key: ValueKey(_gameId),
                game: game,
                onReveal: (g) => ref
                    .read(settingsProvider.notifier)
                    .recordQuizAnswer(correct: g.isCorrect(0)!),
                finishedBuilder: (context, g) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l.battleSoloScore(g.scores[0], g.questions.length),
                            key: const Key('wordquiz_final'),
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 24),
                        FilledButton(
                          key: const Key('wordquiz_again'),
                          onPressed: () => _start(l),
                          child: Text(l.battleAgain),
                        ),
                        TextButton(
                          key: const Key('wordquiz_exit'),
                          onPressed: () => context.pop(),
                          child: Text(l.battleExit),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
