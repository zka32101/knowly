import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

/// ホーム画面ウィジェットに出す内容。日付（yyyy-MM-dd）ごとのタイトルと本文。
class WidgetContent {
  const WidgetContent({
    required this.appName,
    required this.hint,
    required this.days,
  });

  final String appName;

  /// その日のデータがないときに出す案内。
  final String hint;
  final Map<String, ({String title, String body})> days;
}

abstract class HomeWidgetService {
  Future<void> update(WidgetContent content);

  /// ウィジェットの中身を消す（Kids/Junior や、データ削除のあと）。
  Future<void> clear();
}

class DeviceHomeWidgetService implements HomeWidgetService {
  static const _androidName = 'KnowlyWidgetProvider';
  String? _lastKey;

  @override
  Future<void> update(WidgetContent content) async {
    final key = '${content.appName}|${content.hint}|${content.days}';
    if (key == _lastKey) return;
    _lastKey = key;
    try {
      await HomeWidget.saveWidgetData<String>('w_app_name', content.appName);
      await HomeWidget.saveWidgetData<String>('w_hint', content.hint);
      for (final e in content.days.entries) {
        await HomeWidget.saveWidgetData<String>('w_${e.key}_title', e.value.title);
        await HomeWidget.saveWidgetData<String>('w_${e.key}_body', e.value.body);
      }
      await HomeWidget.updateWidget(androidName: _androidName);
    } catch (_) {
      // ウィジェットに対応しない端末・プラットフォームでは何もしない。
    }
  }

  @override
  Future<void> clear() async {
    if (_lastKey == 'cleared') return;
    _lastKey = 'cleared';
    try {
      // 日付つきの保存データは、上書き用に空の案内だけにして、中身は表示しない。
      await HomeWidget.saveWidgetData<String>('w_hint', '');
      for (var i = 0; i < 14; i++) {
        final d = DateTime.now().add(Duration(days: i - 1));
        final k =
            '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        await HomeWidget.saveWidgetData<String>('w_${k}_title', null);
        await HomeWidget.saveWidgetData<String>('w_${k}_body', null);
      }
      await HomeWidget.updateWidget(androidName: _androidName);
    } catch (_) {}
  }
}

final homeWidgetServiceProvider =
    Provider<HomeWidgetService>((ref) => DeviceHomeWidgetService());
