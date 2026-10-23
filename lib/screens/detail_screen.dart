import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/age_band.dart';
import '../services/tts.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/illustration.dart';

class DetailScreen extends ConsumerWidget {
  const DetailScreen({super.key, required this.triviaId});

  final String triviaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final item = ref.watch(triviaRepositoryProvider).byId(triviaId);
    final level = item == null ? null : ref.watch(levelResolverProvider)(item);
    if (item == null || level == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l.emptyFeed)));
    }

    final settings = ref.watch(settingsProvider);
    final band = settings.ageBand ?? AgeBand.adult;
    final notifier = ref.read(settingsProvider.notifier);
    final saved = settings.saved.contains(item.id);
    final ratings = settings.ratings[item.id] ?? const <Rating>{};
    final lang = ref.watch(contentLanguageProvider);
    final theme = Theme.of(context);

    String ratingLabel(Rating r) => switch (r) {
          Rating.heh => l.ratingHeh,
          Rating.useful => l.ratingUseful,
          Rating.wow => l.ratingWow,
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
              if (band.isTeenOrAdult)
                for (final s in item.scenes) Chip(label: Text(sceneLabel(l, s))),
            ]),
            const SizedBox(height: 12),
            Text(level.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(level.body, style: theme.textTheme.bodyLarge?.copyWith(height: 1.6)),
            const SizedBox(height: 24),
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
            Row(
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
                const SizedBox(width: 12),
                // 外部への共有は Teen 以上のみ（Kids/Junior では出さない）。
                if (band.isTeenOrAdult)
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
