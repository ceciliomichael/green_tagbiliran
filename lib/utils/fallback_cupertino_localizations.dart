import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Custom Cupertino localizations delegate that provides English fallback for unsupported locales
class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true; // Support all locales

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    // For Cebuano or any unsupported locale, use English
    final supportedLocale =
        locale.languageCode == 'ceb' ? const Locale('en') : locale;
    return GlobalCupertinoLocalizations.delegate.load(supportedLocale);
  }

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}

