// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Knowly';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'Match device';

  @override
  String get languageJa => '日本語';

  @override
  String get languageEn => 'English';

  @override
  String get continueButton => 'Next';

  @override
  String get birthYearTitle => 'Choose your birth year';

  @override
  String get birthYearNote =>
      'Used only to match content to your age. Your birth year is not saved or sent anywhere.';

  @override
  String get parentNoteTitle => 'For parents';

  @override
  String get parentNoteBody =>
      'Please use this app together with your child. It collects no personal information from children and shows no ads.';

  @override
  String get modeKids => 'Kids (preschool)';

  @override
  String get modeJunior => 'Junior (school age)';

  @override
  String get modeTeen => 'Teen';

  @override
  String get modeAdult => 'Adult';

  @override
  String get interestsTitle => 'Pick what you like';

  @override
  String get interestsAll => 'All';

  @override
  String get catAnimals => 'Animals';

  @override
  String get catSpace => 'Space';

  @override
  String get catBody => 'Body';

  @override
  String get catNature => 'Nature';

  @override
  String get catScience => 'Science';

  @override
  String get catGeography => 'Geography';

  @override
  String get sceneFriends => 'With friends';

  @override
  String get sceneKids => 'With kids';

  @override
  String get sceneWork => 'At work';

  @override
  String get sceneFamily => 'With family';

  @override
  String get sceneLearning => 'Learning';

  @override
  String get filterReset => 'Reset';

  @override
  String get today => 'Today\'s fact';

  @override
  String get past => 'Earlier facts';

  @override
  String get kidsNext => 'Next fact';

  @override
  String get kidsListen => 'Listen';

  @override
  String get emptyFeed => 'No facts to show right now';

  @override
  String get lockedFeedNote => 'Older facts are available with Premium';

  @override
  String get savedTitle => 'Saved';

  @override
  String get savedEmpty => 'Nothing saved yet';

  @override
  String savedLimit(int count) {
    return 'The free plan can save up to $count facts';
  }

  @override
  String get save => 'Save';

  @override
  String get unsave => 'Saved';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get ratingHeh => 'Whoa!';

  @override
  String get ratingUseful => 'Useful!';

  @override
  String get ratingWow => 'Amazing';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsUiLanguage => 'App language';

  @override
  String get settingsContentLanguage => 'Fact language';

  @override
  String get settingsMode => 'Age mode';

  @override
  String get settingsModeNote => 'Changing the mode needs the parent gate';

  @override
  String get settingsPremium => 'Premium';

  @override
  String get settingsOtherApps => 'Check out our other apps';

  @override
  String get settingsPrivacy =>
      'This app collects no personal information from children and shows no ads.';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumBenefit1 => 'Read up to 30 days of past facts';

  @override
  String get premiumBenefit2 => 'Unlimited saves';

  @override
  String get premiumBenefit3 => 'Offline saving and deep dives (coming soon)';

  @override
  String get premiumKidsFree => 'Kids and Junior facts are always free.';

  @override
  String get premiumUnavailable => 'Purchases are coming soon';

  @override
  String get gateTitle => 'For parents';

  @override
  String get gateDescription =>
      'This step is for adults.\nEnter the answer to the sum below.';

  @override
  String get gateHint => 'Enter the answer';

  @override
  String get gateWrong => 'That is not the right answer';

  @override
  String get gateOk => 'Next';

  @override
  String get gateCancel => 'Cancel';

  @override
  String get close => 'Close';
}
