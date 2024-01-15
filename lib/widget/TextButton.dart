import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';

class textButton extends StatelessWidget {
  const textButton(
      {super.key,
      required this.onPress,
      required this.text,
      this.width,
      required this.height,
      required this.buttonRadius,
      required this.textSize,
      required this.textfont,
      required this.textcolor,
      required this.icon,
      this.Gradient_Color,
      this.fontWeight = FontWeight.w300,
      this.begin = Alignment.topCenter,
      this.end = Alignment.bottomCenter,
      this.Gradient_Color2,
      this.iconspace,
      this.iconcolor,
      this.ButtonColor,
      this.sizeWidth,
      this.padding});

  final Function() onPress;

  final double? buttonRadius;
  final Color? Gradient_Color;
  final Color? Gradient_Color2;
  final Color? ButtonColor;
  final double? width;
  final double? height;
  final double? padding;
  final String text;
  final String? textfont;
  final double? textSize;
  final Color? textcolor;
  final double? iconspace;
  final String icon;
  final Color? iconcolor;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final FontWeight fontWeight;
  final double? sizeWidth;

  LinearGradient get gradiant => LinearGradient(
        begin: begin,
        end: end,
        colors: [
          Gradient_Color!,
          Gradient_Color2!,
        ],
      );

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      width: width ?? size.width * 1,
      height: height ?? AppSize.h60,
      padding: EdgeInsets.all(padding ?? 0.0),
      decoration: (ButtonColor == null)
          ? BoxDecoration(
              borderRadius:
                  BorderRadius.all(Radius.circular(buttonRadius ?? 19)),
              gradient: gradiant,
            )
          : BoxDecoration(
              borderRadius:
                  BorderRadius.all(Radius.circular(buttonRadius ?? 19)),
              color: ButtonColor,
            ),
      child: MaterialButton(
        onPressed: onPress,
        // color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius ?? AppRadius.r19),
        ),
        child: (icon.isEmpty)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: textfont,
                      fontWeight: fontWeight,
                      fontStyle: FontStyle.normal,
                      color: textcolor,
                      fontSize: textSize ?? AppFontsSizeManager.s15,
                      letterSpacing: AppConstants.letterSpacing,
                    ),
                  ),
                  //(icon.isNotEmpty)?SizedBox(): SizedBox(width: 16.w), ImageIcon(AssetImage(icon),color: AppColors.white),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: textfont,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.normal,
                      color: textcolor,
                      fontSize: textSize ?? AppFontsSizeManager.s15.sp,
                    ),
                  ),
                  SizedBox(
                    width: sizeWidth ?? 0,
                  ),
                  //SizedBox(width: AppSize.w16.w),
                  ImageIcon(
                    AssetImage(icon),
                    color: iconcolor ?? AppColors.white,
                    size: AppSize.w14,
                  ),
                ],
              ),
      ),
    );
  }
}
