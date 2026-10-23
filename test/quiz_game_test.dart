import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/logic/quiz_game.dart';

BattleQuestion q(String id, bool answer) => BattleQuestion(
    factId: id, statement: id, answer: answer, explanation: '', illustration: 'x');

void main() {
  test('1人: 答えると発表になり、正解数が数えられる', () {
    final g = QuizGame(names: ['a'], questions: [q('1', true), q('2', false)]);
    expect(g.isSolo, isTrue);
    g.answer(true);
    expect(g.phase, BattlePhase.reveal);
    expect(g.scores, [1]);
    g.next();
    expect(g.round, 1);
    expect(g.phase, BattlePhase.answering);
    g.answer(true); // 不正解
    g.next();
    expect(g.phase, BattlePhase.finished);
    expect(g.scores, [1]);
  });

  test('4人: 全員が順番に答えてから発表。発表前は今の問題を数えない', () {
    final g = QuizGame(names: ['a', 'b', 'c', 'd'], questions: [q('1', true)]);
    g.answer(true);
    expect(g.turn, 1);
    expect(g.phase, BattlePhase.answering);
    expect(g.scores, [0, 0, 0, 0]);
    g.answer(false);
    g.answer(true);
    g.answer(false);
    expect(g.phase, BattlePhase.reveal);
    expect(g.scores, [1, 0, 1, 0]);
    expect(g.ranks, [1, 3, 1, 3]);
    expect(g.winners, [0, 2]);
  });

  test('発表中の回答や、回答中の next は無視される', () {
    final g = QuizGame(names: ['a'], questions: [q('1', true), q('2', true)]);
    g.next();
    expect(g.round, 0);
    g.answer(true);
    g.answer(false);
    expect(g.scores, [1]);
  });

  test('pickQuestions: 重複なし・足りなければある分だけ', () {
    final pool = [for (var i = 0; i < 6; i++) i];
    final picked = pickQuestions(pool, 10, Random(1));
    expect(picked.toSet(), pool.toSet());
    expect(pickQuestions(pool, 3, Random(1)), hasLength(3));
    expect(pool, [0, 1, 2, 3, 4, 5]); // 元は変えない
  });
}
