import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'app_language';
  
  // Supported locales
  static const Locale english = Locale('en');
  static const Locale cebuano = Locale('ceb');
  
  static const List<Locale> supportedLocales = [english, cebuano];
  
  /// Get the saved locale from SharedPreferences
  static Future<Locale?> getSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      
      if (languageCode == null) {
        return null; // Use system default
      }
      
      return Locale(languageCode);
    } catch (e) {
      return null;
    }
  }
  
  /// Save the selected locale to SharedPreferences
  static Future<bool> saveLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_languageKey, locale.languageCode);
    } catch (e) {
      return false;
    }
  }
  
  /// Clear the saved locale (revert to system default)
  static Future<bool> clearSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_languageKey);
    } catch (e) {
      return false;
    }
  }
  
  /// Get locale display name
  static String getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'ceb':
        return 'Cebuano';
      default:
        return locale.languageCode.toUpperCase();
    }
  }
}


