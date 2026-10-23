// 日本語の「表記」を、モード（年代）で変えるための、AppLocalizationsJa の派生クラス。
// - AppLocalizationsJa（基本）: ひらがなと分かち書き（Kids）
// - AppLocalizationsJaJunior: 基本から、スペースを取り、小学1〜3年の漢字のことばを漢字にした表記（Junior）
// - AppLocalizationsJaTeen: 漢字まじりで、すこしくだけた言い回し（Teen）
// - AppLocalizationsJaAdult: 漢字まじりの、ふつうの表記（Adult）
// このファイルは tool/gen_ja_styles.py で作る。ひらがなの文言を足したら、tool/ja_adult.tsv にも書いて作り直す。
// ignore_for_file: type=lint

import 'app_localizations_ja.dart';

/// 日本語どうしの間にあるスペースを取る（数字やアルファベットの前後のスペースは残す）。
final _jaSpace = RegExp(
    r'(?<=[\u3040-\u30ff\u4e00-\u9fff！？。、「」…ー])[ \u3000]+(?=[\u3040-\u30ff\u4e00-\u9fff！？。、「」…ー])');
/// ことばの前が「ひらがな」でなく、後ろが助詞・記号・終わりのとき、1つのことばとみなす
/// （「おおきく」の中の「きく」や、「います」の中の「いま」を、漢字にしないため）。
const _wordAfter = r'(?=[はがをにへでとのもやかよねなご、。！？…「」\s]|$|[0-9A-Za-z])';

final _juniorWordRegexps = [
  for (final (from, to) in _juniorWords)
    (RegExp('(?<![\u3040-\u309f])$from$_wordAfter'), to),
];

final _juniorDigitRegexps = [
  for (final (from, to) in _juniorAfterDigit) (RegExp('(?<=[0-9])$from$_wordAfter'), to),
];

/// Junior: 先に、スペースで分かれたことばごとに漢字にして、そのあとスペースを取る。
String _jr(String s) {
  var t = s;
  for (final (re, to) in _juniorWordRegexps) {
    t = t.replaceAll(re, to);
  }
  for (final (re, to) in _juniorDigitRegexps) {
    t = t.replaceAll(re, to);
  }
  return t.replaceAll(_jaSpace, '');
}

/// Junior の表記で漢字にする、よく使うことば（小学1〜3年で習う漢字だけ）。
const _juniorWords = <(String, String)>[
  ('まいにち', '毎日'),
  ('こんしゅう', '今週'),
  ('せんしゅう', '先週'),
  ('いっしゅうかん', '1週間'),
  ('1しゅうかん', '1週間'),
  ('きょう', '今日'),
  ('あした', '明日'),
  ('あそぶ', '遊ぶ'),
  ('あそんだ', '遊んだ'),
  ('あそんで', '遊んで'),
  ('あそべる', '遊べる'),
  ('あそぼう', '遊ぼう'),
  ('あつめる', '集める'),
  ('もんだい', '問題'),
  ('みつけた', '見つけた'),
  ('みるほど', '見るほど'),
  ('みると', '見ると'),
  ('みる', '見る'),
  ('よんだ', '読んだ'),
  ('よんで', '読んで'),
  ('よむ', '読む'),
  ('きく', '聞く'),
  ('ほんとう', '本当'),
  ('ほんと', '本当'),
  ('こたえ', '答え'),
  ('ことば', '言葉'),
  ('はやく', '早く'),
  ('あたらしく', '新しく'),
  ('ぜんぶ', '全部'),
  ('ともだち', '友だち'),
  ('おとな', '大人'),
  ('こども', '子ども'),
  ('ひとつ', '一つ'),
  ('すこしずつ', '少しずつ'),
  ('いちばん', '一番'),
  ('あんぜん', '安全'),
  ('つかう', '使う'),
  ('はじめる', '始める'),
  ('おわる', '終わる'),
  ('かぞく', '家族'),
  ('からだ', '体'),
  ('むし', '虫'),
  ('たべもの', '食べ物'),
  ('のりもの', '乗り物'),
  ('どうぶつ', '動物'),
  ('ちり', '地理'),
  ('かがく', '科学'),
  ('がくしゅう', '学習'),
  ('ちゅうい', '注意'),
  ('ぜんもん', '全問'),
  ('もういちど', 'もう一度'),
  ('おなじ', '同じ'),
  ('しらなかった', '知らなかった'),
  ('しれたこと', '知れたこと'),
  ('しれた', '知れた'),
  ('しってた', '知ってた'),
  ('おくりません', '送りません'),
  ('つくっています', '作っています'),
  ('まわして', '回して'),
  ('でてくる', '出てくる'),
  ('だせる', '出せる'),
  ('そとには', '外には'),
  ('ひとり', '一人'),
  ('つぎ', '次'),
  ('まえ', '前'),
  ('いま', '今'),
  ('かち', '勝ち'),
];

