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

import 'package:waymark/features/journeys/presentation/widgets/create_journey_bottom_sheet.dart';

class ArchivedMemoirsSection extends StatelessWidget {
  final List<TripAlbum> albums;
  final ValueChanged<TripAlbum>? onAlbumTap;
  final ValueChanged<TripAlbum>? onAlbumEdit;
  final String? title;

  const ArchivedMemoirsSection({
    super.key,
    required this.albums,
    this.onAlbumTap,
    this.onAlbumEdit,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) return const SizedBox.shrink();
    final colors = context.colorScheme;

    final completedCount = albums.where((a) => a.status == 'COMPLETED').length;
    final ongoingCount = albums.where((a) => a.status == 'ONGOING').length;
    final countText = (ongoingCount > 0 && completedCount > 0)
        ? '$ongoingCount active • $completedCount archived'
        : ongoingCount > 0
        ? '$ongoingCount active'
        : context.l10n.journeysCompletedCount(albums.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    size: 18.sp,
                    color: colors.secondary,
                  ),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      title ?? context.l10n.journeysArchivedMemoirs,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              countText,
              style: context.textTheme.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        // List of Archived Journeys
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < albums.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i < albums.length - 1 ? 10.h : 0,
                ),
                child: _buildArchivedCard(context, albums[i]),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildArchivedCard(BuildContext context, TripAlbum album) {
    final colors = context.colorScheme;
    final dateFmt = DateFormat('MMM yyyy').format(album.startDate);
    final isOngoing = album.status == 'ONGOING';
    final statusText = isOngoing
        ? 'ONGOING'
        : context.l10n.journeyStatusCompleted.toUpperCase();
    final statusColor = isOngoing ? colors.primary : colors.secondary;

    return Material(
      color: colors.surfaceCard,
      borderRadius: BorderRadius.circular(WaymarkSpacing.radiusMd),
      elevation: 1,
      shadowColor: const Color(0x0D1F2421),
      child: InkWell(
        onTap: () => onAlbumTap?.call(album),
        borderRadius: BorderRadius.circular(WaymarkSpacing.radiusMd),
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Row(
            children: [
              // Square Photo Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(WaymarkSpacing.radiusSm),
                child: SizedBox(
                  width: 68.w,
                  height: 68.w,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildCoverImage(album),
                      Container(color: colors.primary.withValues(alpha: 0.1)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Title and Metrics
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              WaymarkSpacing.radiusSm,
                            ),
                          ),
                          child: Text(
                            statusText,
                            style: context.textTheme.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: statusColor,
                              fontSize: 9.sp,
                            ),
                          ),
                        ),
                        Text(
                          dateFmt,
                          style: context.textTheme.caption.copyWith(
                            color: colors.textSecondary,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      album.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4.w,
                      children: [
                        Icon(
                          Icons.straighten_rounded,
                          size: 13.sp,
                          color: colors.textSecondary,
                        ),
                        Text(
                          '${album.totalDistanceKm.toStringAsFixed(1)} km',
                          style: context.textTheme.caption.copyWith(
                            color: colors.textSecondary,
                            fontSize: 11.sp,
                          ),
                        ),
                        Text(
                          '•',
                          style: context.textTheme.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        Icon(
                          Icons.place_rounded,
                          size: 13.sp,
                          color: colors.textSecondary,
                        ),
                        Text(
                          context.l10n.profileStopsCount(
                            album.totalPlacesCount,
                          ),
                          style: context.textTheme.caption.copyWith(
                            color: colors.textSecondary,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  size: 18.sp,
                  color: colors.textSecondary,
                ),
                tooltip: 'Edit Album',
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 28.w, minHeight: 28.h),
                onPressed: () {
                  if (onAlbumEdit != null) {
                    onAlbumEdit!(album);
                  } else {
                    CreateJourneyBottomSheet.show(context, albumToEdit: album);
                  }
                },
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20.sp,
                color: colors.outlineVariant,
              ),
            ],
          ),
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
