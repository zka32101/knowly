import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/readings.dart';
import '../models/trivia.dart';
import '../services/listen_background.dart';
import '../services/tts.dart';
import 'providers.dart';
import 'settings.dart';

/// 読み上げの速さ（ゆっくり / ふつう / はやい）。
enum ListenSpeed {
  slow(0.3),
  normal(0.4),
  fast(0.5);

  const ListenSpeed(this.rate);
  final double rate;
}

class ListenState {
  const ListenState({
    required this.queue,
    this.index = 0,
    this.playing = false,
    this.finished = false,
    this.speed = ListenSpeed.normal,
  });

  final List<Trivia> queue;
  final int index;
  final bool playing;

  /// 最後まで読み終えた。
  final bool finished;
  final ListenSpeed speed;

  Trivia? get current => queue.isEmpty ? null : queue[index.clamp(0, queue.length - 1)];

  ListenState copyWith({
    List<Trivia>? queue,
    int? index,
    bool? playing,
    bool? finished,
    ListenSpeed? speed,
  }) =>
      ListenState(
        queue: queue ?? this.queue,
        index: index ?? this.index,
        playing: playing ?? this.playing,
        finished: finished ?? this.finished,
        speed: speed ?? this.speed,
      );
}

/// ながら聞き: 雑学を順番に連続で読み上げる。再生・一時停止・前後の移動・速さの変更ができる。
/// 一時停止や移動のたびに「世代」を進め、前の読み上げの終了通知で勝手に次へ進まないようにする。
class ListenController extends StateNotifier<ListenState> {
  ListenController(this._tts, this._textOf, this._language, List<Trivia> queue)
      : super(ListenState(queue: queue));

  final TtsService _tts;
  final String? Function(Trivia) _textOf;
  final String _language;
  int _generation = 0;
  bool _disposed = false;

  void play() {
    if (state.queue.isEmpty) return;
    // 最後まで読み終えていたら、最初から。
    final start = state.finished ? 0 : state.index;
    state = state.copyWith(index: start, playing: true, finished: false);
    unawaited(_run(++_generation));
  }

  void pause() {
    _generation++;
    state = state.copyWith(playing: false);
    unawaited(_tts.stop());
  }

  void toggle() => state.playing ? pause() : play();

  void next() => _jump(state.index + 1);

  void previous() => _jump(state.index - 1);

  void jumpTo(int i) => _jump(i);

  void _jump(int i) {
    if (state.queue.isEmpty) return;
    final target = i.clamp(0, state.queue.length - 1);
    final wasPlaying = state.playing;
    _generation++;
    unawaited(_tts.stop());
    state = state.copyWith(index: target, finished: false);
    if (wasPlaying) unawaited(_run(++_generation));
  }

  void setSpeed(ListenSpeed speed) {
    final wasPlaying = state.playing;
    state = state.copyWith(speed: speed);
    // 再生中なら、いまの雑学を新しい速さで読み直す。
    if (wasPlaying) {
      _generation++;
      unawaited(_tts.stop());
      unawaited(_run(++_generation));
    }
  }

  Future<void> _run(int generation) async {
    while (!_disposed && generation == _generation && state.playing) {
      final item = state.current;
      final text = item == null ? null : _textOf(item);
      if (text != null) {
        await _tts.speakAndWait(text, language: _language, rate: state.speed.rate);
      }
      // 一時停止・移動・画面を閉じたときは、ここで終わる。
      if (_disposed || generation != _generation || !state.playing) return;
      if (state.index + 1 >= state.queue.length) {
        state = state.copyWith(playing: false, finished: true);
        return;
      }
      state = state.copyWith(index: state.index + 1);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    unawaited(_tts.stop());
    super.dispose();
  }
}

/// 連続再生する雑学: 今日の雑学 → いまのおすすめ → あなたの関心 → これまでの雑学（重複なし・最大10件）。
final listenQueueProvider = Provider<List<Trivia>>((ref) {
  final feed = ref.watch(feedProvider);
  final out = <Trivia>[];
  final seen = <String>{};
  void add(Trivia t) {
    if (seen.add(t.id) && out.length < 10) out.add(t);
  }

  if (feed.isNotEmpty) add(feed.first);
  for (final p in ref.watch(timingPicksProvider)) {
    add(p.fact);
  }
  for (final t in ref.watch(interestPicksProvider)) {
    add(t);
  }
  for (final t in feed.skip(1)) {
    add(t);
  }
  return out;
});

final listenControllerProvider =
    StateNotifierProvider.autoDispose<ListenController, ListenState>((ref) {
  final band = ref.read(settingsProvider).ageBand;
  final lang = ref.read(contentLanguageProvider);
  final resolve = ref.read(levelResolverProvider);
  return ListenController(
    ref.read(ttsProvider),
    (t) {
      final level = resolve(t);
      return level == null ? null : stripReadings('${level.title}。${level.body}');
    },
    lang,
    band == null ? const [] : ref.read(listenQueueProvider),
  );
});

/// ながら聞きの画面の間だけ、通知・ロック画面・イヤホンのボタンと読み上げをつなぐ。
final listenBackgroundSyncProvider = Provider.autoDispose<void>((ref) {
  final background = ref.watch(listenBackgroundProvider);
  final controller = ref.read(listenControllerProvider.notifier);
  final resolve = ref.watch(levelResolverProvider);
  final lang = ref.watch(contentLanguageProvider);
  const appNames = {'ja': '雑学コレ！', 'en': 'Knowly'};

  background.bind(
    onPlay: controller.play,
    onPause: controller.pause,
    onNext: controller.next,
    onPrevious: controller.previous,
  );

  void push(ListenState s) {
    final current = s.current;
    final level = current == null ? null : resolve(current);
    if (level == null) return;
    background.update(
      title: stripReadings(level.title),
      appName: appNames[lang] ?? appNames['en']!,
      playing: s.playing,
      hasPrevious: s.index > 0,
      hasNext: s.index + 1 < s.queue.length,
    );
  }

  ref.listen<ListenState>(listenControllerProvider, (_, s) => push(s));
  ref.onDispose(background.stop);
});
