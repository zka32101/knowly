# 雑学の追加（第1弾）。tool/content/add_facts.py から読み込む。
# 書式: F(id, カテゴリー, シーン, 絵, 日本語4段階, 英語4段階, キーワード, 関連, 対訳, 季節)
# 日本語4段階 = [Kids, Junior, Teen, Adult] の (タイトル, 本文)。
#   Kids: ひらがなだけ（本文は60文字まで）。Junior: 漢字のあとに必ず（よみ）。
# 英語4段階 = 同じ順。
FACTS = []


def F(id, cat, scenes, ill, ja, en, kw, rel, vocab, seasons=()):
    FACTS.append(dict(id=id, cat=cat, scenes=scenes, ill=ill, ja=ja, en=en, kw=kw, rel=rel,
                      vocab=vocab, seasons=list(seasons)))


# ---------------- どうぶつ ----------------
F("penguin_huddle", "animals", ["friends", "kids", "family"], "penguin",
  [("ペンギンの おしくらまんじゅう", "コウテイペンギンは さむい ふゆ、みんなで くっついて あたたまるよ。"),
   ("ペンギンは みんなで あたたまる", "コウテイペンギンは、さむい ふゆに ぎゅっと あつまります。そとがわの ペンギンと なかの ペンギンは、じゅんばんに いれかわるよ。"),
   ("コウテイペンギンは、寒（さむ）さのなかで身（み）を寄（よ）せ合（あ）う", "コウテイペンギンは南極（なんきょく）の冬（ふゆ）、数千羽（すうせんわ）で体（からだ）をくっつけて集（あつ）まります。外側（そとがわ）の鳥（とり）と内側（うちがわ）の鳥（とり）は、少（すこ）しずつ入（い）れ替（か）わって、みんなが暖（あたた）まれるようにします。"),
   ("コウテイペンギンは、ハドルで寒さをしのぐ", "コウテイペンギンは南極の冬、気温がマイナス数十℃になる中で、数千羽が密集して「ハドル」と呼ばれる群れをつくります。外側と内側の個体が少しずつ入れ替わるため、全員が風を避けて体温を保つことができます。")],
  [("Penguins snuggle up", "Emperor penguins huddle together to stay warm in winter!"),
   ("Penguins take turns staying warm", "In the cold winter, emperor penguins squeeze close together. Penguins on the outside and inside swap places so everyone gets warm."),
   ("Emperor penguins huddle to survive the cold", "In the Antarctic winter, thousands of emperor penguins press their bodies together. The birds on the outside and inside slowly trade places, so everyone gets a turn in the warm middle."),
   ("Emperor penguins huddle to share body heat", "During the Antarctic winter, with temperatures far below freezing, thousands of emperor penguins form a dense huddle. Individuals gradually rotate between the windy outer edge and the sheltered center, so the whole colony conserves body heat.")],
  ["ペンギン", "南極", "penguin", "寒さ", "冬"], ["koala_fingerprints", "ice_floats"],
  [("penguin", "ペンギン", ""), ("winter", "ふゆ", "冬"), ("warm", "あたたかい", "暖かい")], ["winter"])

F("owl_head_turn", "animals", ["friends", "kids", "learning"], "owl",
  [("フクロウは くびが ぐるり", "フクロウは くびを うしろまで まわせるよ。めが うごかないからなんだ。"),
   ("フクロウは くびを ぐるりと まわす", "フクロウは めを うごかせません。そのかわり、くびを うしろまで ぐるりと まわして まわりを みます。"),
   ("フクロウは首（くび）を約（やく）270度（ど）まわせる", "フクロウの目（め）は、ほとんど動（うご）かせません。そのかわり、首（くび）を約（やく）270度（ど）もまわして、うしろまで見（み）ることができます。"),
   ("フクロウは眼球がほぼ固定されているため、首を約270度回す", "フクロウの眼球は筒状で頭蓋骨にほぼ固定されており、目を動かせません。その代わり、首の骨(頸椎)の数が多く、約270度まで首を回して周囲を見渡します。")],
  [("Owls turn their heads", "An owl can turn its head almost all the way around!"),
   ("Owls can't move their eyes", "An owl cannot move its eyes. So it turns its head far around to look behind itself."),
   ("Owls can turn their heads about 270 degrees", "An owl's eyes hardly move in their sockets. To make up for it, an owl can swivel its head about 270 degrees to see behind itself."),
   ("Owls rotate their necks about 270 degrees", "An owl's tubular eyes are nearly fixed in the skull, so it cannot move them. Instead, flexible neck vertebrae let it rotate its head up to about 270 degrees to scan its surroundings.")],
  ["フクロウ", "梟", "owl", "首", "目"], ["giraffe_seven_vertebrae", "crows_recognize_faces"],
  [("owl", "ふくろう", "梟"), ("head", "あたま", "頭"), ("eye", "め", "目")])

