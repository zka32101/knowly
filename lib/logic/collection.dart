import 'dart:math';

import '../models/trivia.dart';
import 'daily_pick.dart';

/// 雑学カードのレア度。id から決まる（同じ雑学はずっと同じレア度）。
enum Rarity {
  common(1),
  rare(2),
  superRare(3);

  const Rarity(this.stars);
  final int stars;
}

/// 割合: ふつう 60% / レア 30% / スーパーレア 10%。
Rarity rarityOf(String id) {
  final n = fnv1a('rarity:$id') % 100;
  if (n < 60) return Rarity.common;
  if (n < 90) return Rarity.rare;
  return Rarity.superRare;
}

/// カプセルで出す雑学を選ぶ。先にレア度を割合で決め、その中から選ぶ。
/// まだ見ていない雑学があれば、8割はそちらから選ぶ（ずかんが埋まりやすいように）。
/// 選んだレア度の雑学がなければ、ほかのレア度から選ぶ。
Trivia? pickCapsule(List<Trivia> pool, Set<String> seen, Random random) {
  if (pool.isEmpty) return null;
  final roll = random.nextInt(100);
  final want = roll < 60 ? Rarity.common : (roll < 90 ? Rarity.rare : Rarity.superRare);
  var candidates = [for (final t in pool) if (rarityOf(t.id) == want) t];
  if (candidates.isEmpty) candidates = pool;
  final unseen = [for (final t in candidates) if (!seen.contains(t.id)) t];
  if (unseen.isNotEmpty && random.nextInt(100) < 80) {
    return unseen[random.nextInt(unseen.length)];
  }
  return candidates[random.nextInt(candidates.length)];
}
