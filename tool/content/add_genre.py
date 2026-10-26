#!/usr/bin/env python3
"""新しいジャンルの雑学（new_<genre>.json）を assets/trivia に取り込む。
各ファイル: {"items":[雑学], "quiz":[○×], "choice":[選択式], "illustrations":{絵の id: 絵文字}}
使い方: python3 tool/content/add_genre.py <new_weather.json> ...   （追加済みの id は飛ばす）"""
import json, pathlib, re, sys
root = pathlib.Path(__file__).resolve().parents[2]
D = root / 'assets/trivia'


def load(n):
    return json.loads((D / n).read_text(encoding='utf-8'))


def save(n, d):
    (D / n).write_text(json.dumps(d, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


trivia, quiz, choice = load('trivia.json'), load('quiz.json'), load('quiz_choice.json')
ids = {i['id'] for i in trivia['items']}
qids = {q['factId'] for q in quiz['items']}
cids = {c['id'] for c in choice['items']}
ill = {}
for f in sys.argv[1:]:
    d = json.loads(pathlib.Path(f).read_text(encoding='utf-8'))
    for i in d['items']:
        if i['id'] not in ids:
            trivia['items'].append(i)
            ids.add(i['id'])
    for q in d['quiz']:
        if q['factId'] not in qids:
            quiz['items'].append(q)
            qids.add(q['factId'])
    for c in d['choice']:
        if c['id'] not in cids:
            choice['items'].append(c)
            cids.add(c['id'])
    ill.update(d.get('illustrations', {}))
by = {i['id']: i for i in trivia['items']}
missing = sorted({r for i in trivia['items'] for r in i['related'] if r not in by})
if missing:
    sys.exit('related に、存在しない id がある: ' + ', '.join(missing))
for i in trivia['items']:  # related は、おたがいに結ぶ
    for r in list(i['related']):
        if i['id'] not in by[r]['related']:
            by[r]['related'].append(i['id'])
save('trivia.json', trivia)
save('quiz.json', quiz)
save('quiz_choice.json', choice)
p = root / 'lib/widgets/illustration.dart'
s = p.read_text(encoding='utf-8')
add = ''.join(f"  '{k}': '{v}',\n" for k, v in ill.items() if not re.search(rf"'{re.escape(k)}':", s))
if add:
    if "  'hand': '✋'" not in s:
        sys.exit('illustration.dart の差し込み位置（hand）が見つからない')
    s = s.replace("  'hand': '✋'", add + "  'hand': '✋'", 1)
    p.write_text(s, encoding='utf-8')
print(len(trivia['items']), 'items')