F("camel_hump_fat", "animals", ["friends", "kids", "learning"], "camel",
  [("ラクダの こぶの なかみ", "ラクダの こぶには、みずじゃなくて あぶらが はいっているよ。"),
   ("こぶには あぶらが ある", "ラクダの こぶの なかみは あぶらです。ごはんが ないときに、この あぶらを つかって いきるんだよ。"),
   ("ラクダのこぶには脂肪（しぼう）がたまっている", "ラクダのこぶに入（はい）っているのは水（みず）ではなく、脂肪（しぼう）です。食（た）べ物（もの）が少（すく）ない砂漠（さばく）で、この脂肪（しぼう）を使（つか）って生（い）きのびます。"),
   ("ラクダのこぶは水ではなく脂肪の貯蔵庫", "ラクダのこぶは水を貯めた袋ではなく、脂肪の塊です。食べ物が乏しい砂漠で、この脂肪をエネルギー源に使います。体の他の部分に脂肪がつきにくいため、熱がこもりにくい効果もあるとされます。")],
  [("Camel humps", "A camel's hump holds fat, not water!"),
   ("A hump stores fat", "A camel's hump is full of fat. When there is little food, the camel can live off that fat."),
   ("A camel's hump is fat, not water", "The hump on a camel is a store of fat, not water. In the desert, where food is scarce, the camel lives off this fat."),
   ("A camel's hump is a fat reserve, not a water tank", "A camel's hump is a lump of fat rather than a bag of water. In deserts where food is scarce, the camel metabolizes it for energy. Concentrating fat in the hump may also help the rest of the body shed heat.")],
  ["ラクダ", "駱駝", "camel", "こぶ", "砂漠"], ["antarctica_desert", "elephant_ground_sounds"],
  [("camel", "らくだ", "駱駝"), ("desert", "さばく", "砂漠"), ("fat", "あぶら", "脂")])

F("sloth_slow", "animals", ["friends", "kids", "learning"], "sloth",
  [("ナマケモノは ゆっくり", "ナマケモノは とても ゆっくり。トイレは 1しゅうかんに 1かいくらい。"),
   ("ナマケモノは とても ゆっくり", "ナマケモノは はっぱを すこしずつ たべて、ゆっくり ゆっくり うごきます。トイレも 1しゅうかんに 1かいくらいです。"),
   ("ナマケモノは、ゆっくり動（うご）いて省（しょう）エネ", "ナマケモノは葉（は）っぱを少（すこ）しずつ食（た）べ、とてもゆっくり動（うご）きます。消化（しょうか）にも時間（じかん）がかかり、トイレは約（やく）1週間（しゅうかん）に1回（かい）、木（き）から降（お）りて行（い）きます。"),
   ("ナマケモノは、低エネルギーの生活で葉を食べて生きる", "ナマケモノは栄養の少ない葉を主食とし、代謝が低く、動きがとてもゆっくりです。消化にも日数がかかり、排泄はおよそ1週間に1回、木から降りて地上で行うことが知られています。")],
  [("Sloths are slow", "A sloth moves very slowly and goes to the bathroom about once a week!"),
   ("Sloths take it slow", "A sloth eats leaves a little at a time and moves very slowly. It only goes to the bathroom about once a week."),
   ("Sloths save energy by moving slowly", "Sloths eat a few leaves at a time and move very slowly. Digestion takes days, and they climb down from the tree only about once a week to go to the bathroom."),
   ("Sloths live on a low-energy budget", "Sloths feed on low-nutrient leaves, have a low metabolic rate and move slowly. Digestion takes many days, and they typically descend to the ground to defecate only about once a week.")],
  ["ナマケモノ", "怠け者", "sloth", "ゆっくり", "木"], ["koala_fingerprints", "wombat_cube_poop"],
  [("sloth", "なまけもの", ""), ("slow", "ゆっくり", ""), ("leaf", "は", "葉")])

