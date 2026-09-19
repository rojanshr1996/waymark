import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/presentation/screens/waymark_navigation_shell.dart';
import 'package:waymark/core/router/route_names.dart';
import 'package:waymark/features/journeys/presentation/screens/all_active_expeditions_screen.dart';
import 'package:waymark/features/journeys/presentation/screens/journey_album_detail_screen.dart';
import 'package:waymark/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:waymark/features/settings/presentation/screens/settings_info_screens.dart';
import 'package:waymark/features/settings/presentation/screens/settings_screen.dart';
import 'package:waymark/features/splash/presentation/screens/splash_screen.dart';
import 'package:waymark/features/studio/presentation/screens/postcard_studio_screen.dart';

/// Centralized application router using GoRouter with declarative routing
/// and persistent StatefulShellRoute navigation for bottom tabs.
class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'rootNav');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) async {
      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (isSplash || isOnboarding) return null;

      final profile = await AppDatabase.instance.userProfileDao.getProfile();
      if (profile == null) {
        return AppRoutes.onboarding;
      }
      return null;
    },
    routes: [
      // 1. Splash Screen (Root)
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashScreen(),
      ),

      // 2. Onboarding Screen
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboardingName,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // 3. Settings Screen
      GoRoute(
        path: AppRoutes.settings,
        name: AppRoutes.settingsName,
        builder: (context, state) => const SettingsScreen(),
      ),

      GoRoute(
        path: AppRoutes.helpSupport,
        name: AppRoutes.helpSupportName,
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.faq,
        name: AppRoutes.faqName,
        builder: (context, state) => const FaqScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        name: AppRoutes.aboutName,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        name: AppRoutes.privacyPolicyName,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: AppRoutes.termsConditions,
        name: AppRoutes.termsConditionsName,
        builder: (context, state) => const TermsConditionsScreen(),
      ),

      // 4. Main Shell Page with 4 Child Screens & Detail Subroute
      GoRoute(
        path: AppRoutes.activeExpeditions,
        name: AppRoutes.activeExpeditionsName,
        builder: (context, state) => const AllActiveExpeditionsScreen(),
      ),

      GoRoute(
        path: AppRoutes.journeys,
        name: AppRoutes.journeysName,
        builder: (context, state) =>
            const WaymarkNavigationShell(initialIndex: 0),
        routes: [
          GoRoute(
            path: ':id',
            name: AppRoutes.journeyDetailName,
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return JourneyAlbumDetailScreen(journeyId: id);
            },
          ),
        ],
      ),

      // Direct routes mapped to corresponding tab on WaymarkNavigationShell
      GoRoute(
        path: AppRoutes.explore,
        name: AppRoutes.exploreName,
        builder: (context, state) =>
            const WaymarkNavigationShell(initialIndex: 1),
      ),

      GoRoute(
        path: AppRoutes.studio,
        name: AppRoutes.studioName,
        builder: (context, state) =>
            const WaymarkNavigationShell(initialIndex: 2),
      ),

      GoRoute(
        path: AppRoutes.profile,
        name: AppRoutes.profileName,
        builder: (context, state) =>
            const WaymarkNavigationShell(initialIndex: 3),
      ),

      GoRoute(
        path: AppRoutes.postcardGenerator,
        name: AppRoutes.postcardGeneratorName,
        builder: (context, state) => PostcardStudioScreen(
          initialAlbumId: state.pathParameters['albumId'],
        ),
      ),
    ],
  );
}
