# AI イラストの指示文

仮の絵文字を、本番の絵に差しかえるための指示文の一覧。画像生成の AI（好きなもの）に、「共通のスタイル」と、各行の「題材」を渡す。

## 共通のスタイル（毎回つける）

> flat, friendly children's-book illustration, soft rounded shapes, gentle pastel colors with a warm off-white background removed (transparent PNG), single centered subject, thick soft outline, simple shading, cute but accurate, no text, no letters, no logos, no watermark, no people's faces unless the subject is a person, square 1:1, 1024x1024

## 進めかた

1. 各行の題材に、共通のスタイルをつけて生成する。1つずつ見て、**子どもに安全か**（こわくない、とがりすぎない、文字や商標が入っていない）を確認する。
2. 背景を透明にした PNG（1024×1024 でよい）を、`assets/illustrations/<絵の id>.png` に置く。ファイル名は、下の表の「絵の id」と同じ。
3. `python3 tool/content/make_illustration_prompts.py --sync` を実行すると、置いた画像が、アプリの一覧（`illustrationImages`）に入る。画像がない絵は、いままでどおり絵文字で出る。
4. `flutter test` と、実機（またはウェブ）で見た目を確認する。
5. 生成した画像の**権利（利用規約・商用利用）**を、使う AI のサービスで確認し、ストアの掲載ルールに合わせる。

## 絵の一覧

114 点（仮の絵文字 → 本番の絵）。

