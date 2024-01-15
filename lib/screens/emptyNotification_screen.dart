import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/widget/back_button.dart';

import '../config/colorsFile.dart';
import '../localization/localization_methods.dart';

class EmptyNotification extends StatefulWidget {
  const EmptyNotification({Key? key}) : super(key: key);

  @override
  State<EmptyNotification> createState() => _EmptyNotificationState();
}

class _EmptyNotificationState extends State<EmptyNotification> {
  @override
  Widget build(BuildContext context) {
    String lang = "ar";
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: lang == "ar" ? AppPadding.p0 : AppPadding.p32.w,
                  right: AppPadding.p32.w,
                  top: AppPadding.p16.h,
                  bottom: AppPadding.p16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomBackButton(),
                      // IconButton1(
                      //   radius: AppRadius.r10_6.r,
                      //   color: AppColors.white,
                      //   shadowcolor: AppColors.warmPurple,
                      //   iconsize: AppSize.w32_6,
                      //   icon: lang=="ar"? AssetsManager.purple_right_arrowPath:AssetsManager.purple_left_arrowPath,
                      //   iconcolor:AppColors.linear2,
                      //   onPress: () {
                      //     Navigator.pop(context);
                      //   },
                      //   width: AppSize.w50_6.r,
                      //   height:AppSize.h50_6.r,
                      // ),
                      SizedBox(
                        width: AppSize.w16.w,
                      ),
                      Text(
                        getTranslated(context, "notification"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithra'),
                            fontSize: AppFontsSizeManager.s21_3.sp,
                            color: AppColors.pureBlack.withOpacity(0.8),
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Center(
                child: Container(
                    color: AppColors.lightGrey,
                    height: AppSize.h1.h,
                    width: double.infinity)),
            Spacer(),
            Center(
                child: Text(
              getTranslated(context, "noNotification"),
              style: TextStyle(
                  fontFamily: getTranslated(context, "Ithra"),
                  fontSize: AppFontsSizeManager.s32.sp,
                  color: AppColors.grey,
                  fontWeight: AppFontsWeightManager.bold700),
            )),
            SizedBox(
              height: AppSize.h32.h,
            ),
            Image.asset(
              AssetsManager.grey_notification_iconPath,
              width: 58.6.w,
              height: AppSize.h68.h,
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
