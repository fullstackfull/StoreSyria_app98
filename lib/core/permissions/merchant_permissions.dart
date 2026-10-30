import '../../utils/prefer.dart';

/// P2-07-13 / WS K13 — what this merchant or employee may do, in the store they are in.
///
/// WHY THE APP NEEDED THIS AT ALL. Before this, the app had no permission model of any kind:
/// `permission`, `role`, `isAble`, `userType` and `hasAccess` matched nothing across `lib/` but a
/// single translation string. Every screen was shown to everyone, because `api/admin/adminlogin`
/// returned `id, name, email, image, mobile, current_store, token` and said nothing about what the
/// employee may do. The server now reports a `permissions` list on login AND on the dashboard, and
/// this is the client's side of that contract.
///
/// THIS IS NOT A SECURITY BOUNDARY, and that distinction is the whole point. It lives in
/// unencrypted local storage, so on a rooted device it is attacker-controlled — exactly the
/// caveat [Prefs.getStoreID] already carries. It decides what the UI OFFERS; the server decides
/// what the server DOES, and `Api\DashboardController` now enforces the same names independently.
/// A permission list that said "yes" to everything would reveal buttons, not data.
///
/// [wildcard] IS THE PLATFORM OPERATOR. `isAbleTo()` refuses the operator in the backend — there
/// is no super-admin bypass there, operator status is a string on `users.type` — so a list built
/// from role membership alone comes back EMPTY for the one principal who may do everything. The
/// server answers `['*']` for them, and [may] has to honour it or the app would hide every screen
/// from the operator.
class MerchantPermissions {
  /// The operator's entry: every permission. Mirrors `MerchantPermissions::WILDCARD` server-side.
  static const String wildcard = '*';

  static const String _storageKey = 'merchant_permissions';
  static const String _typeStorageKey = 'merchant_user_type';

  const MerchantPermissions._(this._names, this.userType);

  /// Nothing held. The honest default before a login: the UI offers nothing it cannot confirm.
  const MerchantPermissions.none() : _names = const <String>{}, userType = '';

  final Set<String> _names;

  /// `users.type` as the server reported it — reported for display and diagnostics, never the
  /// basis of a gate here. [wildcard] carries the operator's authority instead, so there is one
  /// rule to honour rather than a string comparison the client could get wrong. The backend's own
  /// comparison `rtrim`s SPACE only to match MySQL's PAD SPACE, a distinction `trim()` gets
  /// wrong, and reproducing that subtlety client-side would be a second place to get it wrong.
  final String userType;

  /// Reads the `permissions` / `user_type` keys out of a login or dashboard `data` envelope.
  ///
  /// TOLERANT BY DESIGN, because this parses a response from a server that may be older than the
  /// app: a missing key, a null, a non-list, or a list with non-string entries must all degrade to
  /// "nothing held" rather than throw. The whole app is behind this parse.
  factory MerchantPermissions.fromJson(dynamic json) {
    if (json is! Map) return const MerchantPermissions.none();

    final raw = json['permissions'];
    final names = <String>{};

    if (raw is List) {
      for (final entry in raw) {
        if (entry is String && entry.isNotEmpty) names.add(entry);
      }
    }

    final type = json['user_type'];

    return MerchantPermissions._(names, type is String ? type : '');
  }

  /// True when this principal holds [permission] — or the wildcard.
  bool may(String permission) => _names.contains(wildcard) || _names.contains(permission);

  /// True when ANY of [permissions] is held. For a surface more than one role can reach, which is
  /// how the backend gates orders: `Manage Order` OR `Show Order`.
  bool mayAny(Iterable<String> permissions) {
    if (_names.contains(wildcard)) return true;

    for (final permission in permissions) {
      if (_names.contains(permission)) return true;
    }

    return false;
  }

