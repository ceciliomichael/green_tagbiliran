// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Cebuano (`ceb`).
class AppLocalizationsCeb extends AppLocalizations {
  AppLocalizationsCeb([String locale = 'ceb']) : super(locale);

  @override
  String get appTitle => 'Green Tagbilaran';

  @override
  String get navHome => 'Home';

  @override
  String get navTrack => 'Lokasyon';

  @override
  String get navRecycle => 'Recycle';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeClickAndComplaint => 'Klik ug Reklamo';

  @override
  String get nextCollection => 'Sunod nga Koleksyon';

  @override
  String tomorrow(String day) {
    return 'Ugma ($day)';
  }

  @override
  String nextDay(String day, int days) {
    return '$day (sa $days ka adlaw)';
  }

  @override
  String nextDayNext(String day) {
    return 'Sunod $day';
  }

  @override
  String get loginTitle => 'Sulod';

  @override
  String get registerTitle => 'Pagrehistro';

  @override
  String get welcomeBack => 'Maayong Pagbalik';

  @override
  String get signInToContinue => 'Pag-sign in aron magpadayon';

  @override
  String get signIn => 'Pag-sign In';

  @override
  String get signingIn => 'Nag-sign In...';

  @override
  String get createAccount => 'Paghimo ug Account';

  @override
  String get joinUs => 'Apil kanamo ug sugdi ang imong eco-friendly nga panaw';

  @override
  String get signUp => 'Pag-sign Up';

  @override
  String get creatingAccount => 'Naghimo ug Account...';

  @override
  String get dontHaveAccount => 'Wala kay account?';

  @override
  String get alreadyHaveAccount => 'Naa nay account?';

  @override
  String get phoneNumber => 'Numero sa Telepono';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Kumpirma ang Password';

  @override
  String get firstName => 'Pangalan';

  @override
  String get lastName => 'Apelyido';

  @override
  String get barangayTagbilaran => 'Barangay (Dakbayan sa Tagbilaran)';

  @override
  String get selectYourBarangay => 'Pilia ang Imong Barangay';

  @override
  String get tagbilaranCityBohol => 'Dakbayan sa Tagbilaran, Bohol';

  @override
  String get wasteManagementHub => 'Sentro sa Pagdumala sa Basura';

  @override
  String get onboardingSkip => 'Laktawi';

  @override
  String get onboardingNext => 'Sunod';

  @override
  String get onboardingGetStarted => 'Sugdi';

  @override
  String get onb1Title => 'Sunda ang trak sa basura';

  @override
  String get onb1Desc =>
      'Hibaloa asa na ang trak sa basura aron dili ka maulahi sa paglabay';

  @override
  String get onb2Title => 'Klik ug Upload';

  @override
  String get onb2Desc =>
      'Klik ug upload bisan kanus-a, bisan asa ug ma-file ang imong reklamo';

  @override
  String get onb3Title => '3R para sa Kinabuhi';

  @override
  String get onb3Desc => 'Pagbulag sa basura ug pagkat-on';

  @override
  String get reportIssue => 'I-report ang Problema';

  @override
  String get issueStatus => 'Kahimtang sa Report';

  @override
  String get schedule => 'Iskedyul';

  @override
  String get eventsReminders => 'Mga Hitabo ug Pahimangno';

  @override
  String get location => 'Lokasyon';

  @override
  String get helpSupport => 'Tabang & Suporta';

  @override
  String get logout => 'Pag-logout';

  @override
  String get cancel => 'Pag-undang';

  @override
  String get confirmLogoutMsg => 'Sigurado ka nga mogawas ka sa imong account?';

  @override
  String get profile => 'Profile';

  @override
  String get accountInformation => 'Impormasyon sa Account';

  @override
  String get fullName => 'Tibuok nga Ngalan';

  @override
  String get memberSince => 'Miyembro Sukad';

  @override
  String get actions => 'Mga Aksyon';

  @override
  String get reportStatus => 'Kahimtang sa Report';

  @override
  String get language => 'Pinulongan';

  @override
  String get selectLanguage => 'Pilia ang Pinulongan';

  @override
  String get english => 'English';

  @override
  String get cebuano => 'Cebuano';

  @override
  String get adminAccess => 'Admin Access';

  @override
  String get adminAccessDesc =>
      'Pag-access sa mga kontrola sa admin ug mga katalagsaon sa pagdumala';

  @override
  String get enterAdminPanel => 'Sulod sa Admin Panel';

  @override
  String get truckDriverAccess => 'Truck Driver Access';

  @override
  String get truckDriverAccessDesc =>
      'Ang mga drayber sa trak kinahanglan mogamit sa ilang gi-assign nga numero sa telepono ug password sa pag-sign in sa ibabaw. Ang imong account gihimo sa admin.';

  @override
  String welcome(String name) {
    return 'Maayong pag-abot, $name';
  }

  @override
  String barangay(String name) {
    return 'Barangay $name';
  }

