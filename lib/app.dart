import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/config/flavor_config.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/l10n/app_localizations.dart';
import 'package:waymark/core/presentation/widgets/widgets.dart';
import 'package:waymark/core/router/app_router.dart';
import 'package:waymark/core/theme/waymark_theme.dart';
import 'package:waymark/core/theme/waymark_typography.dart';

class WaymarkApp extends StatelessWidget {
  const WaymarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppFlavorConfig.instance;

    return ScreenUtilInit(
      designSize: const Size(390, 844), // Standard modern mobile design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: config.appTitle,
          debugShowCheckedModeBanner: !config.flavor.isProduction,
          theme: WaymarkTheme.lightTheme,
          scrollBehavior: const WaymarkNoOverscrollScrollBehavior(),
          routerConfig: AppRouter.router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}

class FlavorHomeScreen extends StatefulWidget {
  final AppFlavorConfig config;

  const FlavorHomeScreen({super.key, required this.config});

  @override
  State<FlavorHomeScreen> createState() => _FlavorHomeScreenState();
}

class _FlavorHomeScreenState extends State<FlavorHomeScreen> {
  final ValueNotifier<int> _currentNavIndexNotifier = ValueNotifier<int>(0);

  @override
  void dispose() {
    _currentNavIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;

    return ValueListenableBuilder<int>(
      valueListenable: _currentNavIndexNotifier,
      builder: (context, currentNavIndex, _) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          appBar: WaymarkLiquidGlassAppBar(
            showBrandMasthead: true,
            sectionName: switch (currentNavIndex) {
              0 => 'Journeys',
              1 => 'Explore',
              2 => 'Studio',
              3 => 'Profile',
              _ => 'Journeys',
            },
            actions: [
              if (!config.flavor.isProduction)
                Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: WaymarkStatusPill(
                    label: config.flavor.name.toUpperCase(),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () {},
              ),
            ],
          ),
          bottomNavigationBar: WaymarkLiquidGlassBottomNavBar(
            currentIndex: currentNavIndex,
            onTap: (index) {
              _currentNavIndexNotifier.value = index;
            },
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: WaymarkSpacing.margin(context),
                vertical: 100.h,
              ),
              child: WaymarkCard(
                padding: EdgeInsets.all(WaymarkSpacing.spaceLg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28.sp,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Environment: ${config.flavor.displayName}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24.h),
                    _buildInfoRow(context, 'App Name', config.appTitle),
                    _buildInfoRow(
                      context,
                      'Flavor Identifier',
                      config.flavor.name,
                    ),
                    _buildInfoRow(
                      context,
                      'Active Tab',
                      WaymarkLiquidGlassBottomNavBar.defaultItems(
                        context,
                      )[currentNavIndex].label,
                    ),
                    _buildInfoRow(
                      context,
                      'Debug Logging',
                      config.enableLogging ? 'Enabled' : 'Disabled',
                    ),
                    SizedBox(height: WaymarkSpacing.spaceMd),
                    Text(
                      'Liquid Glass Effect active on App Bar and Bottom Nav Bar with backdrop blur, specular gradients, and ambient shadows.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
