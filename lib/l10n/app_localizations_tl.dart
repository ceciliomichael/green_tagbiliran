// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tagalog (`tl`).
class AppLocalizationsTl extends AppLocalizations {
  AppLocalizationsTl([String locale = 'tl']) : super(locale);

  @override
  String get appTitle => 'Green Tagbilaran';

  @override
  String get navHome => 'Home';

  @override
  String get navTrack => 'Subaybayan';

  @override
  String get navRecycle => 'Recycle';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeClickAndComplaint => 'I-click at Magreklamo';

  @override
  String get nextCollection => 'Susunod na Koleksyon';

  @override
  String tomorrow(String day) {
    return 'Bukas ($day)';
  }

  @override
  String nextDay(String day, int days) {
    return '$day ($days araw)';
  }

  @override
  String nextDayNext(String day) {
    return 'Susunod na $day';
  }

  @override
  String get loginTitle => 'Mag-login';

  @override
  String get registerTitle => 'Magrehistro';

  @override
  String get welcomeBack => 'Maligayang Pagbabalik';

  @override
  String get signInToContinue => 'Mag-sign in upang magpatuloy';

  @override
  String get signIn => 'Mag-sign In';

  @override
  String get signingIn => 'Nag-sign In...';

  @override
  String get createAccount => 'Gumawa ng Account';

  @override
  String get joinUs =>
      'Sumali sa amin at simulan ang iyong eco-friendly na paglalakbay';

  @override
  String get signUp => 'Mag-sign Up';

  @override
  String get creatingAccount => 'Gumagawa ng Account...';

  @override
  String get dontHaveAccount => 'Walang account?';

  @override
  String get alreadyHaveAccount => 'Mayroon nang account?';

  @override
  String get phoneNumber => 'Numero ng Telepono';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Kumpirmahin ang Password';

  @override
  String get firstName => 'Pangalan';

  @override
  String get lastName => 'Apelyido';

  @override
  String get barangayTagbilaran => 'Barangay (Lungsod ng Tagbilaran)';

  @override
  String get selectYourBarangay => 'Piliin ang Iyong Barangay';

  @override
  String get tagbilaranCityBohol => 'Lungsod ng Tagbilaran, Bohol';

  @override
  String get wasteManagementHub => 'Sentro ng Pamamahala ng Basura';

  @override
  String get onboardingSkip => 'Laktawan';

  @override
  String get onboardingNext => 'Susunod';

  @override
  String get onboardingGetStarted => 'Magsimula';

  @override
  String get onb1Title => 'Subaybayan ang trak ng basura';

  @override
  String get onb1Desc =>
      'Alamin kung nasaan ang trak ng basura at huwag palampasin ang pagtatapon';

  @override
  String get onb2Title => 'I-click at I-upload';

  @override
  String get onb2Desc =>
      'I-click at i-upload anumang oras, kahit saan at mai-file ang iyong reklamo';

  @override
  String get onb3Title => '3R para sa Buhay';

  @override
  String get onb3Desc => 'Paghiwalayin ang iyong basura at matuto';

  @override
  String get reportIssue => 'Mag-ulat ng Problema';

  @override
  String get issueStatus => 'Katayuan ng Ulat';

  @override
  String get schedule => 'Iskedyul';

  @override
  String get eventsReminders => 'Mga Kaganapan at Paalala';

  @override
  String get location => 'Lokasyon';

  @override
  String get helpSupport => 'Tulong at Suporta';

  @override
  String get logout => 'Mag-logout';

  @override
  String get cancel => 'Kanselahin';

  @override
  String get confirmLogoutMsg =>
      'Sigurado ka bang gusto mong mag-logout sa iyong account?';

  @override
  String get profile => 'Profile';

  @override
  String get accountInformation => 'Impormasyon ng Account';

  @override
  String get fullName => 'Buong Pangalan';

  @override
  String get memberSince => 'Miyembro Mula';

  @override
  String get actions => 'Mga Aksyon';

  @override
  String get reportStatus => 'Katayuan ng Ulat';

  @override
  String get language => 'Wika';

  @override
  String get selectLanguage => 'Pumili ng Wika';

  @override
  String get english => 'English';

  @override
  String get cebuano => 'Cebuano';

  @override
  String get tagalog => 'Tagalog';

  @override
  String get adminAccess => 'Admin Access';

  @override
  String get adminAccessDesc =>
      'I-access ang mga kontrol ng admin at mga feature ng pamamahala';

  @override
  String get enterAdminPanel => 'Pumasok sa Admin Panel';

  @override
  String get truckDriverAccess => 'Truck Driver Access';

  @override
  String get truckDriverAccessDesc =>
      'Ang mga trak driver ay dapat gumamit ng kanilang nakaassign na numero ng telepono at password upang mag-sign in sa itaas. Ang iyong account ay ginawa ng admin.';

  @override
  String welcome(String name) {
    return 'Maligayang pagdating, $name';
  }

  @override
  String barangay(String name) {
    return 'Barangay $name';
  }

  @override
  String welcomeBackUser(String name) {
    return 'Maligayang pagbabalik, $name!';
  }

