import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/trivia_repository.dart';
import '../l10n/app_localizations.dart';
import '../models/age_band.dart';
import '../models/myth.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/ja_wrap_text.dart';

/// 「ほんと？うそ？」: よくある勘違いを○×で確かめる。結果は保存しない（採点・ランキングなし）。
class MythScreen extends ConsumerStatefulWidget {
  const MythScreen({super.key});

  @override
  ConsumerState<MythScreen> createState() => _MythScreenState();
}

class _MythScreenState extends ConsumerState<MythScreen> {
  int _index = 0;
  int _correct = 0;
  bool? _picked;
  bool _finished = false;

  void _answer(bool pick, Myth m) {
    setState(() {
      _picked = pick;
      if (pick == m.answer) _correct++;
    });
  }

  void _next(int total) {
    setState(() {
      _picked = null;
      if (_index + 1 >= total) {
        _finished = true;
      } else {
        _index++;
      }
    });
  }

  void _restart() => setState(() {
        _index = 0;
        _correct = 0;
        _picked = null;
        _finished = false;
      });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final deck = ref.watch(mythDeckProvider);
    final band = ref.watch(settingsProvider.select((s) => s.ageBand)) ?? AgeBand.adult;
    final lang = ref.watch(contentLanguageProvider);
    final theme = Theme.of(context);
    final wordWrap = band.isChild && lang == 'ja';

    Widget body;
    if (deck.isEmpty) {
      body = Center(child: Text(l.mythNone));
    } else if (_finished) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(l.mythResult(_correct, deck.length),
                  key: const Key('myth_result'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('myth_again'),
                onPressed: _restart,
                child: Text(l.mythAgain),
              ),
            ],
          ),
        ),
      );
    } else {
      final m = deck[_index];
      final text = m.textFor(band, lang, allowDraft: kAllowDraftContent)!;
      final picked = _picked;
      final correct = picked != null && picked == m.answer;
      final verdict = m.answer ? l.quizTrue : l.quizFalse;
      final repo = ref.watch(triviaRepositoryProvider);
      final factAvailable = m.factId != null &&
          ref.watch(allEligibleProvider).any((t) => t.id == m.factId) &&
          repo.byId(m.factId!) != null;
      body = ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(l.mythProgress(_index + 1, deck.length),
              key: const Key('myth_progress'),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: WrapText(text.statement,
                  key: const Key('myth_statement'),
                  wordWrap: wordWrap,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall),
            ),
          ),
          const SizedBox(height: 24),
          if (picked == null)
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    key: const Key('myth_true'),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(72)),
                    onPressed: () => _answer(true, m),
                    child: Text('○ ${l.quizTrue}', style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonal(
                    key: const Key('myth_false'),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(72)),
                    onPressed: () => _answer(false, m),
                    child: Text('✕ ${l.quizFalse}', style: const TextStyle(fontSize: 22)),
                  ),
                ),
              ],
            )
          else ...[
            Row(
              key: const Key('myth_verdict'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(correct ? Icons.check_circle : Icons.cancel,
                    size: 40,
                    color: correct ? Colors.green : theme.colorScheme.error),
                const SizedBox(width: 8),
                Text(correct ? l.quizCorrect : l.quizWrong,
                    style: theme.textTheme.headlineMedium),
              ],
            ),
            const SizedBox(height: 12),
            Text(l.mythAnswerIs(verdict),
                key: const Key('myth_answer_is'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            WrapText(text.explanation,
                key: const Key('myth_explanation'),
                wordWrap: wordWrap,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge),
            const SizedBox(height: 20),
            if (factAvailable)
              OutlinedButton(
                key: const Key('myth_read'),
                onPressed: () => context.push('/detail/${m.factId}'),
                child: Text(l.mythRead),
              ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('myth_next'),
              onPressed: () => _next(deck.length),
              child: Text(_index + 1 >= deck.length ? l.mythFinish : l.mythNext),
            ),
          ],
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.mythsTitle)),
      body: SafeArea(child: body),
    );
  }
}
