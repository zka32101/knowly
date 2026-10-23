import 'package:flutter/material.dart';

/// 分かち書き（半角スペースで区切った日本語）を、単語の途中で改行せずに表示する。
/// Kids/Junior の日本語は「ぞうは ひくい おとを…」のように区切ってあるので、
/// 標準の Text だと「お/はなし」のように単語の途中で折り返してしまうのを防ぐ。
/// スペースがない文章（英語や大人向けの日本語）は、そのまま Text で表示する。
class WrapText extends StatelessWidget {
  const WrapText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
    this.wordWrap = false,
  });

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  /// true のとき、スペースで区切った単語単位で折り返す。
  final bool wordWrap;

  @override
  Widget build(BuildContext context) {
    if (!wordWrap || !text.contains(' ')) {
      return Text(text, style: style, textAlign: textAlign);
    }
    final effective = DefaultTextStyle.of(context).style.merge(style);
    final size = effective.fontSize ?? 14;
    final words = text.split(RegExp(r' +')).where((w) => w.isNotEmpty);
    return Semantics(
      label: text.replaceAll(' ', ''),
      excludeSemantics: true,
      child: Wrap(
        alignment: switch (textAlign) {
          TextAlign.center => WrapAlignment.center,
          TextAlign.end || TextAlign.right => WrapAlignment.end,
          _ => WrapAlignment.start,
        },
        spacing: size * 0.4,
        runSpacing: size * 0.25,
        children: [for (final w in words) Text(w, style: style)],
      ),
    );
  }
}
