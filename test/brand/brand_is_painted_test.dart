// P2.5-BR-03 -- the brand as the engine ACTUALLY PAINTS IT, not as the tokens declare it.
//
// WHY THIS EXISTS BESIDE store_syria_brand_test.dart. That file asserts the token VALUES. This one
// renders the widgets and reads the pixels back out of the rasterised frame, because a token is
// only a promise: a widget that ignores the theme, a decoration that overpaints, an opacity
// wrapper, or a Material elevation overlay all change what a merchant sees while every token test
// stays green. Everything below is measured from `RepaintBoundary.toImage()` -- the same Skia
// pipeline that paints on a device.
//
// THE LIMITATION, STATED PLAINLY. This is NOT on-device verification. This container has no
// Android SDK, no emulator and no attached device (`flutter devices` offers only Linux desktop and
// Chrome), and `flutter build web` FAILS here before it can be screenshotted: dart2js aborts in
// firebase_messaging_web-3.5.18's interop with "Type 'PromiseJsImpl' not found", a package/SDK
// incompatibility in a dependency, not in this app's code. So the honest description of this
// evidence is: the Flutter engine rasterised these widgets and these are the pixels it produced.

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/config/theme_light/dark_theme.dart';
import 'package:store_go_app/config/theme_light/light_theme.dart';
import 'package:store_go_app/utils/store_syria_brand.dart';
import 'package:store_go_app/view/widget/common_button.dart';

final GlobalKey _boundary = GlobalKey();

Future<Map<String, int>> paintAndCount(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GetMaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF808080), // a neutral grey, in neither brand band
          body: Center(
            child: RepaintBoundary(key: _boundary, child: SizedBox(width: 300, child: child)),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final boundary = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;

  // `toImage()` hands back a Future that only completes when the REAL event loop turns, and
  // `testWidgets` runs inside a fake one. Awaiting it directly therefore hangs until the test
  // times out -- which is exactly what the first draft of this file did, twice. `runAsync` lends
  // the body the real loop for the duration of the rasterisation.
  final Uint8List bytes = (await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    final ByteData data = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final out = data.buffer.asUint8List();
    image.dispose();
    return out;
  }))!;

  final counts = <String, int>{};
  for (var i = 0; i + 3 < bytes.length; i += 4) {
    if (bytes[i + 3] < 200) continue;
    final key = '#'
        '${bytes[i].toRadixString(16).padLeft(2, '0')}'
        '${bytes[i + 1].toRadixString(16).padLeft(2, '0')}'
        '${bytes[i + 2].toRadixString(16).padLeft(2, '0')}';
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return counts;
}

/// Hue of a #rrggbb string, in degrees; null when the pixel is a grey.
double? hueOf(String hex) {
  final r = int.parse(hex.substring(1, 3), radix: 16) / 255;
  final g = int.parse(hex.substring(3, 5), radix: 16) / 255;
  final b = int.parse(hex.substring(5, 7), radix: 16) / 255;
  final mx = math.max(r, math.max(g, b)), mn = math.min(r, math.min(g, b));
  final d = mx - mn;
  if (mx == 0 || d / mx < 0.18 || mx < 0.12) return null; // grey or near-black
  double h;
  if (mx == r) {
    h = ((g - b) / d) % 6;
  } else if (mx == g) {
    h = (b - r) / d + 2;
  } else {
    h = (r - g) / d + 4;
  }
  h *= 60;
  return h < 0 ? h + 360 : h;
}

void main() {
  setUp(() => AppLightTheme.lightThemeColor());

  testWidgets('a primary button is painted in the logo blue, in light mode', (tester) async {
    AppLightTheme.lightThemeColor();
    final counts = await paintAndCount(tester, CommonButton(title: 'Save', onPressed: () {}));

    final chromatic = counts.entries.where((e) => hueOf(e.key) != null).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    expect(chromatic, isNotEmpty, reason: 'the button painted no chromatic pixel at all');

    final dominant = chromatic.first;
    final hue = hueOf(dominant.key)!;
    expect(StoreSyriaBrand.hueIsInBand(hue), isTrue,
        reason: 'the most painted chromatic colour is ${dominant.key} at hue '
            '${hue.toStringAsFixed(1)}°, outside the logo gradient '
            '${StoreSyriaBrand.hueMin}–${StoreSyriaBrand.hueMax}°');
  });

  testWidgets('a primary button is painted in the dark brand, in dark mode', (tester) async {
    AppDarkTheme.darkColor();
    final counts = await paintAndCount(tester, CommonButton(title: 'Save', onPressed: () {}));

    final chromatic = counts.entries.where((e) => hueOf(e.key) != null).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    expect(chromatic, isNotEmpty);
    final hue = hueOf(chromatic.first.key)!;
    expect(StoreSyriaBrand.hueIsInBand(hue), isTrue,
        reason: 'the dark button paints ${chromatic.first.key} at hue '
            '${hue.toStringAsFixed(1)}°');
    // And it is the CYAN end, not the light blue re-used on a dark surface.
    expect(hue, lessThan(200.0),
        reason: 'dark mode is painting the light-mode blue, which measures 2.36:1 on the card');

    AppLightTheme.lightThemeColor();
  });

  // THE ANTI-VACUITY CONTROL. If the capture were silently returning an empty or all-grey frame,
  // every assertion above would be satisfiable by an empty `chromatic` list -- so prove the
  // measurement can SEE an off-brand colour when one is really painted.
  testWidgets('the capture detects an off-brand colour when one is painted', (tester) async {
    final counts = await paintAndCount(
      tester,
      CommonButton(title: 'Save', onPressed: () {}, btnColor: const Color(0xFF10B77F)),
    );

    final chromatic = counts.entries.where((e) => hueOf(e.key) != null).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final hue = hueOf(chromatic.first.key)!;
    expect(StoreSyriaBrand.hueIsInBand(hue), isFalse,
        reason: 'the retired host green #10B77F was painted and the measurement called it '
            'on-brand, so the measurement is not measuring anything');
    expect(hue, closeTo(160.0, 3.0));
  });
}
