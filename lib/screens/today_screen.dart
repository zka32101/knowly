import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../models/age_band.dart';
import '../models/calendar_event.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/ja_wrap_text.dart';

/// 今日は何の日: 今日の記念日と、これから2週間以内の記念日。
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final today = dateOnly(ref.watch(nowProvider));
    final todays = ref.watch(todayEventsProvider);
    final upcoming = ref.watch(upcomingEventsProvider);
    final theme = Theme.of(context);
    final band = ref.watch(settingsProvider.select((s) => s.ageBand)) ?? AgeBand.adult;
    final wordWrap = band.isChild && ref.watch(contentLanguageProvider) == 'ja';

    return Scaffold(
      appBar: AppBar(title: Text(l.todayTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.dateMonthDay(today),
              key: const Key('today_date'), style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          if (todays.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(l.todayNone, key: const Key('today_none')),
            )
          else
            for (final e in todays) _EventCard(event: e, big: true, wordWrap: wordWrap),
          if (upcoming.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(l.todayUpcoming, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final e in upcoming) _EventCard(event: e, wordWrap: wordWrap, showDate: true),
          ],
        ],
      ),
    );
  }
}

class _EventCard extends ConsumerWidget {
  const _EventCard({
    required this.event,
    this.big = false,
    this.wordWrap = false,
    this.showDate = false,
  });

  final DayEvent event;
  final bool big;
  final bool wordWrap;
  final bool showDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      key: Key('event_${event.id}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (showDate)
                  Text(l.dateMonthDay(event.date),
                      key: Key('event_date_${event.id}'),
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: theme.colorScheme.primary)),
                if (event.isCountrySpecific) ...[
                  if (showDate) const SizedBox(width: 8),
                  Text(l.todayCountry, style: theme.textTheme.labelSmall),
                ],
              ],
            ),
            WrapText(event.title,
                wordWrap: wordWrap,
                style: big ? theme.textTheme.titleLarge : theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            WrapText(event.body, wordWrap: wordWrap, style: theme.textTheme.bodyMedium),
            if (event.factId != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: Key('event_read_${event.id}'),
                  onPressed: () => context.push('/detail/${event.factId}'),
                  child: Text(l.mythRead),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
