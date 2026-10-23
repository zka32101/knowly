import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../logic/mascot.dart';
import '../state/providers.dart';
import '../widgets/mascot_card.dart';

/// 相棒の成長の一覧。まだなっていない姿は「？？？」で見せる。
class MascotScreen extends ConsumerWidget {
  const MascotScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final points = ref.watch(mascotPointsProvider);
    final stage = mascotStageFor(points);
    return Scaffold(
      appBar: AppBar(title: Text(l.mascotTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(child: MascotFace(stage: stage, size: 96)),
            const SizedBox(height: 8),
            Text(mascotName(l, stage.id),
                key: const Key('mascot_current'),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall),
            Text(l.mascotPoints(points),
                key: const Key('mascot_points'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l.mascotHint, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            for (final s in mascotStages)
              ListTile(
                key: Key('mascot_stage_${s.id}'),
                leading: Opacity(
                  opacity: points >= s.threshold ? 1 : 0.2,
                  child: Text(s.emoji, style: const TextStyle(fontSize: 32)),
                ),
                title: Text(points >= s.threshold ? mascotName(l, s.id) : l.mascotLocked),
                subtitle: Text(l.mascotPoints(s.threshold)),
                trailing: s.id == stage.id ? const Icon(Icons.check_circle) : null,
              ),
          ],
        ),
      ),
    );
  }
}
