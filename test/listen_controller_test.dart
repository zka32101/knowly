import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/models/age_band.dart';
import 'package:knowly/models/trivia.dart';
import 'package:knowly/services/tts.dart';
import 'package:knowly/state/listen_controller.dart';

class _Tts implements TtsService {
  final spoken = <String>[];
  final rates = <double?>[];
  bool auto = true;
  final pending = <Completer<void>>[];
  int stops = 0;

  @override
  Future<void> speak(String text, {required String language, double? rate}) async {}

  @override
  Future<void> speakAndWait(String text, {required String language, double? rate}) async {
    spoken.add(text);
    rates.add(rate);
    if (auto) return;
    final c = Completer<void>();
    pending.add(c);
    await c.future;
  }

  void finishCurrent() {
    if (pending.isNotEmpty) pending.removeAt(0).complete();
  }

  @override
  Future<void> stop() async {
    stops++;
    for (final c in pending) {
      if (!c.isCompleted) c.complete();
    }
    pending.clear();
  }
}

Trivia _t(String id) => Trivia(
      id: id, category: 'animals', scenes: const [], minAgeBand: AgeBand.kids,
      sensitivity: 'none', regions: const [], illustration: '', translations: const {},
    );

Future<void> settle() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

ListenController _make(_Tts tts, List<String> ids, {String? Function(Trivia)? textOf}) =>
    ListenController(tts, textOf ?? (t) => 'text-${t.id}', 'ja', [for (final i in ids) _t(i)]);

void main() {
  test('再生すると、順番に最後まで読んで、おしまいになる', () async {
    final tts = _Tts();
    final c = _make(tts, ['a', 'b', 'c']);
    c.play();
    await settle();
    expect(tts.spoken, ['text-a', 'text-b', 'text-c']);
    expect(c.state.playing, isFalse);
    expect(c.state.finished, isTrue);
    expect(c.state.index, 2);
    c.dispose();
  });

  test('1つ読み終えるまで次へ進まない', () async {
    final tts = _Tts()..auto = false;
    final c = _make(tts, ['a', 'b']);
    c.play();
    await settle();
    expect(tts.spoken, ['text-a']);
    expect(c.state.index, 0);
    tts.finishCurrent();
    await settle();
    expect(tts.spoken, ['text-a', 'text-b']);
    expect(c.state.index, 1);
    c.dispose();
  });

  test('一時停止すると止まり、再生すると同じ雑学から読み直す', () async {
    final tts = _Tts()..auto = false;
    final c = _make(tts, ['a', 'b', 'c']);
    c.play();
    await settle();
    tts.finishCurrent();
    await settle();
    expect(c.state.index, 1);
    c.pause();
    await settle();
    expect(c.state.playing, isFalse);
    expect(c.state.index, 1); // 止めても進まない
    expect(tts.spoken, ['text-a', 'text-b']);
    c.play();
    await settle();
    expect(tts.spoken, ['text-a', 'text-b', 'text-b']); // b を読み直す
    c.dispose();
  });

  test('一時停止→すぐ再生しても、古い読み上げの終了で二重に進まない', () async {
    final tts = _Tts()..auto = false;
    final c = _make(tts, ['a', 'b', 'c']);
    c.play();
    await settle();
    c.pause();
    c.play();
    await settle();
    expect(c.state.index, 0);
    expect(tts.spoken, ['text-a', 'text-a']);
    tts.finishCurrent();
    await settle();
    expect(c.state.index, 1);
    c.dispose();
  });

  test('再生中に「つぎへ」「まえへ」で移動し、その雑学から読む', () async {
    final tts = _Tts()..auto = false;
    final c = _make(tts, ['a', 'b', 'c']);
    c.play();
    await settle();
    c.next();
    await settle();
    expect(c.state.index, 1);
    expect(tts.spoken.last, 'text-b');
    c.previous();
    await settle();
    expect(c.state.index, 0);
    expect(tts.spoken.last, 'text-a');
    c.dispose();
  });

  test('停止中の移動は読まない。両端でとどまる', () async {
    final tts = _Tts();
    final c = _make(tts, ['a', 'b']);
    c.previous();
    expect(c.state.index, 0);
    c.next();
    c.next();
    expect(c.state.index, 1);
    await settle();
    expect(tts.spoken, isEmpty);
    c.jumpTo(99);
    expect(c.state.index, 1);
    c.jumpTo(-5);
    expect(c.state.index, 0);
    c.dispose();
  });

  test('読み終えたあとの再生は、最初からやり直す', () async {
    final tts = _Tts();
    final c = _make(tts, ['a', 'b']);
    c.play();
    await settle();
    expect(c.state.finished, isTrue);
    tts.spoken.clear();
    c.play();
    await settle();
    expect(tts.spoken, ['text-a', 'text-b']);
    c.dispose();
  });

  test('再生中に速さを変えると、いまの雑学を新しい速さで読み直す', () async {
    final tts = _Tts()..auto = false;
    final c = _make(tts, ['a', 'b']);
    c.play();
    await settle();
    expect(tts.rates.last, ListenSpeed.normal.rate);
    c.setSpeed(ListenSpeed.slow);
    await settle();
    expect(tts.spoken, ['text-a', 'text-a']);
    expect(tts.rates.last, ListenSpeed.slow.rate);
    expect(c.state.index, 0);
    c.dispose();
  });

  test('画面を閉じると読み上げを止め、それ以上読まない', () async {
    final tts = _Tts()..auto = false;
    final c = _make(tts, ['a', 'b']);
    c.play();
    await settle();
    final stopsBefore = tts.stops;
    c.dispose();
    await settle();
    expect(tts.stops, greaterThan(stopsBefore));
    expect(tts.spoken, ['text-a']);
  });

  test('空の一覧では何もしない', () async {
    final tts = _Tts();
    final c = _make(tts, []);
    c.play();
    c.next();
    await settle();
    expect(c.state.playing, isFalse);
    expect(c.state.current, isNull);
    expect(tts.spoken, isEmpty);
    c.dispose();
  });

  test('読む文章がない雑学は飛ばして次へ進む', () async {
    final tts = _Tts();
    final c = _make(tts, ['a', 'x', 'c'], textOf: (t) => t.id == 'x' ? null : 'text-${t.id}');
    c.play();
    await settle();
    expect(tts.spoken, ['text-a', 'text-c']);
    expect(c.state.finished, isTrue);
    c.dispose();
  });
}
