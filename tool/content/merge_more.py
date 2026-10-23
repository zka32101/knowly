#!/usr/bin/env python3
"""うわさ・今日は何の日・自由研究・なぜ？チェーン・辞典の追加分の翻訳を取り込む（draft）。
使い方: python3 tool/content/merge_more.py <more_zh.json> ..."""
import json, pathlib, sys
root = pathlib.Path(__file__).resolve().parents[2]
meta = {'reviewStatus': 'draft', 'reviewedBy': None, 'reviewedAt': None}


def load(n):
    p = root / 'assets/trivia' / n
    return p, json.loads(p.read_text(encoding='utf-8'))


files = {n: load(n + '.json') for n in ['myths', 'calendar', 'projects', 'why_chains', 'glossary']}
for f in sys.argv[1:]:
    lang = pathlib.Path(f).stem.split('_')[-1]
    d = json.loads(pathlib.Path(f).read_text(encoding='utf-8'))
    for n in ['myths', 'calendar', 'projects']:
        for i in files[n][1]['items']:
            t = d[n].get(i['id'])
            if t:
                i['translations'][lang] = {**meta, **t}
    for l in files['why_chains'][1]['links']:
        t = d['why'].get(f"{l['from']}>{l['to']}")
        if t:
            l[lang] = t
    for i in files['glossary'][1]['items']:
        t = d['glossary'].get(i['id'])
        if t and lang != 'en':
            i[lang] = t
    print(lang, 'merged')
for p, d in files.values():
    p.write_text(json.dumps(d, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
