import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/trivia_repository.dart';
import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../logic/quiz_game.dart';
import '../models/age_band.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/quiz_play.dart';

/// 出題の乱数。テストでは固定する。
final quizRandomProvider = Provider<Random>((ref) => Random());

/// 対戦などに出せる問題。いま表示できる雑学のうち、○×クイズ・選択式クイズがあるもの。
final battlePoolProvider = Provider<List<BattleQuestion>>((ref) {
  final repo = ref.watch(triviaRepositoryProvider);
  final band = ref.watch(settingsProvider.select((s) => s.ageBand)) ?? AgeBand.adult;
  final lang = ref.watch(contentLanguageProvider);
  final out = <BattleQuestion>[];
  for (final t in ref.watch(allEligibleProvider)) {
    final level = t.levelFor(band, lang, allowDraft: kAllowDraftContent);
    if (level == null) continue;
    BattleQuestion make(String statement, List<String> options, int correct, bool tf) =>
        BattleQuestion(
          factId: t.id,
          statement: statement,
          options: options,
          correct: correct,
          explanation: level.body,
          illustration: t.illustration,
          category: t.category,
          isTrueFalse: tf,
        );
    final quiz = repo.quizFor(t.id)?.forLanguage(lang);
    if (quiz != null) {
      out.add(make(quiz.statement, const ['○', '✕'], quiz.answer ? 0 : 1, true));
    }
    for (final c in repo.choiceQuizzes) {
      if (c.factId != t.id) continue;
      final q = c.forLanguage(lang);
      if (q != null) out.add(make(q.question, q.options, q.answer, false));
    }
  }
  return out;
});

enum _Kind { all, trueFalse, choice }

class QuizBattleScreen extends ConsumerStatefulWidget {
  const QuizBattleScreen({super.key});

  @override
  ConsumerState<QuizBattleScreen> createState() => _QuizBattleScreenState();
}

class _QuizBattleScreenState extends ConsumerState<QuizBattleScreen> {
  int _players = 1;
  int _rounds = 5;
  int? _timeLimit;
  _Kind _kind = _Kind.all;
  String? _category;
  final _nameControllers = List.generate(4, (_) => TextEditingController());
  QuizGame? _game;
  int _gameId = 0;
  bool _toLeague = true;
  bool _recorded = false;

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  String _name(AppLocalizations l, int p) {
    final typed = _nameControllers[p].text.trim();
    return typed.isEmpty ? l.battlePlayerDefault(p + 1) : typed;
  }

  List<BattleQuestion> _filtered(List<BattleQuestion> pool) => [
        for (final q in pool)
          if ((_kind == _Kind.all ||
                  (_kind == _Kind.trueFalse) == q.isTrueFalse) &&
              (_category == null || q.category == _category))
            q,
      ];

