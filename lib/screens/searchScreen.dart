import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/consultantListItem.dart';

import '../FireStorePagnation/paginate_firestore.dart';
import '../config/colorsFile.dart';
import '../widget/back_button.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    Key? key,
  }) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searchController = new TextEditingController();
  GroceryUser? loggedUser;
  bool load = false;
  late String lang, userImage, theme = "light";
  String name = "";
  String text = "";
  late Query filterQuery;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    initiateSearch(text);
  }

  getCurrentUser() async {
    if (FirebaseAuth.instance.currentUser != null) {
      var __user = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      loggedUser = GroceryUser.fromMap(__user.data() as Map);
    }
  }

  void showSnakbar(String s, bool status) {
    Fluttertoast.showToast(
        msg: s,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: AppColors.white,
        fontSize: AppFontsSizeManager.s16);
  }

  @override
  Widget build(BuildContext context) {
    lang = getTranslated((context), "lang");
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.white,
      key: _scaffoldKey,
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            Container(
                width: size.width,
                child: SafeArea(
                    child: Padding(
                  padding: EdgeInsets.only(
                      right: AppPadding.p32.w,
                      left: lang == "ar" ? AppPadding.p0 : AppPadding.p32.w,
                      top: AppPadding.p16.h,
                      bottom: AppPadding.p16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomBackButton(),
                      // IconButton1(
                      //   radius: AppRadius.r10_6.r,
                      //   color: AppColors.white,
                      //   shadowcolor: AppColors.warmPurple,
                      //   iconsize: AppSize.w50.r,
                      //   icon: lang=="ar"? AssetsManager.purple_right_arrowPath:AssetsManager.purple_left_arrowPath,
                      //   iconcolor: AppColors.linear2,
                      //   onPress: () {
                      //     Navigator.pop(context);
                      //   },
                      //   width: AppSize.w50.w,
                      //   height: AppSize.h50.h,
                      // ),
                      SizedBox(width: AppSize.w21_3.w),
                      Text(
                        getTranslated(context, "search"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithra'),
                            fontSize: AppFontsSizeManager.s21_3.sp,
                            color: AppColors.pureBlack.withOpacity(0.8),
                            fontWeight: AppFontsWeightManager.bold),
                      ),
                    ],
                  ),
                ))),
            Center(
                child: Container(
                    color: AppColors.lightGrey,
                    height: AppSize.h2.h,
                    width: double.infinity)),
            SizedBox(
              height: AppSize.h33_3.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
              child: Center(
                child: Container(
                  height: AppSize.h73_3.h,
                  width: double.infinity,
                  child: Container(
                    // padding: const EdgeInsets.symmetric(
                    //     horizontal: 1.0, vertical: 0.0),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey10,
                      //ِtheme=="light"?Colors.white:Color(0xff3f3f3f),
                      borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                    ),
                    child: TextField(
                      onChanged: (val) => initiateSearch(val),
                      keyboardType: TextInputType.text,
                      controller: searchController,
                      textInputAction: TextInputAction.search,
                      enableInteractiveSelection: true,
                      readOnly: false,
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithra'),
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        color: AppColors.black,
                        letterSpacing: 0.5,
                        //fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: AppPadding.p21_3.h,
                            vertical: AppPadding.p21_3.h),
                        prefixIcon: Image.asset(
                          AssetsManager.searchIcon,
                          // color: AppColors.pink,
                          // width: AppSize.w5.w,
                          // height: AppSize.h5.h,
                        ),
                        border: InputBorder.none,
                        hintText: getTranslated(context, "nameSearch"),
                        hintStyle: TextStyle(
                          fontFamily: getTranslated(context, 'Ithralight'),
                          fontSize: AppFontsSizeManager.s21_3.sp,
                          color: AppColors.greyDark,
                          letterSpacing: 0.5,
                          fontWeight: AppFontsWeightManager.bold500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: AppSize.h15,
            ),
            name == ""
                ? Expanded(
                    child: Center(child: SizedBox()),
                  )
                : Expanded(
                    child: PaginateFirestore(
                      key: ValueKey(filterQuery),
                      itemBuilderType: PaginateBuilderType.gridView,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 170,
                          childAspectRatio: 1.8),
                      padding: const EdgeInsets.only(
                          left: AppPadding.p20,
                          right: AppPadding.p20,
                          bottom: AppPadding.p16,
                          top: AppPadding.p1),
                      itemBuilder: (context, documentSnapshot, index) {
                        return ConsultantListItem(
                            consult: GroceryUser.fromMap(
                                documentSnapshot[index].data() as Map),
                            loggedUser: loggedUser,
                            consultType: documentSnapshot[index]['voice']
                                ? "voice"
                                : "chat");
                      },
                      query: filterQuery,
                      isLive: true,
                    ),
                  )
          ],
        ),
        /* Positioned(
            right: 0.0,
            top: size.height*.24,
            left: 0,
            child:  Center(child: Container(height: 50,width: size.width*.9,child:
               Container(
                  //height: 35.0,
                  //width: size.width*.45,
                  padding: const EdgeInsets.symmetric( horizontal: 1.0, vertical: 0.0),
                  decoration: BoxDecoration(
                    color: theme=="light"?AppColors.white:Color(0xff3f3f3f),
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      AppShadow.primaryShadow
                        offset: Offset(0, 0.0),
                        blurRadius: 15.0,
                        spreadRadius: 2.0,
                        color: AppColors.pureBlack.withOpacity(0.6),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (val) => initiateSearch(val),
                    keyboardType: TextInputType.text,
                    controller: searchController,
                    textInputAction: TextInputAction.search,
                    enableInteractiveSelection: true,
                    readOnly:false,
                    style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                      fontSize: 14.5,
                      color: AppColors.black1,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).primaryColor,
                        size: 25.0,
                      ),
                      border: InputBorder.none,
                      hintText: getTranslated(context, "nameSearch"),
                      hintStyle: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                        fontSize: 14.5,
                        color: Theme.of(context).primaryColor,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
            ),)
        ),*/
      ]),
    );
  }

  void showNoNotifSnack(String text) {
    Flushbar(
      margin: EdgeInsets.all(AppPadding.p8),
      borderRadius: BorderRadius.circular(AppRadius.r7.r),
      backgroundColor: Colors.green.shade500,
      animationDuration: Duration(milliseconds: AppConstants.milliseconds300),
      isDismissible: true,
      boxShadows: [AppShadow.primaryShadow],
      shouldIconPulse: false,
      duration: Duration(milliseconds: AppConstants.milliseconds1500),
      icon: Icon(
        Icons.notification_important,
        color: AppColors.white,
      ),
      messageText: Text(
        '$text',
        style: TextStyle(
          fontFamily: getTranslated(context, "Ithra"),
          fontSize: AppFontsSizeManager.s14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: AppColors.white,
        ),
      ),
    )..show(context);
  }

  Future<void> initiateSearch(String val) async {
    String eventName = "af_search";
    Map eventValues = {
      "af_search_string": val,
      "af_content_list": [val],
    };
    addEvent(eventName, eventValues);
    await FirebaseAnalytics.instance.logSearch(searchTerm: val);
    setState(() {
      name = val.toLowerCase().trim();
      filterQuery = getTranslated(context, 'lang') == "ar"
          ? FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .where('userType', isEqualTo: AppConstants.consultant)
              .where('accountStatus', isEqualTo: "Active")
              .where('consultName.searchIndexAr',
                  arrayContainsAny: [name]).orderBy('rating', descending: true)
          : getTranslated(context, 'lang') == "en"
              ? FirebaseFirestore.instance
                  .collection(Paths.usersPath)
                  .where('userType', isEqualTo: AppConstants.consultant)
                  .where('accountStatus', isEqualTo: "Active")
                  .where('consultName.searchIndexEn', arrayContainsAny: [name]).orderBy('rating',
                      descending: true)
              : getTranslated(context, 'lang') == "fr"
                  ? FirebaseFirestore.instance
                      .collection(Paths.usersPath)
                      .where('userType', isEqualTo: AppConstants.consultant)
                      .where('accountStatus', isEqualTo: "Active")
                      .where('consultName.searchIndexFr', arrayContainsAny: [name]).orderBy(
                          'rating',
                          descending: true)
                  : FirebaseFirestore.instance
                      .collection(Paths.usersPath)
                      .where('userType', isEqualTo: AppConstants.consultant)
                      .where('accountStatus', isEqualTo: "Active")
                      .where('consultName.searchIndexIn',
                          arrayContainsAny: [name]).orderBy('rating', descending: true);
    });
  }

  addEvent(String eventName, Map eventValues) {
    AppsflyerSdk appsflyerSdk;
    if (Platform.isIOS) {
      Map<String, Object> appsFlyerOptions = {
        "afDevKey": "mrP9nrMmbUYnkWEwtkrTmF",
        "afAppId": "id1515745954",
        "isDebug": true
      };
      appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
      appsflyerSdk.initSdk(
          registerConversionDataCallback: true,
          registerOnAppOpenAttributionCallback: true,
          registerOnDeepLinkingCallback: true);
    } else {
      Map<String, Object> appsFlyerOptions = {
        "afDevKey": "mrP9nrMmbUYnkWEwtkrTmF",
        "isDebug": true
      };
      appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
      appsflyerSdk.initSdk(
          registerConversionDataCallback: true,
          registerOnAppOpenAttributionCallback: true,
          registerOnDeepLinkingCallback: true);
    }
    appsflyerSdk.logEvent(eventName, eventValues);
  }
}