F("salmon_return", "animals", ["friends", "family", "learning"], "salmon",
  [("サケは うまれた かわへ", "サケは あきに、うまれた かわに もどって くるんだよ。"),
   ("サケは ふるさとの かわに もどる", "サケは うみで おおきく なって、あきに うまれた かわへ もどって きます。かわの においを おぼえて いるからだよ。"),
   ("サケは生（う）まれた川（かわ）に帰（かえ）ってくる", "サケは川（かわ）で生（う）まれ、海（うみ）で大（おお）きくなります。そして秋（あき）、卵（たまご）を産（う）むために、生（う）まれた川（かわ）に戻（もど）ります。川（かわ）のにおいを覚（おぼ）えているからだと考（かんが）えられています。"),
   ("サケは母川回帰し、産卵のために生まれた川へ戻る", "サケは川で生まれて海で成長し、成熟すると産卵のために生まれた川へ戻ります(母川回帰)。川の水に含まれる化学物質のにおいを記憶して、たどり着くと考えられています。")],
  [("Salmon come home", "Salmon swim back to the river where they were born in autumn!"),
   ("Salmon return to their home river", "Salmon grow up in the sea and swim back to the river where they were born in autumn. They remember the smell of the river."),
   ("Salmon return to the river where they were born", "Salmon are born in rivers and grow up at sea. In autumn they return to their birth river to lay eggs. They are thought to remember the smell of its water."),
   ("Salmon home to their natal rivers to spawn", "Salmon hatch in rivers and mature at sea, then return to their natal river to spawn. They are thought to imprint on the chemical scent of the river water and follow it back.")],
  ["サケ", "鮭", "salmon", "川", "秋"], ["sea_otters_hold_hands", "dolphin_half_sleep"],
  [("salmon", "さけ", "鮭"), ("river", "かわ", "川"), ("autumn", "あき", "秋")], ["autumn"])

F("squirrel_acorns", "animals", ["friends", "kids", "learning"], "squirrel",
  [("リスと どんぐり", "リスは あきに どんぐりを うめるよ。わすれた どんぐりは めが でるんだ。"),
   ("リスは どんぐりを うめる", "リスは あきに どんぐりを ちめんに うめて、ふゆの ごはんに します。わすれた どんぐりは、あたらしい きに なる ことも あります。"),
   ("リスが埋（う）めたどんぐりは木（き）になることがある", "リスは秋（あき）、冬（ふゆ）の食（た）べ物（もの）としてどんぐりを地面（じめん）にたくさん埋（う）めます。食（た）べ忘（わす）れたどんぐりから芽（め）が出（で）て、新（あたら）しい木（き）に育（そだ）つことがあります。"),
   ("リスの貯食行動は、森の木を増やす手助けになる", "リスは秋に、冬の食料としてドングリなどの種子を土の中に分散して埋めます(貯食行動)。埋めた場所を忘れた種子が発芽して成長することがあり、結果として森の更新に役立っていると考えられています。")],
  [("Squirrels and acorns", "Squirrels bury acorns in autumn. The ones they forget can grow into trees!"),
   ("Squirrels bury acorns", "In autumn, squirrels bury acorns in the ground to eat in winter. Acorns they forget can sprout into new trees."),
   ("Acorns buried by squirrels can become trees", "In autumn, squirrels bury many acorns for winter food. Some are forgotten, and those can sprout and grow into new trees."),
   ("Squirrels' food caching helps forests regrow", "In autumn, squirrels scatter-hoard acorns and other seeds in the soil for winter. Seeds whose locations are forgotten may germinate and grow, so caching likely helps forests regenerate.")],
  ["リス", "栗鼠", "squirrel", "どんぐり", "秋"], ["bamboo_fast", "crows_recognize_faces"],
  [("squirrel", "りす", "栗鼠"), ("acorn", "どんぐり", ""), ("tree", "き", "木")], ["autumn"])

