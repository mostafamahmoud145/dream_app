import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/widget/TextButton.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/colorsFile.dart';

class ForceUpdateScreen extends StatefulWidget {
  const ForceUpdateScreen({Key? key}) : super(key: key);

  @override
  _ForceUpdateScreenState createState() => _ForceUpdateScreenState();
}

class _ForceUpdateScreenState extends State<ForceUpdateScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController nameController = TextEditingController();
  String lang = "ar";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");
    return Scaffold(
      backgroundColor: AppColors.white,
      key: _scaffoldKey,
      body: Container(
        height: size.height,
        width: size.width,
        color: AppColors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: AppSize.h349.h,
            ),
            Center(
                child: SvgPicture.asset(
              AssetsManager.dreamImagePath,
              width: AppSize.w218_6.w,
              height: AppSize.h56_6.h,
            )),
            SizedBox(
              height: AppSize.h234_2.h,
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: lang == "ar" ? AppPadding.p32.w : AppPadding.p50.r,
                  right: lang == "ar" ? AppPadding.p32.w : AppPadding.p50.r),
              child: Center(
                child: Text(
                  getTranslated(context, "lastVersion"),
                  maxLines: AppConstants.maxLines,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.warmGrey,
                    fontSize: AppFontsSizeManager.s26_6.sp,
                    // fontWeight: AppFontsWeightManager.bold100,
                    letterSpacing: AppConstants.letterSpacing,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: AppSize.h64.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p97_3.w),
              child: textButton(
                padding: 0,
                onPress: () async {
                  String url = Platform.isIOS
                      ? AppConstants.appStore
                      : AppConstants.googlePlay;
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                text: getTranslated(context, "updateApp"),
                width: double.infinity,
                height: AppSize.h66_6.h,
                buttonRadius: AppRadius.r10_6.r,
                Gradient_Color: AppColors.Gradient_Color1,
                Gradient_Color2: AppColors.Gradient_Color2,
                textSize: AppFontsSizeManager.s21_3.sp,
                textfont: getTranslated(context, "Ithra"),
                textcolor: AppColors.white1,
                icon: '',
              ),
            ),
            /*Container(
              width: size.width*AppSize.w0_8,
              height: AppSize.h45.h,
              child: MaterialButton(
                onPressed: () async {
                  String url = Platform.isIOS ?AppConstants.appStore: AppConstants.googlePlay;
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r5.r),
                ),
                child: Text(
                  getTranslated(context, "install"),
                  style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.white.withOpacity(0.8),
                    fontSize: AppFontsSizeManager.s14.sp,
                    fontWeight: AppFontsWeightManager.semiBold,
                    letterSpacing:AppConstants.letterSpacing,
                  ),
                ),
              ),
            ),*/
            //SizedBox(height: AppSize.h440.h,),
          ],
        ),
      ),
    );
  }
}
