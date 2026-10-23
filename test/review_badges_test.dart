import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/logic/badges.dart';
import 'package:knowly/logic/review.dart';

void main() {
  final today = DateTime(2026, 10, 23);

  group('復習の予定', () {
    test('覚えたら明日が最初の復習日', () {
      expect(firstReview(today).due, '2026-10-24');
    });

    test('正解すると間隔が伸び、最後まで正解すると卒業する', () {
      var e = firstReview(today);
      final dues = <String>[];
      var day = today;
      for (var i = 0; i < reviewIntervals.length - 1; i++) {
        final next = afterReview(e, correct: true, today: day);
        expect(next, isNotNull);
        e = next!;
        dues.add(e.due);
        day = DateTime.parse(e.due);
      }
      expect(dues.first, '2026-10-26'); // +3日
      expect(afterReview(e, correct: true, today: day), isNull); // 卒業
    });

    test('間違えると最初に戻り、明日また復習する', () {
      const e = ReviewEntry(box: 3, due: '2026-10-23');
      final next = afterReview(e, correct: false, today: today)!;
      expect(next.box, 0);
      expect(next.due, '2026-10-24');
    });

    test('期限が来たものだけ、古い順に返す', () {
      final due = dueReviewIds({
        'a': const ReviewEntry(box: 0, due: '2026-10-23'),
        'b': const ReviewEntry(box: 0, due: '2026-10-20'),
        'c': const ReviewEntry(box: 0, due: '2026-10-24'),
      }, today);
      expect(due, ['b', 'a']);
    });

    test('保存形式の往復と、壊れた行の無視', () {
      const e = ReviewEntry(box: 2, due: '2026-11-01');
      final (id, back) = ReviewEntry.decode(e.encode('x'))!;
      expect(id, 'x');
      expect(back.box, 2);
      expect(back.due, '2026-11-01');
      expect(ReviewEntry.decode('broken'), isNull);
      expect(ReviewEntry.decode('x:-1:2026-01-01'), isNull);
    });
  });

  group('バッジ', () {
    test('条件を満たすと手に入る', () {
      const s = BadgeStats(streak: 7, quizCorrect: 10, dailyDays: 1);
      bool earned(BadgeMetric m, int t) =>
          isEarned(badgeDefs.firstWhere((b) => b.metric == m && b.target == t), s);
      expect(earned(BadgeMetric.streak, 3), isTrue);
      expect(earned(BadgeMetric.streak, 7), isTrue);
      expect(earned(BadgeMetric.streak, 30), isFalse);
      expect(earned(BadgeMetric.quizCorrect, 10), isTrue);
      expect(earned(BadgeMetric.quizCorrect, 50), isFalse);
      expect(earned(BadgeMetric.dailyDays, 1), isTrue);
    });

    test('バッジの id は重複しない', () {
      expect(badgeDefs.map((b) => b.id).toSet().length, badgeDefs.length);
    });

    test('bestStreak: 途切れた記録でも、最長を数える', () {
      expect(bestStreak([]), 0);
      expect(
          bestStreak(['2026-10-01', '2026-10-02', '2026-10-03', '2026-10-10', '2026-10-11']), 3);
    });
  });
}
