import 'dart:math';

/// 対戦で出す1問。
class BattleQuestion {
  const BattleQuestion({
    required this.factId,
    required this.statement,
    required this.answer,
    required this.explanation,
    required this.illustration,
  });
  final String factId;
  final String statement;
  final bool answer;
  final String explanation;
  final String illustration;
}

enum BattlePhase { answering, reveal, finished }

/// 1台の端末で、1〜4人が順番に答えるクイズ。全員が同じ問題に順番に答え、
/// 全員が答え終わったら正解を発表する。結果は保存しない。
class QuizGame {
  QuizGame({required this.names, required this.questions})
      : assert(names.isNotEmpty && names.length <= maxPlayers),
        assert(questions.isNotEmpty),
        _answers = List.generate(questions.length, (_) => List<bool?>.filled(names.length, null));

  static const maxPlayers = 4;

  final List<String> names;
  final List<BattleQuestion> questions;
  final List<List<bool?>> _answers;

  int round = 0;
  int turn = 0;
  BattlePhase phase = BattlePhase.answering;

  int get playerCount => names.length;
  bool get isSolo => names.length == 1;
  BattleQuestion get question => questions[round];
  bool get isLastRound => round == questions.length - 1;

  /// 現在の問題に対する、[player] の答え（未回答は null）。
  bool? answerOf(int player) => _answers[round][player];

  bool? isCorrect(int player) {
    final a = answerOf(player);
    return a == null ? null : a == question.answer;
  }

  /// 現在のプレイヤーが答える。全員が答え終わったら発表へ進む。
  void answer(bool value) {
    if (phase != BattlePhase.answering) return;
    _answers[round][turn] = value;
    if (turn == playerCount - 1) {
      phase = BattlePhase.reveal;
    } else {
      turn++;
    }
  }

  /// 発表から次の問題へ（最後なら終了）。
  void next() {
    if (phase != BattlePhase.reveal) return;
    if (isLastRound) {
      phase = BattlePhase.finished;
    } else {
      round++;
      turn = 0;
      phase = BattlePhase.answering;
    }
  }

  /// 各プレイヤーの正解数。発表前の問題は数えない。
  List<int> get scores {
    final last = phase == BattlePhase.answering ? round - 1 : round;
    return [
      for (var p = 0; p < playerCount; p++)
        [
          for (var r = 0; r <= last; r++)
            if (_answers[r][p] == questions[r].answer) 1,
        ].length,
    ];
  }

  /// 順位（同点は同順位）。`rank[p]` は 1 始まり。
  List<int> get ranks {
    final s = scores;
    return [for (final x in s) 1 + s.where((y) => y > x).length];
  }

  /// 最高得点のプレイヤー（同点は全員）。
  List<int> get winners {
    final r = ranks;
    return [for (var p = 0; p < playerCount; p++) if (r[p] == 1) p];
  }
}

/// 出題の選び方: シャッフルして先頭から [count] 問（足りなければある分だけ）。
List<T> pickQuestions<T>(List<T> pool, int count, Random random) {
  final list = [...pool]..shuffle(random);
  return list.take(count).toList();
}
