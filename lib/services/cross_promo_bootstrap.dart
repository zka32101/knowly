import 'dart:async';

import 'package:cross_promo_kit/cross_promo_kit.dart';
import 'package:firebase_core/firebase_core.dart';

/// 他アプリ紹介（cross_promo_kit）の初期化。Teen/Adult の設定画面を開いたときだけ呼ぶ。
/// Kids/Junior では呼ばない（Firebase への通信を発生させないため）。
/// Firebase の設定ファイルが無い環境では何もしない。
class CrossPromoBootstrap {
  CrossPromoBootstrap._();

  static Future<void>? _started;

  static Future<void> ensureInit() => _started ??= _init();

  static Future<void> _init() async {
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      await CrossPromoService.init();
    } catch (_) {}
  }
}