/// 数字のあとの「にち・もん」など。
const _juniorAfterDigit = <(String, String)>[
  ('にちかん', '日間'),
  ('しゅうかん', '週間'),
  ('にち', '日'),
  ('もん', '問'),
  ('かい', '回'),
  ('ふん', '分'),
  ('にん', '人'),
  ('てん', '点'),
  ('しょう', '勝'),
  ('びょう', '秒'),
];

/// Junior の表記に出てくる漢字（テストで、小学1〜3年の漢字だけか確かめる）。
const juniorKanji = '一乗人今体作使先全出分前動勝友同問回地外大始子学安家少度当意新族日早明本次毎注点物理番知科秒答終習聞葉虫見言読送週遊部間集題食';

class AppLocalizationsJaJunior extends AppLocalizationsJa {
  AppLocalizationsJaJunior([super.locale]);

  @override
  String get continueButton => _jr(super.continueButton);

  @override
  String get interestsTitle => _jr(super.interestsTitle);

  @override
  String get interestsAll => _jr(super.interestsAll);

  @override
  String get catAnimals => _jr(super.catAnimals);

  @override
  String get catSpace => _jr(super.catSpace);

  @override
  String get catBody => _jr(super.catBody);

  @override
  String get catNature => _jr(super.catNature);

  @override
  String get catScience => _jr(super.catScience);

  @override
  String get catGeography => _jr(super.catGeography);

  @override
  String get sceneKids => _jr(super.sceneKids);

  @override
  String get kidsNext => _jr(super.kidsNext);

  @override
  String get kidsListen => _jr(super.kidsListen);

  @override
  String get copied => _jr(super.copied);

  @override
  String get ratingHeh => _jr(super.ratingHeh);

  @override
  String get gateOk => _jr(super.gateOk);

  @override
  String get gateCancel => _jr(super.gateCancel);

  @override
  String get catBugs => _jr(super.catBugs);

  @override
  String get catVehicles => _jr(super.catVehicles);

  @override
  String get catFood => _jr(super.catFood);

  @override
  String get quizButton => _jr(super.quizButton);

  @override
  String get quizTitle => _jr(super.quizTitle);

  @override
  String get quizTrue => _jr(super.quizTrue);

  @override
  String get quizFalse => _jr(super.quizFalse);

  @override
  String get quizCorrect => _jr(super.quizCorrect);

  @override
  String get quizWrong => _jr(super.quizWrong);

  @override
  String get quizNext => _jr(super.quizNext);

  @override
  String get timingSection => _jr(super.timingSection);

  @override
  String reasonSeason(String season) => _jr(super.reasonSeason(season));

  @override
  String get whyButton => _jr(super.whyButton);

  @override
  String get mythsTitle => _jr(super.mythsTitle);

  @override
  String mythAnswerIs(String verdict) => _jr(super.mythAnswerIs(verdict));

  @override
  String get mythRead => _jr(super.mythRead);

  @override
  String mythResult(int correct, int total) => _jr(super.mythResult(correct, total));

  @override
  String get mythAgain => _jr(super.mythAgain);

  @override
  String get mythNone => _jr(super.mythNone);

  @override
  String get mythNext => _jr(super.mythNext);

  @override
  String get mythFinish => _jr(super.mythFinish);

  @override
  String get todayNone => _jr(super.todayNone);

  @override
  String get todayUpcoming => _jr(super.todayUpcoming);

  @override
  String get listenNext => _jr(super.listenNext);

  @override
  String get listenPrev => _jr(super.listenPrev);

  @override
  String get listenSlow => _jr(super.listenSlow);

  @override
  String get listenNormal => _jr(super.listenNormal);

  @override
  String get listenFast => _jr(super.listenFast);

  @override
  String get projectNeedsAdult => _jr(super.projectNeedsAdult);

  @override
  String get projectDifficulty => _jr(super.projectDifficulty);

  @override
  String get projectMaterials => _jr(super.projectMaterials);

  @override
  String get projectSteps => _jr(super.projectSteps);

  @override
  String get projectObserve => _jr(super.projectObserve);

  @override
  String get projectSafety => _jr(super.projectSafety);

  @override
  String get privacyTitle => _jr(super.privacyTitle);

  @override
  String get privacyDeleteCancel => _jr(super.privacyDeleteCancel);

  @override
  String get battleTitle => _jr(super.battleTitle);

  @override
  String get battlePlayers => _jr(super.battlePlayers);

  @override
  String get battleSolo => _jr(super.battleSolo);

  @override
  String battlePlayerCount(int n) => _jr(super.battlePlayerCount(n));

  @override
  String get battleRounds => _jr(super.battleRounds);

  @override
  String battleRoundCount(int n) => _jr(super.battleRoundCount(n));

  @override
  String get battleHandHint => _jr(super.battleHandHint);

  @override
  String get battleStart => _jr(super.battleStart);

  @override
  String get battleNoQuestions => _jr(super.battleNoQuestions);

  @override
  String battleRoundOf(int n, int total) => _jr(super.battleRoundOf(n, total));

