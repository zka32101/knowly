import 'dart:math' as math;

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

enum MascotMood { idle, happy, sad, speaking }

/// 相棒の絵。段階が変わると、ぽんっと切り替わる。気分（[mood]）で動く:
/// happy = はねて ✨、sad = しょんぼり揺れて 💧、speaking = 口ぱくのように ふくらむ。
/// 動きは有限回で止まる（画面が落ち着かず、読み上げ中ずっと動き続けないように）。
class MascotFace extends StatefulWidget {
  const MascotFace({
    super.key,
    required this.stage,
    this.size = 56,
    this.mood = MascotMood.idle,
  });
  final MascotStage stage;
  final double size;
  final MascotMood mood;

  @override
  State<MascotFace> createState() => _MascotFaceState();
}

class _MascotFaceState extends State<MascotFace> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

  @override
  void initState() {
    super.initState();
    _play();
  }

  @override
  void didUpdateWidget(MascotFace old) {
    super.didUpdateWidget(old);
    if (old.mood != widget.mood) _play();
  }

  void _play() {
    switch (widget.mood) {
      case MascotMood.idle:
        _c.stop();
        _c.value = 0;
      case MascotMood.happy:
      case MascotMood.sad:
        _c.forward(from: 0);
      case MascotMood.speaking:
        _c.repeat(reverse: true, period: const Duration(milliseconds: 400), count: 10);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final face = AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
      child: Text(widget.stage.emoji,
          key: ValueKey(widget.stage.id), style: TextStyle(fontSize: widget.size)),
    );
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        final t = _c.value;
        var dy = 0.0;
        var angle = 0.0;
        var scale = 1.0;
        String? badge;
        switch (widget.mood) {
          case MascotMood.happy:
            dy = -widget.size * 0.35 * math.sin(math.pi * t);
            badge = t < 1 ? '✨' : null;
          case MascotMood.sad:
            angle = 0.18 * math.sin(t * math.pi * 4) * (1 - t);
            badge = '💧';
          case MascotMood.speaking:
            scale = 1 + 0.12 * t;
          case MascotMood.idle:
            break;
        }
        return SizedBox(
          key: Key('mascot_face_${widget.mood.name}'),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, dy),
                child: Transform.rotate(
                  angle: angle,
                  child: Transform.scale(scale: scale, child: face),
                ),
              ),
              if (badge != null)
                Positioned(
                  right: -widget.size * 0.1,
                  top: -widget.size * 0.1,
                  child: Text(badge, style: TextStyle(fontSize: widget.size * 0.4)),
                ),
            ],
          ),
        );
      },
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