  @override
  String get dayMonday => 'Lunes';

  @override
  String get dayTuesday => 'Martes';

  @override
  String get dayWednesday => 'Miyerkules';

  @override
  String get dayThursday => 'Huwebes';

  @override
  String get dayFriday => 'Biyernes';

  @override
  String get daySaturday => 'Sabado';

  @override
  String get daySunday => 'Linggo';

  @override
  String get noScheduleAvailable => 'Walang available na iskedyul';

  @override
  String get appVersion => 'Green Tagbilaran v1.0.0';

  @override
  String get wasteSegregationGuide => 'Gabay sa Paghihiwalay ng Basura';

  @override
  String get learnProperWasteSeparation =>
      'Matuto ng tamang diskarte sa paghihiwalay ng basura';

  @override
  String get garbageTruckTracking => 'Pagsubaybay sa Trak ng Basura';

  @override
  String get live => 'LIVE';

  @override
  String get truckStatus => 'Katayuan ng Trak';

  @override
  String get activeCollectionRoute => 'Aktibong Ruta ng Pagkolekta';

  @override
  String get biodegradable => 'Biodegradable';

  @override
  String get nonBiodegradable => 'Hindi Biodegradable';

  @override
  String get recyclable => 'Pwedeng I-recycle';

  @override
  String get hazardous => 'Mapanganib';

  @override
  String get biodegradableDesc => 'Organikong basura na natural na nabubulok';

  @override
  String get nonBiodegradableDesc =>
      'Mga materyales na hindi natural na nabubulok';

  @override
  String get recyclableDesc =>
      'Mga materyales na pwedeng iproseso tungo sa bagong produkto';

  @override
  String get hazardousDesc =>
      'Mapanganib na materyales na nangangailangan ng espesyal na paghawak';

  @override
  String get identifyBiodegradableItems =>
      'Kilalanin ang Biodegradable na mga Bagay';

  @override
  String get identifyBiodegradableItemsDesc =>
      'Maghanap ng organikong materyales na natural na nabubulok';

  @override
  String get cleanFoodContainers => 'Linisin ang mga Lalagyan ng Pagkain';

  @override
  String get cleanFoodContainersDesc =>
      'Alisin ang anumang natitirang pagkain sa mga lalagyan bago itapon';

  @override
  String get separateFromOtherWaste => 'Ihiwalay sa Ibang Basura';

  @override
  String get separateFromOtherWasteDesc =>
      'Ilagay ang biodegradable na mga bagay sa itinalagang berdeng basurahan';

  @override
  String get properStorage => 'Tamang Pag-iimbak';

  @override
  String get properStorageDesc =>
      'I-imbak ang biodegradable na basura nang tama upang maiwasan ang amoy';

  @override
  String get identifyNonBiodegradableItems =>
      'Kilalanin ang Hindi Biodegradable na mga Bagay';

  @override
  String get identifyNonBiodegradableItemsDesc =>
      'Kilalanin ang mga materyales na hindi natural na nabubulok';

  @override
  String get cleanAndPrepare => 'Linisin at Ihanda';

  @override
  String get cleanAndPrepareDesc =>
      'Linisin ang mga bagay bago itapon upang maiwasan ang kontaminasyon';

  @override
  String get sortByMaterialType => 'Uriin ayon sa Uri ng Materyales';

  @override
  String get sortByMaterialTypeDesc =>
      'Pagsamahin ang magkakatulad na materyales para sa tamang pagproseso';

  @override
  String get useDesignatedBins => 'Gumamit ng Itinalagang Basurahan';

  @override
  String get useDesignatedBinsDesc =>
      'Ilagay ang mga bagay sa tamang basurahan para sa hindi biodegradable na basura';

  @override
  String get checkRecyclingSymbols => 'Suriin ang mga Simbolo ng Pag-recycle';

  @override
  String get checkRecyclingSymbolsDesc =>
      'Maghanap ng mga simbolo ng pag-recycle at numero sa mga bagay';

  @override
  String get cleanThoroughly => 'Linisin nang Mabuti';

  @override
  String get cleanThoroughlyDesc =>
      'Linisin ang lahat ng recyclable na mga bagay upang alisin ang mga kontaminante';

  @override
  String get separateByCategory => 'Ihiwalay ayon sa Kategorya';

  @override
  String get separateByCategoryDesc =>
      'Uriin ang mga recyclable sa tamang kategorya';

  @override
  String get prepareForCollection => 'Ihanda para sa Pagkolekta';

  @override
  String get prepareForCollectionDesc =>
      'I-package ang mga recyclable nang tama para sa pagkuha';

  @override
  String get identifyHazardousMaterials =>
      'Kilalanin ang Mapanganib na mga Materyales';

  @override
  String get identifyHazardousMaterialsDesc =>
      'Kilalanin ang mga bagay na nakakapinsala sa kalusugan o kapaligiran';

  @override
  String get handleWithCare => 'Hawakan nang may Ingat';

  @override
  String get handleWithCareDesc =>
      'Gumamit ng tamang mga pag-iingat sa kaligtasan sa paghawak';

