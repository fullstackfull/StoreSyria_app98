import 'package:flutter/material.dart';

/// The Store Syria brand, measured from the logo the owner supplied on 2026-11-03.
///
/// ONE SOURCE, SHARED WITH THE WEB. `App\Support\Branding\StoreSyriaBrand` in the Laravel
/// repository holds the same two constants and cites the same artwork, so the merchant web admin
/// and this app are the same brand by construction rather than by two people picking a blue.
///
/// THE NUMBERS ARE MEASURED, NOT CHOSEN. Sampling the 30,235 chromatic pixels of the authoritative
/// wordmark — alpha > 200, saturation > 0.25, value > 0.15 — gives a gradient spanning hue
/// 189.4°–218.9° in two dense bands, whose anchors are:
///
///   * `#335DA8` at hue 218.5° — the single most common chromatic colour, 3,644 pixels
///   * `#0EAED1` at hue 190.8° — the centre of the cyan band; 27% of pixels sit within 3° of it
///
/// WHAT THIS APP ALREADY HAD RIGHT, which is most of it. Before this file, five of the app's six
/// brand colours already sat inside that gradient: `cBlue` `#2C57A2` is 0.4° from the blue anchor
/// and `cAccent` `#00B4D8` is 0.8° from the cyan one. The app was never the thing that had drifted
/// — the WEB design system was, onto a 172° teal taken from a tenant's recoloured copy of the mark.
/// So this is a centralisation and an exact alignment, not a migration, and the 293 hardcoded
/// `Color(0x…)` literals elsewhere in `lib/` are deliberately left alone: a blind sweep is what the
/// owner's decision rules out, and they are in the right family already.
///
/// NAVY IS KEPT, ON PURPOSE. `#172C4E` is inside the gradient too (hue 217.1°) and it is the right
/// colour for a filled bar carrying white type — white on it measures 13.94:1. It stays as the
/// bottom-navigation and label colour. What changed is that it is no longer *the brand*: the logo's
/// own tagline is set in `#335DA8`, and that is what a primary button should be.
class StoreSyriaBrand {
  StoreSyriaBrand._();

  /// The logo's dominant blue. 6.42:1 on white, so it can carry white type.
  static const Color blue = Color(0xFF335DA8);

  /// The logo's cyan. 2.63:1 on white — an accent and a dark-surface brand, never light-mode text.
  static const Color cyan = Color(0xFF0EAED1);

  /// The brand on a dark surface, DERIVED rather than copied.
  ///
  /// `blue` on this app's own dark card (`#18263F`) measures **2.36:1** — the light-mode brand is
  /// unreadable there against any threshold that matters (4.5:1 for text, 3:1 for a non-text
  /// indicator), which is the entire reason a dark variant exists. This is the same step the
  /// web design system's dark `--ss-brand` uses, so the two platforms agree in both themes:
  /// 8.31:1 on `#0F1A2E`, 7.23:1 on `#18263F`, 6.11:1 on `#213252`.
  static const Color cyanOnDark = Color(0xFF2AC3E5);

  /// Deep brand navy. Inside the gradient at hue 217.1°, kept for filled bars under white type.
  static const Color navy = Color(0xFF172C4E);

  /// The hue band the artwork actually spans.
  static const double hueMin = 189.4;
  static const double hueMax = 218.9;

  /// True when a hue in degrees lies inside the logo's own gradient.
  static bool hueIsInBand(double hue) => hue >= hueMin && hue <= hueMax;

  /// Hue of a colour in degrees, for tests and for any runtime check.
  static double hueOf(Color c) => HSVColor.fromColor(c).hue;
}
