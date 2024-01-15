import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/app/authentication/view/screens/sign_up_screen.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/widget/TextButton.dart';
import 'package:grocery_store/widget/back_button.dart';

import '../methods/convert_pt_to_px.dart';

class RegisterTypeScreen extends StatefulWidget {
  @override
  _RegisterTypeScreenState createState() => _RegisterTypeScreenState();
}

class _RegisterTypeScreenState extends State<RegisterTypeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  void showFailedSnakbar(String s) {
    Fluttertoast.showToast(
        msg: s,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: AppColors.white,
        fontSize: 16.0);
  }

  String lang = "";
  @override
  Widget build(BuildContext context) {
    lang = getTranslated(context, "lang");

    return Scaffold(
      backgroundColor: AppColors.white,
      key: _scaffoldKey,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: convertPtToPx(AppPadding.p24).w,
                ),
                child: CustomBackButton(),
              ),
            ),
            SizedBox(
              height: AppSize.h16.h,
            ),
            Container(
              width: double.infinity,
              height: AppSize.h1.h,
              color: AppColors.lightGray,
            ),
            SizedBox(
              height: AppSize.h202_6.h,
            ),
            SvgPicture.asset(
              AssetsManager.dreamImagePath,
              width: AppSize.w218_6.w,
              height: AppSize.h56_6.h,
            ),
            SizedBox(
              height: AppSize.h150.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p97_3.w),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                    gradient: LinearGradient(
                        colors: [
                          AppColors.Gradient_Color1,
                          AppColors.Gradient_Color2
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)),
                child: textButton(
                  onPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        //CONSULTANT
                        builder: (context) => SignUpScreen(userType: "USER"),
                      ),
                    );
                  },
                  text: getTranslated(context, "registerAsClient"),
                  width: double.infinity,
                  height: AppSize.h66_6.h,
                  buttonRadius: AppRadius.r10_6.r,
                  textSize: AppFontsSizeManager.s21_3.sp,
                  textfont: getTranslated(context, 'Ithra'),
                  textcolor: AppColors.white,
                  Gradient_Color: Colors.transparent,
                  Gradient_Color2: Colors.transparent,
                  icon: '',
                ),
              ),
            ),
            SizedBox(
              height: AppSize.h360.h,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    //CONSULTANT
                    builder: (context) => SignUpScreen(userType: "CONSULTANT"),
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    width: AppSize.w64.w,
                    height: AppSize.h64.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.linear2.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: AppRadius.r12.r,
                          offset: Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(AppPadding.p12.r),
                      child: Image.asset(
                        AssetsManager.person_iconPath,
                        width: AppSize.w40_2.w,
                        height: AppSize.h38_5.h,
                      ),
                    ),
                    // child: textButton(
                    //   onPress: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         //CONSULTANT
                    //         builder: (context) => SignUpScreen(userType: "CONSULTANT"),
                    //       ),
                    //     );
                    //   },
                    //   text:"",
                    //   width: AppSize.w52.w,
                    //   height: AppSize.h52.h,
                    //   buttonRadius: AppRadius.r10_6.r,
                    //   textSize: AppFontsSizeManager.s21_3.sp,
                    //   textfont: getTranslated(context, 'Ithra_Bold'),
                    //   textcolor: AppColors.linear2,
                    //   Gradient_Color: Colors.transparent,
                    //   Gradient_Color2: Colors.transparent,
                    //   icon: AssetsManager.person_iconPath,
                    //   iconcolor: AppColors.pink,
                    //
                    // ),
                  ),
                  SizedBox(
                    height: AppSize.h16.h,
                  ),
                  Text(
                    getTranslated(context, "registerAsConsultant"),
                    style: TextStyle(
                        color: AppColors.black,
                        fontFamily: getTranslated(context, 'Ithra'),
                        fontSize: AppFontsSizeManager.s18_6.sp),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: AppSize.h25_3.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p141_3.w),
              child: Center(
                child: Text(
                  getTranslated(context, "noteDuringRegisterAsConsultant"),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: getTranslated(context, 'Ithralight'),
                    color: AppColors.darkGrey3,
                    //fontWeight: AppFontsWeightManager.bold300,
                    fontSize: AppFontsSizeManager.s18_6.sp,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
