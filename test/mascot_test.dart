import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/logic/mascot.dart';

void main() {
  test('ポイント: 開いた数 + 知れた数×2', () {
    expect(mascotPoints(seen: 3, learned: 2), 7);
  });

  test('段階はしきい値で上がり、下がらない順に並ぶ', () {
    final t = mascotStages.map((s) => s.threshold).toList();
    expect([...t]..sort(), t);
    expect(t.toSet().length, t.length);
    expect(mascotStageFor(0).id, 'egg');
    expect(mascotStageFor(4).id, 'egg');
    expect(mascotStageFor(5).id, 'chick');
    expect(mascotStageFor(40).id, 'owl');
    expect(mascotStageFor(9999).id, 'king');
  });

  test('次の段階: 最後は null', () {
    expect(nextMascotStage(0)!.id, 'chick');
    expect(nextMascotStage(5)!.id, 'chicklet');
    expect(nextMascotStage(250), isNull);
  });

  test('段階の id は重複しない', () {
    expect(mascotStages.map((s) => s.id).toSet().length, mascotStages.length);
  });
}
