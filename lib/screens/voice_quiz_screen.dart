import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../logic/quiz_game.dart';
import '../logic/readings.dart';
import '../services/tts.dart';
import '../state/settings.dart';
import 'quiz_battle_screen.dart';

/// 声に出して読む短い決まり文句（本文の言語ごと）。
const _spoken = {
  'ja': (
    trueFalse: 'ほんと？ それとも うそ？',
    correct: 'せいかい！',
    wrong: 'ざんねん！',
    answerIs: 'こたえは',
    done: 'おしまい！',
    score: 'もん せいかい',
  ),
  'en': (
    trueFalse: 'True, or false?',
    correct: 'Correct!',
    wrong: 'Not quite!',
    answerIs: 'The answer is',
    done: 'All done!',
    score: 'correct',
  ),
};

const voiceQuizSize = 10;

/// 耳で遊ぶクイズ: 問題を読み上げ、大きなボタンで答える（○×・選択式）。答えのあとは、結果と解説も読み上げる。
/// 運転中以外の「ながら」や、まだ字が読めない子どもにも。
class VoiceQuizScreen extends ConsumerStatefulWidget {
  const VoiceQuizScreen({super.key});

  @override
  ConsumerState<VoiceQuizScreen> createState() => _VoiceQuizScreenState();
}

class _VoiceQuizScreenState extends ConsumerState<VoiceQuizScreen> {
  late final TtsService _tts;
  late QuizGame? _game = _deal();
  int _gen = 0;
  int? _picked;

  String get _lang => ref.read(contentLanguageProvider);
  ({String trueFalse, String correct, String wrong, String answerIs, String done, String score})
      get _words => _spoken[_lang] ?? _spoken['en']!;

  QuizGame? _deal() {
    final pool = ref.read(battlePoolProvider);
    if (pool.isEmpty) return null;
    return QuizGame(
      names: const ['-'],
      questions: pickQuestions(pool, voiceQuizSize, ref.read(quizRandomProvider)),
    );
  }

  @override
  void initState() {
    super.initState();
    _tts = ref.read(ttsProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) => _readQuestion());
  }

  @override
  void dispose() {
    _gen++;
    unawaited(_tts.stop());
    super.dispose();
  }

  /// 順に読み上げる。途中で別の操作があったら（世代が変わったら）そこでやめる。
  Future<void> _say(List<String> parts) async {
    final gen = ++_gen;
    await _tts.stop();
    for (final p in parts) {
      if (gen != _gen || !mounted) return;
      await _tts.speakAndWait(stripReadings(p), language: _lang, rate: 0.4);
    }
  }

  void _readQuestion() {
    final game = _game;
    if (game == null || game.phase != BattlePhase.answering) return;
    final q = game.question;
    final parts = [q.statement];
    if (q.isTrueFalse) {
      parts.add(_words.trueFalse);
    } else {
      for (var i = 0; i < q.options.length; i++) {
        parts.add('${String.fromCharCode(0x41 + i)}。${q.options[i]}');
      }
    }
    unawaited(_say(parts));
  }

  void _answer(int index) {
    final game = _game;
    if (game == null || game.phase != BattlePhase.answering) return;
    setState(() {
      _picked = index;
      game.answer(index);
    });
    final ok = game.isCorrect(0)!;
    ref.read(settingsProvider.notifier).recordQuizAnswer(correct: ok);
    final q = game.question;
    final correctText = q.isTrueFalse ? (q.correct == 0 ? '○' : '✕') : q.options[q.correct];
    unawaited(_say([
      ok ? _words.correct : _words.wrong,
      '${_words.answerIs} $correctText',
      q.explanation,
    ]));
  }

  void _next() {
    final game = _game;
    if (game == null) return;
    setState(() {
      _picked = null;
      game.next();
    });
    if (game.phase == BattlePhase.finished) {
      unawaited(_say(['${_words.done} ${game.scores[0]} ${_words.score}']));
    } else {
      _readQuestion();
    }
  }

  void _restart() {
    setState(() {
      _picked = null;
      _game = _deal();
    });
    _readQuestion();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final game = _game;

    Widget body;
    if (game == null) {
      body = Center(child: Text(l.battleNoQuestions));
    } else if (game.phase == BattlePhase.finished) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.battleSoloScore(game.scores[0], game.questions.length),
                  key: const Key('voice_final'), style: theme.textTheme.headlineSmall),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('voice_again'),
                onPressed: _restart,
                child: Text(l.battleAgain),
              ),
              TextButton(
                key: const Key('voice_exit'),
                onPressed: () => context.pop(),
                child: Text(l.battleExit),
              ),
            ],
          ),
        ),
      );
    } else {
      final q = game.question;
      final reveal = game.phase == BattlePhase.reveal;
      body = ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(l.battleRoundOf(game.round + 1, game.questions.length),
              key: const Key('voice_round'),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge),
          const SizedBox(height: 12),
          // 聞きなおすボタン（大きく）
          Center(
            child: IconButton.filledTonal(
              key: const Key('voice_replay'),
              iconSize: 56,
              tooltip: l.voiceReplay,
              icon: const Icon(Icons.volume_up),
              onPressed: reveal ? null : _readQuestion,
            ),
          ),
          const SizedBox(height: 12),
          Text(q.statement,
              key: const Key('voice_statement'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          if (q.isTrueFalse)
            Row(
              children: [
                for (final i in [0, 1])
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: i == 1 ? 12 : 0),
                      child: FilledButton(
                        key: Key(i == 0 ? 'voice_true' : 'voice_false'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(110),
                          backgroundColor: _color(theme, reveal, i, q.correct),
                        ),
                        onPressed: reveal ? null : () => _answer(i),
                        child: Text(i == 0 ? '○' : '✕', style: const TextStyle(fontSize: 56)),
                      ),
                    ),
                  ),
              ],
            )
          else
            for (var i = 0; i < q.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FilledButton(
                  key: Key('voice_opt_$i'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(72),
                    backgroundColor: _color(theme, reveal, i, q.correct),
                  ),
                  onPressed: reveal ? null : () => _answer(i),
                  child: Text('${String.fromCharCode(0x41 + i)}.  ${q.options[i]}',
                      textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
                ),
              ),
          if (reveal) ...[
            const SizedBox(height: 12),
            Icon(game.isCorrect(0)! ? Icons.check_circle : Icons.cancel,
                key: Key(game.isCorrect(0)! ? 'voice_ok' : 'voice_ng'),
                size: 48,
                color: game.isCorrect(0)! ? Colors.green : theme.colorScheme.error),
            const SizedBox(height: 8),
            Text(q.explanation, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('voice_next'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(64)),
              onPressed: _next,
              child: Text(game.isLastRound ? l.battleSeeResult : l.quizNext,
                  style: const TextStyle(fontSize: 20)),
            ),
          ],
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.voiceQuizTitle)),
      body: SafeArea(child: body),
    );
  }

  /// 発表のあと、正解のボタンを緑に、選んだ間違いを赤にする。
  Color? _color(ThemeData theme, bool reveal, int index, int correct) {
    if (!reveal) return null;
    if (index == correct) return Colors.green.shade600;
    if (index == _picked) return theme.colorScheme.error;
    return theme.colorScheme.surfaceContainerHighest;
  }
}
