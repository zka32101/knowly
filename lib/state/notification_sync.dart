import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/notification_plan.dart';
import '../models/age_band.dart';
import '../services/notifications.dart';
import 'providers.dart';
import 'settings.dart';

const _appNames = {'ja': 'ノウリー', 'en': 'Knowly'};

/// クイズの前につける、問いかけ（通知の文面に変化をつける）。
const _teaserPrefix = {
  'en': 'True or false? ',
  'zh': '对还是错？',
  'ko': '맞을까요, 틀릴까요? ',
  'es': '¿Verdadero o falso? ',
};
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

  final repo = ref.watch(triviaRepositoryProvider);
  String? quizStatement(String id) => repo.quizFor(id)?.forLanguage(lang)?.statement;

  final items = <NotificationItem>[];
  for (final p in planNotifications(pool: pool, now: now, hour: hour, minute: minute, picker: picker)) {
    final level = resolve(p.fact);
    if (level == null) continue;
    items.add(NotificationItem(
      id: p.id,
      fireAt: p.fireAt,
      title: _appNames[lang] ?? _appNames['en']!,
      body: _body(p.fireAt, level.title, quizStatement(p.fact.id), lang),
    ));
  }
  unawaited(service.schedule(items, channelName: _channelNames[lang] ?? _channelNames['en']!));
});

/// 日によって、雑学の見出しと、○×の問いかけを入れかえる（毎日同じ文面にならないように）。
String _body(DateTime fireAt, String title, String? statement, String lang) {
  // 日本語の○×は、ひらがなだけ（子ども向け）なので、Teen/Adult の通知では使わない。
  if (lang == 'ja' || statement == null || fireAt.day.isEven) return title;
  return '${_teaserPrefix[lang] ?? _teaserPrefix['en']!}$statement';
}
