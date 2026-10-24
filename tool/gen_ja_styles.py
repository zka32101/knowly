#!/usr/bin/env python3
"""日本語の表記（Kids / Junior / Teen・Adult）の派生クラス lib/l10n/ja_styles.dart を作り直す。

- 対象は、app_ja.arb のうち「ひらがなだけで書かれた文言」（Kids 向けの表記）。
- Teen/Adult の表記は、tool/ja_adult.tsv（キー<TAB>文言）に書く。{name} のような ICU の置き換えは、そのまま書く。
- Teen の表記は、Adult の表記を土台に、言い回し（です・ます → だよ・しよう）だけを tool/ja_teen.tsv で変える。
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

teen = {}
for line in (root / 'tool/ja_teen.tsv').read_text(encoding='utf-8').splitlines():
    if line.strip():
        k, v = line.split('\t', 1)
        teen[k] = v
unknown = [k for k in teen if k not in adult]
if unknown:
    sys.exit('tool/ja_teen.tsv のキーが ja_adult.tsv にない: ' + ', '.join(unknown))

# Junior（小学生）の表記: ひらがなのうち、小学1〜3年で習う漢字だけで書ける、よく使うことばを漢字にする。
# 長いことばを先に（たとえば「まいにち」を「にち」より先に）。数字のあとの「にち・もん」なども漢字にする。
JUNIOR_WORDS = [
    ('まいにち', '毎日'), ('こんしゅう', '今週'), ('せんしゅう', '先週'), ('いっしゅうかん', '1週間'),
    ('1しゅうかん', '1週間'), ('きょう', '今日'), ('あした', '明日'),
    ('あそぶ', '遊ぶ'), ('あそんだ', '遊んだ'), ('あそんで', '遊んで'), ('あそべる', '遊べる'), ('あそぼう', '遊ぼう'),
    ('あつめる', '集める'), ('もんだい', '問題'),
    ('みつけた', '見つけた'), ('みるほど', '見るほど'), ('みると', '見ると'), ('みる', '見る'),
    ('よんだ', '読んだ'), ('よんで', '読んで'), ('よむ', '読む'), ('きく', '聞く'),
    ('ほんとう', '本当'), ('ほんと', '本当'), ('こたえ', '答え'), ('ことば', '言葉'),
    ('はやく', '早く'), ('あたらしく', '新しく'), ('ぜんぶ', '全部'), ('ともだち', '友だち'),
    ('おとな', '大人'), ('こども', '子ども'), ('ひとつ', '一つ'), ('すこしずつ', '少しずつ'),
    ('いちばん', '一番'), ('あんぜん', '安全'), ('つかう', '使う'), ('はじめる', '始める'), ('おわる', '終わる'),
    ('かぞく', '家族'), ('からだ', '体'), ('むし', '虫'), ('たべもの', '食べ物'), ('のりもの', '乗り物'),
    ('どうぶつ', '動物'), ('ちり', '地理'), ('かがく', '科学'), ('がくしゅう', '学習'), ('ちゅうい', '注意'),
    ('ぜんもん', '全問'), ('もういちど', 'もう一度'), ('おなじ', '同じ'), ('しらなかった', '知らなかった'),
    ('しれたこと', '知れたこと'), ('しれた', '知れた'), ('しってた', '知ってた'), ('おくりません', '送りません'),
    ('つくっています', '作っています'), ('まわして', '回して'), ('でてくる', '出てくる'), ('だせる', '出せる'),
    ('そとには', '外には'), ('ひとり', '一人'),
    ('つぎ', '次'), ('まえ', '前'), ('いま', '今'), ('かち', '勝ち'),
]
JUNIOR_AFTER_DIGIT = [('にちかん', '日間'), ('しゅうかん', '週間'), ('にち', '日'), ('もん', '問'), ('かい', '回'), ('ふん', '分'), ('にん', '人'), ('てん', '点'), ('しょう', '勝'), ('びょう', '秒')]


def with_reading(kana, kj):
    """「漢字」に、すぐあとに「（よみ）」を付ける。送りがな・前後のかなは、そのまま残す。"""
    if not kanji.search(kj):
        return kj
    pre = 0
    while pre < min(len(kana), len(kj)) and kana[pre] == kj[pre]:
        pre += 1
    suf = 0
    while suf < min(len(kana), len(kj)) - pre and kana[-1 - suf] == kj[-1 - suf]:
        suf += 1
    core = kj[pre:len(kj) - suf]
    reading = kana[pre:len(kana) - suf]
    if not core or not reading or not re.fullmatch(r'[぀-ゟー]+', reading):
        return kj
    return kj[:pre] + core + '（' + reading + '）' + kj[len(kj) - suf:]


JUNIOR_READ_OVERRIDE = {'いっしゅうかん': '1週間（しゅうかん）'}
_pairs = [(a, JUNIOR_READ_OVERRIDE.get(a, with_reading(a, b))) for a, b in JUNIOR_WORDS]
JUNIOR_WORDS_RUBY = _pairs
junior_kanji = ''.join(sorted(set(ch for _, v in JUNIOR_WORDS + JUNIOR_AFTER_DIGIT for ch in v if kanji.match(ch))))

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


adult_members, junior_members, teen_members = [], [], []
for k in cands:
    kind, params = sig(k)
    text = interp(adult[k])
    if k in teen:
        ttext = interp(teen[k])
        if kind == 'get':
            teen_members.append(f"  @override\n  String get {k} => '{ttext}';\n")
        else:
            teen_members.append(f"  @override\n  String {k}({params}) {{\n    return '{ttext}';\n  }}\n")
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
// - AppLocalizationsJaJunior: 基本から、スペースを取り、小学1〜3年の漢字のことばを漢字にした表記（Junior）
// - AppLocalizationsJaTeen: 漢字まじりで、すこしくだけた言い回し（Teen）\n// - AppLocalizationsJaAdult: 漢字まじりの、ふつうの表記（Adult）
// このファイルは tool/gen_ja_styles.py で作る。ひらがなの文言を足したら、tool/ja_adult.tsv にも書いて作り直す。
// ignore_for_file: type=lint

import 'app_localizations_ja.dart';

/// 日本語どうしの間にあるスペースを取る（数字やアルファベットの前後のスペースは残す）。
final _jaSpace = RegExp(
    r'(?<=[\\u3040-\\u30ff\\u4e00-\\u9fff！？。、「」…ー（）])[ \\u3000]+(?=[\\u3040-\\u30ff\\u4e00-\\u9fff！？。、「」…ー（）])');
/// ことばの前が「ひらがな」でなく、後ろが助詞・記号・終わりのとき、1つのことばとみなす
/// （「おおきく」の中の「きく」や、「います」の中の「いま」を、漢字にしないため）。
const _wordAfter = r'(?=[はがをにへでとのもやかよねなご、。！？…「」\\s]|$|[0-9A-Za-z])';

final _juniorWordRegexps = [
  for (final (from, to) in _juniorWords)
    (RegExp('(?<![\\u3040-\\u309f])$from$_wordAfter'), to),
];

final _juniorDigitRegexps = [
  for (final (from, to) in _juniorAfterDigit) (RegExp('(?<=[0-9])$from$_wordAfter'), to),
];

/// Junior の読み仮名（「漢字（よみ）」の「（よみ）」）を付けるか。設定で切りかえる（画面の文言を作り直す前に決める）。
bool juniorRubyEnabled = true;

final _rubyRegexp = RegExp('（[ぁ-んー]+）');

/// Junior: 先に、スペースで分かれたことばごとに漢字にして、そのあとスペースを取る。
String _jr(String s) {
  var t = s;
  for (final (re, to) in _juniorWordRegexps) {
    t = t.replaceAll(re, to);
  }
  for (final (re, to) in _juniorDigitRegexps) {
    t = t.replaceAll(re, to);
  }
  t = t.replaceAll(_jaSpace, '');
  return juniorRubyEnabled ? t : t.replaceAll(_rubyRegexp, '');
}

/// Junior の表記で漢字にする、よく使うことば（小学1〜3年で習う漢字だけ）。
const _juniorWords = <(String, String)>[
@@WORDS@@];

/// 数字のあとの「にち・もん」など。
const _juniorAfterDigit = <(String, String)>[
@@DIGITS@@];

/// Junior の表記に出てくる漢字（テストで、小学1〜3年の漢字だけか確かめる）。
const juniorKanji = '@@KANJI@@';

"""
header = header.replace('@@WORDS@@', ''.join(f"  ('{a}', '{b}'),\n" for a, b in JUNIOR_WORDS_RUBY))
header = header.replace('@@DIGITS@@', ''.join(f"  ('{a}', '{with_reading(a, b)}'),\n" for a, b in JUNIOR_AFTER_DIGIT))
header = header.replace('@@KANJI@@', junior_kanji)
out = (header
       + "class AppLocalizationsJaJunior extends AppLocalizationsJa {\n  AppLocalizationsJaJunior([super.locale]);\n\n"
       + "\n".join(junior_members) + "}\n\n"
       + "class AppLocalizationsJaAdult extends AppLocalizationsJa {\n  AppLocalizationsJaAdult([super.locale]);\n\n"
       + "\n".join(adult_members) + "}\n\n"
       + "/// Teen: Adult の表記と同じ漢字まじりで、言い回しだけ、すこしくだけた（だよ・しよう）。\n"
       + "class AppLocalizationsJaTeen extends AppLocalizationsJaAdult {\n  AppLocalizationsJaTeen([super.locale]);\n\n"
       + "\n".join(teen_members) + "}\n")
(root / 'lib/l10n/ja_styles.dart').write_text(out, encoding='utf-8')
print('generated', len(cands), 'keys')