F("bat_echolocation", "animals", ["friends", "family", "learning"], "bat",
  [("コウモリの ふしぎな みみ", "コウモリは こえを だして、かえって きた おとで まわりを しるよ。"),
   ("コウモリは おとで みる", "コウモリは ひとには きこえない たかい こえを だします。その こえが かえって くる おとで、くらい ところでも ものの ばしょが わかるよ。"),
   ("コウモリは超音波（ちょうおんぱ）で暗（くら）やみを飛（と）ぶ", "コウモリは、人（ひと）には聞（き）こえない高（たか）い音（おと）を出（だ）し、その反響（はんきょう）を聞（き）いて、まわりのものの位置（いち）を知（し）ります。これでくらい夜（よる）でも、虫（むし）をつかまえることができます。"),
   ("コウモリは反響定位で暗闇でも獲物を捕らえる", "コウモリは超音波のパルスを発し、物に当たって返ってくる反響を聞き分けて、周囲の物体の位置や距離を把握します(反響定位)。これにより、暗闇でも飛びながら小さな昆虫を捕らえることができます。")],
  [("Bat ears", "A bat makes sounds and listens for the echoes to find things!"),
   ("Bats see with sound", "Bats make high sounds that people cannot hear. They listen to the echoes to know where things are, even in the dark."),
   ("Bats use ultrasound to fly in the dark", "Bats make high-pitched sounds that humans cannot hear and listen to the echoes to find where objects are. This lets them catch insects even on dark nights."),
   ("Bats use echolocation to hunt in the dark", "Bats emit ultrasonic pulses and listen to the echoes returning from objects to judge their position and distance. This echolocation lets them catch small insects on the wing even in total darkness.")],
  ["コウモリ", "蝙蝠", "bat", "超音波", "夜"], ["no_sound_in_space", "elephant_ground_sounds"],
  [("bat", "こうもり", "蝙蝠"), ("sound", "おと", "音"), ("night", "よる", "夜")])

# ---------------- むし ----------------
F("ladybug_spots", "bugs", ["friends", "kids", "learning"], "ladybug",
  [("テントウムシの ほし", "テントウムシの ほしの かずでは、としは わからないよ。"),
   ("ほしの かずは としでは ない", "テントウムシの せなかの ほしの かずは、しゅるいで ちがいます。おおきく なっても ふえたり へったり しないよ。"),
   ("テントウムシの星（ほし）の数（かず）は年齢（ねんれい）ではない", "テントウムシの背中（せなか）の星（ほし）の数（かず）は、種類（しゅるい）によってちがいます。大（おお）きくなっても、数（かず）はふえたりへったりしません。"),
   ("テントウムシの斑点の数は種によって決まっていて、年齢とは関係ない", "テントウムシの背中の斑点の数は、ナナホシテントウは7個というように、種によってほぼ決まっています。成虫になってからは変わらないため、斑点の数から年齢を知ることはできません。")],
  [("Ladybug spots", "You can't tell a ladybug's age by counting its spots!"),
   ("Spots don't show age", "The number of spots on a ladybug depends on its kind. It does not change as the ladybug gets older."),
   ("A ladybug's spot count is not its age", "The number of spots on a ladybug's back depends on its species. Once it is an adult, the number stays the same."),
   ("Ladybug spot number is set by species, not age", "The number of spots on a ladybug's back is largely fixed by species, for example seven in the seven-spot ladybird. It does not change after the adult stage, so spots cannot be used to tell age.")],
  ["テントウムシ", "天道虫", "ladybug", "星", "斑点"], ["beetle_quarter", "spider_not_insect"],
  [("ladybug", "てんとうむし", "天道虫"), ("spot", "てん", "点"), ("back", "せなか", "背中")])

