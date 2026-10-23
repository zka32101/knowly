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
  String get languageSystem => 'Device';

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
  String get kidsNext => 'Next';

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

  @override
  String get catBugs => 'Bugs';

  @override
  String get catVehicles => 'Vehicles';

  @override
  String get catFood => 'Food';

  @override
  String get viewAs => 'Reading level';

  @override
  String get viewOwn => 'Standard';

  @override
  String get viewJunior => 'For school kids';

  @override
  String get viewKids => 'For little ones';

  @override
  String get explainToKids => 'Explaining it to a child';

  @override
  String get bilingualOn => 'Show both languages';

  @override
  String get bilingualOff => 'Show one language';

  @override
  String get knewIt => 'I knew that';

  @override
  String get learnedIt => 'I learned something!';

  @override
  String streakDays(int count) {
    return '$count-day streak';
  }

  @override
  String get streakFreeze => 'Rest day ready';

  @override
  String get streakStart => 'Read today\'s fact to start a streak';

  @override
  String get statsTitle => 'Your facts';

  @override
  String statsKnowRate(int percent, int knew, int total) {
    return 'Facts you already knew: $percent% ($knew/$total)';
  }

  @override
  String get statsEmpty =>
      'Tap I knew that / I learned something to see stats here';

  @override
  String get quizButton => 'Quiz';

  @override
  String get quizTitle => 'True or false?';

  @override
  String get quizTrue => 'True';

  @override
  String get quizFalse => 'False';

  @override
  String get quizCorrect => 'Correct!';

  @override
  String get quizWrong => 'Not quite!';

  @override
  String get quizNext => 'Next';

  @override
  String get notifyTitle => 'Daily fact reminder';

  @override
  String get notifySubtitle =>
      'Get today\'s fact at a set time. Works entirely on your device.';

  @override
  String get notifyJuniorNote =>
      'A parent should set this up. It works on the device only and sends no data.';

  @override
  String get notifyTime => 'Notification time';

  @override
  String get notifyDenied =>
      'Notifications are not allowed. Please enable them in your device settings.';

  @override
  String get birthYearHint => 'Birth year';

  @override
  String get filterButton => 'Filter';

  @override
  String filterButtonActive(int count) {
    return 'Filter ($count)';
  }

  @override
  String get libraryTitle => 'Library';

  @override
  String get searchHint => 'Search facts (Japanese / English)';

  @override
  String get searchClear => 'Clear';

  @override
  String resultsCount(int count) {
    return '$count facts';
  }

  @override
  String get noResults => 'Nothing found. Try different words or filters';

  @override
  String get filterStatus => 'Status';

  @override
  String get statusSaved => 'Saved';

  @override
  String get statusKnew => 'I knew it';

  @override
  String get statusLearned => 'New to me';

  @override
  String get statusUnrated => 'Not rated';

  @override
  String get filterCategoryHeader => 'Genre';

  @override
  String get filterSceneHeader => 'Scene';

  @override
  String get libraryLocked => 'Premium to read';

  @override
  String get libraryOpen => 'Library';

  @override
  String get interestsSection => 'Your interests';

  @override
  String get interestsEdit => 'Edit';

  @override
  String get interestsEmptyTitle => 'Add your interests to see picks here';

  @override
  String get interestsRegister => 'Add interests';

  @override
  String get interestsNoMatch => 'No facts match your interests right now';

  @override
  String get interestsScreenTitle => 'Interests';

  @override
  String get interestsCategories => 'Genres';

  @override
  String get interestsScenes => 'Scenes';

  @override
  String get interestsKeywords => 'Keywords';

  @override
  String get interestsKeywordHint => 'e.g. space, otter, money';

  @override
  String get interestsAdd => 'Add';

  @override
  String interestsMax(int count) {
    return 'Up to $count keywords';
  }

  @override
  String get interestsNote =>
      'Your interests stay on this device and are never sent anywhere.';

  @override
  String get settingsInterests => 'Interests';

  @override
  String get timingSection => 'Right now';

  @override
  String get reasonDate => 'On this day';

  @override
  String reasonSeason(String season) {
    return 'Perfect for $season';
  }

  @override
  String get reasonNight => 'Good for tonight';

  @override
  String get reasonMorning => 'Good for the morning';

  @override
  String get reasonEvening => 'Good for the evening';

  @override
  String get reasonWeekend => 'For the weekend';

  @override
  String get seasonSpring => 'spring';

  @override
  String get seasonSummer => 'summer';

  @override
  String get seasonAutumn => 'autumn';

  @override
  String get seasonWinter => 'winter';

  @override
  String get settingsRegion => 'Country / region';

  @override
  String get regionAuto => 'Auto (device setting)';

  @override
  String get regionAll => 'All countries';

  @override
  String get regionNote =>
      'Country-specific facts are shown only for the selected country.';

  @override
  String get settingsSeason => 'Seasonal picks';

  @override
  String get seasonAuto => 'Auto';

  @override
  String get seasonNorth => 'North';

  @override
  String get seasonSouth => 'South';

  @override
  String get seasonOff => 'Off';

  @override
  String get seasonNote =>
      'Estimated from your time zone (no location is used).';

  @override
  String get relatedSection => 'Related facts';

  @override
  String get whyButton => 'Why?';

  @override
  String whyCheer(int count) {
    return 'You kept asking \"why?\" $count times! Great!';
  }

  @override
  String get mythsTitle => 'True or false?';

  @override
  String mythAnswerIs(String verdict) {
    return 'The answer: $verdict';
  }

  @override
  String get mythRead => 'Read more';

  @override
  String mythProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String mythResult(int correct, int total) {
    return '$correct of $total correct!';
  }

  @override
  String get mythAgain => 'Play again';

  @override
  String get mythNone => 'No questions to play right now';

  @override
  String get mythNext => 'Next';

  @override
  String get mythFinish => 'See results';

  @override
  String get todayTitle => 'On this day';

  @override
  String get todayNone => 'No special day today';

  @override
  String get todayUpcoming => 'Coming up';

  @override
  String todayBanner(String title) {
    return 'Today: $title';
  }

  @override
  String get todayCountry => 'Local event';

  @override
  String get todayHome => 'On this day';

  @override
  String dateMonthDay(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }
}