  @override
  String welcomeBackUser(String name) {
    return 'Maayong pagbalik, $name!';
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
  String get daySunday => 'Domingo';

  @override
  String get noScheduleAvailable => 'Walay available nga iskedyul';

  @override
  String get appVersion => 'Green Tagbilaran v1.0.0';

  @override
  String get wasteSegregationGuide => 'Giya sa Pagbulag sa Basura';

  @override
  String get learnProperWasteSeparation =>
      'Kat-uni ang hustong paagi sa pagbulag sa basura';

  @override
  String get garbageTruckTracking => 'Pagsunod sa Trak sa Basura';

  @override
  String get live => 'LIVE';

  @override
  String get truckStatus => 'Kahimtang sa Trak';

  @override
  String get activeCollectionRoute => 'Aktibo nga Ruta sa Pagkolekta';

  @override
  String get biodegradable => 'Biodegradable';

  @override
  String get nonBiodegradable => 'Dili Biodegradable';

  @override
  String get recyclable => 'Pwedeng I-recycle';

  @override
  String get hazardous => 'Peligroso';

  @override
  String get biodegradableDesc => 'Organikong basura nga natural nga madunot';

  @override
  String get nonBiodegradableDesc =>
      'Mga materyales nga dili natural nga madunot';

  @override
  String get recyclableDesc =>
      'Mga materyales nga pwedeng prosesuhon ngadto sa bag-ong produkto';

  @override
  String get hazardousDesc =>
      'Peligrosong materyales nga nanginahanglan espesyal nga paggamit';

  @override
  String get identifyBiodegradableItems =>
      'Ilha ang Biodegradable nga mga Butang';

  @override
  String get identifyBiodegradableItemsDesc =>
      'Pangita og organikong materyales nga natural nga madunot';

  @override
  String get cleanFoodContainers => 'Hugasi ang mga Sudlanan sa Pagkaon';

  @override
  String get cleanFoodContainersDesc =>
      'Kuhaa ang bisan unsang salin sa pagkaon sa mga sudlanan sa dili pa ilabay';

  @override
  String get separateFromOtherWaste => 'Bulagi sa Ubang Basura';

  @override
  String get separateFromOtherWasteDesc =>
      'Ibutang ang biodegradable nga mga butang sa gitakda nga lungag nga berde';

  @override
  String get properStorage => 'Hustong Pagtipig';

  @override
  String get properStorageDesc =>
      'Tipigi ang biodegradable nga basura sa hustong paagi aron malikayan ang baho';

  @override
  String get identifyNonBiodegradableItems =>
      'Ilha ang Dili Biodegradable nga mga Butang';

  @override
  String get identifyNonBiodegradableItemsDesc =>
      'Ilha ang mga materyales nga dili natural nga madunot';

  @override
  String get cleanAndPrepare => 'Hugasi ug Andama';

  @override
  String get cleanAndPrepareDesc =>
      'Hugasi ang mga butang sa dili pa ilabay aron malikayan ang kontaminasyon';

  @override
  String get sortByMaterialType => 'Paghan-ay Sumala sa Tipo sa Materyales';

  @override
  String get sortByMaterialTypeDesc =>
      'Pundoka ang managsama nga materyales alang sa hustong pagproseso';

  @override
  String get useDesignatedBins => 'Gamita ang Gitakda nga mga Lungag';

  @override
  String get useDesignatedBinsDesc =>
      'Ibutang ang mga butang sa hustong lungag para sa dili biodegradable nga basura';

  @override
  String get checkRecyclingSymbols => 'Susiha ang mga Simbolo sa Pag-recycle';

  @override
  String get checkRecyclingSymbolsDesc =>
      'Pangita og mga simbolo sa pag-recycle ug mga numero sa mga butang';

  @override
  String get cleanThoroughly => 'Hugasi Pag-ayo';

  @override
  String get cleanThoroughlyDesc =>
      'Hugasi ang tanang recyclable nga mga butang aron makuha ang mga kontaminante';

  @override
  String get separateByCategory => 'Bulagi Sumala sa Kategoriya';

  @override
  String get separateByCategoryDesc =>
      'Paghan-ay sa mga recyclable ngadto sa hustong kategoriya';

  @override
  String get prepareForCollection => 'Andama alang sa Pagkolekta';

  @override
  String get prepareForCollectionDesc =>
      'Putos-a ang mga recyclable sa hustong paagi alang sa pagkuha';

  @override
  String get identifyHazardousMaterials =>
      'Ilha ang Peligrosong mga Materyales';

  @override
  String get identifyHazardousMaterialsDesc =>
      'Ilha ang mga butang nga makahimo og panganib sa kahimsog o kalikopan';

  @override
  String get handleWithCare => 'Gamita nga Mabinantayon';

  @override
  String get handleWithCareDesc =>
      'Gamita ang hustong mga panggiya sa kaluwasan sa paggamit';

  @override
  String get keepOriginalContainers => 'Tipigi ang Orihinal nga mga Sudlanan';

  @override
  String get keepOriginalContainersDesc =>
      'Tipigi ang peligrosong mga butang sa ilang orihinal nga pakete';

  @override
  String get findSpecialCollectionPoints =>
      'Pangita og Espesyal nga mga Punto sa Pagkolekta';

  @override
  String get findSpecialCollectionPointsDesc =>
      'Pangita og awtorisadong mga pasilidad sa paglabay';

  @override
  String get exampleFoodScraps => 'Mga salin sa pagkaon';

  @override
  String get exampleFruitPeels => 'Mga panit sa prutas';

  @override
  String get exampleVegetableWaste => 'Basura sa utanon';

  @override
  String get exampleGardenTrimmings => 'Mga putol sa tanaman';

  @override
  String get examplePaper => 'Papel';

  @override
  String get exampleCardboard => 'Karton';

  @override
  String get exampleRinseContainers => 'Hugasi ang mga sudlanan';

  @override
  String get exampleRemoveLabels => 'Kuhaa ang mga label kon mahimo';

  @override
  String get exampleScrapeFood => 'Kuskusa ang nahibilin nga pagkaon';

  @override
  String get exampleGreenBins => 'Gamita ang berde o brown nga mga lungag';

  @override
  String get exampleKeepDrySeparate =>
      'Bulagi ang uga nga mga butang gikan sa basa';

  @override
  String get exampleLayerMaterials =>
      'Ibutang ang mga materyales sa hustong paagi';

  @override
  String get exampleLinedBins => 'Gamita ang mga lungag nga may lining';

  @override
  String get exampleEmptyRegularly => 'Hawani kanunay';

  @override
  String get exampleCoolPlace => 'Tipigi sa bugnaw, uga nga lugar';

  @override
  String get examplePlasticBags => 'Plastik nga mga bag';

  @override
  String get exampleStyrofoam => 'Styrofoam';

  @override
  String get exampleRubberItems => 'Goma nga mga butang';

  @override
  String get exampleMetalCans => 'Metal nga mga lata';

  @override
  String get exampleGlassBottles => 'Baso nga mga botelya';

  @override
  String get exampleRemoveCaps => 'Kuhaa ang mga takop ug tabon';

  @override
  String get exampleDryThoroughly => 'Pauga pag-ayo';

  @override
  String get exampleSeparatePlastics => 'Bulagi ang plastik sumala sa tipo';

  @override
  String get exampleGroupMetal => 'Pundoka ang metal nga mga butang';

  @override
  String get exampleKeepGlassSeparate => 'Bulagi ang baso';

  @override
  String get exampleRedBins => 'Gamita ang pula o itom nga mga lungag';

  @override
  String get exampleFollowGuidelines => 'Sunda ang lokal nga mga giya';

  @override
  String get exampleAvoidOverpacking => 'Likayi ang sobra nga pagpuno';

  @override
  String get examplePlasticNumbers => 'Plastik nga mga numero 1-7';

  @override
  String get exampleRecyclingSymbol => 'Simbolo sa pag-recycle';

  @override
  String get exampleMaterialCodes => 'Mga code sa pagila sa materyales';

  @override
  String get exampleRemoveFoodResidue => 'Kuhaa ang salin sa pagkaon';

  @override
  String get exampleRinseWater => 'Hugasi sa tubig';

  @override
  String get exampleRemoveTape => 'Kuhaa ang tape ug stickers';

  @override
  String get examplePaperProducts => 'Mga produkto sa papel';

  @override
  String get examplePlasticContainers => 'Plastik nga mga sudlanan';

  @override
  String get exampleRecyclingBins => 'Gamita ang mga lungag sa pag-recycle';

  @override
  String get exampleFlattenCardboard => 'Patag-a ang karton';

  @override
  String get exampleBundlePaper => 'Pundoka ang mga materyales sa papel';

  @override
  String get exampleBatteries => 'Mga baterya';

  @override
  String get examplePaintCans => 'Mga lata sa pintura';

  @override
  String get exampleChemicals => 'Mga kemikal';

  @override
  String get exampleLightBulbs => 'Mga bombilya';

  @override
  String get exampleElectronics => 'Mga elektronik';

  @override
  String get exampleWearGloves => 'Pagsul-ob og guwantes';

  @override
  String get exampleAvoidContact => 'Likayi ang direktang kontak';

  @override
  String get exampleVentilatedArea => 'Pagtrabaho sa lugar nga may hangin';

  @override
  String get exampleDontMixChemicals => 'Ayaw pagsagol sa mga kemikal';

  @override
  String get exampleKeepLabels => 'Tipigi ang mga label';

  @override
  String get exampleSecureContainers => 'Siguroha ang mga sudlanan';

  @override
  String get exampleContactAuthorities => 'Kontaka ang lokal nga mga awtoridad';

  @override
  String get exampleVisitCenters => 'Bisitaha ang mga sentro sa pagkolekta';

  @override
  String get exampleSchedulePickup => 'Mag-iskedyul og pagkuha';
}
