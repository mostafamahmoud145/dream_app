import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';

import '../widget/TextButton.dart';

class NoInternet extends StatefulWidget {
  const NoInternet({super.key});

  @override
  State<NoInternet> createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        setState(() {
        });
        return await false;
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Image.asset(AssetsManager.noNetwork, width: AppSize.w218_6.w, height: AppSize.h251.h,),
                SizedBox(
                  height: AppSize.h42_6.h,
                ),
                Text(
                  getTranslated(context, "sorry"),
                  style: TextStyle(
                    fontSize: AppFontsSizeManager.s42_6.sp,
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.linear2,
                  ),
                ),
                SizedBox(
                  height: AppSize.h21_3.h,
                ),
                Text(
                  getTranslated(context, "noNetwork"),
                  style: TextStyle(
                    fontSize: AppFontsSizeManager.s26_6.sp,
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.appbartext,
                  ),
                ),
                SizedBox(
                  height: AppSize.h16.h,
                ),
                Text(
                  getTranslated(context, "pleaseConnect"),
                  style: TextStyle(
                    fontSize: AppFontsSizeManager.s18_6.sp,
                    fontFamily: getTranslated(context, "Ithralight"),
                    color: AppColors.darkgrey,
                  ),
                ),
                Spacer(),
                textButton(
                  onPress: () {
                  },
                  text: getTranslated(context, "againTxt"),
                  width: double.infinity,
                  height: AppSize.h66_6.h,
                  buttonRadius: AppRadius.r10_6.r,
                  textSize: AppFontsSizeManager.s21_3.sp,
                  textfont: getTranslated(context, 'Ithra'),
                  textcolor: AppColors.white1,
                  Gradient_Color: AppColors.gradiant2,
                  Gradient_Color2: AppColors.gradiant1,
                  icon: '',
                ),
                SizedBox(
                  height: AppSize.h58_6.h,
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
