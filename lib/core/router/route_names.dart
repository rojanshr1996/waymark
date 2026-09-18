/// Centralized route paths and route names for GoRouter
class AppRoutes {
  // --- Root & Onboarding ---
  static const String splash = '/';
  static const String splashName = 'splash';

  static const String onboarding = '/onboarding';
  static const String onboardingName = 'onboarding';

  // --- Shell Branches (Bottom Navigation) ---
  // Branch 1: Journeys
  static const String journeys = '/journeys';
  static const String journeysName = 'journeys';

  static const String journeyDetail = '/journeys/:id';
  static const String journeyDetailName = 'journeyDetail';

  static const String activeExpeditions = '/journeys/active-expeditions';
  static const String activeExpeditionsName = 'activeExpeditions';

  static const String createJourney = '/journeys/create';
  static const String createJourneyName = 'createJourney';

  // Branch 2: Explore
  static const String explore = '/explore';
  static const String exploreName = 'explore';

  // Branch 3: Studio
  static const String studio = '/studio';
  static const String studioName = 'studio';

  // Branch 4: Profile
  static const String profile = '/profile';
  static const String profileName = 'profile';

  // --- Fullscreen Modals / Actions ---
  static const String placeLogger = '/logger/:albumId';
  static const String placeLoggerName = 'placeLogger';

  static const String postcardGenerator = '/postcard/:albumId';
  static const String postcardGeneratorName = 'postcardGenerator';

  // --- Settings ---
  static const String settings = '/settings';
  static const String settingsName = 'settings';
}
