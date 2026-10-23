# 雑学の追加（第2弾: 秋・冬・夏の季節ネタと、からだ・そら）。ja は [Kids, Junior(よみ付き), Adult]。
from facts_batch1 import F, FACTS  # noqa: F401

F("snow_hexagon", "nature", ["friends", "kids", "learning"], "snow",
  [("ゆきの けっしょうは ろっかくけい", "ゆきの けっしょうは、だいたい ろっかくけいの かたちだよ。"),
   ("雪（ゆき）の結晶（けっしょう）は六角形（ろっかくけい）", "雪（ゆき）のつぶを虫（むし）めがねで見（み）ると、六角形（ろっかくけい）のきれいな形（かたち）をしています。水（みず）のつぶが、決（き）まった形（かたち）でくっつくからです。"),
   ("雪の結晶は六角形を基本にしている", "雪の結晶は、水分子が規則的に並ぶ氷の性質から、六角形を基本とした形になります。気温や湿度によって、板状・針状・樹枝状など多様な形に育ちます。")],
  [("Snowflakes have six sides", "Most snow crystals are shaped like little six-sided stars."),
   ("Snow crystals are hexagons", "Look at snow with a magnifying glass and you will see six-sided shapes. Water freezes into ice in a set pattern."),
   ("Snow crystals are built on a six-sided plan", "Water molecules lock into a regular pattern in ice, giving snow crystals a six-sided base shape. Temperature and humidity change how they grow."),
   ("Snow crystals grow from a hexagonal lattice", "Ice's molecular lattice is hexagonal, so snow crystals share a six-fold symmetry. Temperature and humidity decide whether they grow as plates, needles or branching dendrites.")],
  ["雪", "結晶", "snow", "六角形", "冬"], ["ice_floats", "penguin_huddle"],
  [("snow", "ゆき", "雪"), ("crystal", "けっしょう", "結晶"), ("winter", "ふゆ", "冬")], ["winter"])

F("goosebumps_cold", "body", ["friends", "kids", "learning"], "heart",
  [("さむいと とりはだが たつ", "さむいと はだに ぷつぷつが できるよ。からだを あたためる しくみなんだ。"),
   ("鳥肌（とりはだ）は体（からだ）の名残（なごり）", "寒（さむ）いと、はだの毛（け）が立（た）って、ぷつぷつができます。むかしの人（ひと）は毛（け）がふさふさで、毛（け）を立（た）てて体（からだ）を暖（あたた）めていたなごりです。"),
   ("鳥肌は、毛を立てて体温を守る名残", "寒いと、毛穴の周りの筋肉が縮んで毛が立ち、鳥肌になります。体毛が多かった祖先が、毛を立てて空気の層をつくり、体温を逃がさないようにしていた名残だと考えられています。")],
  [("Goosebumps in the cold", "When it is cold, tiny bumps pop up on your skin to help you stay warm."),
   ("Goosebumps are a leftover from our past", "In the cold, the hairs on your skin stand up. Long ago, people with lots of body hair stayed warm this way."),
   ("Goosebumps are a leftover from furry ancestors", "Tiny muscles around each hair tighten and make it stand up. Our furry ancestors trapped a layer of warm air this way."),
   ("Goosebumps are a vestigial warming reflex", "Arrector pili muscles contract and raise body hairs. In furrier ancestors this trapped insulating air; in humans it is considered a vestigial reflex.")],
  ["鳥肌", "寒さ", "goosebumps", "体温", "冬"], ["penguin_huddle", "baby_bones"],
  [("cold", "さむい", "寒い"), ("skin", "はだ", "肌"), ("hair", "け", "毛")], ["winter"])

