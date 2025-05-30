import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// This is the assumed path for the generated localization file.
// If 'flutter_gen' is not recognized, it might need to be created conceptually
// or use a placeholder like 'package:your_app_name/generated/l10n.dart'
// and note this assumption. For now, we'll use the standard one.
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'dashboard_screen.dart'; // Assuming dashboard_screen.dart is in lib

// GlobalKey to access MyApp's state for changing locale
final GlobalKey<_MyAppState> myAppKey = GlobalKey();

void main() {
  runApp(MyApp(key: myAppKey));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  // Static method to allow changing locale from anywhere
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en'); // Default locale

  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clinic Manager', // This will be localized later if needed
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate, // Generated delegate
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales, // Generated list
      // Example: home screen
      home: const DashboardScreen(),
    );
  }
}
```
