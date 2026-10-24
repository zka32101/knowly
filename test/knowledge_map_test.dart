import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/logic/knowledge_map.dart';
import 'package:knowly/models/trivia.dart';

List<Trivia> _items() {
  final raw = jsonDecode(File('assets/trivia/trivia.json').readAsStringSync())
      as Map<String, dynamic>;
  return (raw['items'] as List)
      .map((e) => Trivia.fromJson(e as Map<String, dynamic>))
      .toList();
}

void main() {
  final items = _items();
  final links = buildLinks(items);

  test('つながりは両方向（片方にしか書かれていなくても）', () {
    for (final e in links.entries) {
      for (final other in e.value) {
        expect(links[other], contains(e.key), reason: '${e.key} ↔ $other');
      }
    }
  });

  test('自分自身や、存在しない雑学にはつながらない', () {
    final ids = items.map((t) => t.id).toSet();
    for (final e in links.entries) {
      expect(e.value, isNot(contains(e.key)));
      expect(ids.containsAll(e.value), isTrue);
    }
  });

  test('ほとんどの雑学に、つながりがある', () {
    final linked = links.values.where((v) => v.isNotEmpty).length;
    expect(linked, greaterThan(items.length * 0.8));
  });

  test('neighborsOf: 見たものを先に出し、表示できないものは除き、数を絞る', () {
    final center = links.entries.firstWhere((e) => e.value.length >= 3).key;
    final all = links[center]!;
    final seenOne = all.last;
    final n = neighborsOf(center, links, links.keys.toSet(), seen: {seenOne});
    expect(n.first, seenOne);
    expect(n.toSet(), all);
    final hidden = all.first;
    final visible = links.keys.toSet()..remove(hidden);
    expect(neighborsOf(center, links, visible), isNot(contains(hidden)));
    expect(neighborsOf(center, links, links.keys.toSet(), limit: 2), hasLength(2));
    expect(neighborsOf('nope', links, links.keys.toSet()), isEmpty);
  });
}
