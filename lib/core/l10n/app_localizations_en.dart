// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'WayMark';

  @override
  String get navJourneys => 'Journeys';

  @override
  String get navExplore => 'Explore';

  @override
  String get navStudio => 'Studio';

  @override
  String get navProfile => 'Profile';

  @override
  String get btnBackToJourneys => 'Back to Journeys';

  @override
  String journeysWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String journeysWelcomeBack(String name) {
    return 'Welcome back, $name';
  }

  @override
  String get journeysOfflineReady => 'Offline Ready';

  @override
  String get journeysTravelerDossier => 'Traveler Dossier';

  @override
  String get journeysCleanSlateDossier => 'Clean Slate';

  @override
  String journeysMetricsSummary(int count, String km) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count memoirs',
      one: '1 memoir',
    );
    return '$_temp0 • $km km logged';
  }

  @override
  String get journeysRecordTravelMemory => 'Record Travel Memory';

  @override
  String get journeysStartNewJourney => 'Start New Journey';

  @override
  String get travelerProfileTitle => 'Traveler Profile';

  @override
  String get profileClaimCompassDesc =>
      'Claim your compass. Your dossier, your expedition identity.';

  @override
  String get profileFullNameLabel => 'Full Name';

  @override
  String get profileFullNamePlaceholder => 'e.g. Rojan Shrestha';

  @override
  String get profileHandleLabel => 'Compass ID / Email';

  @override
  String get profileHandlePlaceholder => 'e.g. rojan@waymark.app';

  @override
  String get profileHandleClaimed => 'CLAIMED';

  @override
  String get profileArchetypeLabel => 'Traveler Type';

  @override
  String get profileBioLabel => 'Field Philosophy / Bio';

  @override
  String get profileBioFieldNote => 'optional';

  @override
  String get profileBioPlaceholder => 'What drives your wanderlust?';

  @override
  String get emptyDeckBtnStart => 'Start Your First Journey';

  @override
  String get emptyDeckHowItWorksTitle => 'How WayMark Works';

  @override
  String get emptyDeckHowItWorksSubtitle => 'Your offline field journal';

  @override
  String get emptyDeckStep1Title => 'Snap & Batch Import';

  @override
  String get emptyDeckStep1Badge => 'Capture';

  @override
  String get emptyDeckStep1Desc =>
      'Take photos during your journey or import entire albums at once. EXIF metadata is automatically parsed for GPS coordinates and timestamps.';

  @override
  String get emptyDeckStep2Title => 'Continuous Vector Trails';

  @override
  String get emptyDeckStep2Badge => 'Track';

  @override
  String get emptyDeckStep2Desc =>
      'Waymark connects your photo stops with dynamic polyline routes rendered from your GPS breadcrumbs, creating a vivid visual trail of your path.';

  @override
  String get emptyDeckStep3Title => 'Tactile Postcards';

  @override
  String get emptyDeckStep3Badge => 'Export';

  @override
  String get emptyDeckStep3Desc =>
      'Export tactile aesthetic postcards with coordinates, altitude, and weather data stamped directly onto them.';

  @override
  String get createJourneyTitle => 'New Travel Memoir';

  @override
  String get createJourneySubtitle =>
      'Start tracking an expedition with local offline storage.';

  @override
  String get createJourneyNameLabel => 'Journey Title';

  @override
  String get createJourneyNameHint => 'e.g. Autumn in Kyoto & Kansai';

  @override
  String get createJourneyDescLabel => 'Expedition Creed / Description';

  @override
  String get createJourneyDescHint => 'Brief field notes on this voyage...';

  @override
  String get createJourneyStartDate => 'Start Date';

  @override
  String get createJourneyEndDate => 'End Date';

  @override
  String get createJourneyBtnCreate => 'Create Journey Album';

  @override
  String get sampleDataLoadedToast =>
      'Kansai Expedition loaded into local SQLite vault!';

  @override
  String get profileAvatarLabel => 'Traveler Portrait';

  @override
  String get profileSaveSuccessToast => 'Profile settings updated successfully';

  @override
  String get profileBtnSaveChanges => 'Save Changes';

  @override
  String get profileTravelAlbumsSectionTitle => 'Travel Albums & Memoirs';

  @override
  String get profileTravelAlbumsSubtitle => 'Archived in local SQLite vault';

  @override
  String get profileTravelAlbumsEmpty =>
      'No travel albums in your offline vault yet';

  @override
  String get profileTravelAlbumsEmptyDesc =>
      'Your recorded expeditions and field memoirs will be safely chronicled here.';

  @override
  String get profileStartFirstJourney => 'Start Your First Journey';

  @override
  String profileMemoirsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Memoirs',
      one: '1 Memoir',
    );
    return '$_temp0';
  }

  @override
  String profileTotalDistanceRecorded(String distance) {
    return '$distance km recorded';
  }

  @override
  String profileTotalPlacesRecorded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places visited',
      one: '1 place visited',
    );
    return '$_temp0';
  }

  @override
  String get emptyExploreTitle => 'No Waypoints Explored Yet';

  @override
  String get emptyExploreDesc =>
      'Record journeys to automatically map GPS breadcrumbs and chart your travel footprints across the globe.';

  @override
  String get emptyExploreBtn => 'Start a Journey to Map Footprints';

  @override
  String get emptyStudioTitle => 'No Postcards Created Yet';

  @override
  String get emptyStudioDesc =>
      'Start a journey and capture photo stops along your path to generate bespoke vintage travel postcards.';

  @override
  String get emptyStudioBtn => 'Record Your First Memory';

  @override
  String get emptyOngoingTitle => 'No Active Expedition';

  @override
  String get emptyOngoingDesc =>
      'You do not have an ongoing journey in progress right now.';

  @override
  String get emptyOngoingBtn => 'Start New Journey';

  @override
  String get emptyDeckJourneyAwaitsTitle => 'Your Journey Awaits';

  @override
  String get emptyDeckJourneyAwaitsDesc =>
      'No journeys recorded in your vault yet. Begin your first expedition to trace steps, pin stops, and preserve memories.';

  @override
  String get notificationsPrivateToast =>
      'All trips and memoirs are stored privately on this device.';

  @override
  String get emptyAlbumStopsTitle => 'No Stops Recorded Yet';

  @override
  String get emptyAlbumStopsDesc =>
      'Add waypoints, milestones, and photo stops to build your journey timeline.';

  @override
  String get emptyAlbumStopsBtn => 'Add First Waypoint';

  @override
  String get settingsTitle => 'Settings & Vault';

  @override
  String get settingsSubtitle => 'Local offline configuration & storage';

  @override
  String get settingsVaultSection => 'Local SQLite Vault';

  @override
  String get settingsClearDatabaseBtn => 'Wipe & Clear Entire Database';

  @override
  String get settingsClearDatabaseDesc =>
      'Permanently erase all journeys, waypoints, media, and reset profile.';

  @override
  String get settingsClearDatabaseConfirm =>
      'Are you sure you want to completely erase the database? This action is irreversible.';

  @override
  String get settingsClearDatabaseSuccess =>
      'Database wiped clean. Starting fresh.';

  @override
  String get settingsAboutSection => 'About WayMark';

  @override
  String get settingsStorageClearedToast =>
      'All journey memoirs cleared successfully';

  @override
  String get placeLoggerTitle => 'Log a New Stop';

  @override
  String get placeLoggerSubtitle =>
      'Pin a waypoint, milestone, or memory to your expedition.';

  @override
  String get placeLoggerNameLabel => 'Place Name';

  @override
  String get placeLoggerNameHint => 'e.g. Fushimi Inari Shrine';

  @override
  String get placeLoggerCategoryLabel => 'Category';

  @override
  String get placeLoggerNotesLabel => 'Field Notes';

  @override
  String get placeLoggerNotesHint => 'Observations, impressions...';

  @override
  String get placeLoggerBtnSave => 'Log Waypoint';

  @override
  String get placeLoggerSuccessToast => 'Waypoint logged to your expedition!';

  @override
  String get placeLoggerUpdatedToast => 'Waypoint updated successfully!';

  @override
  String get placeLoggerLogNewPlace => 'Log New Place';

  @override
  String get placeLoggerEditPlace => 'Edit Place';

  @override
  String get placeLoggerSavePlace => 'Save Place';

  @override
  String get placeLoggerSearchPlaceholder =>
      'Search landmark, cafe, or coordinates...';

  @override
  String get placeLoggerDetectedGpsTitle => 'Detected GPS from photo';

  @override
  String get placeLoggerMatched => 'Matched';

  @override
  String get placeLoggerDragPinCalibrate => 'Drag pin to calibrate';

  @override
  String get placeLoggerPlaceIdentity => 'PLACE IDENTITY';

  @override
  String get placeLoggerCategoryTag => 'Category Tag';

  @override
  String get placeLoggerVisitedTime => 'Visited Time';

  @override
  String get placeLoggerSkyAndTemp => 'Sky & Temp';

  @override
  String get placeLoggerVisualRelics => 'Visual Relics & Photos';

  @override
  String get placeLoggerCoverBadge => 'Cover';

  @override
  String get placeLoggerAddPhoto => 'Add Photo';

  @override
  String get placeLoggerMaxPhotos => 'Max 6 photos';

  @override
  String get placeLoggerSensoryImpressions => 'Sensory Impressions';

  @override
  String get placeLoggerSensoryHint =>
      'How did the wind smell? What sounds echoed? Record fleeting moments...';

  @override
  String placeLoggerLogToJourney(String title) {
    return 'Log Place to $title';
  }

  @override
  String placeLoggerUpdatePlaceInJourney(String title) {
    return 'Update Place in $title';
  }

  @override
  String placeLoggerSyncSubtitle(String order) {
    return 'Synchronized with offline storage • Auto-assigns to Route $order';
  }

  @override
  String get journeyDetailMapPreview =>
      'Route polyline renders once multiple waypoints are added';

  @override
  String get journeyDetailTimeline => 'JOURNEY TIMELINE';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSave => 'Save';

  @override
  String get commonRequired => 'Required';

  @override
  String get commonOptional => 'Optional';

  @override
  String get settingsDialogClearTitle => 'Clear Journey Records';

  @override
  String get settingsDialogClearDesc =>
      'Are you sure you want to clear all journey memoirs, waypoints, and photos? Your profile settings will be preserved.';

  @override
  String get settingsDialogClearConfirm => 'Clear Journeys';

  @override
  String get settingsDialogWipeConfirm => 'Wipe Everything';

  @override
  String get settingsDriftEngineTitle => 'Drift SQLite Engine';

  @override
  String get settingsDriftEngineSubtitle =>
      'Local, zero-cloud encrypted storage vault';

  @override
  String get settingsStatusActive => 'ACTIVE';

  @override
  String get settingsClearMemoirsTitle => 'Clear All Journey Memoirs';

  @override
  String get settingsClearMemoirsDesc =>
      'Removes all trips, waypoints, and photos, but keeps your traveler profile.';

  @override
  String get settingsBtnClear => 'Clear';

  @override
  String get settingsBtnWipeVault => 'Wipe Vault';

  @override
  String get settingsAppDescription => 'WayMark: Memoir & Living Atlas';

  @override
  String get settingsAppVersion => 'v1.0.0';

  @override
  String get settingsEnvFlavor => 'Environment Flavor';

  @override
  String get settingsStorageArch => 'Storage Architecture';

  @override
  String get settingsStorageArchValue => 'SQLite 3 / Drift ORM';

  @override
  String get studioBadgeClosed => 'STUDIO CLOSED';

  @override
  String get studioNoMemoriesTitle => 'No memories to print';

  @override
  String get studioNoMemoriesDesc =>
      'Add a journey and places to start making postcards.';

  @override
  String get studioBadgeAtelier => 'POSTCARD ATELIER';

  @override
  String get studioMemoryPrintsTitle => 'Memory Prints';

  @override
  String get studioMemoryPrintsSubtitle =>
      'Craft bespoke vintage travel postcards from your expedition stops';

  @override
  String get studioBannerNotice =>
      'Select a memory below to generate a postcard. Full generator coming soon.';

  @override
  String get studioSectionMemories => 'JOURNEY MEMORIES';

  @override
  String get studioGeneratorTitle => 'Postcard Generator';

  @override
  String get studioGeneratorDesc =>
      'Export high-resolution vintage postcards with your GPS coordinates, altitude, and weather stamped into the design. Coming in the next update.';

  @override
  String get studioBtnCreatePostcard => 'Create Postcard';

  @override
  String studioComingSoonToast(String name) {
    return 'Postcard generator coming soon for $name!';
  }

  @override
  String get exploreBadgeUnmapped => 'UNMAPPED HORIZONS';

  @override
  String get exploreFootprintsTitle => 'Explore Your Footprints';

  @override
  String get exploreFootprintsSubtitle => 'Interactive map coming soon';

  @override
  String get exploreBadgeComingSoon => 'INTERACTIVE MAP COMING SOON';

  @override
  String exploreStatsSummary(int albumsCount, int waypointsCount) {
    String _temp0 = intl.Intl.pluralLogic(
      albumsCount,
      locale: localeName,
      other: '$albumsCount Journeys',
      one: '1 Journey',
    );
    String _temp1 = intl.Intl.pluralLogic(
      waypointsCount,
      locale: localeName,
      other: '$waypointsCount Waypoints',
      one: '1 Waypoint',
    );
    return '$_temp0  •  $_temp1';
  }

  @override
  String get exploreRecentWaypointsTitle => 'Recent Waypoints';

  @override
  String get exploreWaypointComingSoonToast =>
      'Waypoint detail coming in next update';

  @override
  String get journeyDetailExportReportToast => 'Exporting expedition report';

  @override
  String get journeyDetailLogWaypointTooltip => 'Log Waypoint';

  @override
  String get journeyStatusOngoing => 'ONGOING';

  @override
  String get journeyStatusCompleted => 'COMPLETED';

  @override
  String get journeyDatePresent => 'Present';

  @override
  String journeyPlacesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places',
      one: '1 place',
    );
    return '$_temp0';
  }

  @override
  String get journeyDetailRouteMap => 'Route Map';

  @override
  String get journeyDetailExpeditionLogbook => 'EXPEDITION LOGBOOK';

  @override
  String get placeLoggerWeatherLabel => 'Weather Condition (Optional)';

  @override
  String get placeLoggerGpsNotice =>
      'GPS: Location will be pinned automatically';

  @override
  String get placeLoggerFailedToast => 'Failed to log waypoint.';

  @override
  String get weatherSunny => 'Sunny';

  @override
  String get weatherCloudy => 'Cloudy';

  @override
  String get weatherRainy => 'Rainy';

  @override
  String get weatherCold => 'Cold';

  @override
  String get weatherFoggy => 'Foggy';

  @override
  String get categoryGeneral => 'GENERAL';

  @override
  String get categorySightseeing => 'SIGHTSEEING';

  @override
  String get categoryFood => 'FOOD';

  @override
  String get categoryStay => 'STAY';

  @override
  String get categoryHike => 'HIKE';

  @override
  String get categoryTransit => 'TRANSIT';

  @override
  String get createJourneyTitleValidation => 'Please enter a title';

  @override
  String createJourneySuccessToast(String title) {
    return 'Created expedition \"$title\"';
  }

  @override
  String createJourneyErrorToast(String error) {
    return 'Failed to create journey: $error';
  }

  @override
  String get profileBtnTakePhoto => 'Take Photo';

  @override
  String get profileBtnFromGallery => 'From Gallery';

  @override
  String get profileChoosePresetTitle => 'CHOOSE AVATAR PRESET';

  @override
  String profileCameraError(String error) {
    return 'Unable to access camera: $error';
  }

  @override
  String profileGalleryError(String error) {
    return 'Unable to access photo library: $error';
  }

  @override
  String get onboardingPortraitTitle => 'Traveler Portrait';

  @override
  String get onboardingPortraitSubtitle =>
      'Take a photo, choose from gallery, or select an avatar.';

  @override
  String get archetypeModalTitle => 'Choose Your Travel Style';

  @override
  String get archetypeModalSubtitle =>
      'Select the travel style that best matches how you like to journey.';

  @override
  String get archetypeBtnChange => 'Change';

  @override
  String get onboardingVaultTitle => 'Private Travel Storage';

  @override
  String get onboardingVaultSubtitle => 'Private • On-Device Only';

  @override
  String get onboardingVaultOfflinePill => '100% Offline';

  @override
  String journeysStopNumber(int order) {
    return 'Stop #$order';
  }

  @override
  String get tagBackpacking => 'Backpacking';

  @override
  String get tagTemples => 'Temples';

  @override
  String get tagTeaTrails => 'Tea Trails';

  @override
  String get appPhilosophy => 'Your Journey.  Your Story.';

  @override
  String get verbTravel => 'Travel';

  @override
  String get verbJournal => 'Journal';

  @override
  String get verbRelive => 'Relive';

  @override
  String get interactiveRouteMapsTitle => 'Interactive Route Maps';

  @override
  String get interactiveRouteMapsDesc =>
      'Vector polylines & elevation profiles';

  @override
  String get artisticJourneyPostcardsTitle => 'Artistic Journey Postcards';

  @override
  String get artisticJourneyPostcardsDesc =>
      'Vintage typography & metadata stamps';

  @override
  String get offlineFirstTitle => '100% Offline First';

  @override
  String get offlineFirstDesc => 'Private sqlite vault with no tracking';

  @override
  String get moreThanJustPhotos => '— More Than Just Photos —';

  @override
  String get initializingLocalVault => 'Initializing local vault...';

  @override
  String get journeysRecentDiscoveries => 'Recent Discoveries';

  @override
  String get journeysSeeMap => 'See Map';

  @override
  String get journeysArchivedMemoirs => 'Archived Memoirs';

  @override
  String journeysCompletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completed',
      one: '1 completed',
    );
    return '$_temp0';
  }

  @override
  String get filterAll => 'All';

  @override
  String get filterOngoing => 'Ongoing';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get filterFavorites => 'Favorites';

  @override
  String get journeysExportFieldJournalTitle => 'Export Field Journal';

  @override
  String get journeysExportFieldJournalDesc =>
      'Generate an archival PDF dossier of your journeys with high-res photos and route logs.';

  @override
  String get journeysBtnPreview => 'Preview';

  @override
  String get journeysActiveExpedition => 'Active Expedition';

  @override
  String get journeysGpsTrackingActive => 'GPS Tracking Active';

  @override
  String get journeysOngoingExpedition => 'Ongoing Expedition';

  @override
  String journeysDayOf(int current, int total) {
    return 'Day $current of $total';
  }

  @override
  String get journeysDistanceLabel => 'Distance';

  @override
  String get journeysWaypointsLabel => 'Places';

  @override
  String journeysWaypointsLogged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places',
      one: '1 place',
    );
    return '$_temp0 logged';
  }

  @override
  String get journeysPaceLogLabel => 'Pace Log';

  @override
  String get journeysPaceOnTrack => 'On Track';

  @override
  String get journeysRouteTraceTitle => 'ROUTE TRACE';

  @override
  String get journeysRouteTraceSubtitle => 'Waypoints connected in order';

  @override
  String get journeysBtnContinueMemoir => 'Continue Memoir';

  @override
  String get emptyDeckSecurityFooter =>
      'Private SQLite Vault • 100% Offline • Zero Data Tracking';

  @override
  String get onboardingHeroTitle => 'WayMark';

  @override
  String get onboardingHeroTitleItalic => 'Expeditions';

  @override
  String get onboardingHeroDesc =>
      'An offline-first travel journal that turns your routes and memories into artistic memoirs.';

  @override
  String get onboardingFeature1Title => 'Interactive Route Maps';

  @override
  String get onboardingFeature1Badge => 'VECTOR';

  @override
  String get onboardingFeature1Desc =>
      'Real-time breadcrumb tracking with high-res polyline mapping.';

  @override
  String get onboardingFeature2Title => 'Artistic Postcards';

  @override
  String get onboardingFeature2Badge => 'STUDIO';

  @override
  String get onboardingFeature2Desc =>
      'Generate vintage expedition postcards stamped with GPS and weather data.';

  @override
  String get onboardingFeature3Title => 'Private Local Vault';

  @override
  String get onboardingFeature3Badge => '100% OFFLINE';

  @override
  String get onboardingFeature3Desc =>
      'Your data never leaves your device. Fully encrypted local SQLite storage.';

  @override
  String get onboardingBtnBeginSetup => 'Begin Expedition Setup';

  @override
  String get onboardingRestoreBackupPrefix => 'Have an existing vault? ';

  @override
  String get onboardingRestoreBackupFile => 'Restore Backup';

  @override
  String get onboardingRestoreBackupSuffix =>
      ' to continue where you left off.';

  @override
  String get profileClaimCompassTitle => 'Claim Your Compass';

  @override
  String get profileBtnInitializeVault => 'Initialize Local Vault';

  @override
  String get profileOfflineFirst => '100% Offline';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingStep1Badge => 'STEP 1 OF 2';

  @override
  String get onboardingStep2Badge => 'STEP 2 OF 2';

  @override
  String get profileMeasurementStandards => 'Measurement Standards';

  @override
  String get profileMetricUnit => 'Metric (km, m, °C)';

  @override
  String get profileImperialUnit => 'Imperial (mi, ft, °F)';

  @override
  String get profileAutoExifTitle => 'Auto-Extract EXIF Data';

  @override
  String get profileAutoExifDesc =>
      'Extract GPS coordinates and timestamps from photos automatically';

  @override
  String get profileDbTargetLabel => 'Database Target';

  @override
  String get profileDbAllocated => 'Allocated';

  @override
  String get settingsPrivacySection => 'Privacy & Architecture';

  @override
  String get settingsZeroCloudTitle => 'Zero Cloud Tracking';

  @override
  String get settingsZeroCloudDesc =>
      'All journeys, coordinates, and memoirs remain strictly on your device.';

  @override
  String get settingsNativeExifTitle => 'Native Hardware EXIF Extraction';

  @override
  String get settingsNativeExifDesc =>
      'Stamps date, time, and coordinates from your original photos without internet.';

  @override
  String get settingsOfflineTrailsTitle => 'Offline Vector Trails';

  @override
  String get settingsOfflineTrailsDesc =>
      'Calculates smooth geographic trajectories through on-device interpolation.';

  @override
  String profileStopsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stops',
      one: '1 stop',
    );
    return '$_temp0';
  }

  @override
  String get profileTravelAlbumsEmptyBadge => 'EXPEDITION LOGS';

  @override
  String get profilePrivateBadge => '100% Private';

  @override
  String get onboardingHeroArchive => 'WAYMARK ARCHIVE';

  @override
  String get onboardingHeroPlateNo => 'PLATE NO. 12';

  @override
  String get onboardingRestoreBackupSnackbar =>
      'Select your encrypted .waymark archive file to restore local trips and journal snapshots.';

  @override
  String onboardingVaultInitError(String error) {
    return 'Failed to initialize vault: $error';
  }

  @override
  String get vaultPrivateStorageTitle => 'Private Travel Storage';

  @override
  String get vaultPrivateStorageSubtitle => 'Private • On-Device Only';

  @override
  String get vaultOfflineBadge => '100% Offline';

  @override
  String get emptyDeckBadge => 'OFFLINE FIELD JOURNAL';

  @override
  String get weatherClear => 'Clear';

  @override
  String journeysStopOrder(int order) {
    return 'Stop #$order';
  }

  @override
  String get journeysExportFieldJournalPreparing =>
      'Field Journal PDF compiler is preparing your printable layout...';

  @override
  String get journeysExpeditionStatusBadge => 'EXPEDITION STATUS';

  @override
  String journeysSelectedWaypoint(String name) {
    return 'Selected waypoint: $name';
  }

  @override
  String get journeysTagBackpacking => 'Backpacking';

  @override
  String get journeysTagTemples => 'Temples';

  @override
  String get journeysTagTeaTrails => 'Tea Trails';

  @override
  String get createJourneyTitleRequired => 'Please enter a title';

  @override
  String get createJourneyOptional => 'Optional';

  @override
  String createJourneyFailedToast(String error) {
    return 'Failed to create journey: $error';
  }
}
