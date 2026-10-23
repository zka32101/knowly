import 'package:cross_promo_kit/cross_promo_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/age_band.dart';
import '../services/cross_promo_bootstrap.dart';
import '../state/settings.dart';
import '../widgets/parental_gate.dart';

const knowlyApplicationId = 'com.petitworks.knowly';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // 他アプリ紹介は Teen/Adult のみ。Kids/Junior では Firebase に接続しない。
    final band = ref.read(settingsProvider).ageBand;
    if (band != null && band.allowsPromo) {
      CrossPromoBootstrap.ensureInit();
    }
  }

  Future<void> _changeMode() async {
    final band = ref.read(settingsProvider).ageBand;
    // 子どもモードから他のモードへ変えるには保護者ゲートを通す。
    if (band != null && band.isChild) {
      final ok = await showParentalGate(context);
      if (!ok || !mounted) return;
    }
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<AgeBand>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final b in AgeBand.values)
              ListTile(
                key: Key('mode_${b.name}'),
                title: Text(modeLabel(l, b)),
                trailing: b == band ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(b),
              ),
          ],
        ),
      ),
    );
    if (picked != null) ref.read(settingsProvider.notifier).setAgeBand(picked);
  }

  Future<void> _openPremium() async {
    final band = ref.read(settingsProvider).ageBand;
    if (band != null && band.isChild) {
      final ok = await showParentalGate(context);
      if (!ok || !mounted) return;
    }
    if (mounted) context.push('/premium');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final band = settings.ageBand ?? AgeBand.adult;

    Widget languageTile(String title, String? value, void Function(String?) onChanged) =>
        ListTile(
          title: Text(title),
          subtitle: SegmentedButton<String?>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: null, label: Text(l.languageSystem)),
              ButtonSegment(value: 'ja', label: Text(l.languageJa)),
              ButtonSegment(value: 'en', label: Text(l.languageEn)),
            ],
            selected: {value},
            onSelectionChanged: (s) => onChanged(s.first),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        children: [
          languageTile(l.settingsUiLanguage, settings.uiLanguage, notifier.setUiLanguage),
          languageTile(l.settingsContentLanguage, settings.contentLanguage,
              notifier.setContentLanguage),
          ListTile(
            key: const Key('change_mode'),
            title: Text(l.settingsMode),
            subtitle: Text(
                '${modeLabel(l, band)}${band.isChild ? '\n${l.settingsModeNote}' : ''}'),
            isThreeLine: band.isChild,
            trailing: const Icon(Icons.chevron_right),
            onTap: _changeMode,
          ),
          ListTile(
            title: Text(l.settingsPremium),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openPremium,
          ),
          if (band.allowsPromo)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CrossPromoSection(
                currentAppId: knowlyApplicationId,
                title: l.settingsOtherApps,
              ),
            ),
          if (band.isChild)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l.settingsPrivacy, style: Theme.of(context).textTheme.bodySmall),
            ),
        ],
      ),
    );
  }
}
