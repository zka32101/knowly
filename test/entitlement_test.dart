import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/services/entitlement.dart';

void main() {
  test('購入キーがない（ビルド時に渡していない）ときは、空のキーになる', () {
    expect(purchaseKeyFor(TargetPlatform.iOS), isEmpty);
    expect(purchaseKeyFor(TargetPlatform.android), isEmpty);
    expect(purchaseKeyFor(TargetPlatform.macOS), isEmpty);
  });

  test('FreeEntitlementService は、常に無料プランで購入できない', () async {
    const s = FreeEntitlementService();
    expect(await s.isPremium(), isFalse);
    expect(await s.offers(), isEmpty);
    expect(await s.restore(), isFalse);
    expect(
        await s.purchase(const PurchaseOffer(
            id: 'x', period: PurchasePeriod.monthly, priceString: '')),
        PurchaseOutcome.unavailable);
  });

  test('エンタイトルメント ID は premium', () {
    expect(premiumEntitlementId, 'premium');
  });
}
