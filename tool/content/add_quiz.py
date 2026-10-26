#!/usr/bin/env python3
"""新しい雑学の ○×クイズを assets/trivia/quiz.json に追加する（追加済みは飛ばす）。ja はひらがなだけ。"""
import json, pathlib
root = pathlib.Path(__file__).resolve().parents[2]
Q = {
 "penguin_huddle": ("コウテイペンギンは、さむい ふゆに みんなで くっついて あたたまる。", True, "Emperor penguins huddle together to stay warm in winter."),
 "owl_head_turn": ("フクロウは、めを ぐるぐる うごかして うしろを みる。", False, "An owl moves its eyes around to look behind it."),
 "camel_hump_fat": ("ラクダの こぶには、あぶらが はいっている。", True, "A camel's hump stores fat."),
 "sloth_slow": ("ナマケモノは、とても ゆっくり うごく。", True, "Sloths move very slowly."),
 "salmon_return": ("サケは、うまれた かわに もどって たまごを うむ。", True, "Salmon return to the river where they were born to lay eggs."),
 "squirrel_acorns": ("リスが うめた どんぐりは、ぜんぶ ぜったいに たべられる。", False, "Squirrels always eat every acorn they bury."),
 "bat_echolocation": ("コウモリは、おとの はねかえりで ものの いちを しる。", True, "Bats use bouncing sound to find where things are."),
 "ladybug_spots": ("テントウムシの ほしの かずは、しゅるいで ちがう。", True, "The number of spots on a ladybug depends on its kind."),
 "cricket_sing": ("コオロギは、はねを こすりあわせて おとを だす。", True, "Crickets make sound by rubbing their wings together."),
 "bicycle_first": ("さいしょの じてんしゃには、ペダルが なかった。", True, "The very first bicycles had no pedals."),
 "black_box_orange": ("ひこうきの ブラックボックスは、まっくろな いろを している。", False, "An airplane's black box is jet black in color."),
 "shinkansen_kingfisher": ("しんかんせんの かたちは、カワセミの くちばしを ヒントに した。", True, "The Shinkansen's shape was inspired by a kingfisher's beak."),
 "snow_hexagon": ("ゆきの けっしょうは、ほとんど ろっかくけいの かたち。", True, "Most snow crystals are six-sided."),
 "goosebumps_cold": ("さむいと、はだに ぷつぷつが できる ことが ある。", True, "Your skin can get goosebumps when you are cold."),
 "maple_red": ("もみじは、なつに いちばん あかくなる。", False, "Maple leaves turn their reddest in summer."),
 "tree_rings": ("きの ねんりんを かぞえると、としが わかる。", True, "Counting a tree's rings tells you its age."),
 "sunflower_sun": ("わかい ひまわりは、たいように あわせて むきを かえる。", True, "Young sunflowers turn to follow the sun."),
 "thunder_count": ("かみなりは、ひかる まえに おとが きこえる。", False, "You hear thunder before you see the lightning."),
 "nails_grow": ("つめは、まいにち すこしずつ のびている。", True, "Your nails grow a little every day."),
 "brain_energy": ("のうは、からだの なかで たくさん エネルギーを つかう。", True, "The brain uses a lot of energy."),
 "blink_times": ("ひとは、1にちに なんまんかいも まばたきを する。", True, "People blink many thousands of times a day."),
 "fuji_3776": ("ふじさんは、にほんで いちばん ひくい やまだ。", False, "Mt. Fuji is the lowest mountain in Japan."),
}
p = root / 'assets/trivia/quiz.json'
d = json.loads(p.read_text(encoding='utf-8'))
have = {i['factId'] for i in d['items']}
for k, (j, a, e) in Q.items():
    if k not in have:
        d['items'].append({'factId': k, 'ja': {'statement': j, 'answer': a}, 'en': {'statement': e, 'answer': a}})
p.write_text(json.dumps(d, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print(len(d['items']))
