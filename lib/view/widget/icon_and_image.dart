// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/utils/colors.dart';

Widget assetSvdImageWidget({
  String? image,
  double? width,
  double? height,
  BoxFit? fit,
  Color? color,
  ColorFilter? colorFilter,
}) {
  if (image == null || image.isEmpty) {
    return SizedBox();
  }

  final ColorFilter? finalColorFilter = color != null
      ? ColorFilter.mode(color, BlendMode.srcIn)
      : colorFilter;

  return SvgPicture.asset(
    image,
    width: width,
    height: height,
    fit: fit ?? BoxFit.contain,
    // R7-N2. This was commented out while `finalColorFilter` above was still
    // being computed, so every caller that passed `color:` or `colorFilter:`
    // got an untinted SVG. Seven live call sites rely on the tint -- including
    // a white copy icon drawn on a coloured card, which rendered in its own
    // source colour and effectively disappeared. The analyzer only reported it
    // as `unused_local_variable`.
    colorFilter: finalColorFilter,
  );
}

Widget assetImageWidget({
  String? image,
  double? width,
  double? height,
  BoxFit? fit,
}) {
  if (image == null || image.isEmpty) {
    return const SizedBox.shrink();
  }

  return Image.asset(
    image,
    fit: fit ?? BoxFit.cover,
    height: height,
    width: width,
    errorBuilder: (context, error, stackTrace) {
      /* P2.5-WAVE-5. `Colors.grey` (#9E9E9E) measured 2.68:1 on the light background --
         below SC 1.4.11's 3:1 for a non-text graphic, and this icon IS the information:
         it is the only thing telling a merchant the image failed to load. It was also a
         fixed literal, so it could not follow the theme either way.

         `AppColor.cFont` is the existing secondary-text token and is ALREADY theme-aware:
         #66728C light / #A9B8D0 dark. Measured 4.83:1 on the light background and
         6.36-8.66:1 on all three dark surfaces. No new value is invented. */
      return Icon(Icons.image_not_supported, size: width ?? 24.w, color: AppColor.cFont);
    },
  );
}

Widget buildCachedNetworkImage({
  required String imageUrl,
  double? height,
  double? width,
  BoxFit? fit,
}) {
  final String formattedUrl = getImageUrl(imageUrl);

  final bool isValidUrl = formattedUrl.isNotEmpty &&
      (formattedUrl.startsWith('http') || formattedUrl.startsWith('/'));


  Widget fallbackImage() {
    return Center(child: SizedBox(child: Text("No Image Found".tr)));
  }

  if (!isValidUrl) {
    return fallbackImage();
  }

  return CachedNetworkImage(
    imageUrl: formattedUrl,
    height: height,
    width: width,
    fit: fit ?? BoxFit.cover,

    placeholder: (context, url) => SizedBox(
      height: height,
      width: width,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          // #BDBDBD measured 1.88:1 on the light background -- a spinner that is
          // nearly invisible is a loading state the merchant cannot see.
          valueColor: AlwaysStoppedAnimation<Color>(AppColor.cFont),
        ),
      ),
    ),

    errorWidget: (context, url, error) {
      return fallbackImage();
    },
  );
}