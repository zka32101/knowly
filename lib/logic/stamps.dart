import 'timing.dart';

/// 1つの季節のスタンプ帳が完成するのに必要なスタンプの数。
const stampGoal = 3;

/// 季節ごとの、相棒の飾り（仮の絵文字）。
const seasonAccessory = {
  Season.spring: '🌸',
  Season.summer: '🌻',
  Season.autumn: '🍂',
  Season.winter: '🧣',
};

const seasonEmoji = {
  Season.spring: '🌸',
  Season.summer: '🌻',
  Season.autumn: '🍁',
  Season.winter: '⛄',
};

/// スタンプ帳の年。12月〜2月にまたがる季節（北半球の冬、南半球の夏）は、1〜2月を前の年として数える。
int stampYear(DateTime d, Season season, Hemisphere hemisphere) {
  final spansNewYear = (season == Season.winter && hemisphere == Hemisphere.north) ||
      (season == Season.summer && hemisphere == Hemisphere.south);
  return (spansNewYear && d.month <= 2) ? d.year - 1 : d.year;
}

/// スタンプの印。「年-季節:雑学の id」。
String stampKey(int year, Season season, String factId) => '$year-${season.name}:$factId';

/// [year] の [season] のスタンプ（雑学の id のリスト）。
List<String> stampsFor(Set<String> stamps, int year, Season season) {
  final prefix = '$year-${season.name}:';
  return [
    for (final s in stamps)
      if (s.startsWith(prefix)) s.substring(prefix.length),
  ]..sort();
}

bool isBookComplete(Set<String> stamps, int year, Season season) =>
    stampsFor(stamps, year, season).length >= stampGoal;

/// 今の季節の飾りを、相棒が着ているか（その季節の今年のスタンプ帳が完成していれば）。
String? currentAccessory(Set<String> stamps, DateTime now, Hemisphere? hemisphere) {
  final h = hemisphere ?? Hemisphere.north;
  final season = seasonFor(now, h);
  return isBookComplete(stamps, stampYear(now, season, h), season)
      ? seasonAccessory[season]
      : null;
}

/// 完成したスタンプ帳（"年-季節"）。
Set<String> completedBooks(Set<String> stamps) {
  final counts = <String, int>{};
  for (final s in stamps) {
    final i = s.indexOf(':');
    if (i < 0) continue;
    counts[s.substring(0, i)] = (counts[s.substring(0, i)] ?? 0) + 1;
  }
  return {for (final e in counts.entries) if (e.value >= stampGoal) e.key};
}
