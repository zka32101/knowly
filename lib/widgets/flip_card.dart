import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/trivia.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import 'illustration.dart';
import 'ja_wrap_text.dart';

/// 今日の雑学のめくりカード。おもては「ほんと？うそ？」（クイズがなければタイトル）、
/// タップするとくるっと裏返って、答えと本文が出る。めくると、その雑学を見たことになる。
class FlipTodayCard extends ConsumerStatefulWidget {
  const FlipTodayCard({
    super.key,
    required this.item,
    required this.level,
    this.wordWrap = false,
  });

  final Trivia item;
  final TriviaLevel level;
  final bool wordWrap;

  @override
  ConsumerState<FlipTodayCard> createState() => _FlipTodayCardState();
}

class _FlipTodayCardState extends ConsumerState<FlipTodayCard> {
  bool _flipped = false;

  @override
  void didUpdateWidget(FlipTodayCard old) {
    super.didUpdateWidget(old);
    // 別の雑学（日付が変わった・言語を変えた）になったら、おもてに戻す。
    if (old.item.id != widget.item.id) _flipped = false;
  }

  void _toggle() {
    setState(() => _flipped = !_flipped);
    if (_flipped) ref.read(settingsProvider.notifier).markSeen(widget.item.id);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lang = ref.watch(contentLanguageProvider);
    final quiz = ref.watch(triviaRepositoryProvider).quizFor(widget.item.id)?.forLanguage(lang);

    Widget front() => Column(
          key: const Key('flip_front'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(categoryLabel(l, widget.item.category),
                      style: theme.textTheme.labelSmall),
                ),
                IconButton(
                  key: const Key('flip_open_detail'),
                  tooltip: l.flipDetail,
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => context.push('/detail/${widget.item.id}'),
                ),
              ],
            ),
            Center(child: TriviaIllustration(id: widget.item.illustration, size: 56)),
            const SizedBox(height: 8),
            if (quiz != null)
              Center(
                child: Text(l.quizTitle,
                    style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
              ),
            WrapText(quiz?.statement ?? widget.level.title,
                key: const Key('flip_prompt'),
                wordWrap: widget.wordWrap,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Center(
              child: Text(l.flipHint,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
            ),
          ],
        );

    Widget back() => Column(
          key: const Key('flip_back'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (quiz != null)
              Center(
                child: Text(
                  quiz.answer ? '○ ${l.quizTrue}' : '✕ ${l.quizFalse}',
                  key: const Key('flip_answer'),
                  style: theme.textTheme.headlineSmall,
                ),
              ),
            const SizedBox(height: 8),
            WrapText(widget.level.title,
                wordWrap: widget.wordWrap, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            WrapText(widget.level.body,
                wordWrap: widget.wordWrap, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                key: const Key('flip_detail_button'),
                icon: const Icon(Icons.arrow_forward),
                label: Text(l.flipDetail),
                onPressed: () => context.push('/detail/${widget.item.id}'),
              ),
            ),
          ],
        );

    return TweenAnimationBuilder<double>(
      tween: Tween(end: _flipped ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, v, _) {
        final showBack = v > 0.5;
        final angle = v * math.pi;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: Card(
            key: const Key('flip_card'),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _toggle,
              child: Padding(
                padding: const EdgeInsets.all(16),
                // 裏側は鏡文字にならないよう、さらに半回転させて描く。
                child: showBack
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: back())
                    : front(),
              ),
            ),
          ),
        );
      },
    );
  }
}
