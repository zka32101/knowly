import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../services/share.dart';
import 'illustration.dart';

/// 共有する画像の見た目。固定の配色で、端末のテーマに左右されない。
class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.illustration,
    required this.title,
    required this.body,
    required this.appName,
  });

  final String illustration;
  final String title;
  final String body;
  final String appName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF4D6), Color(0xFFFFE0B2)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: TriviaIllustration(id: illustration, size: 72)),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
          const SizedBox(height: 12),
          Text(body,
              style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF4E342E))),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: Text(appName,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF8D6E63))),
          ),
        ],
      ),
    );
  }
}

/// 共有画像のプレビューを出し、「共有」で PNG にして共有する。
Future<void> showShareSheet(
  BuildContext context, {
  required String illustration,
  required String title,
  required String body,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ShareDialog(illustration: illustration, title: title, body: body),
  );
}

class _ShareDialog extends ConsumerStatefulWidget {
  const _ShareDialog({required this.illustration, required this.title, required this.body});
  final String illustration;
  final String title;
  final String body;

  @override
  ConsumerState<_ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends ConsumerState<_ShareDialog> {
  final _boundary = GlobalKey();
  bool _busy = false;

  Future<void> _share(String appName) async {
    setState(() => _busy = true);
    try {
      final render = _boundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await render.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) return;
      await ref.read(shareServiceProvider).shareImage(
            data.buffer.asUint8List(),
            text: '${widget.title} - $appName',
          );
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
        child: RepaintBoundary(
          key: _boundary,
          child: ShareCard(
            key: const Key('share_card'),
            illustration: widget.illustration,
            title: widget.title,
            body: widget.body,
            appName: l.appName,
          ),
        ),
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
          onPressed: _busy ? null : () => _share(l.appName),
        ),
      ],
    );
  }
}
