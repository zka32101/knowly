import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// アプリを開き直したとき（バックグラウンドから戻ったとき）に、「今」を取り直す。
/// 夜をまたいで開いたままでも、日付・週・季節の記録が前の日のままにならないようにする。
final clockSyncProvider = Provider<void>((ref) {
  final observer = _ResumeObserver(() => ref.invalidate(nowProvider));
  WidgetsBinding.instance.addObserver(observer);
  ref.onDispose(() => WidgetsBinding.instance.removeObserver(observer));
});

class _ResumeObserver with WidgetsBindingObserver {
  _ResumeObserver(this.onResume);
  final VoidCallback onResume;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResume();
  }
}
