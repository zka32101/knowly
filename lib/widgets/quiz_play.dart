import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../logic/quiz_game.dart';
import '../models/age_band.dart';
import '../state/settings.dart';
import 'ja_wrap_text.dart';

const quizAvatars = ['🐶', '🐱', '🐰', '🐻'];
const quizColors = [Colors.orange, Colors.pink, Colors.teal, Colors.indigo];

/// クイズの進行画面（出題 → 回答 → 発表）。対戦・復習・今日のチャレンジで共通。
/// 全問が終わると [finishedBuilder] の画面に切り替える。
class QuizPlay extends ConsumerStatefulWidget {
  const QuizPlay({
    super.key,
    required this.game,
    required this.finishedBuilder,
    this.onReveal,
  });

  final QuizGame game;
  final Widget Function(BuildContext context, QuizGame game) finishedBuilder;

  /// 1問の答えが出そろって発表になったときに呼ぶ。
  final void Function(QuizGame game)? onReveal;

  @override
  ConsumerState<QuizPlay> createState() => _QuizPlayState();
}

class _QuizPlayState extends ConsumerState<QuizPlay> {
  Timer? _timer;
  int _remaining = 0;

  QuizGame get game => widget.game;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    final limit = game.timeLimit;
    if (limit == null || game.phase != BattlePhase.answering) return;
    _remaining = limit;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) _submit(timedOut);
    });
  }

  void _submit(int index) {
    final before = game.phase;
    setState(() => game.answer(index, remaining: _remaining));
    _afterChange(before);
  }

  void _afterChange(BattlePhase before) {
    if (game.phase == BattlePhase.reveal && before != BattlePhase.reveal) {
      _timer?.cancel();
      widget.onReveal?.call(game);
    } else if (game.phase == BattlePhase.answering) {
      _startTimer();
    }
  }

  void _next() {
    setState(game.next);
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (game.phase == BattlePhase.finished) return widget.finishedBuilder(context, game);
    final l = AppLocalizations.of(context);
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
        if (!game.isSolo) _scoreBar(game),
        if (game.timed && !reveal) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            key: const Key('battle_timer'),
            value: (_remaining / game.timeLimit!).clamp(0, 1).toDouble(),
          ),
          Text(l.battleSecondsLeft(_remaining < 0 ? 0 : _remaining),
              textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
        ],
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
                color: quizColors[game.turn].withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${quizAvatars[game.turn]} ${l.battleTurnOf(game.names[game.turn])}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
            ),
          const SizedBox(height: 16),
          if (q.isTrueFalse)
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    key: const Key('battle_true'),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(80)),
                    onPressed: () => _submit(0),
                    child: Text('○ ${l.quizTrue}', style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonal(
                    key: const Key('battle_false'),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(80)),
                    onPressed: () => _submit(1),
                    child: Text('✕ ${l.quizFalse}', style: const TextStyle(fontSize: 22)),
                  ),
                ),
              ],
            )
          else
            for (var i = 0; i < q.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FilledButton.tonal(
                  key: Key('battle_opt_$i'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(60)),
                  onPressed: () => _submit(i),
                  child: Text('${String.fromCharCode(0x41 + i)}.  ${q.options[i]}',
                      textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
                ),
              ),
        ] else ...[
          Text(
            q.isTrueFalse
                ? (q.correct == 0 ? '○ ${l.quizTrue}' : '✕ ${l.quizFalse}')
                : l.battleCorrectIs(q.options[q.correct]),
            key: const Key('battle_answer'),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          for (var p = 0; p < game.playerCount; p++)
            ListTile(
              key: Key('battle_result_$p'),
              dense: true,
              leading: Text(quizAvatars[p], style: const TextStyle(fontSize: 24)),
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
            onPressed: _next,
            child: Text(game.isLastRound ? l.battleSeeResult : l.quizNext),
          ),
        ],
      ],
    );
  }

  Widget _scoreBar(QuizGame game) {
    final scores = game.scores;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 4,
      children: [
        for (var p = 0; p < game.playerCount; p++)
          Chip(
            key: Key('battle_score_$p'),
            avatar: Text(quizAvatars[p]),
            label: Text('${game.names[p]} ${scores[p]}'),
            side: BorderSide(color: quizColors[p]),
          ),
      ],
    );
  }
}