F("maple_red", "nature", ["friends", "kids", "learning"], "maple",
  [("もみじは どうして あかくなる？", "あきに なって さむくなると、はっぱが あかく なるよ。"),
   ("紅葉（こうよう）は秋（あき）のしくみ", "秋（あき）になって寒（さむ）くなると、葉（は）の中（なか）の緑色（みどりいろ）が消（き）えます。そのあと、赤（あか）い色（いろ）の元（もと）が作（つく）られて、葉（は）が赤（あか）くなります。"),
   ("紅葉は、アントシアニンが作られて赤くなる", "秋に気温が下がると、葉の緑の色素が分解されます。モミジなどでは、さらに赤い色素のアントシアニンが作られるため、葉が赤く染まります。")],
  [("Why do leaves turn red?", "In fall, when it gets cold, some leaves turn red!"),
   ("Why autumn leaves turn red", "When fall comes and it gets cold, the green color in a leaf fades. Then red color is made in the leaf."),
   ("Autumn leaves turn red when anthocyanin forms", "As temperatures drop, a leaf's green pigment breaks down. Maples also make red anthocyanin, which colors the leaf."),
   ("Red autumn foliage comes from anthocyanin synthesis", "Cooling temperatures degrade chlorophyll. In maples and similar trees, sugars in the leaf are used to produce red anthocyanin pigments, so the leaf turns red.")],
  ["紅葉", "もみじ", "maple", "秋", "葉"], ["tree_rings", "snow_hexagon"],
  [("leaf", "は", "葉"), ("autumn", "あき", "秋"), ("red", "あか", "赤")], ["autumn"])

F("tree_rings", "nature", ["kids", "learning"], "tree",
  [("きの としわ", "きを きると、わっかが みえるよ。わっかを かぞえると とし が わかるんだ。"),
   ("木（き）の年輪（ねんりん）", "木（き）を切（き）ると、まるい線（せん）が見（み）えます。この線（せん）の数（かず）をかぞえると、その木（き）が何年（なんねん）生（い）きたかが分（わ）かります。"),
   ("年輪を数えると、木の年齢が分かる", "木は、成長の早い春から夏と、遅い秋から冬で密度が変わり、1年に1本の輪ができます。この数を数えると年齢が分かり、輪の幅から当時の天候も推測できます。")],
  [("A tree's rings", "Cut a tree and you can see rings. Count them to find its age!"),
   ("Tree rings tell a tree's age", "When a tree is cut, you can see round lines. Counting them shows how many years it lived."),
   ("Counting rings reveals a tree's age", "Trees grow fast in spring and summer and slowly in fall and winter, making one ring a year. The ring widths also hint at past weather."),
   ("Tree rings record age and climate", "Seasonal growth differences leave one ring per year. Ring width and density are used in dendrochronology to date wood and infer past climate.")],
  ["年輪", "木", "tree", "ring", "年齢"], ["maple_red", "bamboo_fast"],
  [("tree", "き", "木"), ("ring", "わ", "輪"), ("age", "とし", "年")])

F("sunflower_sun", "nature", ["friends", "kids", "learning"], "sunflower",
  [("ひまわりは たいように むく", "わかい ひまわりは、おひさまの ほうへ くびを まわすよ。"),
   ("ひまわりは太陽（たいよう）を追（お）いかける", "つぼみのころのヒマワリは、朝（あさ）は東（ひがし）、夕方（ゆうがた）は西（にし）へと、太陽（たいよう）の動（うご）きに合（あ）わせて向（む）きを変（か）えます。花（はな）がさくと、東（ひがし）を向（む）いたままになります。"),
   ("ヒマワリは、つぼみの間だけ太陽を追う", "若いヒマワリは、茎の成長のしかたの差で、日中に東から西へ向きを変えます。花が咲いて成長が止まると、ほぼ東を向いたまま固定されます。")],
  [("Sunflowers face the sun", "Young sunflowers turn toward the sun all day long."),
   ("Sunflowers follow the sun", "Young sunflowers face east in the morning and west in the evening. After they bloom, they stay facing east."),
   ("Sunflowers follow the sun only while young", "A young sunflower bends its stem to track the sun from east to west. Once it blooms and stops growing, it stays facing east."),
   ("Heliotropism in sunflowers stops at maturity", "Differential stem growth makes immature sunflowers track the sun. When flowering ends growth, the head locks facing roughly east.")],
  ["ひまわり", "向日葵", "sunflower", "太陽", "夏"], ["maple_red", "tree_rings"],
  [("sunflower", "ひまわり", "向日葵"), ("sun", "たいよう", "太陽"), ("summer", "なつ", "夏")], ["summer"])

