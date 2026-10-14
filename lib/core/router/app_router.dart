import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/presentation/screens/waymark_navigation_shell.dart';
import 'package:waymark/core/router/route_names.dart';
import 'package:waymark/core/services/remote_config_models.dart';
import 'package:waymark/core/services/remote_config_service.dart';
import 'package:waymark/features/app_maintenance/presentation/screens/app_maintenance_screen.dart';
import 'package:waymark/features/app_update/presentation/screens/app_update_screen.dart';
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
    refreshListenable: RemoteConfigService.instance.gateNotifier,
    debugLogDiagnostics: false,
    redirect: (context, state) async {
      final matched = state.matchedLocation;
      final isSplash = matched == AppRoutes.splash;
      final isMaintenance = matched == AppRoutes.maintenance;
      final isUpdate = matched == AppRoutes.appUpdate;

      final gate = RemoteConfigService.instance.currentGate;

      // Allow splash to run its initial 5-second cinematic entrance & bootstrap
      if (isSplash) return null;

      // 1. Check Maintenance Gate
      if (gate.status == AppGateStatus.maintenance) {
        return isMaintenance ? null : AppRoutes.maintenance;
      }
      if (isMaintenance && gate.status != AppGateStatus.maintenance) {
        return AppRoutes.splash;
      }

      // 2. Check Force Update Gate
      if (gate.status == AppGateStatus.forceUpdate) {
        return isUpdate ? null : AppRoutes.appUpdate;
      }

      final isOnboarding = matched == AppRoutes.onboarding;
      if (isOnboarding || isUpdate) return null;

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

      // 2. App Maintenance Screen (Remote Config Controlled)
      GoRoute(
        path: AppRoutes.maintenance,
        name: AppRoutes.maintenanceName,
        builder: (context, state) => const AppMaintenanceScreen(),
      ),

      // 3. App Update Screen (Force & Recommended Update)
      GoRoute(
        path: AppRoutes.appUpdate,
        name: AppRoutes.appUpdateName,
        builder: (context, state) {
          final eval = state.extra as AppGateEvaluation?;
          return AppUpdateScreen(initialEvaluation: eval);
        },
      ),

      // 4. Onboarding Screen
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
              final highlightId = state.uri.queryParameters['highlightPlaceId'];
              return JourneyAlbumDetailScreen(
                journeyId: id,
                initialHighlightPlaceId: highlightId,
              );
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
