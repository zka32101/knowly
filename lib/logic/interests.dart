import '../models/trivia.dart';
import 'daily_pick.dart';
import 'search.dart';

/// 登録した関心事。ジャンル・利用シーン・キーワードのどれかに当てはまる雑学を「あなたの関心」に出す。
class Interests {
  const Interests({
    this.categories = const {},
    this.scenes = const {},
    this.keywords = const [],
  });

  final Set<String> categories;
  final Set<String> scenes;
  final List<String> keywords;

  bool get isEmpty => categories.isEmpty && scenes.isEmpty && keywords.isEmpty;
}

/// 関心事に当てはまるか。キーワードは、そろえた本文 [entry] に含まれるか（1語でも一致すれば当てはまる）。
bool matchesInterests(Trivia t, Interests interests, SearchEntry? entry) {
  if (interests.categories.contains(t.category)) return true;
  if (t.scenes.any(interests.scenes.contains)) return true;
  if (entry != null) {
    final text = '${entry.title} ${entry.body}';
    for (final k in interests.keywords) {
      final folded = foldText(k).trim();
      if (folded.isNotEmpty && text.contains(folded)) return true;
    }
  }
  return false;
}

/// 「あなたの関心」に出す雑学を、その日ごとに決定的に選ぶ（日が変わると顔ぶれが変わる）。
/// [exclude] は今日の雑学など、重複させたくないもの。
List<Trivia> pickInterests({
  required List<Trivia> pool,
  required Interests interests,
  required Map<String, SearchEntry> index,
  required DateTime day,
  required Set<String> exclude,
  required int count,
}) {
  if (interests.isEmpty || count <= 0) return const [];
  final matching = [
    for (final t in pool)
      if (!exclude.contains(t.id) && matchesInterests(t, interests, index[t.id])) t,
  ];
  final daySeed = fnv1a('interest-${dayNumber(day)}');
  int key(Trivia t) => mix32(fnv1a(t.id) ^ daySeed);
  matching.sort((a, b) {
    final c = key(a).compareTo(key(b));
    return c != 0 ? c : a.id.compareTo(b.id);
  });
  return matching.take(count).toList();
}
