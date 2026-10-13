// TENANT CONTEXT, CLIENT SIDE -- the local caches must not survive a store
// switch.
//
// The server-side half of tenancy is a store_id discriminator and a global
// scope. This app has a second, independent copy of the same problem, and the
// server cannot help with it: eight controllers persist their last response in
// GetStorage through CacheService, and the KEYS ARE NOT STORE-SCOPED.
// `home_product_list_data` is one key for every store the merchant owns
// (product_controller.dart:20, and the same shape in the other seven).
//
// They are read in `onInit` specifically to paint the screen before the
// network answers -- `_loadCachedProducts` at product_controller.dart:60-82,
// and its siblings. So a merchant who switches from store A to store B sees
// store A's products, orders, customers, coupons, categories, delivery boys,
// notifications and dashboard totals, for as long as the new request takes,
// and permanently if it fails. That is one tenant's data rendered under
// another tenant's name, decided entirely on the device.
//
// WHAT KEEPS IT CORRECT. One central service. Every store-scoped controller
// implements StoreAware, registers a resolver with StoreChangeService in its
// onInit, and clears its own cache key in resetForStoreChange;
// HomeController calls notifyStoreChanged() once, after the store change
// succeeds (home_controller.dart:149).
//
// WHY THAT NEEDS A TEST RATHER THAN A REVIEW. The wiring is in four separate
// places per controller -- the `implements` clause, the register call, the
// reset method, and the clear inside it -- and THREE OF THE FOUR FAIL
// SILENTLY. A controller that implements StoreAware but never registers is
// never reset, and the compiler is satisfied. A reset that forgets its
// CacheService.clear() leaves the stale rows on disk to be re-read on the next
// onInit, and the compiler is satisfied. register() even swallows the error
// when a resolver throws (store_change_service.dart:32-37), deliberately, so
// that one disposed controller cannot block the rest -- which is right, and
// also means a broken resolver is invisible at runtime.
//
// So the four facts are asserted structurally, the service's own dispatch is
// executed, and the one key that is NOT cleared is named with the evidence
// for why it must not be.

import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/core/controller/home_controller/store_change_service.dart';

import '../support/source_tree.dart';

/// The one cache key that is deliberately NOT cleared on a store change, and
/// the evidence: its endpoint carries no store_id, so the value is
/// platform-global rather than tenant data.
///
///   home_controller.dart:19   _cacheImageUrlKey
///   dashboard_repository.dart:6  getImageBaseData() -> getRequest(
///                                API.imageBaseUrl) with no store_id appended
///   base_api.dart:9           imageBaseUrl = '/base_url'
///
/// Repo A leaves `base_url` on ['AdminApiLog'] alone with no custom.auth and
/// no store scoping, which is the server agreeing that it is not tenant data.
const _globalCacheKeys = <String>{'_cacheImageUrlKey'};

