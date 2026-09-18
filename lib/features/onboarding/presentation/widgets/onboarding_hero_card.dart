import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/gen/assets.gen.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';

class OnboardingHeroCard extends StatelessWidget {
  const OnboardingHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.borderDivider, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0x141F2421), // rgba(31,36,33,0.08)
            blurRadius: 20.r,
            offset: Offset(0, 6.h),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4.r,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 10.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Framed Travel Poster Print
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Stack(
              children: [
                // Hero Photo (place_twelve.jpeg)
                SizedBox(
                  width: double.infinity,
                  height: 230.h,
                  child: Assets.images.placeTwelve.image(
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),

                // Fine inner photo frame hairline
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.0,
                      ),
                    ),
                  ),
                ),

                // Tactile atmospheric vignette
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.08),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.25),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // Poster Mat Archival Footplate
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.explore_outlined,
                        size: 11.sp,
                        color: colors.primary,
                      ),
                      SizedBox(width: 5.w),
                      Flexible(
                        child: Text(
                          context.l10n.onboardingHeroArchive,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.caption.copyWith(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  context.l10n.onboardingHeroPlateNo,
                  style: context.textTheme.caption.copyWith(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: colors.textSecondary.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