F("cricket_sing", "bugs", ["friends", "family", "learning"], "cricket",
  [("スズムシの なきごえ", "あきに なく むしは おすだけ。はねを こすって おとを だすよ。"),
   ("なくのは おすだけ", "あきの よるに りんりんと なくのは おすの スズムシです。はねを こすりあわせて、めすに よびかけて いるんだよ。"),
   ("秋（あき）に鳴（な）く虫（むし）はオスだけ", "秋（あき）の夜（よる）に鳴（な）く虫（むし）の多（おお）くは、オスです。羽（はね）をこすり合（あ）わせて音（おと）を出（だ）し、メスに呼（よ）びかけています。"),
   ("コオロギやスズムシは、オスが翅をこすって鳴く", "秋の夜に聞こえる虫の声の多くは、オスが前翅をこすり合わせて出す音で、メスを呼ぶためのものです。コオロギの仲間は、耳が前脚にあり、仲間の声を聞き分けます。")],
  [("Singing insects", "In autumn, only the boy insects sing, by rubbing their wings!"),
   ("Only males sing", "On autumn nights, it is male crickets that sing. They rub their wings together to call to the females."),
   ("Only male crickets sing", "Most of the insects singing on autumn nights are males. They rub their wings together to make sounds that call to females."),
   ("Male crickets sing by rubbing their wings", "Much of the insect song heard on autumn nights is made by males rubbing their forewings together to attract females. Crickets have their ears on their front legs, which they use to pick out the songs of their own kind.")],
  ["スズムシ", "鈴虫", "cricket", "秋", "鳴く"], ["cicada_17_years", "mosquito_female_bites"],
  [("cricket", "こおろぎ", ""), ("wing", "はね", "羽"), ("sing", "なく", "鳴く")], ["autumn"])

# ---------------- のりもの ----------------
F("bicycle_first", "vehicles", ["friends", "kids", "learning"], "bicycle",
  [("さいしょの じてんしゃ", "さいしょの じてんしゃには、ペダルが なかったんだよ。"),
   ("さいしょの じてんしゃは ペダルなし", "むかしの じてんしゃは、じめんを あしで けって すすみました。ペダルは あとから つけられたよ。"),
   ("最初（さいしょ）の自転車（じてんしゃ）にはペダルがなかった", "1817年（ねん）にドイツで作（つく）られた自転車（じてんしゃ）のもとになる乗（の）り物（もの）には、ペダルがありませんでした。足（あし）で地面（じめん）をけって進（すす）んだのです。ペダルはあとから発明（はつめい）されました。"),
   ("初期の自転車（ドライジーネ）にはペダルがなかった", "1817年にドイツのカール・ドライスが考案した「ドライジーネ」は、自転車の原型とされ、ペダルがなく、乗り手が地面を足で蹴って進みました。ペダルを前輪に付けた型は、その後の1860年代に登場します。")],
  [("The first bicycle", "The very first bicycle had no pedals!"),
   ("The first bicycle had no pedals", "Long ago, people rode by kicking the ground with their feet. Pedals were added later."),
   ("The first bicycle had no pedals", "The ancestor of the bicycle, built in Germany in 1817, had no pedals. Riders pushed along the ground with their feet. Pedals were invented later."),
   ("Early bicycles, the draisine, had no pedals", "The draisine, devised by Karl Drais in Germany in 1817 and regarded as the ancestor of the bicycle, had no pedals; riders pushed themselves along with their feet. Pedals mounted on the front wheel appeared in the 1860s.")],
  ["自転車", "ペダル", "bicycle", "ドライジーネ", "1817"], ["wright_first_flight", "tokyo_first_subway"],
  [("bicycle", "じてんしゃ", "自転車"), ("pedal", "ぺだる", ""), ("wheel", "しゃりん", "車輪")])

