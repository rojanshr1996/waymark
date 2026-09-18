import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/gen/assets.gen.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';

class RecentDiscoveriesCarousel extends StatelessWidget {
  final List<TripPlace> places;
  final VoidCallback? onSeeMap;
  final ValueChanged<TripPlace>? onPlaceTap;
  final Map<String, String>? placeCoverMap;

  const RecentDiscoveriesCarousel({
    super.key,
    required this.places,
    this.onSeeMap,
    this.onPlaceTap,
    this.placeCoverMap,
  });

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) return const SizedBox.shrink();
    final colors = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.pin_drop_rounded,
                    size: 18.sp,
                    color: colors.primary,
                  ),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      context.l10n.journeysRecentDiscoveries,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (onSeeMap != null)
              InkWell(
                onTap: onSeeMap,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 6.w),
                  child: Row(
                    children: [
                      Text(
                        context.l10n.journeysSeeMap,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16.sp,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),

        // Horizontal List
        SizedBox(
          height: 200.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: places.take(4).length + (onSeeMap != null ? 1 : 0),
            separatorBuilder: (context, index) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final displayPlaces = places.take(4).toList();
              if (index < displayPlaces.length) {
                final place = displayPlaces[index];
                return _buildDiscoveryCard(context, place, index);
              }
              return _buildViewAllCard(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoveryCard(BuildContext context, TripPlace place, int index) {
    final colors = context.colorScheme;
    final timeFmt = DateFormat('MMM d • HH:mm').format(place.visitedAt);
    final tempStr = place.temperatureCelsius != null
        ? '${place.temperatureCelsius!.toInt()}°C'
        : null;

    return Material(
      color: colors.surfaceCard,
      borderRadius: BorderRadius.circular(WaymarkSpacing.radiusMd),
      elevation: 1,
      shadowColor: const Color(0x101F2421),
      child: InkWell(
        onTap: () => onPlaceTap?.call(place),
        borderRadius: BorderRadius.circular(WaymarkSpacing.radiusMd),
        child: Container(
          width: 220.w,
          padding: EdgeInsets.all(8.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Thumbnail Area with Weather Badge
              ClipRRect(
                borderRadius: BorderRadius.circular(WaymarkSpacing.radiusSm),
                child: SizedBox(
                  width: double.infinity,
                  height: 105.h,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Reusable archival asset
                      _buildPlaceImage(place, index),
                      // Ambient darkening
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
                            ],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                      // Temperature badge
                      if (tempStr != null)
                        Positioned(
                          bottom: 6.h,
                          left: 6.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(
                                WaymarkSpacing.radiusFull,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  place.weatherCondition == 'Light Rain'
                                      ? Icons.water_drop_rounded
                                      : Icons.wb_sunny_rounded,
                                  size: 10.sp,
                                  color: const Color(0xFFFFDEA9),
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  tempStr,
                                  style: context.textTheme.caption.copyWith(
                                    fontSize: 10.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Favorite bookmark
                      Positioned(
                        top: 6.h,
                        right: 6.w,
                        child: Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            color: colors.surfaceCard.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            index == 0
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 13.sp,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              // Title & Time
              Text(
                place.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '$timeFmt • ${place.weatherCondition ?? context.l10n.weatherClear}',
                style: context.textTheme.caption.copyWith(
                  color: colors.textSecondary,
                  fontSize: 11.sp,
                ),
              ),

              const Spacer(),

              // Divider & Footnote
              Container(
                padding: EdgeInsets.only(top: 6.h),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colors.borderDivider.withValues(alpha: 0.6),
                      width: 0.8,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 12.sp,
                          color: colors.secondary,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          context.l10n.journeysStopOrder(place.visitOrder),
                          style: context.textTheme.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.secondary,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        place.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: context.textTheme.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceImage(TripPlace place, int index) {
    final coverPath = placeCoverMap?[place.id];
    if (coverPath != null && coverPath.isNotEmpty) {
      final file = File(coverPath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }

    final placeAssets = [
      Assets.images.placeOne,
      Assets.images.placeTwo,
      Assets.images.placeThree,
      Assets.images.placeFour,
      Assets.images.placeFive,
      Assets.images.placeSix,
      Assets.images.placeSeven,
      Assets.images.placeEight,
      Assets.images.placeNine,
      Assets.images.placeTen,
      Assets.images.placeEleven,
      Assets.images.placeTwelve,
    ];
    final selectedAsset =
        placeAssets[place.id.hashCode.abs() % placeAssets.length];
    return selectedAsset.image(fit: BoxFit.cover);
  }

  Widget _buildViewAllCard(BuildContext context) {
    final colors = context.colorScheme;

    return Material(
      color: colors.surfaceCard,
      borderRadius: BorderRadius.circular(WaymarkSpacing.radiusMd),
      elevation: 1,
      shadowColor: const Color(0x101F2421),
      child: InkWell(
        onTap: onSeeMap,
        borderRadius: BorderRadius.circular(WaymarkSpacing.radiusMd),
        child: Container(
          width: 140.w,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(WaymarkSpacing.radiusMd),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.2),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.explore_rounded,
                  size: 24.sp,
                  color: colors.primary,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                context.l10n.journeysSeeMap,
                textAlign: TextAlign.center,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${places.length} places',
                style: context.textTheme.caption.copyWith(
                  color: colors.textSecondary,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
