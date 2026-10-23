import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../logic/mascot.dart';
import '../logic/quiz_game.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/ja_wrap_text.dart';
import '../widgets/mascot_card.dart';
import 'quiz_battle_screen.dart';

/// 1ゲームの問題数。
const swipeRoundSize = 10;

/// スワイプ ほんと？うそ？: カードを右へ（ほんと）・左へ（うそ）。連続で答えて、れんぞく正解をのばす。
class SwipeQuizScreen extends ConsumerStatefulWidget {
  const SwipeQuizScreen({super.key});

  @override
  ConsumerState<SwipeQuizScreen> createState() => _SwipeQuizScreenState();
}

class _SwipeQuizScreenState extends ConsumerState<SwipeQuizScreen> {
  late List<BattleQuestion> _cards = _deal();
  int _index = 0;
  int _correct = 0;
  int _combo = 0;
  int _bestCombo = 0;
  bool? _lastOk;
  BattleQuestion? _lastCard;

  List<BattleQuestion> _deal() {
    final pool = [for (final q in ref.read(battlePoolProvider)) if (q.isTrueFalse) q];
    return pickQuestions(pool, swipeRoundSize, ref.read(quizRandomProvider));
  }

  void _restart() => setState(() {
        _cards = _deal();
        _index = 0;
        _correct = 0;
        _combo = 0;
        _bestCombo = 0;
        _lastOk = null;
        _lastCard = null;
      });

  /// [saidTrue]: 右（ほんと）にしたか。
  void _answer(bool saidTrue) {
    final card = _cards[_index];
    final ok = (card.correct == 0) == saidTrue;
    ref.read(settingsProvider.notifier).recordQuizAnswer(correct: ok);
    setState(() {
      _lastCard = card;
      _lastOk = ok;
      if (ok) {
        _correct++;
        _combo++;
        if (_combo > _bestCombo) _bestCombo = _combo;
      } else {
        _combo = 0;
      }
      _index++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lang = ref.watch(contentLanguageProvider);
    final band = ref.watch(settingsProvider.select((s) => s.ageBand));
    final wrap = lang == 'ja' && (band?.isChild ?? false);
    final stage = mascotStageFor(ref.watch(mascotPointsProvider));
    final finished = _cards.isNotEmpty && _index >= _cards.length;

    Widget body;
    if (_cards.isEmpty) {
      body = Center(child: Text(l.battleNoQuestions));
    } else if (finished) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MascotFace(
                  stage: stage,
                  size: 64,
                  mood: _correct * 2 >= _cards.length ? MascotMood.happy : MascotMood.sad),
              const SizedBox(height: 8),
              Text(l.battleSoloScore(_correct, _cards.length),
                  key: const Key('swipe_final'), style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(l.swipeBestCombo(_bestCombo), style: theme.textTheme.titleMedium),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('swipe_again'),
                onPressed: _restart,
                child: Text(l.battleAgain),
              ),
              TextButton(
                key: const Key('swipe_exit'),
                onPressed: () => context.pop(),
                child: Text(l.battleExit),
              ),
            ],
          ),
        ),
      );
    } else {
      final card = _cards[_index];
      body = Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(l.battleRoundOf(_index + 1, _cards.length),
                key: const Key('swipe_round'), style: theme.textTheme.labelLarge),
            if (_combo >= 2)
              Text(l.swipeCombo(_combo),
                  key: const Key('swipe_combo'),
                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.deepOrange)),
            const SizedBox(height: 12),
            Expanded(
              child: Dismissible(
                key: ValueKey('${card.factId}_$_index'),
                direction: DismissDirection.horizontal,
                background: _hint(Alignment.centerLeft, Colors.green, '○ ${l.quizTrue}'),
                secondaryBackground: _hint(Alignment.centerRight, Colors.red, '✕ ${l.quizFalse}'),
                onDismissed: (dir) => _answer(dir == DismissDirection.startToEnd),
                child: Card(
                  key: const Key('swipe_card'),
                  elevation: 4,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l.quizTitle, style: theme.textTheme.labelLarge),
                          const SizedBox(height: 16),
                          WrapText(card.statement,
                              key: const Key('swipe_statement'),
                              wordWrap: lang == 'ja',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall),
                          const SizedBox(height: 24),
                          Text(l.swipeHint,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: theme.colorScheme.outline)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    key: const Key('swipe_false'),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                    onPressed: () => _answer(false),
                    child: Text('✕ ${l.quizFalse}', style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const Key('swipe_true'),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                    onPressed: () => _answer(true),
                    child: Text('○ ${l.quizTrue}', style: const TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            ),
            if (_lastCard != null && _lastOk != null) ...[
              const SizedBox(height: 12),
              _Feedback(card: _lastCard!, ok: _lastOk!, wrap: wrap, stage: stage),
            ],
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.swipeTitle)),
      body: SafeArea(child: body),
    );
  }

  Widget _hint(Alignment alignment, Color color, String text) => Container(
        alignment: alignment,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(12)),
        child: Text(text, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      );
}

/// 直前の答えの結果（せいかい／ざんねん と、解説）。
class _Feedback extends StatelessWidget {
  const _Feedback({required this.card, required this.ok, required this.wrap, required this.stage});
  final BattleQuestion card;
  final bool ok;
  final bool wrap;
  final MascotStage stage;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Row(
      key: Key(ok ? 'swipe_result_ok' : 'swipe_result_ng'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MascotFace(
            stage: stage, size: 32, mood: ok ? MascotMood.happy : MascotMood.sad),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${ok ? l.quizCorrect : l.quizWrong}  ${card.correct == 0 ? '○' : '✕'}',
                style: theme.textTheme.titleSmall?.copyWith(
                    color: ok ? Colors.green.shade700 : theme.colorScheme.error),
              ),
              WrapText(card.explanation, wordWrap: wrap, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
