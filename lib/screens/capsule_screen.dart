import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../logic/collection.dart';
import '../logic/streak.dart';
import '../models/trivia.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/illustration.dart';
import '../widgets/ja_wrap_text.dart';
import '../widgets/share_cards.dart';
import '../widgets/share_sheet.dart';
import 'quiz_battle_screen.dart';
import 'zukan_screen.dart';

/// ざつがくカプセル: 1日1回あけると、雑学カードが1枚出る（レア度つき）。お金や課金とは無関係。
class CapsuleScreen extends ConsumerStatefulWidget {
  const CapsuleScreen({super.key});

  @override
  ConsumerState<CapsuleScreen> createState() => _CapsuleScreenState();
}

class _CapsuleScreenState extends ConsumerState<CapsuleScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
  bool _opening = false;
  bool _isNew = false;
  String? _revealedId;

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) setState(() => _opening = false);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String? _todayId() {
    final value = ref.read(settingsProvider).capsule;
    final today = dayKey(ref.read(nowProvider));
    if (value != null && value.startsWith('$today:')) return value.substring(today.length + 1);
    return null;
  }

  void _open() {
    final pool = ref.read(allEligibleProvider);
    final seen = ref.read(settingsProvider).seen;
    final item = pickCapsule(pool, seen, ref.read(quizRandomProvider));
    if (item == null) return;
    _isNew = !seen.contains(item.id);
    ref.read(settingsProvider.notifier).recordCapsule(ref.read(nowProvider), item.id);
    setState(() {
      _revealedId = item.id;
      _opening = true;
    });
    _c.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    ref.watch(settingsProvider.select((s) => s.capsule));
    final pool = ref.watch(allEligibleProvider);
    final todayId = _todayId();
    final resolve = ref.watch(levelResolverProvider);
    final item = todayId == null ? null : ref.watch(triviaRepositoryProvider).byId(todayId);
    final level = item == null ? null : resolve(item);

    Widget body;
    if (item != null && level != null && !_opening) {
      body = _Revealed(item: item, level: level, isNew: _isNew && _revealedId == item.id);
    } else if (_opening) {
      body = AnimatedBuilder(
        animation: _c,
        builder: (_, _) {
          final t = _c.value;
          // 前半: ゆれる。後半: ぱかっと開いて大きくなる。
          final shake = t < 0.7 ? math.sin(t * math.pi * 14) * 0.25 * (1 - t / 0.7) : 0.0;
          final scale = t < 0.7 ? 1.0 : 1.0 + (t - 0.7) / 0.3 * 0.8;
          return Opacity(
            opacity: t < 0.85 ? 1 : (1 - (t - 0.85) / 0.15).clamp(0, 1),
            child: Transform.rotate(
              angle: shake,
              child: Transform.scale(
                scale: scale,
                child: const Text('🎁', key: Key('capsule_opening'), style: TextStyle(fontSize: 120)),
              ),
            ),
          );
        },
      );
    } else if (pool.isEmpty) {
      body = Text(l.capsuleEmpty);
    } else {
      body = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎁', style: TextStyle(fontSize: 120)),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('capsule_open'),
            style: FilledButton.styleFrom(minimumSize: const Size(220, 64)),
            onPressed: _open,
            child: Text(l.capsuleOpen, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(height: 12),
          Text(l.capsuleHint, style: theme.textTheme.bodyMedium),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.capsuleTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: body),
        ),
      ),
    );
  }
}

class _Revealed extends ConsumerWidget {
  const _Revealed({required this.item, required this.level, required this.isNew});
  final Trivia item;
  final TriviaLevel level;
  final bool isNew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final rarity = rarityOf(item.id);
    final color = rarityColor(rarity);
    final wrap = ref.watch(contentLanguageProvider) == 'ja';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          key: const Key('capsule_card'),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: rarity == Rarity.superRare ? 4 : 2),
            gradient: rarity == Rarity.superRare
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFF8E1), Color(0xFFFFE082), Color(0xFFFFF8E1)],
                  )
                : null,
            color: rarity == Rarity.superRare ? null : color.withValues(alpha: 0.08),
            boxShadow: rarity == Rarity.superRare
                ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 24)]
                : null,
          ),
          child: Column(
            children: [
              Text('${rarityStars(rarity)}  ${rarityLabel(l, rarity)}',
                  key: const Key('capsule_rarity'),
                  style: theme.textTheme.titleMedium?.copyWith(color: color)),
              if (isNew)
                Chip(
                  key: const Key('capsule_new'),
                  label: Text(l.capsuleNew),
                  visualDensity: VisualDensity.compact,
                ),
              const SizedBox(height: 8),
              TriviaIllustration(id: item.illustration, size: 72),
              const SizedBox(height: 8),
              Text(categoryLabel(l, item.category), style: theme.textTheme.labelMedium),
              WrapText(level.title,
                  wordWrap: wrap && (ref.watch(settingsProvider).ageBand?.isChild ?? false),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              WrapText(level.body,
                  wordWrap: wrap && (ref.watch(settingsProvider).ageBand?.isChild ?? false),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ShareButton(
          buttonKey: const Key('capsule_share'),
          text: '${rarityStars(rarity)} ${level.title}\n#${l.appName}',
          card: ShareFrame(
            appName: l.appName,
            colors: rarity == Rarity.superRare
                ? const [Color(0xFFFFF8E1), Color(0xFFFFE082)]
                : const [Color(0xFFFFF4D6), Color(0xFFFFE0B2)],
            border: color,
            children: [
              cardTitle('${rarityStars(rarity)}  ${rarityLabel(l, rarity)}'),
              gap8,
              bigEmoji(emojiForIllustration(item.illustration), size: 72),
              gap8,
              cardBody(categoryLabel(l, item.category), size: 13),
              cardTitle(level.title),
              gap8,
              cardBody(level.body),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(l.capsuleDone, key: const Key('capsule_done')),
        TextButton(
          key: const Key('capsule_to_zukan'),
          onPressed: () => context.push('/zukan'),
          child: Text(l.capsuleToZukan),
        ),
      ],
    );
  }
}
