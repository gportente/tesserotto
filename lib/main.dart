import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'database/database_helper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'screens/locale_changer.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/deep_link_handler.dart';

/// Global navigator key so widget/deep-link callbacks can navigate without a
/// BuildContext (e.g. when the app is launched from the home-screen widget).
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  if (Platform.isIOS) {
    await HomeWidget.setAppGroupId('group.com.gportente.tesserotto');
  }
  runApp(const ProviderScope(child: LocaleChanger(child: FidelityCardsApp())));
}

class FidelityCardsApp extends ConsumerWidget {
  const FidelityCardsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return DeepLinkHandler(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: AppLocalizations.of(context)?.appTitle ?? 'Tesserotto',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: settings.themeMode,
        locale: settings.locale,
        supportedLocales: const [
          Locale('en'),
          Locale('it'),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const HomeScreen(),
      ),
    );
  }
}
