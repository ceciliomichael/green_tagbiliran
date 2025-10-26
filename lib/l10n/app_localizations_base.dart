import 'package:flutter/widgets.dart';
import 'app_localizations_delegate.dart' as delegate_lib;

// ignore_for_file: type=lint

/// Base abstract class containing all localization getters
/// 
/// This class defines the interface that all language implementations must follow.
/// Split into logical sections for better organization.
abstract class AppLocalizations {
  AppLocalizations(this.localeName);

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// The delegate for loading localized resources
  /// Backwards compatibility with original generated code
  static const delegate_lib.AppLocalizationsDelegate delegate = delegate_lib.AppLocalizationsDelegate();

  /// List of supported locales
  /// Backwards compatibility with original generated code  
  static const List<Locale> supportedLocales = delegate_lib.supportedLocales;

  // ============================================================================
  // App General
  // ============================================================================

  /// App title
  String get appTitle;

  /// App version info
  String get appVersion;

  // ============================================================================
  // Navigation
  // ============================================================================

  /// Bottom navigation: Home
  String get navHome;

  /// Bottom navigation: Track
  String get navTrack;

  /// Bottom navigation: Recycle
  String get navRecycle;

  /// Bottom navigation: Profile
  String get navProfile;

  // ============================================================================
  // Authentication & Onboarding
  // ============================================================================

  String get loginTitle;
  String get registerTitle;
  String get welcomeBack;
  String get signInToContinue;
  String get signIn;
  String get signingIn;
  String get createAccount;
  String get joinUs;
  String get signUp;
  String get creatingAccount;
  String get dontHaveAccount;
  String get alreadyHaveAccount;
  String get phoneNumber;
  String get password;
  String get confirmPassword;
  String get firstName;
  String get lastName;
  String get barangayTagbilaran;
  String get selectYourBarangay;
  String get tagbilaranCityBohol;
  String get wasteManagementHub;

  // Onboarding
  String get onboardingSkip;
  String get onboardingNext;
  String get onboardingGetStarted;
  String get onb1Title;
  String get onb1Desc;
  String get onb2Title;
  String get onb2Desc;
  String get onb3Title;
  String get onb3Desc;

  // ============================================================================
  // Home Screen
  // ============================================================================

  String get homeTitle;
  String get homeClickAndComplaint;
  String get nextCollection;
  String tomorrow(String day);
  String nextDay(String day, int days);
  String nextDayNext(String day);

  // ============================================================================
  // Profile & Account
  // ============================================================================

  String get profile;
  String get accountInformation;
  String get fullName;
  String get memberSince;
  String get actions;
  String get logout;
  String get cancel;
  String get confirmLogoutMsg;
  String welcome(String name);
  String welcomeBackUser(String name);
  String barangay(String name);

  // Admin & Driver Access
  String get adminAccess;
  String get adminAccessDesc;
  String get enterAdminPanel;
  String get truckDriverAccess;
  String get truckDriverAccessDesc;

  // ============================================================================
  // Reports & Issues
  // ============================================================================

  String get reportIssue;
  String get issueStatus;
  String get reportStatus;

  // ============================================================================
  // Schedule & Events
  // ============================================================================

  String get schedule;
  String get eventsReminders;
  String get noScheduleAvailable;

  // Days of the week
  String get dayMonday;
  String get dayTuesday;
  String get dayWednesday;
  String get dayThursday;
  String get dayFriday;
  String get daySaturday;
  String get daySunday;

  // ============================================================================
  // Location & Tracking
  // ============================================================================

  String get location;
  String get garbageTruckTracking;
  String get live;
  String get truckStatus;
  String get activeCollectionRoute;

  // ============================================================================
  // Language Settings
  // ============================================================================

  String get language;
  String get selectLanguage;
  String get english;
  String get cebuano;
  String get tagalog;

  // ============================================================================
  // Help & Support
  // ============================================================================

  String get helpSupport;

  // ============================================================================
  // Waste Segregation Guide
  // ============================================================================

  String get wasteSegregationGuide;
  String get learnProperWasteSeparation;