void main() {
  // ---------------------------------------------------------------------------
  group('the store-change wiring is symmetric', () {
    late Map<String, String> sources;

    setUpAll(() {
      sources = {
        for (final f in libDartFiles())
          relative(f): commentsStripped(f.readAsStringSync()),
      };
    });

    test('every controller that reads a cache key is StoreAware', () {
      final readers = sources.entries
          .where((e) => e.value.contains('CacheService.get<'))
          .map((e) => e.key)
          .toList()
        ..sort();

      expect(
        readers,
        isNotEmpty,
        reason: 'No file reads a cache key. Either caching was removed or '
            'this test has gone vacuous.',
      );

      final missing = <String>[];

      for (final path in readers) {
        final source = sources[path]!;

        if (!source.contains('implements StoreAware')) {
          missing.add('$path reads a cache key but does not implement '
              'StoreAware, so a store change never resets it');
        }

        if (!source.contains('void resetForStoreChange()')) {
          missing.add('$path has no resetForStoreChange()');
        }

        // The resolver is a closure on purpose (store_change_service.dart:
        // 21-26) so the service always reaches the live instance.
        if (!source.contains('StoreChangeService.instance.register(')) {
          missing.add('$path never registers itself, so its '
              'resetForStoreChange() is unreachable -- the exact failure '
              'the compiler cannot see');
        }
      }

      expect(missing, isEmpty, reason: missing.join('\n'));
    });

    test('and nothing registers without being StoreAware', () {
      // The other direction. A register() call in a class that does not
      // implement StoreAware would not compile, but a StoreAware class whose
      // register call was deleted in a refactor compiles perfectly, so both
      // sets are compared rather than one checked.
      final declares = sources.entries
          .where((e) =>
              e.key != 'lib/core/controller/home_controller/'
                  'store_change_service.dart' &&
              e.value.contains('implements StoreAware'))
          .map((e) => e.key)
          .toSet();

      final registers = sources.entries
          .where((e) =>
              e.value.contains('StoreChangeService.instance.register('))
          .map((e) => e.key)
          .toSet();

      expect(
        declares.difference(registers),
        isEmpty,
        reason: 'StoreAware but never registered -- reset is dead code:\n'
            '${declares.difference(registers).join('\n')}',
      );

      expect(
        registers.difference(declares),
        isEmpty,
        reason: 'Registers a resolver without declaring StoreAware:\n'
            '${registers.difference(declares).join('\n')}',
      );

      expect(declares.length, 9);
    });

    test('every cache key is cleared when the store changes', () {
      // The leak that survives a correct reset: clearing the in-memory list
      // but not the on-disk copy means the next onInit reads the previous
      // store's rows straight back out of GetStorage.
      final uncleared = <String>[];
      final keysSeen = <String>[];

      // Keys are discovered from the SAVE call sites, not from a naming
      // convention. An earlier version of this test matched
      // `static const String _cacheXKey =` and so missed
      // store_setting_controller.dart's _currenciesCacheKey,
      // _currentCurrencyCacheKey and _currenciesCacheTimeKey entirely --
      // which are exactly the three that were leaking across stores. What
      // makes a key need clearing is that something persists it, so that is
      // what is matched.
      final saved = RegExp(r'CacheService\.save\(\s*(\w+)');

      sources.forEach((path, source) {
        for (final m in saved.allMatches(source)) {
          final key = m.group(1)!;
          if (keysSeen.contains('$path  $key')) continue;
          keysSeen.add('$path  $key');

          if (_globalCacheKeys.contains(key)) continue;

          if (!_clearedByReset(source, key)) {
            uncleared.add(
              '$path  $key is persisted but the store-change reset does not '
              'clear it. If it is platform-global rather than tenant data, '
              'add it to _globalCacheKeys WITH the evidence that its '
              'endpoint carries no store_id.',
            );
          }
        }
      });

      expect(uncleared, isEmpty, reason: uncleared.join('\n'));

      // Twelve persisted keys: eleven tenant-scoped and cleared, one global
      // and named in _globalCacheKeys.
      expect(keysSeen.length, 12, reason: keysSeen.join('\n'));
    });

    test('the store change notifies exactly once, after it succeeds', () {
      final callers = <String>[];

      sources.forEach((path, source) {
        if (path.endsWith('store_change_service.dart')) return;

        for (final line in source.split('\n')) {
          if (line.contains('notifyStoreChanged()')) {
            callers.add('$path  ${line.trim()}');
          }
        }
      });

      expect(
        callers.length,
        1,
        reason: 'notifyStoreChanged() belongs at the one place the store '
            'actually changes. More than one caller means a reset can fire '
            'on a FAILED change and throw away the current store\'s data '
            'for nothing. Found:\n${callers.join('\n')}',
      );

      expect(
        callers.single,
        startsWith('lib/core/controller/home_controller/'
            'home_controller.dart'),
      );
    });
  });

  // ---------------------------------------------------------------------------
  group('the service itself dispatches correctly', () {
    // Executed, not read: StoreChangeService is a plain GetxService, so the
    // dispatch loop runs in a unit test without an engine or a navigator.

    test('a store change resets every registered controller', () {
      final service = StoreChangeService();
      final reset = <String>[];

      for (final name in const ['products', 'orders', 'customers']) {
        service.register(() => _Fake(name, reset));
      }

      service.notifyStoreChanged();

      expect(reset, const ['products', 'orders', 'customers']);
    });

    test('one controller that is gone does not stop the others', () {
      // The reason register() takes a closure and notifyStoreChanged()
      // swallows: a controller Get has disposed makes its resolver throw, and
      // that must not leave the REMAINING controllers showing the previous
      // store's data. Without the try/catch, registration order would decide
      // which tenants leaked.
      final service = StoreChangeService();
      final reset = <String>[];

      service.register(() => _Fake('first', reset));
      service.register(() => throw StateError('disposed'));
      service.register(() => _Fake('third', reset));

      service.notifyStoreChanged();

      expect(
        reset,
        const ['first', 'third'],
        reason: 'A disposed controller in the middle of the list must not '
            'cost the ones after it their reset.',
      );
    });

    test('a controller whose own reset throws does not stop the others', () {
      final service = StoreChangeService();
      final reset = <String>[];

      service.register(() => _Fake('first', reset));
      service.register(() => _Throwing());
      service.register(() => _Fake('third', reset));

      service.notifyStoreChanged();

      expect(reset, const ['first', 'third']);
    });

    test('registering nothing is not an error', () {
      expect(StoreChangeService().notifyStoreChanged, returnsNormally);
    });

    test('a second store change resets everything again', () {
      // Resolvers are not consumed. If they were, the second switch of a
      // session would leave the first store's data in place.
      final service = StoreChangeService();
      final reset = <String>[];

      service.register(() => _Fake('products', reset));

      service.notifyStoreChanged();
      service.notifyStoreChanged();

      expect(reset, const ['products', 'products']);
    });
  });

  // ---------------------------------------------------------------------------
  group('the cache layer cannot be bypassed', () {
    test('only Prefs and CacheService write to the storage container', () {
      // A controller writing store-scoped data straight to GetStorage would
      // be outside both the clear-on-logout allowlist and the
      // clear-on-store-change wiring, and nothing above would see it.
      final offenders = <String>[];

      for (final file in libDartFiles()) {
        final path = relative(file);
        if (path == 'lib/utils/prefer.dart') continue;
        if (path.endsWith('cahe.dart')) continue;

        final lines = codeOnly(file.readAsStringSync()).split('\n');

        for (var i = 0; i < lines.length; i++) {
          if (RegExp(r'(getStorage|_box)[?!]?\.write\(').hasMatch(lines[i])) {
            offenders.add('$path:${i + 1}  ${lines[i].trim()}');
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'Persist through Prefs (session state, with the logout '
            'allowlist) or CacheService (store-scoped, with the '
            'store-change clear). Found:\n${offenders.join('\n')}',
      );
    });

    test('the detector finds a write when there is one', () {
      // Keeps the assertion above from passing because the pattern stopped
      // matching rather than because the code is clean.
      const sample = '''
        void save() {
          getStorage?.write('k', 'v');
        }
      ''';

      final hits = RegExp(r'(getStorage|_box)[?!]?\.write\(')
          .allMatches(codeOnly(sample))
          .length;

      expect(hits, 1);
    });

    test('and ignores the same text in a comment', () {
      const sample = '''
        // getStorage?.write('k', 'v') is what this used to do.
        void save() {}
      ''';

      expect(
        RegExp(r'(getStorage|_box)[?!]?\.write\(')
            .allMatches(codeOnly(sample))
            .length,
        0,
      );
    });
  });
}

/// The body of `name`'s declaration, brace-matched.
///
/// Returns '' when there is no such declaration.
String _bodyOf(String source, String name) {
  final at = source.indexOf(name);
  if (at < 0) return '';

  final open = source.indexOf('{', at);
  if (open < 0) return '';

  var depth = 0;

  for (var i = open; i < source.length; i++) {
    if (source[i] == '{') depth++;
    if (source[i] == '}') {
      depth--;
      if (depth == 0) return source.substring(open, i + 1);
    }
  }

  return '';
}

/// Whether a store change actually REACHES the clear for [key].
///
/// `source.contains('CacheService.clear(key)')` is not enough: a clear that
/// exists in a helper nobody calls any more satisfies it while leaving the
/// stale rows on disk, which is precisely the regression this file is here to
/// catch. So the reset's own body is brace-matched, and one level of
/// indirection is followed -- every current controller either clears inline
/// or delegates to a private zero-argument helper
/// (_clearCurrencyCache, _resetDashboardData).
bool _clearedByReset(String source, String key) {
  final reset = _bodyOf(source, 'void resetForStoreChange()');
  if (reset.isEmpty) return false;

  final clear = 'CacheService.clear($key)';

  if (reset.contains(clear)) return true;

  for (final m in RegExp(r'(_\w+)\(\)').allMatches(reset)) {
    if (_bodyOf(source, 'void ${m.group(1)}()').contains(clear)) return true;
  }

  return false;
}

class _Fake implements StoreAware {
  _Fake(this.name, this.log);

  final String name;
  final List<String> log;

  @override
  void resetForStoreChange() => log.add(name);
}

class _Throwing implements StoreAware {
  @override
  void resetForStoreChange() => throw StateError('reset failed');
}
