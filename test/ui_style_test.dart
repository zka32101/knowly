import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/app.dart';
import 'package:knowly/l10n/app_localizations_ja.dart';
import 'package:knowly/l10n/ja_styles.dart';
import 'package:knowly/l10n/knowly_localizations.dart';
import 'package:knowly/models/age_band.dart';

final _kanji = RegExp(r'[一-鿿]');
final _hira = RegExp(r'[぀-ゟ]');

/// ARB のうち、ひらがなだけで書かれた文言（Kids の表記）のキー。
List<String> _hiraganaKeys() {
  final arb = jsonDecode(File('lib/l10n/app_ja.arb').readAsStringSync()) as Map<String, dynamic>;
  return [
    for (final e in arb.entries)
      if (!e.key.startsWith('@') &&
          e.value is String &&
          !_kanji.hasMatch(e.value as String) &&
          _hira.hasMatch(e.value as String))
        e.key,
  ];
}

Set<String> _overridden(String source, String className) {
  final start = source.indexOf('class $className');
  final next = source.indexOf('\nclass ', start + 1);
  final body = source.substring(start, next < 0 ? source.length : next);
  return {
    for (final m in RegExp(r'String (?:get )?(\w+)').allMatches(body)) m.group(1)!,
  };
}

void main() {
  final keys = _hiraganaKeys();
  final generated = File('lib/l10n/ja_styles.dart').readAsStringSync();

  test('モード → 表記: Kids=kids、Junior=junior、Teen/Adult/未選択=adult', () {
    expect(uiStyleFor(AgeBand.kids), UiStyle.kids);
    expect(uiStyleFor(AgeBand.junior), UiStyle.junior);
    expect(uiStyleFor(AgeBand.teen), UiStyle.adult);
    expect(uiStyleFor(AgeBand.adult), UiStyle.adult);
    expect(uiStyleFor(null), UiStyle.adult);
  });

  test('ひらがなの文言は、すべて Junior と Adult の表記が用意されている', () {
    expect(keys.length, greaterThan(150));
    for (final cls in ['AppLocalizationsJaJunior', 'AppLocalizationsJaAdult']) {
      final have = _overridden(generated, cls);
      expect(keys.where((k) => !have.contains(k)), isEmpty, reason: '$cls に足りないキー');
    }
  });

  test('Teen/Adult の表記は、漢字・カタカナまじりで、ひらがなの分かち書きではない', () {
    final adult = AppLocalizationsJaAdult();
    final base = AppLocalizationsJa();
    expect(adult.battleTitle, 'クイズ対戦');
    expect(base.battleTitle, 'クイズたいせん');
    expect(adult.tabPlay, '遊ぶ');
    expect(base.tabPlay, 'あそぶ');
    expect(adult.battleSoloScore(3, 5), '5問中3問正解');
    expect(adult.mascotNext(4, 'ひよこ'), 'あと4で「ひよこ」に成長');
    expect(adult.zukanFound(2, 60), '2 / 60 発見');
    expect(adult.quizCorrect, '正解！');
    // 日本語どうしの間にスペースがない（プレースホルダーのある文言は除く）
    final spaced = RegExp(r'[぀-ヿ一-鿿] [぀-ヿ一-鿿]');
    for (final s in [adult.hubCollectIntro, adult.battleHandHint, adult.reviewNone, adult.recapMsgSome]) {
      expect(spaced.hasMatch(s), isFalse, reason: s);
    }
  });

  test('Junior の表記: ひらがなのまま、ことばの間のスペースだけ取る', () {
    final junior = AppLocalizationsJaJunior();
    expect(junior.battlePlayers, 'なんにんであそぶ？');
    expect(junior.battleTurnOf('ハナ'), 'ハナのばん');
    expect(junior.battleSoloScore(3, 5), '3 / 5 もんせいかい！');
    // 数字や英字の前後のスペースは残す
    expect(junior.mascotNext(5, 'ひよこ'), 'あと 5 で「ひよこ」になるよ');
    expect(junior.zukanFound(2, 60), '2 / 60 みつけた');
  });

  test('Kids（基本）の表記は、分かち書きのひらがな', () {
    final kids = AppLocalizationsJa();
    expect(kids.battlePlayers, 'なんにんで あそぶ？');
    expect(kids.battleTurnOf('ハナ'), 'ハナの ばん');
  });

  test('Adult の表記は、基本と同じ意味の文言で、プレースホルダーの数が同じ', () {
    // ja_adult.tsv の文言のプレースホルダーが、基本の文言と同じ（実行時に落ちないように）
    final arb = jsonDecode(File('lib/l10n/app_ja.arb').readAsStringSync()) as Map<String, dynamic>;
    final ph = RegExp(r'\{(\w+)\}');
    for (final line in File('tool/ja_adult.tsv').readAsLinesSync()) {
      if (line.trim().isEmpty) continue;
      final i = line.indexOf('\t');
      final k = line.substring(0, i);
      final v = line.substring(i + 1);
      expect(arb.containsKey(k), isTrue, reason: k);
      expect({for (final m in ph.allMatches(v)) m.group(1)}, {for (final m in ph.allMatches(arb[k] as String)) m.group(1)},
          reason: k);
    }
  });
}
