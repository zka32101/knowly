import 'package:flutter/material.dart';

/// 共有画像のわく。固定の配色で、端末のテーマ（ダーク）に左右されない。
/// [accent] で、レア度などの色を変えられる。
class ShareFrame extends StatelessWidget {
  const ShareFrame({
    super.key,
    required this.appName,
    required this.children,
    this.colors = const [Color(0xFFFFF4D6), Color(0xFFFFE0B2)],
    this.border,
  });

  final String appName;
  final List<Widget> children;
  final List<Color> colors;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(24),
        border: border == null ? null : Border.all(color: border!, width: 4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...children,
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text('🦉 $appName',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF8D6E63))),
          ),
        ],
      ),
    );
  }
}

const _ink = Color(0xFF3E2723);
const _inkSoft = Color(0xFF6D4C41);

Widget _center(Widget w) => Center(child: w);

/// 大きな絵文字（または記号）の見出し。
Widget bigEmoji(String text, {double size = 64}) =>
    _center(Text(text, style: TextStyle(fontSize: size)));

Widget cardTitle(String text) => Text(text,
    textAlign: TextAlign.center,
    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _ink));

Widget cardBody(String text, {double size = 15, bool center = true}) => Text(text,
    textAlign: center ? TextAlign.center : TextAlign.start,
    style: TextStyle(fontSize: size, height: 1.5, color: _inkSoft));

Widget cardBig(String text) => Text(text,
    textAlign: TextAlign.center,
    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: _ink));

/// 行（名前と値）。ランキングや、ふりかえりの数字に使う。
Widget cardRow(String left, String right) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(left, style: const TextStyle(fontSize: 15, color: _ink))),
          Text(right,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _ink)),
        ],
      ),
    );

const gap8 = SizedBox(height: 8);
const gap12 = SizedBox(height: 12);
