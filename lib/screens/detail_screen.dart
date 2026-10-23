import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/trivia_repository.dart';
import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../logic/readings.dart';
import '../models/age_band.dart';
import '../models/trivia.dart';
import '../models/why_link.dart';
import '../services/tts.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/illustration.dart';
import '../widgets/ja_wrap_text.dart';
import '../widgets/quiz_sheet.dart';
import '../widgets/share_card.dart';

class DetailScreen extends ConsumerStatefulWidget {
  const DetailScreen({super.key, required this.triviaId, this.chain = 0});

  final String triviaId;

  /// 「なぜ？」を何回つなげてここに来たか。
  final int chain;

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  /// 親子モード: Teen/Adult が「こどもに説明するなら」で別の年代の説明を読む。null なら自分の年代。
  AgeBand? _viewBand;
  bool _bilingual = false;

  @override
  void initState() {
    super.initState();
    // 読んだ日を記録（Teen/Adult のストリーク用。Kids/Junior は記録しない）。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsProvider.notifier).markSeen(widget.triviaId);
      final band = ref.read(settingsProvider).ageBand;
      if (band != null && band.isTeenOrAdult) {
        ref.read(settingsProvider.notifier).markRead(ref.read(nowProvider));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final repo = ref.watch(triviaRepositoryProvider);
    final item = repo.byId(widget.triviaId);
    final settings = ref.watch(settingsProvider);
    final ownBand = settings.ageBand ?? AgeBand.adult;
    final lang = ref.watch(contentLanguageProvider);
    final shownBand = _viewBand ?? ownBand;

    TriviaLevel? levelFor(AgeBand band, String language) =>
        item?.levelFor(band, language, allowDraft: kAllowDraftContent);
    TriviaLevel? levelFor2(Trivia t, AgeBand band, String language) =>
        t.levelFor(band, language, allowDraft: kAllowDraftContent);

    final level = levelFor(shownBand, lang);
    if (item == null || level == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l.emptyFeed)));
    }

    final notifier = ref.read(settingsProvider.notifier);
    final saved = settings.saved.contains(item.id);
    final ratings = settings.ratings[item.id] ?? const <Rating>{};
    final knowledge = settings.knowledge[item.id];
    final theme = Theme.of(context);

    // 親子モード: 自分より下の年代の説明があるときだけ切り替えを出す。
    final childBands = [
      for (final b in [AgeBand.junior, AgeBand.kids])
        if (ownBand.isTeenOrAdult && levelFor(b, lang) != null) b,
    ];

    // 二言語: もう一つの言語の本文（Kids 以外）。
    final otherLang = lang == 'ja' ? 'en' : 'ja';
    final otherTranslation = item.translations[otherLang];
    final otherLevel = (ownBand != AgeBand.kids &&
            otherTranslation != null &&
            otherTranslation.isShippable(allowDraft: kAllowDraftContent))
        ? levelFor(shownBand, otherLang)
        : null;

    final quiz = ownBand.isChild ? repo.quizFor(item.id) : null;
    final why = ref.watch(whyStepProvider(item.id));
    final project = ownBand == AgeBand.kids ? null : ref.watch(projectForFactProvider(item.id));

    // 関連する雑学（この年代・言語・国で表示できるものだけ）。
    final region = ref.watch(regionProvider);
    final related = [
      for (final id in item.related)
        if (repo.byId(id) case final r?)
          if (r.allowedInRegion(region.code, anyRegion: region.any) &&
              levelFor2(r, ownBand, lang) != null)
            r,
    ];
    TriviaLevel? relatedLevel(Trivia r) => levelFor2(r, ownBand, lang);

    String ratingLabel(Rating r) => switch (r) {
          Rating.heh => l.ratingHeh,
          Rating.useful => l.ratingUseful,
          Rating.wow => l.ratingWow,
        };
    String viewLabel(AgeBand? b) => switch (b) {
          null => l.viewOwn,
          AgeBand.junior => l.viewJunior,
          AgeBand.kids => l.viewKids,
          _ => l.viewOwn,
        };

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            key: const Key('detail_listen'),
            icon: const Icon(Icons.volume_up),
            tooltip: l.kidsListen,
            onPressed: () => ref
                .read(ttsProvider)
                .speak(stripReadings('${level.title}。${level.body}'), language: lang),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (widget.chain >= whyChainCheerAt)
              Card(
                key: const Key('why_cheer'),
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(l.whyCheer(widget.chain),
                      textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
                ),
              ),
            Center(child: TriviaIllustration(id: item.illustration, size: 96)),
            const SizedBox(height: 16),
            Wrap(spacing: 8, children: [
              Chip(label: Text(categoryLabel(l, item.category))),
              if (ownBand.isTeenOrAdult)
                for (final s in item.scenes) Chip(label: Text(sceneLabel(l, s))),
            ]),
            if (childBands.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(l.explainToKids, style: theme.textTheme.labelMedium),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: [
                  for (final b in [null, ...childBands])
                    ChoiceChip(
                      key: Key('view_${b?.name ?? 'own'}'),
                      label: Text(viewLabel(b)),
                      selected: _viewBand == b,
                      onSelected: (_) => setState(() => _viewBand = b),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            // 就学前・小学生向けの日本語は、単語の途中で折り返さない。
            WrapText(level.title,
                key: const Key('detail_title'),
                wordWrap: lang == 'ja' && shownBand.isChild,
                style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            WrapText(level.body,
                wordWrap: lang == 'ja' && shownBand.isChild,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.6)),
            if (why != null) ...[
              const SizedBox(height: 16),
              Card(
                key: const Key('why_card'),
                color: theme.colorScheme.secondaryContainer,
                child: InkWell(
                  onTap: () => context.push('/detail/${why.target.id}?chain=${widget.chain + 1}'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(l.whyButton,
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: WrapText(why.question,
                              key: const Key('why_question'),
                              wordWrap: lang == 'ja' && ownBand.isChild,
                              style: theme.textTheme.bodyLarge),
                        ),
                        const Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (otherLevel != null && otherLevel.title != level.title) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                key: const Key('bilingual_toggle'),
                icon: const Icon(Icons.translate),
                label: Text(_bilingual ? l.bilingualOff : l.bilingualOn),
                onPressed: () => setState(() => _bilingual = !_bilingual),
              ),
              if (_bilingual) ...[
                Text(otherLevel.title,
                    key: const Key('bilingual_title'), style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(otherLevel.body,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
              ],
            ],
            // 雑学で英語: ことばの対訳と、もう一つの言語での読み上げ（Kids を除く）。
            if (ownBand != AgeBand.kids && (item.vocab.isNotEmpty || otherLevel != null)) ...[
              const SizedBox(height: 16),
              if (otherLevel != null)
                OutlinedButton.icon(
                  key: const Key('listen_other'),
                  icon: const Icon(Icons.record_voice_over_outlined),
                  label: Text(otherLang == 'en' ? l.listenInEnglish : l.listenInJapanese),
                  onPressed: () => ref.read(ttsProvider).speak(
                        stripReadings('${otherLevel.title}。${otherLevel.body}'),
                        language: otherLang,
                        rate: 0.35,
                      ),
                ),
              if (item.vocab.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(lang == 'ja' ? l.vocabEnglishTitle : l.vocabJapaneseTitle,
                    key: const Key('vocab_title'), style: theme.textTheme.titleSmall),
                Text(l.vocabTapToHear, style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Card(
                  key: const Key('vocab_section'),
                  child: Column(
                    children: [
                      for (final v in item.vocab)
                        ListTile(
                          key: Key('vocab_${v.en}'),
                          dense: true,
                          title: Text(lang == 'ja' ? v.en : _jaWord(v, ownBand)),
                          subtitle: Text(lang == 'ja' ? _jaWord(v, ownBand) : v.en),
                          trailing: const Icon(Icons.volume_up_outlined),
                          onTap: () => ref.read(ttsProvider).speak(
                                lang == 'ja' ? v.en : v.ja,
                                language: lang == 'ja' ? 'en' : 'ja',
                                rate: 0.35,
                              ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  key: const Key('knew_it'),
                  label: Text(l.knewIt),
                  selected: knowledge == Knowledge.knew,
                  onSelected: (_) => notifier.setKnowledge(item.id, Knowledge.knew, today: ref.read(nowProvider)),
                ),
                ChoiceChip(
                  key: const Key('learned_it'),
                  label: Text(l.learnedIt),
                  selected: knowledge == Knowledge.learned,
                  onSelected: (_) => notifier.setKnowledge(item.id, Knowledge.learned, today: ref.read(nowProvider)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final r in Rating.values)
                  FilterChip(
                    key: Key('rating_${r.name}'),
                    label: Text(ratingLabel(r)),
                    selected: ratings.contains(r),
                    onSelected: (_) => notifier.toggleRating(item.id, r),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  key: const Key('save_button'),
                  icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
                  label: Text(saved ? l.unsave : l.save),
                  onPressed: () {
                    final ok = notifier.toggleSaved(
                      item.id,
                      isPremium: ref.read(isPremiumNowProvider),
                    );
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.savedLimit(freeSaveLimit))),
                      );
                    }
                  },
                ),
                // 外部への共有は Teen 以上のみ（Kids/Junior では出さない）。
                if (ownBand.isTeenOrAdult)
                  OutlinedButton.icon(
                    key: const Key('copy_button'),
                    icon: const Icon(Icons.copy),
                    label: Text(l.copy),
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: '${level.title}\n${level.body}'));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(l.copied)));
                      }
                    },
                  ),
                if (ownBand.isTeenOrAdult)
                  OutlinedButton.icon(
                    key: const Key('share_button'),
                    icon: const Icon(Icons.ios_share),
                    label: Text(l.shareImage),
                    onPressed: () => showShareSheet(
                      context,
                      illustration: item.illustration,
                      title: level.title,
                      body: level.body,
                    ),
                  ),
                if (project != null)
                  FilledButton.tonalIcon(
                    key: const Key('open_project_from_fact'),
                    icon: const Icon(Icons.science_outlined),
                    label: Text(l.projectFromFact),
                    onPressed: () => context.push('/project/${project.id}'),
                  ),
                if (quiz != null)
                  FilledButton.icon(
                    key: const Key('quiz_button'),
                    icon: const Icon(Icons.quiz_outlined),
                    label: Text(l.quizButton),
                    onPressed: () => showQuizSheet(
                      context,
                      quiz: quiz,
                      language: lang,
                      explanation: level.body,
                    ),
                  ),
              ],
            ),
            if (ownBand.isTeenOrAdult && item.sources.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(l.sourcesSection,
                  key: const Key('sources_title'), style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              for (final src in item.sources)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    src.publisher.isEmpty ? src.title : '${src.title}（${src.publisher}）',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
            ],
            if (related.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(l.relatedSection, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              for (final r in related)
                if (levelFor(shownBand, lang) != null && relatedLevel(r) != null)
                  Card(
                    key: Key('related_${r.id}'),
                    child: ListTile(
                      leading: TriviaIllustration(id: r.illustration, size: 28),
                      title: Text(relatedLevel(r)!.title),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/detail/${r.id}'),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 日本語のことばの表示。Teen/Adult は漢字も添える（「たこ（蛸）」）。Junior は、かなだけ。
String _jaWord(VocabEntry v, AgeBand band) =>
    band.isTeenOrAdult && v.kanji.isNotEmpty ? '${v.ja}（${v.kanji}）' : v.ja;

