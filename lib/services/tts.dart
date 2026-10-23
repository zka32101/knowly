import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// 端末内の読み上げ（API 費用なし・音声データを外部に送らない）。
abstract class TtsService {
  Future<void> speak(String text, {required String language, double? rate});
  Future<void> stop();
}

class DeviceTtsService implements TtsService {
  final FlutterTts _tts = FlutterTts();

  @override
  Future<void> speak(String text, {required String language, double? rate}) async {
    try {
      await _tts.setLanguage(language == 'ja' ? 'ja-JP' : 'en-US');
      await _tts.setSpeechRate(rate ?? 0.4);
      await _tts.speak(text);
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}

final ttsProvider = Provider<TtsService>((ref) => DeviceTtsService());
