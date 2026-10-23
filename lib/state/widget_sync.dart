import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/notification_plan.dart';
import '../logic/streak.dart';
import '../services/home_widget_service.dart';
import 'providers.dart';
import 'settings.dart';

const _appNames = {'ja': '雑学コレ！', 'en': 'Knowly'};
const _hints = {'ja': 'アプリを開いて、今日の雑学を見よう', 'en': 'Open the app for today\'s fact'};

/// ホーム画面ウィジェットに、今日から数日ぶんの「今日の雑学」を書き込む（アプリを開くたびに更新）。
/// Teen/Adult だけ。Kids/Junior では何も出さない。
final widgetSyncProvider = Provider<void>((ref) {
  final band = ref.watch(settingsProvider.select((s) => s.ageBand));
  final service = ref.watch(homeWidgetServiceProvider);
  if (band == null || band.isChild) {
    unawaited(service.clear());
    return;
  }
  final pool = ref.watch(poolProvider);
  final lang = ref.watch(contentLanguageProvider);
  final resolve = ref.watch(levelResolverProvider);
  final now = ref.watch(nowProvider);
  final picker = ref.watch(dayPickerProvider);

  // 通知と同じ選び方（その日の「今日の雑学」と同じもの）。今日を含めるため、深夜0時前の時刻で計画する。
  final plan = planNotifications(
      pool: pool, now: DateTime(now.year, now.month, now.day), hour: 0, minute: 1, days: 7, picker: picker);
  final days = <String, ({String title, String body})>{};
  for (final p in plan) {
    final level = resolve(p.fact);
    if (level == null) continue;
    days[dayKey(p.fireAt)] = (title: level.title, body: level.body);
  }
  unawaited(service.update(WidgetContent(
    appName: _appNames[lang] ?? _appNames['en']!,
    hint: _hints[lang] ?? _hints['en']!,
    days: days,
  )));
});
