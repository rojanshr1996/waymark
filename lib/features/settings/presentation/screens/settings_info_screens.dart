import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/gen/assets.gen.dart';
import 'package:waymark/core/presentation/widgets/waymark_liquid_glass_app_bar.dart';
import 'package:waymark/core/presentation/widgets/waymark_snackbar.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoPage(
      title: 'Help & Support',
      subtitle: 'Get answers and contact the WayMark team',
      icon: Icons.support_agent_rounded,
      child: StreamBuilder<UserProfile?>(
        stream: AppDatabase.instance.userProfileDao.watchProfile(),
        builder: (context, snapshot) {
          final handle = snapshot.data?.handle;
          return Column(
            children: [
              _InfoCard(
                icon: Icons.email_outlined,
                title: 'Email support',
                body:
                    'Send a message to the WayMark team. Your saved profile handle is included so we know who to reply to.',
                action: FilledButton.icon(
                  onPressed: () => _launchSupportEmail(context, handle),
                  icon: const Icon(Icons.mail_outline_rounded),
                  label: const Text('Email Help & Support'),
                ),
              ),
              SizedBox(height: 16.h),
              _InfoCard(
                icon: Icons.route_rounded,
                title: 'Before contacting us',
                body:
                    'Include the journey name, the place where the issue happened, and a short description of what you expected to see.',
              ),
              SizedBox(height: 16.h),
              _InfoCard(
                icon: Icons.offline_bolt_rounded,
                title: 'Offline-first help',
                body:
                    'Your journey data stays on this device. Support messages only leave the device when you choose to open your email app.',
              ),
            ],
          );
        },
      ),
    );
  }
}

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _items = <({String question, String answer})>[
    (
      question: 'Where is my journey data stored?',
      answer:
          'WayMark stores journeys, places, and profile data locally on this device. Your memoirs remain available when you are offline.',
    ),
    (
      question: 'How do I create a postcard?',
      answer:
          'Open a journey, tap Art Postcard, then choose a template, ratio, route style, and export option in the postcard studio.',
    ),
    (
      question: 'Can I change the order of places?',
      answer:
          'Open a journey and use Reorder in the Timeline tab. The route and postcard update to match the new visit sequence.',
    ),
    (
      question: 'What happens when I wipe the vault?',
      answer:
          'Wiping the vault permanently removes journeys, places, media records, and your local profile. This cannot be undone.',
    ),
    (
      question: 'Why is a route distance still loading?',
      answer:
          'WayMark is resolving the path between your places. A straight-line distance is used as a fallback when a road route is unavailable.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _InfoPage(
      title: 'Frequently Asked Questions',
      subtitle: 'Quick answers about using WayMark',
      icon: Icons.help_outline_rounded,
      child: _InfoCard(
        icon: Icons.question_answer_outlined,
        title: 'Common questions',
        child: Column(
          children: [
            for (var index = 0; index < _items.length; index++) ...[
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.only(
                  left: 4.w,
                  right: 4.w,
                  bottom: 12.h,
                ),
                iconColor: context.colorScheme.primary,
                collapsedIconColor: context.colorScheme.textSecondary,
                title: Text(
                  _items[index].question,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  Text(
                    _items[index].answer,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
              if (index < _items.length - 1)
                Divider(height: 1, color: context.colorScheme.borderDivider),
            ],
          ],
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoPage(
      title: 'About WayMark',
      subtitle: 'Memoir & Living Atlas',
      leading: Assets.images.waymarkLogoTransparent.image(fit: BoxFit.contain),
      child: Column(
        children: [
          _InfoCard(
            icon: Icons.explore_rounded,
            title: 'WayMark',
            body:
                'WayMark is a personal travel memoir and living atlas for capturing the places, routes, photographs, and small details that make a journey memorable. Organize each trip as a visual story, revisit the sequence of places you explored, and transform your memories into beautiful postcards. The experience is designed to feel calm, tactile, and useful while keeping your journey records available on your device, even when you are offline.',
            trailing: Text(
              'v1.0.0',
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colorScheme.secondary,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _InfoCard(
            icon: Icons.auto_awesome_rounded,
            title: 'Made for meaningful journeys',
            child: Column(
              children: [
                _FeatureRow(
                  icon: Icons.cloud_off_rounded,
                  title: 'Offline first',
                  body: 'Your memoir stays on this device.',
                ),
                SizedBox(height: 12.h),
                _FeatureRow(
                  icon: Icons.route_rounded,
                  title: 'Living routes',
                  body: 'Trace places in the order you experienced them.',
                ),
                SizedBox(height: 12.h),
                _FeatureRow(
                  icon: Icons.photo_library_outlined,
                  title: 'Postcard studio',
                  body: 'Turn a journey into a visual keepsake.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoPage(
      title: 'Privacy Policy',
      subtitle: 'How WayMark handles your information',
      icon: Icons.privacy_tip_outlined,
      child: Column(
        children: const [
          _InfoCard(
            icon: Icons.lock_outline_rounded,
            title: 'Your journey data stays local',
            body:
                'Journeys, places, notes, and media references are stored on your device. WayMark does not upload your memoir data to a cloud service.',
          ),
          _InfoCard(
            icon: Icons.person_outline_rounded,
            title: 'Profile information',
            body:
                'Your profile details are used only to personalize the local app experience and to identify you when you voluntarily contact support.',
          ),
          _InfoCard(
            icon: Icons.share_outlined,
            title: 'You choose what leaves the device',
            body:
                'Sharing a postcard or opening an email app is an action you start. WayMark does not send content without your interaction.',
          ),
          _InfoCard(
            icon: Icons.delete_outline_rounded,
            title: 'Deletion',
            body:
                'You can clear journeys or wipe the local vault from Settings. Wiping the vault permanently removes locally stored records.',
          ),
        ],
      ),
    );
  }
}

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoPage(
      title: 'Terms & Conditions',
      subtitle: 'Terms for using WayMark',
      icon: Icons.gavel_outlined,
      child: Column(
        children: const [
          _InfoCard(
            icon: Icons.check_circle_outline_rounded,
            title: 'Use of the app',
            body:
                'WayMark is a personal travel journaling and postcard creation tool. Use it responsibly and keep your device protected.',
          ),
          _InfoCard(
            icon: Icons.backup_outlined,
            title: 'Your responsibility',
            body:
                'You are responsible for your device, your local data, and any backups or exports you choose to create.',
          ),
          _InfoCard(
            icon: Icons.map_outlined,
            title: 'Routes and distances',
            body:
                'Route lines, distances, and map details are provided for journaling and visualization. They may be approximate and should not be treated as navigation instructions.',
          ),
          _InfoCard(
            icon: Icons.update_rounded,
            title: 'Updates',
            body:
                'WayMark may change features or these terms as the app evolves. Continued use after an update means you accept the revised terms.',
          ),
        ],
      ),
    );
  }
}

class _InfoPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? leading;
  final Widget child;

  const _InfoPage({
    required this.title,
    required this.subtitle,
    this.icon = Icons.info_outline_rounded,
    this.leading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      extendBodyBehindAppBar: true,
      appBar: WaymarkLiquidGlassAppBar(title: title, subtitle: subtitle),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: WaymarkSpacing.margin(context),
          right: WaymarkSpacing.margin(context),
          top: MediaQuery.paddingOf(context).top + 76.h,
          bottom: 40.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 62.w,
              height: 62.w,
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: leading ?? Icon(icon, color: colors.primary, size: 28.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            SizedBox(height: 20.h),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? body;
  final Widget? child;
  final Widget? action;
  final Widget? trailing;

  const _InfoCard({
    required this.icon,
    required this.title,
    this.body,
    this.child,
    this.action,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.borderDivider, width: 0.8),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 21.sp, color: colors.secondary),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            if (body != null) ...[
              SizedBox(height: 10.h),
              Text(
                body!,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
            if (child != null) ...[SizedBox(height: 8.h), child!],
            if (action != null) ...[SizedBox(height: 14.h), action!],
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19.sp, color: context.colorScheme.secondary),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                body,
                style: context.textTheme.caption.copyWith(
                  color: context.colorScheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> _launchSupportEmail(BuildContext context, String? handle) async {
  final uri = Uri(
    scheme: 'mailto',
    path: 'support@waymark.app',
    queryParameters: {
      'subject': 'WayMark Help & Support',
      'body':
          'Hello WayMark support,\n\nPlease describe your question or issue here.\n\nMy WayMark handle: ${handle?.trim().isNotEmpty == true ? handle!.trim() : 'Not set'}',
    },
  );
  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted)
      WaymarkSnackbar.showError(
        context,
        'No email app is available on this device.',
      );
  } catch (_) {
    if (context.mounted)
      WaymarkSnackbar.showError(context, 'Could not open your email app.');
  }
}
