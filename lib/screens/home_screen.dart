import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/age_band.dart';
import '../models/trivia.dart';
import '../services/tts.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/illustration.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final band = ref.watch(settingsProvider.select((s) => s.ageBand)) ?? AgeBand.adult;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.appName),
        actions: [
          if (!band.isChild || band == AgeBand.junior)
            IconButton(
              tooltip: l.savedTitle,
              icon: const Icon(Icons.bookmark_border),
              onPressed: () => context.push('/saved'),
            ),
          IconButton(
            key: const Key('open_settings'),
            tooltip: l.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: band == AgeBand.kids ? const _KidsHome() : const _FeedHome(),
      ),
    );
  }
}

/// Kids: 1画面に1つの雑学。大きな絵と読み上げ。
class _KidsHome extends ConsumerStatefulWidget {
  const _KidsHome();

  @override
  ConsumerState<_KidsHome> createState() => _KidsHomeState();
}

class _KidsHomeState extends ConsumerState<_KidsHome> {
  int _index = 0;
  late final TtsService _tts;

  @override
  void initState() {
    super.initState();
    _tts = ref.read(ttsProvider);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final feed = ref.watch(feedProvider);
    final resolve = ref.watch(levelResolverProvider);
    if (feed.isEmpty) return Center(child: Text(l.emptyFeed));
    final item = feed[_index % feed.length];
    final level = resolve(item);
    if (level == null) return Center(child: Text(l.emptyFeed));
    final lang = ref.watch(contentLanguageProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TriviaIllustration(id: item.illustration, size: 120),
                  const SizedBox(height: 16),
                  Text(level.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(level.body,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  key: const Key('kids_listen'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(64)),
                  icon: const Icon(Icons.volume_up, size: 32),
                  label: Text(l.kidsListen, style: const TextStyle(fontSize: 20)),
                  onPressed: () => ref
                      .read(ttsProvider)
                      .speak('${level.title}。${level.body}', language: lang),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  key: const Key('kids_next'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(64)),
                  icon: const Icon(Icons.arrow_forward, size: 32),
                  label: Text(l.kidsNext, style: const TextStyle(fontSize: 20)),
                  onPressed: () {
                    ref.read(ttsProvider).stop();
                    setState(() => _index++);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Junior / Teen / Adult: 一覧。
class _FeedHome extends ConsumerWidget {
  const _FeedHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final band = settings.ageBand ?? AgeBand.adult;
    final notifier = ref.read(settingsProvider.notifier);
    final feed = ref.watch(feedProvider);
    final resolve = ref.watch(levelResolverProvider);
    final premium = ref.watch(isPremiumNowProvider);

    final hasFilter = settings.categories.isNotEmpty || settings.scenes.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final c in allCategories)
              FilterChip(
                label: Text(categoryLabel(l, c)),
                selected: settings.categories.contains(c),
                onSelected: (_) => notifier.toggleCategory(c),
              ),
            if (band.isTeenOrAdult)
              for (final s in allScenes)
                FilterChip(
                  label: Text(sceneLabel(l, s)),
                  selected: settings.scenes.contains(s),
                  onSelected: (_) => notifier.toggleScene(s),
                ),
            if (hasFilter)
              TextButton(onPressed: notifier.clearFilters, child: Text(l.filterReset)),
          ],
        ),
        const SizedBox(height: 12),
        if (feed.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(child: Text(l.emptyFeed)),
          )
        else ...[
          Text(l.today, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          _TriviaCard(item: feed.first, level: resolve(feed.first)!, big: true),
          if (feed.length > 1) ...[
            const SizedBox(height: 16),
            Text(l.past, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final t in feed.skip(1))
              if (resolve(t) case final level?) _TriviaCard(item: t, level: level),
          ],
        ],
        if (band.isTeenOrAdult && !premium)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              key: const Key('locked_note'),
              icon: const Icon(Icons.lock_outline),
              label: Text(l.lockedFeedNote),
              onPressed: () => context.push('/premium'),
            ),
          ),
      ],
    );
  }
}

class _TriviaCard extends StatelessWidget {
  const _TriviaCard({required this.item, required this.level, this.big = false});

  final Trivia item;
  final TriviaLevel level;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      child: InkWell(
        onTap: () => context.push('/detail/${item.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              TriviaIllustration(id: item.illustration, size: big ? 56 : 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(categoryLabel(l, item.category),
                        style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Text(level.title,
                        style: big
                            ? Theme.of(context).textTheme.titleLarge
                            : Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
