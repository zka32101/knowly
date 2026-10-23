import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../models/age_band.dart';
import '../state/settings.dart';

/// 下のタブ。Kids は「ホーム・あそぶ・あつめる」の3つ（設定は保護者ゲートの先）、
/// それ以外は「ホーム・あそぶ・あつめる・さがす・設定」の5つ。
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final band = ref.watch(settingsProvider.select((s) => s.ageBand)) ?? AgeBand.adult;
    final kids = band == AgeBand.kids;

    final items = <({Key key, Widget icon, Widget selected, String label})>[
      (
        key: const Key('tab_home'),
        icon: const Icon(Icons.home_outlined),
        selected: const Icon(Icons.home),
        label: l.tabHome,
      ),
      (
        key: const Key('tab_play'),
        icon: const Icon(Icons.sports_esports_outlined),
        selected: const Icon(Icons.sports_esports),
        label: l.tabPlay,
      ),
      (
        key: const Key('tab_collect'),
        icon: const Icon(Icons.emoji_events_outlined),
        selected: const Icon(Icons.emoji_events),
        label: l.tabCollect,
      ),
      if (!kids) ...[
        (
          key: const Key('tab_explore'),
          icon: const Icon(Icons.search),
          selected: const Icon(Icons.search),
          label: l.tabExplore,
        ),
        (
          key: const Key('open_settings'),
          icon: const Icon(Icons.settings_outlined),
          selected: const Icon(Icons.settings),
          label: l.tabSettings,
        ),
      ],
    ];

    // Kids に切り替わったとき、存在しないタブにいたらホームへ戻す。
    final index = shell.currentIndex < items.length ? shell.currentIndex : 0;

    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          for (final it in items)
            NavigationDestination(
              key: it.key,
              icon: it.icon,
              selectedIcon: it.selected,
              label: it.label,
            ),
        ],
      ),
    );
  }
}