  @override
  String battleTurnOf(String name) => _jr(super.battleTurnOf(name));

  @override
  String get battleSeeResult => _jr(super.battleSeeResult);

  @override
  String get battleFinished => _jr(super.battleFinished);

  @override
  String battleSoloScore(int score, int total) => _jr(super.battleSoloScore(score, total));

  @override
  String get battleDraw => _jr(super.battleDraw);

  @override
  String battleWinner(String name) => _jr(super.battleWinner(name));

  @override
  String battleRank(int n) => _jr(super.battleRank(n));

  @override
  String get battleAgain => _jr(super.battleAgain);

  @override
  String get battleChangeSettings => _jr(super.battleChangeSettings);

  @override
  String get battleExit => _jr(super.battleExit);

  @override
  String get battleKind => _jr(super.battleKind);

  @override
  String get battleKindAll => _jr(super.battleKindAll);

  @override
  String get battleKindChoice => _jr(super.battleKindChoice);

  @override
  String get battleGenreAll => _jr(super.battleGenreAll);

  @override
  String get battleTimeLimit => _jr(super.battleTimeLimit);

  @override
  String get battleTimeOff => _jr(super.battleTimeOff);

  @override
  String battleSeconds(int n) => _jr(super.battleSeconds(n));

  @override
  String battleSecondsLeft(int n) => _jr(super.battleSecondsLeft(n));

  @override
  String get battleTimeHint => _jr(super.battleTimeHint);

  @override
  String battleCorrectIs(String answer) => _jr(super.battleCorrectIs(answer));

  @override
  String battlePoints(int n) => _jr(super.battlePoints(n));

  @override
  String get reviewTitle => _jr(super.reviewTitle);

  @override
  String get reviewNone => _jr(super.reviewNone);

  @override
  String get reviewDoneNote => _jr(super.reviewDoneNote);

  @override
  String get reviewChip => _jr(super.reviewChip);

  @override
  String reviewChipCount(int n) => _jr(super.reviewChipCount(n));

  @override
  String get dailyTitle => _jr(super.dailyTitle);

  @override
  String dailyStreak(int n) => _jr(super.dailyStreak(n));

  @override
  String get dailyComeBack => _jr(super.dailyComeBack);

  @override
  String get dailyShare => _jr(super.dailyShare);

  @override
  String badgesCount(int n, int total) => _jr(super.badgesCount(n, total));

  @override
  String badgeStreak(int n) => _jr(super.badgeStreak(n));

  @override
  String badgeReadDays(int n) => _jr(super.badgeReadDays(n));

  @override
  String badgeLearned(int n) => _jr(super.badgeLearned(n));

  @override
  String badgeQuiz(int n) => _jr(super.badgeQuiz(n));

  @override
  String badgeDaily(int n) => _jr(super.badgeDaily(n));

  @override
  String get badgePerfect => _jr(super.badgePerfect);

  @override
  String get reportTitle => _jr(super.reportTitle);

  @override
  String get reportNote => _jr(super.reportNote);

  @override
  String get reportLearned => _jr(super.reportLearned);

  @override
  String get reportKnew => _jr(super.reportKnew);

  @override
  String get reportQuiz => _jr(super.reportQuiz);

  @override
  String get reportNoQuiz => _jr(super.reportNoQuiz);

  @override
  String get reportReviewPending => _jr(super.reportReviewPending);

  @override
  String get reportFavorite => _jr(super.reportFavorite);

  @override
  String get reportEmpty => _jr(super.reportEmpty);

  @override
  String get reportRecent => _jr(super.reportRecent);

  @override
  String get reportOpen => _jr(super.reportOpen);

  @override
  String get mascotTitle => _jr(super.mascotTitle);

  @override
  String mascotNext(int n, String name) => _jr(super.mascotNext(n, name));

  @override
  String get mascotMax => _jr(super.mascotMax);

  @override
  String get mascotHint => _jr(super.mascotHint);

  @override
  String get mascotName_egg => _jr(super.mascotName_egg);

  @override
  String get mascotSay_egg => _jr(super.mascotSay_egg);

  @override
  String get mascotName_chick => _jr(super.mascotName_chick);

  @override
  String get mascotSay_chick => _jr(super.mascotSay_chick);

  @override
  String get mascotName_chicklet => _jr(super.mascotName_chicklet);

  @override
  String get mascotSay_chicklet => _jr(super.mascotSay_chicklet);

  @override
  String get mascotName_owl => _jr(super.mascotName_owl);

  @override
  String get mascotSay_owl => _jr(super.mascotSay_owl);

  @override
  String get mascotName_professor => _jr(super.mascotName_professor);

  @override
  String get mascotSay_professor => _jr(super.mascotSay_professor);

  @override
  String get mascotName_king => _jr(super.mascotName_king);

  @override
  String get mascotSay_king => _jr(super.mascotSay_king);

  @override
  String celebrateStage(String name) => _jr(super.celebrateStage(name));

