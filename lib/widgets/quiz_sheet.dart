import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/quiz.dart';
import 'ja_wrap_text.dart';

/// ○×クイズ。結果は保存しない（採点・ランキングなし）。
Future<void> showQuizSheet(
  BuildContext context, {
  required QuizItem quiz,
  required String language,
  required String explanation,
}) {
  final q = quiz.forLanguage(language);
  if (q == null) return Future.value();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _QuizBody(question: q, explanation: explanation, language: language),
  );
}

class _QuizBody extends StatefulWidget {
  const _QuizBody({required this.question, required this.explanation, required this.language});
  final ({String statement, bool answer}) question;
  final String explanation;
  final String language;

  @override
  State<_QuizBody> createState() => _QuizBodyState();
}

class _QuizBodyState extends State<_QuizBody> {
  bool? _picked;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final picked = _picked;
    final language = widget.language;
    final correct = picked != null && picked == widget.question.answer;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.quizTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            WrapText(widget.question.statement,
                wordWrap: language == 'ja',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall),
            const SizedBox(height: 24),
            if (picked == null)
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      key: const Key('quiz_true'),
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(72)),
                      onPressed: () => setState(() => _picked = true),
                      child: Text('○ ${l.quizTrue}', style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonal(
                      key: const Key('quiz_false'),
                      style:
                          FilledButton.styleFrom(minimumSize: const Size.fromHeight(72)),
                      onPressed: () => setState(() => _picked = false),
                      child: Text('✕ ${l.quizFalse}', style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                ],
              )
            else ...[
              Row(
                key: const Key('quiz_result'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    correct ? Icons.check_circle : Icons.cancel,
                    size: 40,
                    color: correct ? Colors.green : theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(correct ? l.quizCorrect : l.quizWrong,
                      style: theme.textTheme.headlineMedium),
                ],
              ),
              const SizedBox(height: 12),
              WrapText(widget.explanation,
                  wordWrap: language == 'ja',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.quizNext),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
