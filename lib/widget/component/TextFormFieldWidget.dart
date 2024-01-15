import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';

import '../../config/colorsFile.dart';
import '../../localization/localization_methods.dart';

class TextFormFieldWidget extends StatelessWidget {
  const TextFormFieldWidget({
    this.name,
    this.hintTextName,
    required this.controller,
    this.obscureText = false,
    this.icon,
    this.lines,
    this.isNumber,
    this.labelColor = AppColors.pink,
    required this.context,
    this.verticalPadding = AppPadding.p21_3,
    this.horizontalPadding = AppPadding.p10,
    required this.onTap,
    this.fontSize = AppFontsSizeManager.s21,
    this.radius = AppRadius.r10_6,
    this.fontColor = AppColors.darkGrey,
    this.fontFamily,
    this.formatter,
    this.validator,
    this.isReadOnly,
    this.focusNode,
    this.textDirection,
    this.fontSize1,
    this.borderColor,
    this.colorInput,
    this.heightTextFieled,
    this.textAlign = TextAlign.start,
  });

  final TextEditingController controller;
  final String? name;
  final String? hintTextName;
  final bool? obscureText;
  final bool? isNumber;
  final String? icon;
  final int? lines;
  final bool? isReadOnly;
  final BuildContext context;
  final Color labelColor;
  final double verticalPadding;
  final double horizontalPadding;
  final Function onTap;
  final double fontSize;
  final Color fontColor;
  final double radius;
  final String? fontFamily;
  final List<TextInputFormatter>? formatter;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextDirection? textDirection;
  final double? fontSize1;
  final Color? borderColor;
  final TextAlign textAlign;
  final Color? colorInput;
  final double? heightTextFieled;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: heightTextFieled ?? 75.h,
      child: TextFormField(
        // textAlign: textAlign,
        focusNode: focusNode,

        textDirection: textDirection,
        inputFormatters: formatter,
        //textAlign: TextAlign.start,
        onTap: () {
          onTap();
        },

        controller: controller,
        obscureText: obscureText == null ? false : obscureText!,
        textAlignVertical: TextAlignVertical.center,
        validator: validator ??
            (String? val) {
              if (val!.trim().isEmpty) {
                return 'This field is required';
              }
              return null;
            },
        enableInteractiveSelection: true,
        style: TextStyle(
            fontSize: AppFontsSizeManager.s21_3.sp,
            color: colorInput ?? AppColors.black),
        maxLines: lines == null ? 1 : lines,
        readOnly: isReadOnly == null ? false : true,
        textInputAction:
            lines == null ? TextInputAction.done : TextInputAction.newline,
        keyboardType: lines == null
            ? isNumber != null
                ? TextInputType.number
                : TextInputType.text
            : TextInputType.multiline,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
              vertical: verticalPadding.h, horizontal: horizontalPadding.w),
          errorStyle: style(size),
          hintText: hintTextName,
          hintStyle: hintText(size),
          prefixIcon: icon == null
              ? null
              : Image.asset(
                  'assets/icons/' + icon!,
                  width: AppSize.w14,
                  height: AppSize.h12,
                ),
          prefixIconConstraints: BoxConstraints(
            minWidth: AppSize.w50,
          ),
          labelText: name,
          labelStyle: TextStyle(
            fontFamily: fontFamily ?? getTranslated(context, 'Ithra'),
            fontSize: fontSize1 ?? AppFontsSizeManager.s21_3.sp,
            color: labelColor,
            fontWeight: FontWeight.bold,
          ),
          enabledBorder: new OutlineInputBorder(
            borderSide: BorderSide(
                width: AppSize.w0_5, color: borderColor ?? AppColors.grey3),
            borderRadius: BorderRadius.circular(radius.r),
          ),
          focusedBorder: new OutlineInputBorder(
            borderSide:
                BorderSide(width: AppSize.w0_5, color: AppColors.warmPurple4),
            borderRadius: BorderRadius.circular(radius.r),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.grey3),
            borderRadius: BorderRadius.circular(radius.r),
          ),
        ),
      ),
    );
  }

  TextStyle style(Size size) {
    return TextStyle(
        fontFamily: getTranslated(context, 'Ithra'),
        fontSize: fontSize.sp,
        color: fontColor,
        // height: 0.1.w,
        fontWeight: FontWeight.normal);
  }

  TextStyle hintText(Size size) {
    return TextStyle(
        fontSize: AppFontsSizeManager.s21_3.sp,
        color: AppColors.grey,
        fontFamily: getTranslated(context, 'Ithralight'),
        // height: 0.1.w,
        fontWeight: FontWeight.normal);
  }
}
