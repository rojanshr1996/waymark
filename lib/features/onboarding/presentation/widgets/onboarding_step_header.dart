import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/gen/assets.gen.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/presentation/widgets/waymark_liquid_glass_app_bar.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';

class OnboardingStepHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final int step; // 1 or 2
  final int totalSteps;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  const OnboardingStepHeader({
    super.key,
    required this.step,
    this.totalSteps = 2,
    this.onBack,
    this.onSkip,
  });

  @override
  Size get preferredSize => Size.fromHeight(52.h + 34.h);

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return WaymarkLiquidGlassAppBar(
      toolbarHeight: 52.0,
      showBottomBorder: true,
      blurSigma: 20.0,
      backgroundAlpha: 0.88,
      leading: step > 1 && onBack != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusFull,
                    ),
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: colors.surfaceCard.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.borderDivider,
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 18.sp,
                        color: colors.textMain,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Center(
                    child: Assets.images.waymarkLogoTransparent.image(
                      width: 20.w,
                      height: 20.w,
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
      titleWidget: step > 1 && onBack != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Assets.images.waymarkLogoTransparent.image(
                      width: 18.w,
                      height: 18.w,
                      color: colors.primary,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    context.l10n.appName,
                    style: context.textTheme.brandTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          : Text(
              context.l10n.appName,
              style: context.textTheme.brandTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      actions: [
        if (onSkip != null)
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              context.l10n.onboardingSkip,
              style: context.textTheme.labelMedium?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: colors.surfaceCard.withValues(alpha: 0.7),
              shape: BoxShape.circle,
              border: Border.all(color: colors.borderDivider, width: 0.8),
            ),
            child: Icon(
              Icons.verified_user_rounded,
              size: 16.sp,
              color: colors.secondary,
            ),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(34.h),
        child: Padding(
          padding: EdgeInsets.only(
            left: WaymarkSpacing.margin(context),
            right: WaymarkSpacing.margin(context),
            bottom: 8.h,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Step Badge
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceCard.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusFull,
                    ),
                    border: Border.all(color: colors.borderDivider, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: step == 1 ? colors.primary : colors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          step == 1
                              ? context.l10n.onboardingStep1Badge
                              : context.l10n.onboardingStep2Badge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            color: colors.textMain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              // 2-segment progress bar
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: step == 1 ? 20.w : 10.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: step >= 1 ? colors.primary : colors.borderDivider,
                      borderRadius: BorderRadius.circular(
                        WaymarkSpacing.radiusFull,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: step == 2 ? 20.w : 10.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: step >= 2
                          ? colors.secondary
                          : colors.borderDivider.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(
                        WaymarkSpacing.radiusFull,
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
  }
}
