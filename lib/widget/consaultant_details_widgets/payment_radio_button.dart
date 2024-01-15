import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/methods/convert_pt_to_px.dart';

import '../../config/app_fonts.dart';
import '../../config/app_values.dart';
import '../../localization/localization_methods.dart';

class PaymentRadioButton extends StatelessWidget {
  const PaymentRadioButton(
      {Key? key,
      required this.isSelected,
      required this.function,
      required this.icons,
      this.colorEndIcon,
      this.text,
      this.endIconWidth = AppSize.w79,
      this.endPadding,
      required this.endIcon})
      : super(key: key);

  final List<String> icons;
  final String endIcon;
  final String? text;
  final bool isSelected;
  final Function function;
  final double endIconWidth;
  final double? endPadding;
  final Color? colorEndIcon;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: InkWell(
        onTap: () {
          function();
        },
        child: Container(
          height: convertPtToPx(AppSize.h63).h,
          padding: EdgeInsetsDirectional.only(
              start: convertPtToPx(AppSize.w24).w,
              end: endPadding == null
                  ? convertPtToPx(AppSize.w24).w
                  : endPadding!.w,
              top: convertPtToPx(AppSize.h9).h,
              bottom: convertPtToPx(AppSize.h9).h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(convertPtToPx(AppRadius.r8).r),
            border: Border.all(
                color: AppColors.lightGray,
                width: convertPtToPx(AppRadius.r1).r),
          ),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.s,
            // mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: AppColors.linear2,
              ),
              SizedBox(
                width: AppSize.w21_3.w,
              ),
              if (text != null)
                Expanded(
                  child: Text(
                    text!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: AppColors.linear2,
                      fontSize: convertPtToPx(AppFontsSizeManager.s16).sp,
                      fontFamily: getTranslated(context, "Ithra"),
                      fontWeight: AppFontsWeightManager.bold,
                    ),
                  ),
                ),
              if (text == null)
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) => isSvg(icons[index])
                            ? SvgPicture.asset(
                                icons[index],
                                width: AppSize.w34.w,
                                //  height: AppSize.h32.h,
                              )
                            : Image.asset(
                                icons[index],
                                width: AppSize.w34.w,
                                //  height: AppSize.h32.h,
                              ),
                        separatorBuilder: (context, index) => SizedBox(
                              width: convertPtToPx(AppSize.w4).w,
                            ),
                        itemCount: icons.length),
                  ),
                ),
              SizedBox(
                  width: convertPtToPx(
                AppSize.w16.w,
              )),
              isSvg(endIcon)
                  ? SvgPicture.asset(
                      endIcon,
                      width: endIconWidth.w,
                      //  height: AppSize.h32.h,
                    )
                  : Image.asset(
                      endIcon,
                      width: AppSize.w68.w,
                      color: colorEndIcon ?? AppColors.pink,
                      //  height: AppSize.h32.h,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  bool isSvg(String path) => path.split('.').last == 'svg' ? true : false;
}
