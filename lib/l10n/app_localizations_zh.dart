// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Knowly';

  @override
  String get languageTitle => '语言';

  @override
  String get languageSystem => '跟随设备';

  @override
  String get languageJa => '日本語';

  @override
  String get languageEn => 'English';

  @override
  String get continueButton => '下一步';

  @override
  String get birthYearTitle => '请选择出生年份';

  @override
  String get birthYearNote => '仅用于匹配适合你年龄的内容。出生年份不会被保存，也不会发送到任何地方。';

  @override
  String get parentNoteTitle => '致家长';

  @override
  String get parentNoteBody => '请与孩子一起使用本应用。应用不会收集儿童的个人信息，也不会显示广告。';

  @override
  String get modeKids => 'Kids（学龄前）';

  @override
  String get modeJunior => 'Junior（小学生）';

  @override
  String get modeTeen => 'Teen（青少年）';

  @override
  String get modeAdult => 'Adult（成人）';

  @override
  String get interestsTitle => '选择你喜欢的内容';

  @override
  String get interestsAll => '全部';

  @override
  String get catAnimals => '动物';

  @override
  String get catSpace => '宇宙';

  @override
  String get catBody => '身体';

  @override
  String get catNature => '自然';

  @override
  String get catScience => '科学';

  @override
  String get catGeography => '地理';

  @override
  String get sceneFriends => '和朋友';

  @override
  String get sceneKids => '和孩子';

  @override
  String get sceneWork => '工作中';

  @override
  String get sceneFamily => '和家人';

  @override
  String get sceneLearning => '学习';

  @override
  String get filterReset => '重置';

  @override
  String get today => '今日冷知识';

  @override
  String get past => '往期冷知识';

  @override
  String get kidsNext => '下一个';

  @override
  String get kidsListen => '听一听';

  @override
  String get emptyFeed => '现在没有可显示的冷知识';

  @override
  String get lockedFeedNote => '更早的冷知识需要 Premium';

  @override
  String get savedTitle => '已收藏';

  @override
  String get savedEmpty => '还没有收藏';

  @override
  String savedLimit(int count) {
    return '免费版最多可收藏 $count 条';
  }

  @override
  String get save => '收藏';

  @override
  String get unsave => '已收藏';

  @override
  String get copy => '复制';

  @override
  String get copied => '已复制';

  @override
  String get ratingHeh => '哇！';

  @override
  String get ratingUseful => '有用！';

  @override
  String get ratingWow => '太神奇了';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsUiLanguage => '应用语言';

  @override
  String get settingsContentLanguage => '冷知识语言';

  @override
  String get settingsMode => '年龄模式';

  @override
  String get settingsModeNote => '更改模式需要通过家长验证';

  @override
  String get settingsPremium => 'Premium';

  @override
  String get settingsOtherApps => '看看我们的其他应用';

  @override
  String get settingsPrivacy => '本应用不会收集儿童的个人信息，也不会显示广告。';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumBenefit1 => '可阅读最近 30 天的往期冷知识';

  @override
  String get premiumBenefit2 => '无限收藏';

  @override
  String get premiumBenefit3 => '离线保存与深度解读（即将推出）';

  @override
  String get premiumKidsFree => 'Kids 和 Junior 的冷知识永远免费。';

  @override
  String get premiumUnavailable => '购买功能即将推出';

  @override
  String get gateTitle => '致家长';

  @override
  String get gateDescription => '此步骤仅限成人。\n请输入下面算式的答案。';

  @override
  String get gateHint => '请输入答案';

  @override
  String get gateWrong => '答案不对';

  @override
  String get gateOk => '下一步';

  @override
  String get gateCancel => '取消';

  @override
  String get close => '关闭';

  @override
  String get catBugs => '昆虫';

  @override
  String get catVehicles => '交通工具';

  @override
  String get catFood => '食物';

  @override
  String get viewAs => '阅读难度';

  @override
  String get viewOwn => '标准';

  @override
  String get viewJunior => '小学生版';

  @override
  String get viewKids => '幼儿版';

  @override
  String get explainToKids => '向孩子解释';

  @override
  String get bilingualOn => '显示双语';

  @override
  String get bilingualOff => '只显示一种语言';

  @override
  String get knewIt => '我知道';

  @override
  String get learnedIt => '学到了！';

  @override
  String streakDays(int count) {
    return '连续 $count 天';
  }

  @override
  String get streakFreeze => '休息券已备好';

  @override
  String get streakStart => '阅读今日冷知识，开始连续记录';

  @override
  String get statsTitle => '你的冷知识';

  @override
  String statsKnowRate(int percent, int knew, int total) {
    return '你已经知道的冷知识：$percent%（$knew/$total）';
  }

  @override
  String get statsEmpty => '点击“我知道”或“学到了”，这里会显示统计';

  @override
  String get quizButton => '测验';

  @override
  String get quizTitle => '对还是错？';

  @override
  String get quizTrue => '对';

  @override
  String get quizFalse => '错';

  @override
  String get quizCorrect => '答对了！';

  @override
  String get quizWrong => '差一点！';

  @override
  String get quizNext => '下一题';

  @override
  String get notifyTitle => '每日冷知识提醒';

  @override
  String get notifySubtitle => '在设定的时间收到今日冷知识。完全在你的设备上运行。';

  @override
  String get notifyJuniorNote => '请由家长来设置。仅在设备上运行，不会发送任何数据。';

  @override
  String get notifyTime => '提醒时间';

  @override
  String get notifyDenied => '未允许通知。请在设备设置中开启。';

  @override
  String get birthYearHint => '出生年份';

  @override
  String get filterButton => '筛选';

  @override
  String filterButtonActive(int count) {
    return '筛选（$count）';
  }

  @override
  String get libraryTitle => '资料库';

  @override
  String get searchHint => '搜索冷知识（日语/英语）';

  @override
  String get searchClear => '清除';

  @override
  String resultsCount(int count) {
    return '$count 条冷知识';
  }

  @override
  String get noResults => '没有找到。试试换个词或筛选条件';

  @override
  String get filterStatus => '状态';

  @override
  String get statusSaved => '已收藏';

  @override
  String get statusKnew => '我知道';

  @override
  String get statusLearned => '新知识';

  @override
  String get statusUnrated => '未评价';

  @override
  String get filterCategoryHeader => '类别';

  @override
  String get filterSceneHeader => '场景';

  @override
  String get libraryLocked => '需要 Premium';

  @override
  String get libraryOpen => '资料库';

  @override
  String get interestsSection => '你的兴趣';

  @override
  String get interestsEdit => '编辑';

  @override
  String get interestsEmptyTitle => '添加兴趣，这里就会显示为你推荐的内容';

  @override
  String get interestsRegister => '添加兴趣';

  @override
  String get interestsNoMatch => '目前没有符合你兴趣的冷知识';

  @override
  String get interestsScreenTitle => '兴趣';

  @override
  String get interestsCategories => '类别';

  @override
  String get interestsScenes => '场景';

  @override
  String get interestsKeywords => '关键词';

  @override
  String get interestsKeywordHint => '例如：宇宙、海獭、金钱';

  @override
  String get interestsAdd => '添加';

  @override
  String interestsMax(int count) {
    return '最多 $count 个关键词';
  }

  @override
  String get interestsNote => '你的兴趣只保存在这台设备上，不会发送到任何地方。';

  @override
  String get settingsInterests => '兴趣';

  @override
  String get timingSection => '此刻推荐';

  @override
  String get reasonDate => '纪念日';

  @override
  String reasonSeason(String season) {
    return '很适合$season';
  }

  @override
  String get reasonNight => '适合今晚';

  @override
  String get reasonMorning => '适合早晨';

  @override
  String get reasonEvening => '适合傍晚';

  @override
  String get reasonWeekend => '周末适读';

  @override
  String get seasonSpring => '春天';

  @override
  String get seasonSummer => '夏天';

  @override
  String get seasonAutumn => '秋天';

  @override
  String get seasonWinter => '冬天';

  @override
  String get settingsRegion => '国家/地区';

  @override
  String get regionAuto => '自动（跟随设备）';

  @override
  String get regionAll => '所有国家';

  @override
  String get regionNote => '特定国家的冷知识只会在所选国家显示。';

  @override
  String get settingsSeason => '季节推荐';

  @override
  String get seasonAuto => '自动';

  @override
  String get seasonNorth => '北半球';

  @override
  String get seasonSouth => '南半球';

  @override
  String get seasonOff => '关闭';

  @override
  String get seasonNote => '根据你的时区推测（不使用定位）。';

  @override
  String get relatedSection => '相关冷知识';

  @override
  String get whyButton => '为什么？';

  @override
  String whyCheer(int count) {
    return '你已经追问了 $count 次“为什么”！太棒了！';
  }

  @override
  String get mythsTitle => '对还是错？';

  @override
  String mythAnswerIs(String verdict) {
    return '答案：$verdict';
  }

  @override
  String get mythRead => '了解更多';

  @override
  String mythProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String mythResult(int correct, int total) {
    return '答对 $correct / $total 题！';
  }

  @override
  String get mythAgain => '再玩一次';

  @override
  String get mythNone => '现在没有可玩的题目';

  @override
  String get mythNext => '下一题';

  @override
  String get mythFinish => '查看结果';

  @override
  String get todayTitle => '历史上的今天';

  @override
  String get todayNone => '今天没有特别的日子';

  @override
  String get todayUpcoming => '即将到来';

  @override
  String todayBanner(String title) {
    return '今天：$title';
  }

  @override
  String get todayCountry => '当地节日';

  @override
  String get todayHome => '历史上的今天';

  @override
  String dateMonthDay(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get listenInEnglish => '用英语听';

  @override
  String get listenInJapanese => '用日语听';

  @override
  String get vocabEnglishTitle => '英语单词';

  @override
  String get vocabJapaneseTitle => '日语单词';

  @override
  String get vocabTapToHear => '点击单词即可听发音';

  @override
  String get listenTitle => '收听模式';

  @override
  String get listenPlay => '播放';

  @override
  String get listenPause => '暂停';

  @override
  String get listenNext => '下一条';

  @override
  String get listenPrev => '上一条';

  @override
  String get listenSpeedLabel => '速度';

  @override
  String get listenSlow => '慢';

  @override
  String get listenNormal => '正常';

  @override
  String get listenFast => '快';

  @override
  String get listenFinished => '已读完。点击播放可重新收听';

  @override
  String get listenNote => '收听时请保持应用打开（通勤、做饭时等）。';

  @override
  String get listenEmpty => '现在没有可收听的冷知识';

  @override
  String get listenOpen => '收听模式';

  @override
  String get projectsTitle => '科学小实验创意';

  @override
  String projectMinutes(int minutes) {
    return '约 $minutes 分钟';
  }

  @override
  String get projectNeedsAdult => '需要大人陪同';

  @override
  String get projectDifficulty => '难度';

  @override
  String get projectMaterials => '所需材料';

  @override
  String get projectSteps => '步骤';

  @override
  String get projectObserve => '观察要点';

  @override
  String get projectSafety => '安全提示';

  @override
  String get projectFromFact => '把它做成小实验';

  @override
  String get projectsEmpty => '现在没有可显示的实验';

  @override
  String get projectsSummer => '适合暑假';

  @override
  String get quickLinks => '更多';

  @override
  String get projectsIntro => '从一条冷知识，到在家就能做的实验。';

  @override
  String get premiumActive => '你已开通 Premium';

  @override
  String get premiumMonthly => '月付';

  @override
  String get premiumAnnual => '年付';

  @override
  String get premiumTrial => '可免费试用';

  @override
  String get premiumBuy => '开始此方案';

  @override
  String get premiumRestore => '恢复购买';

  @override
  String get premiumLegal =>
      '费用将从你的商店账户扣除。订阅会自动续订，你可以随时在商店设置中取消。带免费试用的方案会在试用结束后自动开始扣费。';

  @override
  String get premiumPurchased => '感谢你的购买！';

  @override
  String get premiumCancelled => '已取消购买';

  @override
  String get premiumFailed => '购买未能完成，请稍后再试。';

  @override
  String get premiumRestored => '已恢复购买';

  @override
  String get premiumNothingToRestore => '没有找到可恢复的购买记录';

  @override
  String get privacyTitle => '隐私与关于';

  @override
  String get privacyDataHeading => '我们如何处理你的数据';

  @override
  String get privacyPointLocal => '你的设置、收藏的冷知识和记录只保存在这台设备上。';

  @override
  String get privacyPointBirthYear => '出生年份仅用于选择年龄模式，不会被保存。';

  @override
  String get privacyPointNoAds => '没有广告，也没有使用情况分析。';

  @override
  String get privacyPointChildren => 'Kids 和 Junior 模式不使用网络连接，也不使用购买 SDK。';

  @override
  String get privacyPointTeenAdult =>
      'Teen 和 Adult 模式可能会联网，用于显示应用推荐（可在设置中关闭）和确认 Premium 状态。支付信息不会传到本应用。';

  @override
  String privacyContact(String email) {
    return '联系方式：$email';
  }

  @override
  String get privacyLicenses => '开源许可';

  @override
  String privacyVersion(String version) {
    return '版本 $version';
  }

  @override
  String get privacyDeleteButton => '删除此设备上的数据';

  @override
  String get privacyDeleteTitle => '要删除你的数据吗？';

  @override
  String get privacyDeleteBody =>
      '所有设置、收藏的冷知识、记录和已安排的通知都会被清除，应用将回到初始画面。此操作无法撤销。已购买的 Premium 会保留（可在商店中恢复）。';

  @override
  String get privacyDeleteConfirm => '删除';

  @override
  String get privacyDeleteCancel => '取消';

  @override
  String get privacyDeleted => '数据已删除';

  @override
  String get shareImage => '以图片分享';

  @override
  String get sourcesSection => '来源';

  @override
  String get battleTitle => '测验对战';

  @override
  String get battlePlayers => '几个人玩？';

  @override
  String get battleSolo => '单人';

  @override
  String battlePlayerCount(int n) {
    return '$n 人';
  }

  @override
  String battlePlayerDefault(int n) {
    return '玩家 $n';
  }

  @override
  String get battleRounds => '几道题？';

  @override
  String battleRoundCount(int n) {
    return '$n 题';
  }

  @override
  String get battleHandHint => '把设备轮流传下去，轮流答题。';

  @override
  String get battleStart => '开始';

  @override
  String get battleNoQuestions => '没有可用的测验题目。';

  @override
  String battleRoundOf(int n, int total) {
    return '第 $n / $total 题';
  }

  @override
  String battleTurnOf(String name) {
    return '轮到$name';
  }

  @override
  String get battleSeeResult => '查看结果';

  @override
  String get battleFinished => '全部完成！';

  @override
  String battleSoloScore(int score, int total) {
    return '答对 $score / $total 题！';
  }

  @override
  String get battleDraw => '平局！';

  @override
  String battleWinner(String name) {
    return '$name 获胜！';
  }

  @override
  String battleRank(int n) {
    return '第 $n 名';
  }

  @override
  String get battleAgain => '再玩一次';

  @override
  String get battleChangeSettings => '更改设置';

  @override
  String get battleExit => '退出';

  @override
  String get battleKind => '题型';

  @override
  String get battleKindAll => '全部';

  @override
  String get battleKindTrueFalse => '判断题';

  @override
  String get battleKindChoice => '选择题';

  @override
  String get battleGenre => '类别';

  @override
  String get battleGenreAll => '全部';

  @override
  String get battleTimeLimit => '时间限制';

  @override
  String get battleTimeOff => '无';

  @override
  String battleSeconds(int n) {
    return '$n 秒';
  }

  @override
  String battleSecondsLeft(int n) {
    return '还剩 $n 秒';
  }

  @override
  String get battleTimeHint => '答得越快，奖励分越多（用于决定同分的名次）。';

  @override
  String battleCorrectIs(String answer) {
    return '答案：$answer';
  }

  @override
  String battlePoints(int n) {
    return '$n 分';
  }

  @override
  String get reviewTitle => '复习';

  @override
  String get reviewNone => '今天没有需要复习的内容。标记为“学到了”的冷知识会从明天开始出现。';

  @override
  String get reviewDoneNote => '明天再来复习吧。';

  @override
  String get reviewChip => '复习';

  @override
  String reviewChipCount(int n) {
    return '复习 $n';
  }

  @override
  String get dailyTitle => '每日挑战';

  @override
  String get dailyChip => '挑战';

  @override
  String dailyStreak(int n) {
    return '已连续挑战 $n 天';
  }

  @override
  String get dailyComeBack => '明天再来挑战新的一题吧！';

  @override
  String get dailyShare => '分享结果';

  @override
  String get badgesTitle => '徽章';

  @override
  String get badgesChip => '徽章';

  @override
  String badgesCount(int n, int total) {
    return '已获得 $n / $total';
  }

  @override
  String badgeStreak(int n) {
    return '连续 $n 天';
  }

  @override
  String badgeReadDays(int n) {
    return '阅读 $n 天';
  }

  @override
  String badgeLearned(int n) {
    return '学到 $n 条冷知识';
  }

  @override
  String badgeQuiz(int n) {
    return '答对 $n 道测验题';
  }

  @override
  String badgeDaily(int n) {
    return '完成 $n 次每日挑战';
  }

  @override
  String get badgePerfect => '每日挑战全对';

  @override
  String get reportTitle => '学习报告';

  @override
  String get reportNote => '此报告仅根据保存在这台设备上的记录生成，不会发送到任何地方。';

  @override
  String get reportLearned => '标记为“学到了”的冷知识';

  @override
  String get reportKnew => '标记为“我知道”的冷知识';

  @override
  String get reportQuiz => '答对的测验题';

  @override
  String get reportNoQuiz => '还没有';

  @override
  String get reportReviewPending => '等待复习';

  @override
  String get reportFavorite => '喜欢的类别';

  @override
  String get reportEmpty => '还没有记录。';

  @override
  String get reportRecent => '最近学到的';

  @override
  String get reportOpen => '学习报告（供家长查看）';

  @override
  String get mascotTitle => '小伙伴';

  @override
  String mascotNext(int n, String name) {
    return '再 $n 点就会变成“$name”';
  }

  @override
  String get mascotMax => '已经完全长大了！';

  @override
  String get mascotHint => '打开一条冷知识 +1，标记“学到了” +2。你的小伙伴会不断成长。';

  @override
  String mascotPoints(int n) {
    return '$n 点';
  }

  @override
  String get mascotLocked => '？？？';

  @override
  String get mascotName_egg => '蛋';

  @override
  String get mascotSay_egg => '……在等一条有趣的冷知识。';

  @override
  String get mascotName_chick => '小鸡';

  @override
  String get mascotSay_chick => '啾！冷知识真有趣！';

  @override
  String get mascotName_chicklet => '小猫头鹰';

  @override
  String get mascotSay_chicklet => '毛茸茸的！再多告诉我一些吧。';

  @override
  String get mascotName_owl => '猫头鹰';

  @override
  String get mascotSay_owl => '呼！我越来越聪明了。';

  @override
  String get mascotName_professor => '猫头鹰博士';

  @override
  String get mascotSay_professor => '嗯嗯，原来如此。你真是个学者。';

  @override
  String get mascotName_king => '猫头鹰王';

  @override
  String get mascotSay_king => '呼呼！冷知识之王！';

  @override
  String celebrateStage(String name) {
    return '你的小伙伴变成了$name！';
  }

  @override
  String get celebrateBadge => '获得新徽章！';

  @override
  String get flipHint => '点击翻面';

  @override
  String get flipDetail => '查看详情';

  @override
  String get zukanTitle => '冷知识图鉴';

  @override
  String get zukanChip => '图鉴';

  @override
  String zukanFound(int n, int total) {
    return '已发现 $n / $total';
  }

  @override
  String get zukanAll => '全部';

  @override
  String get zukanHint => '你看过的每条冷知识都会填进图鉴。';

  @override
  String get zukanLocked => '？';

  @override
  String get capsuleTitle => '冷知识扭蛋';

  @override
  String get capsuleChip => '扭蛋';

  @override
  String get capsuleOpen => '打开它！';

  @override
  String get capsuleHint => '每天会蹦出一条神秘冷知识。';

  @override
  String get capsuleDone => '明天再来吧！';

  @override
  String get capsuleNew => '新！';

  @override
  String get capsuleToZukan => '查看图鉴';

  @override
  String get capsuleEmpty => '没有可用的冷知识。';

  @override
  String get capsuleRarity1 => '普通';

  @override
  String get capsuleRarity2 => '稀有';

  @override
  String get capsuleRarity3 => '超稀有';

  @override
  String get swipeTitle => '滑动：对还是错？';

  @override
  String get swipeChip => '滑动';

  @override
  String get swipeHint => '→ 对     ← 错';

  @override
  String swipeCombo(int n) {
    return '🔥 连续 $n 题！';
  }

  @override
  String swipeBestCombo(int n) {
    return '最高连续：$n';
  }

  @override
  String get tabHome => '首页';

  @override
  String get tabPlay => '玩';

  @override
  String get tabCollect => '收集';

  @override
  String get tabExplore => '探索';

  @override
  String get tabSettings => '设置';

  @override
  String get hubPlayIntro => '通过测验和游戏享受冷知识。';

  @override
  String get hubCollectIntro => '看的冷知识越多，小伙伴就长得越大，收藏也越丰富。';

  @override
  String get hubExploreIntro => '搜索冷知识，或深入了解。';

  @override
  String get hubQuizSub => '1–4 人对战';

  @override
  String get hubSwipeSub => '对还是错';

  @override
  String get hubDailySub => '每天 3 题';

  @override
  String get hubReviewSub => '别忘了';

  @override
  String get hubMythsSub => '常见误解';

  @override
  String get hubLibrarySub => '搜索与类别';

  @override
  String get hubListenSub => '关闭屏幕也能听';

  @override
  String get languageZh => '简体中文';

  @override
  String get languageKo => '한국어';

  @override
  String get languageEs => 'Español';
}
