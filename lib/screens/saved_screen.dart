import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/illustration.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final saved = ref.watch(settingsProvider.select((s) => s.saved));
    final repo = ref.watch(triviaRepositoryProvider);
    final resolve = ref.watch(levelResolverProvider);

    final rows = <Widget>[];
    for (final id in saved) {
      final item = repo.byId(id);
      final level = item == null ? null : resolve(item);
      if (item == null || level == null) continue;
      rows.add(ListTile(
        leading: TriviaIllustration(id: item.illustration, size: 32),
        title: Text(level.title),
        onTap: () => context.push('/detail/${item.id}'),
      ));
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.savedTitle)),
      body: rows.isEmpty
          ? Center(child: Text(l.savedEmpty))
          : ListView(children: rows),
    );
  }
}
