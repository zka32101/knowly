import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// 画像の共有。テストでは差し替える。
abstract class ShareService {
  Future<void> shareImage(Uint8List png, {required String text});
}

class DeviceShareService implements ShareService {
  @override
  Future<void> shareImage(Uint8List png, {required String text}) async {
    await SharePlus.instance.share(ShareParams(
      text: text,
      files: [XFile.fromData(png, mimeType: 'image/png', name: 'knowly.png')],
    ));
  }
}

final shareServiceProvider = Provider<ShareService>((ref) => DeviceShareService());
