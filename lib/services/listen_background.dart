import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ながら聞きの、画面の外（ロック画面・通知・イヤホンのボタン）との連携。
abstract class ListenBackground {
  /// 通知やイヤホンのボタンの操作を、読み上げの操作につなぐ。
  void bind({
    required void Function() onPlay,
    required void Function() onPause,
    required void Function() onNext,
    required void Function() onPrevious,
  });

  /// いま読んでいる雑学を通知に出す。読み上げが始まったら、通知（常駐サービス）を開始する。
  Future<void> update({
    required String title,
    required String appName,
    required bool playing,
    required bool hasPrevious,
    required bool hasNext,
  });

  /// 通知を片づける（画面を閉じたとき）。
  Future<void> stop();
}

class _Handler extends BaseAudioHandler {
  void Function()? onPlay;
  void Function()? onPause;
  void Function()? onNext;
  void Function()? onPrevious;

  @override
  Future<void> play() async => onPlay?.call();

  @override
  Future<void> pause() async => onPause?.call();

  @override
  Future<void> skipToNext() async => onNext?.call();

  @override
  Future<void> skipToPrevious() async => onPrevious?.call();

  @override
  Future<void> stop() async {
    onPause?.call();
    await super.stop();
  }
}

class DeviceListenBackground implements ListenBackground {
  _Handler? _handler;
  Future<_Handler?>? _init;
  void Function()? _onPlay, _onPause, _onNext, _onPrevious;

  /// 初めて読み上げが始まるときに、サービスを用意する（それまでは何も起動しない）。
  Future<_Handler?> _ensure() => _init ??= () async {
        try {
          final h = await AudioService.init(
            builder: _Handler.new,
            config: const AudioServiceConfig(
              androidNotificationChannelId: 'com.yourwish.knowly.listen',
              androidNotificationChannelName: 'Listen',
              // 一時停止でもサービスを前面に残す（Android 12 以降で、背景からの再開が拒否されないように）。
              androidStopForegroundOnPause: false,
            ),
          );
          _handler = h;
          _apply();
          return h;
        } catch (_) {
          return null;
        }
      }();

  void _apply() {
    _handler
      ?..onPlay = _onPlay
      ..onPause = _onPause
      ..onNext = _onNext
      ..onPrevious = _onPrevious;
  }

  @override
  void bind({
    required void Function() onPlay,
    required void Function() onPause,
    required void Function() onNext,
    required void Function() onPrevious,
  }) {
    _onPlay = onPlay;
    _onPause = onPause;
    _onNext = onNext;
    _onPrevious = onPrevious;
    _apply();
  }

  @override
  Future<void> update({
    required String title,
    required String appName,
    required bool playing,
    required bool hasPrevious,
    required bool hasNext,
  }) async {
    // まだ一度も再生していない間は、通知を出さない。
    if (_handler == null && !playing) return;
    final h = await _ensure();
    if (h == null) return;
    h.mediaItem.add(MediaItem(id: 'listen', title: title, album: appName));
    h.playbackState.add(PlaybackState(
      controls: [
        if (hasPrevious) MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        if (hasNext) MediaControl.skipToNext,
      ],
      androidCompactActionIndices: const [0, 1],
      processingState: AudioProcessingState.ready,
      playing: playing,
    ));
  }

  @override
  Future<void> stop() async {
    final h = _handler;
    if (h == null) return;
    try {
      h.onPause = null;
      await h.stop();
    } catch (_) {}
  }
}

final listenBackgroundProvider = Provider<ListenBackground>((ref) => DeviceListenBackground());
