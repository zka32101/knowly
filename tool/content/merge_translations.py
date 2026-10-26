#!/usr/bin/env python3
"""翻訳（zh/ko/es）を assets/trivia/*.json に取り込む。すべて draft（未レビュー）。
使い方: python3 tool/content/merge_translations.py <out_zh.json など> ...
各ファイル: {"trivia":{id:{kids|junior|teen|adult:{title,body}}}, "quiz":{factId:文}, "choice":{id:{question,options,answer}}, "glossary":{id:{term,match,simple,detail}}}"""
import json, pathlib, sys
root = pathlib.Path(__file__).resolve().parents[2]


def load(n):
    p = root / 'assets/trivia' / n
    return p, json.loads(p.read_text(encoding='utf-8'))


tp, trivia = load('trivia.json')
qp, quiz = load('quiz.json')
cp, choice = load('quiz_choice.json')
gp, gloss = load('glossary.json')
for f in sys.argv[1:]:
    lang = pathlib.Path(f).stem.split('_')[-1]
    d = json.loads(pathlib.Path(f).read_text(encoding='utf-8'))
    for i in trivia['items']:
        lv = d['trivia'].get(i['id'])
        if lv:
            i['translations'][lang] = {'reviewStatus': 'draft', 'levels': lv, 'reviewedBy': None, 'reviewedAt': None}
    for i in quiz['items']:
        s = d['quiz'].get(i['factId'])
        if s:
            i[lang] = {'statement': s, 'answer': i['en']['answer']}
    for i in choice['items']:
        c = d['choice'].get(i['id'])
        if c:
            i[lang] = {'question': c['question'], 'options': c['options'], 'answer': i['en']['answer']}
    for i in gloss['items']:
        g = d['glossary'].get(i['id'])
        if g:
            i[lang] = g
    print(lang, 'merged')
for p, d in [(tp, trivia), (qp, quiz), (cp, choice), (gp, gloss)]:
    p.write_text(json.dumps(d, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
