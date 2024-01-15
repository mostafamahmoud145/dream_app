import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/methods/convert_pt_to_px.dart';

import '../../config/app_fonts.dart';
import '../../config/app_values.dart';
import '../../config/colorsFile.dart';
import '../../localization/localization_methods.dart';

class DaysButton extends StatelessWidget {
  DaysButton(
      {Key? key,
      required this.text,
      required this.function,
      this.raduis,
      this.width,
      this.height,
      required this.available,
      this.fontSizeText,
      this.fontFamiltType,
      this.isSelected = false})
      : super(key: key);
  Function function;
  bool isSelected;
  bool available;
  String text;
  double? height;
  double? width;
  double? raduis;
  double? fontSizeText;
  String? fontFamiltType;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: AppColors.green.withOpacity(0.6),
      onTap: () {
        if (available) {
          function();
        }
      },
      child: Container(
        height: height == null ? convertPtToPx(AppSize.h40).h : height,
        width: width == null ? convertPtToPx(AppSize.w111).w : width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: available == false
              ? AppColors.lightGrey6
              : (isSelected ? AppColors.pink : AppColors.white),
          borderRadius: BorderRadius.circular(raduis ?? AppRadius.r10_6.r),
          border: Border.all(
              color: available ? AppColors.pink : AppColors.grey,
              width: AppSize.w1_7.w),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: AppFontsWeightManager.bold,
            fontFamily: fontFamiltType ?? getTranslated(context, 'Ithra'),
            color: available == false
                ? AppColors.grey
                : (isSelected ? AppColors.white : AppColors.pink),
            fontSize: convertPtToPx(fontSizeText ?? AppFontsSizeManager.s14).sp,
          ),
        ),
      ),
    );
  }
}
