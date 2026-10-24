import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../services/entitlement.dart';
import '../state/providers.dart';

/// プレミアムの案内と購入。価格はストアが返す文字列をそのまま表示する。
class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _busy = false;

  void _say(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _buy(PurchaseOffer offer) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    final outcome = await ref.read(entitlementServiceProvider).purchase(offer);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (outcome) {
      case PurchaseOutcome.success:
        ref.invalidate(isPremiumProvider);
        _say(l.premiumPurchased);
      case PurchaseOutcome.cancelled:
        _say(l.premiumCancelled);
      case PurchaseOutcome.failed:
      case PurchaseOutcome.unavailable:
        _say(l.premiumFailed);
    }
  }

  Future<void> _restore() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    final restored = await ref.read(entitlementServiceProvider).restore();
    if (!mounted) return;
    setState(() => _busy = false);
    if (restored) ref.invalidate(isPremiumProvider);
    _say(restored ? l.premiumRestored : l.premiumNothingToRestore);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final premium = ref.watch(isPremiumNowProvider);
    final offers = ref.watch(offersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.premiumTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (premium)
            Card(
              key: const Key('premium_active'),
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  const Icon(Icons.verified_outlined),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l.premiumActive, style: theme.textTheme.titleMedium)),
                ]),
              ),
            ),
          for (final text in [l.premiumBenefit1, l.premiumBenefit2, l.premiumBenefit3])
            ListTile(leading: const Icon(Icons.check_circle_outline), title: Text(text)),
          const SizedBox(height: 8),
          Text(l.premiumKidsFree, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 20),
          if (!premium)
            offers.when(
              loading: () => const Center(
                  key: Key('offers_loading'),
                  child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
              error: (_, _) => Column(
                key: const Key('offers_offline'),
                children: [
                  FilledButton(onPressed: null, child: Text(l.premiumUnavailable)),
                  const SizedBox(height: 8),
                  Text(l.premiumOffline, textAlign: TextAlign.center),
                ],
              ),
              data: (list) => list.isEmpty
                  ? FilledButton(
                      key: const Key('premium_unavailable'),
                      onPressed: null,
                      child: Text(l.premiumUnavailable),
                    )
                  : Column(
                      children: [
                        for (final o in list)
                          Card(
                            key: Key('offer_${o.id}'),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    o.period == PurchasePeriod.monthly
                                        ? l.premiumMonthly
                                        : l.premiumAnnual,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(o.priceString,
                                      key: Key('price_${o.id}'),
                                      style: theme.textTheme.headlineSmall),
                                  if (o.hasFreeTrial)
                                    Text(l.premiumTrial,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: theme.colorScheme.primary)),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                      key: Key('buy_${o.id}'),
                                      onPressed: _busy ? null : () => _buy(o),
                                      child: Text(l.premiumBuy),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          const SizedBox(height: 8),
          TextButton(
            key: const Key('premium_restore'),
            onPressed: _busy ? null : _restore,
            child: Text(l.premiumRestore),
          ),
          const SizedBox(height: 8),
          Text(l.premiumLegal, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