  /// WHETHER TO OFFER A NAVIGATION ENTRY, which is NOT the same question as [may].
  ///
  /// The difference is what to do when the server told us NOTHING. [may] answers strictly: an
  /// empty list holds nothing. That is right for a decision about data, and wrong for a decision
  /// about the drawer, because a client shipped ahead of its backend would hide every screen and
  /// the app would be unusable against a server that does not send the key yet.
  ///
  /// So: UNINFORMED offers, INFORMED gates. Once the server has listed anything at all, the list
  /// is believed and an absent name hides the entry. This is safe only because it decides
  /// nothing: `Api\DashboardController` enforces the same names server-side and withholds the
  /// data regardless of what the drawer shows, so the worst case here is a visible entry whose
  /// screen then reports 'action_not_permitted' — not a leak.
  bool mayOffer(String permission) => isEmpty || may(permission);

  /// [mayOffer] for a surface more than one permission can reach.
  bool mayOfferAny(Iterable<String> permissions) => isEmpty || mayAny(permissions);

  /// The platform operator.
  bool get isUnrestricted => _names.contains(wildcard);

  /// True when the server told us nothing. Distinct from "told us the list is empty": both read
  /// as holding nothing, and the UI treats them the same, but a caller that wants to know whether
  /// to re-ask can.
  bool get isEmpty => _names.isEmpty;

  /// The names, for a test or a diagnostic. A copy — this object is immutable.
  Set<String> get names => Set<String>.unmodifiable(_names);

  // -----------------------------------------------------------------------------------------
  //  PERSISTENCE
  // -----------------------------------------------------------------------------------------
  //
  // Stored so that a screen opening before the dashboard has answered still knows what to offer,
  // and DELIBERATELY NOT in `Prefs.preservedOnClear`: this is session state, so a logout must take
  // it with the token. That allowlist erases by default, which is the safe direction.

  static MerchantPermissions? _current;

  /// The live set, for a screen that is not wired to [HomeController].
  ///
  /// Memoised rather than re-read on every `build()`: a GridView rebuilding on scroll would
  /// otherwise hit storage per frame. [persist] and [forget] keep it correct, and they are the
  /// only two writers — login persists, each dashboard response persists, a store switch and a
  /// logout forget.
  static MerchantPermissions get current => _current ??= restore();

  void persist() {
    Prefs.setString(_storageKey, _names.join('\u0000'));
    Prefs.setString(_typeStorageKey, userType);
    _current = this;
  }

  static MerchantPermissions restore() {
    final raw = Prefs.getString(_storageKey);

    if (raw is! String || raw.isEmpty) return const MerchantPermissions.none();

    final names = raw.split('\u0000').where((name) => name.isNotEmpty).toSet();

    final type = Prefs.getString(_typeStorageKey);

    return MerchantPermissions._(names, type is String ? type : '');
  }

  static void forget() {
    Prefs.remove(_storageKey);
    Prefs.remove(_typeStorageKey);
    _current = const MerchantPermissions.none();
  }

  @override
  String toString() => 'MerchantPermissions(${_names.length} held, type=$userType)';
}

/// The permission names the app gates on. Named constants rather than literals at each call site,
/// because they must match the backend EXACTLY — these four are the names
/// `Utility::addNewData()` creates and grants to the merchant role, verified against it, and a
/// typo here would silently hide a screen from everyone.
class Permissions {
  const Permissions._();

  static const String manageOrder = 'Manage Order';
  static const String showOrder = 'Show Order';
  static const String manageProducts = 'Manage Products';
  static const String manageCoupon = 'Manage Coupon';
  static const String manageCustomer = 'Manage Customer';
  static const String manageDashboard = 'Manage Dashboard';
  static const String manageProductCategory = 'Manage Product Category';
  static const String manageStoreAnalytics = 'Manage Store Analytics';
  static const String manageStoreSetting = 'Manage Store Setting';
  static const String manageShipping = 'Manage Shipping';
  static const String manageTax = 'Manage Tax';
  static const String manageDeliveryboy = 'Manage Deliveryboy';

  /// Reading orders at all: the backend gates the dashboard's order figures on either name.
  static const List<String> readOrders = <String>[manageOrder, showOrder];
}
