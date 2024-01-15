//import 'dart:js_interop';

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/methods/convert_pt_to_px.dart';
import 'package:grocery_store/widget/back_button.dart';
import 'package:uuid/uuid.dart';

import '../config/app_fonts.dart';
import '../config/constants.dart';
import '../main.dart';

class LanguageScreen extends StatefulWidget {
  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String dropdownValue, lang;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  bool changeLang = false;
  /*List<KeyValueModel> _datas = [
    KeyValueModel(key: "0", value: "العربية"),
    KeyValueModel(key: "1", value: "English"),
    KeyValueModel(key: "2", value: "French"),
    KeyValueModel(key: "3", value: "Indonesian"),
  ];*/

  @override
  void initState() {
    super.initState();
    dropdownValue = "العربية";
    lang = "ar";
    storeDeviceToken();
    WidgetsBinding.instance.addPostFrameCallback((_) => getLocalPhoneLang());
  }

  storeDeviceToken() async {
    String uId = Uuid().v4();
    FirebaseMessaging.instance.getToken().then((token) async {
      await FirebaseFirestore.instance
          .collection('NotRegisteredUsers')
          .doc(uId)
          .set({
        'token': token,
        'userId': uId,
      });
    });
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

  void checkLang(lang) {
    setState(() {
      MyApp.setLocale(context, Locale('ar', 'AR'));
      dropdownValue = "0";
    });
  }

  void getLocalPhoneLang() {
    // الحصول على لغة الجهاز
    String deviceLanguage = PlatformDispatcher.instance.locale.languageCode;

    if (deviceLanguage == "ar") {
      dropdownValue = 'العربية';
      lang = "ar";
      MyApp.setLocale(context, Locale('ar', 'AR'));
    } else if (deviceLanguage == "en") {
      dropdownValue = "English";
      lang = "en";
      MyApp.setLocale(context, Locale('en', 'US'));
    } else if (deviceLanguage == "fr") {
      dropdownValue = "French";
      lang = "fr";
      MyApp.setLocale(context, Locale('fr', 'FR'));
    } else if (deviceLanguage == "id") {
      dropdownValue = "Indonesian";
      lang = "id";
      MyApp.setLocale(context, Locale('id', 'ARB'));
    } else {
      dropdownValue = "English";
      lang = "en";
      MyApp.setLocale(context, Locale('en', 'US'));
    }
    setState(() {
      _changeLanguage(lang);
    });
  }

  @override
  Widget build(BuildContext context) {
    //String dropdownValue = 'العربية';
    return Scaffold(
      backgroundColor: AppColors.white,
      key: _scaffoldKey,
      body: ListView(
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
          SizedBox(height: AppSize.h202_6.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppPadding.p190.w),
            child: Center(
                child: SvgPicture.asset(
              AssetsManager.dreamImagePath,
              width: AppSize.w218_6.w,
              height: AppSize.h56_6.h,
            )),
          ),
          SizedBox(height: AppSize.h150_2.h),
          Text(
            getTranslated(context, 'pleaseChooseLang'),
            maxLines: AppConstants.maxLines,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: getTranslated(context, 'Ithra'),
              color: AppColors.warmGrey,
              fontSize: AppFontsSizeManager.s21_3.sp,
              //fontWeight: FontWeight.normal
            ),
          ),
          SizedBox(height: AppSize.h193_3.h),
          Center(
            child: Directionality(
              textDirection: getTranslated(context, "lang") == "ar"
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AssetsManager.lang_icon,
                      width: convertPtToPx(AppSize.w44).r,
                      height: convertPtToPx(AppSize.w44).r),
                  SizedBox(
                    width: convertPtToPx(AppSize.w12).w,
                  ),
                  DropdownButtonHideUnderline(
                    child: SizedBox(
                      height: convertPtToPx(AppSize.h50).h,
                      width: convertPtToPx(AppSize.w322).w,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          // Setting up the border style here
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.r10_6.r),
                            borderSide: BorderSide(
                              color: AppColors.grey, // Purple-ish border color
                              width: 1,
                            ),
                          ),
                          contentPadding: EdgeInsets.only(
                              left: convertPtToPx(AppPadding.p16).w,
                              right: convertPtToPx(AppPadding.p16).w),
                          // To match the border when the Dropdown is clicked
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.r10_6.r),
                            borderSide: BorderSide(
                              color: AppColors.grey,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.r10_6.r),
                            borderSide: BorderSide(
                              color: AppColors.grey,
                              width: 1,
                            ),
                          ),
                        ),
                        isExpanded: true,
                        value: dropdownValue,
                        icon: Image.asset(
                          AssetsManager.ios_purple_down_iconPath,
                          height: AppSize.h26_6.h,
                          width: AppSize.w26_6.w,
                        ),
                        iconSize: AppSize.w24.r,
                        elevation: 16,
                        style: TextStyle(
                          color: AppColors.pink3,
                          fontSize: AppFontsSizeManager.s21_3.sp,
                          fontFamily: getTranslated(context, 'Ithra'),
                        ), // Text Style
                        onChanged: (String? newValue) {
                          if (newValue == "العربية") {
                            lang = "ar";
                            MyApp.setLocale(context, Locale('ar', 'AR'));
                          } else if (newValue == "English") {
                            lang = "en";
                            MyApp.setLocale(context, Locale('en', 'US'));
                          } else if (newValue == "French") {
                            lang = "fr";
                            MyApp.setLocale(context, Locale('fr', 'FR'));
                          } else if (newValue == "Indonesian") {
                            lang = "id";
                            MyApp.setLocale(context, Locale('id', 'ARB'));
                          }
                          dropdownValue = newValue!;
                          _changeLanguage(lang);
                          Navigator.pushNamed(context, '/home');
                        },
                        items: <String>[
                          'العربية',
                          'English',
                          'French',
                          'Indonesian'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeLanguage(String lang) async {
    print(lang);
    final _temp = await setLocaleLang(lang);
    MyApp.setLocale(context, _temp);
  }
}
