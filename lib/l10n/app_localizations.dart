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
