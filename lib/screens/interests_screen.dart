import '../state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/age_band.dart';
import '../state/settings.dart';

/// 関心事の登録。ジャンル・シーン・キーワードを登録すると、ホームの「あなたの関心」に当てはまる雑学が出る。
/// 端末内にだけ保存する。
class InterestsScreen extends ConsumerStatefulWidget {
  const InterestsScreen({super.key});

  @override
  ConsumerState<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends ConsumerState<InterestsScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final l = AppLocalizations.of(context);
    final notifier = ref.read(settingsProvider.notifier);
    if (ref.read(settingsProvider).interestKeywords.length >=
        maxInterestKeywords) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.interestsMax(maxInterestKeywords))),
      );
      return;
    }
    if (notifier.addInterestKeyword(_controller.text)) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final band = settings.ageBand ?? AgeBand.adult;
    final theme = Theme.of(context);

    Widget header(String text) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(text, style: theme.textTheme.titleSmall),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.interestsScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(l.interestsNote, style: theme.textTheme.bodySmall),
          header(l.interestsCategories),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in ref.watch(categoryIdsProvider))
                FilterChip(
                  key: Key('interest_cat_$c'),
                  label: Text(categoryLabel(l, c)),
                  selected: settings.interestCategories.contains(c),
                  onSelected: (_) => notifier.toggleInterestCategory(c),
                ),
            ],
          ),
          if (band.isTeenOrAdult) ...[
            header(l.interestsScenes),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in allScenes)
                  FilterChip(
                    key: Key('interest_scene_$s'),
                    label: Text(sceneLabel(l, s)),
                    selected: settings.interestScenes.contains(s),
                    onSelected: (_) => notifier.toggleInterestScene(s),
                  ),
              ],
            ),
          ],
          header(l.interestsKeywords),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('keyword_field'),
                  controller: _controller,
                  maxLength: maxInterestKeywordLength,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: l.interestsKeywordHint,
                    counterText: '',
                  ),
                  onSubmitted: (_) => _add(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                key: const Key('keyword_add'),
                onPressed: _add,
                child: Text(l.interestsAdd),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final k in settings.interestKeywords)
                InputChip(
                  key: Key('keyword_$k'),
                  label: Text(k),
                  onDeleted: () => notifier.removeInterestKeyword(k),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