  @override
  String get celebrateBadge => _jr(super.celebrateBadge);

  @override
  String get flipHint => _jr(super.flipHint);

  @override
  String get flipDetail => _jr(super.flipDetail);

  @override
  String get zukanTitle => _jr(super.zukanTitle);

  @override
  String get zukanChip => _jr(super.zukanChip);

  @override
  String zukanFound(int n, int total) => _jr(super.zukanFound(n, total));

  @override
  String get zukanAll => _jr(super.zukanAll);

  @override
  String get zukanHint => _jr(super.zukanHint);

  @override
  String get capsuleTitle => _jr(super.capsuleTitle);

  @override
  String get capsuleOpen => _jr(super.capsuleOpen);

  @override
  String get capsuleHint => _jr(super.capsuleHint);

  @override
  String get capsuleDone => _jr(super.capsuleDone);

  @override
  String get capsuleNew => _jr(super.capsuleNew);

  @override
  String get capsuleToZukan => _jr(super.capsuleToZukan);

  @override
  String get capsuleEmpty => _jr(super.capsuleEmpty);

  @override
  String get capsuleRarity1 => _jr(super.capsuleRarity1);

  @override
  String get swipeTitle => _jr(super.swipeTitle);

  @override
  String get swipeHint => _jr(super.swipeHint);

  @override
  String swipeCombo(int n) => _jr(super.swipeCombo(n));

  @override
  String swipeBestCombo(int n) => _jr(super.swipeBestCombo(n));

  @override
  String get tabPlay => _jr(super.tabPlay);

  @override
  String get tabCollect => _jr(super.tabCollect);

  @override
  String get tabExplore => _jr(super.tabExplore);

  @override
  String get tabSettings => _jr(super.tabSettings);

  @override
  String get hubPlayIntro => _jr(super.hubPlayIntro);

  @override
  String get hubCollectIntro => _jr(super.hubCollectIntro);

  @override
  String get hubExploreIntro => _jr(super.hubExploreIntro);

  @override
  String get hubSwipeSub => _jr(super.hubSwipeSub);

  @override
  String get hubDailySub => _jr(super.hubDailySub);

  @override
  String get hubReviewSub => _jr(super.hubReviewSub);

  @override
  String get hubMythsSub => _jr(super.hubMythsSub);

  @override
  String get hubLibrarySub => _jr(super.hubLibrarySub);

  @override
  String get wordTitle => _jr(super.wordTitle);

  @override
  String get wordSimple => _jr(super.wordSimple);

  @override
  String get wordDetail => _jr(super.wordDetail);

  @override
  String get wordFacts => _jr(super.wordFacts);

  @override
  String get wordNotFound => _jr(super.wordNotFound);

  @override
  String get wordsTitle => _jr(super.wordsTitle);

  @override
  String wordsFound(int n, int total) => _jr(super.wordsFound(n, total));

  @override
  String get wordOfDay => _jr(super.wordOfDay);

  @override
  String get wordQuizTitle => _jr(super.wordQuizTitle);

  @override
  String wordQuizQuestion(String term) => _jr(super.wordQuizQuestion(term));

  @override
  String get wordsHint => _jr(super.wordsHint);

  @override
  String get mapTitle => _jr(super.mapTitle);

  @override
  String mapLinkCount(int n) => _jr(super.mapLinkCount(n));

  @override
  String get mapNoLinks => _jr(super.mapNoLinks);

  @override
  String get mapOpen => _jr(super.mapOpen);

  @override
  String get voiceQuizTitle => _jr(super.voiceQuizTitle);

  @override
  String get voiceReplay => _jr(super.voiceReplay);

  @override
  String get voiceQuizSub => _jr(super.voiceQuizSub);

  @override
  String get leagueTitle => _jr(super.leagueTitle);

  @override
  String get leagueNote => _jr(super.leagueNote);

  @override
  String get leagueThisWeek => _jr(super.leagueThisWeek);

  @override
  String leagueLastWinner(String name) => _jr(super.leagueLastWinner(name));

  @override
  String get leagueEmpty => _jr(super.leagueEmpty);

  @override
  String leagueGames(int n, int wins) => _jr(super.leagueGames(n, wins));

  @override
  String get leaguePlay => _jr(super.leaguePlay);

  @override
  String get leagueClear => _jr(super.leagueClear);

  @override
  String get leagueClearTitle => _jr(super.leagueClearTitle);

  @override
  String get leagueClearBody => _jr(super.leagueClearBody);

  @override
  String get leagueRecord => _jr(super.leagueRecord);

  @override
  String get leagueSub => _jr(super.leagueSub);

  @override
  String get recapTitle => _jr(super.recapTitle);

  @override
  String get recapNote => _jr(super.recapNote);

  @override
  String get recapSeen => _jr(super.recapSeen);

  @override
  String get recapLearned => _jr(super.recapLearned);

  @override
  String get recapQuiz => _jr(super.recapQuiz);

  @override
  String get recapActiveDays => _jr(super.recapActiveDays);

