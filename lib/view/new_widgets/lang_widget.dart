import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../translations/translation_service.dart';
import '../../utils/colors.dart';
import '../../utils/text_style.dart';

Widget languageSelector({
  required bool isArabic,
  required bool isDark,
  required VoidCallback onLanguageChanged,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: isDark
          ? DarkThemeColor.cCardBackground
          : AppColor.cBackGround,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: isDark
            ? DarkThemeColor.cBorder.withOpacity(0.7)
            : Colors.transparent,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColor.themeGreenColor.withOpacity(
            isDark ? 0.07 : 0.12,
          ),
          offset: const Offset(0, 2),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ],
    ),
    child: Column(
      children: [
        languageOption(
          title: 'english'.tr,
          flag: '🇬🇧',
          selected: !isArabic,
          isDark: isDark,
          onTap: () {
            if (isArabic) {
              TranslationService.changeLocale('en');
              onLanguageChanged();
            }
          },
        ),

        const SizedBox(height: 6),

        languageOption(
          title: 'arabic'.tr,
          flag: '🇸🇾',
          selected: isArabic,
          isDark: isDark,
          onTap: () {
            if (!isArabic) {
              TranslationService.changeLocale('ar');
              onLanguageChanged();
            }
          },
        ),
      ],
    ),
  );
}


Widget languageOption({
  required String title,
  required String flag,
  required bool selected,
  required bool isDark,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColor.themeGreenColor.withOpacity(
            isDark ? 0.12 : 0.08,
          )
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColor.themeGreenColor.withOpacity(
              isDark ? 0.35 : 0.30,
            )
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(
                fontSize: 22,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: pRegular14.copyWith(
                  color: selected
                      ? AppColor.themeGreenColor
                      : isDark
                      ? DarkThemeColor.cText
                      : AppColor.cText,
                ),
              ),
            ),

            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? AppColor.themeGreenColor
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppColor.themeGreenColor
                      : isDark
                      ? Colors.white.withOpacity(0.25)
                      : AppColor.cFont.withOpacity(0.25),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                Icons.check,
                size: 15,
                color: Colors.white,
              )
                  : null,
            ),
          ],
        ),
      ),
    ),
  );
}


Widget mainCard({
  required IconData icon,
  required String title,
  required String value,
  required bool isExpanded,
  required bool isDark,
  required VoidCallback onTap,
}) {
  final Color cardColor = isDark
      ? DarkThemeColor.cCardBackground
      : AppColor.cBackGround;

  final Color primaryText = isDark
      ? DarkThemeColor.cText
      : AppColor.cText;

  final Color secondaryText = isDark
      ? DarkThemeColor.cSecondaryText
      : AppColor.cFont;

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: isExpanded
                ? AppColor.themeGreenColor.withOpacity(
              isDark ? 0.40 : 0.30,
            )
                : isDark
                ? DarkThemeColor.cBorder.withOpacity(0.7)
                : Colors.transparent,
          ),

          boxShadow: [
            BoxShadow(
              color: AppColor.themeGreenColor.withOpacity(
                isDark ? 0.07 : 0.12,
              ),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColor.themeGreenColor.withOpacity(
                  isDark ? 0.12 : 0.08,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 24,
                  color: AppColor.themeGreenColor,
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: pRegular14.copyWith(
                      color: primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 5),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.themeGreenColor.withOpacity(
                        isDark ? 0.12 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      value,
                      style: pMedium10.copyWith(
                        color: isDark
                            ? AppColor.themeGreenColor
                            : AppColor.cLabel,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                key: ValueKey(isExpanded),
                size: 26,
                color: isDark
                    ? Colors.white.withOpacity(0.45)
                    : AppColor.cFont.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}