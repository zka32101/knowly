import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';

/// 保護者ゲート。かけ算の答えを入力できた場合だけ true を返す。
/// 課金・外部リンク・モード変更の前に使う。
Future<bool> showParentalGate(BuildContext context, {Random? random}) async {
  final r = random ?? Random();
  final a = 3 + r.nextInt(7);
  final b = 3 + r.nextInt(7);
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => _GateDialog(a: a, b: b),
  );
  return result ?? false;
}

class _GateDialog extends StatefulWidget {
  const _GateDialog({required this.a, required this.b});
  final int a;
  final int b;

  @override
  State<_GateDialog> createState() => _GateDialogState();
}

class _GateDialogState extends State<_GateDialog> {
  final _controller = TextEditingController();
  bool _wrong = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (int.tryParse(_controller.text.trim()) == widget.a * widget.b) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _wrong = true);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.gateTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.gateDescription),
          const SizedBox(height: 16),
          Text('${widget.a} × ${widget.b} = ?',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          TextField(
            key: const Key('parental_gate_input'),
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: l.gateHint,
              errorText: _wrong ? l.gateWrong : null,
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.gateCancel)),
        FilledButton(onPressed: _submit, child: Text(l.gateOk)),
      ],
    );
  }
}
