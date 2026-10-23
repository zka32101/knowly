import '../models/trivia.dart';

/// FNV-1a(32bit)。`String.hashCode` はプラットフォーム間で一致する保証がないため自前で計算する。
int fnv1a(String input) {
  var hash = 0x811c9dc5;
  for (final unit in input.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash;
}

/// 32bit のビット混ぜ（MurmurHash3 の fmix32）。FNV-1a の結果は、似た文字列どうしで大小の順序が
/// 保たれやすいので、日替わりの並べ替えにはこれを通して順序を散らす。
int mix32(int h) {
  h &= 0xffffffff;
  h ^= h >> 16;
  h = (h * 0x85ebca6b) & 0xffffffff;
  h ^= h >> 13;
  h = (h * 0xc2b2ae35) & 0xffffffff;
  h ^= h >> 16;
  return h;
}

/// 現地日付の通し番号（タイムゾーンに依存せず、年月日だけで決まる）。
int dayNumber(DateTime day) =>
    DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/ 86400000;

/// その日の雑学を決定的に選ぶ。同じ候補なら入力順に関係なく同じ結果になり、
/// 候補数ぶんの日数は重複しない。
Trivia? pickForDay(List<Trivia> pool, DateTime day, {String salt = 'knowly'}) {
  if (pool.isEmpty) return null;
  final order = [...pool]..sort((a, b) {
      final c = fnv1a('${a.id}$salt').compareTo(fnv1a('${b.id}$salt'));
      return c != 0 ? c : a.id.compareTo(b.id);
    });
  return order[dayNumber(day) % order.length];
}

/// その日の雑学を選ぶ関数。既定は [pickForDay]。季節・記念日を考慮するものに差し替えられる。
typedef DayPicker = Trivia? Function(List<Trivia> pool, DateTime day);

/// 今日から過去 [days] 日ぶんのフィード（新しい順、重複は除く）。
List<Trivia> feedFor(List<Trivia> pool, DateTime today, int days, {DayPicker? picker}) {
  final pick = picker ?? pickForDay;
  final seen = <String>{};
  final out = <Trivia>[];
  for (var i = 0; i < days; i++) {
    final day = DateTime(today.year, today.month, today.day - i);
    final item = pick(pool, day);
    if (item != null && seen.add(item.id)) out.add(item);
  }
  return out;
}
