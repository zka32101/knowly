import 'package:cross_promo_kit/cross_promo_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../l10n/regions.dart';
import '../models/age_band.dart';
import '../services/cross_promo_bootstrap.dart';
import '../services/notifications.dart';
import '../state/settings.dart';
import '../widgets/parental_gate.dart';

const knowlyApplicationId = 'com.yourwish.knowly';

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

  Future<void> _toggleNotify(bool value) async {
    final l = AppLocalizations.of(context);
    final notifier = ref.read(settingsProvider.notifier);
    if (!value) {
      notifier.setNotifyEnabled(false);
      return;
    }
    // Junior は保護者が設定する。
    if (ref.read(settingsProvider).ageBand == AgeBand.junior) {
      final ok = await showParentalGate(context);
      if (!ok || !mounted) return;
    }
    final granted = await ref.read(notificationServiceProvider).requestPermission();
    if (!mounted) return;
    if (granted) {
      notifier.setNotifyEnabled(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.notifyDenied)));
    }
  }

  Future<void> _pickTime() async {
    final s = ref.read(settingsProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: s.notifyHour, minute: s.notifyMinute),
    );
    if (picked != null) {
      ref.read(settingsProvider.notifier).setNotifyTime(picked.hour, picked.minute);
    }
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
            title: Text(l.settingsRegion),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<String>(
                  key: const Key('region_dropdown'),
                  isExpanded: true,
                  value: regionNames.containsKey(settings.regionMode) ||
                          settings.regionMode == 'auto' ||
                          settings.regionMode == 'all'
                      ? settings.regionMode
                      : 'auto',
                  items: [
                    DropdownMenuItem(value: 'auto', child: Text(l.regionAuto)),
                    DropdownMenuItem(value: 'all', child: Text(l.regionAll)),
                    for (final code in regionNames.keys)
                      DropdownMenuItem(
                          value: code,
                          child: Text(regionName(code, ref.watch(uiLanguageProvider)))),
                  ],
                  onChanged: (v) {
                    if (v != null) notifier.setRegionMode(v);
                  },
                ),
                Text(l.regionNote, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          ListTile(
            title: Text(l.settingsSeason),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<String>(
                  key: const Key('season_mode'),
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: 'auto', label: Text(l.seasonAuto)),
                    ButtonSegment(value: 'north', label: Text(l.seasonNorth)),
                    ButtonSegment(value: 'south', label: Text(l.seasonSouth)),
                    ButtonSegment(value: 'off', label: Text(l.seasonOff)),
                  ],
                  selected: {settings.seasonMode},
                  onSelectionChanged: (s) => notifier.setSeasonMode(s.first),
                ),
                const SizedBox(height: 4),
                Text(l.seasonNote, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          // 通知は Kids にはない。Junior は保護者が設定する。
          if (band != AgeBand.kids) ...[
            SwitchListTile(
              key: const Key('notify_switch'),
              title: Text(l.notifyTitle),
              subtitle: Text(
                  band == AgeBand.junior ? l.notifyJuniorNote : l.notifySubtitle),
              value: settings.notifyEnabled,
              onChanged: _toggleNotify,
            ),
            if (settings.notifyEnabled)
              ListTile(
                key: const Key('notify_time'),
                title: Text(l.notifyTime),
                trailing: Text(
                    TimeOfDay(hour: settings.notifyHour, minute: settings.notifyMinute)
                        .format(context)),
                onTap: _pickTime,
              ),
          ],
          ListTile(
            key: const Key('change_mode'),
            title: Text(l.settingsMode),
            subtitle: Text(
                '${modeLabel(l, band)}${band.isChild ? '\n${l.settingsModeNote}' : ''}'),
            isThreeLine: band.isChild,
            trailing: const Icon(Icons.chevron_right),
            onTap: _changeMode,
          ),
          if (band != AgeBand.kids)
            ListTile(
              key: const Key('open_interests'),
              title: Text(l.settingsInterests),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/interests'),
            ),
          ListTile(
            title: Text(l.settingsPremium),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openPremium,
          ),
          if (band.isTeenOrAdult) _StatsTile(settings: settings),
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

class _StatsTile extends StatelessWidget {
  const _StatsTile({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final knew = settings.knowledge.values.where((k) => k == Knowledge.knew).length;
    final total = settings.knowledge.length;
    return ListTile(
      key: const Key('stats_tile'),
      title: Text(l.statsTitle),
      subtitle: Text(total == 0
          ? l.statsEmpty
          : l.statsKnowRate((knew * 100 / total).round(), knew, total)),
    );
  }
}
