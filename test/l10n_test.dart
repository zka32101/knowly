import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/state/settings.dart';

Map<String, dynamic> _arb(String lang) =>
    jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync()) as Map<String, dynamic>;

Set<String> _placeholders(String s) =>
    RegExp(r'\{(\w+)\}').allMatches(s).map((m) => m.group(1)!).toSet();

void main() {
  final template = _arb('ja');
  final keys = template.keys.where((k) => !k.startsWith('@')).toList();

  test('対応する画面の言語は5つ（ja, en, zh, ko, es）で、本文は ja/en だけ', () {
    expect(supportedLanguageCodes, ['ja', 'en', 'zh', 'ko', 'es']);
    expect(contentLanguageCodes, ['ja', 'en']);
    expect(resolveContentLanguage('ja'), 'ja');
    for (final c in ['en', 'zh', 'ko', 'es', null, 'fr']) {
      expect(resolveContentLanguage(c), 'en', reason: '$c');
    }
    expect(resolveLanguage('fr'), 'en');
    expect(resolveLanguage('ko'), 'ko');
  });

  for (final lang in supportedLanguageCodes) {
    group('ARB: $lang', () {
      final arb = _arb(lang);

      test('テンプレート（ja）と同じキーがすべてあり、余分なキーがない', () {
        final mine = arb.keys.where((k) => !k.startsWith('@')).toSet();
        expect(keys.where((k) => !mine.contains(k)), isEmpty, reason: '足りないキー');
        expect(mine.where((k) => !keys.contains(k)), isEmpty, reason: '余分なキー');
      });

      test('プレースホルダーがテンプレートと一致し、空の訳がない', () {
        for (final k in keys) {
          final v = arb[k] as String;
          expect(v.trim(), isNotEmpty, reason: k);
          expect(_placeholders(v), _placeholders(template[k] as String), reason: '$lang/$k');
        }
      });

      test('言語の名前は、その言語自身の表記', () {
        const own = {
          'ja': '日本語',
          'en': 'English',
          'zh': '简体中文',
          'ko': '한국어',
          'es': 'Español',
        };
        expect(arb['language${lang[0].toUpperCase()}${lang[1]}'], own[lang]);
      });
    });
  }

  test('ノウリーは日本語のアプリ名。ほかの言語は Knowly', () {
    expect(_arb('ja')['appName'], 'ノウリー');
    for (final l in ['en', 'zh', 'ko', 'es']) {
      expect(_arb(l)['appName'], 'Knowly', reason: l);
    }
  });
}
