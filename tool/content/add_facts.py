#!/usr/bin/env python3
"""facts_batch*.py の雑学を assets/trivia/trivia.json に追加する（すべて draft・未検証）。
使い方: python3 tool/content/add_facts.py   （追加済みの id は飛ばす）"""
import json, re, sys, pathlib
root = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(pathlib.Path(__file__).parent))
import facts_batch1
facts = list(facts_batch1.FACTS)
try:
    import facts_batch2
    facts += facts_batch2.FACTS
except ImportError:
    pass

path = root / 'assets/trivia/trivia.json'
doc = json.loads(path.read_text(encoding='utf-8'))
have = {i['id'] for i in doc['items']}
strip = lambda s: re.sub(r'（[ぁ-んー]+）', '', s)


def levels_ja(t):
    if len(t) == 4:
        t = [t[0], t[2], t[3]]
    k, j, a = t
    return {'kids': k, 'junior': j, 'teen': (strip(j[0]), strip(j[1])), 'adult': a}


def levels(d):
    return {k: {'title': v[0], 'body': v[1]} for k, v in d.items()}


for f in facts:
    if f['id'] in have:
        continue
    en = dict(zip(['kids', 'junior', 'teen', 'adult'], f['en']))
    doc['items'].append({
        'id': f['id'], 'category': f['cat'], 'scenes': f['scenes'], 'minAgeBand': 'kids',
        'sensitivity': 'none', 'regions': [], 'illustration': f['ill'],
        'translations': {
            'ja': {'reviewStatus': 'draft', 'levels': levels(levels_ja(f['ja'])), 'reviewedBy': None, 'reviewedAt': None},
            'en': {'reviewStatus': 'draft', 'levels': levels(en), 'reviewedBy': None, 'reviewedAt': None},
        },
        'seasons': f['seasons'], 'dates': [], 'timeOfDay': [], 'status': 'active', 'version': 1,
        'createdAt': '2026-10-23', 'updatedAt': '2026-10-23', 'excludeRegions': [],
        'keywords': f['kw'], 'related': f['rel'], 'sources': [],
        'verification': {'status': 'unverified', 'verifiedBy': None, 'verifiedAt': None, 'note': None},
        'volatility': 'stable', 'contentFlags': [],
        'vocab': [{'en': e, 'ja': j, 'kanji': k} for e, j, k in f['vocab']],
    })
by = {i['id']: i for i in doc['items']}
missing = sorted({r for i in doc['items'] for r in i['related'] if r not in by})
if missing:
    sys.exit('related に、存在しない id がある: ' + ', '.join(missing))
for i in doc['items']:  # related は、おたがいに結ぶ（テストで見張る）
    for r in list(i['related']):
        if i['id'] not in by[r]['related']:
            by[r]['related'].append(i['id'])
path.write_text(json.dumps(doc, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print(len(doc['items']), 'items')
