import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/presentation/widgets/waymark_snackbar.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';

class ExportFieldJournalBanner extends StatelessWidget {
  final VoidCallback? onPreview;

  const ExportFieldJournalBanner({super.key, this.onPreview});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(WaymarkSpacing.radiusMd),
        border: Border.all(
          color: colors.borderDivider,
          width: 1.2,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: const BoxDecoration(
              color: Color(0xFFFFDEA9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              size: 20.sp,
              color: const Color(0xFF5E4100),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.journeysExportFieldJournalTitle,
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  context.l10n.journeysExportFieldJournalDesc,
                  style: context.textTheme.caption.copyWith(
                    color: colors.textSecondary,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          OutlinedButton(
            onPressed:
                onPreview ??
                () {
                  WaymarkSnackbar.showInfo(
                    context,
                    context.l10n.journeysExportFieldJournalPreparing,
                  );
                },
            style: OutlinedButton.styleFrom(
              backgroundColor: colors.surfaceCard,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              side: BorderSide(color: colors.borderDivider, width: 0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(WaymarkSpacing.radiusSm),
              ),
            ),
            child: Text(
              context.l10n.journeysBtnPreview,
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
