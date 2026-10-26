#!/usr/bin/env python3
"""AI イラスト用の指示文（プロンプト）の一覧 docs/illustration_prompts.md を作り、
assets/illustrations/ にできあがっている画像を、lib/widgets/illustration.dart の一覧に反映する。
使い方:
  python3 tool/content/make_illustration_prompts.py          # 指示文の一覧を作る
  python3 tool/content/make_illustration_prompts.py --sync   # assets/illustrations/*.png を、アプリの一覧（illustrationImages）に反映する"""
import json, pathlib, re, sys
root = pathlib.Path(__file__).resolve().parents[2]
items = json.loads((root / 'assets/trivia/trivia.json').read_text(encoding='utf-8'))['items']
dart = (root / 'lib/widgets/illustration.dart').read_text(encoding='utf-8')
emoji = dict(re.findall(r"'([a-z0-9_]+)':\s*'([^']+)'", dart.split('const _emoji')[1].split('};')[0]))
imgdir = root / 'assets/illustrations'

if '--sync' in sys.argv:
    have = sorted(p.stem for p in imgdir.glob('*.png'))
    new = 'final Set<String> illustrationImages = {' + ''.join(f"'{h}', " for h in have).rstrip(', ') + '};'
    out = re.sub(r'final Set<String> illustrationImages = \{[^}]*\};', new, dart, count=1)
    (root / 'lib/widgets/illustration.dart').write_text(out, encoding='utf-8')
    print(len(have), 'images synced')
    sys.exit()

STYLE = ("flat, friendly children's-book illustration, soft rounded shapes, gentle pastel colors with a warm "
         "off-white background removed (transparent PNG), single centered subject, thick soft outline, "
         "simple shading, cute but accurate, no text, no letters, no logos, no watermark, no people's faces "
         "unless the subject is a person, square 1:1, 1024x1024")
by_ill = {}
for i in items:
    ill = i['illustration']
    en = i['translations']['en']['levels']
    lv = en.get('kids') or en.get('teen') or next(iter(en.values()))
    by_ill.setdefault(ill, []).append((i['id'], lv['title'], lv['body']))
md = ['# AI イラストの指示文', '',
      '仮の絵文字を、本番の絵に差しかえるための指示文の一覧。画像生成の AI（好きなもの）に、「共通のスタイル」と、各行の「題材」を渡す。',
      '', '## 共通のスタイル（毎回つける）', '', f'> {STYLE}', '',
      '## 進めかた', '',
      '1. 各行の題材に、共通のスタイルをつけて生成する。1つずつ見て、**子どもに安全か**（こわくない、とがりすぎない、文字や商標が入っていない）を確認する。',
      '2. 背景を透明にした PNG（1024×1024 でよい）を、`assets/illustrations/<絵の id>.png` に置く。ファイル名は、下の表の「絵の id」と同じ。',
      '3. `python3 tool/content/make_illustration_prompts.py --sync` を実行すると、置いた画像が、アプリの一覧（`illustrationImages`）に入る。画像がない絵は、いままでどおり絵文字で出る。',
      '4. `flutter test` と、実機（またはウェブ）で見た目を確認する。',
      '5. 生成した画像の**権利（利用規約・商用利用）**を、使う AI のサービスで確認し、ストアの掲載ルールに合わせる。',
      '', '## 絵の一覧', '', f'{len(by_ill)} 点（仮の絵文字 → 本番の絵）。', '',
      '| 絵の id | いまの絵文字 | 題材（雑学のタイトル） | 指示文（題材の部分） |', '|---|---|---|---|']
for ill in sorted(by_ill):
    facts = by_ill[ill]
    titles = ' / '.join(t for _, t, _ in facts[:2])
    subject = facts[0][1].rstrip('!?.')
    prompt = f"{subject}. Illustrate the key idea of this fact: {facts[0][2]}"
    md.append(f"| `{ill}` | {emoji.get(ill, '💡')} | {titles} | {prompt} |")
(root / 'docs/illustration_prompts.md').write_text('\n'.join(md) + '\n', encoding='utf-8')
print(len(by_ill), 'illustrations')