| 絵の id | いまの絵文字 | 題材（雑学のタイトル） | 指示文（題材の部分） |
|---|---|---|---|
| `airplane` | ✈️ | The black box | The black box. Illustrate the key idea of this fact: An airplane's black box is really orange! |
| `ant` | 🐜 | Ants are strong | Ants are strong. Illustrate the key idea of this fact: An ant can carry things much heavier than itself! |
| `antarctica` | 🧊 | The biggest desert | The biggest desert. Illustrate the key idea of this fact: The biggest desert in the world is icy Antarctica! |
| `apple` | 🍎 | Apples float | Apples float. Illustrate the key idea of this fact: Apples float because they have air inside! |
| `astronaut` | 🧑‍🚀 | Space is quiet | Space is quiet. Illustrate the key idea of this fact: You cannot hear sounds in space! |
| `backpack` | 🎒 | The secret behind the word randoseru | The secret behind the word randoseru. Illustrate the key idea of this fact: The word comes from "ransel," a Dutch word for a backpack. |
| `bamboo` | 🎋 | Bamboo grows fast | Bamboo grows fast. Illustrate the key idea of this fact: Bamboo can grow about one meter in a single day! |
| `banana` | 🍌 | What is a banana? | What is a banana. Illustrate the key idea of this fact: A banana is a kind of berry! |
| `basketball` | 🏀 | A basketball hoop is high up | A basketball hoop is high up. Illustrate the key idea of this fact: A basketball hoop is 10 feet, or 3.05 meters, above the floor. |
| `bat` | 🦇 | Bat ears | Bat ears. Illustrate the key idea of this fact: A bat makes sounds and listens for the echoes to find things! |
| `bee` | 🐝 | Bees dance | Bees dance. Illustrate the key idea of this fact: Honeybees dance to tell friends where flowers are! |
| `beethoven` | 🎼 | Beethoven kept making music as his hearing faded | Beethoven kept making music as his hearing faded. Illustrate the key idea of this fact: Beethoven could hear less and less. He still kept writing music. |
| `beetle` | 🪲 | Beetles are everywhere | Beetles are everywhere. Illustrate the key idea of this fact: There are more kinds of beetles than almost any other animal! |
| `bicycle` | 🚲 | The first bicycle | The first bicycle. Illustrate the key idea of this fact: The very first bicycle had no pedals! |
| `brain` | 🧠 | The brain uses lots of energy | The brain uses lots of energy. Illustrate the key idea of this fact: Your brain is one of the biggest energy users in your body. |
| `bridge` | 🌉 | The Golden Gate Bridge is not gold | The Golden Gate Bridge is not gold. Illustrate the key idea of this fact: The Golden Gate Bridge is not gold. It is a reddish orange color. |
| `butterfly` | 🦋 | Butterflies taste with their feet | Butterflies taste with their feet. Illustrate the key idea of this fact: Butterflies can taste with their feet! |
| `cacao` | 🍫 | Cacao as money | Cacao as money. Illustrate the key idea of this fact: Long ago, people used cacao beans like money! |
| `camel` | 🐫 | Camel humps | Camel humps. Illustrate the key idea of this fact: A camel's hump holds fat, not water! |
| `carrot` | 🥕 | Old carrots | Old carrots. Illustrate the key idea of this fact: Long ago, many carrots were purple or yellow! |
| `cat` | 🐱 | Cats and sweet foods | Cats and sweet foods. Illustrate the key idea of this fact: Cats cannot taste sweet things. |
| `cicada` | 🪲 | Cicadas wait underground | Cicadas wait underground. Illustrate the key idea of this fact: Some cicadas stay underground for 17 years! |
| `coin1` | 🪙 | A 1-yen coin can float | A 1-yen coin can float. Illustrate the key idea of this fact: If you set it down gently and flat, it floats on water. |
| `coin5` | 🪙 | The 5-yen coin has a hole | The 5-yen coin has a hole. Illustrate the key idea of this fact: It has a hole in the middle so it is not mixed up with other coins. |
| `container` | 📦 | Ships carry things | Ships carry things. Illustrate the key idea of this fact: Ships carry most of the world's goods! |
| `coral` | 🪸 | Coral is an animal | Coral is an animal. Illustrate the key idea of this fact: Coral is not a plant or a rock. It is a kind of animal. |
| `cricket` | 🦗 | Singing insects | Singing insects. Illustrate the key idea of this fact: In autumn, only the boy insects sing, by rubbing their wings! |
| `crow` | 🐦‍⬛ | Crows remember faces | Crows remember faces. Illustrate the key idea of this fact: Crows can remember people's faces! |
| `dandelion` | 🌼 | Dandelion fluff flies | Dandelion fluff flies. Illustrate the key idea of this fact: Dandelion seeds have fluffy hairs that float on the wind. |
| `dna` | 🧬 | Any two people share about 99.9% of their DNA | Any two people share about 99.9% of their DNA. Illustrate the key idea of this fact: Your DNA is almost exactly the same as anyone else's. The small differences make up the variation between people. |
| `dolphin` | 🐬 | Dolphins half-sleep | Dolphins half-sleep. Illustrate the key idea of this fact: Dolphins sleep with half of their brain at a time! |
| `dragonfly` | 🪽 | Dragonflies are very old | Dragonflies are very old. Illustrate the key idea of this fact: Dragonfly relatives lived before the dinosaurs! |
| `dungbeetle` | 🪲 | Dung beetles and stars | Dung beetles and stars. Illustrate the key idea of this fact: Dung beetles use the stars to find their way! |
| `elephant` | 🐘 | Elephants talk low | Elephants talk low. Illustrate the key idea of this fact: Elephants talk with very deep sounds that people can't hear. |
| `emoji` | 😀 | Emoji began in Japan | Emoji began in Japan. Illustrate the key idea of this fact: In 1999, little pictures called emoji were made for Japanese mobile phones. |
| `eye` | 👁️ | How often do you blink? | How often do you blink. Illustrate the key idea of this fact: You blink many thousands of times every day. |
| `firefly` | ✨ | Firefly light | Firefly light. Illustrate the key idea of this fact: A firefly's light is not hot! |
| `flamingo` | 🦩 | A group of flamingos | A group of flamingos. Illustrate the key idea of this fact: A group of flamingos is called a flamboyance! |
| `flytrap` | 🪤 | The flytrap counts to two | The flytrap counts to two. Illustrate the key idea of this fact: The Venus flytrap shuts its leaf when a bug touches it two times. |
| `fog` | 🌫️ | Fog is a cloud near the ground | Fog is a cloud near the ground. Illustrate the key idea of this fact: Fog is a cloud that sits close to the ground. |
| `giraffe` | 🦒 | A giraffe's neck bones | A giraffe's neck bones. Illustrate the key idea of this fact: A giraffe has seven neck bones, just like you! |
| `hail` | 🧊 | Hail is lumps of ice | Hail is lumps of ice. Illustrate the key idea of this fact: Hail is ice that falls from thundercloud. |
| `hand` | ✋ | Nails keep growing | Nails keep growing. Illustrate the key idea of this fact: Your fingernails grow a tiny bit every day. |
| `heart` | ❤️ | A busy heart / Goosebumps in the cold | A busy heart. Illustrate the key idea of this fact: Your heart beats about 100,000 times every day! |
| `honey` | 🍯 | Does honey go bad? | Does honey go bad. Illustrate the key idea of this fact: Honey can last a very, very long time! |
| `ice` | 🧊 | Ice floats | Ice floats. Illustrate the key idea of this fact: Ice is lighter than water, so it floats! |
| `iss` | 🛰️ | A day in space | A day in space. Illustrate the key idea of this fact: On the space station, the Sun rises many times a day! |
| `japan` | 🗾 | How many islands in Japan? | How many islands in Japan. Illustrate the key idea of this fact: Japan has more than 14,000 islands! |
| `jellyfish` | 🪼 | Jellyfish have no brain | Jellyfish have no brain. Illustrate the key idea of this fact: A jellyfish has no brain, but it can still float and swim in the sea. |
| `koala` | 🐨 | Koalas have fingerprints | Koalas have fingerprints. Illustrate the key idea of this fact: Koalas have fingerprints just like people! |
| `ladybug` | 🐞 | Ladybug spots | Ladybug spots. Illustrate the key idea of this fact: You can't tell a ladybug's age by counting its spots! |
| `lightning` | ⚡ | Lightning is hot / How far is the thunder? | Lightning is hot. Illustrate the key idea of this fact: Lightning is hotter than the surface of the Sun! |
| `maglev` | 🚅 | Floating trains | Floating trains. Illustrate the key idea of this fact: The maglev train floats a little and goes very fast! |
| `maple` | 🍁 | Why do leaves turn red? | Why do leaves turn red. Illustrate the key idea of this fact: In fall, when it gets cold, some leaves turn red! |
| `marathon` | 🏃 | A marathon is 42.195 km | A marathon is 42.195 km. Illustrate the key idea of this fact: A marathon is a very long run of 42.195 kilometers. |
| `mimosa` | 🌱 | The shy plant folds up | The shy plant folds up. Illustrate the key idea of this fact: The sensitive plant folds its leaves when you touch it. |
| `moon` | 🌙 | The Moon is drifting away | The Moon is drifting away. Illustrate the key idea of this fact: The Moon is moving a tiny bit farther from Earth. |
| `mosquito` | 🦟 | Mosquito bites | Mosquito bites. Illustrate the key idea of this fact: Only girl mosquitoes bite people! |
| `mountain` | 🏔️ | Everest isn't the farthest peak from Earth's center / How tall is Mt. Fuji? | Everest isn't the farthest peak from Earth's center. Illustrate the key idea of this fact: Mount Everest is the highest above sea level, but Ecuador's Chimborazo is farther from the center of the Earth, because the planet bulges at the equator. |
| `noodles` | 🍜 | Instant noodles began in 1958 | Instant noodles began in 1958. Illustrate the key idea of this fact: A man in Japan made noodles you just add hot water to. |
| `octopus` | 🐙 | What color is an octopus's blood? | What color is an octopus's blood. Illustrate the key idea of this fact: An octopus has blue blood! And it has three hearts. |
| `opera` | 🎭 | The Opera House roof has lots of tiles | The Opera House roof has lots of tiles. Illustrate the key idea of this fact: The roof of the Sydney Opera House has more than one million tiles. |
| `otter` | 🦦 | Sea otters hold hands | Sea otters hold hands. Illustrate the key idea of this fact: Sea otters sometimes hold hands when they sleep! |
| `owl` | 🦉 | Owls turn their heads | Owls turn their heads. Illustrate the key idea of this fact: An owl can turn its head almost all the way around! |
| `peanut` | 🥜 | Peanuts are beans | Peanuts are beans. Illustrate the key idea of this fact: A peanut is not a nut. It is in the bean family! |
| `penguin` | 🐧 | Penguins snuggle up | Penguins snuggle up. Illustrate the key idea of this fact: Emperor penguins huddle together to stay warm in winter! |
| `pi` | ⭕ | Every circle is about 3.14 times around as wide | Every circle is about 3.14 times around as wide. Illustrate the key idea of this fact: Walk around any circle and it is about 3.14 times as long as the circle is wide. |
| `piano` | 🎹 | A piano has 88 keys | A piano has 88 keys. Illustrate the key idea of this fact: A normal piano has 88 keys. Some are white and some are black. |
| `pineapple` | 🍍 | Pineapples take time | Pineapples take time. Illustrate the key idea of this fact: A pineapple needs about two years to grow! |
| `pingpong` | 🏓 | A table tennis ball is 40 mm | A table tennis ball is 40 mm. Illustrate the key idea of this fact: A table tennis ball is small and round. It is 40 millimeters wide. |
| `pisa` | 🏛️ | The Pisa tower leaned while being built | The Pisa tower leaned while being built. Illustrate the key idea of this fact: The ground was soft, so the tower started to tilt as people built it. |
| `plane` | ✈️ | Airplanes fly high | Airplanes fly high. Illustrate the key idea of this fact: Airplanes fly very high, where it is very cold. |
| `popcorn` | 🍿 | Why does popcorn pop? | Why does popcorn pop. Illustrate the key idea of this fact: The water inside makes popcorn pop when it gets hot! |
| `postit` | 📝 | Sticky notes began as a mistake | Sticky notes began as a mistake. Illustrate the key idea of this fact: A glue that was too weak turned into a handy note. |
| `prime` | 2️⃣ | 2 is the only even prime | 2 is the only even prime. Illustrate the key idea of this fact: Among prime numbers, only 2 can be divided by 2. |
| `rainbow` | 🌈 | Rainbows are circles | Rainbows are circles. Illustrate the key idea of this fact: A rainbow is really a circle! |
| `redwood` | 🌲 | The tallest tree | The tallest tree. Illustrate the key idea of this fact: Redwood trees can grow taller than a 30-story building. |
| `rice` | 🍚 | Rice around the world | Rice around the world. Illustrate the key idea of this fact: Rice is the main food for many people! |
| `rings` | 🏅 | The Olympics have five rings | The Olympics have five rings. Illustrate the key idea of this fact: The Olympic symbol has five rings. They stand for five parts of the world. |
| `rocket` | 🚀 | Rockets are fast | Rockets are fast. Illustrate the key idea of this fact: Rockets go super fast to reach space! |
| `salmon` | 🐟 | Salmon come home | Salmon come home. Illustrate the key idea of this fact: Salmon swim back to the river where they were born in autumn! |
| `saturn` | 🪐 | Would Saturn float? | Would Saturn float. Illustrate the key idea of this fact: Saturn is so light that it would float in water, if there were a giant bathtub! |
| `seahorse` | 🐴 | Seahorse dads carry the babies | Seahorse dads carry the babies. Illustrate the key idea of this fact: A seahorse dad keeps the eggs safe in a pouch on his tummy. |
| `shark` | 🦈 | Sharks are very old | Sharks are very old. Illustrate the key idea of this fact: Sharks lived in the sea before there were trees! |
| `ship` | 🚢 | Why do steel ships float? | Why do steel ships float. Illustrate the key idea of this fact: Steel is heavy, but ships float! |
| `silkworm` | 🐛 | Silkworm thread | Silkworm thread. Illustrate the key idea of this fact: A silkworm cocoon is made of one long thread! |
| `skeleton` | 🦴 | A baby has more bones | A baby has more bones. Illustrate the key idea of this fact: Babies have more bones than grown-ups! |
| `skytree` | 🗼 | Skytree is 634 meters tall | Skytree is 634 meters tall. Illustrate the key idea of this fact: In Japanese, 6-3-4 can be read as "mu-sa-shi," an old name for the area. |
| `sloth` | 🦥 | Sloths are slow | Sloths are slow. Illustrate the key idea of this fact: A sloth moves very slowly and goes to the bathroom about once a week! |
| `snow` | ❄️ | Snowflakes have six sides | Snowflakes have six sides. Illustrate the key idea of this fact: Most snow crystals are shaped like little six-sided stars. |
| `spider` | 🕷️ | Is a spider an insect? | Is a spider an insect. Illustrate the key idea of this fact: A spider has 8 legs. An insect has 6 legs! |
| `squirrel` | 🐿️ | Squirrels and acorns | Squirrels and acorns. Illustrate the key idea of this fact: Squirrels bury acorns in autumn. The ones they forget can grow into trees! |
| `strawberry` | 🍓 | Strawberry dots | Strawberry dots. Illustrate the key idea of this fact: The little dots on a strawberry are the real fruits! |
| `subway` | 🚇 | Asia's first subway | Asia's first subway. Illustrate the key idea of this fact: Japan built the first subway in Asia! |
| `sun` | ☀️ | Sunlight takes a trip | Sunlight takes a trip. Illustrate the key idea of this fact: Sunlight needs a little time to reach Earth. |
| `sunflower` | 🌻 | Sunflowers face the sun | Sunflowers face the sun. Illustrate the key idea of this fact: Young sunflowers turn toward the sun all day long. |
| `theremin` | 👋 | You play the theremin without touching it | You play the theremin without touching it. Illustrate the key idea of this fact: The theremin is played without touching it. You move your hands in the air to change the sound. |
| `tower` | 🗼 | The Eiffel Tower grows | The Eiffel Tower grows. Illustrate the key idea of this fact: The Eiffel Tower gets a little taller when it is hot! |
| `train` | 🚄 | The start of the Shinkansen / Bullet train and kingfisher | The start of the Shinkansen. Illustrate the key idea of this fact: The Shinkansen started running in 1964! |
| `tree` | 🌳 | A tree's rings | A tree's rings. Illustrate the key idea of this fact: Cut a tree and you can see rings. Count them to find its age! |
| `triangle` | 🔺 | A triangle's corners add up to 180 | A triangle's corners add up to 180. Illustrate the key idea of this fact: Add the three corners of any flat triangle and you get 180 degrees. |
| `tuning` | 🎼 | The note A is 440 hertz | The note A is 440 hertz. Illustrate the key idea of this fact: To tune instruments, musicians often set the note A to 440 hertz. |
| `typhoon` | 🌀 | A typhoon has a calm middle | A typhoon has a calm middle. Illustrate the key idea of this fact: The middle of a typhoon is called the eye. It can be calm. |
| `velcro` | 🧷 | Velcro came from a dog's fur | Velcro came from a dog's fur. Illustrate the key idea of this fact: A sticky plant seed gave a man a big idea. |
| `venus` | 🪐 | A day on Venus is very long | A day on Venus is very long. Illustrate the key idea of this fact: Venus spins so slowly that one day lasts a very long time. |
| `wasabi` | 🌿 | Wasabi is spicy | Wasabi is spicy. Illustrate the key idea of this fact: Wasabi's spice goes up your nose! |
| `watermelon` | 🍉 | Watermelon is water | Watermelon is water. Illustrate the key idea of this fact: A watermelon is almost all water! |
| `whale` | 🐋 | The blue whale is the biggest animal | The blue whale is the biggest animal. Illustrate the key idea of this fact: The blue whale is the biggest animal we know of. It lives in the ocean. |
| `wind` | 🌬️ | A north wind comes from the north | A north wind comes from the north. Illustrate the key idea of this fact: A north wind is wind that blows from the north. |
| `window` | 🪟 | The hole in the airplane window | The hole in the airplane window. Illustrate the key idea of this fact: There is a tiny hole in an airplane window! |
| `wombat` | 🐾 | Wombat poop | Wombat poop. Illustrate the key idea of this fact: Wombat poop is shaped like little cubes! |
| `wright` | 🛩️ | The first airplane | The first airplane. Illustrate the key idea of this fact: The first airplane flew for only 12 seconds! |
| `zero` | 0️⃣ | Zero means nothing | Zero means nothing. Illustrate the key idea of this fact: Adding zero to a number does not change it. |
| `zipper` | 🤐 | The zipper took shape around 1913 | The zipper took shape around 1913. Illustrate the key idea of this fact: A Swedish-born man made a zipper much like today's. |
