import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/notification_plan.dart';
import '../models/age_band.dart';
import '../services/notifications.dart';
import 'providers.dart';
import 'settings.dart';

const _appNames = {'ja': '雑学コレ！', 'en': 'Knowly'};
const _channelNames = {'ja': '毎日の雑学', 'en': 'Daily fact'};

/// 設定（通知のオン/オフ・時刻・年代・言語・絞り込み）が変わるたびに、予定通知を作り直す。
/// アプリを開くたびにも作り直すので、先の14日ぶんが常に予定されている状態になる。
final notificationSyncProvider = Provider<void>((ref) {
  final s = ref.watch(settingsProvider.select((s) => (
        s.ageBand,
        s.notifyEnabled,
        s.notifyHour,
        s.notifyMinute,
      )));
  final (band, enabled, hour, minute) = s;
  final service = ref.watch(notificationServiceProvider);
  final pool = ref.watch(poolProvider);
  final lang = ref.watch(contentLanguageProvider);
  final resolve = ref.watch(levelResolverProvider);
  final now = ref.watch(nowProvider);
  final picker = ref.watch(dayPickerProvider);

  // Kids には通知を出さない。
  if (band == null || band == AgeBand.kids || !enabled) {
    unawaited(service.cancelAll());
    return;
  }

  final items = <NotificationItem>[];
  for (final p in planNotifications(pool: pool, now: now, hour: hour, minute: minute, picker: picker)) {
    final level = resolve(p.fact);
    if (level == null) continue;
    items.add(NotificationItem(
      id: p.id,
      fireAt: p.fireAt,
      title: _appNames[lang] ?? _appNames['en']!,
      body: level.title,
    ));
  }
  unawaited(service.schedule(items, channelName: _channelNames[lang] ?? _channelNames['en']!));
});
