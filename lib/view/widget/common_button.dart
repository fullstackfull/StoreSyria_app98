// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../../utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';

class CommonButton extends StatelessWidget {
  final String? title;
  final double? height;
  final double? width;
  final double? fontSize;
  final bool isLoading; // هذا المتغير هو المفتاح
  final Function()? onPressed;
  final Color? bColor;
  final Color? btnColor;
  final Color? textColor;

  CommonButton({
    Key? key,
    this.title,
    this.height,
    this.width,
    this.onPressed,
    this.bColor,
    this.btnColor,
    this.textColor,
    this.fontSize,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // P2.5-FLUTTER-BTN-DISABLED. TWO THINGS THIS BUTTON DID NOT SAY.
    //
    // 1. A `CommonButton` with `onPressed: null` painted the full brand blue, showed its white
    //    label, and silently did nothing when tapped -- indistinguishable from one that works.
    //    `onPressed` is nullable BY DESIGN, so that state is reachable the moment any call site
    //    disables a button during validation or a permission check. Found by rendering the
    //    component gallery: the "disabled (no handler)" specimen matched the "idle" one exactly.
    //    LATENT, not live -- all six call sites in lib/ pass a handler today.
    //
    // 2. It was a `GestureDetector` wrapping a `Container`, which carries NO button semantics at
    //    all. A screen reader announced the label as plain text, in BOTH states, so "this is a
    //    button" and "this button is unavailable" were equally unsaid. Dimming alone would have
    //    fixed only the half a sighted merchant can see.
    //
    // `isLoading` is deliberately not folded into `isInert` for the OPACITY: it already has its
    // own clear state, a spinner in place of the label, and its own 0.7 fade below. It does
    // suppress the tap, so it counts as not-enabled for semantics.
    final bool isInert = onPressed == null;
    final bool isTappable = !isLoading && !isInert;

    return Semantics(
      button: true,
      enabled: isTappable,
      label: title,
      child: AnimatedOpacity(
        // 0.5 is the upper end of the 0.38-0.5 disabled range: dim enough to read as unavailable,
        // light enough that the label stays legible, which a disabled control still needs.
        opacity: isInert ? 0.5 : (isLoading ? 0.7 : 1.0),
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          // تعطيل الضغط تماماً إذا كان يحمل
          onTap: isTappable ? onPressed : null,
          child: Container(
          width: width ?? Get.width,
          // P2.5-D-01. 48 is Material's kMinInteractiveDimension. MEASURED by rendering
          // this widget: it was 42.0dp -- below Material's 48, and below Apple HIG's 44.
          // All SIX shared buttons in this file were under the minimum; the newer AppButton
          // (app_dialog.dart) already uses 48, so this was an internal inconsistency as much
          // as an accessibility gap. Guarded by test/a11y/tap_target_size_test.dart.
          height: height ?? 48,
          decoration: BoxDecoration(
            color: btnColor ?? AppColor.themeNavyBlueColor,
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: bColor ?? AppColor.cTransparent),
          ),
          padding: EdgeInsets.symmetric(horizontal: Get.width * 0.1),
          child: Center(
            child: isLoading
                ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(textColor ?? AppColor.cWhite),
              ),
            )
                : Text(
              title ?? '',
              style: pBold14.copyWith(
                  color: textColor ?? AppColor.cWhite,
                  fontSize: fontSize ?? 14
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ),
        ),
      ),
    );
  }
}
class CommonIconButton extends StatelessWidget {
  final String? title;
  final double? height;
  final double? width;
  final double? radius;
  final String? iconData;
  final Function()? onPressed;
  final Color? bColor;
  final Color? btnColor;
  final Color? textColor;