  @override
  String get keepOriginalContainers =>
      'Panatilihin ang Orihinal na mga Lalagyan';

  @override
  String get keepOriginalContainersDesc =>
      'I-imbak ang mapanganib na mga bagay sa kanilang orihinal na packaging';

  @override
  String get findSpecialCollectionPoints =>
      'Maghanap ng Espesyal na mga Punto ng Pagkolekta';

  @override
  String get findSpecialCollectionPointsDesc =>
      'Maghanap ng awtorisadong mga pasilidad ng pagtatapon';

  @override
  String get exampleFoodScraps => 'Mga tira ng pagkain';

  @override
  String get exampleFruitPeels => 'Mga balat ng prutas';

  @override
  String get exampleVegetableWaste => 'Basura ng gulay';

  @override
  String get exampleGardenTrimmings => 'Mga putol ng halaman';

  @override
  String get examplePaper => 'Papel';

  @override
  String get exampleCardboard => 'Karton';

  @override
  String get exampleRinseContainers => 'Banlawan ang mga lalagyan';

  @override
  String get exampleRemoveLabels => 'Alisin ang mga label kung maaari';

  @override
  String get exampleScrapeFood => 'Kuskusin ang natitirang pagkain';

  @override
  String get exampleGreenBins => 'Gumamit ng berde o brown na basurahan';

  @override
  String get exampleKeepDrySeparate => 'Ihiwalay ang tuyong mga bagay sa basa';

  @override
  String get exampleLayerMaterials => 'I-layer ang mga materyales nang tama';

  @override
  String get exampleLinedBins => 'Gumamit ng basurahan na may lining';

  @override
  String get exampleEmptyRegularly => 'Alisin nang regular';

  @override
  String get exampleCoolPlace => 'Itago sa malamig, tuyong lugar';

  @override
  String get examplePlasticBags => 'Plastik na mga bag';

  @override
  String get exampleStyrofoam => 'Styrofoam';

  @override
  String get exampleRubberItems => 'Goma na mga bagay';

  @override
  String get exampleMetalCans => 'Metal na mga lata';

  @override
  String get exampleGlassBottles => 'Basong mga bote';

  @override
  String get exampleRemoveCaps => 'Alisin ang mga takip at tabon';

  @override
  String get exampleDryThoroughly => 'Patuyuin nang mabuti';

  @override
  String get exampleSeparatePlastics => 'Ihiwalay ang plastik ayon sa uri';

  @override
  String get exampleGroupMetal => 'Pagsamahin ang metal na mga bagay';

  @override
  String get exampleKeepGlassSeparate => 'Ihiwalay ang baso';

  @override
  String get exampleRedBins => 'Gumamit ng pula o itim na basurahan';

  @override
  String get exampleFollowGuidelines => 'Sundin ang lokal na mga alituntunin';

  @override
  String get exampleAvoidOverpacking => 'Iwasan ang labis na pagpuno';

  @override
  String get examplePlasticNumbers => 'Plastik na mga numero 1-7';

  @override
  String get exampleRecyclingSymbol => 'Simbolo ng pag-recycle';

  @override
  String get exampleMaterialCodes => 'Mga code ng pagkilala sa materyales';

  @override
  String get exampleRemoveFoodResidue => 'Alisin ang natitirang pagkain';

  @override
  String get exampleRinseWater => 'Banlawan ng tubig';

  @override
  String get exampleRemoveTape => 'Alisin ang tape at stickers';

  @override
  String get examplePaperProducts => 'Mga produkto ng papel';

  @override
  String get examplePlasticContainers => 'Plastik na mga lalagyan';

  @override
  String get exampleRecyclingBins => 'Gumamit ng mga basurahan sa pag-recycle';

  @override
  String get exampleFlattenCardboard => 'Patagin ang karton';

  @override
  String get exampleBundlePaper => 'Pagsamahin ang mga materyales ng papel';

  @override
  String get exampleBatteries => 'Mga baterya';

  @override
  String get examplePaintCans => 'Mga lata ng pintura';

  @override
  String get exampleChemicals => 'Mga kemikal';

  @override
  String get exampleLightBulbs => 'Mga bombilya';

  @override
  String get exampleElectronics => 'Mga elektronik';

  @override
  String get exampleWearGloves => 'Magsuot ng guwantes';

  @override
  String get exampleAvoidContact => 'Iwasan ang direktang kontak';

  @override
  String get exampleVentilatedArea => 'Magtrabaho sa lugar na may bentilasyon';

  @override
  String get exampleDontMixChemicals => 'Huwag paghaluin ang mga kemikal';

  @override
  String get exampleKeepLabels => 'Panatilihin ang mga label';

  @override
  String get exampleSecureContainers => 'Siguruhin ang mga lalagyan';

  @override
  String get exampleContactAuthorities =>
      'Makipag-ugnayan sa lokal na mga awtoridad';

  @override
  String get exampleVisitCenters => 'Bisitahin ang mga sentro ng pagkolekta';

  @override
  String get exampleSchedulePickup => 'Mag-iskedyul ng pagkuha';
}
