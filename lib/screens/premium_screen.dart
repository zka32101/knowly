import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// プレミアムの案内。購入処理（RevenueCat）は商品設定が済んでから接続する。
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.premiumTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final text in [l.premiumBenefit1, l.premiumBenefit2, l.premiumBenefit3])
            ListTile(leading: const Icon(Icons.check_circle_outline), title: Text(text)),
          const SizedBox(height: 16),
          Text(l.premiumKidsFree, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          FilledButton(onPressed: null, child: Text(l.premiumUnavailable)),
        ],
      ),
    );
  }
}
