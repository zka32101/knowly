// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => '雑学コレ！';

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
}
