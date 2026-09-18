import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/presentation/widgets/waymark_buttons.dart';
import 'package:waymark/core/presentation/widgets/waymark_snackbar.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';

class CreateJourneyBottomSheet extends StatefulWidget {
  final TripAlbum? albumToEdit;

  const CreateJourneyBottomSheet({super.key, this.albumToEdit});

  static Future<void> show(BuildContext context, {TripAlbum? albumToEdit}) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => CreateJourneyBottomSheet(albumToEdit: albumToEdit),
    );
  }

  @override
  State<CreateJourneyBottomSheet> createState() =>
      _CreateJourneyBottomSheetState();
}

class _CreateJourneyBottomSheetState extends State<CreateJourneyBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  late final ValueNotifier<DateTime> _startDateNotifier;
  late final ValueNotifier<DateTime?> _endDateNotifier;
  late final ValueNotifier<String> _statusNotifier;
  late final ValueNotifier<String?> _coverImagePathNotifier;
  final ValueNotifier<bool> _isCreatingNotifier = ValueNotifier<bool>(false);

  bool get _isEditing => widget.albumToEdit != null;

  static const List<String> _titleInspirations = [
    'Kyoto Autumn',
    'Weekend Roadtrip',
    'Alpine Trail',
    'Coastal Escape',
    'City Wanderlust',
    'Highland Hike',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final a = widget.albumToEdit!;
      _titleController = TextEditingController(text: a.title);
      _descController = TextEditingController(text: a.description ?? '');
      _startDateNotifier = ValueNotifier<DateTime>(a.startDate);
      _endDateNotifier = ValueNotifier<DateTime?>(a.endDate);
      _statusNotifier = ValueNotifier<String>(a.status);
      _coverImagePathNotifier = ValueNotifier<String?>(a.coverImagePath);
    } else {
      _titleController = TextEditingController();
      _descController = TextEditingController();
      _startDateNotifier = ValueNotifier<DateTime>(DateTime.now());
      _endDateNotifier = ValueNotifier<DateTime?>(null);
      _statusNotifier = ValueNotifier<String>('ONGOING');
      _coverImagePathNotifier = ValueNotifier<String?>(null);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _startDateNotifier.dispose();
    _endDateNotifier.dispose();
    _statusNotifier.dispose();
    _coverImagePathNotifier.dispose();
    _isCreatingNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (file != null && mounted) {
        _coverImagePathNotifier.value = file.path;
      }
    } catch (e) {
      if (mounted) {
        WaymarkSnackbar.showError(context, 'Failed to pick cover photo: $e');
      }
    }
  }

  Future<void> _pickDate({required bool isStartDate}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? _startDateNotifier.value
          : (_endDateNotifier.value ?? _startDateNotifier.value),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      if (isStartDate) {
        _startDateNotifier.value = picked;
        if (_endDateNotifier.value != null &&
            _endDateNotifier.value!.isBefore(picked)) {
          _endDateNotifier.value = picked;
        }
      } else {
        _endDateNotifier.value = picked;
        _statusNotifier.value = 'COMPLETED';
      }
    }
  }

  Future<void> _saveJourney() async {
    if (!_formKey.currentState!.validate()) return;

    _isCreatingNotifier.value = true;

    try {
      final db = AppDatabase.instance;
      final trimmedTitle = _titleController.text.trim();
      final trimmedDesc = _descController.text.trim();

      if (_isEditing) {
        final existing = widget.albumToEdit!;
        await db.tripAlbumDao.updateAlbum(
          existing.copyWith(
            title: trimmedTitle,
            description: drift.Value(
              trimmedDesc.isNotEmpty ? trimmedDesc : null,
            ),
            startDate: _startDateNotifier.value,
            endDate: drift.Value(_endDateNotifier.value),
            status: _statusNotifier.value,
            coverImagePath: drift.Value(_coverImagePathNotifier.value),
          ),
        );

        if (mounted) {
          Navigator.of(context).pop();
          WaymarkSnackbar.showSuccess(
            context,
            'Journey album "$trimmedTitle" updated successfully',
          );
        }
      } else {
        final id = 'journey-${DateTime.now().millisecondsSinceEpoch}';
        await db.tripAlbumDao.insertAlbum(
          TripAlbumsCompanion.insert(
            id: id,
            title: trimmedTitle,
            description: drift.Value(
              trimmedDesc.isNotEmpty ? trimmedDesc : null,
            ),
            startDate: _startDateNotifier.value,
            endDate: drift.Value(_endDateNotifier.value),
            status: drift.Value(_statusNotifier.value),
            coverImagePath: drift.Value(_coverImagePathNotifier.value),
          ),
        );

        if (mounted) {
          Navigator.of(context).pop();
          WaymarkSnackbar.showSuccess(
            context,
            context.l10n.createJourneySuccessToast(trimmedTitle),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        WaymarkSnackbar.showError(
          context,
          context.l10n.createJourneyFailedToast(e.toString()),
        );
      }
    } finally {
      if (mounted) {
        _isCreatingNotifier.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final dateFmt = DateFormat('MMM d, yyyy');

    return Padding(
      padding: EdgeInsets.only(
        left: WaymarkSpacing.margin(context),
        right: WaymarkSpacing.margin(context),
        top: 12.h,
        bottom: bottomInset + (safeBottom > 0 ? safeBottom : 20.h),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grabber Handle
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.5.h,
                  decoration: BoxDecoration(
                    color: colors.borderDivider,
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusFull,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Header Row with Badge & Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC89D3C).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: const Color(0xFFC89D3C).withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      _isEditing ? 'EDIT EXPEDITION' : 'NEW EXPEDITION',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFFC89D3C),
                        fontWeight: FontWeight.bold,
                        fontSize: 9.sp,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    iconSize: 20.sp,
                    color: colors.textSecondary,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tight(Size(32.w, 32.w)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              SizedBox(height: 6.h),

              // Title and Subtitle
              Text(
                _isEditing
                    ? 'Edit Journey Album'
                    : context.l10n.createJourneyTitle,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                _isEditing
                    ? 'Update expedition title, notes, cover and status'
                    : context.l10n.createJourneySubtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),

              SizedBox(height: 16.h),

              // Journey Status Segmented Toggle: Ongoing vs Completed
              Text(
                'Expedition Status',
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              ValueListenableBuilder<String>(
                valueListenable: _statusNotifier,
                builder: (context, status, _) {
                  return Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: colors.borderDivider.withValues(alpha: 0.8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatusTab(
                            context: context,
                            label: 'Live Ongoing',
                            icon: Icons.explore_rounded,
                            activeColor: const Color(0xFF2E7D32),
                            isSelected: status == 'ONGOING',
                            onTap: () {
                              _statusNotifier.value = 'ONGOING';
                              _endDateNotifier.value = null;
                            },
                          ),
                        ),
                        Expanded(
                          child: _buildStatusTab(
                            context: context,
                            label: 'Completed',
                            icon: Icons.flag_circle_rounded,
                            activeColor: const Color(0xFFC89D3C),
                            isSelected: status == 'COMPLETED',
                            onTap: () {
                              _statusNotifier.value = 'COMPLETED';
                              _endDateNotifier.value ??=
                                  _startDateNotifier.value;
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: 14.h),

              // Journey Title Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.createJourneyNameLabel,
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _titleController,
                    builder: (context, val, _) {
                      if (val.text.isEmpty) return const SizedBox.shrink();
                      return GestureDetector(
                        onTap: () => _titleController.clear(),
                        child: Text(
                          'Clear',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: colors.textSecondary,
                            fontSize: 10.sp,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _titleController,
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? context.l10n.createJourneyTitleRequired
                    : null,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textPrimary,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.bookmark_outline_rounded,
                    color: colors.primary,
                    size: 20.sp,
                  ),
                  hintText: context.l10n.createJourneyNameHint,
                  hintStyle: context.textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary.withValues(alpha: 0.7),
                  ),
                  filled: true,
                  fillColor: colors.surfaceContainerLow,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusMd,
                    ),
                    borderSide: BorderSide(color: colors.borderDivider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusMd,
                    ),
                    borderSide: BorderSide(
                      color: colors.borderDivider.withValues(alpha: 0.8),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusMd,
                    ),
                    borderSide: BorderSide(color: colors.primary, width: 1.5),
                  ),
                ),
              ),

              // Quick Title Inspiration Chips
              SizedBox(height: 6.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 6.w),
                      child: Text(
                        'Quick ideas:',
                        style: context.textTheme.caption.copyWith(
                          fontSize: 10.sp,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    ..._titleInspirations.map((idea) {
                      return Padding(
                        padding: EdgeInsets.only(right: 6.w),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.r),
                          onTap: () {
                            _titleController.text = idea;
                            _titleController.selection =
                                TextSelection.fromPosition(
                                  TextPosition(offset: idea.length),
                                );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: colors.borderDivider.withValues(
                                  alpha: 0.6,
                                ),
                                width: 0.7,
                              ),
                            ),
                            child: Text(
                              idea,
                              style: context.textTheme.labelSmall?.copyWith(
                                fontSize: 10.sp,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // Cover Photo Option
              ValueListenableBuilder<String?>(
                valueListenable: _coverImagePathNotifier,
                builder: (context, coverImagePath, _) {
                  final hasValidCover =
                      coverImagePath != null &&
                      coverImagePath.isNotEmpty &&
                      File(coverImagePath).existsSync();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Album Cover Photo',
                        style: context.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      InkWell(
                        borderRadius: BorderRadius.circular(14.r),
                        onTap: _pickCoverImage,
                        child: Container(
                          height: 84.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: hasValidCover
                                  ? const Color(0xFFC89D3C)
                                  : colors.borderDivider.withValues(alpha: 0.8),
                              width: hasValidCover ? 1.5 : 1.0,
                            ),
                          ),
                          child: hasValidCover
                              ? Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          13.r,
                                        ),
                                        child: Image.file(
                                          File(coverImagePath),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 6.h,
                                      right: 6.w,
                                      child: GestureDetector(
                                        onTap: () =>
                                            _coverImagePathNotifier.value =
                                                null,
                                        child: Container(
                                          padding: EdgeInsets.all(4.w),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close_rounded,
                                            size: 14.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 6.h,
                                      left: 8.w,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 3.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.64,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.photo_camera_rounded,
                                              size: 12.sp,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              'Change Cover',
                                              style: context
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    color: Colors.white,
                                                    fontSize: 9.5.sp,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 24.sp,
                                        color: colors.primary,
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'Tap to choose a cover photo (optional)',
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                              color: colors.textSecondary,
                                              fontSize: 11.sp,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 14.h),

              // Date pickers row
              ListenableBuilder(
                listenable: Listenable.merge([
                  _startDateNotifier,
                  _endDateNotifier,
                ]),
                builder: (context, _) {
                  final startDate = _startDateNotifier.value;
                  final endDate = _endDateNotifier.value;

                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Start Date Card
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.createJourneyStartDate,
                                  style: context.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                InkWell(
                                  borderRadius: BorderRadius.circular(
                                    WaymarkSpacing.radiusMd,
                                  ),
                                  onTap: () => _pickDate(isStartDate: true),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10.h,
                                      horizontal: 10.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(
                                        WaymarkSpacing.radiusMd,
                                      ),
                                      border: Border.all(
                                        color: colors.borderDivider,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          size: 15.sp,
                                          color: colors.primary,
                                        ),
                                        SizedBox(width: 6.w),
                                        Expanded(
                                          child: Text(
                                            dateFmt.format(startDate),
                                            style: context.textTheme.caption
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: colors.textPrimary,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Middle arrow indicator
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 24.h,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 16.sp,
                              color: colors.textSecondary,
                            ),
                          ),

                          // End Date Card
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.createJourneyEndDate,
                                  style: context.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                InkWell(
                                  borderRadius: BorderRadius.circular(
                                    WaymarkSpacing.radiusMd,
                                  ),
                                  onTap: () => _pickDate(isStartDate: false),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10.h,
                                      horizontal: 10.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(
                                        WaymarkSpacing.radiusMd,
                                      ),
                                      border: Border.all(
                                        color: endDate != null
                                            ? colors.borderDivider
                                            : colors.borderDivider.withValues(
                                                alpha: 0.6,
                                              ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.event_available_rounded,
                                          size: 15.sp,
                                          color: endDate != null
                                              ? const Color(0xFFC89D3C)
                                              : colors.textSecondary,
                                        ),
                                        SizedBox(width: 6.w),
                                        Expanded(
                                          child: Text(
                                            endDate != null
                                                ? dateFmt.format(endDate)
                                                : 'Ongoing',
                                            style: context.textTheme.caption
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: endDate != null
                                                      ? colors.textPrimary
                                                      : const Color(0xFF2E7D32),
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (endDate != null)
                                          GestureDetector(
                                            onTap: () {
                                              _endDateNotifier.value = null;
                                              _statusNotifier.value = 'ONGOING';
                                            },
                                            child: Icon(
                                              Icons.close_rounded,
                                              size: 14.sp,
                                              color: colors.textSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Duration Preview
                      if (endDate != null) ...[
                        SizedBox(height: 4.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${endDate.difference(startDate).inDays + 1} days expedition duration',
                            style: context.textTheme.caption.copyWith(
                              fontSize: 9.5.sp,
                              color: colors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),

              SizedBox(height: 14.h),

              // Description input
              Text(
                context.l10n.createJourneyDescLabel,
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textPrimary,
                ),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 20.h),
                    child: Icon(
                      Icons.auto_stories_outlined,
                      color: colors.primary,
                      size: 20.sp,
                    ),
                  ),
                  hintText: context.l10n.createJourneyDescHint,
                  hintStyle: context.textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary.withValues(alpha: 0.7),
                  ),
                  filled: true,
                  fillColor: colors.surfaceContainerLow,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusMd,
                    ),
                    borderSide: BorderSide(color: colors.borderDivider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusMd,
                    ),
                    borderSide: BorderSide(
                      color: colors.borderDivider.withValues(alpha: 0.8),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusMd,
                    ),
                    borderSide: BorderSide(color: colors.primary, width: 1.5),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Submit CTA
              ValueListenableBuilder<bool>(
                valueListenable: _isCreatingNotifier,
                builder: (context, isCreating, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: WaymarkPrimaryButton(
                      label: _isEditing
                          ? 'Save Changes'
                          : context.l10n.createJourneyBtnCreate,
                      icon: _isEditing
                          ? Icons.check_rounded
                          : Icons.explore_rounded,
                      isLoading: isCreating,
                      onPressed: isCreating ? null : _saveJourney,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTab({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color activeColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = context.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? colors.surfaceCard : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15.sp,
                color: isSelected ? activeColor : colors.textSecondary,
              ),
              SizedBox(width: 5.w),
              Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? colors.textPrimary : colors.textSecondary,
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
