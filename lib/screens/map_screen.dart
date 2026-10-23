import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../logic/knowledge_map.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/illustration.dart';

/// 表示できる雑学の「つながり」（この年代・言語・国で出せるものだけ）。
final knowledgeLinksProvider = Provider<Map<String, Set<String>>>((ref) {
  final all = ref.watch(allEligibleProvider);
  final visible = {for (final t in all) t.id};
  final links = buildLinks(ref.watch(triviaRepositoryProvider).items);
  return {
    for (final e in links.entries)
      if (visible.contains(e.key)) e.key: {for (final id in e.value) if (visible.contains(id)) id},
  };
});

/// つながりマップ: 中心の雑学と、つながる雑学が線で結ばれる。タップで中心を移していける。
/// まだ見ていない雑学は「？」（ずかんを埋めたくなる）。
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key, this.startId});
  final String? startId;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  String? _center;

  String? _initialCenter() {
    final links = ref.read(knowledgeLinksProvider);
    if (widget.startId != null && links.containsKey(widget.startId)) return widget.startId;
    final seen = ref.read(settingsProvider).seen;
    // 見た雑学の中で、つながりがいちばん多いもの。なければ、つながりが多い雑学。
    String? best;
    var bestScore = -1;
    final ids = links.keys.toList()..sort();
    for (final id in ids) {
      final score = links[id]!.length + (seen.contains(id) ? 100 : 0);
      if (score > bestScore) {
        bestScore = score;
        best = id;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final links = ref.watch(knowledgeLinksProvider);
    final seen = ref.watch(settingsProvider.select((s) => s.seen));
    final repo = ref.watch(triviaRepositoryProvider);
    final resolve = ref.watch(levelResolverProvider);
    final center = _center ??= _initialCenter();
    final centerItem = center == null ? null : repo.byId(center);
    final centerLevel = centerItem == null ? null : resolve(centerItem);

    if (centerItem == null || centerLevel == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.mapTitle)),
        body: Center(child: Text(l.emptyFeed)),
      );
    }

    final neighbors = neighborsOf(center!, links, links.keys.toSet(), seen: seen);

    Widget node(String id, Offset pos, double radius) {
      final t = repo.byId(id);
      final known = seen.contains(id);
      return Positioned(
        left: pos.dx - radius,
        top: pos.dy - radius,
        child: GestureDetector(
          key: Key('map_node_$id'),
          onTap: () => setState(() => _center = id),
          child: Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: known ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
              border: Border.all(
                  color: known ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                  width: known ? 2.5 : 1.5),
            ),
            alignment: Alignment.center,
            child: known && t != null
                ? TriviaIllustration(id: t.illustration, size: radius * 1.0)
                : Text(l.zukanLocked,
                    style: TextStyle(
                        fontSize: radius, color: theme.colorScheme.outline)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.mapTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final size = Size(c.maxWidth, c.maxHeight);
                  final mid = Offset(size.width / 2, size.height / 2);
                  final ring = math.min(size.width, size.height) * 0.36;
                  final positions = <String, Offset>{};
                  for (var i = 0; i < neighbors.length; i++) {
                    final a = -math.pi / 2 + 2 * math.pi * i / neighbors.length;
                    positions[neighbors[i]] = mid + Offset(math.cos(a), math.sin(a)) * ring;
                  }
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _LinePainter(mid, positions.values.toList(),
                              theme.colorScheme.outlineVariant),
                        ),
                      ),
                      for (final e in positions.entries) node(e.key, e.value, 30),
                      node(center, mid, 44),
                    ],
                  );
                },
              ),
            ),
            Card(
              margin: const EdgeInsets.all(12),
              child: ListTile(
                key: const Key('map_center_card'),
                title: Text(centerLevel.title, key: const Key('map_center_title')),
                subtitle: Text(neighbors.isEmpty ? l.mapNoLinks : l.mapLinkCount(neighbors.length)),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => context.push('/detail/${centerItem.id}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.center, this.points, this.color);
  final Offset center;
  final List<Offset> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    for (final p in points) {
      canvas.drawLine(center, p, paint);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.center != center || old.points != points || old.color != color;
}
