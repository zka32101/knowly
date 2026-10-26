import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/trivia_repository.dart';
import '../l10n/app_localizations.dart';
import '../logic/glossary.dart';
import '../models/age_band.dart';
import '../models/trivia.dart';
import '../services/tts.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/share_cards.dart';
import '../widgets/share_sheet.dart';

/// この用語が出てくる、いま表示できる雑学（この年代・言語・国のもの）。
final wordFactsProvider = Provider.family<List<Trivia>, String>((ref, id) {
  final repo = ref.watch(triviaRepositoryProvider);
  final entry = repo.glossaryEntry(id);
  final lang = ref.watch(contentLanguageProvider);
  final band = ref.watch(settingsProvider.select((s) => s.ageBand)) ?? AgeBand.adult;
  if (entry == null) return const [];
  return [
    for (final t in ref.watch(allEligibleProvider))
      if (t.levelFor(band, lang, allowDraft: kAllowDraftContent) case final level?)
        if (segmentGlossary(level.body, [entry], lang).any((s) => s.entryId == id)) t,
  ];
});

/// 用語の説明（サブ画面）。やさしい説明を先に、そのあとにくわしい説明。出てくる雑学へも進める。
class WordScreen extends ConsumerWidget {
  const WordScreen({super.key, required this.entryId});
  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lang = ref.watch(contentLanguageProvider);
    final band = ref.watch(settingsProvider.select((s) => s.ageBand)) ?? AgeBand.adult;
    final entry = ref.watch(triviaRepositoryProvider).glossaryEntry(entryId);
    final text = entry?.forLanguage(lang);
    if (entry == null || text == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l.wordNotFound)));
    }
    // 見たことばは、ことばずかんに載る。
    final notifier = ref.read(settingsProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 画面がすぐ閉じられても、いまの notifier（閉じた後の ref ではなく）に記録する。
      notifier.markWordSeen(entryId);
    });
    final facts = ref.watch(wordFactsProvider(entryId));
    final resolve = ref.watch(levelResolverProvider);
    // 子ども（Junior）にはやさしい説明だけ。Teen/Adult にはくわしい説明も。
    final showDetail = band.isTeenOrAdult && text.detail.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.wordTitle),
        actions: [
          ShareButton(
            buttonKey: const Key('word_share'),
            compact: true,
            text: '${text.term} - ${text.simple}\n#${l.appName}',
            card: ShareFrame(appName: l.appName, children: [
              bigEmoji('📚'),
              gap8,
              cardTitle(text.term),
              gap12,
              cardBody(text.simple, size: 16),
            ]),
          ),
          IconButton(
            key: const Key('word_listen'),
            icon: const Icon(Icons.volume_up),
            tooltip: l.kidsListen,
            onPressed: () => ref.read(ttsProvider).speak(
                  '${text.term}。${text.simple}${showDetail ? text.detail : ''}',
                  language: lang,
                ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(text.term,
                key: const Key('word_term'), style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.wordSimple, style: theme.textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text(text.simple,
                        key: const Key('word_simple'),
                        style: theme.textTheme.titleMedium?.copyWith(height: 1.5)),
                  ],
                ),
              ),
            ),
            if (showDetail) ...[
              const SizedBox(height: 16),
              Text(l.wordDetail, style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(text.detail,
                  key: const Key('word_detail'),
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6)),
            ],
            if (facts.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(l.wordFacts, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              for (final t in facts)
                if (resolve(t) case final level?)
                  Card(
                    key: Key('word_fact_${t.id}'),
                    child: ListTile(
                      title: Text(level.title),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/detail/${t.id}'),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
