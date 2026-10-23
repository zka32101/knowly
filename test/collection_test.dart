import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/logic/collection.dart';
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

  test('レア度は id で決まり、いつも同じ', () {
    for (final t in items) {
      expect(rarityOf(t.id), rarityOf(t.id));
    }
  });

  test('レア度の割合がだいたい 60/30/10 で、3種類とも存在する', () {
    final counts = {for (final r in Rarity.values) r: 0};
    for (var i = 0; i < 5000; i++) {
      final r = rarityOf('fact_$i');
      counts[r] = counts[r]! + 1;
    }
    expect(counts[Rarity.common]! / 5000, closeTo(0.6, 0.04));
    expect(counts[Rarity.rare]! / 5000, closeTo(0.3, 0.04));
    expect(counts[Rarity.superRare]! / 5000, closeTo(0.1, 0.03));
    final real = items.map((t) => rarityOf(t.id)).toSet();
    expect(real.length, greaterThan(1)); // 実データにも複数のレア度がある
  });

  test('カプセル: 同じ乱数なら同じ結果。空のときは null', () {
    expect(pickCapsule(const [], {}, Random(1)), isNull);
    final a = pickCapsule(items, {}, Random(7))!;
    final b = pickCapsule(items, {}, Random(7))!;
    expect(a.id, b.id);
  });

  test('カプセル: まだ見ていない雑学が多めに出る', () {
    final seen = {for (final t in items.take(items.length - 5)) t.id};
    final unseenIds = items.skip(items.length - 5).map((t) => t.id).toSet();
    final random = Random(3);
    var unseenHits = 0;
    const n = 400;
    for (var i = 0; i < n; i++) {
      if (unseenIds.contains(pickCapsule(items, seen, random)!.id)) unseenHits++;
    }
    // 未見は全体の約8%だが、8割ねらうので、それより大きく増える（レア度の都合で全部は出ない）
    expect(unseenHits / n, greaterThan(0.3));
  });

  test('カプセル: 全部のレア度が出うる', () {
    final random = Random(11);
    final got = <Rarity>{};
    for (var i = 0; i < 600; i++) {
      got.add(rarityOf(pickCapsule(items, const {}, random)!.id));
    }
    expect(got, Rarity.values.toSet());
  });
}
