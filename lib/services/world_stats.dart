import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/streak.dart';
import '../state/providers.dart';
import '../state/settings.dart';

/// 「世界の人も、いま同じ雑学を読んでいる」ための、匿名の集計。
/// - Teen/Adult が、設定でオンにしたときだけ使う。Kids/Junior は通信しない。
/// - 送るのは「雑学の id・国コード（取れたときだけ）・日付」だけ。端末や人を区別する情報は送らない。
/// - サーバー（WORLD_STATS_URL）がなければ、この機能は出ない。仕様は docs/world-stats.md。
class WorldStats {
  const WorldStats({required this.total, required this.countries, required this.top});

  /// 今日この雑学を見た人の数（世界）。
  final int total;

  /// その人たちがいる国の数。
  final int countries;

  /// 多い国（国コード, 人数）。
  final List<(String, int)> top;

  factory WorldStats.fromJson(Map<String, dynamic> json) => WorldStats(
        total: (json['total'] as num?)?.toInt() ?? 0,
        countries: (json['countries'] as num?)?.toInt() ?? 0,
        top: [
          for (final e in (json['top'] as List? ?? const []))
            if (e is Map && e['code'] is String && e['count'] is num)
              ((e['code'] as String).toUpperCase(), (e['count'] as num).toInt()),
        ],
      );
}

abstract class WorldStatsService {
  /// サーバーが設定されていて、この機能を出せるか。
  bool get available;

  /// 今日この雑学を見たことを、匿名で1回だけ伝える。失敗しても何もしない。
  Future<void> recordView(String factId, {String? region, required DateTime day});

  /// 今日の集計。取れないとき（オフラインなど）は null。
  Future<WorldStats?> today(String factId, {required DateTime day});
}

class NoWorldStatsService implements WorldStatsService {
  const NoWorldStatsService();
  @override
  bool get available => false;
  @override
  Future<void> recordView(String factId, {String? region, required DateTime day}) async {}
  @override
  Future<WorldStats?> today(String factId, {required DateTime day}) async => null;
}

/// 自分たちのサーバー（POST /v1/view、GET /v1/today）につなぐ。
class HttpWorldStatsService implements WorldStatsService {
  HttpWorldStatsService(this.baseUrl, {HttpClient? client, this.timeout = const Duration(seconds: 4)})
      : _client = client ?? HttpClient();

  final String baseUrl;
  final Duration timeout;
  final HttpClient _client;

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse(baseUrl).replace(path: '${Uri.parse(baseUrl).path.replaceAll(RegExp(r'/$'), '')}$path', queryParameters: query);

  @override
  bool get available => baseUrl.startsWith('https://');

  @override
  Future<void> recordView(String factId, {String? region, required DateTime day}) async {
    if (!available) return;
    try {
      final req = await _client.postUrl(_uri('/v1/view')).timeout(timeout);
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode({'fact': factId, 'region': region, 'day': dayKey(day)}));
      final res = await req.close().timeout(timeout);
      await res.drain<void>();
    } catch (e) {
      debugPrint('world view failed: $e');
    }
  }

  @override
  Future<WorldStats?> today(String factId, {required DateTime day}) async {
    if (!available) return null;
    try {
      final req = await _client.getUrl(_uri('/v1/today', {'fact': factId, 'day': dayKey(day)})).timeout(timeout);
      final res = await req.close().timeout(timeout);
      if (res.statusCode != 200) {
        await res.drain<void>();
        return null;
      }
      final body = await res.transform(utf8.decoder).join().timeout(timeout);
      return WorldStats.fromJson(jsonDecode(body) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('world today failed: $e');
      return null;
    }
  }
}

/// ビルド時に `--dart-define=WORLD_STATS_URL=https://...` で渡す（なければ、この機能は出ない）。
const worldStatsUrl = String.fromEnvironment('WORLD_STATS_URL');

final worldStatsServiceProvider = Provider<WorldStatsService>((ref) =>
    worldStatsUrl.isEmpty ? const NoWorldStatsService() : HttpWorldStatsService(worldStatsUrl));

/// この機能を使えるか: サーバーがあり、Teen/Adult で、本人が設定でオンにしている。
final worldEnabledProvider = Provider<bool>((ref) {
  final band = ref.watch(settingsProvider.select((s) => s.ageBand));
  if (band == null || !band.isTeenOrAdult) return false;
  return ref.watch(worldStatsServiceProvider).available;
});

final worldJoinedProvider = Provider<bool>(
    (ref) => ref.watch(worldEnabledProvider) && ref.watch(settingsProvider.select((s) => s.worldOptIn)));

const _sentKey = 'worldSent'; // '日付:雑学の id'（同じ日に同じ雑学は1回だけ送る）

/// 今日この雑学を見た人の集計。オンのときだけ、匿名で1回伝えてから取る。
final worldStatsProvider = FutureProvider.autoDispose.family<WorldStats?, String>((ref, factId) async {
  if (!ref.watch(worldJoinedProvider)) return null;
  final service = ref.watch(worldStatsServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  final day = ref.read(nowProvider);
  final mark = '${dayKey(day)}:$factId';
  final sent = prefs.getStringList(_sentKey) ?? const [];
  if (!sent.contains(mark)) {
    await service.recordView(factId, region: ref.read(regionProvider).code, day: day);
    // 古い記録は残さない（直近200件）。
    final next = [...sent, mark];
    await prefs.setStringList(_sentKey, next.length > 200 ? next.sublist(next.length - 200) : next);
  }
  return service.today(factId, day: day);
});

/// この人数より少ないうちは、集計を出さない（人数が少ないと、個人が特定されやすいため）。
const worldMinShown = 5;

/// 国コード（JP）→ 国旗の絵文字。2文字の英字でなければ 🌍。
String flagEmoji(String code) {
  if (!RegExp(r'^[A-Za-z]{2}$').hasMatch(code)) return '🌍';
  const base = 0x1F1E6 - 0x41;
  return String.fromCharCodes(code.toUpperCase().codeUnits.map((c) => base + c));
}
