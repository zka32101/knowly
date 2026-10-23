// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'ノウリー';

  @override
  String get languageTitle => '言語 / Language';

  @override
  String get languageSystem => '端末の言語';

  @override
  String get languageJa => '日本語';

  @override
  String get languageEn => 'English';

  @override
  String get continueButton => 'つぎへ';

  @override
  String get birthYearTitle => '生まれた年を えらんでください';

  @override
  String get birthYearNote => '年齢に合った内容にするためだけに使います。生まれた年は保存せず、端末の外にも送りません。';

  @override
  String get parentNoteTitle => '保護者の方へ';

  @override
  String get parentNoteBody =>
      'お子さまが使うときは、いっしょにご利用ください。このアプリは、お子さまの個人情報を集めず、広告も表示しません。';

  @override
  String get modeKids => 'キッズ（就学前）';

  @override
  String get modeJunior => 'ジュニア（小学生）';

  @override
  String get modeTeen => 'ティーン（中高生）';

  @override
  String get modeAdult => 'アダルト（大人）';

  @override
  String get interestsTitle => 'すきなものを えらんでね';

  @override
  String get interestsAll => 'ぜんぶ';

  @override
  String get catAnimals => 'どうぶつ';

  @override
  String get catSpace => 'うちゅう';

  @override
  String get catBody => 'からだ';

  @override
  String get catNature => 'しぜん';

  @override
  String get catScience => 'かがく';

  @override
  String get catGeography => 'ちり';

  @override
  String get sceneFriends => '友だちと';

  @override
  String get sceneKids => 'こどもと';

  @override
  String get sceneWork => '仕事で';

  @override
  String get sceneFamily => '家族と';

  @override
  String get sceneLearning => '学びたい';

  @override
  String get filterReset => 'リセット';

  @override
  String get today => 'きょうの雑学';

  @override
  String get past => 'これまでの雑学';

  @override
  String get kidsNext => 'つぎへ';

  @override
  String get kidsListen => 'きく';

  @override
  String get emptyFeed => 'いま表示できる雑学がありません';

  @override
  String get lockedFeedNote => 'さらに前の雑学は、プレミアムで読めます';

  @override
  String get savedTitle => '保存した雑学';

  @override
  String get savedEmpty => 'まだ保存した雑学はありません';

  @override
  String savedLimit(int count) {
    return '無料プランで保存できるのは$count件までです';
  }

  @override
  String get save => '保存';

  @override
  String get unsave => '保存済み';

  @override
  String get copy => 'コピー';

  @override
  String get copied => 'コピーしました';

  @override
  String get ratingHeh => 'へぇ！';

  @override
  String get ratingUseful => '使える！';

  @override
  String get ratingWow => 'スゴイ';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsUiLanguage => '画面の言語';

  @override
  String get settingsContentLanguage => '雑学の言語';

  @override
  String get settingsMode => '年代モード';

  @override
  String get settingsModeNote => 'モードを変えるには保護者ゲートが必要です';

  @override
  String get settingsPremium => 'プレミアム';

  @override
  String get settingsOtherApps => '他のアプリもチェック！';

  @override
  String get settingsPrivacy => 'このアプリはお子さまの個人情報を集めません。広告も表示しません。';

  @override
  String get premiumTitle => 'プレミアム';

  @override
  String get premiumBenefit1 => 'これまでの雑学を30日ぶんまで読める';

  @override
  String get premiumBenefit2 => '保存が無制限';

  @override
  String get premiumBenefit3 => 'オフライン保存・深掘り解説（準備中）';

  @override
  String get premiumKidsFree => 'キッズ・ジュニアの雑学はずっと無料です。';

  @override
  String get premiumUnavailable => '購入機能は準備中です';

  @override
  String get gateTitle => '保護者の方へ確認';

  @override
  String get gateDescription => 'これは大人の方が行う操作です。\n下の計算の答えを入力してください。';

  @override
  String get gateHint => '答えを入力';

  @override
  String get gateWrong => '答えが違います';

  @override
  String get gateOk => 'つぎへ';

  @override
  String get gateCancel => 'やめる';

  @override
  String get close => '閉じる';

  @override
  String get catBugs => 'むし';

  @override
  String get catVehicles => 'のりもの';

  @override
  String get catFood => 'たべもの';

  @override
  String get viewAs => '読み方';

  @override
  String get viewOwn => 'いつもの説明';

  @override
  String get viewJunior => '小学生向け';

  @override
  String get viewKids => '就学前向け';

  @override
  String get explainToKids => 'こどもに説明するなら';

  @override
  String get bilingualOn => '二言語で見る';

  @override
  String get bilingualOff => '一つの言語にもどす';

  @override
  String get knewIt => '知ってた';

  @override
  String get learnedIt => '知らなかった！';

  @override
  String streakDays(int count) {
    return '連続$count日';
  }

  @override
  String get streakFreeze => 'お休み券あり';

  @override
  String get streakStart => '今日の雑学を読んで連続をはじめよう';

  @override
  String get statsTitle => 'あなたの雑学';

  @override
  String statsKnowRate(int percent, int knew, int total) {
    return '知っていた雑学: $percent%（$knew/$total）';
  }

  @override
  String get statsEmpty => '「知ってた」「知らなかった」を押すと、ここに表示されます';

  @override
  String get quizButton => 'もんだい';

  @override
  String get quizTitle => 'ほんとかな？';

  @override
  String get quizTrue => 'ほんと';

  @override
  String get quizFalse => 'うそ';

  @override
  String get quizCorrect => 'せいかい！';

  @override
  String get quizWrong => 'ざんねん！';

  @override
  String get quizNext => 'つぎへ';

  @override
  String get notifyTitle => '毎日の雑学を通知';

  @override
  String get notifySubtitle => '毎日、決まった時刻に今日の雑学をお知らせします。端末の中だけで動きます。';

  @override
  String get notifyJuniorNote => '保護者の方が設定してください。端末の中だけで動き、情報は送られません。';

  @override
  String get notifyTime => '通知の時刻';

  @override
  String get notifyDenied => '通知が許可されていません。端末の設定で許可してください。';

  @override
  String get birthYearHint => '生まれた年';

  @override
  String get filterButton => '絞り込み';

  @override
  String filterButtonActive(int count) {
    return '絞り込み（$count）';
  }

  @override
  String get libraryTitle => '雑学ライブラリ';

  @override
  String get searchHint => '雑学をさがす（日本語・English）';

  @override
  String get searchClear => '消す';

  @override
  String resultsCount(int count) {
    return '$count件';
  }

  @override
  String get noResults => '見つかりませんでした。ことばや絞り込みを変えてみてください';

  @override
  String get filterStatus => '状態';

  @override
  String get statusSaved => '保存済み';

  @override
  String get statusKnew => '知ってた';

  @override
  String get statusLearned => '知らなかった';

  @override
  String get statusUnrated => '未評価';

  @override
  String get filterCategoryHeader => 'ジャンル';

  @override
  String get filterSceneHeader => 'シーン';

  @override
  String get libraryLocked => 'プレミアムで読めます';

  @override
  String get libraryOpen => 'ライブラリ';

  @override
  String get interestsSection => 'あなたの関心';

  @override
  String get interestsEdit => '編集';

  @override
  String get interestsEmptyTitle => '関心を登録すると、ここにおすすめを出します';

  @override
  String get interestsRegister => '関心を登録';

  @override
  String get interestsNoMatch => '関心に合う雑学は、いまはありません';

  @override
  String get interestsScreenTitle => '関心事';

  @override
  String get interestsCategories => 'ジャンル';

  @override
  String get interestsScenes => 'シーン';

  @override
  String get interestsKeywords => 'キーワード';

  @override
  String get interestsKeywordHint => '例: 宇宙、ラッコ、お金';

  @override
  String get interestsAdd => '追加';

  @override
  String interestsMax(int count) {
    return 'キーワードは$count個までです';
  }

  @override
  String get interestsNote => '関心事は端末の中にだけ保存され、外には送られません。';

  @override
  String get settingsInterests => '関心事';

  @override
  String get timingSection => 'いまのおすすめ';

  @override
  String get reasonDate => '今日は記念日';

  @override
  String reasonSeason(String season) {
    return '$seasonにぴったり';
  }

  @override
  String get reasonNight => '夜にぴったり';

  @override
  String get reasonMorning => '朝にぴったり';

  @override
  String get reasonEvening => '夕方にぴったり';

  @override
  String get reasonWeekend => '週末に家族で';

  @override
  String get seasonSpring => '春';

  @override
  String get seasonSummer => '夏';

  @override
  String get seasonAutumn => '秋';

  @override
  String get seasonWinter => '冬';

  @override
  String get settingsRegion => '国・地域';

  @override
  String get regionAuto => '自動（端末の設定）';

  @override
  String get regionAll => 'すべての国';

  @override
  String get regionNote => '国ごとの話題（日本の新幹線など）を、選んだ国でだけ出します。';

  @override
  String get settingsSeason => '季節のおすすめ';

  @override
  String get seasonAuto => '自動';

  @override
  String get seasonNorth => '北半球';

  @override
  String get seasonSouth => '南半球';

  @override
  String get seasonOff => 'オフ';

  @override
  String get seasonNote => '端末のタイムゾーンから推定します（位置情報は使いません）。';

  @override
  String get relatedSection => '関連する雑学';

  @override
  String get whyButton => 'なぜ？';

  @override
  String whyCheer(int count) {
    return '「なぜ？」を$count回つづけたよ！すごい！';
  }

  @override
  String get mythsTitle => 'ほんと？うそ？';

  @override
  String mythAnswerIs(String verdict) {
    return 'こたえは「$verdict」！';
  }

  @override
  String get mythRead => 'くわしく よむ';

  @override
  String mythProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String mythResult(int correct, int total) {
    return '$totalもんちゅう $correctもん せいかい！';
  }

  @override
  String get mythAgain => 'もういちど';

  @override
  String get mythNone => 'いま あそべる もんだいが ありません';

  @override
  String get mythNext => 'つぎへ';

  @override
  String get mythFinish => 'けっかを みる';

  @override
  String get todayTitle => '今日は何の日';

  @override
  String get todayNone => 'きょうは とくべつな ひでは ありません';

  @override
  String get todayUpcoming => 'もうすぐ';

  @override
  String todayBanner(String title) {
    return '今日は「$title」';
  }

  @override
  String get todayCountry => 'この国の行事';

  @override
  String get todayHome => '今日は何の日';

  @override
  String dateMonthDay(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get listenInEnglish => '英語で聞く';

  @override
  String get listenInJapanese => '日本語で聞く';

  @override
  String get vocabEnglishTitle => '英語のことば';

  @override
  String get vocabJapaneseTitle => '日本語のことば';

  @override
  String get vocabTapToHear => 'タップで発音を聞けます';

  @override
  String get listenTitle => 'ながら聞き';

  @override
  String get listenPlay => '再生';

  @override
  String get listenPause => '一時停止';

  @override
  String get listenNext => 'つぎへ';

  @override
  String get listenPrev => 'まえへ';

  @override
  String get listenSpeedLabel => '速さ';

  @override
  String get listenSlow => 'ゆっくり';

  @override
  String get listenNormal => 'ふつう';

  @override
  String get listenFast => 'はやい';

  @override
  String get listenFinished => 'おしまい。もういちど聞くには再生を押してください';

  @override
  String get listenNote => '画面を開いたまま使います（通勤・料理中など）。';

  @override
  String get listenEmpty => 'いま聞ける雑学がありません';

  @override
  String get listenOpen => 'ながら聞き';

  @override
  String get projectsTitle => '自由研究ネタ帳';

  @override
  String projectMinutes(int minutes) {
    return '$minutes分くらい';
  }

  @override
  String get projectNeedsAdult => 'おとなといっしょに';

  @override
  String get projectDifficulty => 'むずかしさ';

  @override
  String get projectMaterials => 'ようい するもの';

  @override
  String get projectSteps => 'やりかた';

  @override
  String get projectObserve => 'かんさつ ポイント';

  @override
  String get projectSafety => 'あんぜんに ちゅうい';

  @override
  String get projectFromFact => '自由研究にしてみよう';

  @override
  String get projectsEmpty => 'いま表示できる自由研究がありません';

  @override
  String get projectsSummer => '夏休みにぴったり';

  @override
  String get quickLinks => 'もっと見る';

  @override
  String get projectsIntro => '雑学から、おうちでできる実験・観察へ。';

  @override
  String get premiumActive => 'プレミアムをご利用中です';

  @override
  String get premiumMonthly => '月額プラン';

  @override
  String get premiumAnnual => '年額プラン';

  @override
  String get premiumTrial => '無料トライアルあり';

  @override
  String get premiumBuy => 'このプランで始める';

  @override
  String get premiumRestore => '購入を復元';

  @override
  String get premiumLegal =>
      'お支払いはお使いのストアのアカウントに請求されます。プランは自動で更新され、解約はストアの設定からいつでもできます。無料トライアルがあるプランは、期間が終わると自動で課金が始まります。';

  @override
  String get premiumPurchased => 'ご購入ありがとうございます！';

  @override
  String get premiumCancelled => '購入をやめました';

  @override
  String get premiumFailed => '購入できませんでした。しばらくしてからもう一度お試しください';

  @override
  String get premiumRestored => '購入を復元しました';

  @override
  String get premiumNothingToRestore => '復元できる購入が見つかりませんでした';

  @override
  String get privacyTitle => 'プライバシーとアプリについて';

  @override
  String get privacyDataHeading => 'データの扱い';

  @override
  String get privacyPointLocal => '設定・保存した雑学・記録は、この端末の中だけに保存されます。';

  @override
  String get privacyPointBirthYear => '生まれた年は年代の判定にだけ使い、保存しません。';

  @override
  String get privacyPointNoAds => '広告も、利用状況の分析（アナリティクス）もありません。';

  @override
  String get privacyPointChildren => 'Kids / Junior では、ネットワーク通信も課金のしくみも使いません。';

  @override
  String get privacyPointTeenAdult =>
      'Teen / Adult では、おすすめアプリの案内（設定でオフにできます）と、プレミアムの購入状態の確認のために通信することがあります。支払い情報はアプリには届きません。';

  @override
  String privacyContact(String email) {
    return 'お問い合わせ: $email';
  }

  @override
  String get privacyLicenses => 'オープンソースライセンス';

  @override
  String privacyVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String get privacyDeleteButton => 'この端末のデータを削除';

  @override
  String get privacyDeleteTitle => 'データを削除しますか？';

  @override
  String get privacyDeleteBody =>
      '設定・保存した雑学・記録・通知の予約がすべて消え、最初の画面に戻ります。元に戻せません。購入済みのプレミアムは消えません（ストアで復元できます）。';

  @override
  String get privacyDeleteConfirm => '削除する';

  @override
  String get privacyDeleteCancel => 'やめる';

  @override
  String get privacyDeleted => 'データを削除しました';

  @override
  String get shareImage => '画像でシェア';

  @override
  String get sourcesSection => '出典';

  @override
  String get battleTitle => 'クイズたいせん';

  @override
  String get battlePlayers => 'なんにんで あそぶ？';

  @override
  String get battleSolo => 'ひとり';

  @override
  String battlePlayerCount(int n) {
    return '$nにん';
  }

  @override
  String battlePlayerDefault(int n) {
    return 'プレイヤー$n';
  }

  @override
  String get battleRounds => 'なんもん？';

  @override
  String battleRoundCount(int n) {
    return '$nもん';
  }

  @override
  String get battleHandHint => '1つの たんまつを じゅんばんに まわして あそぼう。';

  @override
  String get battleStart => 'はじめる';

  @override
  String get battleNoQuestions => 'だせる クイズが ありません。';

  @override
  String battleRoundOf(int n, int total) {
    return '$n / $total もんめ';
  }

  @override
  String battleTurnOf(String name) {
    return '$nameの ばん';
  }

  @override
  String get battleSeeResult => 'けっかを みる';

  @override
  String get battleFinished => 'おしまい！';

  @override
  String battleSoloScore(int score, int total) {
    return '$score / $total もん せいかい！';
  }

  @override
  String get battleDraw => 'ひきわけ！';

  @override
  String battleWinner(String name) {
    return '$nameの かち！';
  }

  @override
  String battleRank(int n) {
    return '$nい';
  }

  @override
  String get battleAgain => 'もういちど';

  @override
  String get battleChangeSettings => 'せっていを かえる';

  @override
  String get battleExit => 'おわる';

  @override
  String get battleKind => 'クイズの しゅるい';

  @override
  String get battleKindAll => 'ぜんぶ';

  @override
  String get battleKindTrueFalse => '○×';

  @override
  String get battleKindChoice => 'えらぶ';

  @override
  String get battleGenre => 'ジャンル';

  @override
  String get battleGenreAll => 'ぜんぶ';

  @override
  String get battleTimeLimit => 'せいげんじかん';

  @override
  String get battleTimeOff => 'なし';

  @override
  String battleSeconds(int n) {
    return '$nびょう';
  }

  @override
  String battleSecondsLeft(int n) {
    return 'のこり $nびょう';
  }

  @override
  String get battleTimeHint =>
      'はやく こたえるほど、おまけの てんが ふえるよ（おなじ せいかいすうの ときに くらべる）。';

  @override
  String battleCorrectIs(String answer) {
    return 'せいかいは「$answer」';
  }

  @override
  String battlePoints(int n) {
    return '$nてん';
  }

  @override
  String get reviewTitle => 'おさらい';

  @override
  String get reviewNone => 'きょうの おさらいは ありません。「しらなかった」を おした ざつがくが、あしたから でてくるよ。';

  @override
  String get reviewDoneNote => 'また あした おさらいしよう。';

  @override
  String get reviewChip => 'おさらい';

  @override
  String reviewChipCount(int n) {
    return 'おさらい $n';
  }

  @override
  String get dailyTitle => 'きょうの チャレンジ';

  @override
  String get dailyChip => 'チャレンジ';

  @override
  String dailyStreak(int n) {
    return '$nにち つづけて あそんだよ';
  }

  @override
  String get dailyComeBack => 'また あした ちょうせんしよう！';

  @override
  String get dailyShare => 'けっかを シェア';

  @override
  String get badgesTitle => 'バッジ';

  @override
  String get badgesChip => 'バッジ';

  @override
  String badgesCount(int n, int total) {
    return '$n / $total こ ゲット！';
  }

  @override
  String badgeStreak(int n) {
    return '$nにち れんぞく';
  }

  @override
  String badgeReadDays(int n) {
    return '$nにち よんだ';
  }

  @override
  String badgeLearned(int n) {
    return '$nこ しれた';
  }

  @override
  String badgeQuiz(int n) {
    return 'クイズ $nもん せいかい';
  }

  @override
  String badgeDaily(int n) {
    return 'チャレンジ $nにち';
  }

  @override
  String get badgePerfect => 'チャレンジ ぜんもん せいかい';

  @override
  String get reportTitle => 'がくしゅうの ようす';

  @override
  String get reportNote =>
      'この ようすは、この たんまつの なかだけに ある きろくから つくっています。そとには おくりません。';

  @override
  String get reportLearned => '「しらなかった」と おぼえた ざつがく';

  @override
  String get reportKnew => '「しってた」ざつがく';

  @override
  String get reportQuiz => 'クイズの せいかい';

  @override
  String get reportNoQuiz => 'まだ なし';

  @override
  String get reportReviewPending => 'おさらい まち';

  @override
  String get reportFavorite => 'よく みた ジャンル';

  @override
  String get reportEmpty => 'まだ きろくが ありません。';

  @override
  String get reportRecent => 'さいきん しれたこと';

  @override
  String get reportOpen => 'がくしゅうの ようす（おうちの ひとへ）';

  @override
  String get mascotTitle => 'あいぼう';

  @override
  String mascotNext(int n, String name) {
    return 'あと $n で「$name」に なるよ';
  }

  @override
  String get mascotMax => 'いちばん おおきく なったよ！';

  @override
  String get mascotHint => 'ざつがくを ひらくと +1、「しらなかった」を おぼえると +2 で そだつよ。';

  @override
  String mascotPoints(int n) {
    return '$n ポイント';
  }

  @override
  String get mascotLocked => '？？？';

  @override
  String get mascotName_egg => 'たまご';

  @override
  String get mascotSay_egg => '…ざつがく、まってるよ。';

  @override
  String get mascotName_chick => 'ひよこ';

  @override
  String get mascotSay_chick => 'ぴよっ！ ざつがく おもしろいね！';

  @override
  String get mascotName_chicklet => 'ちびふくろう';

  @override
  String get mascotSay_chicklet => 'ふわふわ！ もっと しりたいな。';

  @override
  String get mascotName_owl => 'ふくろう';

  @override
  String get mascotSay_owl => 'ほー！ ものしりに なってきたよ。';

  @override
  String get mascotName_professor => 'はかせふくろう';

  @override
  String get mascotSay_professor => 'ふむふむ、なるほど。きみは はかせだね。';

  @override
  String get mascotName_king => 'ふくろうおう';

  @override
  String get mascotSay_king => 'ほっほー！ ざつがくの おうさまだ！';

  @override
  String celebrateStage(String name) {
    return '$nameに なったよ！';
  }

  @override
  String get celebrateBadge => 'バッジを ゲット！';

  @override
  String get flipHint => 'タップして めくろう';

  @override
  String get flipDetail => 'くわしく みる';

  @override
  String get zukanTitle => 'ざつがくずかん';

  @override
  String get zukanChip => 'ずかん';

  @override
  String zukanFound(int n, int total) {
    return '$n / $total みつけた';
  }

  @override
  String get zukanAll => 'ぜんぶ';

  @override
  String get zukanHint => 'ざつがくを みると、ずかんが うまっていくよ。';

  @override
  String get zukanLocked => '？';

  @override
  String get capsuleTitle => 'ざつがくカプセル';

  @override
  String get capsuleChip => 'カプセル';

  @override
  String get capsuleOpen => 'あけてみよう！';

  @override
  String get capsuleHint => '1にち 1かい、ふしぎな ざつがくが でてくるよ。';

  @override
  String get capsuleDone => 'また あした あけよう！';

  @override
  String get capsuleNew => 'はじめて！';

  @override
  String get capsuleToZukan => 'ずかんを みる';

  @override
  String get capsuleEmpty => 'でてくる ざつがくが ありません。';

  @override
  String get capsuleRarity1 => 'ふつう';

  @override
  String get capsuleRarity2 => 'レア';

  @override
  String get capsuleRarity3 => 'スーパーレア';

  @override
  String get swipeTitle => 'スワイプ ほんと？うそ？';

  @override
  String get swipeChip => 'スワイプ';

  @override
  String get swipeHint => '→ ほんと　　← うそ';

  @override
  String swipeCombo(int n) {
    return '🔥 $n れんぞく！';
  }

  @override
  String swipeBestCombo(int n) {
    return 'いちばん れんぞく：$n';
  }

  @override
  String get tabHome => 'ホーム';

  @override
  String get tabPlay => 'あそぶ';

  @override
  String get tabCollect => 'あつめる';

  @override
  String get tabExplore => 'さがす';

  @override
  String get tabSettings => 'せってい';

  @override
  String get hubPlayIntro => 'クイズやゲームで、ざつがくを たのしもう。';

  @override
  String get hubCollectIntro => 'ざつがくを みるほど、あいぼうが そだって コレクションが ふえるよ。';

  @override
  String get hubExploreIntro => 'ざつがくを さがしたり、ひろげたりしよう。';

  @override
  String get hubQuizSub => '1〜4人で対戦';

  @override
  String get hubSwipeSub => 'ほんと？うそ？';

  @override
  String get hubDailySub => 'まいにち3もん';

  @override
  String get hubReviewSub => 'わすれないように';

  @override
  String get hubMythsSub => 'よくある かんちがい';

  @override
  String get hubLibrarySub => 'けんさく・ジャンル';

  @override
  String get hubListenSub => 'ながら聞き';
}
