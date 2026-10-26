import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/services/entitlement.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      await s.purchase(
        const PurchaseOffer(
          id: 'x',
          period: PurchasePeriod.monthly,
          priceString: '',
        ),
      ),
      PurchaseOutcome.unavailable,
    );
  });

  test('エンタイトルメント ID は premium', () {
    expect(premiumEntitlementId, 'premium');
  });

  group('オフラインでも、プレミアムの状態を保つ', () {
    final t0 = DateTime(2026, 10, 24);
    Future<bool> offline() async => throw Exception('offline');

    test('確認できたら、結果を保存して返す', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      expect(
        await premiumWithOfflineCache(() async => true, prefs, t0),
        isTrue,
      );
      expect(
        await premiumWithOfflineCache(
          offline,
          prefs,
          t0.add(const Duration(days: 1)),
        ),
        isTrue,
      );
    });

    test('猶予の日数をすぎたら、無料に戻る', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await premiumWithOfflineCache(() async => true, prefs, t0);
      final late = t0.add(const Duration(days: premiumOfflineGraceDays));
      expect(await premiumWithOfflineCache(offline, prefs, late), isFalse);
    });

    test('一度も確認できていないときは、無料', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      expect(await premiumWithOfflineCache(offline, prefs, t0), isFalse);
    });

    test('オンラインで「プレミアムではない」と分かったら、すぐ無料になる', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await premiumWithOfflineCache(() async => true, prefs, t0);
      expect(
        await premiumWithOfflineCache(() async => false, prefs, t0),
        isFalse,
      );
      expect(await premiumWithOfflineCache(offline, prefs, t0), isFalse);
    });

    test('端末の時計を過去に戻しても、プレミアムが続かない', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await premiumWithOfflineCache(() async => true, prefs, t0);
      final back = t0.subtract(const Duration(days: 3));
      expect(await premiumWithOfflineCache(offline, prefs, back), isFalse);
    });
  });

  test('年額の割引率: 月額を12回払うより何％安いか', () {
    const m = PurchaseOffer(
      id: 'm',
      period: PurchasePeriod.monthly,
      priceString: '',
      price: 1.99,
    );
    const a = PurchaseOffer(
      id: 'a',
      period: PurchasePeriod.annual,
      priceString: '',
      price: 14.99,
    );
    expect(annualSavingsPercent([m, a]), 37); // 14.99 ÷ 23.88 = 0.628
    expect(annualSavingsPercent([m]), isNull); // 年額がない
    expect(
      annualSavingsPercent([
        const PurchaseOffer(
          id: 'm',
          period: PurchasePeriod.monthly,
          priceString: '',
        ),
        a,
      ]),
      isNull,
    ); // 価格が分からない
    const dear = PurchaseOffer(
      id: 'a',
      period: PurchasePeriod.annual,
      priceString: '',
      price: 30,
    );
    expect(annualSavingsPercent([m, dear]), isNull); // 割引にならない
  });
}
