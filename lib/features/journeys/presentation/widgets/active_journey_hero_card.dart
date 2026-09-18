import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/gen/assets.gen.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/presentation/widgets/waymark_buttons.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/journeys/presentation/widgets/create_journey_bottom_sheet.dart';
import 'package:waymark/features/journeys/presentation/widgets/place_logger_bottom_sheet.dart';

class ActiveJourneyHeroCard extends StatelessWidget {
  final TripAlbum album;
  final VoidCallback? onContinue;
  final VoidCallback? onAddWaypoint;
  final bool showHeader;
  final String? headerTitle;
  final bool isFlexible;

  const ActiveJourneyHeroCard({
    super.key,
    required this.album,
    this.onContinue,
    this.onAddWaypoint,
    this.showHeader = true,
    this.headerTitle,
    this.isFlexible = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final startFmt = DateFormat('MMM d').format(album.startDate);
    final endFmt = album.endDate != null
        ? DateFormat('MMM d').format(album.endDate!)
        : '';
    final daysCount = album.endDate != null
        ? album.endDate!.difference(album.startDate).inDays + 1
        : 1;

    final mainCard = Material(
      color: colors.surfaceCard,
      borderRadius: BorderRadius.circular(WaymarkSpacing.radiusLg),
      elevation: 2,
      shadowColor: const Color(0x0F1F2421),
      child: InkWell(
        onTap: onContinue,
        borderRadius: BorderRadius.circular(WaymarkSpacing.radiusLg),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Banner Photo with Overlaid Pills & Titles
              isFlexible
                  ? Expanded(
                      child: _buildBanner(
                        context,
                        album,
                        colors,
                        startFmt,
                        endFmt,
                        daysCount,
                      ),
                    )
                  : _buildBanner(
                      context,
                      album,
                      colors,
                      startFmt,
                      endFmt,
                      daysCount,
                    ),

              SizedBox(height: 8.h),

              // Distance and Stats Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(WaymarkSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.journeysDistanceLabel,
                            style: context.textTheme.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          RichText(
                            text: TextSpan(
                              text: album.totalDistanceKm.toStringAsFixed(1),
                              style: context.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                              children: [
                                TextSpan(
                                  text: ' km',
                                  style: context.textTheme.caption.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1.w,
                      height: 28.h,
                      color: colors.borderDivider,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.journeysWaypointsLabel,
                            style: context.textTheme.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            context.l10n.journeysWaypointsLogged(
                              album.totalPlacesCount,
                            ),
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10.h),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: WaymarkPrimaryButton(
                      label: 'View Journey Details',
                      icon: Icons.explore_rounded,
                      onPressed: onContinue,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Material(
                    color: colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusMd,
                    ),
                    child: InkWell(
                      onTap: () => PlaceLoggerBottomSheet.show(
                        context,
                        albumId: album.id,
                        albumTitle: album.title,
                      ),
                      borderRadius: BorderRadius.circular(
                        WaymarkSpacing.radiusMd,
                      ),
                      child: Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            WaymarkSpacing.radiusMd,
                          ),
                        ),
                        child: Icon(
                          Icons.add_location_alt_rounded,
                          color: colors.primary,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        if (showHeader) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  (headerTitle ?? context.l10n.journeysActiveExpedition)
                      .toUpperCase(),
                  style: context.textTheme.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: BoxDecoration(
                      color: colors.forestVivid,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    context.l10n.journeysGpsTrackingActive,
                    style: context.textTheme.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
        ],

        // Main Card
        isFlexible ? Expanded(child: mainCard) : mainCard,
      ],
    );
  }

  Widget _buildBanner(
    BuildContext context,
    TripAlbum album,
    ColorScheme colors,
    String startFmt,
    String endFmt,
    int daysCount,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(WaymarkSpacing.radiusMd),
      child: SizedBox(
        width: double.infinity,
        height: isFlexible ? null : 150.h,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            _buildCoverImage(album),

            // Gradient Vignette
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),

            // Live Status Pill (Top Left)
            Positioned(
              top: 10.h,
              left: 10.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFADF2C3),
                  borderRadius: BorderRadius.circular(
                    WaymarkSpacing.radiusFull,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4.r,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.hiking_rounded,
                      size: 14.sp,
                      color: const Color(0xFF002110),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      context.l10n.journeysOngoingExpedition,
                      style: context.textTheme.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF002110),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Edit Album Button (Top Right)
            Positioned(
              top: 10.h,
              right: 10.w,
              child: Material(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
                child: InkWell(
                  onTap: () => CreateJourneyBottomSheet.show(
                    context,
                    albumToEdit: album,
                  ),
                  borderRadius: BorderRadius.circular(
                    WaymarkSpacing.radiusFull,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 13.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Edit',
                          style: context.textTheme.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Overlaid Title and Dates (Bottom)
            Positioned(
              bottom: 10.h,
              left: 12.w,
              right: 12.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 11.sp,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        endFmt.isNotEmpty
                            ? '$startFmt – $endFmt • $daysCount Days'
                            : startFmt,
                        style: context.textTheme.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage(TripAlbum album) {
    if (album.coverImagePath != null && album.coverImagePath!.isNotEmpty) {
      final file = File(album.coverImagePath!);
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
        placeAssets[album.id.hashCode.abs() % placeAssets.length];
    return selectedAsset.image(fit: BoxFit.cover);
  }
}
