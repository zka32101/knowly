import '../models/trivia.dart';

/// 雑学どうしの「つながり」（`related`）。片方にしか書かれていなくても、両方向につなぐ。
Map<String, Set<String>> buildLinks(Iterable<Trivia> items) {
  final ids = {for (final t in items) t.id};
  final links = <String, Set<String>>{for (final id in ids) id: <String>{}};
  for (final t in items) {
    for (final r in t.related) {
      if (!ids.contains(r) || r == t.id) continue;
      links[t.id]!.add(r);
      links[r]!.add(t.id);
    }
  }
  return links;
}

/// [center] とつながる雑学（[visible] に含まれるものだけ）。見たものを先に、そのあとは id 順。
List<String> neighborsOf(
  String center,
  Map<String, Set<String>> links,
  Set<String> visible, {
  Set<String> seen = const {},
  int limit = 8,
}) {
  final list = [
    for (final id in links[center] ?? const <String>{})
      if (visible.contains(id)) id,
  ]..sort((a, b) {
      final sa = seen.contains(a) ? 0 : 1;
      final sb = seen.contains(b) ? 0 : 1;
      return sa != sb ? sa.compareTo(sb) : a.compareTo(b);
    });
  return list.take(limit).toList();
}
