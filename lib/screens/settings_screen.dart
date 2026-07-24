import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'locale_changer.dart';
import '../providers/fidelity_cards_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final loc = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final isDark = settings.themeMode == ThemeMode.dark;
    const supportedLocales = [Locale('en'), Locale('it')];

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _group(context, p, [
            SwitchListTile(
              title: Text(loc.darkMode, style: context.text.titleMedium),
              value: isDark,
              onChanged: (val) => ref
                  .read(settingsProvider.notifier)
                  .setThemeMode(val ? ThemeMode.dark : ThemeMode.light),
              secondary: _leadingIcon(
                  p, isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            ),
            _divider(p),
            ListTile(
              leading: _leadingIcon(p, Icons.translate_rounded),
              title: Text(loc.language, style: context.text.titleMedium),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
              trailing: DropdownButton<Locale>(
                value: settings.locale,
                underline: const SizedBox.shrink(),
                borderRadius: BorderRadius.circular(AppRadius.md),
                items: supportedLocales
                    .map((locale) => DropdownMenuItem<Locale>(
                          value: locale,
                          child: Text(locale.languageCode == 'en'
                              ? 'English'
                              : 'Italiano'),
                        ))
                    .toList(),
                onChanged: (locale) {
                  if (locale != null) {
                    ref.read(settingsProvider.notifier).setLocale(locale);
                    MyAppLocale.setLocale(context, locale);
                  }
                },
              ),
            ),
          ]),
          const SizedBox(height: AppSpacing.lg),
          _group(context, p, [
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: p.danger.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.delete_forever_rounded, color: p.danger),
              ),
              title: Text(loc.deleteAllCardsTitle,
                  style: context.text.titleMedium?.copyWith(color: p.danger)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
              onTap: () => _confirmDeleteAll(context, ref, loc),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _group(BuildContext context, AppPalette p, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: p.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _leadingIcon(AppPalette p, IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: p.accentSoft,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(icon, color: p.accent),
    );
  }

  Widget _divider(AppPalette p) => Divider(
      color: p.hairline, height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg);

  Future<void> _confirmDeleteAll(
      BuildContext context, WidgetRef ref, AppLocalizations loc) async {
    final p = context.palette;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.deleteAllCardsTitle),
        content: Text(loc.deleteAllCardsContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.deleteCardCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: p.danger,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.deleteCardConfirm),
          ),
        ],
      ),
    );
    if (confirm == true) {
      ref.read(fidelityCardsProvider.notifier).clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.deleteAllCardsConfirm)),
        );
      }
    }
  }
}