  @override
  String get recapMsgNone => _jr(super.recapMsgNone);

  @override
  String get recapMsgSome => _jr(super.recapMsgSome);

  @override
  String get recapMsgGreat => _jr(super.recapMsgGreat);

  @override
  String get recapChip => _jr(super.recapChip);

  @override
  String get recapBanner => _jr(super.recapBanner);

  @override
  String get stampsTitle => _jr(super.stampsTitle);

  @override
  String get stampsChip => _jr(super.stampsChip);

  @override
  String stampsHint(int n) => _jr(super.stampsHint(n));

  @override
  String get stampsSpring => _jr(super.stampsSpring);

  @override
  String get stampsSummer => _jr(super.stampsSummer);

  @override
  String get stampsAutumn => _jr(super.stampsAutumn);

  @override
  String get stampsWinter => _jr(super.stampsWinter);

  @override
  String get stampsNow => _jr(super.stampsNow);

  @override
  String get stampsOutfit => _jr(super.stampsOutfit);

  @override
  String get celebrateOutfit => _jr(super.celebrateOutfit);
}

class AppLocalizationsJaAdult extends AppLocalizationsJa {
  AppLocalizationsJaAdult([super.locale]);

  @override
  String get continueButton => '次へ';

  @override
  String get interestsTitle => '好きなジャンルを選んでください';

  @override
  String get interestsAll => 'すべて';

  @override
  String get catAnimals => '動物';

  @override
  String get catSpace => '宇宙';

  @override
  String get catBody => 'からだ';

  @override
  String get catNature => '自然';

  @override
  String get catScience => '科学';

  @override
  String get catGeography => '地理';

  @override
  String get sceneKids => '子どもと';

  @override
  String get kidsNext => '次へ';

  @override
  String get kidsListen => '聞く';

  @override
  String get copied => 'コピーしました';

  @override
  String get ratingHeh => 'へぇ！';

  @override
  String get gateOk => '次へ';

  @override
  String get gateCancel => 'キャンセル';

  @override
  String get catBugs => '昆虫';

  @override
  String get catVehicles => '乗り物';

  @override
  String get catFood => '食べ物';

  @override
  String get quizButton => 'クイズ';

  @override
  String get quizTitle => '本当？ウソ？';

  @override
  String get quizTrue => '本当';

  @override
  String get quizFalse => 'ウソ';

  @override
  String get quizCorrect => '正解！';

  @override
  String get quizWrong => '残念！';

  @override
  String get quizNext => '次へ';

  @override
  String get timingSection => 'いまのおすすめ';

  @override
  String reasonSeason(String season) {
    return '${season}にぴったり';
  }

  @override
  String get whyButton => 'なぜ？';

  @override
  String get mythsTitle => '本当？ウソ？';

  @override
  String mythAnswerIs(String verdict) {
    return '答えは「${verdict}」';
  }

  @override
  String get mythRead => '詳しく読む';

  @override
  String mythResult(int correct, int total) {
    return '${total}問中${correct}問正解';
  }

  @override
  String get mythAgain => 'もう一度';

  @override
  String get mythNone => 'いま遊べる問題がありません';

  @override
  String get mythNext => '次へ';

  @override
  String get mythFinish => '結果を見る';

  @override
  String get todayNone => '今日は特別な日ではありません';

  @override
  String get todayUpcoming => 'もうすぐ';

  @override
  String get listenNext => '次へ';

  @override
  String get listenPrev => '前へ';

  @override
  String get listenSlow => 'ゆっくり';

  @override
  String get listenNormal => 'ふつう';

  @override
  String get listenFast => 'はやい';

  @override
  String get projectNeedsAdult => '大人と一緒に';

  @override
  String get projectDifficulty => '難易度';

  @override
  String get projectMaterials => '用意するもの';

  @override
  String get projectSteps => '手順';

  @override
  String get projectObserve => '観察のポイント';

  @override
  String get projectSafety => '安全上の注意';

  @override
  String get privacyTitle => 'プライバシーとアプリについて';

  @override
  String get privacyDeleteCancel => 'キャンセル';

  @override
  String get battleTitle => 'クイズ対戦';

  @override
  String get battlePlayers => 'プレイ人数';

  @override
  String get battleSolo => 'ひとり';

  @override
  String battlePlayerCount(int n) {
    return '${n}人';
  }

  @override
  String get battleRounds => '問題数';

  @override
  String battleRoundCount(int n) {
    return '${n}問';
  }

  @override
  String get battleHandHint => '1台の端末を順番に回して遊びます。';

  @override
  String get battleStart => 'はじめる';

  @override
  String get battleNoQuestions => '出題できるクイズがありません。';

  @override
  String battleRoundOf(int n, int total) {
    return '${n} / ${total} 問目';
  }

  @override
  String battleTurnOf(String name) {
    return '${name}の番';
  }

  @override
  String get battleSeeResult => '結果を見る';

  @override
  String get battleFinished => '結果発表';

