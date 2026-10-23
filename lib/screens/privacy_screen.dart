import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../services/notifications.dart';
import '../state/settings.dart';
import '../widgets/parental_gate.dart';

/// 連絡先。公開時に `--dart-define=CONTACT_EMAIL=...` で渡す（未指定なら表示しない）。
const contactEmail = String.fromEnvironment('CONTACT_EMAIL');
const appVersion = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final band = ref.read(settingsProvider).ageBand;
    if (band != null && band.isChild) {
      final ok = await showParentalGate(context);
      if (!ok || !context.mounted) return;
    }
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.privacyDeleteTitle),
        content: Text(l.privacyDeleteBody),
        actions: [
          TextButton(
            key: const Key('privacy_delete_cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.privacyDeleteCancel),
          ),
          FilledButton(
            key: const Key('privacy_delete_confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.privacyDeleteConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final notifications = ref.read(notificationServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    final deleted = l.privacyDeleted;
    await notifications.cancelAll();
    await ref.read(settingsProvider.notifier).resetAll();
    messenger.showSnackBar(SnackBar(content: Text(deleted)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final points = [
      l.privacyPointLocal,
      l.privacyPointBirthYear,
      l.privacyPointNoAds,
      l.privacyPointChildren,
      l.privacyPointTeenAdult,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(l.privacyTitle),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.privacyDataHeading, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final p in points)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('・'),
                  Expanded(child: Text(p)),
                ],
              ),
            ),
          const SizedBox(height: 16),
          if (contactEmail.isNotEmpty) Text(l.privacyContact(contactEmail)),
          Text(l.privacyVersion(appVersion), style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          ListTile(
            key: const Key('privacy_licenses'),
            contentPadding: EdgeInsets.zero,
            title: Text(l.privacyLicenses),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(context: context, applicationVersion: appVersion),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            key: const Key('privacy_delete'),
            style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
            onPressed: () => _delete(context, ref),
            icon: const Icon(Icons.delete_outline),
            label: Text(l.privacyDeleteButton),
          ),
        ],
      ),
    );
  }
}
