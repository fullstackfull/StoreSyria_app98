// Regression guard for R7-N2 -- assetSvdImageWidget silently discarded its tint.
//
// `assetSvdImageWidget` computed a `finalColorFilter` from either the `color:`
// or the `colorFilter:` argument and then handed it to nothing, because the
// `colorFilter:` parameter on the SvgPicture.asset call was commented out. The
// analyzer could only describe that as `unused_local_variable`.
//
// Seven live call sites across five files pass an explicit tint. The worst is
// home_screen_widget.dart, which draws a WHITE copy icon on a coloured card:
// with the tint dropped the glyph rendered in its own source colour and
// effectively disappeared.
//
// These tests call the product function and inspect the widget it returns, so
// they execute the real branch rather than grepping for the argument. No
// pumping is needed -- the function is a plain widget factory, and
// SvgPicture.colorFilter is a public final field (flutter_svg 2.3.0, svg.dart
// line 94).

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';

void main() {
  group('assetSvdImageWidget applies the tint it is given', () {
    test('an explicit colorFilter reaches the SvgPicture', () {
      const filter = ui.ColorFilter.mode(Colors.white, ui.BlendMode.srcIn);

      final widget = assetSvdImageWidget(
        image: 'assets/svg/anything.svg',
        colorFilter: filter,
      );

      expect(widget, isA<SvgPicture>());
      expect(
        (widget as SvgPicture).colorFilter,
        filter,
        reason: 'The colorFilter argument must not be dropped: a white-on-'
            'coloured icon is invisible without it.',
      );
    });

    test('a `color:` argument becomes a srcIn ColorFilter', () {
      // The `color:` form is the convenience spelling. It must produce the
      // same effect as passing the filter directly, and srcIn is what the
      // function documents.
      final widget = assetSvdImageWidget(
        image: 'assets/svg/anything.svg',
        color: const Color(0xFF123456),
      ) as SvgPicture;

      expect(
        widget.colorFilter,
        const ui.ColorFilter.mode(Color(0xFF123456), ui.BlendMode.srcIn),
      );
    });

    test('`color:` wins over `colorFilter:` when both are given', () {
      // Pins the existing precedence rather than changing it, so the
      // conditional in the function cannot be flipped unnoticed.
      final widget = assetSvdImageWidget(
        image: 'assets/svg/anything.svg',
        color: const Color(0xFFAABBCC),
        colorFilter: const ui.ColorFilter.mode(
          Colors.black,
          ui.BlendMode.dstATop,
        ),
      ) as SvgPicture;

      expect(
        widget.colorFilter,
        const ui.ColorFilter.mode(Color(0xFFAABBCC), ui.BlendMode.srcIn),
      );
    });

    test('no tint means no filter, not a transparent one', () {
      // A default-constructed filter would repaint every untinted icon.
      final widget = assetSvdImageWidget(
        image: 'assets/svg/anything.svg',
      ) as SvgPicture;

      expect(widget.colorFilter, isNull);
    });

    test('the other arguments still reach the SvgPicture', () {
      // Guards against a future edit that wires the filter but drops
      // something else while rearranging the argument list.
      final widget = assetSvdImageWidget(
        image: 'assets/svg/anything.svg',
        width: 24,
        height: 25,
        fit: BoxFit.fill,
      ) as SvgPicture;

      expect(widget.width, 24);
      expect(widget.height, 25);
      expect(widget.fit, BoxFit.fill);
    });

    test('BoxFit.contain is the default fit', () {
      final widget = assetSvdImageWidget(
        image: 'assets/svg/anything.svg',
      ) as SvgPicture;

      expect(widget.fit, BoxFit.contain);
    });
  });

  group('assetSvdImageWidget guards its image argument', () {
    test('a null image yields an empty box instead of throwing', () {
      // SvgPicture.asset(null) is not expressible, and several call sites pass
      // a nullable model field straight through.
      expect(assetSvdImageWidget(image: null), isA<SizedBox>());
    });

    test('an empty image yields an empty box instead of throwing', () {
      // An empty asset key reaches the asset bundle and throws at paint time,
      // which in a list builder takes the whole screen down.
      expect(assetSvdImageWidget(image: ''), isA<SizedBox>());
    });
  });
}
