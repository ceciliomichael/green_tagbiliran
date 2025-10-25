import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Custom Material localizations delegate that provides English fallback for unsupported locales
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true; // Support all locales

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    // For Cebuano or any unsupported locale, use English
    final supportedLocale =
        locale.languageCode == 'ceb' ? const Locale('en') : locale;
    return GlobalMaterialLocalizations.delegate.load(supportedLocale);
  }

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

