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
import '../widgets/flip_card.dart';
import '../widgets/ja_wrap_text.dart';
import '../widgets/mascot_card.dart';
import '../widgets/parental_gate.dart';
import '../widgets/quiz_sheet.dart';
import '../logic/streak.dart';
import 'solo_quiz_screens.dart';
import '../models/why_link.dart';
import '../logic/timing.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final band = ref.watch(settingsProvider.select((s) => s.ageBand)) ?? AgeBand.adult;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🦉', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(l.appName),
          ],
        ),
        actions: [
          // Kids は下のタブに設定がない。保護者ゲートの先に置く。
          if (band == AgeBand.kids)
            IconButton(
              key: const Key('open_settings'),
              tooltip: l.settingsTitle,
              icon: const Icon(Icons.settings_outlined),
              onPressed: () async {
                if (!await showParentalGate(context)) return;
                if (context.mounted) context.push('/settings');
              },
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

  /// 「なぜ？」で別の雑学に移っているとき、その雑学。「つぎへ」で元の並びに戻る。
  Trivia? _override;
  int _whyCount = 0;
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
    final item = _override ?? feed[_index % feed.length];
    final level = resolve(item);
    final why = ref.watch(whyStepProvider(item.id));
    if (level == null) return Center(child: Text(l.emptyFeed));
    final lang = ref.watch(contentLanguageProvider);
    // 見た雑学として記録する（相棒の成長用）。
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(settingsProvider.notifier).markSeen(item.id));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const MascotCard(),
                  const _ReviewBanner(),
                  const SizedBox(height: 16),
                  TriviaIllustration(id: item.illustration, size: 120),
                  const SizedBox(height: 16),
                  WrapText(level.title,
                      key: const Key('kids_title'),
                      wordWrap: lang == 'ja',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  WrapText(level.body,
                      wordWrap: lang == 'ja',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_whyCount >= whyChainCheerAt)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(l.whyCheer(_whyCount),
                  key: const Key('why_cheer'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          if (why != null) ...[
            OutlinedButton(
              key: const Key('kids_why'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(64)),
              onPressed: () {
                ref.read(ttsProvider).stop();
                setState(() {
                  _override = why.target;
                  _whyCount++;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l.whyButton,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Flexible(
                    child: WrapText(why.question,
                        wordWrap: lang == 'ja',
                        style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (ref.watch(triviaRepositoryProvider).quizFor(item.id) case final quiz?) ...[
            FilledButton.icon(
              key: const Key('quiz_button'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(64)),
              icon: const Icon(Icons.quiz_outlined, size: 32),
              label: Text(l.quizButton, style: const TextStyle(fontSize: 20)),
              onPressed: () => showQuizSheet(
                context,
                quiz: quiz,
                language: lang,
                explanation: level.body,
              ),
            ),
            const SizedBox(height: 12),
          ],
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
                    setState(() {
                      _index++;
                      _override = null;
                      _whyCount = 0;
                    });
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
    // Kids/Junior の日本語は、単語の途中で折り返さない。
    final wordWrap = band.isChild && ref.watch(contentLanguageProvider) == 'ja';

    final hasFilter = settings.categories.isNotEmpty || settings.scenes.isNotEmpty;

    final streak = band.isTeenOrAdult
        ? computeStreak(settings.readDays, ref.watch(nowProvider))
        : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const MascotCard(),
        const _ReviewBanner(),
        if (streak != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  streak.current > 0
                      ? l.streakDays(streak.current)
                      : l.streakStart,
                  key: const Key('streak_label'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (streak.hasFreeze) ...[
                  const SizedBox(width: 8),
                  Chip(
                    key: const Key('streak_freeze'),
                    label: Text(l.streakFreeze),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
          ),
        // 絞り込みはボタンからシートで選ぶ（チップを並べると一覧が画面の下に押し出されるため）。
        Row(
          children: [
            FilledButton.tonalIcon(
              key: const Key('filter_button'),
              icon: const Icon(Icons.filter_list),
              label: Text(hasFilter
                  ? l.filterButtonActive(settings.categories.length + settings.scenes.length)
                  : l.filterButton),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => const _FilterSheet(),
              ),
            ),
            if (hasFilter)
              TextButton(onPressed: notifier.clearFilters, child: Text(l.filterReset)),
          ],
        ),
        const SizedBox(height: 12),
        const _TodayBanner(),
        if (feed.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(child: Text(l.emptyFeed)),
          )
        else ...[
          Text(l.today, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          FlipTodayCard(
            item: feed.first,
            level: resolve(feed.first)!,
            wordWrap: wordWrap,
          ),
          const SizedBox(height: 16),
          const _TimingSection(),
          const _InterestSection(),
          if (feed.length > 1) ...[
            const SizedBox(height: 16),
            Text(l.past, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final t in feed.skip(1))
              if (resolve(t) case final level?)
                _TriviaCard(item: t, level: level, wordWrap: wordWrap),
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
  const _TriviaCard({
    required this.item,
    required this.level,
    this.wordWrap = false,
    this.badge,
  });

  final Trivia item;
  final TriviaLevel level;
  final bool wordWrap;

  /// 「夏にぴったり」「今日は記念日」など、おすすめの理由。あればカテゴリーの代わりに出す。
  final String? badge;

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
              TriviaIllustration(id: item.illustration, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(badge ?? categoryLabel(l, item.category),
                        key: badge == null ? null : const Key('reason_badge'),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: badge == null
                                ? null
                                : Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 4),
                    WrapText(level.title,
                        wordWrap: wordWrap,
                        style: Theme.of(context).textTheme.titleMedium),
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

/// 絞り込みシート。カテゴリー同士・シーン同士は OR、カテゴリーとシーンは AND。
class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final band = settings.ageBand ?? AgeBand.adult;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in allCategories)
                  FilterChip(
                    label: Text(categoryLabel(l, c)),
                    selected: settings.categories.contains(c),
                    onSelected: (_) => notifier.toggleCategory(c),
                  ),
              ],
            ),
            if (band.isTeenOrAdult) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in allScenes)
                    FilterChip(
                      label: Text(sceneLabel(l, s)),
                      selected: settings.scenes.contains(s),
                      onSelected: (_) => notifier.toggleScene(s),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 「あなたの関心」: 登録した関心事に当てはまる雑学を、日替わりで出す。
class _InterestSection extends ConsumerWidget {
  const _InterestSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final picks = ref.watch(interestPicksProvider);
    final resolve = ref.watch(levelResolverProvider);
    final band = settings.ageBand ?? AgeBand.adult;
    final wordWrap = band.isChild && ref.watch(contentLanguageProvider) == 'ja';
    final theme = Theme.of(context);

    Widget header({bool edit = true}) => Row(
          children: [
            Expanded(child: Text(l.interestsSection, style: theme.textTheme.titleSmall)),
            if (edit)
              TextButton(
                key: const Key('interests_edit'),
                onPressed: () => context.push('/interests'),
                child: Text(l.interestsEdit),
              ),
          ],
        );

    if (settings.interests.isEmpty) {
      return Card(
        key: const Key('interests_empty'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header(edit: false),
              const SizedBox(height: 4),
              Text(l.interestsEmptyTitle),
              const SizedBox(height: 8),
              FilledButton.tonal(
                key: const Key('interests_register'),
                onPressed: () => context.push('/interests'),
                child: Text(l.interestsRegister),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      key: const Key('interests_section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header(),
        if (picks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l.interestsNoMatch),
          )
        else
          for (final t in picks)
            if (resolve(t) case final level?)
              _TriviaCard(item: t, level: level, wordWrap: wordWrap),
      ],
    );
  }
}

String seasonLabel(AppLocalizations l, Season s) => switch (s) {
      Season.spring => l.seasonSpring,
      Season.summer => l.seasonSummer,
      Season.autumn => l.seasonAutumn,
      Season.winter => l.seasonWinter,
    };

String reasonLabel(AppLocalizations l, TimingReason r, Season? season) => switch (r) {
      TimingReason.date => l.reasonDate,
      TimingReason.season => l.reasonSeason(season == null ? '' : seasonLabel(l, season)),
      TimingReason.night => l.reasonNight,
      TimingReason.morning => l.reasonMorning,
      TimingReason.evening => l.reasonEvening,
      TimingReason.weekend => l.reasonWeekend,
    };

/// 「いまのおすすめ」: 季節・時間帯・記念日・週末に合う雑学を、理由つきで出す。
class _TimingSection extends ConsumerWidget {
  const _TimingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final picks = ref.watch(timingPicksProvider);
    if (picks.isEmpty) return const SizedBox.shrink();
    final resolve = ref.watch(levelResolverProvider);
    final band = ref.watch(settingsProvider.select((s) => s.ageBand)) ?? AgeBand.adult;
    final wordWrap = band.isChild && ref.watch(contentLanguageProvider) == 'ja';
    final hemisphere = ref.watch(hemisphereProvider);
    final season = hemisphere == null ? null : seasonFor(ref.watch(nowProvider), hemisphere);

    return Column(
      key: const Key('timing_section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.timingSection, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final p in picks)
          if (resolve(p.fact) case final level?)
            _TriviaCard(
              item: p.fact,
              level: level,
              wordWrap: wordWrap,
              badge: reasonLabel(l, p.reason, season),
            ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// 今日が記念日のとき、一覧の先頭に「今日は「〇〇」」を出す。タップで「今日は何の日」へ。
class _TodayBanner extends ConsumerWidget {
  const _TodayBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final events = ref.watch(todayEventsProvider);
    if (events.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final more = events.length - 1;
    return Card(
      key: const Key('today_banner'),
      color: theme.colorScheme.tertiaryContainer,
      child: ListTile(
        leading: const Icon(Icons.event),
        title: Text(l.todayBanner(events.first.title)),
        subtitle: more > 0 ? Text('+$more') : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/today'),
      ),
    );
  }
}

/// 今日のおさらいがあるときだけ出す、ホームのお知らせ。
class _ReviewBanner extends ConsumerWidget {
  const _ReviewBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final due = ref.watch(reviewQuestionsProvider).length;
    if (due == 0) return const SizedBox.shrink();
    return Card(
      child: ListTile(
        key: const Key('review_banner'),
        leading: const Text('🔁', style: TextStyle(fontSize: 28)),
        title: Text(l.reviewChipCount(due)),
        subtitle: Text(l.hubReviewSub),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => context.push('/review'),
      ),
    );
  }
}
