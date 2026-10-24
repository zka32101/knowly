import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../logic/glossary.dart';
import '../state/providers.dart';
import '../state/settings.dart';

/// 本文の中の難しいことばに点線の下線をつけ、タップすると説明の画面（`/word/:id`）を開く。
/// 同じことばは、最初の1か所だけ。説明のないことばは、ふつうの文字のまま。
class GlossaryText extends ConsumerStatefulWidget {
  const GlossaryText(this.text,
      {super.key, this.style, this.textAlign, this.showHint = false});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  /// リンクがあるとき、「線のついたことばをタップ」の案内を下に出す。
  final bool showHint;

  @override
  ConsumerState<GlossaryText> createState() => _GlossaryTextState();
}

class _GlossaryTextState extends ConsumerState<GlossaryText> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    final lang = ref.watch(contentLanguageProvider);
    final entries = ref.watch(triviaRepositoryProvider).glossary;
    final segments = segmentGlossary(widget.text, entries, lang);
    final base = widget.style ?? DefaultTextStyle.of(context).style;
    final linkStyle = base.copyWith(
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
      decorationStyle: TextDecorationStyle.dotted,
      decorationColor: Theme.of(context).colorScheme.primary,
    );

    final spans = <InlineSpan>[];
    for (final seg in segments) {
      final id = seg.entryId;
      if (id == null) {
        spans.add(TextSpan(text: seg.text));
        continue;
      }
      final recognizer = TapGestureRecognizer()..onTap = () => context.push('/word/$id');
      _recognizers.add(recognizer);
      spans.add(TextSpan(text: seg.text, style: linkStyle, recognizer: recognizer));
    }

    final rich = Text.rich(
      key: const Key('glossary_text'),
      TextSpan(style: base, children: spans),
      textAlign: widget.textAlign,
    );
    final hasLink = segments.any((s) => s.entryId != null);
    if (!widget.showHint || !hasLink) return rich;
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rich,
        const SizedBox(height: 8),
        Text(l.wordHint,
            key: const Key('glossary_hint'),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.outline)),
      ],
    );
  }
}
