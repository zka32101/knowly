import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/category.dart';
import '../state/providers.dart';

/// カテゴリーのチップ。親のチップの下に、子のチップを1段インデントして並べる。
/// 親を選ぶと、子の雑学もふくまれる（子だけを選ぶこともできる）。
class CategoryChips extends ConsumerWidget {
  const CategoryChips({
    super.key,
    required this.selected,
    required this.onToggle,
    this.keyPrefix = 'filter_cat_',
  });

  final Set<String> selected;
  final void Function(String id) onToggle;
  final String keyPrefix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final ids = ref.watch(categoryIdsProvider);
    Widget chip(String c) => FilterChip(
          key: Key('$keyPrefix$c'),
          label: Text(categoryLabel(l, c)),
          selected: selected.contains(c),
          onSelected: (_) => onToggle(c),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final p in ids)
          if (CategoryRegistry.depth(p) == 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  chip(p),
                  if (ids.any((k) => CategoryRegistry.get(k)?.parent == p))
                    Padding(
                      padding: const EdgeInsets.only(left: 24, top: 4),
                      child: Wrap(spacing: 8, runSpacing: 4, children: [
                        for (final k in ids)
                          if (CategoryRegistry.get(k)?.parent == p) chip(k),
                      ]),
                    ),
                ],
              ),
            ),
      ],
    );
  }
}