F("thunder_count", "nature", ["friends", "kids", "learning"], "lightning",
  [("かみなりまで なんメートル？", "ぴかっと ひかってから おとが するまで かぞえると、きょりが わかるよ。"),
   ("雷（かみなり）までの距離（きょり）は数（かぞ）えて分（わ）かる", "光（ひかり）ってから音（おと）が聞（き）こえるまでの秒数（びょうすう）に、300をかけると、雷（かみなり）までの距離（きょり）がおよそ分（わ）かります。"),
   ("雷までの距離は、光と音の時間差で分かる", "雷の光は一瞬で届きますが、音は秒速約340mです。光ってから音が聞こえるまでの秒数に約340をかけると、落雷までのおおよその距離(m)が分かります。")],
  [("How far is the thunder?", "Count the seconds between the flash and the boom to find out!"),
   ("Count to find how far thunder is", "Count the seconds from the flash until you hear the sound. Multiply by 300 to guess how many meters away it is."),
   ("Count the seconds between lightning and thunder", "Light arrives almost instantly but sound travels at about 340 meters per second. Multiply the delay in seconds by about 340 to estimate the distance."),
   ("Flash-to-bang delay gives the distance of lightning", "Light reaches you almost immediately while sound travels at roughly 340 m/s, so the delay in seconds times about 340 gives the strike distance in meters.")],
  ["雷", "かみなり", "thunder", "距離", "夏"], ["lightning_hotter_than_sun", "ice_floats"],
  [("thunder", "かみなり", "雷"), ("sound", "おと", "音"), ("light", "ひかり", "光")], ["summer"])

F("nails_grow", "body", ["friends", "kids", "learning"], "hand",
  [("つめは まいにち のびる", "つめは、ゆびさきで まいにち すこしずつ のびているよ。"),
   ("爪（つめ）は毎日（まいにち）のびている", "手（て）の爪（つめ）は1か月（げつ）に約（やく）3ミリのびます。足（あし）の爪（つめ）よりも、手（て）の爪（つめ）のほうが早（はや）くのびます。"),
   ("手の爪は、1か月に約3mm伸びる", "手の爪は1日に約0.1mm、1か月に約3mmのペースで伸びるとされます。足の爪は手より遅く、冬よりも夏のほうが少し早く伸びる傾向があります。")],
  [("Nails keep growing", "Your fingernails grow a tiny bit every day."),
   ("Your nails grow every day", "Fingernails grow about 3 millimeters a month. They grow faster than toenails."),
   ("Fingernails grow about 3 mm a month", "Fingernails grow around 0.1 mm a day, roughly 3 mm a month. Toenails grow more slowly, and growth is a little faster in summer."),
   ("Fingernails grow roughly 0.1 mm per day", "Fingernails extend about 3 mm per month, faster than toenails, with a slight seasonal speed-up in warm weather.")],
  ["爪", "つめ", "nail", "手", "成長"], ["goosebumps_cold", "baby_bones"],
  [("nail", "つめ", "爪"), ("hand", "て", "手"), ("grow", "のびる", "伸びる")])

