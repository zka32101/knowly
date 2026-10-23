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

  @override
  String get listenInEnglish => 'Listen in English';

  @override
  String get listenInJapanese => 'Listen in Japanese';

  @override
  String get vocabEnglishTitle => 'English words';

  @override
  String get vocabJapaneseTitle => 'Japanese words';

  @override
  String get vocabTapToHear => 'Tap a word to hear it';

  @override
  String get listenTitle => 'Listen mode';

  @override
  String get listenPlay => 'Play';

  @override
  String get listenPause => 'Pause';

  @override
  String get listenNext => 'Next';

  @override
  String get listenPrev => 'Previous';

  @override
  String get listenSpeedLabel => 'Speed';

  @override
  String get listenSlow => 'Slow';

  @override
  String get listenNormal => 'Normal';

  @override
  String get listenFast => 'Fast';

  @override
  String get listenFinished => 'That\'s all. Press play to listen again';

  @override
  String get listenNote =>
      'Keep the app open while listening (commuting, cooking...).';

  @override
  String get listenEmpty => 'No facts to listen to right now';

  @override
  String get listenOpen => 'Listen mode';

  @override
  String get projectsTitle => 'Science project ideas';

  @override
  String projectMinutes(int minutes) {
    return 'About $minutes min';
  }

  @override
  String get projectNeedsAdult => 'With an adult';

  @override
  String get projectDifficulty => 'Difficulty';

  @override
  String get projectMaterials => 'What you need';

  @override
  String get projectSteps => 'Steps';

  @override
  String get projectObserve => 'What to notice';

  @override
  String get projectSafety => 'Safety';

  @override
  String get projectFromFact => 'Try it as a project';

  @override
  String get projectsEmpty => 'No projects to show right now';

  @override
  String get projectsSummer => 'Great for summer break';

  @override
  String get quickLinks => 'More';

  @override
  String get projectsIntro =>
      'From a fact to an experiment you can do at home.';

  @override
  String get premiumActive => 'You have Premium';

  @override
  String get premiumMonthly => 'Monthly';

  @override
  String get premiumAnnual => 'Annual';

  @override
  String get premiumTrial => 'Free trial available';

  @override
  String get premiumBuy => 'Start this plan';

  @override
  String get premiumRestore => 'Restore purchases';

  @override
  String get premiumLegal =>
      'Payment is charged to your store account. Plans renew automatically and you can cancel any time in your store settings. Plans with a free trial start charging automatically when the trial ends.';

  @override
  String get premiumPurchased => 'Thank you for your purchase!';

  @override
  String get premiumCancelled => 'Purchase cancelled';

  @override
  String get premiumFailed =>
      'The purchase could not be completed. Please try again later.';

  @override
  String get premiumRestored => 'Purchases restored';

  @override
  String get premiumNothingToRestore => 'No purchases to restore were found';

  @override
  String get privacyTitle => 'Privacy & about';

  @override
  String get privacyDataHeading => 'How your data is handled';

  @override
  String get privacyPointLocal =>
      'Your settings, saved facts and records stay on this device only.';

  @override
  String get privacyPointBirthYear =>
      'Your birth year is used only to pick an age mode and is never stored.';

  @override
  String get privacyPointNoAds => 'There are no ads and no usage analytics.';

  @override
  String get privacyPointChildren =>
      'Kids and Junior modes use no network connection and no purchase SDK.';

  @override
  String get privacyPointTeenAdult =>
      'Teen and Adult modes may connect to show app recommendations (can be turned off in Settings) and to check your Premium status. Payment details never reach the app.';

  @override
  String privacyContact(String email) {
    return 'Contact: $email';
  }

  @override
  String get privacyLicenses => 'Open-source licenses';

  @override
  String privacyVersion(String version) {
    return 'Version $version';
  }

  @override
  String get privacyDeleteButton => 'Delete data on this device';

  @override
  String get privacyDeleteTitle => 'Delete your data?';

  @override
  String get privacyDeleteBody =>
      'All settings, saved facts, records and scheduled notifications will be erased and the app returns to the first screen. This cannot be undone. Premium you purchased is kept (restore it from the store).';

  @override
  String get privacyDeleteConfirm => 'Delete';

  @override
  String get privacyDeleteCancel => 'Cancel';

  @override
  String get privacyDeleted => 'Data deleted';

  @override
  String get shareImage => 'Share as image';

  @override
  String get sourcesSection => 'Sources';

  @override
  String get battleTitle => 'Quiz battle';

  @override
  String get battlePlayers => 'How many players?';

  @override
  String get battleSolo => 'Solo';

  @override
  String battlePlayerCount(int n) {
    return '$n players';
  }

  @override
  String battlePlayerDefault(int n) {
    return 'Player $n';
  }

  @override
  String get battleRounds => 'How many questions?';

  @override
  String battleRoundCount(int n) {
    return '$n questions';
  }

  @override
  String get battleHandHint => 'Pass the device around and take turns.';

  @override
  String get battleStart => 'Start';

  @override
  String get battleNoQuestions => 'No quiz questions are available.';

  @override
  String battleRoundOf(int n, int total) {
    return 'Question $n of $total';
  }

  @override
  String battleTurnOf(String name) {
    return '$name\'s turn';
  }

  @override
  String get battleSeeResult => 'See results';

  @override
  String get battleFinished => 'All done!';

  @override
  String battleSoloScore(int score, int total) {
    return '$score of $total correct!';
  }

  @override
  String get battleDraw => 'It\'s a tie!';

  @override
  String battleWinner(String name) {
    return '$name wins!';
  }

  @override
  String battleRank(int n) {
    return '#$n';
  }

  @override
  String get battleAgain => 'Play again';

  @override
  String get battleChangeSettings => 'Change settings';

  @override
  String get battleExit => 'Exit';

  @override
  String get battleKind => 'Quiz type';

  @override
  String get battleKindAll => 'All';

  @override
  String get battleKindTrueFalse => 'True / false';

  @override
  String get battleKindChoice => 'Multiple choice';

  @override
  String get battleGenre => 'Genre';

  @override
  String get battleGenreAll => 'All';

  @override
  String get battleTimeLimit => 'Time limit';

  @override
  String get battleTimeOff => 'None';

  @override
  String battleSeconds(int n) {
    return '$n sec';
  }

  @override
  String battleSecondsLeft(int n) {
    return '$n sec left';
  }

  @override
  String get battleTimeHint =>
      'Faster answers earn bonus points (used to break ties).';

  @override
  String battleCorrectIs(String answer) {
    return 'The answer: $answer';
  }

  @override
  String battlePoints(int n) {
    return '$n pts';
  }

  @override
  String get reviewTitle => 'Review';

  @override
  String get reviewNone =>
      'Nothing to review today. Facts you mark \"I learned something\" will show up from tomorrow.';

  @override
  String get reviewDoneNote => 'Come back tomorrow to review more.';

  @override
  String get reviewChip => 'Review';

  @override
  String reviewChipCount(int n) {
    return 'Review $n';
  }

  @override
  String get dailyTitle => 'Daily challenge';

  @override
  String get dailyChip => 'Challenge';

  @override
  String dailyStreak(int n) {
    return '$n-day challenge streak';
  }

  @override
  String get dailyComeBack => 'Come back tomorrow for a new one!';

  @override
  String get dailyShare => 'Share result';

  @override
  String get badgesTitle => 'Badges';

  @override
  String get badgesChip => 'Badges';

  @override
  String badgesCount(int n, int total) {
    return '$n of $total earned';
  }

  @override
  String badgeStreak(int n) {
    return '$n-day streak';
  }

  @override
  String badgeReadDays(int n) {
    return 'Read on $n days';
  }

  @override
  String badgeLearned(int n) {
    return 'Learned $n facts';
  }

  @override
  String badgeQuiz(int n) {
    return '$n quiz answers right';
  }

  @override
  String badgeDaily(int n) {
    return '$n daily challenges';
  }

  @override
  String get badgePerfect => 'Perfect daily challenge';

  @override
  String get reportTitle => 'Learning report';

  @override
  String get reportNote =>
      'This report is built only from records stored on this device. Nothing is sent anywhere.';

  @override
  String get reportLearned => 'Facts marked \"learned something\"';

  @override
  String get reportKnew => 'Facts marked \"I knew it\"';

  @override
  String get reportQuiz => 'Quiz answers right';

  @override
  String get reportNoQuiz => 'None yet';

  @override
  String get reportReviewPending => 'Waiting for review';

  @override
  String get reportFavorite => 'Favorite genres';

  @override
  String get reportEmpty => 'No records yet.';

  @override
  String get reportRecent => 'Recently learned';

  @override
  String get reportOpen => 'Learning report (for parents)';

  @override
  String get mascotTitle => 'Buddy';

  @override
  String mascotNext(int n, String name) {
    return '$n more to become \"$name\"';
  }

  @override
  String get mascotMax => 'Fully grown!';

  @override
  String get mascotHint =>
      'Open a fact: +1. Mark \"I learned something\": +2. Your buddy grows as you go.';

  @override
  String mascotPoints(int n) {
    return '$n points';
  }

  @override
  String get mascotLocked => '???';

  @override
  String get mascotName_egg => 'Egg';

  @override
  String get mascotSay_egg => '…waiting for a fun fact.';

  @override
  String get mascotName_chick => 'Chick';

  @override
  String get mascotSay_chick => 'Peep! Facts are fun!';

  @override
  String get mascotName_chicklet => 'Little Owlet';

  @override
  String get mascotSay_chicklet => 'So fluffy! Tell me more.';

  @override
  String get mascotName_owl => 'Owl';

  @override
  String get mascotSay_owl => 'Hoo! I\'m getting wise.';

  @override
  String get mascotName_professor => 'Professor Owl';

  @override
  String get mascotSay_professor => 'Hmm, I see. You\'re a true scholar.';

  @override
  String get mascotName_king => 'Owl King';

  @override
  String get mascotSay_king => 'Hoo-hoo! The king of trivia!';

  @override
  String celebrateStage(String name) {
    return 'Your buddy became $name!';
  }

  @override
  String get celebrateBadge => 'New badge!';

  @override
  String get flipHint => 'Tap to flip';

  @override
  String get flipDetail => 'Read more';

  @override
  String get zukanTitle => 'Fact collection';

  @override
  String get zukanChip => 'Collection';

  @override
  String zukanFound(int n, int total) {
    return '$n of $total found';
  }

  @override
  String get zukanAll => 'All';

  @override
  String get zukanHint => 'Every fact you see fills in your collection.';

  @override
  String get zukanLocked => '?';

  @override
  String get capsuleTitle => 'Fact capsule';

  @override
  String get capsuleChip => 'Capsule';

  @override
  String get capsuleOpen => 'Open it!';

  @override
  String get capsuleHint => 'One mystery fact pops out each day.';

  @override
  String get capsuleDone => 'Come back tomorrow!';

  @override
  String get capsuleNew => 'New!';

  @override
  String get capsuleToZukan => 'See collection';

  @override
  String get capsuleEmpty => 'No facts available.';

  @override
  String get capsuleRarity1 => 'Common';

  @override
  String get capsuleRarity2 => 'Rare';

  @override
  String get capsuleRarity3 => 'Super rare';

  @override
  String get swipeTitle => 'Swipe: true or false?';

  @override
  String get swipeChip => 'Swipe';

  @override
  String get swipeHint => '→ true     ← false';

  @override
  String swipeCombo(int n) {
    return '🔥 $n in a row!';
  }

  @override
  String swipeBestCombo(int n) {
    return 'Best streak: $n';
  }

  @override
  String get tabHome => 'Home';

  @override
  String get tabPlay => 'Play';

  @override
  String get tabCollect => 'Collect';

  @override
  String get tabExplore => 'Explore';

  @override
  String get tabSettings => 'Settings';

  @override
  String get hubPlayIntro => 'Enjoy trivia through quizzes and games.';

  @override
  String get hubCollectIntro =>
      'The more facts you see, the more your buddy grows and your collection fills.';

  @override
  String get hubExploreIntro => 'Search for facts, or dig deeper.';

  @override
  String get hubQuizSub => '1-4 players';

  @override
  String get hubSwipeSub => 'True or false';

  @override
  String get hubDailySub => '3 questions a day';

  @override
  String get hubReviewSub => 'Don\'t forget';

  @override
  String get hubMythsSub => 'Common misconceptions';

  @override
  String get hubLibrarySub => 'Search & genres';

  @override
  String get hubListenSub => 'Hands-free';
}
