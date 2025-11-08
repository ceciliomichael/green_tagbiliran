import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// Delegate for loading localized resources
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ceb', 'en', 'tl'].contains(locale.languageCode);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

/// Lookup function to get the appropriate localization based on locale
AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ceb':
      return AppLocalizationsCeb();
    case 'en':
      return AppLocalizationsEn();
    case 'tl':
      return AppLocalizationsTl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

/// A list of this localizations delegate along with the default localizations
/// delegates.
///
/// Returns a list of localizations delegates containing this delegate along with
/// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
/// and GlobalWidgetsLocalizations.delegate.
///
/// Additional delegates can be added by appending to this list in
/// MaterialApp. This list does not have to be used at all if a custom list
/// of delegates is preferred or required.
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates =
    <LocalizationsDelegate<dynamic>>[
  AppLocalizationsDelegate(),
  GlobalMaterialLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];

/// A list of supported locales
const List<Locale> supportedLocales = <Locale>[
  Locale('ceb'),
  Locale('en'),
  Locale('tl'),
];

