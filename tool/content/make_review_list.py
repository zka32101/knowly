#!/usr/bin/env python3
"""人の事実確認・レビュー用の一覧を作る。docs/fact-check.md（チェックリスト）と docs/fact-check.csv（表計算用）。
使い方: python3 tool/content/make_review_list.py
出典がない・食い違いの注記がある雑学を先に並べる。確認したら trivia.json の verification と各言語の reviewStatus を更新する。"""
import csv, json, pathlib
root = pathlib.Path(__file__).resolve().parents[2]
items = json.loads((root / 'assets/trivia/trivia.json').read_text(encoding='utf-8'))['items']


def level(i, lang):
    lv = i['translations'][lang]['levels']
    return lv.get('adult') or lv.get('teen') or next(iter(lv.values()))


def priority(i):
    note = (i['verification'].get('note') or '')
    if not i['sources']:
        return 0  # 出典なし
    if len(note) > len('出典あり・人の確認待ち。'):
        return 1  # 出典と食い違い・未確認の点あり
    return 2


rows = sorted(items, key=lambda i: (priority(i), i['category'], i['id']))
label = {0: '出典なし', 1: '注記あり', 2: '出典あり'}
md = ['# 事実確認チェックリスト', '',
      f'雑学 {len(items)} 件。上から順に確認する（出典なし → 注記あり → 出典あり）。確認したら、`assets/trivia/trivia.json` の `verification`（status: verified / verifiedBy / verifiedAt）と、各言語の `reviewStatus`（reviewed / published、reviewedBy / reviewedAt）を更新する。',
      '', '- [ ] = 未確認　事実の確認と、各言語の訳のレビューは別（母語話者が見る）。', '']
with (root / 'docs/fact-check.csv').open('w', encoding='utf-8-sig', newline='') as f:
    w = csv.writer(f)
    w.writerow(['優先', 'id', 'カテゴリー', '日本語(大人)', 'English(adult)', '出典', '注記', '事実確認', '確認者', '確認日', 'ja', 'en', 'zh', 'ko', 'es'])
    for i in rows:
        ja, en = level(i, 'ja'), level(i, 'en')
        srcs = ' | '.join(f"{s['title']} {s['url']}" for s in i['sources'])
        note = (i['verification'].get('note') or '').replace('出典あり・人の確認待ち。', '').strip()
        w.writerow([label[priority(i)], i['id'], i['category'], f"{ja['title']}：{ja['body']}", f"{en['title']}: {en['body']}",
                    srcs, note, '', '', '', '', '', '', '', ''])
last = None
for i in rows:
    p = priority(i)
    if p != last:
        md += ['', f'## {label[p]}', '']
        last = p
    ja, en = level(i, 'ja'), level(i, 'en')
    md.append(f"- [ ] **{i['id']}**（{i['category']}）{ja['title']}")
    md.append(f"  - {ja['body']}")
    md.append(f"  - {en['body']}")
    for s in i['sources']:
        md.append(f"  - 出典: [{s['title']}]({s['url']})（{s['license']}）")
    note = (i['verification'].get('note') or '').replace('出典あり・人の確認待ち。', '').strip()
    if note:
        md.append(f'  - 注記: {note}')
(root / 'docs/fact-check.md').write_text('\n'.join(md) + '\n', encoding='utf-8')
print(len(rows), 'items', {label[k]: sum(1 for i in items if priority(i) == k) for k in (0, 1, 2)})
