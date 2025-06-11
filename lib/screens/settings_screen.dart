import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'locale_changer.dart';
import '../providers/fidelity_cards_provider.dart';
import 'import_export_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = settings.themeMode == ThemeMode.dark;
    const supportedLocales = [Locale('en'), Locale('it')];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.darkMode),
            value: isDark,
            onChanged: (val) {
              ref.read(settingsProvider.notifier).setThemeMode(
                val ? ThemeMode.dark : ThemeMode.light,
              );
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(AppLocalizations.of(context)!.language),
            trailing: DropdownButton<Locale>(
              value: settings.locale,
              items: supportedLocales.map((locale) {
                return DropdownMenuItem<Locale>(
                  value: locale,
                  child: Text(locale.languageCode == 'en' ? 'English' : 'Italiano'),
                );
              }).toList(),
              onChanged: (locale) {
                if (locale != null) {
                  ref.read(settingsProvider.notifier).setLocale(locale);
                  MyAppLocale.setLocale(context, locale);
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(
              AppLocalizations.of(context)!.deleteAllCardsTitle,
              style: const TextStyle(color: Color.fromRGBO(244, 67, 54, 1)),
            ),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.deleteAllCardsTitle),
                  content: Text(AppLocalizations.of(context)!.deleteAllCardsContent),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(AppLocalizations.of(context)!.deleteCardCancel),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(AppLocalizations.of(context)!.deleteCardConfirm),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                ref.read(fidelityCardsProvider.notifier).clearAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.deleteAllCardsConfirm)),
                );
              }
            },
          ),
        ],
      ),
    );
  }
} 