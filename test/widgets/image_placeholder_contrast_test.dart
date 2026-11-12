// P2.5-WAVE-5 -- the broken-image placeholder and the loading spinner were
// invisible in LIGHT mode, which is the opposite of what the surrounding work
// would lead you to expect.
//
// MEASURED, before the change:
//
//     broken-image icon   Colors.grey        #9E9E9E   on #FFFFFF   2.68:1
//     loading spinner     Colors.grey[400]   #BDBDBD   on #FFFFFF   1.88:1
//
// Both are below WCAG 2.2 SC 1.4.11's 3:1 for a NON-TEXT graphic, and both of
// them ARE the information: the icon is the only thing telling a merchant the
// image failed, and the spinner is the only thing telling them anything is
// happening. A spinner at 1.88:1 on white is a loading state nobody can see.
//
// They were also fixed literals in `icon_and_image.dart`, a file with no
// `Theme.of(context)` and no `Brightness` reference at all -- so they could not
// follow the theme in either direction. On the dark surfaces they happened to
// pass (5.65:1 and 8.05:1), which is why nothing ever caught them: the theme
// most likely to be tested was the one where the bug does not show.
//
// THE REPAIR INVENTS NO VALUE. `AppColor.cFont` is the existing secondary-text
// token and is ALREADY theme-aware -- `LightThemeColor.cFont` #66728C and
// `DarkThemeColor.cSecondaryText` #A9B8D0 -- which is semantically right for a
// placeholder and a progress indicator. Measured after: 4.83:1 on the light
// background and 6.36-8.66:1 on all three dark surfaces.
//
// THIS WIDGET IS SHARED. Every product thumbnail, every store logo, every
// avatar in the app renders through it, so the two literals were on effectively
// every image in the product.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/config/theme_light/dark_theme.dart';
import 'package:store_go_app/config/theme_light/light_theme.dart';
import 'package:store_go_app/utils/colors.dart';

double _channel(double srgb) =>
    srgb <= 0.03928 ? srgb / 12.92 : math.pow((srgb + 0.055) / 1.055, 2.4) as double;

double _luminance(Color c) =>
    0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

double _ratio(Color a, Color b) {
  final l1 = _luminance(a);
  final l2 = _luminance(b);
  return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
}

void main() {
  // `AppDarkTheme.darkColor()` and `AppLightTheme.lightThemeColor()` MUTATE the
  // static fields on AppColor -- that is how this app switches theme. So each
  // test sets the theme it is asserting about, and the light arm is restored
  // afterwards so ordering cannot change a result.
  tearDown(AppLightTheme.lightThemeColor);

  test('PREMISE: the old literals really were below 3:1 on the light background', () {
    // Without this the assertions below could be satisfied by a token that is
    // no better than what it replaced.
    AppLightTheme.lightThemeColor();
    expect(_ratio(const Color(0xFF9E9E9E), AppColor.cWhite), lessThan(3.0),
        reason: 'Colors.grey is no longer below 3:1 on white, so the premise of '
            'this whole file has changed and it needs re-measuring');
    expect(_ratio(const Color(0xFFBDBDBD), AppColor.cWhite), lessThan(3.0),
        reason: 'Colors.grey.shade400 is no longer below 3:1 on white');
  });

  test('the placeholder tone clears SC 1.4.11 on the LIGHT surfaces', () {
    AppLightTheme.lightThemeColor();
    for (final surface in <Color>[
      AppColor.cWhite,
      LightThemeColor.cLight,
      LightThemeColor.cButton,
    ]) {
      expect(_ratio(AppColor.cFont, surface), greaterThanOrEqualTo(3.0),
          reason: 'the image placeholder/spinner tone ${AppColor.cFont} is below '
              '3:1 on the light surface $surface');
    }
  });

  test('the placeholder tone clears SC 1.4.11 on the DARK surfaces', () {
    AppDarkTheme.darkColor();
    for (final surface in <Color>[
      DarkThemeColor.cBackGround,
      DarkThemeColor.cCardBackground,
      DarkThemeColor.cSurface,
    ]) {
      expect(_ratio(AppColor.cFont, surface), greaterThanOrEqualTo(3.0),
          reason: 'the image placeholder/spinner tone ${AppColor.cFont} is below '
              '3:1 on the dark surface $surface');
    }
  });

  test('the tone actually changes with the theme', () {
    AppLightTheme.lightThemeColor();
    final light = AppColor.cFont;
    AppDarkTheme.darkColor();
    final dark = AppColor.cFont;

    expect(dark, isNot(equals(light)),
        reason: 'AppColor.cFont is the same value in both themes, so the "theme-aware" '
            'claim in icon_and_image.dart is false and one theme is being served the '
            "other's value");
  });
}
