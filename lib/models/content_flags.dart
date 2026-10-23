import 'age_band.dart';

/// 雑学の「話題の種類」のタグ。該当するものを雑学ごとに付ける（なければ空）。
/// 年代ごとに配信を止める話題を [blockedFlagsFor] で決める。
const validContentFlags = {
  'sexual', //     性的な話題
  'violence', //   暴力・流血・傷害
  'war', //        戦争・兵器・テロ
  'death', //      死・事故・災害の被害
  'religion', //   宗教・信仰
  'politics', //   政治・選挙・国どうしの対立
  'drugs_alcohol', // 酒・たばこ・薬物
  'gambling', //   賭け事
  'horror', //     怖い・不気味な話題
  'discrimination', // 差別につながりうる話題
  'crime', //      犯罪
  'medical', //    病気・治療（医療の助言になりうるもの）
};

/// その年代に出さない話題。
/// - Kids / Junior（13歳未満）: すべて出さない（難しい・刺激の強い話題はすべて）
/// - Teen: 性・暴力・酒たばこ薬物・賭け事・怖い・差別
/// - Adult: 性的な話題のみ（一般向けの雑学アプリのため）
Set<String> blockedFlagsFor(AgeBand band) => switch (band) {
      AgeBand.kids || AgeBand.junior => validContentFlags,
      AgeBand.teen => const {
          'sexual', 'violence', 'drugs_alcohol', 'gambling', 'horror', 'discrimination',
        },
      AgeBand.adult => const {'sexual'},
    };
