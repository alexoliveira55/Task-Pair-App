import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.language,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          RadioListTile<Locale?>(
            title: Text(l10n.systemDefault),
            value: null,
            groupValue: currentLocale,
            onChanged: (_) =>
                ref.read(localeProvider.notifier).setSystemDefault(),
          ),
          RadioListTile<Locale?>(
            title: Text(l10n.portuguese),
            subtitle: const Text('Português (Brasil)'),
            value: const Locale('pt', 'BR'),
            groupValue: currentLocale,
            onChanged: (_) => ref
                .read(localeProvider.notifier)
                .setLocale(const Locale('pt', 'BR')),
          ),
          RadioListTile<Locale?>(
            title: Text(l10n.english),
            subtitle: const Text('English'),
            value: const Locale('en'),
            groupValue: currentLocale,
            onChanged: (_) =>
                ref.read(localeProvider.notifier).setLocale(const Locale('en')),
          ),
        ],
      ),
    );
  }
}
