import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../state/providers.dart';
import '../state/settings.dart';

enum PurchasePeriod { monthly, annual }

/// 購入できるプラン。価格の文字列は、ストアが返すもの（通貨・地域に合わせた表示）をそのまま使う。
class PurchaseOffer {
  const PurchaseOffer({
    required this.id,
    required this.period,
    required this.priceString,
    this.hasFreeTrial = false,
  });

  final String id;
  final PurchasePeriod period;
  final String priceString;
  final bool hasFreeTrial;
}

enum PurchaseOutcome { success, cancelled, failed, unavailable }

/// プレミアムの購入状態と購入処理。
/// 購入の設定（API キー）がないときは [FreeEntitlementService]（常に無料プラン）になる。
abstract class EntitlementService {
  Future<bool> isPremium();
  Future<List<PurchaseOffer>> offers();
  Future<PurchaseOutcome> purchase(PurchaseOffer offer);

  /// 購入の復元。復元できたら true。
  Future<bool> restore();
}

class FreeEntitlementService implements EntitlementService {
  const FreeEntitlementService();
  @override
  Future<bool> isPremium() async => false;
  @override
  Future<List<PurchaseOffer>> offers() async => const [];
  @override
  Future<PurchaseOutcome> purchase(PurchaseOffer offer) async => PurchaseOutcome.unavailable;
  @override
  Future<bool> restore() async => false;
}

/// RevenueCat のキー。ビルド時に `--dart-define` で渡す（ソースにキーを書かない）。
///   --dart-define=REVENUECAT_IOS_KEY=appl_xxx --dart-define=REVENUECAT_ANDROID_KEY=goog_xxx
const revenueCatIosKey = String.fromEnvironment('REVENUECAT_IOS_KEY');
const revenueCatAndroidKey = String.fromEnvironment('REVENUECAT_ANDROID_KEY');

/// RevenueCat のダッシュボードで作るエンタイトルメントの ID。
const premiumEntitlementId = 'premium';

class RevenueCatEntitlementService implements EntitlementService {
  RevenueCatEntitlementService(this.apiKey, {this.entitlementId = premiumEntitlementId});

  final String apiKey;
  final String entitlementId;
  Future<void>? _configured;
  final Map<String, Package> _packages = {};

  /// 最初に必要になったときに初期化する（起動時には初期化しない）。
  Future<void> _ensureConfigured() => _configured ??= Purchases.configure(PurchasesConfiguration(apiKey));

  bool _active(CustomerInfo info) => info.entitlements.active.containsKey(entitlementId);

  @override
  Future<bool> isPremium() async {
    try {
      await _ensureConfigured();
      return _active(await Purchases.getCustomerInfo());
    } catch (e) {
      debugPrint('isPremium failed: $e');
      rethrow; // オフラインなどで確認できないとき。呼び出し側が、前回の結果を使う
    }
  }

  @override
  Future<List<PurchaseOffer>> offers() async {
    try {
      await _ensureConfigured();
      final offering = (await Purchases.getOfferings()).current;
      if (offering == null) return const [];
      _packages.clear();
      final out = <PurchaseOffer>[];
      for (final p in offering.availablePackages) {
        final period = switch (p.packageType) {
          PackageType.monthly => PurchasePeriod.monthly,
          PackageType.annual => PurchasePeriod.annual,
          _ => null,
        };
        if (period == null) continue;
        _packages[p.identifier] = p;
        final intro = p.storeProduct.introductoryPrice;
        out.add(PurchaseOffer(
          id: p.identifier,
          period: period,
          priceString: p.storeProduct.priceString,
          hasFreeTrial: intro != null && intro.price == 0,
        ));
      }
      // 月額 → 年額の順。
      out.sort((a, b) => a.period.index.compareTo(b.period.index));
      return out;
    } catch (e) {
      debugPrint('offers failed: $e');
      rethrow; // オフラインなど。画面で「ネットにつないでください」と案内する
    }
  }

  @override
  Future<PurchaseOutcome> purchase(PurchaseOffer offer) async {
    final package = _packages[offer.id];
    if (package == null) return PurchaseOutcome.unavailable;
    try {
      await _ensureConfigured();
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return _active(result.customerInfo) ? PurchaseOutcome.success : PurchaseOutcome.failed;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      return code == PurchasesErrorCode.purchaseCancelledError
          ? PurchaseOutcome.cancelled
          : PurchaseOutcome.failed;
    } catch (e) {
      debugPrint('purchase failed: $e');
      return PurchaseOutcome.failed;
    }
  }

  @override
  Future<bool> restore() async {
    try {
      await _ensureConfigured();
      return _active(await Purchases.restorePurchases());
    } catch (e) {
      debugPrint('restore failed: $e');
      return false;
    }
  }
}

/// このプラットフォームの購入キー。なければ空（購入機能は「準備中」になる）。
String purchaseKeyFor(TargetPlatform platform) => switch (platform) {
      TargetPlatform.iOS => revenueCatIosKey,
      TargetPlatform.android => revenueCatAndroidKey,
      _ => '',
    };

final entitlementServiceProvider = Provider<EntitlementService>((ref) {
  final key = purchaseKeyFor(defaultTargetPlatform);
  return key.isEmpty ? const FreeEntitlementService() : RevenueCatEntitlementService(key);
});

/// 最後に確認できたプレミアムの状態を、この日数まで、オフラインのとき使う。
const premiumOfflineGraceDays = 14;
const _premiumCacheKey = 'premiumCache'; // 'true|<unix ms>' / 'false|<unix ms>'

/// 確認できたら保存して返す。確認できない（オフラインなど）ときは、猶予の間は前回の結果を返す。
Future<bool> premiumWithOfflineCache(
  Future<bool> Function() check,
  SharedPreferences prefs,
  DateTime now,
) async {
  try {
    final active = await check();
    await prefs.setString(_premiumCacheKey, '$active|${now.millisecondsSinceEpoch}');
    return active;
  } catch (_) {
    final parts = (prefs.getString(_premiumCacheKey) ?? '').split('|');
    if (parts.length != 2) return false;
    final at = int.tryParse(parts[1]);
    if (at == null) return false;
    final age = now.difference(DateTime.fromMillisecondsSinceEpoch(at));
    return parts[0] == 'true' && age.inDays < premiumOfflineGraceDays;
  }
}

/// プレミアムかどうか。Kids/Junior は、すべて無料なので購入の SDK を呼ばない（通信を発生させない）。
/// オフラインのときは、最後に確認できた状態を [premiumOfflineGraceDays] 日まで使う。
final isPremiumProvider = FutureProvider<bool>((ref) async {
  final band = ref.watch(settingsProvider.select((s) => s.ageBand));
  if (band == null || band.isChild) return false;
  final service = ref.watch(entitlementServiceProvider);
  return premiumWithOfflineCache(
      service.isPremium, ref.watch(sharedPreferencesProvider), ref.read(nowProvider));
});

/// 購入できるプラン（プレミアム画面を開いたときに取得する）。
final offersProvider = FutureProvider.autoDispose<List<PurchaseOffer>>(
  (ref) => ref.watch(entitlementServiceProvider).offers(),
);
