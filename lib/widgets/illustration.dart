import 'package:flutter/material.dart';

/// 仮のイラスト（絵文字）。AI 生成イラストができたら、`assets/illustrations/<id>.png` を
/// 用意してここを Image.asset に差し替える。
const _emoji = {
  'octopus': '🐙', 'honey': '🍯', 'banana': '🍌', 'venus': '🪐', 'shark': '🦈',
  'skeleton': '🦴', 'giraffe': '🦒', 'lightning': '⚡', 'otter': '🦦',
  'astronaut': '🧑‍🚀', 'ice': '🧊', 'mountain': '🏔️', 'wombat': '🐾', 'dna': '🧬',
  'flamingo': '🦩', 'moon': '🌙', 'butterfly': '🦋', 'cat': '🐱', 'sun': '☀️',
  'saturn': '🪐', 'tower': '🗼', 'heart': '❤️', 'bamboo': '🎋', 'crow': '🐦‍⬛',
  'rainbow': '🌈', 'elephant': '🐘', 'dolphin': '🐬', 'antarctica': '🧊',
  'koala': '🐨', 'japan': '🗾',
};

class TriviaIllustration extends StatelessWidget {
  const TriviaIllustration({super.key, required this.id, this.size = 48});

  final String id;
  final double size;

  @override
  Widget build(BuildContext context) => Text(
        _emoji[id] ?? '💡',
        style: TextStyle(fontSize: size),
        semanticsLabel: '',
      );
}
