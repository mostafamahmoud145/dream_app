import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';

class TabBarButton extends StatelessWidget {
  const TabBarButton({
    Key? key,
    required this.isSelected,
    required this.function,
    this.activeColor,
    this.notActiveColor = Colors.transparent,
    this.height = AppConstants.tabBarButtonHeight,
    this.width = AppConstants.tabBarButtonWidth,
    required this.text,
    this.activeTextColor,
    this.notActiveTextColor = AppColors.pink,
    this.textSize = AppFontsSizeManager.s21_3,
    this.fontFamily,
    this.fontWeight = FontWeight.bold,
  }) : super(key: key);

  final bool isSelected;
  final Function function;
  final Color? activeColor;
  final Color? notActiveColor;
  final Color? activeTextColor;
  final Color? notActiveTextColor;
  final String text;
  final double width;
  final double height;

  final double textSize;
  final FontWeight? fontWeight;
  final String? fontFamily;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Expanded(
      child: InkWell(
        onTap: () async {
          function();
        },
        child: Container(
          width: AppSize.w254_6.w, // convertPtToPx(width.w),
          height: AppSize.h50_6.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:
                isSelected ? activeColor ?? AppColors.linear8 : notActiveColor,
            borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 0.0,
              fontFamily: fontFamily ?? getTranslated(context, 'Ithra'),
              color: isSelected
                  ? activeTextColor == null
                      ? AppColors.tabColor
                      : activeTextColor
                  : notActiveTextColor,
              fontSize: AppFontsSizeManager.s21_3.sp,
              fontWeight: fontWeight,
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
      ),
    );
  }
}
