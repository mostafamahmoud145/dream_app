import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/methods/convert_pt_to_px.dart';

import '../../config/app_fonts.dart';
import '../../config/colorsFile.dart';
import '../../localization/localization_methods.dart';

class OrderDetailsLine extends StatelessWidget {
  const OrderDetailsLine({
    Key? key,
    required this.header,
    required this.value,
    this.headerColor = AppColors.darkGrey,
    this.valueColor = AppColors.lightBlack,
    this.withPadding = true,
  }) : super(key: key);

  final Color headerColor;
  final Color valueColor;
  final String header, value;
  final withPadding;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          //  withPadding
          //     ?
          EdgeInsets.only(bottom: convertPtToPx(AppSize.h8).h),
      // : EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            header,
            style: TextStyle(
                height: AppSize.h1_38.h,
                color: headerColor,
                fontSize: AppFontsSizeManager.s18_6.sp,
                fontWeight: AppFontsWeightManager.bold,
                letterSpacing: convertPtToPx(-0.5),
                fontFamily: getTranslated(context, "Ithra")),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                height: AppSize.h1_38.h,
                color: valueColor,
                letterSpacing: convertPtToPx(-0.5),
                fontSize: AppFontsSizeManager.s18_6.sp,
                fontFamily: getTranslated(context, "Ithra"),
                fontWeight: AppFontsWeightManager.semiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
