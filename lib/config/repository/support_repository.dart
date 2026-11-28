import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/network/result.dart';
import 'package:store_go_app/translations/translation_service.dart';
import 'package:store_go_app/utils/base_api.dart';

/// SUPPORT-002 -- contextual help and platform announcements.
///
/// NO STORE ID IS SENT, and that is the requirement rather than an omission.
/// Every other repository in this directory appends `API.storeIdUrl +
/// Prefs.getStoreID()`, because every other endpoint reads a tenant's own rows.
/// An announcement is the PLATFORM talking to every tenant on it -- the table
/// has no `store_id` column at all -- and the help corpus is markdown in the
/// server's repository. So there is nothing per-store to send, and nothing
/// per-store that could come back.
///
/// THE LANGUAGE IS SENT, AND THAT ONE IS NECESSARY. The app's language is a
/// DEVICE choice (TranslationService, backed by Prefs) and the server cannot
/// know it: a merchant whose `users.language` still says English and whose app
/// is set to Arabic would otherwise be served English announcements. The server
/// folds anything it does not ship, so this is a presentation preference and
/// never a selector over data.
class SupportRepository {
  /// What the platform is telling this merchant, newest first.
  Future<Result<Map<String, dynamic>>> getAnnouncements() {
    return NetworkHttps.getRequest(
      API.announcementsUrl + API.langUrl + _language(),
    );
  }

  /// The help for one screen.
  ///
  /// [surface] is a key from the server's own vocabulary (`products`, `orders`,
  /// `storefront`, ...) and is deliberately NOT a Laravel route name: the server
  /// keeps the two apart so a route rename there cannot silently empty the help
  /// in a copy of this app that is already on a phone.
  Future<Result<Map<String, dynamic>>> getHelpTopics(String surface) {
    return NetworkHttps.getRequest(
      API.helpTopicsUrl +
          API.langUrl +
          _language() +
          API.andSurfaceUrl +
          Uri.encodeQueryComponent(surface),
    );
  }

  /// The whole help map, for the app to cache in one call.
  Future<Result<Map<String, dynamic>>> getAllHelpTopics() {
    return NetworkHttps.getRequest(
      API.helpTopicsUrl + API.langUrl + _language(),
    );
  }

  /// `ar` or `en` -- the language the merchant chose in THIS app.
  String _language() => TranslationService.currentLocale.languageCode;
}