  @override
  String battleSoloScore(int score, int total) {
    return '${total}問中${score}問正解';
  }

  @override
  String get battleDraw => '引き分け';

  @override
  String battleWinner(String name) {
    return '${name}の勝ち';
  }

  @override
  String battleRank(int n) {
    return '${n}位';
  }

  @override
  String get battleAgain => 'もう一度';

  @override
  String get battleChangeSettings => '設定を変える';

  @override
  String get battleExit => '終わる';

  @override
  String get battleKind => '出題の種類';

  @override
  String get battleKindAll => 'すべて';

  @override
  String get battleKindChoice => '選択式';

  @override
  String get battleGenreAll => 'すべて';

  @override
  String get battleTimeLimit => '制限時間';

  @override
  String get battleTimeOff => 'なし';

  @override
  String battleSeconds(int n) {
    return '${n}秒';
  }

  @override
  String battleSecondsLeft(int n) {
    return '残り${n}秒';
  }

  @override
  String get battleTimeHint => '早く答えるほどボーナス点が加算されます（正解数が同じ場合の順位づけに使用）。';

  @override
  String battleCorrectIs(String answer) {
    return '正解は「${answer}」';
  }

  @override
  String battlePoints(int n) {
    return '${n}点';
  }

  @override
  String get reviewTitle => '復習';

  @override
  String get reviewNone => '今日の復習はありません。「知らなかった」を選んだ雑学が、翌日から出題されます。';

  @override
  String get reviewDoneNote => 'また明日、復習しましょう。';

  @override
  String get reviewChip => '復習';

  @override
  String reviewChipCount(int n) {
    return '復習 ${n}';
  }

  @override
  String get dailyTitle => '今日のチャレンジ';

  @override
  String dailyStreak(int n) {
    return '${n}日連続で挑戦中';
  }

  @override
  String get dailyComeBack => '明日また挑戦しましょう。';

  @override
  String get dailyShare => '結果をシェア';

  @override
  String badgesCount(int n, int total) {
    return '${total}個中${n}個獲得';
  }

  @override
  String badgeStreak(int n) {
    return '${n}日連続';
  }

  @override
  String badgeReadDays(int n) {
    return '${n}日読んだ';
  }

  @override
  String badgeLearned(int n) {
    return '${n}個の発見';
  }

  @override
  String badgeQuiz(int n) {
    return 'クイズ${n}問正解';
  }

  @override
  String badgeDaily(int n) {
    return 'チャレンジ${n}日';
  }

  @override
  String get badgePerfect => 'チャレンジ全問正解';

  @override
  String get reportTitle => '学習のようす';

  @override
  String get reportNote => 'この記録は、この端末内のデータだけから作成しています。外部には送信されません。';

  @override
  String get reportLearned => '「知らなかった」と覚えた雑学';

  @override
  String get reportKnew => '「知ってた」雑学';

  @override
  String get reportQuiz => 'クイズの正解数';

  @override
  String get reportNoQuiz => '記録なし';

  @override
  String get reportReviewPending => '復習待ち';

  @override
  String get reportFavorite => 'よく見たジャンル';

  @override
  String get reportEmpty => 'まだ記録がありません。';

  @override
  String get reportRecent => '最近知ったこと';

  @override
  String get reportOpen => '学習のようす（保護者向け）';

  @override
  String get mascotTitle => '相棒';

  @override
  String mascotNext(int n, String name) {
    return 'あと${n}で「${name}」に成長';
  }

  @override
  String get mascotMax => '最大まで成長しました';

  @override
  String get mascotHint => '雑学を開くと+1、「知らなかった」を選ぶと+2。ポイントが貯まるほど相棒が成長します。';

  @override
  String get mascotName_egg => 'たまご';

  @override
  String get mascotSay_egg => '…面白い雑学を待っています。';

  @override
  String get mascotName_chick => 'ひよこ';

  @override
  String get mascotSay_chick => 'ぴよっ。雑学って面白いですね。';

  @override
  String get mascotName_chicklet => 'ちびフクロウ';

  @override
  String get mascotSay_chicklet => 'ふわふわ。もっと知りたいです。';

  @override
  String get mascotName_owl => 'フクロウ';

  @override
  String get mascotSay_owl => 'ほー。ものしりになってきました。';

  @override
  String get mascotName_professor => '博士フクロウ';

  @override
  String get mascotSay_professor => 'ふむふむ、なるほど。かなりの博識ですね。';

  @override
  String get mascotName_king => 'フクロウ王';

  @override
  String get mascotSay_king => 'ほっほー。雑学の王様です。';

  @override
  String celebrateStage(String name) {
    return '${name}に成長しました';
  }

  @override
  String get celebrateBadge => 'バッジを獲得';

  @override
  String get flipHint => 'タップでめくる';

  @override
  String get flipDetail => '詳しく見る';

  @override
  String get zukanTitle => '雑学図鑑';

  @override
  String get zukanChip => '図鑑';

