import 'dart:math';

/// 対戦で出す1問。○×は選択肢が2つ（[isTrueFalse]）、選択式は2〜4つ。
class BattleQuestion {
  const BattleQuestion({
    required this.factId,
    required this.statement,
    required this.options,
    required this.correct,
    required this.explanation,
    required this.illustration,
    required this.category,
    this.isTrueFalse = false,
  });
  final String factId;
  final String statement;
  final List<String> options;
  final int correct;
  final String explanation;
  final String illustration;
  final String category;
  final bool isTrueFalse;
}

enum BattlePhase { answering, reveal, finished }

/// 時間切れの答え。
const timedOut = -1;

/// 速く答えるほど増える得点（[timeLimit] 秒のうち残り [remaining] 秒）。
int speedPoints(int remaining) => 100 + remaining * 10;

/// 1台の端末で、1〜4人が順番に答えるクイズ。全員が同じ問題に順番に答え、
/// 全員が答え終わったら正解を発表する。結果は保存しない。
class QuizGame {
  QuizGame({required this.names, required this.questions, this.timeLimit})
      : assert(names.isNotEmpty && names.length <= maxPlayers),
        assert(questions.isNotEmpty),
        _answers = List.generate(questions.length, (_) => List<int?>.filled(names.length, null)),
        _points = List.generate(questions.length, (_) => List<int>.filled(names.length, 0));

  static const maxPlayers = 4;

  final List<String> names;
  final List<BattleQuestion> questions;

  /// 1人あたりの制限時間（秒）。null なら時間制限なし。
  final int? timeLimit;
  final List<List<int?>> _answers;
  final List<List<int>> _points;

  int round = 0;
  int turn = 0;
  BattlePhase phase = BattlePhase.answering;

  int get playerCount => names.length;
  bool get isSolo => names.length == 1;
  bool get timed => timeLimit != null;
  BattleQuestion get question => questions[round];
  bool get isLastRound => round == questions.length - 1;

  int? answerOf(int player) => _answers[round][player];

  bool? isCorrect(int player) {
    final a = answerOf(player);
    return a == null ? null : a == question.correct;
  }

  /// 現在のプレイヤーが [index] 番目の選択肢を選ぶ。全員が答え終わったら発表へ進む。
  /// [remaining] は残り秒数（時間制限があるとき、正解の得点に使う）。
  void answer(int index, {int remaining = 0}) {
    if (phase != BattlePhase.answering) return;
    _answers[round][turn] = index;
    if (index == question.correct && timed) {
      _points[round][turn] = speedPoints(remaining);
    }
    if (turn == playerCount - 1) {
      phase = BattlePhase.reveal;
    } else {
      turn++;
    }
  }

  /// 時間切れ（不正解として次の人へ）。
  void timeUp() => answer(timedOut);

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

  int get _lastCounted => phase == BattlePhase.answering ? round - 1 : round;

  /// 各プレイヤーの正解数。発表前の問題は数えない。
  List<int> get scores => [
        for (var p = 0; p < playerCount; p++)
          [
            for (var r = 0; r <= _lastCounted; r++)
              if (_answers[r][p] == questions[r].correct) 1,
          ].length,
      ];

  /// 速さの得点の合計（時間制限があるときの同点の決着に使う）。
  List<int> get points => [
        for (var p = 0; p < playerCount; p++)
          [for (var r = 0; r <= _lastCounted; r++) _points[r][p]].fold(0, (a, b) => a + b),
      ];

  /// 順位（同点は同順位）。時間制限ありのときは、正解数が同じなら速さの得点で決める。
  List<int> get ranks {
    final s = scores;
    final pt = points;
    bool better(int a, int b) =>
        s[a] > s[b] || (timed && s[a] == s[b] && pt[a] > pt[b]);
    return [
      for (var p = 0; p < playerCount; p++)
        1 + [for (var o = 0; o < playerCount; o++) if (better(o, p)) 1].length,
    ];
  }

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
