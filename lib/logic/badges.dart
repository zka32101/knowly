import 'streak.dart';

enum BadgeMetric { streak, readDays, learned, quizCorrect, dailyDays, dailyPerfect }

class BadgeDef {
  const BadgeDef(this.emoji, this.metric, this.target);
  final String emoji;
  final BadgeMetric metric;
  final int target;

  String get id => '${metric.name}_$target';
}

/// 集めるバッジ。条件を満たすと自動で手に入る（端末内の記録から計算するので、保存しない）。
const badgeDefs = [
  BadgeDef('🌱', BadgeMetric.streak, 3),
  BadgeDef('🔥', BadgeMetric.streak, 7),
  BadgeDef('🏆', BadgeMetric.streak, 30),
  BadgeDef('📖', BadgeMetric.readDays, 10),
  BadgeDef('📚', BadgeMetric.readDays, 50),
  BadgeDef('💡', BadgeMetric.learned, 5),
  BadgeDef('🧠', BadgeMetric.learned, 20),
  BadgeDef('⭐', BadgeMetric.quizCorrect, 10),
  BadgeDef('🌟', BadgeMetric.quizCorrect, 50),
  BadgeDef('👑', BadgeMetric.quizCorrect, 100),
  BadgeDef('🎯', BadgeMetric.dailyDays, 1),
  BadgeDef('📅', BadgeMetric.dailyDays, 7),
  BadgeDef('💯', BadgeMetric.dailyPerfect, 1),
];

class BadgeStats {
  const BadgeStats({
    this.streak = 0,
    this.readDays = 0,
    this.learned = 0,
    this.quizCorrect = 0,
    this.dailyDays = 0,
    this.dailyPerfect = 0,
  });

  /// これまでで一番長く続いた日数。
  final int streak;
  final int readDays;
  final int learned;
  final int quizCorrect;
  final int dailyDays;
  final int dailyPerfect;

  int valueOf(BadgeMetric m) => switch (m) {
        BadgeMetric.streak => streak,
        BadgeMetric.readDays => readDays,
        BadgeMetric.learned => learned,
        BadgeMetric.quizCorrect => quizCorrect,
        BadgeMetric.dailyDays => dailyDays,
        BadgeMetric.dailyPerfect => dailyPerfect,
      };
}

bool isEarned(BadgeDef b, BadgeStats s) => s.valueOf(b.metric) >= b.target;

/// 連続して読んだ日数の最長（お休み券は使わない単純な数え方）。
int bestStreak(Iterable<String> readDays) {
  final days = readDays.toSet().toList()..sort();
  var best = 0;
  var run = 0;
  DateTime? prev;
  for (final k in days) {
    final p = k.split('-').map(int.parse).toList();
    final d = DateTime.utc(p[0], p[1], p[2]);
    run = (prev != null && d.difference(prev).inDays == 1) ? run + 1 : 1;
    if (run > best) best = run;
    prev = d;
  }
  return best;
}

/// 今日のチャレンジで、昨日まで何日続けて遊んだか（今日遊んでいれば今日を含む）。
int dailyStreak(Iterable<String> playedDays, DateTime today) =>
    computeStreak(playedDays, today).current;
