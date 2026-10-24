import '../models/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../logic/collection.dart';
import '../models/trivia.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/illustration.dart';
import '../widgets/share_cards.dart';
import '../widgets/share_sheet.dart';

/// レア度の色（ふつう＝灰、レア＝青、スーパーレア＝金）。
Color rarityColor(Rarity r) => switch (r) {
      Rarity.common => Colors.blueGrey,
      Rarity.rare => Colors.blue,
      Rarity.superRare => Colors.amber.shade700,
    };

String rarityStars(Rarity r) => '★' * r.stars;

String rarityLabel(AppLocalizations l, Rarity r) => switch (r) {
      Rarity.common => l.capsuleRarity1,
      Rarity.rare => l.capsuleRarity2,
      Rarity.superRare => l.capsuleRarity3,
    };

/// ざつがくずかん: 見た雑学がジャンルごとのマスに埋まっていく。まだのマスは「？」。
class ZukanScreen extends ConsumerStatefulWidget {
  const ZukanScreen({super.key});

  @override
  ConsumerState<ZukanScreen> createState() => _ZukanScreenState();
}

class _ZukanScreenState extends ConsumerState<ZukanScreen> {
  String? _category;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final all = ref.watch(allEligibleProvider);
    final seen = ref.watch(settingsProvider.select((s) => s.seen));
    final categories = [for (final c in ref.watch(categoryIdsProvider)) if (all.any((t) => CategoryRegistry.matches({c}, t.category))) c];
    final shown = [for (final t in all) if (_category == null || CategoryRegistry.matches({_category!}, t.category)) t];
    final found = shown.where((t) => seen.contains(t.id)).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.zukanTitle),
        actions: [
          ShareButton(
            buttonKey: const Key('zukan_share'),
            compact: true,
            text: '${l.appName} ${l.zukanTitle} ${l.zukanFound(found, shown.length)}\n#${l.appName}',
            card: ShareFrame(appName: l.appName, children: [
              bigEmoji('📖'),
              gap8,
              cardTitle(l.zukanTitle),
              gap8,
              cardBig('$found / ${shown.length}'),
              gap8,
              // 見つけた雑学の絵を、ならべる（最大24個）
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final t in shown.where((t) => seen.contains(t.id)).take(24))
                    Text(emojiForIllustration(t.illustration), style: const TextStyle(fontSize: 26)),
                ],
              ),
            ]),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.zukanFound(found, shown.length),
                key: const Key('zukan_progress'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            LinearProgressIndicator(
                value: shown.isEmpty ? 0 : found / shown.length, minHeight: 8),
            const SizedBox(height: 4),
            Text(l.zukanHint, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  key: const Key('zukan_cat_all'),
                  label: Text(l.zukanAll),
                  selected: _category == null,
                  onSelected: (_) => setState(() => _category = null),
                ),
                for (final c in categories)
                  ChoiceChip(
                    key: Key('zukan_cat_$c'),
                    label: Text(categoryLabel(l, c)),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in shown) _Cell(item: t, found: seen.contains(t.id)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.item, required this.found});
  final Trivia item;
  final bool found;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rarity = rarityOf(item.id);
    return InkWell(
      key: Key('zukan_cell_${item.id}'),
      borderRadius: BorderRadius.circular(12),
      onTap: found ? () => context.push('/detail/${item.id}') : null,
      child: Container(
        width: 64,
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: found ? rarityColor(rarity) : Theme.of(context).colorScheme.outlineVariant,
              width: found && rarity == Rarity.superRare ? 3 : 1.5),
          color: found ? rarityColor(rarity).withValues(alpha: 0.08) : null,
        ),
        child: found
            ? Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TriviaIllustration(id: item.illustration, size: 28),
                  Text(rarityStars(rarity),
                      style: TextStyle(fontSize: 11, color: rarityColor(rarity))),
                ],
              )
            : Center(
                child: Text(l.zukanLocked,
                    style: TextStyle(
                        fontSize: 26, color: Theme.of(context).colorScheme.outlineVariant)),
              ),
      ),
    );
  }
}
