// P2.5-BR-03 -- the Flutter admin and the merchant web admin are ONE brand.
//
// The owner's decision of 2026-11-03 is that Store Syria has one visual identity across web and
// mobile, taken from the real logo. The logo is a blue-to-cyan gradient spanning hue 189.4-218.9
// degrees, with anchors #335DA8 (hue 218.5, its single most common chromatic colour) and #0EAED1
// (hue 190.8, the centre of its cyan band).
//
// WHAT THIS FILE IS FOR. The web side has a test that opens the PNG and measures it. This side
// cannot -- the artwork lives in the Laravel repository -- so this pins the OUTCOME instead: the
// two anchors, by value, and every brand colour's membership of the band. If the two repositories
// ever drift again, one of the two test files fails.
//
// AND IT PINS WHAT THE BADLY NAMED GLOBALS ACTUALLY HOLD. `AppColor.themeGreenColor` and
// `AppColor.cGreenFont` have held a CYAN since long before Phase 2.5. Renaming them would touch
// 121 call sites for no behaviour change, so the names stay and the test states the truth.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/config/theme_light/dark_theme.dart';
import 'package:store_go_app/config/theme_light/light_theme.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/store_syria_brand.dart';

double _luminance(Color c) {
  double ch(int v) {
    final s = v / 255.0;
    return s <= 0.03928 ? s / 12.92 : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * ch((c.r * 255.0).round()) +
      0.7152 * ch((c.g * 255.0).round()) +
      0.0722 * ch((c.b * 255.0).round());
}

double contrast(Color a, Color b) {
  final la = _luminance(a), lb = _luminance(b);
  final hi = math.max(la, lb), lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

String hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

void main() {
  group('the anchors are the measured logo colours', () {
    test('the blue anchor is the logo\'s dominant chromatic colour', () {
      expect(hex(StoreSyriaBrand.blue), '#335DA8');
      expect(StoreSyriaBrand.hueOf(StoreSyriaBrand.blue), closeTo(218.5, 1.0));
    });

    test('the cyan anchor is the centre of the logo\'s cyan band', () {
      expect(hex(StoreSyriaBrand.cyan), '#0EAED1');
      expect(StoreSyriaBrand.hueOf(StoreSyriaBrand.cyan), closeTo(190.8, 1.0));
    });

    test('the band is the one the artwork spans', () {
      expect(StoreSyriaBrand.hueMin, 189.4);
      expect(StoreSyriaBrand.hueMax, 218.9);
      expect(StoreSyriaBrand.hueIsInBand(172.0), isFalse,
          reason: 'the retired web teal must not read as in-band');
      expect(StoreSyriaBrand.hueIsInBand(160.0), isFalse,
          reason: 'the retired host chrome green must not read as in-band');
    });
  });

  group('every brand colour sits inside the logo gradient', () {
    test('in the light palette', () {
      final palette = <String, Color>{
        'cPrimary': LightThemeColor.cPrimary,
        'cBlue': LightThemeColor.cBlue,
        'cAccent': LightThemeColor.cAccent,
        'cLabel': LightThemeColor.cLabel,
        'cBottomNavyBlueColor': LightThemeColor.cBottomNavyBlueColor,
      };
      palette.forEach((name, c) {
        final h = StoreSyriaBrand.hueOf(c);
        expect(StoreSyriaBrand.hueIsInBand(h), isTrue,
            reason: 'LightThemeColor.$name is ${hex(c)} at hue ${h.toStringAsFixed(1)}, outside '
                'the logo\'s ${StoreSyriaBrand.hueMin}-${StoreSyriaBrand.hueMax} gradient');
      });
    });

    test('in the dark palette', () {
      final palette = <String, Color>{
        'cPrimary': DarkThemeColor.cPrimary,
        'cBlue': DarkThemeColor.cBlue,
        'cAccent': DarkThemeColor.cAccent,
      };
      palette.forEach((name, c) {
        final h = StoreSyriaBrand.hueOf(c);
        expect(StoreSyriaBrand.hueIsInBand(h), isTrue,
            reason: 'DarkThemeColor.$name is ${hex(c)} at hue ${h.toStringAsFixed(1)}, outside the '
                'logo gradient. Before P2.5-BR-03 this was #10AFC0 at 185.8 -- the one colour in '
                'the whole app that was off-brand.');
      });
    });
  });

  group('the dark brand is derived, not the light hex re-used', () {
    // THE PREMISE of having a dark variant at all. The first draft of this asserted < 2.0 on the
    // strength of a figure written into the source comment by hand; the measured value is 2.36:1,
    // so both the comment and this threshold were corrected to what the arithmetic actually says.
    // 2.36 still fails every threshold that matters -- 4.5:1 for text, 3:1 for a non-text
    // indicator -- which is the claim this test exists to make.
    test('the light brand really is unreadable on the dark card', () {
      final r = contrast(StoreSyriaBrand.blue, DarkThemeColor.cCardBackground);
      expect(r, closeTo(2.36, 0.05));
      expect(r, lessThan(3.0),
          reason: 'the light-mode brand would have to clear 3:1 even as a mere indicator');
    });

    test('the dark brand clears 4.5:1 on all three dark surfaces', () {
      for (final entry in {
        'cBackGround': DarkThemeColor.cBackGround,
        'cCardBackground': DarkThemeColor.cCardBackground,
        'cSurface': DarkThemeColor.cSurface,
      }.entries) {
        final r = contrast(DarkThemeColor.cPrimary, entry.value);
        expect(r, greaterThanOrEqualTo(4.5),
            reason: 'the dark brand is ${r.toStringAsFixed(2)}:1 on ${entry.key}');
      }
    });

    test('the light brand clears 4.5:1 on white and 3:1 as a non-text indicator', () {
      expect(contrast(LightThemeColor.cPrimary, const Color(0xFFFFFFFF)),
          greaterThanOrEqualTo(4.5));
      expect(contrast(LightThemeColor.cPrimary, LightThemeColor.cLight),
          greaterThanOrEqualTo(3.0));
    });
  });

  group('navy is kept where a filled bar wants it', () {
    test('the bottom navigation and label colour are still the deep navy', () {
      expect(hex(LightThemeColor.cBottomNavyBlueColor), '#172C4E');
      expect(hex(LightThemeColor.cLabel), '#172C4E');
    });

    test('white type on that navy is still comfortably legible', () {
      expect(contrast(const Color(0xFFFFFFFF), LightThemeColor.cBottomNavyBlueColor),
          greaterThan(12.0));
    });
  });

  group('the theme switch carries the brand into the mutable globals', () {
    test('light mode publishes the light brand', () {
      AppLightTheme.lightThemeColor();
      expect(AppColor.themeNavyBlueColor, LightThemeColor.cPrimary);
      expect(AppColor.themeGreenColor, LightThemeColor.cAccent);
      expect(AppColor.cGreenFont, LightThemeColor.cAccent);
    });

    test('dark mode publishes the dark brand', () {
      AppDarkTheme.darkColor();
      expect(AppColor.themeNavyBlueColor, DarkThemeColor.cPrimary);
      expect(AppColor.themeGreenColor, DarkThemeColor.cAccent);
      AppLightTheme.lightThemeColor(); // leave the globals where the rest of the suite expects
    });

    test('the two misleadingly named globals hold a cyan, not a green', () {
      AppLightTheme.lightThemeColor();
      for (final entry in {
        'themeGreenColor': AppColor.themeGreenColor,
        'cGreenFont': AppColor.cGreenFont,
      }.entries) {
        final h = StoreSyriaBrand.hueOf(entry.value);
        expect(h, greaterThan(180.0),
            reason: '${entry.key} is ${hex(entry.value)} at hue ${h.toStringAsFixed(1)}; if this '
                'ever really became a green the name would stop being merely misleading');
        expect(StoreSyriaBrand.hueIsInBand(h), isTrue);
      }
    });
  });
}
