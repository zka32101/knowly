import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appName.
  ///
  /// In ja, this message translates to:
  /// **'雑学コレ！'**
  String get appName;

  /// No description provided for @languageTitle.
  ///
  /// In ja, this message translates to:
  /// **'言語 / Language'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In ja, this message translates to:
  /// **'端末の言語'**
  String get languageSystem;

  /// No description provided for @languageJa.
  ///
  /// In ja, this message translates to:
  /// **'日本語'**
  String get languageJa;

  /// No description provided for @languageEn.
  ///
  /// In ja, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @continueButton.
  ///
  /// In ja, this message translates to:
  /// **'つぎへ'**
  String get continueButton;

  /// No description provided for @birthYearTitle.
  ///
  /// In ja, this message translates to:
  /// **'生まれた年を えらんでください'**
  String get birthYearTitle;

  /// No description provided for @birthYearNote.
  ///
  /// In ja, this message translates to:
  /// **'年齢に合った内容にするためだけに使います。生まれた年は保存せず、端末の外にも送りません。'**
  String get birthYearNote;

  /// No description provided for @parentNoteTitle.
  ///
  /// In ja, this message translates to:
  /// **'保護者の方へ'**
  String get parentNoteTitle;

  /// No description provided for @parentNoteBody.
  ///
  /// In ja, this message translates to:
  /// **'お子さまが使うときは、いっしょにご利用ください。このアプリは、お子さまの個人情報を集めず、広告も表示しません。'**
  String get parentNoteBody;

  /// No description provided for @modeKids.
  ///
  /// In ja, this message translates to:
  /// **'キッズ（就学前）'**
  String get modeKids;

  /// No description provided for @modeJunior.
  ///
  /// In ja, this message translates to:
  /// **'ジュニア（小学生）'**
  String get modeJunior;

  /// No description provided for @modeTeen.
  ///
  /// In ja, this message translates to:
  /// **'ティーン（中高生）'**
  String get modeTeen;

  /// No description provided for @modeAdult.
  ///
  /// In ja, this message translates to:
  /// **'アダルト（大人）'**
  String get modeAdult;

  /// No description provided for @interestsTitle.
  ///
  /// In ja, this message translates to:
  /// **'すきなものを えらんでね'**
  String get interestsTitle;

  /// No description provided for @interestsAll.
  ///
  /// In ja, this message translates to:
  /// **'ぜんぶ'**
  String get interestsAll;

  /// No description provided for @catAnimals.
  ///
  /// In ja, this message translates to:
  /// **'どうぶつ'**
  String get catAnimals;

  /// No description provided for @catSpace.
  ///
  /// In ja, this message translates to:
  /// **'うちゅう'**
  String get catSpace;

  /// No description provided for @catBody.
  ///
  /// In ja, this message translates to:
  /// **'からだ'**
  String get catBody;

  /// No description provided for @catNature.
  ///
  /// In ja, this message translates to:
  /// **'しぜん'**
  String get catNature;

  /// No description provided for @catScience.
  ///
  /// In ja, this message translates to:
  /// **'かがく'**
  String get catScience;

  /// No description provided for @catGeography.
  ///
  /// In ja, this message translates to:
  /// **'ちり'**
  String get catGeography;

  /// No description provided for @sceneFriends.
  ///
  /// In ja, this message translates to:
  /// **'友だちと'**
  String get sceneFriends;

  /// No description provided for @sceneKids.
  ///
  /// In ja, this message translates to:
  /// **'こどもと'**
  String get sceneKids;

  /// No description provided for @sceneWork.
  ///
  /// In ja, this message translates to:
  /// **'仕事で'**
  String get sceneWork;

  /// No description provided for @sceneFamily.
  ///
  /// In ja, this message translates to:
  /// **'家族と'**
  String get sceneFamily;

  /// No description provided for @sceneLearning.
  ///
  /// In ja, this message translates to:
  /// **'学びたい'**
  String get sceneLearning;

  /// No description provided for @filterReset.
  ///
  /// In ja, this message translates to:
  /// **'リセット'**
  String get filterReset;

  /// No description provided for @today.
  ///
  /// In ja, this message translates to:
  /// **'きょうの雑学'**
  String get today;

  /// No description provided for @past.
  ///
  /// In ja, this message translates to:
  /// **'これまでの雑学'**
  String get past;

  /// No description provided for @kidsNext.
  ///
  /// In ja, this message translates to:
  /// **'つぎへ'**
  String get kidsNext;

  /// No description provided for @kidsListen.
  ///
  /// In ja, this message translates to:
  /// **'きく'**
  String get kidsListen;

  /// No description provided for @emptyFeed.
  ///
  /// In ja, this message translates to:
  /// **'いま表示できる雑学がありません'**
  String get emptyFeed;

  /// No description provided for @lockedFeedNote.
  ///
  /// In ja, this message translates to:
  /// **'さらに前の雑学は、プレミアムで読めます'**
  String get lockedFeedNote;

  /// No description provided for @savedTitle.
  ///
  /// In ja, this message translates to:
  /// **'保存した雑学'**
  String get savedTitle;

  /// No description provided for @savedEmpty.
  ///
  /// In ja, this message translates to:
  /// **'まだ保存した雑学はありません'**
  String get savedEmpty;

  /// No description provided for @savedLimit.
  ///
  /// In ja, this message translates to:
  /// **'無料プランで保存できるのは{count}件までです'**
  String savedLimit(int count);

  /// No description provided for @save.
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @unsave.
  ///
  /// In ja, this message translates to:
  /// **'保存済み'**
  String get unsave;

  /// No description provided for @copy.
  ///
  /// In ja, this message translates to:
  /// **'コピー'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In ja, this message translates to:
  /// **'コピーしました'**
  String get copied;

  /// No description provided for @ratingHeh.
  ///
  /// In ja, this message translates to:
  /// **'へぇ！'**
  String get ratingHeh;

  /// No description provided for @ratingUseful.
  ///
  /// In ja, this message translates to:
  /// **'使える！'**
  String get ratingUseful;

  /// No description provided for @ratingWow.
  ///
  /// In ja, this message translates to:
  /// **'スゴイ'**
  String get ratingWow;

  /// No description provided for @settingsTitle.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settingsTitle;

  /// No description provided for @settingsUiLanguage.
  ///
  /// In ja, this message translates to:
  /// **'画面の言語'**
  String get settingsUiLanguage;

  /// No description provided for @settingsContentLanguage.
  ///
  /// In ja, this message translates to:
  /// **'雑学の言語'**
  String get settingsContentLanguage;

  /// No description provided for @settingsMode.
  ///
  /// In ja, this message translates to:
  /// **'年代モード'**
  String get settingsMode;

  /// No description provided for @settingsModeNote.
  ///
  /// In ja, this message translates to:
  /// **'モードを変えるには保護者ゲートが必要です'**
  String get settingsModeNote;

  /// No description provided for @settingsPremium.
  ///
  /// In ja, this message translates to:
  /// **'プレミアム'**
  String get settingsPremium;

  /// No description provided for @settingsOtherApps.
  ///
  /// In ja, this message translates to:
  /// **'他のアプリもチェック！'**
  String get settingsOtherApps;

  /// No description provided for @settingsPrivacy.
  ///
  /// In ja, this message translates to:
  /// **'このアプリはお子さまの個人情報を集めません。広告も表示しません。'**
  String get settingsPrivacy;

  /// No description provided for @premiumTitle.
  ///
  /// In ja, this message translates to:
  /// **'プレミアム'**
  String get premiumTitle;

  /// No description provided for @premiumBenefit1.
  ///
  /// In ja, this message translates to:
  /// **'これまでの雑学を30日ぶんまで読める'**
  String get premiumBenefit1;

  /// No description provided for @premiumBenefit2.
  ///
  /// In ja, this message translates to:
  /// **'保存が無制限'**
  String get premiumBenefit2;

  /// No description provided for @premiumBenefit3.
  ///
  /// In ja, this message translates to:
  /// **'オフライン保存・深掘り解説（準備中）'**
  String get premiumBenefit3;

  /// No description provided for @premiumKidsFree.
  ///
  /// In ja, this message translates to:
  /// **'キッズ・ジュニアの雑学はずっと無料です。'**
  String get premiumKidsFree;

  /// No description provided for @premiumUnavailable.
  ///
  /// In ja, this message translates to:
  /// **'購入機能は準備中です'**
  String get premiumUnavailable;

  /// No description provided for @gateTitle.
  ///
  /// In ja, this message translates to:
  /// **'保護者の方へ確認'**
  String get gateTitle;

  /// No description provided for @gateDescription.
  ///
  /// In ja, this message translates to:
  /// **'これは大人の方が行う操作です。\n下の計算の答えを入力してください。'**
  String get gateDescription;

  /// No description provided for @gateHint.
  ///
  /// In ja, this message translates to:
  /// **'答えを入力'**
  String get gateHint;

  /// No description provided for @gateWrong.
  ///
  /// In ja, this message translates to:
  /// **'答えが違います'**
  String get gateWrong;

  /// No description provided for @gateOk.
  ///
  /// In ja, this message translates to:
  /// **'つぎへ'**
  String get gateOk;

  /// No description provided for @gateCancel.
  ///
  /// In ja, this message translates to:
  /// **'やめる'**
  String get gateCancel;

  /// No description provided for @close.
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get close;

  /// No description provided for @catBugs.
  ///
  /// In ja, this message translates to:
  /// **'むし'**
  String get catBugs;

  /// No description provided for @catVehicles.
  ///
  /// In ja, this message translates to:
  /// **'のりもの'**
  String get catVehicles;

  /// No description provided for @catFood.
  ///
  /// In ja, this message translates to:
  /// **'たべもの'**
  String get catFood;

  /// No description provided for @viewAs.
  ///
  /// In ja, this message translates to:
  /// **'読み方'**
  String get viewAs;

  /// No description provided for @viewOwn.
  ///
  /// In ja, this message translates to:
  /// **'いつもの説明'**
  String get viewOwn;

  /// No description provided for @viewJunior.
  ///
  /// In ja, this message translates to:
  /// **'小学生向け'**
  String get viewJunior;

  /// No description provided for @viewKids.
  ///
  /// In ja, this message translates to:
  /// **'就学前向け'**
  String get viewKids;

  /// No description provided for @explainToKids.
  ///
  /// In ja, this message translates to:
  /// **'こどもに説明するなら'**
  String get explainToKids;

  /// No description provided for @bilingualOn.
  ///
  /// In ja, this message translates to:
  /// **'二言語で見る'**
  String get bilingualOn;

  /// No description provided for @bilingualOff.
  ///
  /// In ja, this message translates to:
  /// **'一つの言語にもどす'**
  String get bilingualOff;

  /// No description provided for @knewIt.
  ///
  /// In ja, this message translates to:
  /// **'知ってた'**
  String get knewIt;

  /// No description provided for @learnedIt.
  ///
  /// In ja, this message translates to:
  /// **'知らなかった！'**
  String get learnedIt;

  /// No description provided for @streakDays.
  ///
  /// In ja, this message translates to:
  /// **'連続{count}日'**
  String streakDays(int count);

  /// No description provided for @streakFreeze.
  ///
  /// In ja, this message translates to:
  /// **'お休み券あり'**
  String get streakFreeze;

  /// No description provided for @streakStart.
  ///
  /// In ja, this message translates to:
  /// **'今日の雑学を読んで連続をはじめよう'**
  String get streakStart;

  /// No description provided for @statsTitle.
  ///
  /// In ja, this message translates to:
  /// **'あなたの雑学'**
  String get statsTitle;

  /// No description provided for @statsKnowRate.
  ///
  /// In ja, this message translates to:
  /// **'知っていた雑学: {percent}%（{knew}/{total}）'**
  String statsKnowRate(int percent, int knew, int total);

  /// No description provided for @statsEmpty.
  ///
  /// In ja, this message translates to:
  /// **'「知ってた」「知らなかった」を押すと、ここに表示されます'**
  String get statsEmpty;

  /// No description provided for @quizButton.
  ///
  /// In ja, this message translates to:
  /// **'もんだい'**
  String get quizButton;

  /// No description provided for @quizTitle.
  ///
  /// In ja, this message translates to:
  /// **'ほんとかな？'**
  String get quizTitle;

  /// No description provided for @quizTrue.
  ///
  /// In ja, this message translates to:
  /// **'ほんと'**
  String get quizTrue;

  /// No description provided for @quizFalse.
  ///
  /// In ja, this message translates to:
  /// **'うそ'**
  String get quizFalse;

  /// No description provided for @quizCorrect.
  ///
  /// In ja, this message translates to:
  /// **'せいかい！'**
  String get quizCorrect;

  /// No description provided for @quizWrong.
  ///
  /// In ja, this message translates to:
  /// **'ざんねん！'**
  String get quizWrong;

  /// No description provided for @quizNext.
  ///
  /// In ja, this message translates to:
  /// **'つぎへ'**
  String get quizNext;

  /// No description provided for @notifyTitle.
  ///
  /// In ja, this message translates to:
  /// **'毎日の雑学を通知'**
  String get notifyTitle;

  /// No description provided for @notifySubtitle.
  ///
  /// In ja, this message translates to:
  /// **'毎日、決まった時刻に今日の雑学をお知らせします。端末の中だけで動きます。'**
  String get notifySubtitle;

  /// No description provided for @notifyJuniorNote.
  ///
  /// In ja, this message translates to:
  /// **'保護者の方が設定してください。端末の中だけで動き、情報は送られません。'**
  String get notifyJuniorNote;

  /// No description provided for @notifyTime.
  ///
  /// In ja, this message translates to:
  /// **'通知の時刻'**
  String get notifyTime;

  /// No description provided for @notifyDenied.
  ///
  /// In ja, this message translates to:
  /// **'通知が許可されていません。端末の設定で許可してください。'**
  String get notifyDenied;

  /// No description provided for @birthYearHint.
  ///
  /// In ja, this message translates to:
  /// **'生まれた年'**
  String get birthYearHint;

  /// No description provided for @filterButton.
  ///
  /// In ja, this message translates to:
  /// **'絞り込み'**
  String get filterButton;

  /// No description provided for @filterButtonActive.
  ///
  /// In ja, this message translates to:
  /// **'絞り込み（{count}）'**
  String filterButtonActive(int count);

  /// No description provided for @libraryTitle.
  ///
  /// In ja, this message translates to:
  /// **'雑学ライブラリ'**
  String get libraryTitle;

  /// No description provided for @searchHint.
  ///
  /// In ja, this message translates to:
  /// **'雑学をさがす（日本語・English）'**
  String get searchHint;

  /// No description provided for @searchClear.
  ///
  /// In ja, this message translates to:
  /// **'消す'**
  String get searchClear;

  /// No description provided for @resultsCount.
  ///
  /// In ja, this message translates to:
  /// **'{count}件'**
  String resultsCount(int count);

  /// No description provided for @noResults.
  ///
  /// In ja, this message translates to:
  /// **'見つかりませんでした。ことばや絞り込みを変えてみてください'**
  String get noResults;

  /// No description provided for @filterStatus.
  ///
  /// In ja, this message translates to:
  /// **'状態'**
  String get filterStatus;

  /// No description provided for @statusSaved.
  ///
  /// In ja, this message translates to:
  /// **'保存済み'**
  String get statusSaved;

  /// No description provided for @statusKnew.
  ///
  /// In ja, this message translates to:
  /// **'知ってた'**
  String get statusKnew;

  /// No description provided for @statusLearned.
  ///
  /// In ja, this message translates to:
  /// **'知らなかった'**
  String get statusLearned;

  /// No description provided for @statusUnrated.
  ///
  /// In ja, this message translates to:
  /// **'未評価'**
  String get statusUnrated;

  /// No description provided for @filterCategoryHeader.
  ///
  /// In ja, this message translates to:
  /// **'ジャンル'**
  String get filterCategoryHeader;

  /// No description provided for @filterSceneHeader.
  ///
  /// In ja, this message translates to:
  /// **'シーン'**
  String get filterSceneHeader;

  /// No description provided for @libraryLocked.
  ///
  /// In ja, this message translates to:
  /// **'プレミアムで読めます'**
  String get libraryLocked;

  /// No description provided for @libraryOpen.
  ///
  /// In ja, this message translates to:
  /// **'ライブラリ'**
  String get libraryOpen;

  /// No description provided for @interestsSection.
  ///
  /// In ja, this message translates to:
  /// **'あなたの関心'**
  String get interestsSection;

  /// No description provided for @interestsEdit.
  ///
  /// In ja, this message translates to:
  /// **'編集'**
  String get interestsEdit;

  /// No description provided for @interestsEmptyTitle.
  ///
  /// In ja, this message translates to:
  /// **'関心を登録すると、ここにおすすめを出します'**
  String get interestsEmptyTitle;

  /// No description provided for @interestsRegister.
  ///
  /// In ja, this message translates to:
  /// **'関心を登録'**
  String get interestsRegister;

  /// No description provided for @interestsNoMatch.
  ///
  /// In ja, this message translates to:
  /// **'関心に合う雑学は、いまはありません'**
  String get interestsNoMatch;

  /// No description provided for @interestsScreenTitle.
  ///
  /// In ja, this message translates to:
  /// **'関心事'**
  String get interestsScreenTitle;

  /// No description provided for @interestsCategories.
  ///
  /// In ja, this message translates to:
  /// **'ジャンル'**
  String get interestsCategories;

  /// No description provided for @interestsScenes.
  ///
  /// In ja, this message translates to:
  /// **'シーン'**
  String get interestsScenes;

  /// No description provided for @interestsKeywords.
  ///
  /// In ja, this message translates to:
  /// **'キーワード'**
  String get interestsKeywords;

  /// No description provided for @interestsKeywordHint.
  ///
  /// In ja, this message translates to:
  /// **'例: 宇宙、ラッコ、お金'**
  String get interestsKeywordHint;

  /// No description provided for @interestsAdd.
  ///
  /// In ja, this message translates to:
  /// **'追加'**
  String get interestsAdd;

  /// No description provided for @interestsMax.
  ///
  /// In ja, this message translates to:
  /// **'キーワードは{count}個までです'**
  String interestsMax(int count);

  /// No description provided for @interestsNote.
  ///
  /// In ja, this message translates to:
  /// **'関心事は端末の中にだけ保存され、外には送られません。'**
  String get interestsNote;

  /// No description provided for @settingsInterests.
  ///
  /// In ja, this message translates to:
  /// **'関心事'**
  String get settingsInterests;

  /// No description provided for @timingSection.
  ///
  /// In ja, this message translates to:
  /// **'いまのおすすめ'**
  String get timingSection;

  /// No description provided for @reasonDate.
  ///
  /// In ja, this message translates to:
  /// **'今日は記念日'**
  String get reasonDate;

  /// No description provided for @reasonSeason.
  ///
  /// In ja, this message translates to:
  /// **'{season}にぴったり'**
  String reasonSeason(String season);

  /// No description provided for @reasonNight.
  ///
  /// In ja, this message translates to:
  /// **'夜にぴったり'**
  String get reasonNight;

  /// No description provided for @reasonMorning.
  ///
  /// In ja, this message translates to:
  /// **'朝にぴったり'**
  String get reasonMorning;

  /// No description provided for @reasonEvening.
  ///
  /// In ja, this message translates to:
  /// **'夕方にぴったり'**
  String get reasonEvening;

  /// No description provided for @reasonWeekend.
  ///
  /// In ja, this message translates to:
  /// **'週末に家族で'**
  String get reasonWeekend;

  /// No description provided for @seasonSpring.
  ///
  /// In ja, this message translates to:
  /// **'春'**
  String get seasonSpring;

  /// No description provided for @seasonSummer.
  ///
  /// In ja, this message translates to:
  /// **'夏'**
  String get seasonSummer;

  /// No description provided for @seasonAutumn.
  ///
  /// In ja, this message translates to:
  /// **'秋'**
  String get seasonAutumn;

  /// No description provided for @seasonWinter.
  ///
  /// In ja, this message translates to:
  /// **'冬'**
  String get seasonWinter;

  /// No description provided for @settingsRegion.
  ///
  /// In ja, this message translates to:
  /// **'国・地域'**
  String get settingsRegion;

  /// No description provided for @regionAuto.
  ///
  /// In ja, this message translates to:
  /// **'自動（端末の設定）'**
  String get regionAuto;

  /// No description provided for @regionAll.
  ///
  /// In ja, this message translates to:
  /// **'すべての国'**
  String get regionAll;

  /// No description provided for @regionNote.
  ///
  /// In ja, this message translates to:
  /// **'国ごとの話題（日本の新幹線など）を、選んだ国でだけ出します。'**
  String get regionNote;

  /// No description provided for @settingsSeason.
  ///
  /// In ja, this message translates to:
  /// **'季節のおすすめ'**
  String get settingsSeason;

  /// No description provided for @seasonAuto.
  ///
  /// In ja, this message translates to:
  /// **'自動'**
  String get seasonAuto;

  /// No description provided for @seasonNorth.
  ///
  /// In ja, this message translates to:
  /// **'北半球'**
  String get seasonNorth;

  /// No description provided for @seasonSouth.
  ///
  /// In ja, this message translates to:
  /// **'南半球'**
  String get seasonSouth;

  /// No description provided for @seasonOff.
  ///
  /// In ja, this message translates to:
  /// **'オフ'**
  String get seasonOff;

  /// No description provided for @seasonNote.
  ///
  /// In ja, this message translates to:
  /// **'端末のタイムゾーンから推定します（位置情報は使いません）。'**
  String get seasonNote;

  /// No description provided for @relatedSection.
  ///
  /// In ja, this message translates to:
  /// **'関連する雑学'**
  String get relatedSection;

  /// No description provided for @whyButton.
  ///
  /// In ja, this message translates to:
  /// **'なぜ？'**
  String get whyButton;

  /// No description provided for @whyCheer.
  ///
  /// In ja, this message translates to:
  /// **'「なぜ？」を{count}回つづけたよ！すごい！'**
  String whyCheer(int count);

  /// No description provided for @mythsTitle.
  ///
  /// In ja, this message translates to:
  /// **'ほんと？うそ？'**
  String get mythsTitle;

  /// No description provided for @mythAnswerIs.
  ///
  /// In ja, this message translates to:
  /// **'こたえは「{verdict}」！'**
  String mythAnswerIs(String verdict);

  /// No description provided for @mythRead.
  ///
  /// In ja, this message translates to:
  /// **'くわしく よむ'**
  String get mythRead;

  /// No description provided for @mythProgress.
  ///
  /// In ja, this message translates to:
  /// **'{current} / {total}'**
  String mythProgress(int current, int total);

  /// No description provided for @mythResult.
  ///
  /// In ja, this message translates to:
  /// **'{total}もんちゅう {correct}もん せいかい！'**
  String mythResult(int correct, int total);

  /// No description provided for @mythAgain.
  ///
  /// In ja, this message translates to:
  /// **'もういちど'**
  String get mythAgain;

  /// No description provided for @mythNone.
  ///
  /// In ja, this message translates to:
  /// **'いま あそべる もんだいが ありません'**
  String get mythNone;

  /// No description provided for @mythNext.
  ///
  /// In ja, this message translates to:
  /// **'つぎへ'**
  String get mythNext;

  /// No description provided for @mythFinish.
  ///
  /// In ja, this message translates to:
  /// **'けっかを みる'**
  String get mythFinish;

  /// No description provided for @todayTitle.
  ///
  /// In ja, this message translates to:
  /// **'今日は何の日'**
  String get todayTitle;

  /// No description provided for @todayNone.
  ///
  /// In ja, this message translates to:
  /// **'きょうは とくべつな ひでは ありません'**
  String get todayNone;

  /// No description provided for @todayUpcoming.
  ///
  /// In ja, this message translates to:
  /// **'もうすぐ'**
  String get todayUpcoming;

  /// No description provided for @todayBanner.
  ///
  /// In ja, this message translates to:
  /// **'今日は「{title}」'**
  String todayBanner(String title);

  /// No description provided for @todayCountry.
  ///
  /// In ja, this message translates to:
  /// **'この国の行事'**
  String get todayCountry;

  /// No description provided for @todayHome.
  ///
  /// In ja, this message translates to:
  /// **'今日は何の日'**
  String get todayHome;

  /// No description provided for @dateMonthDay.
  ///
  /// In ja, this message translates to:
  /// **'{date}'**
  String dateMonthDay(DateTime date);

  /// No description provided for @listenInEnglish.
  ///
  /// In ja, this message translates to:
  /// **'英語で聞く'**
  String get listenInEnglish;

  /// No description provided for @listenInJapanese.
  ///
  /// In ja, this message translates to:
  /// **'日本語で聞く'**
  String get listenInJapanese;

  /// No description provided for @vocabEnglishTitle.
  ///
  /// In ja, this message translates to:
  /// **'英語のことば'**
  String get vocabEnglishTitle;

  /// No description provided for @vocabJapaneseTitle.
  ///
  /// In ja, this message translates to:
  /// **'日本語のことば'**
  String get vocabJapaneseTitle;

  /// No description provided for @vocabTapToHear.
  ///
  /// In ja, this message translates to:
  /// **'タップで発音を聞けます'**
  String get vocabTapToHear;

  /// No description provided for @listenTitle.
  ///
  /// In ja, this message translates to:
  /// **'ながら聞き'**
  String get listenTitle;

  /// No description provided for @listenPlay.
  ///
  /// In ja, this message translates to:
  /// **'再生'**
  String get listenPlay;

  /// No description provided for @listenPause.
  ///
  /// In ja, this message translates to:
  /// **'一時停止'**
  String get listenPause;

  /// No description provided for @listenNext.
  ///
  /// In ja, this message translates to:
  /// **'つぎへ'**
  String get listenNext;

  /// No description provided for @listenPrev.
  ///
  /// In ja, this message translates to:
  /// **'まえへ'**
  String get listenPrev;

  /// No description provided for @listenSpeedLabel.
  ///
  /// In ja, this message translates to:
  /// **'速さ'**
  String get listenSpeedLabel;

  /// No description provided for @listenSlow.
  ///
  /// In ja, this message translates to:
  /// **'ゆっくり'**
  String get listenSlow;

  /// No description provided for @listenNormal.
  ///
  /// In ja, this message translates to:
  /// **'ふつう'**
  String get listenNormal;

  /// No description provided for @listenFast.
  ///
  /// In ja, this message translates to:
  /// **'はやい'**
  String get listenFast;

  /// No description provided for @listenFinished.
  ///
  /// In ja, this message translates to:
  /// **'おしまい。もういちど聞くには再生を押してください'**
  String get listenFinished;

  /// No description provided for @listenNote.
  ///
  /// In ja, this message translates to:
  /// **'画面を開いたまま使います（通勤・料理中など）。'**
  String get listenNote;

  /// No description provided for @listenEmpty.
  ///
  /// In ja, this message translates to:
  /// **'いま聞ける雑学がありません'**
  String get listenEmpty;

  /// No description provided for @listenOpen.
  ///
  /// In ja, this message translates to:
  /// **'ながら聞き'**
  String get listenOpen;

  /// No description provided for @projectsTitle.
  ///
  /// In ja, this message translates to:
  /// **'自由研究ネタ帳'**
  String get projectsTitle;

  /// No description provided for @projectMinutes.
  ///
  /// In ja, this message translates to:
  /// **'{minutes}分くらい'**
  String projectMinutes(int minutes);

  /// No description provided for @projectNeedsAdult.
  ///
  /// In ja, this message translates to:
  /// **'おとなといっしょに'**
  String get projectNeedsAdult;

  /// No description provided for @projectDifficulty.
  ///
  /// In ja, this message translates to:
  /// **'むずかしさ'**
  String get projectDifficulty;

  /// No description provided for @projectMaterials.
  ///
  /// In ja, this message translates to:
  /// **'ようい するもの'**
  String get projectMaterials;

  /// No description provided for @projectSteps.
  ///
  /// In ja, this message translates to:
  /// **'やりかた'**
  String get projectSteps;

  /// No description provided for @projectObserve.
  ///
  /// In ja, this message translates to:
  /// **'かんさつ ポイント'**
  String get projectObserve;

  /// No description provided for @projectSafety.
  ///
  /// In ja, this message translates to:
  /// **'あんぜんに ちゅうい'**
  String get projectSafety;

  /// No description provided for @projectFromFact.
  ///
  /// In ja, this message translates to:
  /// **'自由研究にしてみよう'**
  String get projectFromFact;

  /// No description provided for @projectsEmpty.
  ///
  /// In ja, this message translates to:
  /// **'いま表示できる自由研究がありません'**
  String get projectsEmpty;

  /// No description provided for @projectsSummer.
  ///
  /// In ja, this message translates to:
  /// **'夏休みにぴったり'**
  String get projectsSummer;

  /// No description provided for @quickLinks.
  ///
  /// In ja, this message translates to:
  /// **'もっと見る'**
  String get quickLinks;

  /// No description provided for @projectsIntro.
  ///
  /// In ja, this message translates to:
  /// **'雑学から、おうちでできる実験・観察へ。'**
  String get projectsIntro;

  /// No description provided for @premiumActive.
  ///
  /// In ja, this message translates to:
  /// **'プレミアムをご利用中です'**
  String get premiumActive;

  /// No description provided for @premiumMonthly.
  ///
  /// In ja, this message translates to:
  /// **'月額プラン'**
  String get premiumMonthly;

  /// No description provided for @premiumAnnual.
  ///
  /// In ja, this message translates to:
  /// **'年額プラン'**
  String get premiumAnnual;

  /// No description provided for @premiumTrial.
  ///
  /// In ja, this message translates to:
  /// **'無料トライアルあり'**
  String get premiumTrial;

  /// No description provided for @premiumBuy.
  ///
  /// In ja, this message translates to:
  /// **'このプランで始める'**
  String get premiumBuy;

  /// No description provided for @premiumRestore.
  ///
  /// In ja, this message translates to:
  /// **'購入を復元'**
  String get premiumRestore;

  /// No description provided for @premiumLegal.
  ///
  /// In ja, this message translates to:
  /// **'お支払いはお使いのストアのアカウントに請求されます。プランは自動で更新され、解約はストアの設定からいつでもできます。無料トライアルがあるプランは、期間が終わると自動で課金が始まります。'**
  String get premiumLegal;

  /// No description provided for @premiumPurchased.
  ///
  /// In ja, this message translates to:
  /// **'ご購入ありがとうございます！'**
  String get premiumPurchased;

  /// No description provided for @premiumCancelled.
  ///
  /// In ja, this message translates to:
  /// **'購入をやめました'**
  String get premiumCancelled;

  /// No description provided for @premiumFailed.
  ///
  /// In ja, this message translates to:
  /// **'購入できませんでした。しばらくしてからもう一度お試しください'**
  String get premiumFailed;

  /// No description provided for @premiumRestored.
  ///
  /// In ja, this message translates to:
  /// **'購入を復元しました'**
  String get premiumRestored;

  /// No description provided for @premiumNothingToRestore.
  ///
  /// In ja, this message translates to:
  /// **'復元できる購入が見つかりませんでした'**
  String get premiumNothingToRestore;

  /// No description provided for @privacyTitle.
  ///
  /// In ja, this message translates to:
  /// **'プライバシーとアプリについて'**
  String get privacyTitle;

  /// No description provided for @privacyDataHeading.
  ///
  /// In ja, this message translates to:
  /// **'データの扱い'**
  String get privacyDataHeading;

  /// No description provided for @privacyPointLocal.
  ///
  /// In ja, this message translates to:
  /// **'設定・保存した雑学・記録は、この端末の中だけに保存されます。'**
  String get privacyPointLocal;

  /// No description provided for @privacyPointBirthYear.
  ///
  /// In ja, this message translates to:
  /// **'生まれた年は年代の判定にだけ使い、保存しません。'**
  String get privacyPointBirthYear;

  /// No description provided for @privacyPointNoAds.
  ///
  /// In ja, this message translates to:
  /// **'広告も、利用状況の分析（アナリティクス）もありません。'**
  String get privacyPointNoAds;

  /// No description provided for @privacyPointChildren.
  ///
  /// In ja, this message translates to:
  /// **'Kids / Junior では、ネットワーク通信も課金のしくみも使いません。'**
  String get privacyPointChildren;

  /// No description provided for @privacyPointTeenAdult.
  ///
  /// In ja, this message translates to:
  /// **'Teen / Adult では、おすすめアプリの案内（設定でオフにできます）と、プレミアムの購入状態の確認のために通信することがあります。支払い情報はアプリには届きません。'**
  String get privacyPointTeenAdult;

  /// No description provided for @privacyContact.
  ///
  /// In ja, this message translates to:
  /// **'お問い合わせ: {email}'**
  String privacyContact(String email);

  /// No description provided for @privacyLicenses.
  ///
  /// In ja, this message translates to:
  /// **'オープンソースライセンス'**
  String get privacyLicenses;

  /// No description provided for @privacyVersion.
  ///
  /// In ja, this message translates to:
  /// **'バージョン {version}'**
  String privacyVersion(String version);

  /// No description provided for @privacyDeleteButton.
  ///
  /// In ja, this message translates to:
  /// **'この端末のデータを削除'**
  String get privacyDeleteButton;

  /// No description provided for @privacyDeleteTitle.
  ///
  /// In ja, this message translates to:
  /// **'データを削除しますか？'**
  String get privacyDeleteTitle;

  /// No description provided for @privacyDeleteBody.
  ///
  /// In ja, this message translates to:
  /// **'設定・保存した雑学・記録・通知の予約がすべて消え、最初の画面に戻ります。元に戻せません。購入済みのプレミアムは消えません（ストアで復元できます）。'**
  String get privacyDeleteBody;

  /// No description provided for @privacyDeleteConfirm.
  ///
  /// In ja, this message translates to:
  /// **'削除する'**
  String get privacyDeleteConfirm;

  /// No description provided for @privacyDeleteCancel.
  ///
  /// In ja, this message translates to:
  /// **'やめる'**
  String get privacyDeleteCancel;

  /// No description provided for @privacyDeleted.
  ///
  /// In ja, this message translates to:
  /// **'データを削除しました'**
  String get privacyDeleted;

  /// No description provided for @shareImage.
  ///
  /// In ja, this message translates to:
  /// **'画像でシェア'**
  String get shareImage;

  /// No description provided for @sourcesSection.
  ///
  /// In ja, this message translates to:
  /// **'出典'**
  String get sourcesSection;

  /// No description provided for @battleTitle.
  ///
  /// In ja, this message translates to:
  /// **'クイズたいせん'**
  String get battleTitle;

  /// No description provided for @battlePlayers.
  ///
  /// In ja, this message translates to:
  /// **'なんにんで あそぶ？'**
  String get battlePlayers;

  /// No description provided for @battleSolo.
  ///
  /// In ja, this message translates to:
  /// **'ひとり'**
  String get battleSolo;

  /// No description provided for @battlePlayerCount.
  ///
  /// In ja, this message translates to:
  /// **'{n}にん'**
  String battlePlayerCount(int n);

  /// No description provided for @battlePlayerDefault.
  ///
  /// In ja, this message translates to:
  /// **'プレイヤー{n}'**
  String battlePlayerDefault(int n);

  /// No description provided for @battleRounds.
  ///
  /// In ja, this message translates to:
  /// **'なんもん？'**
  String get battleRounds;

  /// No description provided for @battleRoundCount.
  ///
  /// In ja, this message translates to:
  /// **'{n}もん'**
  String battleRoundCount(int n);

  /// No description provided for @battleHandHint.
  ///
  /// In ja, this message translates to:
  /// **'1つの たんまつを じゅんばんに まわして あそぼう。'**
  String get battleHandHint;

  /// No description provided for @battleStart.
  ///
  /// In ja, this message translates to:
  /// **'はじめる'**
  String get battleStart;

  /// No description provided for @battleNoQuestions.
  ///
  /// In ja, this message translates to:
  /// **'だせる クイズが ありません。'**
  String get battleNoQuestions;

  /// No description provided for @battleRoundOf.
  ///
  /// In ja, this message translates to:
  /// **'{n} / {total} もんめ'**
  String battleRoundOf(int n, int total);

  /// No description provided for @battleTurnOf.
  ///
  /// In ja, this message translates to:
  /// **'{name}の ばん'**
  String battleTurnOf(String name);

  /// No description provided for @battleSeeResult.
  ///
  /// In ja, this message translates to:
  /// **'けっかを みる'**
  String get battleSeeResult;

  /// No description provided for @battleFinished.
  ///
  /// In ja, this message translates to:
  /// **'おしまい！'**
  String get battleFinished;

  /// No description provided for @battleSoloScore.
  ///
  /// In ja, this message translates to:
  /// **'{score} / {total} もん せいかい！'**
  String battleSoloScore(int score, int total);

  /// No description provided for @battleDraw.
  ///
  /// In ja, this message translates to:
  /// **'ひきわけ！'**
  String get battleDraw;

  /// No description provided for @battleWinner.
  ///
  /// In ja, this message translates to:
  /// **'{name}の かち！'**
  String battleWinner(String name);

  /// No description provided for @battleRank.
  ///
  /// In ja, this message translates to:
  /// **'{n}い'**
  String battleRank(int n);

  /// No description provided for @battleAgain.
  ///
  /// In ja, this message translates to:
  /// **'もういちど'**
  String get battleAgain;

  /// No description provided for @battleChangeSettings.
  ///
  /// In ja, this message translates to:
  /// **'せっていを かえる'**
  String get battleChangeSettings;

  /// No description provided for @battleExit.
  ///
  /// In ja, this message translates to:
  /// **'おわる'**
  String get battleExit;

  /// No description provided for @battleKind.
  ///
  /// In ja, this message translates to:
  /// **'クイズの しゅるい'**
  String get battleKind;

  /// No description provided for @battleKindAll.
  ///
  /// In ja, this message translates to:
  /// **'ぜんぶ'**
  String get battleKindAll;

  /// No description provided for @battleKindTrueFalse.
  ///
  /// In ja, this message translates to:
  /// **'○×'**
  String get battleKindTrueFalse;

  /// No description provided for @battleKindChoice.
  ///
  /// In ja, this message translates to:
  /// **'えらぶ'**
  String get battleKindChoice;

  /// No description provided for @battleGenre.
  ///
  /// In ja, this message translates to:
  /// **'ジャンル'**
  String get battleGenre;

  /// No description provided for @battleGenreAll.
  ///
  /// In ja, this message translates to:
  /// **'ぜんぶ'**
  String get battleGenreAll;

  /// No description provided for @battleTimeLimit.
  ///
  /// In ja, this message translates to:
  /// **'せいげんじかん'**
  String get battleTimeLimit;

  /// No description provided for @battleTimeOff.
  ///
  /// In ja, this message translates to:
  /// **'なし'**
  String get battleTimeOff;

  /// No description provided for @battleSeconds.
  ///
  /// In ja, this message translates to:
  /// **'{n}びょう'**
  String battleSeconds(int n);

  /// No description provided for @battleSecondsLeft.
  ///
  /// In ja, this message translates to:
  /// **'のこり {n}びょう'**
  String battleSecondsLeft(int n);

  /// No description provided for @battleTimeHint.
  ///
  /// In ja, this message translates to:
  /// **'はやく こたえるほど、おまけの てんが ふえるよ（おなじ せいかいすうの ときに くらべる）。'**
  String get battleTimeHint;

  /// No description provided for @battleCorrectIs.
  ///
  /// In ja, this message translates to:
  /// **'せいかいは「{answer}」'**
  String battleCorrectIs(String answer);

  /// No description provided for @battlePoints.
  ///
  /// In ja, this message translates to:
  /// **'{n}てん'**
  String battlePoints(int n);

  /// No description provided for @reviewTitle.
  ///
  /// In ja, this message translates to:
  /// **'おさらい'**
  String get reviewTitle;

  /// No description provided for @reviewNone.
  ///
  /// In ja, this message translates to:
  /// **'きょうの おさらいは ありません。「しらなかった」を おした ざつがくが、あしたから でてくるよ。'**
  String get reviewNone;

  /// No description provided for @reviewDoneNote.
  ///
  /// In ja, this message translates to:
  /// **'また あした おさらいしよう。'**
  String get reviewDoneNote;

  /// No description provided for @reviewChip.
  ///
  /// In ja, this message translates to:
  /// **'おさらい'**
  String get reviewChip;

  /// No description provided for @reviewChipCount.
  ///
  /// In ja, this message translates to:
  /// **'おさらい {n}'**
  String reviewChipCount(int n);

  /// No description provided for @dailyTitle.
  ///
  /// In ja, this message translates to:
  /// **'きょうの チャレンジ'**
  String get dailyTitle;

  /// No description provided for @dailyChip.
  ///
  /// In ja, this message translates to:
  /// **'チャレンジ'**
  String get dailyChip;

  /// No description provided for @dailyStreak.
  ///
  /// In ja, this message translates to:
  /// **'{n}にち つづけて あそんだよ'**
  String dailyStreak(int n);

  /// No description provided for @dailyComeBack.
  ///
  /// In ja, this message translates to:
  /// **'また あした ちょうせんしよう！'**
  String get dailyComeBack;

  /// No description provided for @dailyShare.
  ///
  /// In ja, this message translates to:
  /// **'けっかを シェア'**
  String get dailyShare;

  /// No description provided for @badgesTitle.
  ///
  /// In ja, this message translates to:
  /// **'バッジ'**
  String get badgesTitle;

  /// No description provided for @badgesChip.
  ///
  /// In ja, this message translates to:
  /// **'バッジ'**
  String get badgesChip;

  /// No description provided for @badgesCount.
  ///
  /// In ja, this message translates to:
  /// **'{n} / {total} こ ゲット！'**
  String badgesCount(int n, int total);

  /// No description provided for @badgeStreak.
  ///
  /// In ja, this message translates to:
  /// **'{n}にち れんぞく'**
  String badgeStreak(int n);

  /// No description provided for @badgeReadDays.
  ///
  /// In ja, this message translates to:
  /// **'{n}にち よんだ'**
  String badgeReadDays(int n);

  /// No description provided for @badgeLearned.
  ///
  /// In ja, this message translates to:
  /// **'{n}こ しれた'**
  String badgeLearned(int n);

  /// No description provided for @badgeQuiz.
  ///
  /// In ja, this message translates to:
  /// **'クイズ {n}もん せいかい'**
  String badgeQuiz(int n);

  /// No description provided for @badgeDaily.
  ///
  /// In ja, this message translates to:
  /// **'チャレンジ {n}にち'**
  String badgeDaily(int n);

  /// No description provided for @badgePerfect.
  ///
  /// In ja, this message translates to:
  /// **'チャレンジ ぜんもん せいかい'**
  String get badgePerfect;

  /// No description provided for @reportTitle.
  ///
  /// In ja, this message translates to:
  /// **'がくしゅうの ようす'**
  String get reportTitle;

  /// No description provided for @reportNote.
  ///
  /// In ja, this message translates to:
  /// **'この ようすは、この たんまつの なかだけに ある きろくから つくっています。そとには おくりません。'**
  String get reportNote;

  /// No description provided for @reportLearned.
  ///
  /// In ja, this message translates to:
  /// **'「しらなかった」と おぼえた ざつがく'**
  String get reportLearned;

  /// No description provided for @reportKnew.
  ///
  /// In ja, this message translates to:
  /// **'「しってた」ざつがく'**
  String get reportKnew;

  /// No description provided for @reportQuiz.
  ///
  /// In ja, this message translates to:
  /// **'クイズの せいかい'**
  String get reportQuiz;

  /// No description provided for @reportNoQuiz.
  ///
  /// In ja, this message translates to:
  /// **'まだ なし'**
  String get reportNoQuiz;

  /// No description provided for @reportReviewPending.
  ///
  /// In ja, this message translates to:
  /// **'おさらい まち'**
  String get reportReviewPending;

  /// No description provided for @reportFavorite.
  ///
  /// In ja, this message translates to:
  /// **'よく みた ジャンル'**
  String get reportFavorite;

  /// No description provided for @reportEmpty.
  ///
  /// In ja, this message translates to:
  /// **'まだ きろくが ありません。'**
  String get reportEmpty;

  /// No description provided for @reportRecent.
  ///
  /// In ja, this message translates to:
  /// **'さいきん しれたこと'**
  String get reportRecent;

  /// No description provided for @reportOpen.
  ///
  /// In ja, this message translates to:
  /// **'がくしゅうの ようす（おうちの ひとへ）'**
  String get reportOpen;

  /// No description provided for @mascotTitle.
  ///
  /// In ja, this message translates to:
  /// **'あいぼう'**
  String get mascotTitle;

  /// No description provided for @mascotNext.
  ///
  /// In ja, this message translates to:
  /// **'あと {n} で「{name}」に なるよ'**
  String mascotNext(int n, String name);

  /// No description provided for @mascotMax.
  ///
  /// In ja, this message translates to:
  /// **'いちばん おおきく なったよ！'**
  String get mascotMax;

  /// No description provided for @mascotHint.
  ///
  /// In ja, this message translates to:
  /// **'ざつがくを ひらくと +1、「しらなかった」を おぼえると +2 で そだつよ。'**
  String get mascotHint;

  /// No description provided for @mascotPoints.
  ///
  /// In ja, this message translates to:
  /// **'{n} ポイント'**
  String mascotPoints(int n);

  /// No description provided for @mascotLocked.
  ///
  /// In ja, this message translates to:
  /// **'？？？'**
  String get mascotLocked;

  /// No description provided for @mascotName_egg.
  ///
  /// In ja, this message translates to:
  /// **'たまご'**
  String get mascotName_egg;

  /// No description provided for @mascotSay_egg.
  ///
  /// In ja, this message translates to:
  /// **'…ざつがく、まってるよ。'**
  String get mascotSay_egg;

  /// No description provided for @mascotName_chick.
  ///
  /// In ja, this message translates to:
  /// **'ひよこ'**
  String get mascotName_chick;

  /// No description provided for @mascotSay_chick.
  ///
  /// In ja, this message translates to:
  /// **'ぴよっ！ ざつがく おもしろいね！'**
  String get mascotSay_chick;

  /// No description provided for @mascotName_chicklet.
  ///
  /// In ja, this message translates to:
  /// **'ちびふくろう'**
  String get mascotName_chicklet;

  /// No description provided for @mascotSay_chicklet.
  ///
  /// In ja, this message translates to:
  /// **'ふわふわ！ もっと しりたいな。'**
  String get mascotSay_chicklet;

  /// No description provided for @mascotName_owl.
  ///
  /// In ja, this message translates to:
  /// **'ふくろう'**
  String get mascotName_owl;

  /// No description provided for @mascotSay_owl.
  ///
  /// In ja, this message translates to:
  /// **'ほー！ ものしりに なってきたよ。'**
  String get mascotSay_owl;

  /// No description provided for @mascotName_professor.
  ///
  /// In ja, this message translates to:
  /// **'はかせふくろう'**
  String get mascotName_professor;

  /// No description provided for @mascotSay_professor.
  ///
  /// In ja, this message translates to:
  /// **'ふむふむ、なるほど。きみは はかせだね。'**
  String get mascotSay_professor;

  /// No description provided for @mascotName_king.
  ///
  /// In ja, this message translates to:
  /// **'ふくろうおう'**
  String get mascotName_king;

  /// No description provided for @mascotSay_king.
  ///
  /// In ja, this message translates to:
  /// **'ほっほー！ ざつがくの おうさまだ！'**
  String get mascotSay_king;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
