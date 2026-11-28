import 'package:get/get.dart';
import 'package:store_go_app/config/repository/support_repository.dart';
import 'package:store_go_app/core/model/announcement_model.dart';
import 'package:store_go_app/network/result.dart';
import 'package:store_go_app/utils/app_log.dart';

/// SUPPORT-002 -- the announcements screen's state, and the help sheet's.
///
/// -----------------------------------------------------------------------------
/// A REFUSAL ARRIVES AT `onSuccess`, SO IT IS CHECKED THERE.
///
/// `result.dart` records the measurement: `ApiResponser::error()` on the Laravel
/// side answers HTTP **200** with `{"status": 0}` by default -- 401 has to be
/// passed explicitly and mostly is not, because this app force-logs-out on any
/// 401. So the transport succeeds and the operation does not, and 14 `onSuccess`
/// closures in this app showed a green success toast anyway. `apiRefused(data)`
/// is the first thing both closures below ask.
///
/// The server refuses these two endpoints for a non-merchant principal -- a
/// shopper's or a driver's token passes its `custom.auth` middleware while the
/// panel guard stays null -- so a refusal here is a real state, not a
/// hypothetical.
///
/// -----------------------------------------------------------------------------
/// ERROR BEFORE EMPTY, which is this app's own rule and the reason
/// `errorMessage` exists separately from an empty list. A failed fetch also
/// leaves the list empty, so a merchant whose network dropped would otherwise be
/// told there are no announcements -- which, for a screen whose entire job is to
/// carry maintenance notices, is the worst possible lie.
class AnnouncementController extends GetxController {
  final SupportRepository _repository = SupportRepository();

  final RxList<Announcement> announcements = <Announcement>[].obs;
  final RxInt liveCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// The help for the screen the merchant opened the sheet from.
  final RxList<HelpArticle> helpArticles = <HelpArticle>[].obs;
  final RxBool isHelpLoading = false.obs;
  final RxString helpError = ''.obs;

  /// False when the server does not recognise the surface this app asked for --
  /// see [HelpTopics.known]. Starts true so the "we have drifted" message is
  /// shown only once an answer has actually said so.
  final RxBool helpSurfaceKnown = true.obs;

  @override
  void onInit() {
    super.onInit();
    getAnnouncements();
  }

  Future<void> getAnnouncements() async {
    if (announcements.isEmpty) {
      isLoading.value = true;
    }

    errorMessage.value = '';

    try {
      final response = await _repository.getAnnouncements();

      response.fold(
        onSuccess: (data) {
          if (apiRefused(data)) {
            // A 200 carrying `status: 0`. See the class docblock.
            if (announcements.isEmpty) {
              errorMessage.value = apiMessage(
                data,
                fallback: 'announcements_failed'.tr,
              );
            }
            return;
          }

          final model = AnnouncementModel.fromJson(data);

          announcements.value = model.announcements;
          liveCount.value = model.liveCount;
          announcements.refresh();
        },
        onFailure: (reason, message, errors) {
          AppLog.d('announcements fetch failed: $message');

          if (announcements.isEmpty) {
            errorMessage.value = failureMessage(
              reason,
              message,
              'announcements_failed'.tr,
            );
          }
        },
      );
    } catch (e) {
      AppLog.d('announcements fetch threw: $e');

      if (announcements.isEmpty) {
        errorMessage.value = 'connection_failed'.tr;
      }
    }

    isLoading.value = false;
  }

  /// The contextual help for [surface].
  ///
  /// The list is cleared FIRST. A sheet opened from a second screen while the
  /// previous screen's articles are still in the list would show the wrong
  /// screen's help for as long as the request takes, which is worse than showing
  /// a spinner.
  Future<void> getHelp(String surface) async {
    helpArticles.clear();
    helpError.value = '';
    helpSurfaceKnown.value = true;
    isHelpLoading.value = true;

    try {
      final response = await _repository.getHelpTopics(surface);

      response.fold(
        onSuccess: (data) {
          if (apiRefused(data)) {
            helpError.value = apiMessage(data, fallback: 'help_failed'.tr);
            return;
          }

          final topics = HelpTopics.fromJson(data);

          helpSurfaceKnown.value = topics.known;
          helpArticles.value = topics.articles;
          helpArticles.refresh();
        },
        onFailure: (reason, message, errors) {
          AppLog.d('help fetch failed: $message');
          helpError.value = failureMessage(reason, message, 'help_failed'.tr);
        },
      );
    } catch (e) {
      AppLog.d('help fetch threw: $e');
      helpError.value = 'connection_failed'.tr;
    }

    isHelpLoading.value = false;
  }
}
