import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/logic/league.dart';

void main() {
  test('週は月曜はじまり', () {
    expect(weekKey(DateTime(2026, 10, 19)), '2026-10-19'); // 月
    expect(weekKey(DateTime(2026, 10, 23)), '2026-10-19'); // 金
    expect(weekKey(DateTime(2026, 10, 25)), '2026-10-19'); // 日
    expect(weekKey(DateTime(2026, 10, 26)), '2026-10-26'); // 次の月
    expect(weekKey(DateTime(2026, 1, 1)), '2025-12-29');
  });

  test('1試合の結果: 正解数＋勝ちボーナス', () {
    final d = addGame(const LeagueData(), DateTime(2026, 10, 23),
        names: ['a', 'b'], scores: [4, 2], winners: [0]);
    expect(d.scores['a']!.points, 4 + leagueWinBonus);
    expect(d.scores['a']!.wins, 1);
    expect(d.scores['b']!.points, 2);
    expect(d.scores['b']!.wins, 0);
    expect(d.scores['a']!.games, 1);
    expect(d.week, '2026-10-19');
  });

  test('同点は、勝った人全員にボーナス。同じ名前は積み上がる', () {
    var d = addGame(const LeagueData(), DateTime(2026, 10, 20),
        names: ['a', 'b'], scores: [3, 3], winners: [0, 1]);
    d = addGame(d, DateTime(2026, 10, 21), names: ['a'], scores: [1], winners: [0]);
    expect(d.scores['a']!.points, (3 + leagueWinBonus) + (1 + leagueWinBonus));
    expect(d.scores['a']!.games, 2);
    expect(d.scores['b']!.points, 3 + leagueWinBonus);
  });

  test('週がかわると、先週の優勝者が決まり、今週は0から', () {
    var d = addGame(const LeagueData(), DateTime(2026, 10, 22),
        names: ['a', 'b'], scores: [5, 1], winners: [0]);
    d = rollWeek(d, DateTime(2026, 10, 27)); // 翌週
    expect(d.lastWinner, 'a');
    expect(d.lastPoints, 5 + leagueWinBonus);
    expect(d.scores, isEmpty);
    expect(d.week, '2026-10-26');
  });

  test('同じ週なら、そのまま。1週間以上あいたら、先週の優勝者は出さない', () {
    final d = addGame(const LeagueData(), DateTime(2026, 10, 22),
        names: ['a'], scores: [5], winners: [0]);
    expect(identical(rollWeek(d, DateTime(2026, 10, 25)), d), isTrue);
    final late = rollWeek(d, DateTime(2026, 11, 20));
    expect(late.lastWinner, isNull);
    expect(late.scores, isEmpty);
  });

  test('leader: 同点は名前順、得点がなければ null', () {
    expect(leader(const {}), isNull);
    expect(
        leader({
          'b': const LeagueEntry(points: 5, games: 1, wins: 0),
          'a': const LeagueEntry(points: 5, games: 1, wins: 0),
        }),
        'a');
    expect(leader({'a': const LeagueEntry(points: 0, games: 1, wins: 0)}), isNull);
  });
}
