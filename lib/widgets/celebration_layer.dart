import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../logic/badges.dart';
import '../logic/mascot.dart';
import '../logic/timing.dart';
import '../screens/badges_screen.dart';
import '../screens/stamps_screen.dart' show seasonName;
import '../state/celebration.dart';
import '../state/settings.dart';
import 'mascot_card.dart';

/// 相棒が成長したとき・バッジを取ったときの、紙吹雪つきのお祝い。アプリ全体の上に重ねる。
/// 3秒で自動で消える（タップでも消える）。何個たまっていても1つずつ出す。
class CelebrationLayer extends ConsumerStatefulWidget {
  const CelebrationLayer({super.key});

  @override
  ConsumerState<CelebrationLayer> createState() => _CelebrationLayerState();
}

class _CelebrationLayerState extends ConsumerState<CelebrationLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );
  Celebration? _shown;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _dismiss();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => ensureCelebrationBaseline(ref));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    final c = _shown;
    if (c == null) return;
    final notifier = ref.read(settingsProvider.notifier);
    setState(() => _shown = null);
    _controller.reset();
    if (c.kind == CelebrationKind.stage) {
      notifier.ackStage(mascotStages.indexWhere((s) => s.id == c.id));
    } else if (c.kind == CelebrationKind.outfit) {
      notifier.ackOutfits([c.id]);
    } else {
      notifier.ackBadges([c.id]);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(settingsProvider.select((s) => s.ageBand));
    final pending = ref.watch(pendingCelebrationsProvider);
    if (_shown == null && pending.isNotEmpty) {
      _shown = pending.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.forward(from: 0);
      });
    }
    final c = _shown;
    final l = Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (c == null || l == null) return const SizedBox.shrink();

    final String title;
    final String sub;
    if (c.kind == CelebrationKind.stage) {
      title = l.celebrateStage(mascotName(l, c.id));
      sub = mascotSay(l, c.id);
    } else if (c.kind == CelebrationKind.outfit) {
      final season = Season.values.firstWhere((x) => c.id.endsWith('-${x.name}'));
      title = l.celebrateOutfit;
      sub = seasonName(l, season);
    } else {
      final def = badgeDefs.firstWhere((b) => b.id == c.id);
      title = l.celebrateBadge;
      sub = badgeLabel(l, def);
    }

    return GestureDetector(
      key: const Key('celebration'),
      behavior: HitTestBehavior.opaque,
      onTap: _dismiss,
      child: Material(
        color: Colors.black54,
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, _) => CustomPaint(painter: _ConfettiPainter(_controller.value)),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, child) {
                  // ぽんっと大きくなって、少しはずむ
                  final t = Curves.elasticOut.transform(math.min(1, _controller.value * 4));
                  return Transform.scale(scale: t, child: child);
                },
                child: Card(
                  margin: const EdgeInsets.all(32),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(c.emoji, style: const TextStyle(fontSize: 80)),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          key: const Key('celebration_title'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sub,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 落ちてくる紙吹雪（乱数ではなく、番号から決めた位置・色・速さ）。
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t);
  final double t;

  static const _colors = [
    Colors.pink,
    Colors.amber,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.deepOrange,
    Colors.purple,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 60; i++) {
      final x = (math.sin(i * 12.9898) * 43758.5453).abs() % 1.0;
      final speed = 0.6 + ((i * 37) % 10) / 12;
      final phase = ((i * 53) % 100) / 100;
      final y = ((t * speed) + phase) % 1.0;
      final sway = math.sin((t * 6) + i) * 12;
      final paint = Paint()..color = _colors[i % _colors.length];
      canvas.save();
      canvas.translate(x * size.width + sway, y * size.height);
      canvas.rotate(t * 8 + i);
      canvas.drawRect(const Rect.fromLTWH(-4, -2, 8, 4), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
