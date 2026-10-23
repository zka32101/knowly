import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../state/listen_controller.dart';
import '../state/providers.dart';
import '../widgets/illustration.dart';

/// ながら聞き: 雑学を順番に連続で読み上げる（Teen/Adult）。画面を開いたまま使う。
class ListenScreen extends ConsumerWidget {
  const ListenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    ref.watch(listenBackgroundSyncProvider);
    final state = ref.watch(listenControllerProvider);
    final controller = ref.read(listenControllerProvider.notifier);
    final resolve = ref.watch(levelResolverProvider);
    final theme = Theme.of(context);
    final current = state.current;
    final level = current == null ? null : resolve(current);

    if (current == null || level == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.listenTitle)),
        body: Center(child: Text(l.listenEmpty)),
      );
    }

    String speedLabel(ListenSpeed s) => switch (s) {
          ListenSpeed.slow => l.listenSlow,
          ListenSpeed.normal => l.listenNormal,
          ListenSpeed.fast => l.listenFast,
        };

    return Scaffold(
      appBar: AppBar(title: Text(l.listenTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Center(child: TriviaIllustration(id: current.illustration, size: 96)),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      '${state.index + 1} / ${state.queue.length}',
                      key: const Key('listen_progress'),
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(categoryLabel(l, current.category),
                      textAlign: TextAlign.center, style: theme.textTheme.labelMedium),
                  Text(level.title,
                      key: const Key('listen_title'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  if (state.finished)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(l.listenFinished,
                          key: const Key('listen_finished'),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        key: const Key('listen_prev'),
                        iconSize: 40,
                        tooltip: l.listenPrev,
                        icon: const Icon(Icons.skip_previous),
                        onPressed: state.index > 0 ? controller.previous : null,
                      ),
                      const SizedBox(width: 16),
                      IconButton.filled(
                        key: const Key('listen_toggle'),
                        iconSize: 56,
                        tooltip: state.playing ? l.listenPause : l.listenPlay,
                        icon: Icon(state.playing ? Icons.pause : Icons.play_arrow),
                        onPressed: controller.toggle,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        key: const Key('listen_next'),
                        iconSize: 40,
                        tooltip: l.listenNext,
                        icon: const Icon(Icons.skip_next),
                        onPressed: state.index + 1 < state.queue.length ? controller.next : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(l.listenSpeedLabel, style: theme.textTheme.labelMedium),
                  const SizedBox(height: 4),
                  SegmentedButton<ListenSpeed>(
                    key: const Key('listen_speed'),
                    showSelectedIcon: false,
                    segments: [
                      for (final s in ListenSpeed.values)
                        ButtonSegment(value: s, label: Text(speedLabel(s))),
                    ],
                    selected: {state.speed},
                    onSelectionChanged: (v) => controller.setSpeed(v.first),
                  ),
                  const SizedBox(height: 8),
                  Text(l.listenNote, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 16),
                  for (var i = 0; i < state.queue.length; i++)
                    if (resolve(state.queue[i]) case final item?)
                      ListTile(
                        key: Key('listen_item_$i'),
                        dense: true,
                        selected: i == state.index,
                        leading: TriviaIllustration(
                            id: state.queue[i].illustration, size: 24),
                        title: Text(item.title),
                        onTap: () => controller.jumpTo(i),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
