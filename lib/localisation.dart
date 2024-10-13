import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  late Map<String, dynamic> _localizedStrings;

  Future<bool> load() async {
    // Load from assets/lang/.. first, if not found, load from lang/..
    String jsonString;
    try {
      jsonString = await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    } catch (e) {
      jsonString = await rootBundle.loadString('lang/${locale.languageCode}.json');
    }
    _localizedStrings = json.decode(jsonString);
    return true;
  }

  String translate(String key) {
    List<String> keys = key.split('.');
    dynamic value = _localizedStrings;

    for (String k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return 'Error $key'; // Return the key itself if translation is not found
      }
    }

    return value.toString();
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
