/// Main AppLocalizations entry point
///
/// This file provides a clean interface for accessing localized strings.
/// The actual implementation is split across multiple files for better maintainability:
/// - app_localizations_base.dart: Abstract interface with organized sections
/// - app_localizations_delegate.dart: Delegate and lookup logic
/// - app_localizations_[lang].dart: Language-specific implementations
library;

export 'app_localizations_base.dart';
export 'app_localizations_delegate.dart';
export 'app_localizations_ceb.dart';
export 'app_localizations_en.dart';
export 'app_localizations_tl.dart';