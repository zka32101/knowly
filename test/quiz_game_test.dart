import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/logic/quiz_game.dart';

/// 正解が [correct] 番目（○×なら 0=○, 1=✕）の問題。
BattleQuestion q(String id, int correct, {int options = 2}) => BattleQuestion(
      factId: id,
      statement: id,
      options: [for (var i = 0; i < options; i++) '$i'],
      correct: correct,
      explanation: '',
      illustration: 'x',
      category: 'animals',
      isTrueFalse: options == 2,
    );

void main() {
  test('1人: 答えると発表になり、正解数が数えられる', () {
    final g = QuizGame(names: ['a'], questions: [q('1', 0), q('2', 1)]);
    expect(g.isSolo, isTrue);
    g.answer(0);
    expect(g.phase, BattlePhase.reveal);
    expect(g.scores, [1]);
    g.next();
    expect(g.round, 1);
    g.answer(0); // 不正解
    g.next();
    expect(g.phase, BattlePhase.finished);
    expect(g.scores, [1]);
  });

  test('4人: 全員が順番に答えてから発表。発表前は今の問題を数えない', () {
    final g = QuizGame(names: ['a', 'b', 'c', 'd'], questions: [q('1', 0)]);
    g.answer(0);
    expect(g.turn, 1);
    expect(g.scores, [0, 0, 0, 0]);
    g.answer(1);
    g.answer(0);
    g.answer(1);
    expect(g.phase, BattlePhase.reveal);
    expect(g.scores, [1, 0, 1, 0]);
    expect(g.ranks, [1, 3, 1, 3]);
    expect(g.winners, [0, 2]);
  });

  test('4択: 正解の番号で判定する', () {
    final g = QuizGame(names: ['a', 'b'], questions: [q('1', 2, options: 4)]);
    g.answer(2);
    g.answer(3);
    expect(g.isCorrect(0), isTrue);
    expect(g.isCorrect(1), isFalse);
  });

  test('発表中の回答や、回答中の next は無視される', () {
    final g = QuizGame(names: ['a'], questions: [q('1', 0), q('2', 0)]);
    g.next();
    expect(g.round, 0);
    g.answer(0);
    g.answer(1);
    expect(g.scores, [1]);
  });

  test('時間制限: 速い方が得点が高く、同じ正解数なら順位が決まる', () {
    final g = QuizGame(names: ['a', 'b'], questions: [q('1', 0)], timeLimit: 10);
    g.answer(0, remaining: 3);
    g.answer(0, remaining: 9);
    expect(g.scores, [1, 1]);
    expect(g.points, [speedPoints(3), speedPoints(9)]);
    expect(g.ranks, [2, 1]);
    expect(g.winners, [1]);
  });

  test('時間制限なしなら、同じ正解数は同順位', () {
    final g = QuizGame(names: ['a', 'b'], questions: [q('1', 0)]);
    g.answer(0);
    g.answer(0);
    expect(g.ranks, [1, 1]);
  });

  test('時間切れは不正解で、次の人へ進む', () {
    final g = QuizGame(names: ['a', 'b'], questions: [q('1', 0)], timeLimit: 10);
    g.timeUp();
    expect(g.turn, 1);
    g.answer(0, remaining: 5);
    expect(g.isCorrect(0), isFalse);
    expect(g.isCorrect(1), isTrue);
    expect(g.points[0], 0);
  });

  test('pickQuestions: 重複なし・足りなければある分だけ', () {
    final pool = [for (var i = 0; i < 6; i++) i];
    final picked = pickQuestions(pool, 10, Random(1));
    expect(picked.toSet(), pool.toSet());
    expect(pickQuestions(pool, 3, Random(1)), hasLength(3));
    expect(pool, [0, 1, 2, 3, 4, 5]);
  });
}
