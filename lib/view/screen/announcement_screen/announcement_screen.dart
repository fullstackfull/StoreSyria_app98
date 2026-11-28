import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/support_controller/announcement_controller.dart';
import 'package:store_go_app/core/model/announcement_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/error_empty_state.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../new_widgets/shimmer.dart';

/// SUPPORT-002 -- «مساعدة سياقية وإعلانات للويب وFlutter»: THE APP'S HALF.
///
/// A merchant who only uses this app was told NOTHING when the platform
/// announced maintenance: the banner shipped with CTRL-003 lives in the web
/// panel's Blade layout and `api/admin` was deliberately left untouched. This
/// screen is the other client the requirement names.
///
/// -----------------------------------------------------------------------------
/// IT IS A LIST, NOT A BANNER, AND THAT IS THE POINT RATHER THAN A CONVENIENCE.
///
/// A banner shows what is live while the window is open. A merchant who did not
/// open the app on Thursday night has no other way to learn what the platform
/// said about Thursday night, so the ENDED announcements are here too, each
/// marked. Drafts and not-yet-started windows never arrive at all -- the server
/// decides that, in one place, so this screen and the web list cannot disagree.
///
/// -----------------------------------------------------------------------------
/// NOTHING HERE PINS A DIRECTION.
///
/// No `EdgeInsets.only(left:)`, no `TextAlign.left`, no `Alignment.centerLeft`,
/// no `Row` whose order means "label then value". `EdgeInsetsDirectional`,
/// `AlignmentDirectional` and `CrossAxisAlignment.start` resolve against the
/// ambient direction, which `GetMaterialApp` sets from the locale now that
/// `localizationsDelegates` is wired up. `test/rtl/` asserts this family.
///
/// SEVERITY AND STATE EACH CARRY A WORD, never a colour alone. Urgent and quiet
/// differ by a label as well as a hue, and so does "happening now" from "ended" --
/// the same contract the web panel's badges hold (WCAG 1.4.1).
class AnnouncementScreen extends StatefulWidget {
  /// The surface key of the screen the merchant came from, if any.
  ///
  /// Passed straight to the help sheet. It is the SERVER's vocabulary
  /// (`products`, `orders`, `storefront`, ...) and deliberately not a Laravel
  /// route name, so a route rename on the server cannot empty the help in a copy
  /// of this app that is already on a phone.
  final String? helpSurface;

  const AnnouncementScreen({super.key, this.helpSurface});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final AnnouncementController controller = Get.put(AnnouncementController());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround,
      appBar: _appBar(isDark),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return ShimmerList(
              trailing: false,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            );
          }

          // ERROR BEFORE EMPTY. A failed fetch also leaves the list empty, and
          // telling a merchant there are no maintenance notices when the request
          // failed is the worst lie this screen could tell.
          if (controller.errorMessage.value.isNotEmpty &&
              controller.announcements.isEmpty) {
            return ErrorState(
              message: controller.errorMessage.value,
              onRetry: controller.getAnnouncements,
            );
          }

          if (controller.announcements.isEmpty) {
            return EmptyState(
              message: 'no_announcements'.tr,
              icon: Icons.campaign_outlined,
            );
          }

          return RefreshIndicator(
            color: AppColor.themeNavyBlueColor,
            backgroundColor: isDark ? DarkThemeColor.cCardBackground : Colors.white,
            onRefresh: controller.getAnnouncements,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              // `fromSTEB` rather than the `fromLTRB` its sibling list uses:
              // the two are identical here because the horizontal insets are
              // equal, and the directional form means the direction census
              // below needs no exception to allow it.
              padding: EdgeInsetsDirectional.fromSTEB(16.w, 14.h, 16.w, 24.h),
              itemCount: controller.announcements.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) =>
                  _card(controller.announcements[index], isDark),
            ),
          );
        }),
      ),
    );
  }

  PreferredSizeWidget _appBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        'announcements'.tr,
        style: pSemiBold18.copyWith(
          color: isDark ? DarkThemeColor.cText : AppColor.cText,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          // An accessible name, not a bare glyph: `test/a11y/` requires every
          // icon-only control in this app to carry one.
          tooltip: 'help_for_this_screen'.tr,
          onPressed: _openHelp,
          icon: Icon(
            Icons.help_outline,
            color: isDark ? DarkThemeColor.cText : AppColor.blueColor,
          ),
        ),
      ],
    );
  }

  void _openHelp() {
    controller.getHelp(widget.helpSurface ?? '');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HelpSheet(controller: controller),
    );
  }

  Widget _card(Announcement announcement, bool isDark) {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: isDark ? DarkThemeColor.cCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? DarkThemeColor.cBorder : AppColor.cBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              // THE TONES ARE EXISTING PALETTE ENTRIES, not new ones. This app's
              // palette has no semantic `warning`/`success` names, and adding
              // two would be a design-system change with its own contrast
              // verification in two themes -- for a wash behind a label that
              // already carries the meaning in words.
              _chip(
                announcement.isUrgent ? 'urgent'.tr : 'notice'.tr,
                announcement.isUrgent ? AppColor.cRedText : AppColor.blueColor,
                isDark,
              ),
              _chip(
                announcement.isLive ? 'happening_now'.tr : 'ended'.tr,
                announcement.isLive ? AppColor.cGreenFont : AppColor.cFont,
                isDark,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            announcement.title,
            style: pSemiBold16.copyWith(
              color: isDark ? DarkThemeColor.cText : AppColor.cText,
            ),
          ),
          if (announcement.body.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              announcement.body,
              style: pRegular14.copyWith(
                color: isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont,
              ),
            ),
          ],
          if (announcement.startsAt.isNotEmpty || announcement.endsAt.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              _window(announcement),
              style: pRegular12.copyWith(
                color: isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// The window, as words rather than two bare timestamps.
  ///
  /// A null bound means "no bound at that end" on the server, so all three
  /// shapes are real: both ends, an end only, and a start only.
  String _window(Announcement announcement) {
    if (announcement.startsAt.isNotEmpty && announcement.endsAt.isNotEmpty) {
      return 'announcement_window'.trParams({
        'from': announcement.startsAt,
        'until': announcement.endsAt,
      });
    }

    if (announcement.endsAt.isNotEmpty) {
      return 'announcement_window_until'.trParams({'until': announcement.endsAt});
    }

    return 'announcement_window_from'.trParams({'from': announcement.startsAt});
  }

  Widget _chip(String label, Color tone, bool isDark) {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(8.w, 3.h, 8.w, 3.h),
      decoration: BoxDecoration(
        // A 12% wash rather than the tone itself: the label sits on top of this,
        // and the tone at full strength would put coloured text on a coloured
        // ground in both themes.
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: pMedium12.copyWith(
          color: isDark ? DarkThemeColor.cText : AppColor.cText,
        ),
      ),
    );
  }
}

