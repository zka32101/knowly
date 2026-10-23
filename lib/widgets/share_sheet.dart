import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../services/share.dart';
import '../state/settings.dart';

/// 外へ共有できるのは Teen/Adult だけ（Kids/Junior は共有しない）。
final canShareProvider = Provider<bool>((ref) {
  final band = ref.watch(settingsProvider.select((s) => s.ageBand));
  return band != null && band.isTeenOrAdult;
});

/// 共有する画像（[card]）のプレビューを出し、「共有」で PNG にして、[text] といっしょに共有する。
Future<void> showShareCardSheet(
  BuildContext context, {
  required Widget card,
  required String text,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ShareCardDialog(card: card, text: text),
  );
}

class _ShareCardDialog extends ConsumerStatefulWidget {
  const _ShareCardDialog({required this.card, required this.text});
  final Widget card;
  final String text;

  @override
  ConsumerState<_ShareCardDialog> createState() => _ShareCardDialogState();
}

class _ShareCardDialogState extends ConsumerState<_ShareCardDialog> {
  final _boundary = GlobalKey();
  bool _busy = false;

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      final render = _boundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await render.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) return;
      await ref.read(shareServiceProvider).shareImage(data.buffer.asUint8List(), text: widget.text);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      contentPadding: const EdgeInsets.all(16),
      content: SingleChildScrollView(
        child: RepaintBoundary(key: _boundary, child: widget.card),
      ),
      actions: [
        TextButton(
          key: const Key('share_cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.privacyDeleteCancel),
        ),
        FilledButton.icon(
          key: const Key('share_confirm'),
          icon: const Icon(Icons.ios_share),
          label: Text(l.shareImage),
          onPressed: _busy ? null : _share,
        ),
      ],
    );
  }
}

/// 「画像でシェア」ボタン。Teen/Adult にだけ出す。押すと、[card] のプレビューを出す。
class ShareButton extends ConsumerWidget {
  const ShareButton({
    super.key,
    this.buttonKey,
    required this.card,
    required this.text,
    this.compact = false,
  });

  /// 中のボタンのキー（共有できない年代では、ボタンごと出ないので、見つからない）。
  final Key? buttonKey;
  final Widget card;
  final String text;

  /// true なら、アイコンだけ（アプリバーなど）。
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(canShareProvider)) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    void open() => showShareCardSheet(context, card: card, text: text);
    if (compact) {
      return IconButton(
        key: buttonKey ?? const Key('share_button'),
        tooltip: l.shareImage,
        icon: const Icon(Icons.ios_share),
        onPressed: open,
      );
    }
    return OutlinedButton.icon(
      key: buttonKey ?? const Key('share_button'),
      icon: const Icon(Icons.ios_share),
      label: Text(l.shareImage),
      onPressed: open,
    );
  }
}
