import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/trivia_repository.dart';
import '../l10n/app_localizations.dart';
import '../logic/quiz_game.dart';
import '../models/age_band.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/ja_wrap_text.dart';

/// 出題の乱数。テストでは固定する。
final quizRandomProvider = Provider<Random>((ref) => Random());

/// 対戦に出せる問題。いま表示できる雑学のうち、○×クイズがあるもの。
final battlePoolProvider = Provider<List<BattleQuestion>>((ref) {
  final repo = ref.watch(triviaRepositoryProvider);
  final band = ref.watch(settingsProvider.select((s) => s.ageBand)) ?? AgeBand.adult;
  final lang = ref.watch(contentLanguageProvider);
  return [
    for (final t in ref.watch(allEligibleProvider))
      if (repo.quizFor(t.id) case final quiz?)
        if (quiz.forLanguage(lang) case final q?)
          if (t.levelFor(band, lang, allowDraft: kAllowDraftContent) case final level?)
            BattleQuestion(
              factId: t.id,
              statement: q.statement,
              answer: q.answer,
              explanation: level.body,
              illustration: t.illustration,
            ),
  ];
});

const _avatars = ['🐶', '🐱', '🐰', '🐻'];
const _colors = [Colors.orange, Colors.pink, Colors.teal, Colors.indigo];

class QuizBattleScreen extends ConsumerStatefulWidget {
  const QuizBattleScreen({super.key});

  @override
  ConsumerState<QuizBattleScreen> createState() => _QuizBattleScreenState();
}

class _QuizBattleScreenState extends ConsumerState<QuizBattleScreen> {
  int _players = 1;
  int _rounds = 5;
  final _nameControllers = List.generate(4, (_) => TextEditingController());
  QuizGame? _game;

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

  void _start(AppLocalizations l) {
    final pool = ref.read(battlePoolProvider);
    if (pool.isEmpty) return;
    final questions = pickQuestions(pool, _rounds, ref.read(quizRandomProvider));
    setState(() => _game = QuizGame(
          names: [for (var p = 0; p < _players; p++) _name(l, p)],
          questions: questions,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final game = _game;
    return Scaffold(
      appBar: AppBar(title: Text(l.battleTitle)),
      body: SafeArea(
        child: game == null ? _setup(l) : _play(l, game),
      ),
    );
  }

  // ---- 設定 ----
  Widget _setup(AppLocalizations l) {
    final theme = Theme.of(context);
    final band = ref.watch(settingsProvider.select((s) => s.ageBand)) ?? AgeBand.adult;
    final available = ref.watch(battlePoolProvider).length;
    final lang = ref.watch(contentLanguageProvider);
    final rounds = [for (final r in const [5, 10]) if (r <= available || r == 5) r];
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
                Text(_avatars[p], style: const TextStyle(fontSize: 28)),
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
        const SizedBox(height: 16),
        Text(l.battleRounds, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final r in rounds)
              ChoiceChip(
                key: Key('battle_rounds_$r'),
                label: Text(l.battleRoundCount(r)),
                selected: _rounds == r,
                onSelected: (_) => setState(() => _rounds = r),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (band.isChild) Text(l.battleHandHint, style: theme.textTheme.bodySmall),
        const SizedBox(height: 24),
        FilledButton(
          key: const Key('battle_start'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          onPressed: available == 0 ? null : () => _start(l),
          child: Text(l.battleStart, style: TextStyle(fontSize: lang == 'ja' ? 20 : 18)),
        ),
        if (available == 0) Text(l.battleNoQuestions),
      ],
    );
  }

  // ---- 対戦中 ----
  Widget _play(AppLocalizations l, QuizGame game) {
    if (game.phase == BattlePhase.finished) return _finished(l, game);
    final theme = Theme.of(context);
    final lang = ref.watch(contentLanguageProvider);
    final band = ref.watch(settingsProvider.select((s) => s.ageBand)) ?? AgeBand.adult;
    final wrap = lang == 'ja' && band.isChild;
    final q = game.question;
    final reveal = game.phase == BattlePhase.reveal;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l.battleRoundOf(game.round + 1, game.questions.length),
            key: const Key('battle_round'),
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        if (!game.isSolo) _scoreBar(l, game),
        const SizedBox(height: 16),
        WrapText(q.statement,
            key: const Key('battle_statement'),
            wordWrap: lang == 'ja',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall),
        const SizedBox(height: 24),
        if (!reveal) ...[
          if (!game.isSolo)
            Container(
              key: const Key('battle_turn'),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: _colors[game.turn].withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_avatars[game.turn]} ${l.battleTurnOf(game.names[game.turn])}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  key: const Key('battle_true'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(80)),
                  onPressed: () => setState(() => game.answer(true)),
                  child: Text('○ ${l.quizTrue}', style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonal(
                  key: const Key('battle_false'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(80)),
                  onPressed: () => setState(() => game.answer(false)),
                  child: Text('✕ ${l.quizFalse}', style: const TextStyle(fontSize: 22)),
                ),
              ),
            ],
          ),
        ] else ...[
          Text(
            q.answer ? '○ ${l.quizTrue}' : '✕ ${l.quizFalse}',
            key: const Key('battle_answer'),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          for (var p = 0; p < game.playerCount; p++)
            ListTile(
              key: Key('battle_result_$p'),
              dense: true,
              leading: Text(_avatars[p], style: const TextStyle(fontSize: 24)),
              title: Text(game.names[p]),
              trailing: Icon(
                game.isCorrect(p)! ? Icons.check_circle : Icons.cancel,
                color: game.isCorrect(p)! ? Colors.green : theme.colorScheme.error,
              ),
            ),
          const SizedBox(height: 12),
          WrapText(q.explanation,
              wordWrap: wrap,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('battle_next'),
            onPressed: () => setState(game.next),
            child: Text(game.isLastRound ? l.battleSeeResult : l.quizNext),
          ),
        ],
      ],
    );
  }

  Widget _scoreBar(AppLocalizations l, QuizGame game) {
    final scores = game.scores;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 4,
      children: [
        for (var p = 0; p < game.playerCount; p++)
          Chip(
            key: Key('battle_score_$p'),
            avatar: Text(_avatars[p]),
            label: Text('${game.names[p]} ${scores[p]}'),
            side: BorderSide(color: _colors[p]),
          ),
      ],
    );
  }

  // ---- 結果 ----
  Widget _finished(AppLocalizations l, QuizGame game) {
    final theme = Theme.of(context);
    final scores = game.scores;
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
        if (game.isSolo)
          Text(l.battleSoloScore(scores[0], total),
              key: const Key('battle_final'),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall)
        else ...[
          Text(
            tied
                ? l.battleDraw
                : l.battleWinner(game.names[game.winners.first]),
            key: const Key('battle_final'),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          for (final p in order)
            ListTile(
              key: Key('battle_rank_$p'),
              leading: Text(l.battleRank(ranks[p]),
                  style: theme.textTheme.titleLarge),
              title: Text('${_avatars[p]} ${game.names[p]}'),
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
