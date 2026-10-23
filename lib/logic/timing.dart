import '../models/trivia.dart';
import 'daily_pick.dart';

enum Season { spring, summer, autumn, winter }

enum Hemisphere { north, south }

enum TimeBand { morning, day, evening, night }

/// おすすめの理由。画面に「夏にぴったり」「夜にぴったり」のように出す。
enum TimingReason { date, season, night, morning, evening, weekend }

/// 端末のタイムゾーン名から、北半球・南半球を推定する（位置情報は使わない）。
/// 南半球の主なタイムゾーンだけを判定し、それ以外は北半球とする。設定で選び直せる。
Hemisphere hemisphereFromTimezone(String? id) {
  if (id == null) return Hemisphere.north;
  const prefixes = [
    'Australia/', 'Antarctica/', 'Pacific/Auckland', 'Pacific/Chatham', 'Pacific/Fiji',
    'Pacific/Tongatapu', 'Pacific/Apia', 'America/Sao_Paulo', 'America/Argentina/',
    'America/Buenos_Aires', 'America/Santiago', 'America/Montevideo', 'America/Asuncion',
    'America/La_Paz', 'America/Lima', 'Africa/Johannesburg', 'Africa/Maputo',
    'Africa/Harare', 'Africa/Windhoek', 'Africa/Lusaka', 'Africa/Gaborone',
    'Africa/Maseru', 'Africa/Mbabane', 'Africa/Luanda', 'Indian/Antananarivo',
    'Indian/Mauritius', 'Indian/Reunion',
  ];
  return prefixes.any(id.startsWith) ? Hemisphere.south : Hemisphere.north;
}

/// 季節。気象の区分（3〜5月が春）。南半球は半年ずらす。
Season seasonFor(DateTime d, Hemisphere hemisphere) {
  final shifted = hemisphere == Hemisphere.south ? (d.month + 5) % 12 + 1 : d.month;
  return switch (shifted) {
    3 || 4 || 5 => Season.spring,
    6 || 7 || 8 => Season.summer,
    9 || 10 || 11 => Season.autumn,
    _ => Season.winter,
  };
}

TimeBand timeBandFor(int hour) {
  if (hour >= 5 && hour < 11) return TimeBand.morning;
  if (hour >= 11 && hour < 17) return TimeBand.day;
  if (hour >= 17 && hour < 21) return TimeBand.evening;
  return TimeBand.night;
}

bool isWeekend(DateTime d) => d.weekday >= DateTime.saturday;

/// 記念日（MM-DD）と [day] の日数の差（記念日から見て何日後か。前の日はマイナス）。年をまたいでも正しく測る。
/// 当てはまる記念日がなければ null。差の絶対値が [window] 以内のものだけを対象にする。
int? dateOffset(List<String> dates, DateTime day, {int window = 1}) {
  int? best;
  for (final md in dates) {
    final parts = md.split('-');
    if (parts.length != 2) continue;
    final m = int.tryParse(parts[0]);
    final dd = int.tryParse(parts[1]);
    if (m == null || dd == null) continue;
    for (final year in [day.year - 1, day.year, day.year + 1]) {
      final anniversary = DateTime.utc(year, m, dd);
      final offset = DateTime.utc(day.year, day.month, day.day).difference(anniversary).inDays;
      if (offset.abs() <= window && (best == null || offset.abs() < best.abs())) {
        best = offset;
      }
    }
  }
  return best;
}

class TimingContext {
  const TimingContext({required this.now, required this.season, this.weekendOn = true});

  final DateTime now;

  /// null のとき季節は使わない（設定でオフ）。
  final Season? season;
  final bool weekendOn;
}

class TimingMatch {
  const TimingMatch(this.score, this.reason);
  final int score;
  final TimingReason reason;
}

/// 「いま」に合う度合い。合わなければ null。複数合うときは点数の高い理由を使う。
/// 点数: 記念日 5 / 季節 3 / 時間帯 2 / 週末 1（週末は「家族と」「こどもと」のシーンに）。
TimingMatch? timingMatch(Trivia t, TimingContext ctx) {
  if (dateOffset(t.dates, ctx.now) != null) {
    return const TimingMatch(5, TimingReason.date);
  }
  if (ctx.season != null && t.seasons.contains(ctx.season!.name)) {
    return const TimingMatch(3, TimingReason.season);
  }
  final band = timeBandFor(ctx.now.hour);
  if (t.timeOfDay.contains(band.name)) {
    return TimingMatch(2, switch (band) {
      TimeBand.night => TimingReason.night,
      TimeBand.morning => TimingReason.morning,
      _ => TimingReason.evening,
    });
  }
  if (ctx.weekendOn &&
      isWeekend(ctx.now) &&
      (t.scenes.contains('family') || t.scenes.contains('kids'))) {
    return const TimingMatch(1, TimingReason.weekend);
  }
  return null;
}

class TimingPick {
  const TimingPick(this.fact, this.reason);
  final Trivia fact;
  final TimingReason reason;
}

/// 「いまのおすすめ」。合う度合いの高い順に、同点は日替わりで入れ替えて、[count] 件。
List<TimingPick> pickTiming({
  required List<Trivia> pool,
  required TimingContext ctx,
  required Set<String> exclude,
  required int count,
}) {
  final scored = <(Trivia, TimingMatch)>[];
  for (final t in pool) {
    if (exclude.contains(t.id)) continue;
    final m = timingMatch(t, ctx);
    if (m != null) scored.add((t, m));
  }
  final seed = fnv1a('timing-${dayNumber(ctx.now)}');
  scored.sort((a, b) {
    final c = b.$2.score.compareTo(a.$2.score);
    if (c != 0) return c;
    final k = mix32(fnv1a(a.$1.id) ^ seed).compareTo(mix32(fnv1a(b.$1.id) ^ seed));
    return k != 0 ? k : a.$1.id.compareTo(b.$1.id);
  });
  return [for (final e in scored.take(count)) TimingPick(e.$1, e.$2.reason)];
}

/// 「今日の雑学」を選ぶ。記念日の当日はその雑学にする。そうでなければ、季節外れのものを避けて選ぶ
/// （季節が合うもの・一年中のものから。該当がなければ全体から）。同じ日・同じ条件なら同じ結果。
/// 通知とフィードが同じ雑学になるように、どちらもこの関数で選ぶ。
Trivia? pickTodayFact(List<Trivia> pool, DateTime day, {Season? season}) {
  if (pool.isEmpty) return null;
  final anniversaries = [
    for (final t in pool)
      if (dateOffset(t.dates, day, window: 0) != null) t,
  ]..sort((a, b) => a.id.compareTo(b.id));
  if (anniversaries.isNotEmpty) return anniversaries.first;
  if (season != null) {
    final inSeason = [
      for (final t in pool)
        if (t.seasons.isEmpty || t.seasons.contains(season.name)) t,
    ];
    if (inSeason.isNotEmpty) return pickForDay(inSeason, day);
  }
  return pickForDay(pool, day);
}