  void _start(AppLocalizations l) {
    final pool = _filtered(ref.read(battlePoolProvider));
    if (pool.isEmpty) return;
    final questions = pickQuestions(pool, _rounds, ref.read(quizRandomProvider));
    setState(() {
      _gameId++;
      _recorded = false;
      _game = QuizGame(
        names: [for (var p = 0; p < _players; p++) _name(l, p)],
        questions: questions,
        timeLimit: _timeLimit,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final game = _game;
    return Scaffold(
      appBar: AppBar(title: Text(l.battleTitle)),
      body: SafeArea(
        child: game == null
            ? _setup(l)
            : QuizPlay(
                key: ValueKey(_gameId),
                game: game,
                onReveal: (g) {
                  if (g.isSolo) {
                    ref.read(settingsProvider.notifier).recordQuizAnswer(correct: g.isCorrect(0)!);
                  }
                },
                finishedBuilder: (context, g) => _finished(l, g),
              ),
      ),
    );
  }

  Widget _setup(AppLocalizations l) {
    final theme = Theme.of(context);
    final band = ref.watch(settingsProvider.select((s) => s.ageBand)) ?? AgeBand.adult;
    final pool = ref.watch(battlePoolProvider);
    final available = _filtered(pool).length;
    final categories = {for (final q in pool) q.category}.toList()..sort();

    Widget heading(String text) => Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(text, style: theme.textTheme.titleMedium),
        );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l.battlePlayers, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (var n = 1; n <= QuizGame.maxPlayers; n++)
              ChoiceChip(
                key: Key('battle_players_$n'),
                label: Text(n == 1 ? l.battleSolo : l.battlePlayerCount(n)),
                selected: _players == n,
                onSelected: (_) => setState(() => _players = n),
              ),
          ],
        ),
        const SizedBox(height: 16),
        for (var p = 0; p < _players; p++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(quizAvatars[p], style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    key: Key('battle_name_$p'),
                    controller: _nameControllers[p],
                    maxLength: 8,
                    decoration: InputDecoration(
                      hintText: l.battlePlayerDefault(p + 1),
                      counterText: '',
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        heading(l.battleRounds),
        Wrap(
          spacing: 8,
          children: [
            for (final r in const [5, 10])
              ChoiceChip(
                key: Key('battle_rounds_$r'),
                label: Text(l.battleRoundCount(r)),
                selected: _rounds == r,
                onSelected: (_) => setState(() => _rounds = r),
              ),
          ],
        ),
        heading(l.battleKind),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              key: const Key('battle_kind_all'),
              label: Text(l.battleKindAll),
              selected: _kind == _Kind.all,
              onSelected: (_) => setState(() => _kind = _Kind.all),
            ),
            ChoiceChip(
              key: const Key('battle_kind_tf'),
              label: Text(l.battleKindTrueFalse),
              selected: _kind == _Kind.trueFalse,
              onSelected: (_) => setState(() => _kind = _Kind.trueFalse),
            ),
            ChoiceChip(
              key: const Key('battle_kind_choice'),
              label: Text(l.battleKindChoice),
              selected: _kind == _Kind.choice,
              onSelected: (_) => setState(() => _kind = _Kind.choice),
            ),
          ],
        ),
        heading(l.battleGenre),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              key: const Key('battle_genre_all'),
              label: Text(l.battleGenreAll),
              selected: _category == null,
              onSelected: (_) => setState(() => _category = null),
            ),
            for (final c in categories)
              ChoiceChip(
                key: Key('battle_genre_$c'),
                label: Text(categoryLabel(l, c)),
                selected: _category == c,
                onSelected: (_) => setState(() => _category = c),
              ),
          ],
        ),
        heading(l.battleTimeLimit),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              key: const Key('battle_time_off'),
              label: Text(l.battleTimeOff),
              selected: _timeLimit == null,
              onSelected: (_) => setState(() => _timeLimit = null),
            ),
            for (final s in const [10, 20])
              ChoiceChip(
                key: Key('battle_time_$s'),
                label: Text(l.battleSeconds(s)),
                selected: _timeLimit == s,
                onSelected: (_) => setState(() => _timeLimit = s),
              ),
          ],
        ),
        if (_players >= 2)
          SwitchListTile(
            key: const Key('battle_league_switch'),
            contentPadding: EdgeInsets.zero,
            title: Text(l.leagueRecord),
            value: _toLeague,
            onChanged: (v) => setState(() => _toLeague = v),
          ),
        const SizedBox(height: 8),
        if (_timeLimit != null) Text(l.battleTimeHint, style: theme.textTheme.bodySmall),
        if (band.isChild) Text(l.battleHandHint, style: theme.textTheme.bodySmall),
        const SizedBox(height: 24),
        FilledButton(
          key: const Key('battle_start'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          onPressed: available == 0 ? null : () => _start(l),
          child: Text(l.battleStart, style: const TextStyle(fontSize: 20)),
        ),
        if (available == 0) Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(l.battleNoQuestions),
        ),
      ],
    );
  }

  Widget _finished(AppLocalizations l, QuizGame game) {
    final theme = Theme.of(context);
    // 2人以上の対戦は、家族リーグに記録する（1回だけ）。
    if (!_game!.isSolo && _toLeague && !_recorded) {
      _recorded = true;
      final names = game.names;
      final scores = game.scores;
      final winners = game.winners;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(settingsProvider.notifier).recordLeagueGame(ref.read(nowProvider),
            names: names, scores: scores, winners: winners);
      });
    }
    final scores = game.scores;
    final points = game.points;
    final total = game.questions.length;
    final ranks = game.ranks;
    final order = [for (var p = 0; p < game.playerCount; p++) p]
      ..sort((a, b) => ranks[a] != ranks[b] ? ranks[a].compareTo(ranks[b]) : a.compareTo(b));
    final tied = game.winners.length > 1;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l.battleFinished,
            textAlign: TextAlign.center, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 12),
        if (game.isSolo) ...[
          Text(l.battleSoloScore(scores[0], total),
              key: const Key('battle_final'),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall),
          if (game.timed)
            Text(l.battlePoints(points[0]),
                textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
        ] else ...[
          Text(
            tied ? l.battleDraw : l.battleWinner(game.names[game.winners.first]),
            key: const Key('battle_final'),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          for (final p in order)
            ListTile(
              key: Key('battle_rank_$p'),
              leading: Text(l.battleRank(ranks[p]), style: theme.textTheme.titleLarge),
              title: Text('${quizAvatars[p]} ${game.names[p]}'),
              subtitle: game.timed ? Text(l.battlePoints(points[p])) : null,
              trailing: Text('${scores[p]} / $total', style: theme.textTheme.titleMedium),
            ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          key: const Key('battle_again'),
          onPressed: () => _start(l),
          child: Text(l.battleAgain),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const Key('battle_setup'),
          onPressed: () => setState(() => _game = null),
          child: Text(l.battleChangeSettings),
        ),
        const SizedBox(height: 8),
        TextButton(
          key: const Key('battle_exit'),
          onPressed: () => context.pop(),
          child: Text(l.battleExit),
        ),
      ],
    );
  }
}
