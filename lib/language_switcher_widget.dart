import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Assumed path
import 'main.dart'; // To access MyApp.setLocale

class LanguageSwitcherWidget extends StatelessWidget {
  const LanguageSwitcherWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the AppLocalizations instance to access translated strings
    final appLocalizations = AppLocalizations.of(context)!;
    Locale currentLocale = Localizations.localeOf(context);

    // Create a list of locales and their display names using translated strings
    final Map<Locale, String> languageMap = {
      const Locale('en'): appLocalizations.english, // "English"
      const Locale('hi'): appLocalizations.hindi,   // "हिंदी"
      const Locale('gu'): appLocalizations.gujarati, // "ગુજરાતી"
    };

    return DropdownButton<Locale>(
      value: currentLocale,
      icon: const Icon(Icons.language),
      items: languageMap.entries.map((entry) {
        return DropdownMenuItem<Locale>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: (Locale? newLocale) {
        if (newLocale != null && newLocale != currentLocale) {
          MyApp.setLocale(context, newLocale);
        }
      },
    );
  }
}
```
