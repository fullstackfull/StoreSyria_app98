import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

Widget productNetworkImage({
  required String imageUrl,
  required Color backgroundColor,
  required Color iconColor,
  required Color loadingColor,
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
}) {
  final url = imageUrl.trim();

  if (url.isEmpty) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor,
      child: Icon(Icons.image_outlined, color: iconColor),
    );
  }

  final cleanUrl = url.split('?').first.toLowerCase();
  final isSvg = cleanUrl.endsWith('.svg') || cleanUrl.contains('.svg/');

  if (isSvg) {
    return _RetrySvgNetwork(
      url: url,
      width: width,
      height: height,
      fit: fit,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      loadingColor: loadingColor,
    );
  }

  return CachedNetworkImage(
    imageUrl: url,
    width: width,
    height: height,
    fit: fit,
    placeholder: (_, __) => Container(
      width: width,
      height: height,
      color: backgroundColor,
      child: Center(
        child: SizedBox(
          width: 18.w,
          height: 18.w,
          child: CircularProgressIndicator(strokeWidth: 1.5, color: loadingColor),
        ),
      ),
    ),
    errorWidget: (_, __, ___) => Container(
      width: width,
      height: height,
      color: backgroundColor,
      child: Icon(Icons.image_not_supported_outlined, color: iconColor),
    ),
  );
}

/// SVG loader مع إعادة محاولة + مسك الأخطاء بدل ما تنكسر
class _RetrySvgNetwork extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color backgroundColor;
  final Color iconColor;
  final Color loadingColor;

  const _RetrySvgNetwork({
    required this.url,
    required this.width,
    required this.height,
    required this.fit,
    required this.backgroundColor,
    required this.iconColor,
    required this.loadingColor,
  });

  @override
  State<_RetrySvgNetwork> createState() => _RetrySvgNetworkState();
}

class _RetrySvgNetworkState extends State<_RetrySvgNetwork> {
  late Future<String?> _svgFuture;

  @override
  void initState() {
    super.initState();
    _svgFuture = _fetchSvg();
  }

  Future<String?> _fetchSvg({int attempt = 1}) async {
    try {
      final response = await http
          .get(Uri.parse(widget.url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return response.body;
      }
      return null;
    } catch (e) {
      if (attempt < 2) {
        await Future.delayed(const Duration(milliseconds: 500));
        return _fetchSvg(attempt: attempt + 1);
      }
      return null; // فشل نهائياً بعد المحاولات
    }
  }

  Widget _placeholder() => Container(
    width: widget.width,
    height: widget.height,
    color: widget.backgroundColor,
    child: Center(
      child: SizedBox(
        width: 18.w,
        height: 18.w,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: widget.loadingColor,
        ),
      ),
    ),
  );

  Widget _errorWidget() => Container(
    width: widget.width,
    height: widget.height,
    color: widget.backgroundColor,
    child: Icon(Icons.image_not_supported_outlined, color: widget.iconColor),
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _svgFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _placeholder();
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return _errorWidget();
        }
        try {
          return SvgPicture.string(
            snapshot.data!,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            placeholderBuilder: (_) => _placeholder(),
          );
        } catch (_) {
          return _errorWidget();
        }
      },
    );
  }
}