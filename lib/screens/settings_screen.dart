import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'locale_changer.dart';
import '../providers/fidelity_cards_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _sourceUrl = 'https://github.com/gportente/tesserotto';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final loc = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    const supportedLocales = [Locale('en'), Locale('it')];

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // ── Appearance ──────────────────────────────────────────────
          _group(context, p, [
            _themeSelector(context, ref, loc, p, settings.themeMode),
            _divider(p),
            SwitchListTile(
              title: Text(loc.autoBrightness, style: context.text.titleMedium),
              subtitle: Text(loc.autoBrightnessSubtitle),
              value: settings.autoBrightness,
              onChanged: (v) =>
                  ref.read(settingsProvider.notifier).setAutoBrightness(v),
              secondary: _leadingIcon(p, Icons.brightness_high_rounded),
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

          // ── Data ────────────────────────────────────────────────────
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
          const SizedBox(height: AppSpacing.lg),

          // ── About ───────────────────────────────────────────────────
          _sectionHeader(context, loc.about),
          _group(context, p, [
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final v = snapshot.hasData
                    ? '${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                    : '—';
                return ListTile(
                  leading: _leadingIcon(p, Icons.info_outline_rounded),
                  title: Text(loc.version, style: context.text.titleMedium),
                  trailing: Text(v, style: context.text.bodyMedium),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                );
              },
            ),
            _divider(p),
            ListTile(
              leading: _leadingIcon(p, Icons.description_outlined),
              title: Text(loc.licenses, style: context.text.titleMedium),
              trailing: Icon(Icons.chevron_right_rounded, color: p.inkFaint),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
              onTap: () async {
                final info = await PackageInfo.fromPlatform();
                if (!context.mounted) return;
                showLicensePage(
                  context: context,
                  applicationName: loc.appTitle,
                  applicationVersion: info.version,
                );
              },
            ),
            _divider(p),
            ListTile(
              leading: _leadingIcon(p, Icons.code_rounded),
              title: Text(loc.sourceCode, style: context.text.titleMedium),
              subtitle: Text(_sourceUrl),
              trailing: Icon(Icons.copy_rounded, color: p.inkFaint, size: 20),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
              onTap: () async {
                await Clipboard.setData(const ClipboardData(text: _sourceUrl));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.copied)),
                  );
                }
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _themeSelector(BuildContext context, WidgetRef ref,
      AppLocalizations loc, AppPalette p, ThemeMode mode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _leadingIcon(p, Icons.palette_outlined),
              const SizedBox(width: AppSpacing.lg),
              Text(loc.theme, style: context.text.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                    value: ThemeMode.system,
                    icon: const Icon(Icons.brightness_auto_rounded, size: 18),
                    label: Text(loc.themeSystem)),
                ButtonSegment(
                    value: ThemeMode.light,
                    icon: const Icon(Icons.light_mode_rounded, size: 18),
                    label: Text(loc.themeLight)),
                ButtonSegment(
                    value: ThemeMode.dark,
                    icon: const Icon(Icons.dark_mode_rounded, size: 18),
                    label: Text(loc.themeDark)),
              ],
              selected: {mode},
              showSelectedIcon: false,
              onSelectionChanged: (s) =>
                  ref.read(settingsProvider.notifier).setThemeMode(s.first),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) =>
                    states.contains(WidgetState.selected)
                        ? p.accentSoft
                        : Colors.transparent),
                foregroundColor: WidgetStateProperty.resolveWith((states) =>
                    states.contains(WidgetState.selected) ? p.accent : p.inkSoft),
                side: WidgetStatePropertyAll(BorderSide(color: p.hairline)),
                textStyle: WidgetStatePropertyAll(context.text.labelMedium),
              ),
            ),
          ),
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

  Widget _sectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(
          left: AppSpacing.sm, bottom: AppSpacing.sm, top: AppSpacing.xs),
      child: Text(text,
          style: context.text.labelMedium
              ?.copyWith(color: context.palette.inkFaint)),
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
      color: p.hairline,
      height: 1,
      indent: AppSpacing.lg,
      endIndent: AppSpacing.lg);

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
