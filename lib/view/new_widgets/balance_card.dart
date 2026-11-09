import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/wallet/wallet_controller.dart';
import '../../utils/colors.dart';
import '../../utils/store_syria_brand.dart';
import '../../utils/images.dart';
import '../widget/icon_and_image.dart';
import 'balance_bottomsheet.dart';

Widget balanceCard({
  required bool isDark,
  required WalletController controller,
  required BuildContext context,
}) {
  return Obx(() {
    // R7-N3. `balance` used to be read HERE, outside the Obx builder, which
    // broke it twice over. GetX only registers an observable as a dependency
    // when it is read inside the builder, and a local captured outside the
    // closure is never re-evaluated when the closure re-runs -- so this was a
    // snapshot taken once, at widget-construction time, and frozen.
    final String balance = controller.availableBalance.value;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.themeNavyBlueColor.withValues(alpha: 0.3)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // P2.5-FLUTTER-WALLET-CARD. These used to be
          // `[themeNavyBlueColor, themeNavyBlueColor, themeGreenColor]`, which READS as
          // "navy, navy, cyan" and is not what it evaluates to. `AppColor.themeNavyBlueColor` is
          // a mutable static the active theme reassigns, and in DARK mode it becomes
          // `DarkThemeColor.cPrimary` — `StoreSyriaBrand.cyanOnDark`. So the dark card collapsed
          // to a flat cyan slab, the white balance on it measured **2.09:1**, and the filled
          // button drew cyan on cyan at **1.03:1**: the merchant's primary wallet action was
          // invisible. See `test/a11y/balance_card_contrast_test.dart`.
          //
          // Named explicitly now, so the gradient cannot be re-pointed by a theme switch. Light
          // is unchanged — `themeNavyBlueColor`/`themeGreenColor` already resolved to exactly
          // these two there. Dark starts from the SURFACE navy, which carries white at 16.05:1.
          colors: balanceCardGradient(isDark: isDark),
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color : AppColor.cBlack.withValues(alpha: 0.2),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'current_balance'.tr,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              assetSvdImageWidget(
                image: DefaultImages.walletImg,
                width: 27.w,
                height: 27.h,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                // `balance == null` was dead: `balance` is a non-nullable
                // String, so the analyzer reported `unnecessary_null_comparison`.
                // The surviving `isEmpty` test never fired either, because
                // availableBalance is seeded with '0' (wallet_controller.dart:21),
                // which is not empty -- so the spinner was unreachable and a
                // merchant was shown a hard "0" balance while the wallet was
                // still loading. A zero balance the merchant does not actually
                // have is worse than a spinner, so the load state now drives it.
                child: controller.isLoading.value || balance.isEmpty ?
                CircularProgressIndicator(color: Colors.grey,strokeWidth: 2.w,) :
                Text(
                  balance,
                  style:  TextStyle(
                    color: Colors.white,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  controller.currencySymbol.value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          Row(
            children: [
              Expanded(
                child: cardButton(
                  label: 'withdraw'.tr,
                  filled: false,
                  onTap: () {
                    showBalanceSheet(
                        isAdd: false,
                        isDark: isDark,
                        context: context,
                        controller: controller);
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: cardButton(
                  label: 'add_funds'.tr,
                  filled: true,
                  onTap: () {
                    showBalanceSheet(
                        isAdd: true,
                        isDark: isDark,
                        context: context,
                        controller: controller
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  });
}

/// The balance card's background, pinned per theme rather than read from the mutable
/// `AppColor` statics. See the note at the gradient for why that distinction mattered.
List<Color> balanceCardGradient({required bool isDark}) => isDark
    ? <Color>[
        DarkThemeColor.cBottomNavyBlueColor,
        DarkThemeColor.cBottomNavyBlueColor,
        DarkThemeColor.cAccent,
      ]
    : <Color>[
        LightThemeColor.cPrimary,
        LightThemeColor.cPrimary,
        LightThemeColor.cAccent,
      ];

/// The two action colours. Deliberately NOT theme-dependent: both buttons are solid surfaces, so
/// each label is measured against its OWN fill — 13.94:1, the same number in both themes and
/// wherever along the gradient the button lands. A label measured against the card instead drifts
/// with the gradient, which is how the white "Withdraw" label ended up at 2.05:1 in dark mode and
/// 4.05:1 in light.
const Color kBalanceActionDark = StoreSyriaBrand.navy;
const Color kBalanceActionLight = Color(0xFFFFFFFF);

Widget cardButton({
  required String label,
  required bool filled,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        height: 46.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // SOLID, AND OPAQUE. The filled variant used to be `themeGreenColor` at **alpha 0.7**
          // over the card, so its label's contrast was a function of the gradient underneath —
          // cyan over cyan, 1.03:1, in dark mode. The outlined variant was fully transparent, so
          // its white label sat straight on the gradient and read 2.05:1 there.
          //
          // Each button now carries its own opaque fill and a border in the OPPOSITE tone. That
          // second part is what keeps the control perceivable (WCAG 2.1 SC 1.4.11) at every point
          // of a gradient no single colour can clear 3:1 against: where the fill disappears into
          // the card, the border does not, and vice versa.
          color: filled ? kBalanceActionDark : kBalanceActionLight,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: filled ? kBalanceActionLight : kBalanceActionDark,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                // The label always contrasts with its OWN fill, not with the card: 13.94:1 either
                // way, in both themes.
                color: filled ? kBalanceActionLight : kBalanceActionDark,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
