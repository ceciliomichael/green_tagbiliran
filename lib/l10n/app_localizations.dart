import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ceb.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ceb'),
    Locale('en'),
    Locale('tl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Green Tagbilaran'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTrack.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get navTrack;

  /// No description provided for @navRecycle.
  ///
  /// In en, this message translates to:
  /// **'Recycle'**
  String get navRecycle;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homeClickAndComplaint.
  ///
  /// In en, this message translates to:
  /// **'Click & Complaint'**
  String get homeClickAndComplaint;

  /// No description provided for @nextCollection.
  ///
  /// In en, this message translates to:
  /// **'Next Collection'**
  String get nextCollection;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow ({day})'**
  String tomorrow(String day);

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'{day} ({days} days)'**
  String nextDay(String day, int days);

  /// No description provided for @nextDayNext.
  ///
  /// In en, this message translates to:
  /// **'Next {day}'**
  String nextDayNext(String day);

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your journey'**
  String get signInToContinue;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing In...'**
  String get signingIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinUs.
  ///
  /// In en, this message translates to:
  /// **'Join us and start your eco-friendly journey'**
  String get joinUs;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating Account...'**
  String get creatingAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @barangayTagbilaran.
  ///
  /// In en, this message translates to:
  /// **'Barangay (Tagbilaran City)'**
  String get barangayTagbilaran;

  /// No description provided for @selectYourBarangay.
  ///
  /// In en, this message translates to:
  /// **'Select Your Barangay'**
  String get selectYourBarangay;

  /// No description provided for @tagbilaranCityBohol.
  ///
  /// In en, this message translates to:
  /// **'Tagbilaran City, Bohol'**
  String get tagbilaranCityBohol;

  /// No description provided for @wasteManagementHub.
  ///
  /// In en, this message translates to:
  /// **'Waste Management Hub'**
  String get wasteManagementHub;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onb1Title.
  ///
  /// In en, this message translates to:
  /// **'Track your garbage truck'**
  String get onb1Title;

  /// No description provided for @onb1Desc.
  ///
  /// In en, this message translates to:
  /// **'Know where the garbage truck is and don\'t miss to dump your trash'**
  String get onb1Desc;

  /// No description provided for @onb2Title.
  ///
  /// In en, this message translates to:
  /// **'Click & Upload'**
  String get onb2Title;

  /// No description provided for @onb2Desc.
  ///
  /// In en, this message translates to:
  /// **'Click and upload anytime, anywhere and your complaint will be filed'**
  String get onb2Desc;

  /// No description provided for @onb3Title.
  ///
  /// In en, this message translates to:
  /// **'3R\'s for Life'**
  String get onb3Title;

  /// No description provided for @onb3Desc.
  ///
  /// In en, this message translates to:
  /// **'Segregate your waste and learn'**
  String get onb3Desc;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// No description provided for @issueStatus.
  ///
  /// In en, this message translates to:
  /// **'Report Status'**
  String get issueStatus;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @eventsReminders.
  ///
  /// In en, this message translates to:
  /// **'Events & Reminders'**
  String get eventsReminders;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirmLogoutMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout from your account?'**
  String get confirmLogoutMsg;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @reportStatus.
  ///
  /// In en, this message translates to:
  /// **'Report Status'**
  String get reportStatus;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @cebuano.
  ///
  /// In en, this message translates to:
  /// **'Cebuano'**
  String get cebuano;

  /// No description provided for @tagalog.
  ///
  /// In en, this message translates to:
  /// **'Tagalog'**
  String get tagalog;

  /// No description provided for @adminAccess.
  ///
  /// In en, this message translates to:
  /// **'Admin Access'**
  String get adminAccess;

  /// No description provided for @adminAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Access administrative controls and management features'**
  String get adminAccessDesc;

  /// No description provided for @enterAdminPanel.
  ///
  /// In en, this message translates to:
  /// **'Enter Admin Panel'**
  String get enterAdminPanel;

  /// No description provided for @truckDriverAccess.
  ///
  /// In en, this message translates to:
  /// **'Truck Driver Access'**
  String get truckDriverAccess;

  /// No description provided for @truckDriverAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Truck drivers should use their assigned phone number and password to sign in above. Your account is created by the admin.'**
  String get truckDriverAccessDesc;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcome(String name);

  /// No description provided for @barangay.
  ///
  /// In en, this message translates to:
  /// **'Barangay {name}'**
  String barangay(String name);

  /// No description provided for @welcomeBackUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}!'**
  String welcomeBackUser(String name);

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySunday;

  /// No description provided for @noScheduleAvailable.
  ///
  /// In en, this message translates to:
  /// **'No schedule available'**
  String get noScheduleAvailable;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Green Tagbilaran v1.0.0'**
  String get appVersion;

  /// No description provided for @wasteSegregationGuide.
  ///
  /// In en, this message translates to:
  /// **'Waste Segregation Guide'**
  String get wasteSegregationGuide;

  /// No description provided for @learnProperWasteSeparation.
  ///
  /// In en, this message translates to:
  /// **'Learn proper waste separation techniques'**
  String get learnProperWasteSeparation;

  /// No description provided for @garbageTruckTracking.
  ///
  /// In en, this message translates to:
  /// **'Garbage Truck Tracking'**
  String get garbageTruckTracking;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @truckStatus.
  ///
  /// In en, this message translates to:
  /// **'Truck Status'**
  String get truckStatus;

  /// No description provided for @activeCollectionRoute.
  ///
  /// In en, this message translates to:
  /// **'Active Collection Route'**
  String get activeCollectionRoute;

  /// No description provided for @biodegradable.
  ///
  /// In en, this message translates to:
  /// **'Biodegradable'**
  String get biodegradable;

  /// No description provided for @nonBiodegradable.
  ///
  /// In en, this message translates to:
  /// **'Non-Biodegradable'**
  String get nonBiodegradable;

  /// No description provided for @recyclable.
  ///
  /// In en, this message translates to:
  /// **'Recyclable'**
  String get recyclable;

  /// No description provided for @hazardous.
  ///
  /// In en, this message translates to:
  /// **'Hazardous'**
  String get hazardous;

  /// No description provided for @biodegradableDesc.
  ///
  /// In en, this message translates to:
  /// **'Organic waste that naturally decomposes'**
  String get biodegradableDesc;

  /// No description provided for @nonBiodegradableDesc.
  ///
  /// In en, this message translates to:
  /// **'Materials that do not decompose naturally'**
  String get nonBiodegradableDesc;

  /// No description provided for @recyclableDesc.
  ///
  /// In en, this message translates to:
  /// **'Materials that can be processed into new products'**
  String get recyclableDesc;

  /// No description provided for @hazardousDesc.
  ///
  /// In en, this message translates to:
  /// **'Dangerous materials requiring special handling'**
  String get hazardousDesc;

  /// No description provided for @identifyBiodegradableItems.
  ///
  /// In en, this message translates to:
  /// **'Identify Biodegradable Items'**
  String get identifyBiodegradableItems;

  /// No description provided for @identifyBiodegradableItemsDesc.
  ///
  /// In en, this message translates to:
  /// **'Look for organic materials that can decompose naturally'**
  String get identifyBiodegradableItemsDesc;

  /// No description provided for @cleanFoodContainers.
  ///
  /// In en, this message translates to:
  /// **'Clean Food Containers'**
  String get cleanFoodContainers;

  /// No description provided for @cleanFoodContainersDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove any food residue from containers before disposal'**
  String get cleanFoodContainersDesc;

  /// No description provided for @separateFromOtherWaste.
  ///
  /// In en, this message translates to:
  /// **'Separate from Other Waste'**
  String get separateFromOtherWaste;

  /// No description provided for @separateFromOtherWasteDesc.
  ///
  /// In en, this message translates to:
  /// **'Place biodegradable items in designated green bins'**
  String get separateFromOtherWasteDesc;

  /// No description provided for @properStorage.
  ///
  /// In en, this message translates to:
  /// **'Proper Storage'**
  String get properStorage;

  /// No description provided for @properStorageDesc.
  ///
  /// In en, this message translates to:
  /// **'Store biodegradable waste correctly to prevent odors'**
  String get properStorageDesc;

  /// No description provided for @identifyNonBiodegradableItems.
  ///
  /// In en, this message translates to:
  /// **'Identify Non-Biodegradable Items'**
  String get identifyNonBiodegradableItems;

  /// No description provided for @identifyNonBiodegradableItemsDesc.
  ///
  /// In en, this message translates to:
  /// **'Recognize materials that cannot decompose naturally'**
  String get identifyNonBiodegradableItemsDesc;

  /// No description provided for @cleanAndPrepare.
  ///
  /// In en, this message translates to:
  /// **'Clean and Prepare'**
  String get cleanAndPrepare;

  /// No description provided for @cleanAndPrepareDesc.
  ///
  /// In en, this message translates to:
  /// **'Clean items before disposal to prevent contamination'**
  String get cleanAndPrepareDesc;

  /// No description provided for @sortByMaterialType.
  ///
  /// In en, this message translates to:
  /// **'Sort by Material Type'**
  String get sortByMaterialType;

  /// No description provided for @sortByMaterialTypeDesc.
  ///
  /// In en, this message translates to:
  /// **'Group similar materials together for proper processing'**
  String get sortByMaterialTypeDesc;

  /// No description provided for @useDesignatedBins.
  ///
  /// In en, this message translates to:
  /// **'Use Designated Bins'**
  String get useDesignatedBins;

  /// No description provided for @useDesignatedBinsDesc.
  ///
  /// In en, this message translates to:
  /// **'Place items in appropriate non-biodegradable waste bins'**
  String get useDesignatedBinsDesc;

  /// No description provided for @checkRecyclingSymbols.
  ///
  /// In en, this message translates to:
  /// **'Check Recycling Symbols'**
  String get checkRecyclingSymbols;

  /// No description provided for @checkRecyclingSymbolsDesc.
  ///
  /// In en, this message translates to:
  /// **'Look for recycling symbols and numbers on items'**
  String get checkRecyclingSymbolsDesc;

  /// No description provided for @cleanThoroughly.
  ///
  /// In en, this message translates to:
  /// **'Clean Thoroughly'**
  String get cleanThoroughly;

  /// No description provided for @cleanThoroughlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Clean all recyclable items to remove contaminants'**
  String get cleanThoroughlyDesc;

  /// No description provided for @separateByCategory.
  ///
  /// In en, this message translates to:
  /// **'Separate by Category'**
  String get separateByCategory;

  /// No description provided for @separateByCategoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Sort recyclables into proper categories'**
  String get separateByCategoryDesc;

  /// No description provided for @prepareForCollection.
  ///
  /// In en, this message translates to:
  /// **'Prepare for Collection'**
  String get prepareForCollection;

  /// No description provided for @prepareForCollectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Package recyclables correctly for pickup'**
  String get prepareForCollectionDesc;

  /// No description provided for @identifyHazardousMaterials.
  ///
  /// In en, this message translates to:
  /// **'Identify Hazardous Materials'**
  String get identifyHazardousMaterials;

  /// No description provided for @identifyHazardousMaterialsDesc.
  ///
  /// In en, this message translates to:
  /// **'Recognize items that pose health or environmental risks'**
  String get identifyHazardousMaterialsDesc;

  /// No description provided for @handleWithCare.
  ///
  /// In en, this message translates to:
  /// **'Handle with Care'**
  String get handleWithCare;

  /// No description provided for @handleWithCareDesc.
  ///
  /// In en, this message translates to:
  /// **'Use proper safety precautions when handling'**
  String get handleWithCareDesc;

  /// No description provided for @keepOriginalContainers.
  ///
  /// In en, this message translates to:
  /// **'Keep Original Containers'**
  String get keepOriginalContainers;

  /// No description provided for @keepOriginalContainersDesc.
  ///
  /// In en, this message translates to:
  /// **'Store hazardous items in their original packaging'**
  String get keepOriginalContainersDesc;

  /// No description provided for @findSpecialCollectionPoints.
  ///
  /// In en, this message translates to:
  /// **'Find Special Collection Points'**
  String get findSpecialCollectionPoints;

  /// No description provided for @findSpecialCollectionPointsDesc.
  ///
  /// In en, this message translates to:
  /// **'Locate authorized disposal facilities'**
  String get findSpecialCollectionPointsDesc;

  /// No description provided for @exampleFoodScraps.
  ///
  /// In en, this message translates to:
  /// **'Food scraps'**
  String get exampleFoodScraps;

  /// No description provided for @exampleFruitPeels.
  ///
  /// In en, this message translates to:
  /// **'Fruit peels'**
  String get exampleFruitPeels;

  /// No description provided for @exampleVegetableWaste.
  ///
  /// In en, this message translates to:
  /// **'Vegetable waste'**
  String get exampleVegetableWaste;

  /// No description provided for @exampleGardenTrimmings.
  ///
  /// In en, this message translates to:
  /// **'Garden trimmings'**
  String get exampleGardenTrimmings;

  /// No description provided for @examplePaper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get examplePaper;

  /// No description provided for @exampleCardboard.
  ///
  /// In en, this message translates to:
  /// **'Cardboard'**
  String get exampleCardboard;

  /// No description provided for @exampleRinseContainers.
  ///
  /// In en, this message translates to:
  /// **'Rinse containers'**
  String get exampleRinseContainers;

  /// No description provided for @exampleRemoveLabels.
  ///
  /// In en, this message translates to:
  /// **'Remove labels if possible'**
  String get exampleRemoveLabels;

  /// No description provided for @exampleScrapeFood.
  ///
  /// In en, this message translates to:
  /// **'Scrape off remaining food'**
  String get exampleScrapeFood;

  /// No description provided for @exampleGreenBins.
  ///
  /// In en, this message translates to:
  /// **'Use green or brown bins'**
  String get exampleGreenBins;

  /// No description provided for @exampleKeepDrySeparate.
  ///
  /// In en, this message translates to:
  /// **'Keep dry items separate from wet'**
  String get exampleKeepDrySeparate;

  /// No description provided for @exampleLayerMaterials.
  ///
  /// In en, this message translates to:
  /// **'Layer materials properly'**
  String get exampleLayerMaterials;

  /// No description provided for @exampleLinedBins.
  ///
  /// In en, this message translates to:
  /// **'Use lined bins'**
  String get exampleLinedBins;

  /// No description provided for @exampleEmptyRegularly.
  ///
  /// In en, this message translates to:
  /// **'Empty regularly'**
  String get exampleEmptyRegularly;

  /// No description provided for @exampleCoolPlace.
  ///
  /// In en, this message translates to:
  /// **'Keep in cool, dry place'**
  String get exampleCoolPlace;

  /// No description provided for @examplePlasticBags.
  ///
  /// In en, this message translates to:
  /// **'Plastic bags'**
  String get examplePlasticBags;

  /// No description provided for @exampleStyrofoam.
  ///
  /// In en, this message translates to:
  /// **'Styrofoam'**
  String get exampleStyrofoam;

  /// No description provided for @exampleRubberItems.
  ///
  /// In en, this message translates to:
  /// **'Rubber items'**
  String get exampleRubberItems;

  /// No description provided for @exampleMetalCans.
  ///
  /// In en, this message translates to:
  /// **'Metal cans'**
  String get exampleMetalCans;

  /// No description provided for @exampleGlassBottles.
  ///
  /// In en, this message translates to:
  /// **'Glass bottles'**
  String get exampleGlassBottles;

  /// No description provided for @exampleRemoveCaps.
  ///
  /// In en, this message translates to:
  /// **'Remove caps and lids'**
  String get exampleRemoveCaps;

  /// No description provided for @exampleDryThoroughly.
  ///
  /// In en, this message translates to:
  /// **'Dry thoroughly'**
  String get exampleDryThoroughly;

  /// No description provided for @exampleSeparatePlastics.
  ///
  /// In en, this message translates to:
  /// **'Separate plastics by type'**
  String get exampleSeparatePlastics;

  /// No description provided for @exampleGroupMetal.
  ///
  /// In en, this message translates to:
  /// **'Group metal items'**
  String get exampleGroupMetal;

  /// No description provided for @exampleKeepGlassSeparate.
  ///
  /// In en, this message translates to:
  /// **'Keep glass separate'**
  String get exampleKeepGlassSeparate;

  /// No description provided for @exampleRedBins.
  ///
  /// In en, this message translates to:
  /// **'Use red or black bins'**
  String get exampleRedBins;

  /// No description provided for @exampleFollowGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Follow local guidelines'**
  String get exampleFollowGuidelines;

  /// No description provided for @exampleAvoidOverpacking.
  ///
  /// In en, this message translates to:
  /// **'Avoid overpacking'**
  String get exampleAvoidOverpacking;

  /// No description provided for @examplePlasticNumbers.
  ///
  /// In en, this message translates to:
  /// **'Plastic numbers 1-7'**
  String get examplePlasticNumbers;

  /// No description provided for @exampleRecyclingSymbol.
  ///
  /// In en, this message translates to:
  /// **'Recycling arrows symbol'**
  String get exampleRecyclingSymbol;

  /// No description provided for @exampleMaterialCodes.
  ///
  /// In en, this message translates to:
  /// **'Material identification codes'**
  String get exampleMaterialCodes;

  /// No description provided for @exampleRemoveFoodResidue.
  ///
  /// In en, this message translates to:
  /// **'Remove food residue'**
  String get exampleRemoveFoodResidue;

  /// No description provided for @exampleRinseWater.
  ///
  /// In en, this message translates to:
  /// **'Rinse with water'**
  String get exampleRinseWater;

  /// No description provided for @exampleRemoveTape.
  ///
  /// In en, this message translates to:
  /// **'Remove tape and stickers'**
  String get exampleRemoveTape;

  /// No description provided for @examplePaperProducts.
  ///
  /// In en, this message translates to:
  /// **'Paper products'**
  String get examplePaperProducts;

  /// No description provided for @examplePlasticContainers.
  ///
  /// In en, this message translates to:
  /// **'Plastic containers'**
  String get examplePlasticContainers;

  /// No description provided for @exampleRecyclingBins.
  ///
  /// In en, this message translates to:
  /// **'Use recycling bins'**
  String get exampleRecyclingBins;

  /// No description provided for @exampleFlattenCardboard.
  ///
  /// In en, this message translates to:
  /// **'Flatten cardboard'**
  String get exampleFlattenCardboard;

  /// No description provided for @exampleBundlePaper.
  ///
  /// In en, this message translates to:
  /// **'Bundle paper materials'**
  String get exampleBundlePaper;

  /// No description provided for @exampleBatteries.
  ///
  /// In en, this message translates to:
  /// **'Batteries'**
  String get exampleBatteries;

  /// No description provided for @examplePaintCans.
  ///
  /// In en, this message translates to:
  /// **'Paint cans'**
  String get examplePaintCans;

  /// No description provided for @exampleChemicals.
  ///
  /// In en, this message translates to:
  /// **'Chemicals'**
  String get exampleChemicals;

  /// No description provided for @exampleLightBulbs.
  ///
  /// In en, this message translates to:
  /// **'Light bulbs'**
  String get exampleLightBulbs;

  /// No description provided for @exampleElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get exampleElectronics;

  /// No description provided for @exampleWearGloves.
  ///
  /// In en, this message translates to:
  /// **'Wear gloves'**
  String get exampleWearGloves;

  /// No description provided for @exampleAvoidContact.
  ///
  /// In en, this message translates to:
  /// **'Avoid direct contact'**
  String get exampleAvoidContact;

  /// No description provided for @exampleVentilatedArea.
  ///
  /// In en, this message translates to:
  /// **'Work in ventilated area'**
  String get exampleVentilatedArea;

  /// No description provided for @exampleDontMixChemicals.
  ///
  /// In en, this message translates to:
  /// **'Do not mix chemicals'**
  String get exampleDontMixChemicals;

  /// No description provided for @exampleKeepLabels.
  ///
  /// In en, this message translates to:
  /// **'Keep labels intact'**
  String get exampleKeepLabels;

  /// No description provided for @exampleSecureContainers.
  ///
  /// In en, this message translates to:
  /// **'Secure containers'**
  String get exampleSecureContainers;

  /// No description provided for @exampleContactAuthorities.
  ///
  /// In en, this message translates to:
  /// **'Contact local authorities'**
  String get exampleContactAuthorities;

  /// No description provided for @exampleVisitCenters.
  ///
  /// In en, this message translates to:
  /// **'Visit collection centers'**
  String get exampleVisitCenters;

  /// No description provided for @exampleSchedulePickup.
  ///
  /// In en, this message translates to:
  /// **'Schedule pickup'**
  String get exampleSchedulePickup;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ceb', 'en', 'tl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

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
