// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'Knowly';

  @override
  String get languageTitle => '언어';

  @override
  String get languageSystem => '기기 설정';

  @override
  String get languageJa => '日本語';

  @override
  String get languageEn => 'English';

  @override
  String get continueButton => '다음';

  @override
  String get settingsJuniorRuby => '후리가나 표시';

  @override
  String get listenSlow => '느리게';

  @override
  String get settingsTextSize => '글자 크기';

  @override
  String get textSizeNormal => '보통';

  @override
  String get textSizeLarge => '크게';

  @override
  String get textSizeXLarge => '아주 크게';

  @override
  String relatedMore(int n) {
    return '더 보기 ($n개 더)';
  }

  @override
  String get searchRecent => '최근 검색';

  @override
  String get hintHomeTips => '카드를 누르면 뒤집혀요. ‘놀기’에는 퀴즈도 있어요!';

  @override
  String get hintGotIt => '알겠어요';

  @override
  String get onboardingSkip => '나중에';

  @override
  String get onboardingPickBand => '또는 가장 알맞은 것을 골라 주세요';

  @override
  String get birthYearTitle => '태어난 해를 선택하세요';

  @override
  String get birthYearNote =>
      '연령에 맞는 콘텐츠를 보여 주는 데만 사용합니다. 태어난 해는 저장되거나 어디로도 전송되지 않습니다.';

  @override
  String get parentNoteTitle => '부모님께';

  @override
  String get parentNoteBody =>
      '아이와 함께 사용해 주세요. 이 앱은 어린이의 개인정보를 수집하지 않으며 광고도 표시하지 않습니다.';

  @override
  String get modeKids => 'Kids (미취학)';

  @override
  String get modeJunior => 'Junior (초등학생)';

  @override
  String get modeTeen => 'Teen (청소년)';

  @override
  String get modeAdult => 'Adult (성인)';

  @override
  String get interestsTitle => '좋아하는 것을 골라 보세요';

  @override
  String get interestsAll => '전체';

  @override
  String get catAnimals => '동물';

  @override
  String get catSpace => '우주';

  @override
  String get catBody => '몸';

  @override
  String get catNature => '자연';

  @override
  String get catScience => '과학';

  @override
  String get catGeography => '지리';

  @override
  String get sceneFriends => '친구와 함께';

  @override
  String get sceneKids => '아이와 함께';

  @override
  String get sceneWork => '직장에서';

  @override
  String get sceneFamily => '가족과 함께';

  @override
  String get sceneLearning => '공부할 때';

  @override
  String get filterReset => '초기화';

  @override
  String get today => '오늘의 상식';

  @override
  String get past => '지난 상식';

  @override
  String get kidsNext => '다음';

  @override
  String get kidsListen => '듣기';

  @override
  String get emptyFeed => '지금 보여 줄 상식이 없어요';

  @override
  String get lockedFeedNote => '이전 상식은 Premium에서 볼 수 있어요';

  @override
  String get savedTitle => '저장함';

  @override
  String get savedEmpty => '아직 저장한 것이 없어요. 상세 화면에서 책갈피 아이콘을 누르면 여기에 모여요.';

  @override
  String savedLimit(int count) {
    return '무료 플랜에서는 최대 $count개까지 저장할 수 있어요';
  }

  @override
  String get save => '저장';

  @override
  String get unsave => '저장됨';

  @override
  String get copy => '복사';

  @override
  String get copied => '복사했어요';

  @override
  String get ratingHeh => '오!';

  @override
  String get ratingUseful => '유용해요!';

  @override
  String get ratingWow => '놀라워요';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsUiLanguage => '앱 언어';

  @override
  String get settingsContentLanguage => '상식 언어';

  @override
  String get settingsMode => '연령 모드';

  @override
  String get settingsModeNote => '모드를 바꾸려면 보호자 확인이 필요해요';

  @override
  String get settingsPremium => 'Premium';

  @override
  String get settingsOtherApps => '다른 앱도 구경해 보세요';

  @override
  String get settingsPrivacy => '이 앱은 어린이의 개인정보를 수집하지 않으며 광고도 표시하지 않습니다.';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumBenefit1 => '최근 30일의 지난 상식 읽기';

  @override
  String get premiumBenefit2 => '무제한 저장';

  @override
  String get premiumBenefit3 => '오프라인 저장과 심화 해설 (준비 중)';

  @override
  String get premiumKidsFree => 'Kids와 Junior의 상식은 언제나 무료예요.';

  @override
  String get premiumUnavailable => '결제 기능은 준비 중이에요';

  @override
  String get premiumOffline => '요금제를 불러오지 못했어요. 인터넷에 연결한 뒤 다시 열어 주세요.';

  @override
  String get gateTitle => '부모님께';

  @override
  String get gateDescription => '이 단계는 어른용이에요.\n아래 계산식의 답을 입력하세요.';

  @override
  String get gateHint => '답을 입력하세요';

  @override
  String get gateWrong => '정답이 아니에요';

  @override
  String get gateOk => '다음';

  @override
  String get gateCancel => '취소';

  @override
  String get close => '닫기';

  @override
  String get catBugs => '곤충';

  @override
  String get catVehicles => '탈것';

  @override
  String get catFood => '음식';

  @override
  String get viewAs => '읽기 수준';

  @override
  String get viewOwn => '기본';

  @override
  String get viewJunior => '초등학생용';

  @override
  String get viewKids => '어린이용';

  @override
  String get explainToKids => '아이에게 설명하기';

  @override
  String get bilingualOn => '두 언어로 보기';

  @override
  String get bilingualOff => '한 언어로 보기';

  @override
  String get knewIt => '알고 있었어요';

  @override
  String get learnedIt => '새로 알았어요!';

  @override
  String streakDays(int count) {
    return '$count일 연속';
  }

  @override
  String get streakFreeze => '쉬는 날 이용권 준비됨';

  @override
  String get streakStart => '오늘의 상식을 읽고 연속 기록을 시작해 보세요';

  @override
  String get statsTitle => '나의 상식';

  @override
  String statsKnowRate(int percent, int knew, int total) {
    return '이미 알고 있던 상식: $percent% ($knew/$total)';
  }

  @override
  String get statsEmpty => '\'알고 있었어요\' 또는 \'새로 알았어요\'를 누르면 여기에 통계가 표시돼요';

  @override
  String get quizButton => '퀴즈';

  @override
  String get quizTitle => '맞을까요, 틀릴까요?';

  @override
  String get quizTrue => '맞아요';

  @override
  String get quizFalse => '틀려요';

  @override
  String get quizCorrect => '정답!';

  @override
  String get quizWrong => '아쉬워요!';

  @override
  String get quizNext => '다음';

  @override
  String get notifyTitle => '매일 상식 알림';

  @override
  String get notifySubtitle => '정한 시간에 오늘의 상식을 받아 보세요. 기기 안에서만 작동해요.';

  @override
  String get notifyJuniorNote => '부모님이 설정해 주세요. 기기 안에서만 작동하며 데이터를 전송하지 않아요.';

  @override
  String get notifyTime => '알림 시간';

  @override
  String get notifyDenied => '알림이 허용되지 않았어요. 기기 설정에서 허용해 주세요.';

  @override
  String get birthYearHint => '태어난 해';

  @override
  String get filterButton => '필터';

  @override
  String filterButtonActive(int count) {
    return '필터 ($count)';
  }

  @override
  String get libraryTitle => '라이브러리';

  @override
  String get searchHint => '상식 검색 (일본어/영어)';

  @override
  String get searchClear => '지우기';

  @override
  String resultsCount(int count) {
    return '상식 $count개';
  }

  @override
  String get noResults => '찾지 못했어요. 다른 단어나 필터를 써 보세요';

  @override
  String get filterStatus => '상태';

  @override
  String get statusSaved => '저장함';

  @override
  String get statusKnew => '알고 있었어요';

  @override
  String get statusLearned => '새로 알았어요';

  @override
  String get statusUnrated => '평가 안 함';

  @override
  String get filterCategoryHeader => '장르';

  @override
  String get filterSceneHeader => '상황';

  @override
  String get libraryLocked => 'Premium 필요';

  @override
  String get libraryOpen => '라이브러리';

  @override
  String get interestsSection => '나의 관심사';

  @override
  String get interestsEdit => '편집';

  @override
  String get interestsEmptyTitle => '관심사를 추가하면 여기에 추천이 표시돼요';

  @override
  String get interestsRegister => '관심사 추가';

  @override
  String get interestsNoMatch => '지금 관심사에 맞는 상식이 없어요';

  @override
  String get interestsScreenTitle => '관심사';

  @override
  String get interestsCategories => '장르';

  @override
  String get interestsScenes => '상황';

  @override
  String get interestsKeywords => '키워드';

  @override
  String get interestsKeywordHint => '예: 우주, 해달, 돈';

  @override
  String get interestsAdd => '추가';

  @override
  String interestsMax(int count) {
    return '키워드는 최대 $count개';
  }

  @override
  String get interestsNote => '관심사는 이 기기에만 저장되며 어디로도 전송되지 않아요.';

  @override
  String get settingsInterests => '관심사';

  @override
  String get timingSection => '지금 추천';

  @override
  String get reasonDate => '오늘은 기념일';

  @override
  String reasonSeason(String season) {
    return '$season에 딱 맞아요';
  }

  @override
  String get reasonNight => '오늘 밤에 좋아요';

  @override
  String get reasonMorning => '아침에 좋아요';

  @override
  String get reasonEvening => '저녁에 좋아요';

  @override
  String get reasonWeekend => '주말에 읽기 좋아요';

  @override
  String get seasonSpring => '봄';

  @override
  String get seasonSummer => '여름';

  @override
  String get seasonAutumn => '가을';

  @override
  String get seasonWinter => '겨울';

  @override
  String get settingsRegion => '국가/지역';

  @override
  String get regionAuto => '자동 (기기 설정)';

  @override
  String get regionAll => '모든 국가';

  @override
  String get regionNote => '특정 국가의 상식은 선택한 국가에서만 표시돼요.';

  @override
  String get settingsSeason => '계절 추천';

  @override
  String get seasonAuto => '자동';

  @override
  String get seasonNorth => '북반구';

  @override
  String get seasonSouth => '남반구';

  @override
  String get seasonOff => '끄기';

  @override
  String get seasonNote => '시간대로 추정해요 (위치 정보는 사용하지 않아요).';

  @override
  String get relatedSection => '관련 상식';

  @override
  String get whyButton => '왜?';

  @override
  String whyCheer(int count) {
    return '\'왜?\'를 $count번이나 물었어요! 대단해요!';
  }

  @override
  String get mythsTitle => '맞을까요, 틀릴까요?';

  @override
  String mythAnswerIs(String verdict) {
    return '정답: $verdict';
  }

  @override
  String get mythRead => '더 읽기';

  @override
  String mythProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String mythResult(int correct, int total) {
    return '$total문제 중 $correct문제 정답!';
  }

  @override
  String get mythAgain => '다시 하기';

  @override
  String get mythNone => '지금 풀 수 있는 문제가 없어요';

  @override
  String get mythNext => '다음';

  @override
  String get mythFinish => '결과 보기';

  @override
  String get todayTitle => '오늘은 무슨 날';

  @override
  String get todayNone => '오늘은 특별한 날이 아니에요';

  @override
  String get todayUpcoming => '다가오는 날';

  @override
  String todayBanner(String title) {
    return '오늘: $title';
  }

  @override
  String get todayCountry => '현지 행사';

  @override
  String get todayHome => '오늘은 무슨 날';

  @override
  String dateMonthDay(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get listenInEnglish => '영어로 듣기';

  @override
  String get listenInJapanese => '일본어로 듣기';

  @override
  String get vocabEnglishTitle => '영어 단어';

  @override
  String get vocabJapaneseTitle => '일본어 단어';

  @override
  String get vocabTapToHear => '단어를 누르면 발음을 들을 수 있어요';

  @override
  String get listenTitle => '듣기 모드';

  @override
  String get listenPlay => '재생';

  @override
  String get listenPause => '일시정지';

  @override
  String get listenNext => '다음';

  @override
  String get listenPrev => '이전';

  @override
  String get listenSpeedLabel => '속도';

  @override
  String get listenNormal => '보통';

  @override
  String get listenFast => '빠르게';

  @override
  String get listenFinished => '다 들었어요. 재생을 누르면 다시 들을 수 있어요';

  @override
  String get listenNote => '듣는 동안 앱을 열어 두세요 (출퇴근, 요리 중 등).';

  @override
  String get listenEmpty => '지금 들을 수 있는 상식이 없어요';

  @override
  String get listenOpen => '듣기 모드';

  @override
  String get projectsTitle => '과학 실험 아이디어';

  @override
  String projectMinutes(int minutes) {
    return '약 $minutes분';
  }

  @override
  String get projectNeedsAdult => '어른과 함께';

  @override
  String get projectDifficulty => '난이도';

  @override
  String get projectMaterials => '준비물';

  @override
  String get projectSteps => '순서';

  @override
  String get projectObserve => '관찰 포인트';

  @override
  String get projectSafety => '안전 수칙';

  @override
  String get projectFromFact => '실험으로 해 보기';

  @override
  String get projectsEmpty => '지금 보여 줄 실험이 없어요';

  @override
  String get projectsSummer => '여름방학에 좋아요';

  @override
  String get quickLinks => '더보기';

  @override
  String get projectsIntro => '상식 하나에서 집에서 할 수 있는 실험까지.';

  @override
  String get premiumActive => 'Premium을 이용 중이에요';

  @override
  String get premiumMonthly => '월간';

  @override
  String get premiumAnnual => '연간';

  @override
  String get premiumTrial => '무료 체험 가능';

  @override
  String get premiumBuy => '이 플랜으로 시작';

  @override
  String get premiumRestore => '구매 복원';

  @override
  String get premiumLegal =>
      '결제 금액은 스토어 계정으로 청구됩니다. 플랜은 자동으로 갱신되며 스토어 설정에서 언제든 해지할 수 있습니다. 무료 체험이 있는 플랜은 체험이 끝나면 자동으로 결제가 시작됩니다.';

  @override
  String get premiumPurchased => '구매해 주셔서 감사합니다!';

  @override
  String get premiumCancelled => '구매를 취소했어요';

  @override
  String get premiumFailed => '구매를 완료하지 못했어요. 잠시 후 다시 시도해 주세요.';

  @override
  String get premiumRestored => '구매를 복원했어요';

  @override
  String get premiumNothingToRestore => '복원할 구매 내역을 찾지 못했어요';

  @override
  String get privacyTitle => '개인정보 및 앱 정보';

  @override
  String get privacyDataHeading => '데이터는 이렇게 다뤄요';

  @override
  String get privacyPointLocal => '설정, 저장한 상식, 기록은 이 기기에만 저장돼요.';

  @override
  String get privacyPointBirthYear => '태어난 해는 연령 모드를 고르는 데만 쓰이며 저장되지 않아요.';

  @override
  String get privacyPointNoAds => '광고도, 이용 현황 분석도 없어요.';

  @override
  String get privacyPointChildren =>
      'Kids와 Junior 모드는 네트워크 연결도, 결제 SDK도 사용하지 않아요.';

  @override
  String get privacyPointTeenAdult =>
      'Teen과 Adult 모드는 앱 추천 표시(설정에서 끌 수 있어요)와 Premium 상태 확인을 위해 연결될 수 있어요. 결제 정보는 앱에 전달되지 않아요.';

  @override
  String privacyContact(String email) {
    return '문의: $email';
  }

  @override
  String get privacyLicenses => '오픈소스 라이선스';

  @override
  String privacyVersion(String version) {
    return '버전 $version';
  }

  @override
  String get privacyDeleteButton => '이 기기의 데이터 삭제';

  @override
  String get privacyDeleteTitle => '데이터를 삭제할까요?';

  @override
  String get privacyDeleteBody =>
      '모든 설정, 저장한 상식, 기록, 예약된 알림이 지워지고 앱이 처음 화면으로 돌아가요. 되돌릴 수 없어요. 구매한 Premium은 그대로 유지돼요 (스토어에서 복원할 수 있어요).';

  @override
  String get privacyDeleteConfirm => '삭제';

  @override
  String get privacyDeleteCancel => '취소';

  @override
  String get privacyDeleted => '데이터를 삭제했어요';

  @override
  String get shareImage => '이미지로 공유';

  @override
  String get sourcesSection => '출처';

  @override
  String get battleTitle => '퀴즈 대결';

  @override
  String get battlePlayers => '몇 명이서 할까요?';

  @override
  String get battleSolo => '혼자';

  @override
  String battlePlayerCount(int n) {
    return '$n명';
  }

  @override
  String battlePlayerDefault(int n) {
    return '플레이어 $n';
  }

  @override
  String get battleRounds => '몇 문제?';

  @override
  String battleRoundCount(int n) {
    return '$n문제';
  }

  @override
  String get battleHandHint => '기기를 돌려 가며 차례로 풀어요.';

  @override
  String get battleStart => '시작';

  @override
  String get battleNoQuestions => '풀 수 있는 퀴즈가 없어요.';

  @override
  String battleRoundOf(int n, int total) {
    return '$total문제 중 $n번째';
  }

  @override
  String battleTurnOf(String name) {
    return '$name의 차례';
  }

  @override
  String get battleSeeResult => '결과 보기';

  @override
  String get battleFinished => '모두 끝났어요!';

  @override
  String battleSoloScore(int score, int total) {
    return '$total문제 중 $score문제 정답!';
  }

  @override
  String get battleDraw => '무승부!';

  @override
  String battleWinner(String name) {
    return '$name 승리!';
  }

  @override
  String battleRank(int n) {
    return '$n위';
  }

  @override
  String get battleAgain => '다시 하기';

  @override
  String get battleChangeSettings => '설정 바꾸기';

  @override
  String get battleExit => '나가기';

  @override
  String get battleKind => '퀴즈 종류';

  @override
  String get battleKindAll => '전체';

  @override
  String get battleKindTrueFalse => 'O/X';

  @override
  String get battleKindChoice => '객관식';

  @override
  String get battleGenre => '장르';

  @override
  String get battleGenreAll => '전체';

  @override
  String get battleTimeLimit => '제한 시간';

  @override
  String get battleTimeOff => '없음';

  @override
  String battleSeconds(int n) {
    return '$n초';
  }

  @override
  String battleSecondsLeft(int n) {
    return '$n초 남음';
  }

  @override
  String get battleTimeHint => '빨리 답할수록 보너스 점수를 받아요 (동점일 때 순위를 가려요).';

  @override
  String battleCorrectIs(String answer) {
    return '정답: $answer';
  }

  @override
  String battlePoints(int n) {
    return '$n점';
  }

  @override
  String get reviewTitle => '복습';

  @override
  String get reviewNone => '오늘 복습할 것이 없어요. \'새로 알았어요\'를 누른 상식이 내일부터 나와요.';

  @override
  String get reviewDoneNote => '내일 또 복습해요.';

  @override
  String get reviewChip => '복습';

  @override
  String reviewChipCount(int n) {
    return '복습 $n';
  }

  @override
  String get dailyTitle => '오늘의 챌린지';

  @override
  String get dailyChip => '챌린지';

  @override
  String dailyStreak(int n) {
    return '챌린지 $n일 연속';
  }

  @override
  String get dailyComeBack => '내일 새로운 문제로 다시 만나요!';

  @override
  String get dailyShare => '결과 공유';

  @override
  String get badgesTitle => '배지';

  @override
  String get badgesChip => '배지';

  @override
  String badgesCount(int n, int total) {
    return '$total개 중 $n개 획득';
  }

  @override
  String badgeStreak(int n) {
    return '$n일 연속';
  }

  @override
  String badgeReadDays(int n) {
    return '$n일 읽음';
  }

  @override
  String badgeLearned(int n) {
    return '상식 $n개 알게 됨';
  }

  @override
  String badgeQuiz(int n) {
    return '퀴즈 $n문제 정답';
  }

  @override
  String badgeDaily(int n) {
    return '챌린지 $n회';
  }

  @override
  String get badgePerfect => '챌린지 전부 정답';

  @override
  String get reportTitle => '학습 리포트';

  @override
  String get reportNote => '이 리포트는 이 기기에 저장된 기록만으로 만들어지며 어디로도 전송되지 않아요.';

  @override
  String get reportLearned => '\'새로 알았어요\'를 누른 상식';

  @override
  String get reportKnew => '\'알고 있었어요\'를 누른 상식';

  @override
  String get reportQuiz => '퀴즈 정답';

  @override
  String get reportNoQuiz => '아직 없음';

  @override
  String get reportReviewPending => '복습 대기';

  @override
  String get reportFavorite => '좋아하는 장르';

  @override
  String get reportEmpty => '아직 기록이 없어요.';

  @override
  String get reportRecent => '최근에 알게 된 것';

  @override
  String get reportOpen => '학습 리포트 (부모님용)';

  @override
  String get mascotTitle => '단짝';

  @override
  String mascotNext(int n, String name) {
    return '$n점 더 모으면 \'$name\'이(가) 돼요';
  }

  @override
  String get mascotMax => '다 자랐어요!';

  @override
  String get mascotHint => '상식을 열면 +1, \'새로 알았어요\'를 누르면 +2. 단짝이 쑥쑥 자라요.';

  @override
  String mascotPoints(int n) {
    return '$n점';
  }

  @override
  String get mascotLocked => '???';

  @override
  String get mascotName_egg => '알';

  @override
  String get mascotSay_egg => '…재미있는 상식을 기다리고 있어.';

  @override
  String get mascotName_chick => '병아리';

  @override
  String get mascotSay_chick => '삐약! 상식은 재미있어!';

  @override
  String get mascotName_chicklet => '아기 올빼미';

  @override
  String get mascotSay_chicklet => '보송보송! 더 알려 줘.';

  @override
  String get mascotName_owl => '올빼미';

  @override
  String get mascotSay_owl => '부엉! 점점 똑똑해지고 있어.';

  @override
  String get mascotName_professor => '올빼미 박사';

  @override
  String get mascotSay_professor => '흠흠, 그렇군. 정말 박식하구나.';

  @override
  String get mascotName_king => '올빼미 왕';

  @override
  String get mascotSay_king => '부엉부엉! 상식의 왕이다!';

  @override
  String celebrateStage(String name) {
    return '단짝이 $name(으)로 자랐어요!';
  }

  @override
  String get celebrateBadge => '새 배지 획득!';

  @override
  String get flipHint => '눌러서 뒤집기';

  @override
  String get flipDetail => '자세히 보기';

  @override
  String get zukanTitle => '상식 도감';

  @override
  String get zukanChip => '도감';

  @override
  String zukanFound(int n, int total) {
    return '$total개 중 $n개 발견';
  }

  @override
  String get zukanAll => '전체';

  @override
  String get zukanHint => '본 상식이 도감에 하나씩 채워져요.';

  @override
  String get zukanLocked => '?';

  @override
  String get capsuleTitle => '상식 캡슐';

  @override
  String get capsuleChip => '캡슐';

  @override
  String get capsuleOpen => '열어 보자!';

  @override
  String get capsuleHint => '하루에 한 번, 신기한 상식이 튀어나와요.';

  @override
  String get capsuleDone => '내일 또 열어요!';

  @override
  String get capsuleNew => 'NEW!';

  @override
  String get capsuleToZukan => '도감 보기';

  @override
  String get capsuleEmpty => '나올 상식이 없어요.';

  @override
  String get capsuleRarity1 => '일반';

  @override
  String get capsuleRarity2 => '레어';

  @override
  String get capsuleRarity3 => '슈퍼 레어';

  @override
  String get swipeTitle => '스와이프: O일까 X일까?';

  @override
  String get swipeChip => '스와이프';

  @override
  String get swipeHint => '→ 맞아요     ← 틀려요';

  @override
  String swipeCombo(int n) {
    return '🔥 $n연속!';
  }

  @override
  String swipeBestCombo(int n) {
    return '최고 연속: $n';
  }

  @override
  String get tabHome => '홈';

  @override
  String get tabPlay => '놀기';

  @override
  String get tabCollect => '모으기';

  @override
  String get tabExplore => '찾기';

  @override
  String get tabSettings => '설정';

  @override
  String get hubPlayIntro => '퀴즈와 게임으로 상식을 즐겨 보세요.';

  @override
  String get hubCollectIntro => '상식을 많이 볼수록 단짝이 자라고 컬렉션이 채워져요.';

  @override
  String get hubExploreIntro => '상식을 검색하거나 더 깊이 알아보세요.';

  @override
  String get hubQuizSub => '1~4명 대결';

  @override
  String get hubSwipeSub => 'O/X 퀴즈';

  @override
  String get hubDailySub => '하루 3문제';

  @override
  String get hubReviewSub => '잊지 않도록';

  @override
  String get hubMythsSub => '흔한 오해';

  @override
  String get hubLibrarySub => '검색·장르';

  @override
  String get hubListenSub => '화면을 꺼도 들어요';

  @override
  String get languageZh => '简体中文';

  @override
  String get languageKo => '한국어';

  @override
  String get languageEs => 'Español';

  @override
  String get wordTitle => '낱말 설명';

  @override
  String get wordSimple => '쉽게 말하면';

  @override
  String get wordDetail => '자세히';

  @override
  String get wordFacts => '이 낱말이 나오는 상식';

  @override
  String get wordHint => '밑줄 친 낱말을 누르면 뜻을 알 수 있어요.';

  @override
  String get wordNotFound => '설명을 찾지 못했어요.';

  @override
  String get wordsTitle => '낱말 도감';

  @override
  String wordsFound(int n, int total) {
    return '낱말 $total개 중 $n개';
  }

  @override
  String get wordOfDay => '오늘의 낱말';

  @override
  String get wordQuizTitle => '낱말 퀴즈';

  @override
  String wordQuizQuestion(String term) {
    return '\'$term\'의 뜻은?';
  }

  @override
  String get wordsHint => '설명을 본 낱말이 여기에 쌓여요.';

  @override
  String get mapTitle => '연결 지도';

  @override
  String mapLinkCount(int n) {
    return '연결된 상식 $n개';
  }

  @override
  String get mapNoLinks => '아직 연결된 상식이 없어요';

  @override
  String get mapOpen => '연결 보기';

  @override
  String get voiceQuizTitle => '귀로 하는 퀴즈';

  @override
  String get voiceReplay => '다시 듣기';

  @override
  String get voiceQuizSub => '듣고 답하기';

  @override
  String get leagueTitle => '가족 리그';

  @override
  String get leagueNote => '이 기기에서 한 대결의 점수를 한 주 단위로 모아요. 어디로도 전송되지 않아요.';

  @override
  String get leagueThisWeek => '이번 주 순위';

  @override
  String leagueLastWinner(String name) {
    return '지난주 우승: $name';
  }

  @override
  String get leagueEmpty => '아직 기록이 없어요. 2명 이상이 대결하면 여기에 나타나요.';

  @override
  String leagueGames(int n, int wins) {
    return '$n경기 $wins승';
  }

  @override
  String get leaguePlay => '대결하러 가기';

  @override
  String get leagueClear => '이번 주 기록 지우기';

  @override
  String get leagueClearTitle => '이번 주 기록을 지울까요?';

  @override
  String get leagueClearBody => '이번 주 점수가 지워져요. 지난주 우승자는 남아요.';

  @override
  String get leagueRecord => '가족 리그에 기록하기';

  @override
  String get leagueSub => '일주일 승부';

  @override
  String get recapTitle => '주간 돌아보기';

  @override
  String get recapNote => '최근 7일을 그 전 7일과 비교해요.';

  @override
  String get recapSeen => '본 상식';

  @override
  String get recapLearned => '새로 알게 된 것';

  @override
  String get recapQuiz => '퀴즈 정답';

  @override
  String get recapActiveDays => '활동한 날';

  @override
  String get recapMsgNone => '이번 주는 쉬었네요. 하나만 읽고 다시 시작해 봐요!';

  @override
  String get recapMsgSome => '좋은 페이스예요! 조금씩 쌓여 가요.';

  @override
  String get recapMsgGreat => '대단해요! 거의 매일 했어요!';

  @override
  String get recapChip => '돌아보기';

  @override
  String get recapBanner => '이번 주 돌아보기가 준비됐어요';

  @override
  String get stampsTitle => '계절 스탬프북';

  @override
  String get stampsChip => '스탬프북';

  @override
  String stampsHint(int n) {
    return '지금 계절에 어울리는 상식을 읽으면 스탬프가 하나. $n개를 모으면 단짝이 그 계절의 옷을 입어요.';
  }

  @override
  String get stampsSpring => '봄';

  @override
  String get stampsSummer => '여름';

  @override
  String get stampsAutumn => '가을';

  @override
  String get stampsWinter => '겨울';

  @override
  String get stampsNow => '지금';

  @override
  String get stampsOutfit => '옷 획득!';

  @override
  String get celebrateOutfit => '계절 옷을 얻었어요!';
}