  // Waste Categories
  String get biodegradable;
  String get nonBiodegradable;
  String get recyclable;
  String get hazardous;

  // Category Descriptions
  String get biodegradableDesc;
  String get nonBiodegradableDesc;
  String get recyclableDesc;
  String get hazardousDesc;

  // ============================================================================
  // Biodegradable Waste Steps
  // ============================================================================

  String get identifyBiodegradableItems;
  String get identifyBiodegradableItemsDesc;
  String get cleanFoodContainers;
  String get cleanFoodContainersDesc;
  String get separateFromOtherWaste;
  String get separateFromOtherWasteDesc;
  String get properStorage;
  String get properStorageDesc;

  // ============================================================================
  // Non-Biodegradable Waste Steps
  // ============================================================================

  String get identifyNonBiodegradableItems;
  String get identifyNonBiodegradableItemsDesc;
  String get cleanAndPrepare;
  String get cleanAndPrepareDesc;
  String get sortByMaterialType;
  String get sortByMaterialTypeDesc;
  String get useDesignatedBins;
  String get useDesignatedBinsDesc;

  // ============================================================================
  // Recyclable Waste Steps
  // ============================================================================

  String get checkRecyclingSymbols;
  String get checkRecyclingSymbolsDesc;
  String get cleanThoroughly;
  String get cleanThoroughlyDesc;
  String get separateByCategory;
  String get separateByCategoryDesc;
  String get prepareForCollection;
  String get prepareForCollectionDesc;

  // ============================================================================
  // Hazardous Waste Steps
  // ============================================================================

  String get identifyHazardousMaterials;
  String get identifyHazardousMaterialsDesc;
  String get handleWithCare;
  String get handleWithCareDesc;
  String get keepOriginalContainers;
  String get keepOriginalContainersDesc;
  String get findSpecialCollectionPoints;
  String get findSpecialCollectionPointsDesc;

  // ============================================================================
  // Biodegradable Examples
  // ============================================================================

  String get exampleFoodScraps;
  String get exampleFruitPeels;
  String get exampleVegetableWaste;
  String get exampleGardenTrimmings;
  String get examplePaper;
  String get exampleCardboard;
  String get exampleRinseContainers;
  String get exampleRemoveLabels;
  String get exampleScrapeFood;
  String get exampleGreenBins;
  String get exampleKeepDrySeparate;
  String get exampleLayerMaterials;
  String get exampleLinedBins;
  String get exampleEmptyRegularly;
  String get exampleCoolPlace;

  // ============================================================================
  // Non-Biodegradable Examples
  // ============================================================================

  String get examplePlasticBags;
  String get exampleStyrofoam;
  String get exampleRubberItems;
  String get exampleMetalCans;
  String get exampleGlassBottles;
  String get exampleRemoveCaps;
  String get exampleDryThoroughly;
  String get exampleSeparatePlastics;
  String get exampleGroupMetal;
  String get exampleKeepGlassSeparate;
  String get exampleRedBins;
  String get exampleFollowGuidelines;
  String get exampleAvoidOverpacking;

  // ============================================================================
  // Recyclable Examples
  // ============================================================================

  String get examplePlasticNumbers;
  String get exampleRecyclingSymbol;
  String get exampleMaterialCodes;
  String get exampleRemoveFoodResidue;
  String get exampleRinseWater;
  String get exampleRemoveTape;
  String get examplePaperProducts;
  String get examplePlasticContainers;
  String get exampleRecyclingBins;
  String get exampleFlattenCardboard;
  String get exampleBundlePaper;

  // ============================================================================
  // Hazardous Examples
  // ============================================================================

  String get exampleBatteries;
  String get examplePaintCans;
  String get exampleChemicals;
  String get exampleLightBulbs;
  String get exampleElectronics;
  String get exampleWearGloves;
  String get exampleAvoidContact;
  String get exampleVentilatedArea;
  String get exampleDontMixChemicals;
  String get exampleKeepLabels;
  String get exampleSecureContainers;
  String get exampleContactAuthorities;
  String get exampleVisitCenters;
  String get exampleSchedulePickup;
}

