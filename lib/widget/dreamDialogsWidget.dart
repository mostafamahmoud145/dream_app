import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/methods/convert_pt_to_px.dart';
import 'package:grocery_store/widget/TextButton.dart';

import '../config/assets_manager.dart';

class DreamDialogsWidget extends StatelessWidget {
  String lang = 'ar';
  Widget dialogContent;
  double? padRight;
  double? padTop;
  double? padLeft;
  double? padBottom;
  double? raduis;

  DreamDialogsWidget({
    this.padRight,
    this.padTop,
    this.padLeft,
    this.padBottom,
    this.raduis,
    required this.dialogContent,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentTextStyle: TextStyle(
        fontFamily: lang == "ar"
            ? getTranslated(context, 'Ithra')
            : getTranslated(context, 'Montserrat'),
      ),
      contentPadding: EdgeInsets.only(
          right: padRight ?? convertPtToPx(AppPadding.p16.w),
          left: padLeft ?? convertPtToPx(AppPadding.p16.w),
          top: padTop ?? convertPtToPx(AppPadding.p16.h),
          bottom: padBottom ?? AppPadding.p32.h),
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(raduis ?? AppRadius.r16.r),
        ),
      ),
      scrollable: true,
      elevation: 0.0,
      content: dialogContent,
    );
  }
}

////////////////////////////////////
/// rate consult dialog ///
/// مؤقتا و سيتم نقله فى الاسكرين الخاصة بيه ///
///////////////////////////////////
class RateConsultDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DreamDialogsWidget(
      dialogContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AssetsManager.heartImagePath,
            width: AppSize.w64.w,
            height: AppSize.h56.h,
          ),
          SizedBox(
            height: AppSize.h16,
          ),
          Text(
            getTranslated(context, "Do you like the explanation?"),
            style: TextStyle(
              fontSize: AppFontsSizeManager.s21_3.sp,
            ),
          ),
          SizedBox(
            height: AppSize.h16,
          ),
          Text(
            getTranslated(context, "consultantRateDialogMessage"),
            style: TextStyle(
              fontSize: AppFontsSizeManager.s16.sp,
            ),
          ),
          SizedBox(
            height: AppSize.h16,
          ),
          textButton(
              onPress: () {},
              text: getTranslated(context, "share"),
              width: AppSize.w394.w,
              height: AppSize.h52.h,
              buttonRadius: 0,
              textSize: AppFontsSizeManager.s21_3.sp,
              textfont: '',
              textcolor: AppColors.white,
              icon: '',
              Gradient_Color: AppColors.pink,
              Gradient_Color2: AppColors.pink),
        ],
      ),
    );
  }
}

////////////////////////////////////
/// rate dream app dialog ///
/// مؤقتا و سيتم نقله فى الاسكرين الخاصة بيه ///
///////////////////////////////////
class RateDreamAppDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DreamDialogsWidget(
      dialogContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AssetsManager.heartImagePath,
            width: AppSize.w64.w,
            height: AppSize.h56.h,
          ),
          SizedBox(
            height: AppSize.h16,
          ),
          Text(
            getTranslated(context, "likeUsingDreamApp"),
            style: TextStyle(
              fontSize: AppFontsSizeManager.s21_3.sp,
            ),
          ),
          SizedBox(
            height: AppSize.h16,
          ),
          Text(
            getTranslated(context, "rateDreamAppDialogMessage"),
            style: TextStyle(
              fontSize: AppFontsSizeManager.s16.sp,
            ),
          ),
          SizedBox(
            height: AppSize.h16,
          ),
          Row(
            children: [
              textButton(
                  onPress: () {},
                  text: getTranslated(context, "rateUs"),
                  width: AppSize.w124.w,
                  height: AppSize.h33.h,
                  buttonRadius: 0,
                  textSize: AppFontsSizeManager.s12.sp,
                  textfont: '',
                  textcolor: AppColors.pureBlack,
                  icon: '',
                  Gradient_Color: AppColors.yellow,
                  Gradient_Color2: AppColors.yellow),
              SizedBox(
                width: AppSize.w40,
              ),
              textButton(
                  onPress: () {},
                  text: getTranslated(context, "share"),
                  width: AppSize.w124.w,
                  height: AppSize.h33.h,
                  buttonRadius: 0,
                  textSize: AppFontsSizeManager.s12.sp,
                  textfont: '',
                  textcolor: AppColors.white,
                  icon: '',
                  Gradient_Color: AppColors.pink,
                  Gradient_Color2: AppColors.pink),
            ],
          ),
        ],
      ),
    );
  }
}
