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
      color: AppColor.cBackGround,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: isDark
            ? AppColor.cFont.withOpacity(0.06)
            : Colors.transparent,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColor.cShadow.withOpacity(
            isDark ? 0.10 : 0.25,
          ),
          offset: const Offset(0, 4),
          blurRadius: 12,
        ),
      ],
    ),
    child: Column(
      children: [
        // English
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

        // Arabic
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

// ============================================================
// LANGUAGE OPTION
// ============================================================

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
              ? AppColor.cLabel.withOpacity(0.08)
              : isDark
              ? AppColor.cFont.withOpacity(0.025)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColor.cLabel.withOpacity(0.30)
                : isDark
                ? AppColor.cFont.withOpacity(0.05)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            // =================================================
            // FLAG
            // =================================================

            Text(
              flag,
              style: const TextStyle(
                fontSize: 22,
              ),
            ),

            const SizedBox(width: 12),

            // =================================================
            // LANGUAGE
            // =================================================

            Expanded(
              child: Text(
                title,
                style: pRegular14.copyWith(
                  color: selected
                      ? AppColor.cLabel
                      : AppColor.cFont,
                ),
              ),
            ),

            // =================================================
            // CHECK
            // =================================================

            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? AppColor.cLabel
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppColor.cLabel
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