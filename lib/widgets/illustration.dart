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
  'ant': '🐜', 'dragonfly': '🪽', 'firefly': '✨', 'bee': '🐝', 'cicada': '🪲',
  'mosquito': '🦟', 'spider': '🕷️', 'beetle': '🪲', 'dungbeetle': '🪲',
  'silkworm': '🐛', 'train': '🚄', 'plane': '✈️', 'wright': '🛩️', 'subway': '🚇',
  'ship': '🚢', 'rocket': '🚀', 'maglev': '🚅', 'window': '🪟', 'iss': '🛰️',
  'container': '📦', 'watermelon': '🍉', 'cacao': '🍫', 'rice': '🍚', 'carrot': '🥕',
  'peanut': '🥜', 'pineapple': '🍍', 'apple': '🍎', 'wasabi': '🌿', 'popcorn': '🍿',
  'strawberry': '🍓',
  'penguin': '🐧', 'owl': '🦉', 'camel': '🐫', 'sloth': '🦥', 'salmon': '🐟',
  'squirrel': '🐿️', 'bat': '🦇', 'ladybug': '🐞', 'cricket': '🦗', 'bicycle': '🚲',
  'airplane': '✈️', 'snow': '❄️', 'maple': '🍁', 'tree': '🌳', 'sunflower': '🌻',
  'fog': '🌫️',
  'hail': '🧊',
  'wind': '🌬️',
  'typhoon': '🌀',
  'seahorse': '🐴',
  'whale': '🐋',
  'jellyfish': '🪼',
  'coral': '🪸',
  'marathon': '🏃',
  'basketball': '🏀',
  'rings': '🏅',
  'pingpong': '🏓',
  'zero': '0️⃣',
  'pi': '⭕',
  'triangle': '🔺',
  'prime': '2️⃣',
  'piano': '🎹',
  'theremin': '👋',
  'tuning': '🎼',
  'beethoven': '🎼',
  'hand': '✋', 'brain': '🧠', 'eye': '👁️',
};

/// 絵の id から、仮の絵文字を返す（共有画像など、ウィジェット以外で使う）。
String emojiForIllustration(String id) => _emoji[id] ?? '💡';

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
