import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/trivia_repository.dart';
import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/age_band.dart';
import '../models/trivia.dart';
import '../services/tts.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/illustration.dart';
import '../widgets/ja_wrap_text.dart';
import '../widgets/quiz_sheet.dart';

class DetailScreen extends ConsumerStatefulWidget {
  const DetailScreen({super.key, required this.triviaId});

  final String triviaId;

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
                .speak('${level.title}。${level.body}', language: lang),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
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
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  key: const Key('knew_it'),
                  label: Text(l.knewIt),
                  selected: knowledge == Knowledge.knew,
                  onSelected: (_) => notifier.setKnowledge(item.id, Knowledge.knew),
                ),
                ChoiceChip(
                  key: const Key('learned_it'),
                  label: Text(l.learnedIt),
                  selected: knowledge == Knowledge.learned,
                  onSelected: (_) => notifier.setKnowledge(item.id, Knowledge.learned),
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
          ],
        ),
      ),
    );
  }
}
