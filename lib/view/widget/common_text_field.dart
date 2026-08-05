// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/colors.dart';
import '../../utils/text_style.dart';
import 'common_space_divider_widget.dart';
import 'icon_and_image.dart';

class CommonTextField extends StatefulWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final bool autocorrect;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final String? labelText;
  final Color? color;
  final String? hintText;
  final String? prefix;
  final Widget? suffix;
  final String obscuringCharacter;

  const CommonTextField({
    super.key,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.readOnly = false,
    this.autofocus = false,
    this.obscureText = false,
    this.autocorrect = true,
    this.onChanged,
    this.onTap,
    this.validator,
    this.labelText,
    this.hintText,
    this.prefix,
    this.suffix,
    this.focusNode,
    this.obscuringCharacter = "*",
    this.color,
  });

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  late FocusNode _focusNode;
  ModalRoute? _modalRoute;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void didUpdateWidget(covariant CommonTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChange);
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newRoute = ModalRoute.of(context);
    if (_modalRoute != newRoute) {
      _modalRoute?.secondaryAnimation?.removeListener(_onRouteAnimationChange);
      _modalRoute = newRoute;
      _modalRoute?.secondaryAnimation?.addListener(_onRouteAnimationChange);
    }
  }

  void _onRouteAnimationChange() {
    final secondaryAnimation = _modalRoute?.secondaryAnimation;
    if (secondaryAnimation == null) return;

    if (secondaryAnimation.value > 0) {
      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
      }
      _focusNode.canRequestFocus = false;
    } else {
      _focusNode.canRequestFocus = true;
    }
  }

  @override
  void dispose() {
    _modalRoute?.secondaryAnimation?.removeListener(_onRouteAnimationChange);
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFocused = _focusNode.hasFocus;

    final borderColor =
    isDark ? Colors.white24 : const Color(0xffD8DEE9);

    final fillColor =
    isDark ? const Color(0xff1F2937) : Colors.white;

    final textColor =
    isDark ? Colors.white : const Color(0xff1E293B);

    final hintColor =
    isDark ? Colors.white54 : Colors.grey.shade500;

    final labelColor =
    isDark ? Colors.white70 : Colors.grey.shade700;

    final iconBackground =
    isDark ? const Color(0xff2C3748) : const Color(0xffF5F7FA);

    final iconColor = isFocused
        ? AppColor.themeNavyBlueColor
        : (isDark ? Colors.white70 : Colors.grey.shade700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null &&
            widget.labelText!.isNotEmpty) ...[
          Text(
            widget.labelText!,
            style: pMedium12.copyWith(
              color: labelColor,
            ),
          ),
          verticalSpace(8.h),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          readOnly: widget.readOnly,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          obscureText: widget.obscureText,
          obscuringCharacter: widget.obscuringCharacter,
          autocorrect: widget.autocorrect,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          cursorColor: AppColor.themeNavyBlueColor,
          style: pMedium14.copyWith(
            color: textColor,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: pMedium14.copyWith(
              color: hintColor,
            ),
            errorStyle: pMedium12.copyWith(
              color: Colors.red,
            ),

            filled: true,
            fillColor: widget.color ?? fillColor,

            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),

            prefixIcon: widget.prefix == null
                ? null
                : Padding(
              padding: EdgeInsets.only(
                left: 8.w,
                right: 8.w,
              ),
              child: CircleAvatar(
                radius: 18.r,
                backgroundColor: isFocused
                    ? AppColor.themeNavyBlueColor
                    .withOpacity(.12)
                    : iconBackground,
                child: assetSvdImageWidget(
                  image: widget.prefix,
                  width: 20.w,
                  height: 20.h,
                  colorFilter: ColorFilter.mode(
                    iconColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            suffixIcon: widget.suffix,

            prefixIconConstraints: BoxConstraints(
              minWidth: 56.w,
              maxWidth: 56.w,
            ),

            suffixIconConstraints: BoxConstraints(
              minWidth: 48.w,
              maxWidth: 48.w,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40.r),
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40.r),
              borderSide: BorderSide(
                color: AppColor.themeNavyBlueColor,
                width: 1.5.w,
              ),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40.r),
              borderSide: BorderSide(
                color: Colors.red,
              ),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40.r),
              borderSide: BorderSide(
                color: Colors.red,
                width: 1.5.w,
              ),
            ),

            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(
                color: borderColor.withOpacity(.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}