  @override
  String zukanFound(int n, int total) {
    return '${n} / ${total} 発見';
  }

  @override
  String get zukanAll => 'すべて';

  @override
  String get zukanHint => '見た雑学が図鑑に記録されていきます。';

  @override
  String get capsuleTitle => '雑学カプセル';

  @override
  String get capsuleOpen => '開ける';

  @override
  String get capsuleHint => '1日1回、雑学が1つ出てきます。';

  @override
  String get capsuleDone => 'また明日どうぞ';

  @override
  String get capsuleNew => 'NEW';

  @override
  String get capsuleToZukan => '図鑑を見る';

  @override
  String get capsuleEmpty => '出せる雑学がありません。';

  @override
  String get capsuleRarity1 => 'ノーマル';

  @override
  String get swipeTitle => 'スワイプ 本当？ウソ？';

  @override
  String get swipeHint => '→ 本当　　← ウソ';

  @override
  String swipeCombo(int n) {
    return '🔥 ${n}連続';
  }

  @override
  String swipeBestCombo(int n) {
    return '最高連続：${n}';
  }

  @override
  String get tabPlay => '遊ぶ';

  @override
  String get tabCollect => '集める';

  @override
  String get tabExplore => '探す';

  @override
  String get tabSettings => '設定';

  @override
  String get hubPlayIntro => 'クイズやゲームで雑学を楽しみます。';

  @override
  String get hubCollectIntro => '雑学を見るほど、相棒が成長してコレクションが増えます。';

  @override
  String get hubExploreIntro => '雑学を探したり、深掘りしたりできます。';

  @override
  String get hubSwipeSub => '本当？ウソ？';

  @override
  String get hubDailySub => '毎日3問';

  @override
  String get hubReviewSub => '忘れないために';

  @override
  String get hubMythsSub => 'よくある勘違い';

  @override
  String get hubLibrarySub => '検索・ジャンル';

  @override
  String get wordTitle => '用語の解説';

  @override
  String get wordSimple => 'ひとことで言うと';

  @override
  String get wordDetail => '詳しく';

  @override
  String get wordFacts => 'この用語が出てくる雑学';

  @override
  String get wordNotFound => '解説が見つかりません。';

  @override
  String get wordsTitle => '用語図鑑';

  @override
  String wordsFound(int n, int total) {
    return '${n} / ${total} 語';
  }

  @override
  String get wordOfDay => '今日の用語';

  @override
  String get wordQuizTitle => '用語クイズ';

  @override
  String wordQuizQuestion(String term) {
    return '「${term}」の意味は？';
  }

  @override
  String get wordsHint => '解説を見た用語が、ここに記録されます。';

  @override
  String get mapTitle => 'つながりマップ';

  @override
  String mapLinkCount(int n) {
    return '関連する雑学 ${n}件';
  }

  @override
  String get mapNoLinks => '関連する雑学はまだありません';

  @override
  String get mapOpen => 'つながりを見る';

  @override
  String get voiceQuizTitle => '音声クイズ';

  @override
  String get voiceReplay => 'もう一度聞く';

  @override
  String get voiceQuizSub => '読み上げて答える';

  @override
  String get leagueTitle => '家族リーグ';

  @override
  String get leagueNote => 'この端末で遊んだ対戦の得点を、週ごとに集計します。外部には送信されません。';

  @override
  String get leagueThisWeek => '今週の順位';

  @override
  String leagueLastWinner(String name) {
    return '先週の優勝：${name}';
  }

  @override
  String get leagueEmpty => '記録がありません。2人以上で対戦すると、ここに表示されます。';

  @override
  String leagueGames(int n, int wins) {
    return '${n}試合・${wins}勝';
  }

  @override
  String get leaguePlay => '対戦する';

  @override
  String get leagueClear => '今週の記録を消す';

  @override
  String get leagueClearTitle => '今週の記録を消しますか？';

  @override
  String get leagueClearBody => '今週の得点が消えます。先週の優勝者は残ります。';

  @override
  String get leagueRecord => '家族リーグに記録する';

  @override
  String get leagueSub => '1週間の勝負';

  @override
  String get recapTitle => '週間レポート';

  @override
  String get recapNote => '直近7日間と、その前の7日間を比較しています。';

  @override
  String get recapSeen => '見た雑学';

  @override
  String get recapLearned => '新しく知ったこと';

  @override
  String get recapQuiz => 'クイズの正解数';

  @override
  String get recapActiveDays => '利用した日';

  @override
  String get recapMsgNone => '今週はお休みでしたね。ひとつ読んで再開しましょう。';

  @override
  String get recapMsgSome => 'いいペースです。少しずつ積み上がっています。';

  @override
  String get recapMsgGreat => '素晴らしい。ほぼ毎日利用しました。';

  @override
  String get recapChip => '週間レポート';

  @override
  String get recapBanner => '今週のレポートができました';

  @override
  String get stampsTitle => '季節のスタンプ帳';

  @override
  String get stampsChip => 'スタンプ帳';

