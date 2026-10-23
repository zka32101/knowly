import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../logic/mascot.dart';
import '../state/providers.dart';

String mascotName(AppLocalizations l, String id) => switch (id) {
      'egg' => l.mascotName_egg,
      'chick' => l.mascotName_chick,
      'chicklet' => l.mascotName_chicklet,
      'owl' => l.mascotName_owl,
      'professor' => l.mascotName_professor,
      _ => l.mascotName_king,
    };

String mascotSay(AppLocalizations l, String id) => switch (id) {
      'egg' => l.mascotSay_egg,
      'chick' => l.mascotSay_chick,
      'chicklet' => l.mascotSay_chicklet,
      'owl' => l.mascotSay_owl,
      'professor' => l.mascotSay_professor,
      _ => l.mascotSay_king,
    };

/// 相棒の絵。段階が変わると、ぽんっと切り替わる。
class MascotFace extends StatelessWidget {
  const MascotFace({super.key, required this.stage, this.size = 56});
  final MascotStage stage;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
      child: Text(stage.emoji,
          key: ValueKey(stage.id), style: TextStyle(fontSize: size)),
    );
  }
}

/// ホームに出す、相棒のカード。タップで成長の一覧へ。
class MascotCard extends ConsumerWidget {
  const MascotCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final points = ref.watch(mascotPointsProvider);
    final stage = mascotStageFor(points);
    final next = nextMascotStage(points);
    return Card(
      key: const Key('mascot_card'),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/mascot'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              MascotFace(stage: stage, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mascotName(l, stage.id), style: theme.textTheme.titleMedium),
                    Text(mascotSay(l, stage.id),
                        key: const Key('mascot_say'), style: theme.textTheme.bodyMedium),
                    Text(
                      next == null
                          ? l.mascotMax
                          : l.mascotNext(next.threshold - points, mascotName(l, next.id)),
                      key: const Key('mascot_next'),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