/// The contextual help for the screen the merchant came from.
///
/// ONE SURFACE, like the web panel's help screen, and for the same stated
/// reason: a second place that shows the same articles is a second focus order,
/// a second RTL placement and a second dark-mode contrast to verify.
class _HelpSheet extends StatelessWidget {
  final AnnouncementController controller;

  // `super.key` even though this widget is private and built in one place:
  // `use_key_in_widget_constructors` is in the `flutter_lints` set this project
  // includes, and an analyzer warning in a new file is how a gate gets ignored.
  const _HelpSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkThemeColor.cCardBackground : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 24.h),
      child: Obx(() {
        if (controller.isHelpLoading.value) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final children = <Widget>[
          Text(
            'help_for_this_screen'.tr,
            style: pSemiBold16.copyWith(
              color: isDark ? DarkThemeColor.cText : AppColor.cText,
            ),
          ),
          SizedBox(height: 12.h),
        ];

        if (controller.helpError.value.isNotEmpty) {
          children.add(
            Text(
              controller.helpError.value,
              style: pRegular14.copyWith(
                color: isDark ? DarkThemeColor.cRedText : AppColor.cRedText,
              ),
            ),
          );
        } else if (controller.helpArticles.isEmpty) {
          // TWO DIFFERENT FACTS, TWO DIFFERENT SENTENCES. "no help for this
          // screen yet" is expected on most screens; "the server does not know
          // that key" means this app and the server have drifted, and saying so
          // is how anybody finds out.
          children.add(
            Text(
              controller.helpSurfaceKnown.value
                  ? 'no_help_for_this_screen'.tr
                  : 'help_surface_unknown'.tr,
              style: pRegular14.copyWith(
                color: isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont,
              ),
            ),
          );
        } else {
          for (final article in controller.helpArticles) {
            children.add(_article(article, isDark));
          }
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        );
      }),
    );
  }

  Widget _article(HelpArticle article, bool isDark) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 14.h),
      child: InkWell(
        onTap: article.url.isEmpty
            ? null
            : () async {
                final uri = Uri.tryParse(article.url);

                if (uri != null) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: pMedium14.copyWith(color: AppColor.blueColor),
            ),
            if (article.summary.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                article.summary,
                style: pRegular12.copyWith(
                  color: isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont,
                ),
              ),
            ],
            if (article.isFallback) ...[
              SizedBox(height: 4.h),
              Text(
                'help_not_in_your_language'.tr,
                style: pRegular12.copyWith(
                  color: isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
