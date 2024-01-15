import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/TextButton.dart';
import 'package:grocery_store/widget/dreamDialogsWidget.dart';
import 'package:uuid/uuid.dart';

import '../widget/back_button.dart';

class SuggestionScreen extends StatefulWidget {
  final GroceryUser? loggedUser;

  const SuggestionScreen({Key? key, this.loggedUser}) : super(key: key);

  @override
  _SuggestionScreenState createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends State<SuggestionScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool saving = false;
  String? title, des;
  String lang = "";

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
                        //   radius: AppRadius.r9_3.r,
                        //   color: AppColors.white,
                        //   shadowcolor: AppColors.warmPurple,
                        //   iconsize: AppSize.w30,
                        //   icon: lang=="ar"? AssetsManager.purple_right_arrowPath:AssetsManager.purple_left_arrowPath,
                        //   iconcolor: AppColors.linear2,
                        //   onPress: () {
                        //     Navigator.pop(context);
                        //   },
                        //   width: AppSize.w50.w,
                        //   height: AppSize.h50.h,
                        // ),
                        SizedBox(
                          width: AppSize.w21_3.w,
                        ),
                        Text(
                          getTranslated(context, "suggestions"),
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
                      width: size.width)),
              Expanded(
                child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppPadding.p32.w,
                    ),
                    children: <Widget>[
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            //image
                            SizedBox(
                              height: AppSize.h32.h,
                            ),
                            Center(
                              child: Container(
                                  height: AppSize.h191.h,
                                  width: AppSize.w162_3.w,
                                  child: SvgPicture.asset(
                                    AssetsManager.lumpImagePath,
                                  )),
                            ),
                            SizedBox(
                              height: AppSize.h32.h,
                            ),
                            Text(
                              getTranslated(context, "suggestionText"),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              maxLines: 4,
                              style: TextStyle(
                                  fontFamily:
                                      getTranslated(context, 'Ithralight'),
                                  fontSize: AppFontsSizeManager.s21.sp,
                                  color: AppColors.darkGrey3),
                            ),
                            SizedBox(
                              height: AppSize.h42_6.h,
                            ),
                            Text(
                              getTranslated(context, "nikNameTxt"),
                              style: TextStyle(
                                fontSize: AppFontsSizeManager.s21_3.sp,
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.linear2,
                              ),
                            ),
                            //p3
                            Padding(
                              padding: EdgeInsets.only(
                                  top: AppPadding.p21_3.h,
                                  bottom: AppPadding.p32.h),
                              child: SizedBox(
                                height: AppSize.h72.h,
                                width: double.infinity,
                                child: Theme(
                                  data: new ThemeData(
                                    primaryColor: AppColors.redShade500,
                                    primaryColorDark: AppColors.red,
                                  ),
                                  child: TextFormField(
                                      style: TextStyle(
                                        fontFamily: getTranslated(
                                            context, 'Ithralight'),
                                        fontSize: AppFontsSizeManager.s18_6.sp,
                                        color: AppColors.grey,
                                      ),
                                      textAlign: TextAlign.start,
                                      cursorColor: AppColors.pink,
                                      keyboardType: TextInputType.text,
                                      validator: (String? val) {
                                        if (val!.trim().isEmpty) {
                                          return getTranslated(
                                              context, 'required');
                                        }
                                        return null;
                                      },
                                      onSaved: (val) {
                                        title = val!;
                                      },
                                      enableInteractiveSelection: true,
                                      decoration: inputDecoration()),
                                ),
                              ),
                            ),

                            Text(
                              getTranslated(context, "suggestionTxt"),
                              style: TextStyle(
                                fontSize: AppFontsSizeManager.s21_3.sp,
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.linear2,
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h21_3.h,
                            ),
                            Container(
                              height: AppSize.h201_3.h,
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                  left: AppPadding.p21_3.w,
                                  //top: AppPadding.p13_3.h,
                                  bottom: AppPadding.p13_3.h,
                                  right: AppPadding.p21_3.w),
                              decoration: BoxDecoration(
                                //color: AppColors.white,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r10_6.r),
                                border: Border.all(
                                    color: AppColors.grey11,
                                    width: AppSize.w2.w),
                              ),
                              child: Center(
                                child: Container(
                                  height: AppSize.h201_3.h,
                                  //  color: Colors.red,
                                  width: double.infinity,
                                  child: TextFormField(
                                    maxLines: 7,
                                    maxLength: AppConstants.maxLength,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, 'Ithralight'),
                                      fontSize: AppFontsSizeManager.s18_6.sp,
                                      color: AppColors.grey,
                                    ),
                                    cursorColor: AppColors.pureBlack,
                                    initialValue: des,
                                    keyboardType: TextInputType.multiline,
                                    onSaved: (val) {
                                      des = val!;
                                    },
                                    decoration: new InputDecoration(
                                      counterStyle: TextStyle(
                                        fontSize: AppFontsSizeManager.s18_6.sp,
                                        color: AppColors.grey,
                                      ),
                                      hintStyle: TextStyle(
                                        fontFamily: getTranslated(
                                            context, 'Ithralight'),
                                        fontSize: AppFontsSizeManager.s18_6.sp,
                                        color: AppColors.grey,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing:
                                            AppConstants.letterSpacing,
                                      ),
                                      hintText: "...............",
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,

                                      //  hintText: sLabel
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height: AppSize.h42_6.h,
                            ),
                            Center(
                              child: textButton(
                                onPress: () {
                                  save();
                                  //showAddingSuggestionDialog(size);
                                },
                                text: getTranslated(context, "save"),
                                width: double.infinity,
                                height: AppSize.h66_6.h,
                                buttonRadius: AppRadius.r10_6.r,
                                textSize: AppFontsSizeManager.s21_3.sp,
                                textfont: getTranslated(context, 'Ithra'),
                                textcolor: AppColors.white,
                                Gradient_Color: AppColors.Gradient_Color1,
                                Gradient_Color2: AppColors.Gradient_Color2,
                                icon: '',
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h50.h,
                            ),
                          ],
                        ),
                      ),
                    ]),
              ),
            ],
          ),
        ]));
  }

  save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        setState(() {
          saving = true;
        });
        String suggestionId = Uuid().v4();
        await FirebaseFirestore.instance
            .collection(Paths.suggestionsPath)
            .doc(suggestionId)
            .set({
          "userUid": widget.loggedUser!.uid,
          'suggestionId': suggestionId,
          'status': false,
          'sendTime': Timestamp.now(),
          'title': title,
          'desc': des,
          'userData': {
            'uid': widget.loggedUser!.uid,
            'name': widget.loggedUser!.name,
            'image': widget.loggedUser!.photoUrl,
            'phone': widget.loggedUser!.phoneNumber,
          },
        });
        setState(() {
          saving = false;
        });
        showAddingSuggestionDialog(MediaQuery.of(context).size);
      } catch (e) {}
    }
  }

  showAddingSuggestionDialog(Size size) {
    return showDialog(
      builder: (context) => DreamDialogsWidget(
        padBottom: 0,
        padLeft: 0,
        padRight: 0,
        padTop: 0,
        dialogContent: Container(
          // height: AppSize.h326_6.h,
          width: AppSize.w441_3.w,
          padding: EdgeInsets.symmetric(
              horizontal: AppPadding.p32.w, vertical: AppPadding.p32.h),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      AssetsManager.black_cancel_iconPath,
                      width: AppSize.w32.r,
                      height: AppSize.h32.r,
                    ),
                  ),
                ],
              ),
              Center(
                child: Image.asset(
                  AssetsManager.solar_hand_heart_iconPath,
                  width: AppSize.w53_5.r,
                  height: AppSize.h53_5.r,
                ),
              ),
              SizedBox(height: AppSize.h13_3.h),
              Column(
                children: [
                  Text(
                    getTranslated(context, "suggestions2"),
                    style: TextStyle(
                      height: AppSize.h1_8.h,
                      fontFamily: getTranslated(context, 'Ithra'),
                      fontSize: AppFontsSizeManager.s32.sp,
                      color: AppColors.linear2,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSize.h13_3.h),
                  Text(
                    getTranslated(context, "thanks2"),
                    style: TextStyle(
                      height: AppSize.h1_8.h,
                      fontFamily: getTranslated(context, 'Ithralight'),
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      color: AppColors.black4,
                      //fontWeight: AppFontsWeightManager.bold600,
                      //FontWeight.w600,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h21_3.h,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      height: AppSize.h56.h,

                      //   alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              AppColors.Gradient_Color1,
                              AppColors.Gradient_Color2
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter),
                        borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                      ),
                      child: Center(
                        child: Text(
                          getTranslated(context, 'continue_rating'),
                          style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithra'),
                            fontSize: AppFontsSizeManager.s18_6.sp,
                            color: AppColors.white,
                            fontWeight: AppFontsWeightManager.bold700,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
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

  InputDecoration inputDecoration() {
    return InputDecoration(
        errorStyle: TextStyle(
            fontFamily: getTranslated(context, "Ithra"), // 'Montserrat',
            fontSize: 16.sp,
            color: AppColors.red,
            height: 0.1,
            fontWeight: FontWeight.normal),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0.r),
          borderSide: BorderSide(
            color: AppColors.red,
            width: 1.0.w,
            //style: BorderStyle.solid,
          ),
        ),
        //fillColor: AppColors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
        hintText: getTranslated(context, "enterTitleTxt"),
        hintStyle: TextStyle(
          fontSize: AppFontsSizeManager.s18_6.sp,
          color: AppColors.grey,
          fontFamily: getTranslated(context, "Ithralight"),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r12.r),
          borderSide: BorderSide(
            color: AppColors.grey11,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r12.r),
          borderSide: BorderSide(
            color: AppColors.grey11,
            width: AppSize.w2.w,
          ),
        ));
  }
}
