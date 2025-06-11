import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyAppLocale {
  static void setLocale(BuildContext context, Locale newLocale) {
    MyLocaleChanger? state = context.findAncestorStateOfType<MyLocaleChanger>();
    state?.changeLocale(newLocale);
  }
}

class LocaleChanger extends StatefulWidget {
  final Widget child;
  const LocaleChanger({required this.child, super.key});
  @override
  MyLocaleChanger createState() => MyLocaleChanger();
}

class MyLocaleChanger extends State<LocaleChanger> {
  Locale? _locale;

  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('it'),
      ],
      home: widget.child,
    );
  }
} 