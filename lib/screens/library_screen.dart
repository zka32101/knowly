import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../logic/search.dart';
import '../models/age_band.dart';
import '../models/trivia.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/illustration.dart';
import '../widgets/ja_wrap_text.dart';

/// 保存・評価の状態での絞り込み。
enum StatusFilter { saved, knew, learned, unrated }

/// ライブラリ: すべての雑学を、検索とフィルター（ジャンル・シーン・状態）で探す。
/// 日本語と英語のどちらのことばでも探せる。
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _controller = TextEditingController();
  String _query = '';
  final Set<String> _categories = {};
  final Set<String> _scenes = {};
  final Set<StatusFilter> _status = {};

  int get _filterCount => _categories.length + _scenes.length + _status.length;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _statusMatches(Trivia t, AppSettings s) {
    if (_status.isEmpty) return true;
    final knowledge = s.knowledge[t.id];
    return _status.any((f) => switch (f) {
          StatusFilter.saved => s.saved.contains(t.id),
          StatusFilter.knew => knowledge == Knowledge.knew,
          StatusFilter.learned => knowledge == Knowledge.learned,
          StatusFilter.unrated => knowledge == null,
        });
  }

  /// 検索語と絞り込みに合う雑学を、一致の強い順（タイトルに一致 → 本文に一致）に並べる。
  List<Trivia> _results() {
    final settings = ref.watch(settingsProvider);
    final index = ref.watch(searchIndexProvider);
    final tokens = queryTokens(_query);
    final scored = <(Trivia, int)>[];
    for (final t in ref.watch(allEligibleProvider)) {
      if (_categories.isNotEmpty && !_categories.contains(t.category)) continue;
      if (_scenes.isNotEmpty && !t.scenes.any(_scenes.contains)) continue;
      if (!_statusMatches(t, settings)) continue;
      final entry = index[t.id];
      final score = entry == null ? (tokens.isEmpty ? 1 : 0) : searchScore(entry, tokens);
      if (score > 0) scored.add((t, score));
    }
    // 同点は元の順（ID順に安定）。
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    return [for (final e in scored) e.$1];
  }

  Future<void> _openFilters() {
    final band = ref.read(settingsProvider).ageBand ?? AgeBand.adult;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) {
          final l = AppLocalizations.of(context);
          void update(void Function() fn) {
            setState(fn);
            setSheet(() {});
          }

          String statusLabel(StatusFilter f) => switch (f) {
                StatusFilter.saved => l.statusSaved,
                StatusFilter.knew => l.statusKnew,
                StatusFilter.learned => l.statusLearned,
                StatusFilter.unrated => l.statusUnrated,
              };

          Widget header(String text) => Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 6),
                child: Text(text, style: Theme.of(context).textTheme.labelLarge),
              );

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header(l.filterCategoryHeader),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final c in ref.watch(categoryIdsProvider))
                      FilterChip(
                        label: Text(categoryLabel(l, c)),
                        selected: _categories.contains(c),
                        onSelected: (v) =>
                            update(() => v ? _categories.add(c) : _categories.remove(c)),
                      ),
                  ]),
                  if (band.isTeenOrAdult) ...[
                    header(l.filterSceneHeader),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final s in allScenes)
                        FilterChip(
                          label: Text(sceneLabel(l, s)),
                          selected: _scenes.contains(s),
                          onSelected: (v) =>
                              update(() => v ? _scenes.add(s) : _scenes.remove(s)),
                        ),
                    ]),
                  ],
                  header(l.filterStatus),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final f in StatusFilter.values)
                      FilterChip(
                        key: Key('status_${f.name}'),
                        label: Text(statusLabel(f)),
                        selected: _status.contains(f),
                        onSelected: (v) =>
                            update(() => v ? _status.add(f) : _status.remove(f)),
                      ),
                  ]),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_filterCount > 0)
                        TextButton(
                          onPressed: () => update(() {
                            _categories.clear();
                            _scenes.clear();
                            _status.clear();
                          }),
                          child: Text(l.filterReset),
                        ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l.close),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final results = _results();
    final resolve = ref.watch(levelResolverProvider);
    final unlocked = ref.watch(unlockedIdsProvider);
    final band = ref.watch(settingsProvider.select((s) => s.ageBand)) ?? AgeBand.adult;
    final wordWrap = band.isChild && ref.watch(contentLanguageProvider) == 'ja';

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          key: const Key('search_field'),
          controller: _controller,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l.searchHint,
            border: InputBorder.none,
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    key: const Key('search_clear'),
                    tooltip: l.searchClear,
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  ),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(
              children: [
                FilledButton.tonalIcon(
                  key: const Key('library_filter_button'),
                  icon: const Icon(Icons.filter_list),
                  label: Text(_filterCount > 0
                      ? l.filterButtonActive(_filterCount)
                      : l.filterButton),
                  onPressed: _openFilters,
                ),
                const SizedBox(width: 12),
                Text(l.resultsCount(results.length), key: const Key('results_count')),
              ],
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(l.noResults, textAlign: TextAlign.center),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final t = results[i];
                      final level = resolve(t);
                      if (level == null) return const SizedBox.shrink();
                      final locked = unlocked != null && !unlocked.contains(t.id);
                      return Card(
                        key: Key('result_${t.id}'),
                        child: ListTile(
                          leading: TriviaIllustration(id: t.illustration, size: 32),
                          title: WrapText(level.title, wordWrap: wordWrap),
                          subtitle: Text(
                              locked ? l.libraryLocked : categoryLabel(l, t.category)),
                          trailing: Icon(locked ? Icons.lock_outline : Icons.chevron_right),
                          onTap: () =>
                              context.push(locked ? '/premium' : '/detail/${t.id}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