  CommonIconButton({
    Key? key,
    this.title,
    this.height,
    this.width,
    this.onPressed,
    this.bColor,
    this.btnColor,
    this.iconData,
    this.radius,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? Get.width,
        // height: height ?? Get.height * 0.07,
        // P2.5-D-01. 48 is Material's kMinInteractiveDimension. MEASURED by rendering
        // this widget: it was 43.0dp -- below Material's 48, and below Apple HIG's 44.
        // All SIX shared buttons in this file were under the minimum; the newer AppButton
        // (app_dialog.dart) already uses 48, so this was an internal inconsistency as much
        // as an accessibility gap. Guarded by test/a11y/tap_target_size_test.dart.
        height: height ?? 48,
        decoration: BoxDecoration(
            color: btnColor ?? AppColor.themeNavyBlueColor,
            borderRadius: BorderRadius.circular(radius ?? 35),
            border: Border.all(color: bColor ?? AppColor.cTransparent, width: 1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // P2.5-R-04. `iconData` is declared `String?` and was dereferenced `iconData!`, so a
            // caller who took the signature at its word got "Null check operator used on a null
            // value" at build time. The icon and the gap it needs are now conditional together --
            // a button with no icon must not keep the icon's spacing. When an icon IS passed the
            // tree is byte-for-byte what it was, which is what makes this safe for all 145
            // existing call sites.
            if (iconData != null) ...[
              assetSvdImageWidget(
                image: iconData!,
              ),
              horizontalSpace(10),
            ],
            Text(
              title ?? '',
              style: pBold12.copyWith(color: textColor ?? AppColor.cWhite),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SmallCommonIconButton extends StatelessWidget {
  final String? title;
  final double? height;
  final double? width;
  final double? radius;
  final String? iconData;
  final Function()? onPressed;
  final Color? bColor;
  final Color? btnColor;
  final Color? textColor;
  final Color? circleColor;

  SmallCommonIconButton({
    Key? key,
    this.title,
    this.height,
    this.width,
    this.onPressed,
    this.bColor,
    this.btnColor,
    this.iconData,
    this.radius,
    this.textColor,
    this.circleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // P2.5-D-01. THIS ONE KEEPS ITS SIZE AND GAINS ITS TAP TARGET, which is the opposite
    // decision from the five buttons around it and is deliberate. It is called "Small" and it
    // is small on purpose: measured at 35.0dp, below all three thresholds (Material 48,
    // Apple HIG 44, and WCAG 2.2 AA 2.5.8's 24 floor). Enlarging the painted box would overturn
    // a visual decision somebody made; enlarging the HIT AREA fixes the accessibility defect and
    // changes nothing a merchant sees.
    //
    // `HitTestBehavior.opaque` is what makes the transparent margin tappable. Without it the
    // gesture only fires over the painted child and the SizedBox is decoration -- which is the
    // way this fix is usually written wrong, and it looks identical on screen.
    // Guarded by test/a11y/tap_target_size_test.dart.
    final double paintedHeight = height ?? 35;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: SizedBox(
        height: paintedHeight > kMinInteractiveDimension
            ? paintedHeight
            : kMinInteractiveDimension,
        child: Center(
          child: Container(
        // width: width ?? 180,
        height: paintedHeight,
        decoration: BoxDecoration(
            color: btnColor ?? AppColor.themeNavyBlueColor,
            borderRadius: BorderRadius.circular(radius ?? 35),
            border: Border.all(color: bColor ?? AppColor.cTransparent, width: 1)),
        // Directional: the Row is mainAxisAlignment.start with an icon circle then a label, so
        // in Arabic the content runs right-to-left and this trailing padding belongs on the END.
        // Physical `right` put it on the icon's side in RTL.
        padding: EdgeInsetsDirectional.only(top: 3, bottom: 3, end: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // P2.5-R-04 -- see CommonIconButton above. The circular plate goes with the icon:
            // an empty 35dp circle beside a label would be a worse answer than no icon at all.
            if (iconData != null) ...[
              Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(color: circleColor ?? AppColor.cWhite, shape: BoxShape.circle),
                padding: EdgeInsets.all(3),
                child: assetSvdImageWidget(
                  image: iconData!,
                ),
              ),
              horizontalSpace(10),
            ],
            Text(
              title ?? '',
              style: pMedium12.copyWith(color: textColor ?? AppColor.cWhiteFont),
              textAlign: TextAlign.center,
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }
}

class CommonBorderButton extends StatelessWidget {
  final String? title;
  final double? height;
  final double? width;
  final double? radius;
  final Function()? onPressed;
  final Color? bColor;
  final Color? btnColor;
  final Color? textColor;

  CommonBorderButton({
    Key? key,
    this.title,
    this.height,
    this.width,
    this.onPressed,
    this.bColor,
    this.btnColor,
    this.radius,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? Get.width,
        // height: height ?? Get.height * 0.07,
        // P2.5-D-01. 48 is Material's kMinInteractiveDimension. MEASURED by rendering
        // this widget: it was 43.0dp -- below Material's 48, and below Apple HIG's 44.
        // All SIX shared buttons in this file were under the minimum; the newer AppButton
        // (app_dialog.dart) already uses 48, so this was an internal inconsistency as much
        // as an accessibility gap. Guarded by test/a11y/tap_target_size_test.dart.
        height: height ?? 48,
        decoration: BoxDecoration(
            color: btnColor ?? AppColor.cWhite,
            borderRadius: BorderRadius.circular(radius ?? 10),
            border: Border.all(color: bColor ?? AppColor.themeGreenColor, width: 1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title ?? '',
              style: pBold14.copyWith(color: textColor ?? AppColor.cText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class CommonIconBorderButton extends StatelessWidget {
  final String? title;
  final double? height;
  final double? width;
  final double? radius;
  final String? iconData;
  final Function()? onPressed;
  final Color? bColor;
  final Color? btnColor;
  final Color? textColor;

  CommonIconBorderButton({
    Key? key,
    this.title,
    this.height,
    this.width,
    this.onPressed,
    this.bColor,
    this.btnColor,
    this.iconData,
    this.radius,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? Get.width,
        // height: height ?? Get.height * 0.07,
        // P2.5-D-01. 48 is Material's kMinInteractiveDimension. MEASURED by rendering
        // this widget: it was 43.0dp -- below Material's 48, and below Apple HIG's 44.
        // All SIX shared buttons in this file were under the minimum; the newer AppButton
        // (app_dialog.dart) already uses 48, so this was an internal inconsistency as much
        // as an accessibility gap. Guarded by test/a11y/tap_target_size_test.dart.
        height: height ?? 48,
        decoration: BoxDecoration(
            color: btnColor ?? AppColor.cWhite,
            borderRadius: BorderRadius.circular(radius ?? 10),
            border: Border.all(color: bColor ?? AppColor.themeGreenColor, width: 1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title ?? '',
              style: pBold14.copyWith(color: textColor ?? AppColor.cText),
              textAlign: TextAlign.center,
            ),
            // P2.5-R-04 -- the icon trails the label here, so the gap leads it.
            if (iconData != null) ...[
              horizontalSpace(10),
              assetSvdImageWidget(
                image: iconData!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CommonSocialButton extends StatelessWidget {
  final String? title;
  final String? icon;
  final double? height;
  final double? width;
  final double? radius;
  final Color? btnColor;
  final Color? circleColor;
  final Color? iconColor;
  final Color? textColor;
  final Color? borderColor;
  final Function()? onPressed;

  CommonSocialButton(
      {Key? key,
      this.title,
      this.icon,
      this.height,
      this.width,
      this.onPressed,
      this.btnColor,
      this.radius,
      this.borderColor,
      this.iconColor,
      this.textColor,
      this.circleColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        // P2.5-D-01. 48 is Material's kMinInteractiveDimension. MEASURED by rendering
        // this widget: it was 45.0dp -- below Material's 48, and below Apple HIG's 44.
        // All SIX shared buttons in this file were under the minimum; the newer AppButton
        // (app_dialog.dart) already uses 48, so this was an internal inconsistency as much
        // as an accessibility gap. Guarded by test/a11y/tap_target_size_test.dart.
        height: height ?? 48,
        width: width ?? 272,
        decoration: BoxDecoration(
            color: btnColor ?? AppColor.themeGreenColor,
            borderRadius: BorderRadius.circular(radius ?? 64),
            border: Border.all(color: borderColor ?? AppColor.cTransparent)),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                    color: circleColor ?? AppColor.themeNavyBlueColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColor.cBorder, width: 1)),
                padding: const EdgeInsets.all(3),
                child: Center(
                  // P2.5-R-04 -- `icon` is `String?` here rather than `iconData`, and was
                  // force-unwrapped the same way. SizedBox.shrink() keeps the Expanded's flex
                  // slot, so an icon-less social button stays the same width as its siblings.
                  child: icon != null
                      ? assetSvdImageWidget(
                          image: icon!,
                        )
                      : const SizedBox.shrink(),
                )),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  title ?? '',
                  style: pMedium10.copyWith(color: textColor ?? AppColor.cFont),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: SizedBox(width: 0, height: 0),
            ),
          ],
        ),
      ),
    );
  }
}