F("black_box_orange", "vehicles", ["friends", "family", "learning"], "airplane",
  [("ブラックボックスの いろ", "ひこうきの ブラックボックスは、ほんとは オレンジいろなんだ。"),
   ("ブラックボックスは オレンジ", "ひこうきの きろくを のこす そうちは「ブラックボックス」と いうけど、ほんとうは めだつ オレンジいろです。"),
   ("ブラックボックスは本当（ほんとう）はオレンジ色（いろ）", "飛行機（ひこうき）の記録（きろく）を残（のこ）す装置（そうち）は「ブラックボックス」とよばれますが、実際（じっさい）は見（み）つけやすいオレンジ色（いろ）にぬられています。"),
   ("フライトレコーダーは、発見しやすいオレンジ色に塗られている", "航空機の飛行データや操縦室の音声を記録する装置は、通称「ブラックボックス」ですが、実際は事故の際に発見しやすいよう、明るいオレンジ色に塗られています。名前の由来には諸説あります。")],
  [("The black box", "An airplane's black box is really orange!"),
   ("The black box is orange", "The recorder on an airplane is called a black box, but it is painted bright orange so it is easy to find."),
   ("The \"black box\" is actually orange", "The device that records an airplane's flight data is called the black box, but it is painted bright orange so that it is easy to find."),
   ("Flight recorders are painted bright orange", "The devices that record an aircraft's flight data and cockpit audio are nicknamed black boxes, yet they are painted bright orange so they can be found easily after an accident. The origin of the nickname is disputed.")],
  ["ブラックボックス", "飛行機", "black box", "オレンジ", "記録"], ["airliner_cruise", "plane_window_hole"],
  [("airplane", "ひこうき", "飛行機"), ("orange", "おれんじ", ""), ("box", "はこ", "箱")])

F("shinkansen_kingfisher", "vehicles", ["friends", "family", "learning"], "train",
  [("しんかんせんと カワセミ", "しんかんせんの かたちは、とりの くちばしを まねして いるよ。"),
   ("しんかんせんは とりに まなんだ", "500けいの しんかんせんの さきっぽは、カワセミの くちばしを まねして、おとを ちいさくしたんだよ。"),
   ("新幹線（しんかんせん）の先頭（せんとう）はカワセミに学（まな）んだ", "新幹線（しんかんせん）の500系（けい）の先頭（せんとう）は、水（みず）に飛（と）びこむカワセミのくちばしを参考（さんこう）に作（つく）られ、トンネルに入（はい）るときの大（おお）きな音（おと）を小（ちい）さくしました。"),
   ("500系新幹線の先頭形状は、カワセミのくちばしがヒントになった", "トンネルに高速で突入すると、空気の圧力波により「トンネルドン」という大きな音が出ます。500系新幹線は、水に飛び込む際に水しぶきを立てないカワセミのくちばしに学んだ細長い先頭形状で、これを抑えました。")],
  [("Bullet train and kingfisher", "The bullet train's nose copies a bird's beak!"),
   ("The bullet train learned from a bird", "The nose of the 500 Series bullet train copies a kingfisher's beak, which makes the noise in tunnels much smaller."),
   ("The bullet train's nose was inspired by a kingfisher", "The nose of the 500 Series Shinkansen was modeled on the beak of the kingfisher, a bird that dives into water, which makes the loud boom in tunnels much quieter."),
   ("The 500 Series nose took its cue from the kingfisher's beak", "When a high-speed train enters a tunnel, pressure waves can cause a loud boom. The long, slender nose of the 500 Series Shinkansen was designed with the kingfisher's beak in mind, a bird that dives with hardly a splash, to reduce it.")],
  ["新幹線", "カワセミ", "bullet train", "500系", "トンネル"], ["shinkansen_1964", "maglev_603"],
  [("train", "でんしゃ", "電車"), ("bird", "とり", "鳥"), ("tunnel", "とんねる", "")])
