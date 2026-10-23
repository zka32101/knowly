import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/models/content_flags.dart';

/// 雑学データ（assets/trivia/trivia.json）の情報管理ルール。
/// `reviewed` / `published` にするには、出典・検証・レビュー者の記録が必要（未確認のまま出荷しない）。
void main() {
  final doc = jsonDecode(File('assets/trivia/trivia.json').readAsStringSync())
      as Map<String, dynamic>;
  final items = (doc['items'] as List).cast<Map<String, dynamic>>();
  final ids = {for (final i in items) i['id'] as String};
  final isoDate = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  bool validMmDd(String s) {
    final p = s.split('-');
    if (p.length != 2) return false;
    final m = int.tryParse(p[0]);
    final d = int.tryParse(p[1]);
    if (m == null || d == null || m < 1 || m > 12 || d < 1 || d > 31) return false;
    return DateTime.utc(2024, m, d).month == m; // うるう年で存在する日か
  }

  test('ファイル全体の情報（スキーマ版・コンテンツ版・更新日）', () {
    expect(doc['schemaVersion'], 2);
    expect((doc['contentVersion'] as String), isNotEmpty);
    expect(doc['updatedAt'], matches(isoDate));
  });

  test('必須項目と値の範囲', () {
    for (final i in items) {
      final id = i['id'] as String;
      expect(id, matches(RegExp(r'^[a-z0-9_]+$')), reason: id);
      expect(['active', 'hidden', 'retired'], contains(i['status']), reason: id);
      expect(i['version'], isA<int>(), reason: id);
      expect(i['version'] as int, greaterThanOrEqualTo(1), reason: id);
      expect(i['createdAt'], matches(isoDate), reason: id);
      expect(i['updatedAt'], matches(isoDate), reason: id);
      expect((i['updatedAt'] as String).compareTo(i['createdAt'] as String),
          greaterThanOrEqualTo(0), reason: id);
      expect(['stable', 'changing'], contains(i['volatility']), reason: id);
      expect(['none', 'mild', 'adult-only'], contains(i['sensitivity']), reason: id);
    }
  });

  test('変わりうる雑学（changing）には、見直し期限がある', () {
    for (final i in items) {
      if (i['volatility'] == 'changing') {
        expect(i['reviewDueAt'], matches(isoDate), reason: i['id'] as String);
      }
    }
  });

  test('季節・時間帯・記念日の値が正しい', () {
    for (final i in items) {
      final id = i['id'] as String;
      for (final s in i['seasons'] as List) {
        expect(['spring', 'summer', 'autumn', 'winter'], contains(s), reason: id);
      }
      for (final t in i['timeOfDay'] as List) {
        expect(['morning', 'day', 'evening', 'night'], contains(t), reason: id);
      }
      for (final d in i['dates'] as List) {
        expect(validMmDd(d as String), isTrue, reason: '$id: $d');
      }
    }
  });

  test('国タグ: 2文字の大文字コードで、表示する国と除外する国が重ならない', () {
    final code = RegExp(r'^[A-Z]{2}$');
    for (final i in items) {
      final id = i['id'] as String;
      final regions = (i['regions'] as List).cast<String>();
      final exclude = (i['excludeRegions'] as List).cast<String>();
      for (final r in [...regions, ...exclude]) {
        expect(r, matches(code), reason: '$id: $r');
      }
      expect(regions.toSet().intersection(exclude.toSet()), isEmpty, reason: id);
      expect(regions.toSet().length, regions.length, reason: '$id: 重複');
    }
  });

  test('話題のタグ（contentFlags）は決められた値だけ', () {
    for (final i in items) {
      for (final f in i['contentFlags'] as List) {
        expect(validContentFlags, contains(f), reason: i['id'] as String);
      }
    }
  });

  test('検索キーワードと関連する雑学', () {
    for (final i in items) {
      final id = i['id'] as String;
      final kw = (i['keywords'] as List).cast<String>();
      expect(kw.length, greaterThanOrEqualTo(2), reason: '$id: 検索キーワード');
      expect(kw.every((k) => k.trim().isNotEmpty), isTrue, reason: id);
      for (final r in i['related'] as List) {
        expect(ids, contains(r), reason: '$id → $r');
        expect(r, isNot(id), reason: '$id: 自分自身');
      }
      expect((i['related'] as List).toSet().length, (i['related'] as List).length,
          reason: '$id: 重複');
    }
  });

  test('出典の形式', () {
    for (final i in items) {
      for (final s in (i['sources'] as List).cast<Map<String, dynamic>>()) {
        final id = i['id'] as String;
        expect((s['title'] as String?)?.trim(), isNotEmpty, reason: id);
        expect(s['url'] as String, startsWith('https://'), reason: id);
        expect((s['license'] as String?)?.trim(), isNotEmpty, reason: id);
        expect(s['accessedAt'], matches(isoDate), reason: id);
      }
    }
  });

  test('reviewed / published にするには、出典・検証・レビューの記録が必要', () {
    for (final i in items) {
      final id = i['id'] as String;
      final v = i['verification'] as Map<String, dynamic>;
      expect(['unverified', 'verified'], contains(v['status']), reason: id);
      final translations = (i['translations'] as Map<String, dynamic>).cast<String, Map<String, dynamic>>();
      for (final e in translations.entries) {
        final tr = e.value;
        expect(['draft', 'reviewed', 'published'], contains(tr['reviewStatus']),
            reason: '$id/${e.key}');
        if (tr['reviewStatus'] != 'draft') {
          expect(v['status'], 'verified', reason: '$id: 事実の検証が未了');
          expect(v['verifiedBy'], isNotNull, reason: '$id: 検証者');
          expect(v['verifiedAt'], matches(isoDate), reason: '$id: 検証日');
          expect((i['sources'] as List), isNotEmpty, reason: '$id: 出典がない');
          expect(tr['reviewedBy'], isNotNull, reason: '$id/${e.key}: レビュー者');
          expect(tr['reviewedAt'], matches(isoDate), reason: '$id/${e.key}: レビュー日');
        }
      }
    }
  });

  test('配信してよい雑学（active）には、ja・en の翻訳がある', () {
    for (final i in items) {
      if (i['status'] != 'active') continue;
      final translations = i['translations'] as Map<String, dynamic>;
      expect(translations.keys, containsAll(['ja', 'en']), reason: i['id'] as String);
    }
  });
}
