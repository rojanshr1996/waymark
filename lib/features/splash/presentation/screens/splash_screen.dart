import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/gen/assets.gen.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/router/route_names.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _floatController;
  late AnimationController _progressController;

  // Staged animations
  late Animation<double> _backgroundBlur;
  late Animation<double> _dimOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _headerTextFade;
  late Animation<Offset> _headerTextSlide;
  late Animation<double> _bottomFeaturesFade;
  late Animation<Offset> _bottomFeaturesSlide;
  late Animation<double> _loadingProgress;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation controller (2.4s)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // 2. Floating idle animation for the logo
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // 3. Linear progress loading controller across 4.9s of the 5.0s splash
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4900),
    );

    // Choreographed tweens:
    // Background starts crystal clear (0.0), smoothly animates to blurred (5.0) as logo & text appear
    _backgroundBlur = Tween<double>(begin: 0.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.20, 0.70, curve: Curves.easeInOutCubic),
      ),
    );

    // Subtle dimming layer deepens smoothly in tandem with blur to ensure high contrast
    _dimOpacity = Tween<double>(begin: 0.06, end: 0.30).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.20, 0.70, curve: Curves.easeInOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.20, 0.70, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.20, 0.55, curve: Curves.easeIn),
      ),
    );

    _headerTextFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.40, 0.85, curve: Curves.easeOut),
      ),
    );

    _headerTextSlide =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.40, 0.85, curve: Curves.easeOutCubic),
          ),
        );

    _bottomFeaturesFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.60, 1.0, curve: Curves.easeOut),
      ),
    );

    _bottomFeaturesSlide =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.60, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _loadingProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _entranceController.forward().then((_) {
      if (mounted) {
        _floatController.repeat(reverse: true);
      }
    });

    _progressController.forward();

    _bootstrap();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    // Splash screen lasts 5 seconds before routing
    await Future.delayed(const Duration(milliseconds: 5000));

    final prefs = await SharedPreferences.getInstance();
    // One-time complete purge of legacy static/seeded database content
    if (prefs.getBool('legacy_static_data_cleared_v3') != true) {
      await AppDatabase.instance.clearEntireDatabase();
      await prefs.setBool('hasCompletedOnboarding', false);
      await prefs.setBool('legacy_static_data_cleared_v3', true);
    }

    final hasCompletedOnboarding =
        prefs.getBool('hasCompletedOnboarding') ?? false;
    final profile = await AppDatabase.instance.userProfileDao.getProfile();
    final hasProfile = profile != null;

    if (!mounted) return;

    if (hasCompletedOnboarding && hasProfile) {
      context.go(AppRoutes.journeys);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Scenic Lake Background Image (starts completely clear, animates to blurred as logo/texts emerge)
          AnimatedBuilder(
            animation: _backgroundBlur,
            builder: (context, child) {
              final blurSigma = _backgroundBlur.value;
              final scale =
                  1.0 + (blurSigma > 0.01 ? (blurSigma / 5.0) * 0.04 : 0.0);

              return ClipRect(
                child: Transform.scale(
                  scale: scale,
                  child: blurSigma > 0.01
                      ? ImageFiltered(
                          imageFilter: ui.ImageFilter.blur(
                            sigmaX: blurSigma,
                            sigmaY: blurSigma,
                          ),
                          child: child!,
                        )
                      : child!,
                ),
              );
            },
            child: Assets.images.splashImage.image(
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // 2. Uniform Dimming Layer (smoothly deepens from light to standard contrast as blur sets in)
          AnimatedBuilder(
            animation: _dimOpacity,
            builder: (context, child) {
              return Container(
                color: Colors.black.withValues(alpha: _dimOpacity.value),
              );
            },
          ),

          // 3. Subtle Top Gradient Overlay (improves text contrast against bright sky)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380.h,
            child: AnimatedBuilder(
              animation: _entranceController,
              builder: (context, child) {
                return Opacity(opacity: _headerTextFade.value, child: child!);
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 4. Deep Bottom Gradient Overlay (enhances readability of 3 feature cards & loader)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 340.h,
            child: AnimatedBuilder(
              animation: _entranceController,
              builder: (context, child) {
                return Opacity(
                  opacity: _bottomFeaturesFade.value,
                  child: child!,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      const Color(0xFF0F1A24).withValues(alpha: 0.92),
                      const Color(0xFF0F1A24).withValues(alpha: 0.65),
                      const Color(0xFF0F1A24).withValues(alpha: 0.20),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 0.75, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 4. Safe Area Content Layout
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 24.h),

                // --- TOP BRANDING HEADER ---
                _buildTopBranding(),

                const Spacer(),

                // --- BOTTOM VALUE PROPS & LINEAR LOADER ---
                _buildBottomSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBranding() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated Logo with Floating Pulse
        AnimatedBuilder(
          animation: Listenable.merge([_entranceController, _floatController]),
          builder: (context, child) {
            final floatOffset = _floatController.isAnimating
                ? 4.0 * (0.5 - _floatController.value)
                : 0.0;

            return Transform.translate(
              offset: Offset(0, floatOffset.h),
              child: Opacity(
                opacity: _logoFade.value,
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.25),
                          blurRadius: 36.r,
                          spreadRadius: 4.r,
                        ),
                      ],
                    ),
                    child: Assets.images.waymarkLogoTransparent.image(
                      width: 108.w,
                      height: 108.w,
                      fit: BoxFit.contain,
                      color:
                          Colors.white, // Crisp white outline as per template
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Animated Brand Script Title & Subtitle
        AnimatedBuilder(
          animation: _entranceController,
          builder: (context, child) {
            return Opacity(
              opacity: _headerTextFade.value,
              child: FractionalTranslation(
                translation: _headerTextSlide.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cursive / Editorial Title "WayMark" matching template
                    Text(
                      context.l10n.appName,
                      style: context.textTheme.brandScript.copyWith(
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            offset: const Offset(0, 3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // "Your Journey.  Your Story."
                    Text(
                      context.l10n.appPhilosophy,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.4,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            offset: const Offset(0, 1.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 6.h),

                    // "Travel • Journal • Relive"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.l10n.verbTravel,
                          style: _categoryTextStyle(context),
                        ),
                        _bulletSeparator(context),
                        Text(
                          context.l10n.verbJournal,
                          style: _categoryTextStyle(context),
                        ),
                        _bulletSeparator(context),
                        Text(
                          context.l10n.verbRelive,
                          style: _categoryTextStyle(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  TextStyle _categoryTextStyle(BuildContext context) {
    return (context.textTheme.labelMedium ?? const TextStyle()).copyWith(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: Colors.white.withValues(alpha: 0.92),
      letterSpacing: 0.5,
      shadows: [
        Shadow(
          color: Colors.black.withValues(alpha: 0.5),
          offset: const Offset(0, 1),
          blurRadius: 4,
        ),
      ],
    );
  }

  Widget _bulletSeparator(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Text(
        '•',
        style: context.textTheme.caption.copyWith(
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return Opacity(
          opacity: _bottomFeaturesFade.value,
          child: FractionalTranslation(
            translation: _bottomFeaturesSlide.value,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: WaymarkSpacing.margin(context),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Linear Loading Bar (indicating app is loading in splash)
                  _buildLinearLoader(context),

                  SizedBox(height: 20.h),

                  // 2. Three Feature Columns from the template
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Column 1: Interactive Route Maps
                      Expanded(
                        child: _buildFeatureColumn(
                          context: context,
                          icon: Icons.map_outlined,
                          iconColor: const Color(0xFF2DD4BF), // Vibrant Teal
                          title: context.l10n.interactiveRouteMapsTitle,
                          subtitle: context.l10n.interactiveRouteMapsDesc,
                        ),
                      ),

                      _verticalDivider(),

                      // Column 2: Artistic Journey Postcards
                      Expanded(
                        child: _buildFeatureColumn(
                          context: context,
                          icon: Icons.photo_library_outlined,
                          iconColor: const Color(0xFFFBBF24), // Warm Gold
                          title: context.l10n.artisticJourneyPostcardsTitle,
                          subtitle: context.l10n.artisticJourneyPostcardsDesc,
                        ),
                      ),

                      _verticalDivider(),

                      // Column 3: Offline First
                      Expanded(
                        child: _buildFeatureColumn(
                          context: context,
                          icon: Icons.cloud_off_rounded,
                          iconColor: const Color(0xFFA78BFA), // Soft Lavender
                          title: context.l10n.offlineFirstTitle,
                          subtitle: context.l10n.offlineFirstDesc,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 22.h),

                  // 3. Bottom Tagline "— More Than Just Photos —"
                  Text(
                    context.l10n.moreThanJustPhotos,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                      letterSpacing: 1.4,
                    ),
                  ),

                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLinearLoader(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        final progress = _loadingProgress.value;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Linear Progress Track
            Container(
              height: 4.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusFull,
                    ),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE26D5C), // Earth Terracotta
                        Color(0xFFFFB703), // Sunset Gold
                        Color(0xFF38B000), // Forest Vivid
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.colorScheme.primary.withValues(
                          alpha: 0.6,
                        ),
                        blurRadius: 8.r,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 6.h),

            // Loading status subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.initializingLocalVault,
                  style: context.textTheme.caption.copyWith(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: context.textTheme.caption.copyWith(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureColumn({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rounded Icon Badge
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor.withValues(alpha: 0.18),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.4),
              width: 1.0,
            ),
          ),
          child: Icon(icon, size: 22.sp, color: iconColor),
        ),

        SizedBox(height: 8.h),

        // Title
        Text(
          title,
          textAlign: TextAlign.center,
          style: context.textTheme.headlineSmall?.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.25,
            letterSpacing: -0.1,
          ),
        ),

        SizedBox(height: 4.h),

        // Subtitle
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall?.copyWith(
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.75),
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1.w,
      height: 70.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      color: Colors.white.withValues(alpha: 0.22),
    );
  }
}