  @override
  String stampsHint(int n) {
    return 'いまの季節にぴったりの雑学を読むとスタンプが1つ。${n}つ集めると、相棒がその季節の衣装を着ます。';
  }

  @override
  String get stampsSpring => '春';

  @override
  String get stampsSummer => '夏';

  @override
  String get stampsAutumn => '秋';

  @override
  String get stampsWinter => '冬';

  @override
  String get stampsNow => 'いま';

  @override
  String get stampsOutfit => '衣装を獲得';

  @override
  String get celebrateOutfit => '季節の衣装を獲得';
}

/// Teen: Adult の表記と同じ漢字まじりで、言い回しだけ、すこしくだけた（だよ・しよう）。
class AppLocalizationsJaTeen extends AppLocalizationsJaAdult {
  AppLocalizationsJaTeen([super.locale]);

  @override
  String get interestsTitle => '好きなジャンルを選ぼう';

  @override
  String get battleHandHint => '1台の端末を順番に回して遊ぼう。';

  @override
  String get battleFinished => '結果発表！';

  @override
  String get battleDraw => '引き分け！';

  @override
  String battleWinner(String name) {
    return '${name}の勝ち！';
  }

  @override
  String get battleTimeHint => '早く答えるほどボーナス点がもらえるよ（正解数が同じときの順位づけに使うよ）。';

  @override
  String get reviewNone => '今日の復習はないよ。「知らなかった」を選んだ雑学が、明日から出てくるよ。';

  @override
  String get reviewDoneNote => 'また明日、復習しよう。';

  @override
  String dailyStreak(int n) {
    return '${n}日連続で挑戦中！';
  }

  @override
  String get dailyComeBack => '明日もまた挑戦しよう！';

  @override
  String badgesCount(int n, int total) {
    return '${total}個中${n}個ゲット！';
  }

  @override
  String mascotNext(int n, String name) {
    return 'あと${n}で「${name}」に成長するよ';
  }

  @override
  String get mascotMax => '最大まで育ったよ！';

  @override
  String get mascotHint => '雑学を開くと+1、「知らなかった」を選ぶと+2。ポイントが貯まるほど相棒が育つよ。';

  @override
  String get mascotSay_egg => '…おもしろい雑学、待ってるよ。';

  @override
  String get mascotSay_chick => 'ぴよっ！ 雑学っておもしろいね！';

  @override
  String get mascotSay_chicklet => 'ふわふわ！ もっと知りたいな。';

  @override
  String get mascotSay_owl => 'ほー！ ものしりになってきたよ。';

  @override
  String get mascotSay_professor => 'ふむふむ、なるほど。きみは博士だね。';

  @override
  String get mascotSay_king => 'ほっほー！ 雑学の王様だ！';

  @override
  String celebrateStage(String name) {
    return '${name}に成長したよ！';
  }

  @override
  String get celebrateBadge => 'バッジをゲット！';

  @override
  String get zukanHint => '見た雑学が図鑑に増えていくよ。';

  @override
  String get capsuleOpen => '開けてみよう！';

  @override
  String get capsuleHint => '1日1回、ふしぎな雑学が出てくるよ。';

  @override
  String get capsuleDone => 'また明日あけよう！';

  @override
  String swipeCombo(int n) {
    return '🔥 ${n}連続！';
  }

  @override
  String get hubPlayIntro => 'クイズやゲームで、雑学を楽しもう。';

  @override
  String get hubCollectIntro => '雑学を見るほど、相棒が育ってコレクションが増えるよ。';

  @override
  String get hubExploreIntro => '雑学を探したり、深掘りしたりしよう。';

  @override
  String get wordsHint => '用語の解説を見ると、ここに増えていくよ。';

  @override
  String get mapNoLinks => 'つながる雑学はまだないよ';

  @override
  String get leagueNote => 'この端末で遊んだ対戦の得点を、1週間ごとに集計するよ。外には送らないよ。';

  @override
  String get leagueEmpty => 'まだ記録がないよ。2人以上で対戦すると、ここに載るよ。';

  @override
  String get leagueClearBody => '今週の得点が消えるよ。先週の優勝者は残るよ。';

  @override
  String get recapNote => '今日までの7日間と、その前の7日間を比べるよ。';

  @override
  String get recapMsgNone => '今週はお休みだったね。ひとつ読んで再開しよう！';

  @override
  String get recapMsgSome => 'いいペース！ 少しずつ増えていくよ。';

  @override
  String get recapMsgGreat => 'すごい！ ほぼ毎日遊んだね！';

  @override
  String get recapBanner => '今週のレポートができたよ';

  @override
  String stampsHint(int n) {
    return 'いまの季節にぴったりの雑学を読むと、スタンプが1つ。${n}つ集めると、相棒がその季節の衣装を着るよ。';
  }

  @override
  String get stampsOutfit => '衣装ゲット！';

  @override
  String get celebrateOutfit => '季節の衣装をゲット！';
}
