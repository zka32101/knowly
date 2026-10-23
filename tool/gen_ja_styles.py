#!/usr/bin/env python3
"""日本語の表記（Kids / Junior / Teen・Adult）の派生クラス lib/l10n/ja_styles.dart を作り直す。

- 対象は、app_ja.arb のうち「ひらがなだけで書かれた文言」（Kids 向けの表記）。
- Teen/Adult の表記は、tool/ja_adult.tsv（キー<TAB>文言）に書く。{name} のような ICU の置き換えは、そのまま書く。
- Junior の表記は、基本の文言から、日本語どうしの間のスペースを取って作る（自動）。
使い方: python3 tool/gen_ja_styles.py  （先に flutter gen-l10n を実行しておく）
"""
import json
import re
import sys
from pathlib import Path

root = Path(__file__).resolve().parent.parent
arb = json.loads((root / 'lib/l10n/app_ja.arb').read_text(encoding='utf-8'))
kanji = re.compile(r'[一-鿿]')
hira = re.compile(r'[぀-ゟ]')
cands = [k for k, v in arb.items()
         if not k.startswith('@') and isinstance(v, str) and not kanji.search(v) and hira.search(v)]

adult = {}
for line in (root / 'tool/ja_adult.tsv').read_text(encoding='utf-8').splitlines():
    if line.strip():
        k, v = line.split('\t', 1)
        adult[k] = v

missing = [k for k in cands if k not in adult]
if missing:
    sys.exit('tool/ja_adult.tsv に足りないキー: ' + ', '.join(missing))

src = (root / 'lib/l10n/app_localizations_ja.dart').read_text(encoding='utf-8')


def sig(k):
    if re.search(r'String get %s =>' % re.escape(k), src):
        return ('get', None)
    m = re.search(r'String %s\(([^)]*)\) \{' % re.escape(k), src)
    assert m, k
    return ('method', m.group(1))


def esc(s):
    return s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')


def interp(v):
    out = ''
    for p in re.split(r'(\{\w+\})', v):
        m = re.fullmatch(r'\{(\w+)\}', p)
        out += ('${' + m.group(1) + '}') if m else esc(p)
    return out


adult_members, junior_members = [], []
for k in cands:
    kind, params = sig(k)
    text = interp(adult[k])
    if kind == 'get':
        adult_members.append(f"  @override\n  String get {k} => '{text}';\n")
        junior_members.append(f"  @override\n  String get {k} => _jr(super.{k});\n")
    else:
        names = [p.strip().split(' ')[-1] for p in params.split(',')]
        adult_members.append(f"  @override\n  String {k}({params}) {{\n    return '{text}';\n  }}\n")
        junior_members.append(
            f"  @override\n  String {k}({params}) => _jr(super.{k}({', '.join(names)}));\n")

header = """// 日本語の「表記」を、モード（年代）で変えるための、AppLocalizationsJa の派生クラス。
// - AppLocalizationsJa（基本）: ひらがなと分かち書き（Kids）
// - AppLocalizationsJaJunior: 基本から、ことばの間のスペースを取った表記（Junior）
// - AppLocalizationsJaAdult: 漢字まじりの、ふつうの表記（Teen / Adult）
// このファイルは tool/gen_ja_styles.py で作る。ひらがなの文言を足したら、tool/ja_adult.tsv にも書いて作り直す。
// ignore_for_file: type=lint

import 'app_localizations_ja.dart';

/// 日本語どうしの間にあるスペースを取る（数字やアルファベットの前後のスペースは残す）。
final _jaSpace = RegExp(
    r'(?<=[\\u3040-\\u30ff\\u4e00-\\u9fff！？。、「」…ー])[ \\u3000]+(?=[\\u3040-\\u30ff\\u4e00-\\u9fff！？。、「」…ー])');
String _jr(String s) => s.replaceAll(_jaSpace, '');

"""
out = (header
       + "class AppLocalizationsJaJunior extends AppLocalizationsJa {\n  AppLocalizationsJaJunior([super.locale]);\n\n"
       + "\n".join(junior_members) + "}\n\n"
       + "class AppLocalizationsJaAdult extends AppLocalizationsJa {\n  AppLocalizationsJaAdult([super.locale]);\n\n"
       + "\n".join(adult_members) + "}\n")
(root / 'lib/l10n/ja_styles.dart').write_text(out, encoding='utf-8')
print('generated', len(cands), 'keys')
