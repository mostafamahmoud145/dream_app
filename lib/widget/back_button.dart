import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/methods/convert_pt_to_px.dart';

import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../config/colorsFile.dart';
import '../localization/localization_methods.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({Key? key}) : super(key: key);
  // String lang

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey4),
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
        ),
        // shadowcolor: AppColors.warmPurple,

        child: Center(
          child: Image.asset(
            getTranslated(context, "lang") == "ar"
                ? AssetsManager.purple_right_arrowPath
                : AssetsManager.purple_left_arrowPath,
            height: AppSize.h32.h,
            width: AppSize.w32.w,
          ),
        ),
        // iconcolor: AppColors.linear2,

        width: convertPtToPx(AppSize.w38).w,
        height: convertPtToPx(AppSize.w38).w,
      ),
    );

    // IconButton1(
    //   radius: AppRadius.r10_6.r,
    //   color: AppColors.white,
    //   // shadowcolor: AppColors.warmPurple,
    //   iconsize: 30,
    //   icon: getTranslated(context, "lang") == "ar"
    //       ? AssetsManager.purple_right_arrowPath
    //       : AssetsManager.purple_left_arrowPath,
    //   iconcolor: AppColors.linear2,
    //   onPress: () {
    //     Navigator.pop(context);
    //   },
    //   width: convertPtToPx(AppSize.w38).w,
    //   height: convertPtToPx(AppSize.w38).w,
    // );
  }
}
