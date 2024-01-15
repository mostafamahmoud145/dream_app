
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/colorsFile.dart';

import '../../config/app_values.dart';
import '../../config/assets_manager.dart';
import '../../localization/localization_methods.dart';
import '../dreamDialogsWidget.dart';



customTextDialog({
  required context ,
  required String text,
  String? title,
  required String buttonText,
  double textSize= AppFontsSizeManager.s21_3,
  required Function okFunction,
}) {
  return showDialog(
    builder: (context) => DreamDialogsWidget(
      dialogContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  AssetsManager.pink_cancel_iconPath,
                  width: 32.w,
                  height: 32.h,
                ),
              ),
              SizedBox(width: 140.w),
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Image.asset(
                  AssetsManager.dream_icon_logo2,
                  color: AppColors.pink,
                  width: 53.5.r,
                  height: 53.5.r,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.h16.h),
          if(title!=null)
          Text(
            title,
            style: TextStyle(
              fontFamily: getTranslated(context, 'Ithra'),
              fontSize: AppFontsSizeManager.s32.sp,
              color: AppColors.linear2,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSize.h16.h),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: getTranslated(context, 'Ithralight'),
              fontSize: textSize.sp,
              color: AppColors.black4,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.normal,
            ),
          ),
          SizedBox(
            height: AppSize.h32.h,
          ),
          InkWell(
            onTap: () async {
              okFunction();
              // Navigator.pop(context);
            },
            child: Container(
              width: 160.w,
              height: 56.h,
              //   alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.linear2,
                borderRadius:
                BorderRadius.circular(AppRadius.r10_6.r),
              ),
              child: Center(
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontFamily: getTranslated(context, 'Ithra'),
                    fontSize: AppFontsSizeManager.s18_6.sp,
                    color: AppColors.white,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    barrierDismissible: false,
    context: context,
  );
}

