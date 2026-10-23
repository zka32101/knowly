import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../logic/badges.dart';
import '../logic/daily_pick.dart';
import '../logic/quiz_game.dart';
import '../logic/review.dart';
import '../logic/streak.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/quiz_play.dart';
import '../widgets/share_cards.dart';
import '../widgets/share_sheet.dart';
import 'quiz_battle_screen.dart';

/// 今日の復習に出す問題（期限が来た「知らなかった」雑学のうち、クイズがあるもの。1雑学に1問）。
final reviewQuestionsProvider = Provider<List<BattleQuestion>>((ref) {
  final entries = ref.watch(settingsProvider.select((s) => s.reviews));
  final due = dueReviewIds(entries, ref.watch(nowProvider));
  final pool = ref.watch(battlePoolProvider);
  return [
    for (final id in due)
      for (final q in pool.where((q) => q.factId == id).take(1)) q,
  ];
});

/// 今日のチャレンジの問題数。
const dailyChallengeSize = 3;

/// 今日のチャレンジの問題。日付で決まるので、同じ言語・年代の人は同じ問題になる。
List<BattleQuestion> dailyQuestions(List<BattleQuestion> pool, DateTime day) {
  final key = dayKey(day);
  final sorted = [...pool]
    ..sort((a, b) => '${a.factId}${a.statement}'.compareTo('${b.factId}${b.statement}'));
  sorted.sort((a, b) => mix32(fnv1a('$key${a.factId}${a.statement}'))
      .compareTo(mix32(fnv1a('$key${b.factId}${b.statement}'))));
  final out = <BattleQuestion>[];
  final facts = <String>{};
  for (final q in sorted) {
    if (facts.add(q.factId)) out.add(q);
    if (out.length == dailyChallengeSize) break;
  }
  return out;
}

QuizGame _soloGame(List<BattleQuestion> questions) =>
    QuizGame(names: const ['-'], questions: questions);

// ---------------------------------------------------------------- 復習

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  late final QuizGame? _game = () {
    final all = ref.read(reviewQuestionsProvider);
    if (all.isEmpty) return null;
    return _soloGame(all.take(10).toList());
  }();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final game = _game;
    return Scaffold(
      appBar: AppBar(title: Text(l.reviewTitle)),
      body: SafeArea(
        child: game == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l.reviewNone,
                      key: const Key('review_none'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
              )
            : QuizPlay(
                game: game,
                onReveal: (g) {
                  final ok = g.isCorrect(0)!;
                  final notifier = ref.read(settingsProvider.notifier);
                  notifier.recordReview(g.question.factId,
                      correct: ok, today: ref.read(nowProvider));
                  notifier.recordQuizAnswer(correct: ok);
                },
                finishedBuilder: (context, g) {
                  final total = g.questions.length;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l.battleSoloScore(g.scores[0], total),
                              key: const Key('review_done'),
                              style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 8),
                          Text(l.reviewDoneNote, textAlign: TextAlign.center),
                          const SizedBox(height: 24),
                          FilledButton(
                            key: const Key('review_exit'),
                            onPressed: () => context.pop(),
                            child: Text(l.battleExit),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------- 今日のチャレンジ

class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen> {
  final _results = <bool>[];
  QuizGame? _game;

  @override
  void initState() {
    super.initState();
    final today = ref.read(nowProvider);
    final done = ref.read(settingsProvider).dailyResults.containsKey(dayKey(today));
    if (!done) {
      final qs = dailyQuestions(ref.read(battlePoolProvider), today);
      if (qs.isNotEmpty) _game = _soloGame(qs);
    }
  }

  String _marks(String result) =>
      result.split('').map((c) => c == '1' ? '✅' : '❌').join();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final today = ref.watch(nowProvider);
    final settings = ref.watch(settingsProvider);
    final todayResult = settings.dailyResults[dayKey(today)];
    final game = _game;

    Widget summary(String result) {
      final correct = result.split('').where((c) => c == '1').length;
      final streak = dailyStreak(settings.dailyResults.keys, today);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_marks(result),
                  key: const Key('daily_marks'),
                  style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(l.battleSoloScore(correct, result.length),
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(l.dailyStreak(streak), key: const Key('daily_streak')),
              const SizedBox(height: 4),
              Text(l.dailyComeBack),
              const SizedBox(height: 24),
              ShareButton(
                buttonKey: const Key('daily_share'),
                text: '${l.appName} ${l.dailyTitle} ${dayKey(today)}\n${_marks(result)} $correct/${result.length}\n#${l.appName}',
                card: ShareFrame(appName: l.appName, children: [
                  bigEmoji(_marks(result), size: 44),
                  gap8,
                  cardBig('$correct / ${result.length}'),
                  gap8,
                  cardTitle(l.dailyTitle),
                  cardBody(dayKey(today)),
                  cardBody(l.dailyStreak(streak)),
                ]),
              ),
              TextButton(
                key: const Key('daily_exit'),
                onPressed: () => context.pop(),
                child: Text(l.battleExit),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.dailyTitle)),
      body: SafeArea(
        // 遊んでいる最中は、記録が保存されても画面を切り替えない（最後の解説まで見せる）。
        child: game == null
            ? (todayResult != null
                ? summary(todayResult)
                : Center(child: Text(l.battleNoQuestions)))
            : QuizPlay(
                    game: game,
                    onReveal: (g) {
                      final ok = g.isCorrect(0)!;
                      _results.add(ok);
                      final notifier = ref.read(settingsProvider.notifier);
                      notifier.recordQuizAnswer(correct: ok);
                      if (g.isLastRound) {
                        notifier.recordDaily(
                            ref.read(nowProvider), _results.map((r) => r ? '1' : '0').join());
                      }
                    },
                    finishedBuilder: (context, g) =>
                        summary(_results.map((r) => r ? '1' : '0').join()),
                  ),
      ),
    );
  }
}
