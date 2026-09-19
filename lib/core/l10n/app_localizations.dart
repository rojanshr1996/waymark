import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'WayMark'**
  String get appName;

  /// Bottom nav label for journeys
  ///
  /// In en, this message translates to:
  /// **'Journeys'**
  String get navJourneys;

  /// Bottom nav label for explore map
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// Bottom nav label for postcard studio
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get navStudio;

  /// Bottom nav label for traveler profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Back button label to journeys list
  ///
  /// In en, this message translates to:
  /// **'Back to Journeys'**
  String get btnBackToJourneys;

  /// Welcome message on empty journeys deck
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String journeysWelcome(String name);

  /// Welcome back message on journeys deck with content
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}'**
  String journeysWelcomeBack(String name);

  /// Offline status badge text
  ///
  /// In en, this message translates to:
  /// **'Offline Ready'**
  String get journeysOfflineReady;

  /// Traveler dossier label on empty state header
  ///
  /// In en, this message translates to:
  /// **'Traveler Dossier'**
  String get journeysTravelerDossier;

  /// Clean slate label on empty state header
  ///
  /// In en, this message translates to:
  /// **'Clean Slate'**
  String get journeysCleanSlateDossier;

  /// Summary stats row on journeys dashboard
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 memoir} other{{count} memoirs}} • {km} km logged'**
  String journeysMetricsSummary(int count, String km);

  /// FAB tooltip on journeys dashboard
  ///
  /// In en, this message translates to:
  /// **'Record Travel Memory'**
  String get journeysRecordTravelMemory;

  /// Bottom CTA button on journeys dashboard
  ///
  /// In en, this message translates to:
  /// **'Start New Journey'**
  String get journeysStartNewJourney;

  /// Main title on traveler profile screen
  ///
  /// In en, this message translates to:
  /// **'Traveler Profile'**
  String get travelerProfileTitle;

  /// Subtitle on traveler profile screen
  ///
  /// In en, this message translates to:
  /// **'Claim your compass. Your dossier, your expedition identity.'**
  String get profileClaimCompassDesc;

  /// Label for full name field on profile
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profileFullNameLabel;

  /// Placeholder for full name field on profile
  ///
  /// In en, this message translates to:
  /// **'e.g. Rojan Shrestha'**
  String get profileFullNamePlaceholder;

  /// Label for handle/email field on profile
  ///
  /// In en, this message translates to:
  /// **'Compass ID / Email'**
  String get profileHandleLabel;

  /// Placeholder for handle field on profile
  ///
  /// In en, this message translates to:
  /// **'e.g. rojan@waymark.app'**
  String get profileHandlePlaceholder;

  /// Badge when handle/email is entered on profile
  ///
  /// In en, this message translates to:
  /// **'CLAIMED'**
  String get profileHandleClaimed;

  /// Label for archetype selector on profile
  ///
  /// In en, this message translates to:
  /// **'Traveler Type'**
  String get profileArchetypeLabel;

  /// Label for bio text field on profile
  ///
  /// In en, this message translates to:
  /// **'Field Philosophy / Bio'**
  String get profileBioLabel;

  /// Note indicating bio is optional
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get profileBioFieldNote;

  /// Placeholder for bio field on profile
  ///
  /// In en, this message translates to:
  /// **'What drives your wanderlust?'**
  String get profileBioPlaceholder;

  /// Button label in empty deck view
  ///
  /// In en, this message translates to:
  /// **'Start Your First Journey'**
  String get emptyDeckBtnStart;

  /// Title in how-it-works card on empty deck
  ///
  /// In en, this message translates to:
  /// **'How WayMark Works'**
  String get emptyDeckHowItWorksTitle;

  /// Subtitle in how-it-works card on empty deck
  ///
  /// In en, this message translates to:
  /// **'Your offline field journal'**
  String get emptyDeckHowItWorksSubtitle;

  /// Step 1 title in guide
  ///
  /// In en, this message translates to:
  /// **'Snap & Batch Import'**
  String get emptyDeckStep1Title;

  /// Step 1 badge in guide
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get emptyDeckStep1Badge;

  /// Step 1 description in guide
  ///
  /// In en, this message translates to:
  /// **'Take photos during your journey or import entire albums at once. EXIF metadata is automatically parsed for GPS coordinates and timestamps.'**
  String get emptyDeckStep1Desc;

  /// Step 2 title in guide
  ///
  /// In en, this message translates to:
  /// **'Continuous Vector Trails'**
  String get emptyDeckStep2Title;

  /// Step 2 badge in guide
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get emptyDeckStep2Badge;

  /// Step 2 description in guide
  ///
  /// In en, this message translates to:
  /// **'Waymark connects your photo stops with dynamic polyline routes rendered from your GPS breadcrumbs, creating a vivid visual trail of your path.'**
  String get emptyDeckStep2Desc;

  /// Step 3 title in guide
  ///
  /// In en, this message translates to:
  /// **'Tactile Postcards'**
  String get emptyDeckStep3Title;

  /// Step 3 badge in guide
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get emptyDeckStep3Badge;

  /// Step 3 description in guide
  ///
  /// In en, this message translates to:
  /// **'Export tactile aesthetic postcards with coordinates, altitude, and weather data stamped directly onto them.'**
  String get emptyDeckStep3Desc;

  /// Title in create journey bottom sheet
  ///
  /// In en, this message translates to:
  /// **'New Travel Memoir'**
  String get createJourneyTitle;

  /// Subtitle in create journey bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Start tracking an expedition with local offline storage.'**
  String get createJourneySubtitle;

  /// Label for journey title input
  ///
  /// In en, this message translates to:
  /// **'Journey Title'**
  String get createJourneyNameLabel;

  /// Hint for journey title input
  ///
  /// In en, this message translates to:
  /// **'e.g. Autumn in Kyoto & Kansai'**
  String get createJourneyNameHint;

  /// Label for journey description input
  ///
  /// In en, this message translates to:
  /// **'Expedition Creed / Description'**
  String get createJourneyDescLabel;

  /// Hint for journey description input
  ///
  /// In en, this message translates to:
  /// **'Brief field notes on this voyage...'**
  String get createJourneyDescHint;

  /// Start date label in create journey
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get createJourneyStartDate;

  /// End date label in create journey
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get createJourneyEndDate;

  /// Button to create journey album
  ///
  /// In en, this message translates to:
  /// **'Create Journey Album'**
  String get createJourneyBtnCreate;

  /// Toast message when sample route is seeded
  ///
  /// In en, this message translates to:
  /// **'Kansai Expedition loaded into local SQLite vault!'**
  String get sampleDataLoadedToast;

  /// Label for avatar selection bottom sheet on profile
  ///
  /// In en, this message translates to:
  /// **'Traveler Portrait'**
  String get profileAvatarLabel;

  /// Toast message when traveler profile is saved
  ///
  /// In en, this message translates to:
  /// **'Profile settings updated successfully'**
  String get profileSaveSuccessToast;

  /// Button to save traveler profile edits
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profileBtnSaveChanges;

  /// Section header for travel albums on traveler profile
  ///
  /// In en, this message translates to:
  /// **'Travel Albums & Memoirs'**
  String get profileTravelAlbumsSectionTitle;

  /// Subtitle for travel albums section on traveler profile
  ///
  /// In en, this message translates to:
  /// **'Archived in local SQLite vault'**
  String get profileTravelAlbumsSubtitle;

  /// Empty state text for travel albums on traveler profile
  ///
  /// In en, this message translates to:
  /// **'No travel albums in your offline vault yet'**
  String get profileTravelAlbumsEmpty;

  /// Empty state description for travel albums on traveler profile
  ///
  /// In en, this message translates to:
  /// **'Your recorded expeditions and field memoirs will be safely chronicled here.'**
  String get profileTravelAlbumsEmptyDesc;

  /// CTA button to start first journey when albums list is empty
  ///
  /// In en, this message translates to:
  /// **'Start Your First Journey'**
  String get profileStartFirstJourney;

  /// Count of travel memoirs on profile
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Memoir} other{{count} Memoirs}}'**
  String profileMemoirsCount(int count);

  /// Total distance traveled displayed on profile
  ///
  /// In en, this message translates to:
  /// **'{distance} km recorded'**
  String profileTotalDistanceRecorded(String distance);

  /// Total places recorded displayed on profile
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 place visited} other{{count} places visited}}'**
  String profileTotalPlacesRecorded(int count);

  /// Title for empty explore map view
  ///
  /// In en, this message translates to:
  /// **'No Waypoints Explored Yet'**
  String get emptyExploreTitle;

  /// Description for empty explore map view
  ///
  /// In en, this message translates to:
  /// **'Record journeys to automatically map GPS breadcrumbs and chart your travel footprints across the globe.'**
  String get emptyExploreDesc;

  /// Button for empty explore map view
  ///
  /// In en, this message translates to:
  /// **'Start a Journey to Map Footprints'**
  String get emptyExploreBtn;

  /// Title for empty postcard studio
  ///
  /// In en, this message translates to:
  /// **'No Postcards Created Yet'**
  String get emptyStudioTitle;

  /// Description for empty postcard studio
  ///
  /// In en, this message translates to:
  /// **'Start a journey and capture photo stops along your path to generate bespoke vintage travel postcards.'**
  String get emptyStudioDesc;

  /// Button for empty postcard studio
  ///
  /// In en, this message translates to:
  /// **'Record Your First Memory'**
  String get emptyStudioBtn;

  /// Title when no active ongoing journey exists
  ///
  /// In en, this message translates to:
  /// **'No Active Expedition'**
  String get emptyOngoingTitle;

  /// Description when no active ongoing journey exists
  ///
  /// In en, this message translates to:
  /// **'You do not have an ongoing journey in progress right now.'**
  String get emptyOngoingDesc;

  /// Button when no active ongoing journey exists
  ///
  /// In en, this message translates to:
  /// **'Start New Journey'**
  String get emptyOngoingBtn;

  /// Title for clean empty journeys deck
  ///
  /// In en, this message translates to:
  /// **'Your Journey Awaits'**
  String get emptyDeckJourneyAwaitsTitle;

  /// Description for clean empty journeys deck
  ///
  /// In en, this message translates to:
  /// **'No journeys recorded in your vault yet. Begin your first expedition to trace steps, pin stops, and preserve memories.'**
  String get emptyDeckJourneyAwaitsDesc;

  /// Toast message confirming private on-device storage
  ///
  /// In en, this message translates to:
  /// **'All trips and memoirs are stored privately on this device.'**
  String get notificationsPrivateToast;

  /// Title for empty album stops
  ///
  /// In en, this message translates to:
  /// **'No Stops Recorded Yet'**
  String get emptyAlbumStopsTitle;

  /// Description for empty album stops
  ///
  /// In en, this message translates to:
  /// **'Add waypoints, milestones, and photo stops to build your journey timeline.'**
  String get emptyAlbumStopsDesc;

  /// Button to add first waypoint
  ///
  /// In en, this message translates to:
  /// **'Add First Waypoint'**
  String get emptyAlbumStopsBtn;

  /// Title for settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings & Vault'**
  String get settingsTitle;

  /// Subtitle for settings screen
  ///
  /// In en, this message translates to:
  /// **'Local offline configuration & storage'**
  String get settingsSubtitle;

  /// Header for vault section in settings
  ///
  /// In en, this message translates to:
  /// **'Local SQLite Vault'**
  String get settingsVaultSection;

  /// Button to erase the entire database
  ///
  /// In en, this message translates to:
  /// **'Wipe & Clear Entire Database'**
  String get settingsClearDatabaseBtn;

  /// Description for database wipe action
  ///
  /// In en, this message translates to:
  /// **'Permanently erase all journeys, waypoints, media, and reset profile.'**
  String get settingsClearDatabaseDesc;

  /// Confirmation message before wiping database
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to completely erase the database? This action is irreversible.'**
  String get settingsClearDatabaseConfirm;

  /// Toast message when database is wiped clean
  ///
  /// In en, this message translates to:
  /// **'Database wiped clean. Starting fresh.'**
  String get settingsClearDatabaseSuccess;

  /// Header for about section in settings
  ///
  /// In en, this message translates to:
  /// **'About WayMark'**
  String get settingsAboutSection;

  /// Toast message when all journeys are cleared
  ///
  /// In en, this message translates to:
  /// **'All journey memoirs cleared successfully'**
  String get settingsStorageClearedToast;

  /// Title of the place logger bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Log a New Stop'**
  String get placeLoggerTitle;

  /// Subtitle of the place logger bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Pin a waypoint, milestone, or memory to your expedition.'**
  String get placeLoggerSubtitle;

  /// Label for place name input
  ///
  /// In en, this message translates to:
  /// **'Place Name'**
  String get placeLoggerNameLabel;

  /// Hint for place name input
  ///
  /// In en, this message translates to:
  /// **'e.g. Fushimi Inari Shrine'**
  String get placeLoggerNameHint;

  /// Label for category picker
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get placeLoggerCategoryLabel;

  /// Label for notes input
  ///
  /// In en, this message translates to:
  /// **'Field Notes'**
  String get placeLoggerNotesLabel;

  /// Hint for notes input
  ///
  /// In en, this message translates to:
  /// **'Observations, impressions...'**
  String get placeLoggerNotesHint;

  /// Button to save the logged waypoint
  ///
  /// In en, this message translates to:
  /// **'Log Waypoint'**
  String get placeLoggerBtnSave;

  /// Toast when waypoint is saved
  ///
  /// In en, this message translates to:
  /// **'Waypoint logged to your expedition!'**
  String get placeLoggerSuccessToast;

  /// Toast when waypoint is updated
  ///
  /// In en, this message translates to:
  /// **'Waypoint updated successfully!'**
  String get placeLoggerUpdatedToast;

  /// Title of log new place story sheet
  ///
  /// In en, this message translates to:
  /// **'Log New Place'**
  String get placeLoggerLogNewPlace;

  /// Title of edit place story sheet
  ///
  /// In en, this message translates to:
  /// **'Edit Place'**
  String get placeLoggerEditPlace;

  /// Top action button to save place
  ///
  /// In en, this message translates to:
  /// **'Save Place'**
  String get placeLoggerSavePlace;

  /// Placeholder for global location search bar
  ///
  /// In en, this message translates to:
  /// **'Search landmark, cafe, or coordinates...'**
  String get placeLoggerSearchPlaceholder;

  /// Smart GPS detection banner title
  ///
  /// In en, this message translates to:
  /// **'Detected GPS from photo'**
  String get placeLoggerDetectedGpsTitle;

  /// Status badge for matched coordinates
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get placeLoggerMatched;

  /// Floating pill beneath the beacon pin marker
  ///
  /// In en, this message translates to:
  /// **'Drag pin to calibrate'**
  String get placeLoggerDragPinCalibrate;

  /// Header for place identity section
  ///
  /// In en, this message translates to:
  /// **'PLACE IDENTITY'**
  String get placeLoggerPlaceIdentity;

  /// Label for category tag chips
  ///
  /// In en, this message translates to:
  /// **'Category Tag'**
  String get placeLoggerCategoryTag;

  /// Label for visited time card
  ///
  /// In en, this message translates to:
  /// **'Visited Time'**
  String get placeLoggerVisitedTime;

  /// Label for sky and temperature card
  ///
  /// In en, this message translates to:
  /// **'Sky & Temp'**
  String get placeLoggerSkyAndTemp;

  /// Header for visual relics and photos section
  ///
  /// In en, this message translates to:
  /// **'Visual Relics & Photos'**
  String get placeLoggerVisualRelics;

  /// Cover badge on primary photo
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get placeLoggerCoverBadge;

  /// Label for add photo card
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get placeLoggerAddPhoto;

  /// Caption beneath add photo
  ///
  /// In en, this message translates to:
  /// **'Max 6 photos'**
  String get placeLoggerMaxPhotos;

  /// Header for sensory impressions section
  ///
  /// In en, this message translates to:
  /// **'Sensory Impressions'**
  String get placeLoggerSensoryImpressions;

  /// Placeholder for sensory notes field
  ///
  /// In en, this message translates to:
  /// **'How did the wind smell? What sounds echoed? Record fleeting moments...'**
  String get placeLoggerSensoryHint;

  /// Bottom action button to log place to journey
  ///
  /// In en, this message translates to:
  /// **'Log Place to {title}'**
  String placeLoggerLogToJourney(String title);

  /// Bottom action button to update place in journey
  ///
  /// In en, this message translates to:
  /// **'Update Place in {title}'**
  String placeLoggerUpdatePlaceInJourney(String title);

  /// Footer under bottom action button
  ///
  /// In en, this message translates to:
  /// **'Synchronized with offline storage • Auto-assigns to Route {order}'**
  String placeLoggerSyncSubtitle(String order);

  /// Map preview placeholder subtitle
  ///
  /// In en, this message translates to:
  /// **'Route polyline renders once multiple waypoints are added'**
  String get journeyDetailMapPreview;

  /// Timeline section label
  ///
  /// In en, this message translates to:
  /// **'JOURNEY TIMELINE'**
  String get journeyDetailTimeline;

  /// Common cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Common confirm button label
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// Common save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Common required validation message
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get commonRequired;

  /// Common optional text
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get commonOptional;

  /// Title of clear journeys dialog
  ///
  /// In en, this message translates to:
  /// **'Clear Journey Records'**
  String get settingsDialogClearTitle;

  /// Description of clear journeys dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all journey memoirs, waypoints, and photos? Your profile settings will be preserved.'**
  String get settingsDialogClearDesc;

  /// Confirm button for clearing journeys
  ///
  /// In en, this message translates to:
  /// **'Clear Journeys'**
  String get settingsDialogClearConfirm;

  /// Confirm button for wiping database
  ///
  /// In en, this message translates to:
  /// **'Wipe Everything'**
  String get settingsDialogWipeConfirm;

  /// Title of drift sqlite card in settings
  ///
  /// In en, this message translates to:
  /// **'Drift SQLite Engine'**
  String get settingsDriftEngineTitle;

  /// Subtitle of drift sqlite card in settings
  ///
  /// In en, this message translates to:
  /// **'Local, zero-cloud encrypted storage vault'**
  String get settingsDriftEngineSubtitle;

  /// Active status label in settings
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get settingsStatusActive;

  /// Title for clear memoirs item in settings
  ///
  /// In en, this message translates to:
  /// **'Clear All Journey Memoirs'**
  String get settingsClearMemoirsTitle;

  /// Description for clear memoirs item in settings
  ///
  /// In en, this message translates to:
  /// **'Removes all trips, waypoints, and photos, but keeps your traveler profile.'**
  String get settingsClearMemoirsDesc;

  /// Clear button in settings
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get settingsBtnClear;

  /// Wipe vault button in settings
  ///
  /// In en, this message translates to:
  /// **'Wipe Vault'**
  String get settingsBtnWipeVault;

  /// App description in settings
  ///
  /// In en, this message translates to:
  /// **'WayMark: Memoir & Living Atlas'**
  String get settingsAppDescription;

  /// App version in settings
  ///
  /// In en, this message translates to:
  /// **'v1.0.0'**
  String get settingsAppVersion;

  /// Environment flavor label in settings
  ///
  /// In en, this message translates to:
  /// **'Environment Flavor'**
  String get settingsEnvFlavor;

  /// Storage architecture label in settings
  ///
  /// In en, this message translates to:
  /// **'Storage Architecture'**
  String get settingsStorageArch;

  /// Storage architecture value in settings
  ///
  /// In en, this message translates to:
  /// **'SQLite 3 / Drift ORM'**
  String get settingsStorageArchValue;

  /// Badge when studio has no memories
  ///
  /// In en, this message translates to:
  /// **'STUDIO CLOSED'**
  String get studioBadgeClosed;

  /// Title when studio has no memories
  ///
  /// In en, this message translates to:
  /// **'No memories to print'**
  String get studioNoMemoriesTitle;

  /// Description when studio has no memories
  ///
  /// In en, this message translates to:
  /// **'Add a journey and places to start making postcards.'**
  String get studioNoMemoriesDesc;

  /// Studio atelier badge
  ///
  /// In en, this message translates to:
  /// **'POSTCARD ATELIER'**
  String get studioBadgeAtelier;

  /// Studio memory prints header
  ///
  /// In en, this message translates to:
  /// **'Memory Prints'**
  String get studioMemoryPrintsTitle;

  /// Studio memory prints subtitle
  ///
  /// In en, this message translates to:
  /// **'Craft bespoke vintage travel postcards from your expedition stops'**
  String get studioMemoryPrintsSubtitle;

  /// Studio banner notice
  ///
  /// In en, this message translates to:
  /// **'Select a memory below to generate a postcard. Full generator coming soon.'**
  String get studioBannerNotice;

  /// Studio section header for memories
  ///
  /// In en, this message translates to:
  /// **'JOURNEY MEMORIES'**
  String get studioSectionMemories;

  /// Postcard generator promo title
  ///
  /// In en, this message translates to:
  /// **'Postcard Generator'**
  String get studioGeneratorTitle;

  /// Postcard generator promo description
  ///
  /// In en, this message translates to:
  /// **'Export high-resolution vintage postcards with your GPS coordinates, altitude, and weather stamped into the design. Coming in the next update.'**
  String get studioGeneratorDesc;

  /// Button to create postcard
  ///
  /// In en, this message translates to:
  /// **'Create Postcard'**
  String get studioBtnCreatePostcard;

  /// Toast when postcard card is tapped
  ///
  /// In en, this message translates to:
  /// **'Postcard generator coming soon for {name}!'**
  String studioComingSoonToast(String name);

  /// Badge on explore empty state
  ///
  /// In en, this message translates to:
  /// **'UNMAPPED HORIZONS'**
  String get exploreBadgeUnmapped;

  /// Explore screen hero title
  ///
  /// In en, this message translates to:
  /// **'Explore Your Footprints'**
  String get exploreFootprintsTitle;

  /// Explore screen hero subtitle
  ///
  /// In en, this message translates to:
  /// **'Interactive map coming soon'**
  String get exploreFootprintsSubtitle;

  /// Explore screen hero badge
  ///
  /// In en, this message translates to:
  /// **'INTERACTIVE MAP COMING SOON'**
  String get exploreBadgeComingSoon;

  /// Explore screen summary stats
  ///
  /// In en, this message translates to:
  /// **'{albumsCount, plural, =1{1 Journey} other{{albumsCount} Journeys}}  •  {waypointsCount, plural, =1{1 Waypoint} other{{waypointsCount} Waypoints}}'**
  String exploreStatsSummary(int albumsCount, int waypointsCount);

  /// Recent waypoints section title
  ///
  /// In en, this message translates to:
  /// **'Recent Waypoints'**
  String get exploreRecentWaypointsTitle;

  /// Toast when waypoint card is tapped
  ///
  /// In en, this message translates to:
  /// **'Waypoint detail coming in next update'**
  String get exploreWaypointComingSoonToast;

  /// Toast when exporting expedition report
  ///
  /// In en, this message translates to:
  /// **'Exporting expedition report'**
  String get journeyDetailExportReportToast;

  /// Tooltip on log waypoint FAB
  ///
  /// In en, this message translates to:
  /// **'Log Waypoint'**
  String get journeyDetailLogWaypointTooltip;

  /// Ongoing journey status pill
  ///
  /// In en, this message translates to:
  /// **'ONGOING'**
  String get journeyStatusOngoing;

  /// Completed journey status pill
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get journeyStatusCompleted;

  /// Present date text for active journeys
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get journeyDatePresent;

  /// Places count text on journey detail
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 place} other{{count} places}}'**
  String journeyPlacesCount(int count);

  /// Route map title on detail card
  ///
  /// In en, this message translates to:
  /// **'Route Map'**
  String get journeyDetailRouteMap;

  /// Badge on journey detail empty state
  ///
  /// In en, this message translates to:
  /// **'EXPEDITION LOGBOOK'**
  String get journeyDetailExpeditionLogbook;

  /// Weather label in place logger
  ///
  /// In en, this message translates to:
  /// **'Weather Condition (Optional)'**
  String get placeLoggerWeatherLabel;

  /// GPS status text in place logger
  ///
  /// In en, this message translates to:
  /// **'GPS: Location will be pinned automatically'**
  String get placeLoggerGpsNotice;

  /// Toast on place logger error
  ///
  /// In en, this message translates to:
  /// **'Failed to log waypoint.'**
  String get placeLoggerFailedToast;

  /// Weather condition sunny
  ///
  /// In en, this message translates to:
  /// **'Sunny'**
  String get weatherSunny;

  /// Weather condition cloudy
  ///
  /// In en, this message translates to:
  /// **'Cloudy'**
  String get weatherCloudy;

  /// Weather condition rainy
  ///
  /// In en, this message translates to:
  /// **'Rainy'**
  String get weatherRainy;

  /// Weather condition cold
  ///
  /// In en, this message translates to:
  /// **'Cold'**
  String get weatherCold;

  /// Weather condition foggy
  ///
  /// In en, this message translates to:
  /// **'Foggy'**
  String get weatherFoggy;

  /// Category general
  ///
  /// In en, this message translates to:
  /// **'GENERAL'**
  String get categoryGeneral;

  /// Category sightseeing
  ///
  /// In en, this message translates to:
  /// **'SIGHTSEEING'**
  String get categorySightseeing;

  /// Category food
  ///
  /// In en, this message translates to:
  /// **'FOOD'**
  String get categoryFood;

  /// Category stay
  ///
  /// In en, this message translates to:
  /// **'STAY'**
  String get categoryStay;

  /// Category hike
  ///
  /// In en, this message translates to:
  /// **'HIKE'**
  String get categoryHike;

  /// Category transit
  ///
  /// In en, this message translates to:
  /// **'TRANSIT'**
  String get categoryTransit;

  /// Validation error for empty journey title
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get createJourneyTitleValidation;

  /// Toast when journey is created
  ///
  /// In en, this message translates to:
  /// **'Created expedition \"{title}\"'**
  String createJourneySuccessToast(String title);

  /// Toast when journey creation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create journey: {error}'**
  String createJourneyErrorToast(String error);

  /// Button to take avatar photo
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get profileBtnTakePhoto;

  /// Button to pick avatar from gallery
  ///
  /// In en, this message translates to:
  /// **'From Gallery'**
  String get profileBtnFromGallery;

  /// Header for avatar presets
  ///
  /// In en, this message translates to:
  /// **'CHOOSE AVATAR PRESET'**
  String get profileChoosePresetTitle;

  /// Toast when camera fails
  ///
  /// In en, this message translates to:
  /// **'Unable to access camera: {error}'**
  String profileCameraError(String error);

  /// Toast when gallery fails
  ///
  /// In en, this message translates to:
  /// **'Unable to access photo library: {error}'**
  String profileGalleryError(String error);

  /// Portrait title in onboarding
  ///
  /// In en, this message translates to:
  /// **'Traveler Portrait'**
  String get onboardingPortraitTitle;

  /// Portrait subtitle in onboarding
  ///
  /// In en, this message translates to:
  /// **'Take a photo, choose from gallery, or select an avatar.'**
  String get onboardingPortraitSubtitle;

  /// Archetype selector modal title
  ///
  /// In en, this message translates to:
  /// **'Choose Your Travel Style'**
  String get archetypeModalTitle;

  /// Archetype selector modal subtitle
  ///
  /// In en, this message translates to:
  /// **'Select the travel style that best matches how you like to journey.'**
  String get archetypeModalSubtitle;

  /// Button to change archetype
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get archetypeBtnChange;

  /// Vault card title in onboarding
  ///
  /// In en, this message translates to:
  /// **'Private Travel Storage'**
  String get onboardingVaultTitle;

  /// Vault card subtitle in onboarding
  ///
  /// In en, this message translates to:
  /// **'Private • On-Device Only'**
  String get onboardingVaultSubtitle;

  /// Offline pill text in onboarding vault card
  ///
  /// In en, this message translates to:
  /// **'100% Offline'**
  String get onboardingVaultOfflinePill;

  /// Stop sequence number in recent discoveries
  ///
  /// In en, this message translates to:
  /// **'Stop #{order}'**
  String journeysStopNumber(int order);

  /// Tag backpacking
  ///
  /// In en, this message translates to:
  /// **'Backpacking'**
  String get tagBackpacking;

  /// Tag temples
  ///
  /// In en, this message translates to:
  /// **'Temples'**
  String get tagTemples;

  /// Tag tea trails
  ///
  /// In en, this message translates to:
  /// **'Tea Trails'**
  String get tagTeaTrails;

  /// App philosophy headline on splash screen
  ///
  /// In en, this message translates to:
  /// **'Your Journey.  Your Story.'**
  String get appPhilosophy;

  /// Travel action verb on splash screen
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get verbTravel;

  /// Journal action verb on splash screen
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get verbJournal;

  /// Relive action verb on splash screen
  ///
  /// In en, this message translates to:
  /// **'Relive'**
  String get verbRelive;

  /// Feature column title on splash
  ///
  /// In en, this message translates to:
  /// **'Interactive Route Maps'**
  String get interactiveRouteMapsTitle;

  /// Feature column description on splash
  ///
  /// In en, this message translates to:
  /// **'Vector polylines & elevation profiles'**
  String get interactiveRouteMapsDesc;

  /// Feature column title on splash
  ///
  /// In en, this message translates to:
  /// **'Artistic Journey Postcards'**
  String get artisticJourneyPostcardsTitle;

  /// Feature column description on splash
  ///
  /// In en, this message translates to:
  /// **'Vintage typography & metadata stamps'**
  String get artisticJourneyPostcardsDesc;

  /// Feature column title on splash
  ///
  /// In en, this message translates to:
  /// **'100% Offline First'**
  String get offlineFirstTitle;

  /// Feature column description on splash
  ///
  /// In en, this message translates to:
  /// **'Private sqlite vault with no tracking'**
  String get offlineFirstDesc;

  /// Bottom tagline on splash
  ///
  /// In en, this message translates to:
  /// **'— More Than Just Photos —'**
  String get moreThanJustPhotos;

  /// Loading vault status text on splash
  ///
  /// In en, this message translates to:
  /// **'Initializing local vault...'**
  String get initializingLocalVault;

  /// Header for recent discoveries carousel
  ///
  /// In en, this message translates to:
  /// **'Recent Discoveries'**
  String get journeysRecentDiscoveries;

  /// Action button to view map in recent discoveries
  ///
  /// In en, this message translates to:
  /// **'See Map'**
  String get journeysSeeMap;

  /// Header for archived memoirs section
  ///
  /// In en, this message translates to:
  /// **'Archived Memoirs'**
  String get journeysArchivedMemoirs;

  /// Count of completed memoirs
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 completed} other{{count} completed}}'**
  String journeysCompletedCount(int count);

  /// Filter tab all
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Filter tab ongoing
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get filterOngoing;

  /// Filter tab completed
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filterCompleted;

  /// Filter tab favorites
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get filterFavorites;

  /// Title in export field journal banner
  ///
  /// In en, this message translates to:
  /// **'Export Field Journal'**
  String get journeysExportFieldJournalTitle;

  /// Description in export field journal banner
  ///
  /// In en, this message translates to:
  /// **'Generate an archival PDF dossier of your journeys with high-res photos and route logs.'**
  String get journeysExportFieldJournalDesc;

  /// Button to preview journal in export banner
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get journeysBtnPreview;

  /// Badge in active journey hero card
  ///
  /// In en, this message translates to:
  /// **'Active Expedition'**
  String get journeysActiveExpedition;

  /// Live GPS tracking status in active journey hero card
  ///
  /// In en, this message translates to:
  /// **'GPS Tracking Active'**
  String get journeysGpsTrackingActive;

  /// Ongoing expedition badge in active journey hero card
  ///
  /// In en, this message translates to:
  /// **'Ongoing Expedition'**
  String get journeysOngoingExpedition;

  /// Day counter in active journey hero card
  ///
  /// In en, this message translates to:
  /// **'Day {current} of {total}'**
  String journeysDayOf(int current, int total);

  /// Distance stat label in active journey hero card
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get journeysDistanceLabel;

  /// Places stat label in active journey hero card
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get journeysWaypointsLabel;

  /// Places logged stat in active journey hero card
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 place} other{{count} places}} logged'**
  String journeysWaypointsLogged(int count);

  /// Pace log stat label in active journey hero card
  ///
  /// In en, this message translates to:
  /// **'Pace Log'**
  String get journeysPaceLogLabel;

  /// Pace on track value in active journey hero card
  ///
  /// In en, this message translates to:
  /// **'On Track'**
  String get journeysPaceOnTrack;

  /// Title for route trace section in active journey card
  ///
  /// In en, this message translates to:
  /// **'ROUTE TRACE'**
  String get journeysRouteTraceTitle;

  /// Subtitle for route trace section in active journey card
  ///
  /// In en, this message translates to:
  /// **'Waypoints connected in order'**
  String get journeysRouteTraceSubtitle;

  /// Button to continue memoir in active journey card
  ///
  /// In en, this message translates to:
  /// **'Continue Memoir'**
  String get journeysBtnContinueMemoir;

  /// Security footer on empty deck view
  ///
  /// In en, this message translates to:
  /// **'Private SQLite Vault • 100% Offline • Zero Data Tracking'**
  String get emptyDeckSecurityFooter;

  /// Hero title on onboarding screen
  ///
  /// In en, this message translates to:
  /// **'WayMark'**
  String get onboardingHeroTitle;

  /// Hero italic subtitle on onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Expeditions'**
  String get onboardingHeroTitleItalic;

  /// Hero description on onboarding screen
  ///
  /// In en, this message translates to:
  /// **'An offline-first travel journal that turns your routes and memories into artistic memoirs.'**
  String get onboardingHeroDesc;

  /// Feature 1 title on onboarding
  ///
  /// In en, this message translates to:
  /// **'Interactive Route Maps'**
  String get onboardingFeature1Title;

  /// Feature 1 badge on onboarding
  ///
  /// In en, this message translates to:
  /// **'VECTOR'**
  String get onboardingFeature1Badge;

  /// Feature 1 description on onboarding
  ///
  /// In en, this message translates to:
  /// **'Real-time breadcrumb tracking with high-res polyline mapping.'**
  String get onboardingFeature1Desc;

  /// Feature 2 title on onboarding
  ///
  /// In en, this message translates to:
  /// **'Artistic Postcards'**
  String get onboardingFeature2Title;

  /// Feature 2 badge on onboarding
  ///
  /// In en, this message translates to:
  /// **'STUDIO'**
  String get onboardingFeature2Badge;

  /// Feature 2 description on onboarding
  ///
  /// In en, this message translates to:
  /// **'Generate vintage expedition postcards stamped with GPS and weather data.'**
  String get onboardingFeature2Desc;

  /// Feature 3 title on onboarding
  ///
  /// In en, this message translates to:
  /// **'Private Local Vault'**
  String get onboardingFeature3Title;

  /// Feature 3 badge on onboarding
  ///
  /// In en, this message translates to:
  /// **'100% OFFLINE'**
  String get onboardingFeature3Badge;

  /// Feature 3 description on onboarding
  ///
  /// In en, this message translates to:
  /// **'Your data never leaves your device. Fully encrypted local SQLite storage.'**
  String get onboardingFeature3Desc;

  /// Button to begin setup on onboarding
  ///
  /// In en, this message translates to:
  /// **'Begin Expedition Setup'**
  String get onboardingBtnBeginSetup;

  /// Prefix text for restore backup on onboarding
  ///
  /// In en, this message translates to:
  /// **'Have an existing vault? '**
  String get onboardingRestoreBackupPrefix;

  /// Clickable text for restore backup on onboarding
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get onboardingRestoreBackupFile;

  /// Suffix text for restore backup on onboarding
  ///
  /// In en, this message translates to:
  /// **' to continue where you left off.'**
  String get onboardingRestoreBackupSuffix;

  /// Title in onboarding step 2
  ///
  /// In en, this message translates to:
  /// **'Claim Your Compass'**
  String get profileClaimCompassTitle;

  /// Button to initialize vault on profile/onboarding
  ///
  /// In en, this message translates to:
  /// **'Initialize Local Vault'**
  String get profileBtnInitializeVault;

  /// Offline badge on traveler avatar picker
  ///
  /// In en, this message translates to:
  /// **'100% Offline'**
  String get profileOfflineFirst;

  /// Skip button in onboarding header
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Step 1 badge in onboarding header
  ///
  /// In en, this message translates to:
  /// **'STEP 1 OF 2'**
  String get onboardingStep1Badge;

  /// Step 2 badge in onboarding header
  ///
  /// In en, this message translates to:
  /// **'STEP 2 OF 2'**
  String get onboardingStep2Badge;

  /// Measurement standards label in vault settings card
  ///
  /// In en, this message translates to:
  /// **'Measurement Standards'**
  String get profileMeasurementStandards;

  /// Metric unit option in vault settings card
  ///
  /// In en, this message translates to:
  /// **'Metric (km, m, °C)'**
  String get profileMetricUnit;

  /// Imperial unit option in vault settings card
  ///
  /// In en, this message translates to:
  /// **'Imperial (mi, ft, °F)'**
  String get profileImperialUnit;

  /// Auto EXIF setting title in vault settings card
  ///
  /// In en, this message translates to:
  /// **'Auto-Extract EXIF Data'**
  String get profileAutoExifTitle;

  /// Auto EXIF setting description in vault settings card
  ///
  /// In en, this message translates to:
  /// **'Extract GPS coordinates and timestamps from photos automatically'**
  String get profileAutoExifDesc;

  /// Database target label in vault settings card
  ///
  /// In en, this message translates to:
  /// **'Database Target'**
  String get profileDbTargetLabel;

  /// Allocated badge in vault settings card
  ///
  /// In en, this message translates to:
  /// **'Allocated'**
  String get profileDbAllocated;

  /// Header for privacy section on settings screen
  ///
  /// In en, this message translates to:
  /// **'Privacy & Architecture'**
  String get settingsPrivacySection;

  /// Title for zero cloud tracking point
  ///
  /// In en, this message translates to:
  /// **'Zero Cloud Tracking'**
  String get settingsZeroCloudTitle;

  /// Description for zero cloud tracking point
  ///
  /// In en, this message translates to:
  /// **'All journeys, coordinates, and memoirs remain strictly on your device.'**
  String get settingsZeroCloudDesc;

  /// Title for native EXIF extraction point
  ///
  /// In en, this message translates to:
  /// **'Native Hardware EXIF Extraction'**
  String get settingsNativeExifTitle;

  /// Description for native EXIF extraction point
  ///
  /// In en, this message translates to:
  /// **'Stamps date, time, and coordinates from your original photos without internet.'**
  String get settingsNativeExifDesc;

  /// Title for offline vector trails point
  ///
  /// In en, this message translates to:
  /// **'Offline Vector Trails'**
  String get settingsOfflineTrailsTitle;

  /// Description for offline vector trails point
  ///
  /// In en, this message translates to:
  /// **'Calculates smooth geographic trajectories through on-device interpolation.'**
  String get settingsOfflineTrailsDesc;

  /// Stops count formatted
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 stop} other{{count} stops}}'**
  String profileStopsCount(int count);

  /// Badge on profile travel albums empty state
  ///
  /// In en, this message translates to:
  /// **'EXPEDITION LOGS'**
  String get profileTravelAlbumsEmptyBadge;

  /// Badge indicating 100% private storage
  ///
  /// In en, this message translates to:
  /// **'100% Private'**
  String get profilePrivateBadge;

  /// Archive label on onboarding hero card
  ///
  /// In en, this message translates to:
  /// **'WAYMARK ARCHIVE'**
  String get onboardingHeroArchive;

  /// Plate number label on onboarding hero card
  ///
  /// In en, this message translates to:
  /// **'PLATE NO. 12'**
  String get onboardingHeroPlateNo;

  /// Snackbar info text for restore backup on onboarding
  ///
  /// In en, this message translates to:
  /// **'Select your encrypted .waymark archive file to restore local trips and journal snapshots.'**
  String get onboardingRestoreBackupSnackbar;

  /// Error message when initializing vault fails
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize vault: {error}'**
  String onboardingVaultInitError(String error);

  /// Title for private travel storage card
  ///
  /// In en, this message translates to:
  /// **'Private Travel Storage'**
  String get vaultPrivateStorageTitle;

  /// Subtitle for private travel storage card
  ///
  /// In en, this message translates to:
  /// **'Private • On-Device Only'**
  String get vaultPrivateStorageSubtitle;

  /// Offline badge on private travel storage card
  ///
  /// In en, this message translates to:
  /// **'100% Offline'**
  String get vaultOfflineBadge;

  /// Badge on empty journeys deck
  ///
  /// In en, this message translates to:
  /// **'OFFLINE FIELD JOURNAL'**
  String get emptyDeckBadge;

  /// Default clear weather fallback
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get weatherClear;

  /// Stop order indicator on waypoint card
  ///
  /// In en, this message translates to:
  /// **'Stop #{order}'**
  String journeysStopOrder(int order);

  /// Snackbar text when preparing field journal export
  ///
  /// In en, this message translates to:
  /// **'Field Journal PDF compiler is preparing your printable layout...'**
  String get journeysExportFieldJournalPreparing;

  /// Badge for expedition status on journeys dashboard
  ///
  /// In en, this message translates to:
  /// **'EXPEDITION STATUS'**
  String get journeysExpeditionStatusBadge;

  /// Snackbar text when a waypoint is tapped
  ///
  /// In en, this message translates to:
  /// **'Selected waypoint: {name}'**
  String journeysSelectedWaypoint(String name);

  /// Tag label for backpacking
  ///
  /// In en, this message translates to:
  /// **'Backpacking'**
  String get journeysTagBackpacking;

  /// Tag label for temples
  ///
  /// In en, this message translates to:
  /// **'Temples'**
  String get journeysTagTemples;

  /// Tag label for tea trails
  ///
  /// In en, this message translates to:
  /// **'Tea Trails'**
  String get journeysTagTeaTrails;

  /// Validation message when title is empty in create journey form
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get createJourneyTitleRequired;

  /// Optional label in create journey form
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get createJourneyOptional;

  /// Error toast when creating a journey fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create journey: {error}'**
  String createJourneyFailedToast(String error);
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
