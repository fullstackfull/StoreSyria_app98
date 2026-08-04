// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/helper.dart';


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
      return Icon(Icons.image_not_supported, size: width ?? 24.w, color: Colors.grey);
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
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
        ),
      ),
    ),

    errorWidget: (context, url, error) {
      return fallbackImage();
    },
  );
}