F("brain_energy", "body", ["friends", "kids", "learning"], "brain",
  [("のうは エネルギーを つかう", "のうは からだの なかで、いちばん エネルギーを つかう ばしょの ひとつだよ。"),
   ("脳（のう）はたくさんエネルギーを使（つか）う", "脳（のう）の重（おも）さは体（からだ）の約（やく）2パーセントですが、体（からだ）全体（ぜんたい）の約（やく）2割（わり）のエネルギーを使（つか）います。"),
   ("脳は体重の約2%で、エネルギーの約2割を使う", "脳の重さは体重の約2%ですが、安静時に消費するエネルギーは全体の約20%にのぼります。主なエネルギー源はブドウ糖です。")],
  [("The brain uses lots of energy", "Your brain is one of the biggest energy users in your body."),
   ("The brain uses a lot of energy", "Your brain is about 2 percent of your weight but uses about 20 percent of your energy."),
   ("The brain is 2% of weight but uses 20% of energy", "At rest, the brain burns about a fifth of the body's energy. Its main fuel is glucose, a kind of sugar."),
   ("The brain consumes about 20% of resting energy", "Though only about 2% of body mass, the brain accounts for roughly 20% of resting energy use, relying mainly on glucose.")],
  ["脳", "のう", "brain", "エネルギー", "ブドウ糖"], ["nails_grow", "goosebumps_cold"],
  [("brain", "のう", "脳"), ("energy", "エネルギー", ""), ("sugar", "さとう", "糖")])

F("blink_times", "body", ["friends", "kids", "learning"], "eye",
  [("まばたきは なんかい？", "ひとは 1にちに なんまんかいも まばたきを するよ。"),
   ("まばたきは1日（にち）に何万回（なんまんかい）", "人（ひと）は1分間（ふんかん）に約（やく）15から20回（かい）まばたきをします。1日（にち）では15000回（かい）以上（いじょう）になります。"),
   ("まばたきは1分間に約15〜20回", "人は1分間に平均15〜20回まばたきをします。目の表面を涙で潤し、ほこりを洗い流すためで、画面を集中して見ていると回数が減ります。")],
  [("How often do you blink?", "You blink many thousands of times every day."),
   ("Blinking all day long", "People blink about 15 to 20 times a minute. That is over 15,000 times a day."),
   ("People blink about 15 to 20 times a minute", "Blinking spreads tears over the eye and washes away dust. You blink less when staring at a screen."),
   ("Average blink rate is 15 to 20 per minute", "Blinks keep the cornea moist and clear debris. Blink rate drops during intense visual focus such as screen use.")],
  ["まばたき", "瞬き", "blink", "目", "涙"], ["brain_energy", "owl_head_turn"],
  [("eye", "め", "目"), ("blink", "まばたき", "瞬き"), ("tear", "なみだ", "涙")])

F("fuji_3776", "japan", ["friends", "kids", "family", "learning"], "mountain",
  [("ふじさんの たかさ", "ふじさんは にほんで いちばん たかい やまだよ。3776メートルなんだ。"),
   ("富士山（ふじさん）は3776メートル", "富士山（ふじさん）は日本（にほん）でいちばん高（たか）い山（やま）で、高（たか）さは3776メートルです。"),
   ("富士山の標高は3776m", "富士山は日本一高い山で、標高は3776mです。")],
  [("How tall is Mt. Fuji?", "Mt. Fuji is the tallest mountain in Japan. It is 3,776 meters high!"),
   ("Mt. Fuji is 3,776 meters tall", "Mt. Fuji is the tallest mountain in Japan, at 3,776 meters."),
   ("Mt. Fuji stands 3,776 meters high", "At 3,776 meters, Mt. Fuji is Japan's highest peak."),
   ("Mt. Fuji is Japan's highest peak at 3,776 m", "Mt. Fuji's summit elevation is 3,776 m, the highest in Japan.")],
  ["富士山", "ふじさん", "Fuji", "標高", "日本"], ["japan_islands", "ice_floats"],
  [("mountain", "やま", "山"), ("Japan", "にほん", "日本"), ("tall", "たかい", "高い")])
