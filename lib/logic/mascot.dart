/// 相棒のキャラクター。雑学を読んだ数・知れた数で成長し、見た目（表情・かっこう）が変わる。
/// 連続日数は使わない（毎日やらないと戻る、という圧をかけないため。Kids/Junior にも出せる）。
class MascotStage {
  const MascotStage(this.id, this.emoji, this.threshold);
  final String id;

  /// 仮の絵。AI で作った画像に差し替える（`mascot_<id>`）。
  final String emoji;
  final int threshold;
}

const mascotStages = [
  MascotStage('egg', '🥚', 0),
  MascotStage('chick', '🐣', 5),
  MascotStage('chicklet', '🐥', 15),
  MascotStage('owl', '🦉', 40),
  MascotStage('professor', '🦉🎓', 100),
  MascotStage('king', '🦉👑', 250),
];

/// 成長のポイント: 開いた雑学1つにつき1点、「知らなかった」を覚えたら +2点。
int mascotPoints({required int seen, required int learned}) => seen + learned * 2;

MascotStage mascotStageFor(int points) {
  var current = mascotStages.first;
  for (final s in mascotStages) {
    if (points >= s.threshold) current = s;
  }
  return current;
}

MascotStage? nextMascotStage(int points) {
  for (final s in mascotStages) {
    if (points < s.threshold) return s;
  }
  return null;
}
