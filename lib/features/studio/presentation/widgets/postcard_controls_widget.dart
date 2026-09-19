import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/theme/waymark_colors.dart';

import '../../domain/models/postcard_enums.dart';

class PostcardControlsWidget extends StatelessWidget {
  final List<TripAlbum> albums;
  final ValueNotifier<TripAlbum?> selectedAlbumNotifier;
  final ValueNotifier<PostcardAestheticStyle> selectedStyleNotifier;
  final ValueNotifier<PostcardRatio> selectedRatioNotifier;
  final ValueNotifier<bool> showMapRouteNotifier;
  final ValueNotifier<bool> showWeatherNotifier;
  final ValueNotifier<bool> isQuadPhotoLayoutNotifier;

  const PostcardControlsWidget({
    super.key,
    required this.albums,
    required this.selectedAlbumNotifier,
    required this.selectedStyleNotifier,
    required this.selectedRatioNotifier,
    required this.showMapRouteNotifier,
    required this.showWeatherNotifier,
    required this.isQuadPhotoLayoutNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Journey Source Album Selector (if multiple albums exist)
        if (albums.length > 1) ...[
          _buildAlbumSelector(context),
          SizedBox(height: 16.h),
        ],

        // 2. Postcard Aesthetic Style Selector
        _buildStyleSelector(context),
        SizedBox(height: 16.h),

        // 3. Export Canvas Ratio Selector
        _buildRatioSelector(context),
        SizedBox(height: 16.h),

        // 4. Canvas Elements & Layers Toggles
        _buildLayersCard(context),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildAlbumSelector(BuildContext context) {
    final colors = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 16.sp,
              color: colors.primary,
            ),
            SizedBox(width: 6.w),
            Text(
              'Select Journey Memoir',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 36.h,
          child: ValueListenableBuilder<TripAlbum?>(
            valueListenable: selectedAlbumNotifier,
            builder: (context, selectedAlbum, _) {
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: albums.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final album = albums[index];
                  final isSelected = selectedAlbum?.id == album.id;

                  return InkWell(
                    borderRadius: BorderRadius.circular(20.r),
                    onTap: () => selectedAlbumNotifier.value = album,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary
                            : colors.surfaceContainer,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.borderDivider,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          album.title,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12.sp,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected ? Colors.white : colors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStyleSelector(BuildContext context) {
    final colors = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.style_rounded, size: 16.sp, color: colors.primary),
            SizedBox(width: 6.w),
            Text(
              'Postcard Template Style',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ValueListenableBuilder<PostcardAestheticStyle>(
          valueListenable: selectedStyleNotifier,
          builder: (context, currentStyle, _) {
            return InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: () => _showTemplateSheet(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: currentStyle
                        .getAccentColor(colors)
                        .withValues(alpha: 0.55),
                  ),
                ),
                child: Row(
                  children: [
                    _TemplateSwatch(style: currentStyle),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentStyle.label,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Choose from ${PostcardAestheticStyle.values.length} postcard templates',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10.sp,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.expand_more_rounded,
                      color: colors.textSecondary,
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

  Future<void> _showTemplateSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.78,
            ),
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: context.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Postcard Templates',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Close templates',
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select a visual direction for your travel postcard.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.sp,
                      color: context.colorScheme.textSecondary,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: PostcardAestheticStyle.values.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                      childAspectRatio: 1.35,
                    ),
                    itemBuilder: (context, index) {
                      final style = PostcardAestheticStyle.values[index];
                      return ValueListenableBuilder<PostcardAestheticStyle>(
                        valueListenable: selectedStyleNotifier,
                        builder: (context, selectedStyle, _) {
                          final isSelected = style == selectedStyle;
                          return InkWell(
                            borderRadius: BorderRadius.circular(14.r),
                            onTap: () {
                              selectedStyleNotifier.value = style;
                              Navigator.of(sheetContext).pop();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: style.getCanvasBackgroundColor(
                                  context.colorScheme,
                                ),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: isSelected
                                      ? style.getAccentColor(
                                          context.colorScheme,
                                        )
                                      : context.colorScheme.outlineVariant,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _TemplatePreview(style: style),
                                  ),
                                  SizedBox(height: 7.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          style.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w700,
                                            color: style.getTextColor(
                                              context.colorScheme,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle_rounded,
                                          size: 15.sp,
                                          color: style.getAccentColor(
                                            context.colorScheme,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatioSelector(BuildContext context) {
    final colors = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.aspect_ratio_rounded,
              size: 16.sp,
              color: colors.primary,
            ),
            SizedBox(width: 6.w),
            Text(
              'Export Canvas Ratio',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ValueListenableBuilder<PostcardRatio>(
          valueListenable: selectedRatioNotifier,
          builder: (context, currentRatio, _) {
            return Row(
              children: PostcardRatio.values.map((ratio) {
                final isSelected = currentRatio == ratio;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.r),
                      onTap: () => selectedRatioNotifier.value = ratio,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          vertical: 8.h,
                          horizontal: 8.w,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary
                              : colors.surfaceContainer,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: colors.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 6.r,
                                    offset: Offset(0, 2.h),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              ratio.icon,
                              size: 14.sp,
                              color: isSelected
                                  ? Colors.white
                                  : colors.onSurface,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              ratio.label,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.sp,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLayersCard(BuildContext context) {
    final colors = context.colorScheme;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CANVAS ELEMENTS & LAYERS',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),

          // Route Polyline Toggle
          ValueListenableBuilder<bool>(
            valueListenable: showMapRouteNotifier,
            builder: (context, showRoute, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.polyline_rounded,
                        size: 18.sp,
                        color: colors.secondary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Show Journey Route Polyline',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.sp,
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: showRoute,
                    activeThumbColor: colors.primary,
                    onChanged: (val) => showMapRouteNotifier.value = val,
                  ),
                ],
              );
            },
          ),
          Divider(height: 12.h, color: colors.borderDivider),

          // Weather & Ambient Data Toggle
          ValueListenableBuilder<bool>(
            valueListenable: showWeatherNotifier,
            builder: (context, showWeather, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.wb_sunny_rounded,
                        size: 18.sp,
                        color: const Color(0xFFFFB703),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Show Weather & Atmosphere',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.sp,
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: showWeather,
                    activeThumbColor: colors.primary,
                    onChanged: (val) => showWeatherNotifier.value = val,
                  ),
                ],
              );
            },
          ),
          Divider(height: 12.h, color: colors.borderDivider),

          // Photo Layout Toggle (Duo vs Quad)
          ValueListenableBuilder<bool>(
            valueListenable: isQuadPhotoLayoutNotifier,
            builder: (context, isQuad, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.photo_library_rounded,
                        size: 18.sp,
                        color: colors.primary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Photo Layout',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.sp,
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8.r),
                    onTap: () => isQuadPhotoLayoutNotifier.value = !isQuad,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: colors.borderDivider),
                      ),
                      child: Text(
                        isQuad ? '4 Polaroids (Quad)' : '2 Polaroids (Duo)',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TemplateSwatch extends StatelessWidget {
  final PostcardAestheticStyle style;

  const _TemplateSwatch({required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
        color: style.getCanvasBackgroundColor(context.colorScheme),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: style
              .getAccentColor(context.colorScheme)
              .withValues(alpha: 0.45),
        ),
      ),
      child: Center(
        child: Icon(
          Icons.style_rounded,
          size: 20.sp,
          color: style.getAccentColor(context.colorScheme),
        ),
      ),
    );
  }
}

class _TemplatePreview extends StatelessWidget {
  final PostcardAestheticStyle style;

  const _TemplatePreview({required this.style});

  @override
  Widget build(BuildContext context) {
    final accent = style.getAccentColor(context.colorScheme);
    final textColor = style.getTextColor(context.colorScheme);

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: style.getCardBackgroundColor(context.colorScheme),
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: style.getBorderColor(context.colorScheme)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(height: 4.h, color: accent),
              ),
              SizedBox(width: 5.w),
              Container(
                width: 10.w,
                height: 6.h,
                color: accent.withValues(alpha: 0.35),
              ),
            ],
          ),
          SizedBox(height: 7.h),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            height: 3.h,
            width: 42.w,
            color: textColor.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }
}
