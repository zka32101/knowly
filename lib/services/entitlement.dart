import 'package:flutter_riverpod/flutter_riverpod.dart';

/// プレミアムの購入状態。RevenueCat 連携は購入の設定（API キー・商品）が済んでから
/// この provider を差し替える。それまでは常に無料プラン。
abstract class EntitlementService {
  Future<bool> isPremium();
}

class FreeEntitlementService implements EntitlementService {
  const FreeEntitlementService();
  @override
  Future<bool> isPremium() async => false;
}

final entitlementServiceProvider =
    Provider<EntitlementService>((ref) => const FreeEntitlementService());

final isPremiumProvider =
    FutureProvider<bool>((ref) => ref.watch(entitlementServiceProvider).isPremium());
