import 'streak.dart';

/// 家族リーグ（端末内）。1週間（月曜はじまり）ごとに、名前ごとの得点を集計する。
class LeagueEntry {
  const LeagueEntry({required this.points, required this.games, required this.wins});
  final int points;
  final int games;
  final int wins;

  LeagueEntry add({required int points, required bool won}) => LeagueEntry(
        points: this.points + points,
        games: games + 1,
        wins: wins + (won ? 1 : 0),
      );
}

class LeagueData {
  const LeagueData({this.week, this.scores = const {}, this.lastWinner, this.lastPoints = 0});

  /// 集計中の週の月曜（yyyy-MM-dd）。
  final String? week;
  final Map<String, LeagueEntry> scores;

  /// 先週の優勝者（いなければ null）と、その得点。
  final String? lastWinner;
  final int lastPoints;
}

/// 1試合の勝ちボーナス。
const leagueWinBonus = 3;

/// その日を含む週の月曜（yyyy-MM-dd）。
String weekKey(DateTime d) {
  final day = DateTime(d.year, d.month, d.day);
  final monday = day.subtract(Duration(days: day.weekday - DateTime.monday));
  return dayKey(monday);
}

/// 最高得点の名前（同点なら名前順で先頭）。得点がなければ null。
String? leader(Map<String, LeagueEntry> scores) {
  final list = scores.entries.where((e) => e.value.points > 0).toList()
    ..sort((a, b) {
      final c = b.value.points.compareTo(a.value.points);
      return c != 0 ? c : a.key.compareTo(b.key);
    });
  return list.isEmpty ? null : list.first.key;
}

/// 週がかわっていたら、先週の優勝者を決めて、集計を新しい週にする。
LeagueData rollWeek(LeagueData data, DateTime today) {
  final current = weekKey(today);
  if (data.week == current) return data;
  if (data.week == null) return LeagueData(week: current, lastWinner: data.lastWinner, lastPoints: data.lastPoints);
  // 先週より前の週なら、先週の優勝者としては出さない（1週間以上あいたとき）。
  // 夏時間の切り替えで 7日=168時間 がずれないよう、日付で7日進める。
  final w = DateTime.parse(data.week!);
  final prev = weekKey(DateTime(w.year, w.month, w.day + 7));
  final winner = prev == current ? leader(data.scores) : null;
  return LeagueData(
    week: current,
    lastWinner: winner,
    lastPoints: winner == null ? 0 : data.scores[winner]!.points,
  );
}

/// 1試合の結果を加える。[scores] は正解数、[winners] は勝った人の番号（同点は全員）。
LeagueData addGame(
  LeagueData data,
  DateTime today, {
  required List<String> names,
  required List<int> scores,
  required List<int> winners,
}) {
  final base = rollWeek(data, today);
  final map = {...base.scores};
  for (var i = 0; i < names.length; i++) {
    final won = winners.contains(i);
    final pts = scores[i] + (won ? leagueWinBonus : 0);
    map[names[i]] = (map[names[i]] ?? const LeagueEntry(points: 0, games: 0, wins: 0))
        .add(points: pts, won: won);
  }
  return LeagueData(
      week: base.week, scores: map, lastWinner: base.lastWinner, lastPoints: base.lastPoints);
}
