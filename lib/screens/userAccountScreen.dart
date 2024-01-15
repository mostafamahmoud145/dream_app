import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/TextButton.dart';
import 'package:grocery_store/widget/dreamDialogsWidget.dart';
import 'package:image_picker/image_picker.dart';

import '../config/colorsFile.dart';
import '../config/paths.dart';
import '../localization/language_constants.dart';
import '../services/app_flyer_service.dart';
import '../widget/back_button.dart';

class UserAccountScreen extends StatefulWidget {
  final GroceryUser user;
  final bool? firstLogged;

  const UserAccountScreen({Key? key, required this.user, this.firstLogged})
      : super(key: key);

  @override
  _UserAccountScreenState createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  late AccountBloc accountBloc;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TimeOfDay selectedTime = TimeOfDay.now();
  late String name, userName, bio, theme, age, education, lang = "ar";
  late ScrollController scrollController;
  var image;
  File? selectedProfileImage;
  bool profileCompleted = false,
      dataSave = false,
      first = true,
      deleting = false;
  late Size size;

  @override
  void initState() {
    super.initState();

    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.stream.listen((state) {
      if (state is UpdateAccountDetailsInProgressState) {
        //show dialog
        if (mounted)
          showSnack(
              getTranslated(context, "updateDetailsProfile"), context, true);
      }
      if (state is UpdateAccountDetailsFailedState) {
        //show error
        if (mounted) showSnack(getTranslated(context, "error"), context, false);
      }
      if (state is UpdateAccountDetailsCompletedState) {
        if (mounted && dataSave) {
          dataSave = false;
          accountBloc.add(GetLoggedUserEvent());
          selectedProfileImage = null;
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
          // Navigator.pop(context);
          // accountBloc.add(GetLoggedUserEvent(widget.user.uid));
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    getThemeName().then((theme) {
      setState(() {
        this.theme = theme;
        lang = getTranslated(context, "lang");
        size = MediaQuery.of(context).size;
      });
    });
    super.didChangeDependencies();
  }

  showDeleteConfimationDialog(Size size) {
    return showDialog(
      builder: (context) => DreamDialogsWidget(
        padLeft: 0,
        padBottom: 0,
        padRight: 0,
        padTop: 0,
        dialogContent: Container(
          width: AppSize.w441_3.w,
          // height: AppSize.h339.h,
          padding: EdgeInsets.symmetric(
              horizontal: AppPadding.p32.w, vertical: AppPadding.p32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      AssetsManager.black_cancel_iconPath,
                      width: AppSize.w32.w,
                      height: AppSize.h32.h,
                    ),
                  ),
                ],
              ),
              Image.asset(
                AssetsManager.red_delete_iconPath,
                width: AppSize.w53_5.r,
                height: AppSize.h53_5.r,
              ),
              SizedBox(height: AppSize.h13_3.h),
              Column(
                children: [
                  Text(
                    getTranslated(context, "deleteAccount"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: AppSize.h1_3.h,
                      fontFamily: getTranslated(context, 'Ithra'),
                      fontSize: AppFontsSizeManager.s26_6.sp,
                      color: AppColors.black4,
                      //fontStyle: FontStyle.normal,
                      //fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppSize.h13_3.h),
                  Text(
                    getTranslated(context, "DoYouWantDeleteAccount"),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: AppSize.h2.h,

                      overflow: TextOverflow.ellipsis,
                      fontFamily: getTranslated(context, 'Ithralight'),
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      color: AppColors.black4,
                      // fontWeight: FontWeight.w300,
                      // fontStyle: FontStyle.normal,
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h16_7.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      deleting
                          ? CircularProgressIndicator()
                          : Expanded(
                              child: InkWell(
                                onTap: () async {
                                  await FirebaseFirestore.instance
                                      .collection(Paths.usersPath)
                                      .doc(widget.user.uid)
                                      .delete();
                                  FirebaseAuth.instance.signOut();
                                  setState(() {
                                    deleting = false;
                                  });
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/home',
                                    (route) => false,
                                  );
                                },
                                child: Container(
                                  // width: AppSize.w160.w,
                                  height: AppSize.h56.h,
                                  //   alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.red8,
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.r10_6.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      getTranslated(context, 'yes'),
                                      style: TextStyle(
                                        fontFamily: getTranslated(
                                            context, 'Ithra_Bold'),
                                        fontSize: AppFontsSizeManager.s18_6.sp,
                                        color: AppColors.white,
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(
                        width: AppSize.w21_3.w,
                      ),
                      //SizedBox(width: AppSize.w57_3.w),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            // width: AppSize.w160.w,
                            height: AppSize.h56.h,
                            //   alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(AppRadius.r10_6.r)),
                                border: Border.all(
                                  color: AppColors.red8,
                                  width: AppSize.w1_5.w,
                                )),
                            child: Center(
                              child: Text(
                                getTranslated(context, 'no'),
                                style: TextStyle(
                                  fontFamily:
                                      getTranslated(context, 'Ithra_Bold'),
                                  fontSize: AppFontsSizeManager.s18_6.sp,
                                  color: AppColors.red8,
                                  // fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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

  void showSnack(String text, BuildContext context, bool status) {
    Container(
      width: AppSize.w509.w,
      height: AppSize.h72.h,
      child: Flushbar(
        margin: EdgeInsets.all(AppSize.w20).w,
        borderRadius: BorderRadius.circular(AppRadius.r5_3.r),
        backgroundColor: AppColors.white,
        animationDuration: Duration(milliseconds: AppConstants.milliseconds300),
        isDismissible: true,
        boxShadows: [AppShadow.primaryShadow],
        shouldIconPulse: false,
        duration: Duration(milliseconds: AppConstants.milliseconds6000),
        messageText: Row(
          children: [
            Image.asset(
              AssetsManager.green_Vector_iconPath,
              width: AppSize.w30_6.w,
              height: AppSize.h30_6.h,
            ),
            SizedBox(
              width: AppSize.w21_3.w,
            ),
            Text(
              '$text',
              style: TextStyle(
                fontFamily: getTranslated(context, 'Ithra'),
                fontSize: AppFontsSizeManager.s21_3.sp,
                fontWeight: AppFontsWeightManager.bold700,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.3,
                color: AppColors.black3,
              ),
            ),
          ],
        ),
      )..show(context),
    );
  }

  /* showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: getTranslated(context, "loading"),
        );
      },
    );
  }*/
  Future cropImage(context) async {
    image = await ImagePicker().pickImage(source: ImageSource.gallery);
    File croppedFile = File(image.path);

    if (croppedFile != null) {
      setState(() {
        selectedProfileImage = croppedFile;
      });
      // signupBloc.add(PickedProfilePictureEvent(file: croppedFile));
    } else {
      //not croppped
    }
  }

  @override
  Widget build(BuildContext context) {
    if (first)
      setState(() {
        first = false;
        size = MediaQuery.of(context).size;
        lang = getTranslated(context, "lang");
      });
    return Scaffold(
      backgroundColor: AppColors.white,
      key: _scaffoldKey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding(
                padding: EdgeInsets.only(
                    right: AppPadding.p32.w,
                    left: lang == "ar" ? AppPadding.p32.w : AppPadding.p32.w,
                    top: AppPadding.p35.h,
                    bottom: AppPadding.p20.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomBackButton(),

                    // IconButton1(
                    //   radius: AppRadius.r10_6.r,
                    //   color: AppColors.white,
                    //   shadowcolor: AppColors.warmPurple,
                    //   iconsize: 30,
                    //   icon: lang=="ar"? AssetsManager.purple_right_arrowPath:AssetsManager.purple_left_arrowPath,
                    //   iconcolor:AppColors.linear2,
                    //   onPress: () {
                    //     Navigator.pop(context);
                    //   },
                    //   width: AppSize.w50_5.w,
                    //   height: AppSize.h50_5.h,
                    // ),
                    SizedBox(width: AppSize.w30_6.w),
                    Text(
                      getTranslated(context, "account"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithra'),
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        color: AppColors.pureBlack,
                        fontWeight: AppFontsWeightManager.bold700,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ))),
          Container(
              color: AppColors.lightGrey6,
              height: AppSize.h1_5.h,
              width: size.width),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: AppSize.w33.w),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      //dc
                      SizedBox(
                        height: AppSize.h32.h,
                      ),
                      Center(
                        child: InkWell(
                          onTap: () {
                            cropImage(context);
                          },
                          child: Container(
                            height: AppSize.h93_3.h,
                            width: AppSize.w93_3.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.white,
                            ),
                            child: widget.user.photoUrl == null &&
                                    selectedProfileImage == null
                                ? Image.asset(
                                    AssetsManager.dreamLogoPurpleImagePath,
                                    fit: BoxFit.fill,
                                    height: AppSize.h93_3.h,
                                    width: AppSize.w93_3.w,
                                  )
                                : selectedProfileImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.r35),
                                        child: Image.file(
                                          selectedProfileImage!,
                                          fit: BoxFit.fill,
                                          height: AppSize.h93_3.h,
                                          width: AppSize.w93_3.w,
                                        ))
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.r35),
                                        child: FadeInImage.assetNetwork(
                                          placeholder:
                                              AssetsManager.icon_personPath,
                                          placeholderScale: 0.5,
                                          imageErrorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(
                                            Icons.person,
                                            color: AppColors.pureBlack,
                                            size: AppSize.w50,
                                          ),
                                          image: widget.user.photoUrl!,
                                          fit: BoxFit.cover,
                                          fadeInDuration: Duration(
                                              milliseconds:
                                                  AppConstants.milliseconds250),
                                          fadeInCurve: Curves.easeInOut,
                                          fadeOutDuration: Duration(
                                              milliseconds:
                                                  AppConstants.milliseconds150),
                                          fadeOutCurve: Curves.easeInOut,
                                        ),
                                      ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: AppSize.h10_5.h,
                      ),
                      Center(
                        child: Text(
                          getTranslated(context, "welcomeBack"),
                          style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithra'),
                            fontSize: AppFontsSizeManager.s24.sp,
                            color: AppColors.linear3,
                            fontWeight: AppFontsWeightManager.bold700,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                      //name
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: AppPadding.p20, right: AppPadding.p20),
                          child: Text(
                            getTranslated(context, "lang") == "ar"
                                ? widget.user.consultName!.nameAr!
                                : getTranslated(context, "lang") == "en"
                                    ? widget.user.consultName!.nameEn!
                                    : getTranslated(context, "lang") == "fr"
                                        ? widget.user.consultName!.nameFr!
                                        : widget.user.consultName!.nameId!,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              fontSize: AppFontsSizeManager.s26_6.sp,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                              color: AppColors.pureBlack,
                            ),
                          ),
                        ),
                      ),

                      //welcome_text

                      SizedBox(
                        height: AppSize.h32.h,
                      ),
                      getTitle(getTranslated(context, "name")),
                      SizedBox(
                        height: 10.5.h,
                      ),
                      SizedBox(
                        child: Theme(
                          data: new ThemeData(
                            primaryColor: Colors.redAccent,
                            primaryColorDark: Colors.red,
                          ),
                          child: TextFormField(
                              textAlign: lang == "ar"
                                  ? TextAlign.start
                                  : TextAlign.end,
                              style: TextStyle(
                                fontFamily:
                                    getTranslated(context, 'Ithralight'),
                                fontSize: AppFontsSizeManager.s21_3.sp,
                                // color: Color.fromRGBO(147, 147, 147, 1),
                                color: AppColors.greyShade400,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal,
                              ),
                              cursorColor: AppColors.pink,
                              initialValue: widget.user.name,
                              keyboardType: TextInputType.name,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, 'required');
                                }
                                return null;
                              },
                              onSaved: (val) {
                                widget.user.name = val;
                              },
                              enableInteractiveSelection: true,
                              decoration: inputDecoration()),
                        ),
                      ),
                      SizedBox(
                        height: AppSize.h21_5.h,
                      ),
                      getTitle(getTranslated(context, "bio1")),
                      SizedBox(
                        height: AppSize.h10_5.h,
                      ),
                      Container(
                        height: AppSize.h155.h,
                        /*borderRadius: BorderRadius.circular(11.r),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.5.w,
                        ),*/
                        padding: EdgeInsets.only(
                            right: AppPadding.p16.w,
                            left: AppPadding.p16.w,
                            top: 0,
                            bottom: AppPadding.p16.h),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.r11.r),
                          border: Border.all(
                              color: Colors.grey.shade300,
                              width: AppSize.w1_5.w),
                        ),
                        child: TextFormField(
                          maxLines: 7,
                          maxLength: AppConstants.maxLength,
                          style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithralight'),
                            fontSize: AppFontsSizeManager.s21_3.sp,
                            color: Colors.grey.shade400,
                            fontWeight: AppFontsWeightManager.bold300,
                            fontStyle: FontStyle.normal,
                          ),
                          cursorColor: AppColors.pureBlack,
                          initialValue: widget.user.bio,
                          keyboardType: TextInputType.multiline,
                          onSaved: (val) {
                            widget.user.bio = val;
                          },
                          decoration: new InputDecoration(
                            counterStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: AppFontsSizeManager.s17_5.sp,
                            ),
                            hintStyle: TextStyle(
                              fontFamily: getTranslated(context, 'Ithralight'),
                              fontSize: AppFontsSizeManager.s21_3.sp,
                              color: Colors.grey.shade400,
                              fontWeight: AppFontsWeightManager.bold300,
                              fontStyle: FontStyle.normal,
                              letterSpacing: AppConstants.letterSpacing,
                            ),
                            hintText: getTranslated(context, "bio1"),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,

                            //  hintText: sLabel
                          ),
                        ),
                      ),
                      SizedBox(
                        height: AppSize.h32.h,
                      ),
                      //Delete Account
                      InkWell(
                        onTap: () {
                          showDeleteConfimationDialog(size);
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              AssetsManager.deleteRed,
                              width: AppSize.w32.w,
                              height: AppSize.h32.h,
                            ),
                            SizedBox(width: AppSize.w5_5.w),
                            Text(
                              getTranslated(context, "deleteAccount"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: getTranslated(context, 'Ithra'),
                                fontSize: AppFontsSizeManager.s21_3.sp,
                                color: AppColors.pureBlack,
                                fontWeight: AppFontsWeightManager.bold700,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: AppSize.h42_6.h,
                      ),
                      //d
                      Visibility(
                        visible: false,
                        child: Center(
                          child: textButton(
                            onPress: () async {
                              await AppFlyerService().inviteFriends(
                                FirebaseAuth.instance.currentUser!.uid,
                                widget.user.name ?? '',
                              );
                            },
                            text: getTranslated(context, "inviteFriends"),
                            width: AppSize.w306.w,
                            height: AppSize.h49_3.h,
                            buttonRadius: AppRadius.r10_6.r,
                            textSize: AppFontsSizeManager.s21_3.sp,
                            textfont: getTranslated(context, 'Ithra'),
                            textcolor: AppColors.white,
                            Gradient_Color: AppColors.linear12,
                            Gradient_Color2: AppColors.linear2,
                            icon: '',
                          ),
                        ),
                      ),
                      SizedBox(height: AppSize.h12.h),
                      Center(
                        child: textButton(
                          onPress: () {
                            save();
                          },
                          text: getTranslated(context, "saveAndContinue"),
                          width: AppSize.w509_3.w,
                          height: AppSize.h66_6.h,
                          buttonRadius: AppRadius.r10_6.r,
                          textSize: AppFontsSizeManager.s21_3.sp,
                          textfont: getTranslated(context, 'Ithra'),
                          textcolor: AppColors.white,
                          fontWeight: AppFontsWeightManager.bold600,
                          Gradient_Color: AppColors.linear12,
                          Gradient_Color2: AppColors.linear2,
                          icon: '',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(),
      child: Text(
        title,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: getTranslated(context, 'Ithra'),
          fontSize: AppFontsSizeManager.s21_3.sp,
          color: AppColors.linear3,
          fontWeight: AppFontsWeightManager.bold700,
          fontStyle: FontStyle.normal,
        ),
      ),
    );
  }

  InputDecoration inputDecoration() {
    return InputDecoration(
        contentPadding: EdgeInsets.only(right: AppPadding.p16.w),
        fillColor: AppColors.white,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r11.r),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            // color: Color.fromRGBO(147, 147, 147, 1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r11.r),
          borderSide: BorderSide(
            color: AppColors.grey6,
            // color: Color.fromRGBO(147, 147, 147, 1),
            width: AppSize.w1_5.w,
          ),
        ));
  }

  save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        List<String> indexList = [];
        for (int y = 1;
            y <= widget.user.name!.trimLeft().trimRight().length;
            y++) {
          indexList.add(widget.user.name!
              .trimLeft()
              .trimRight()
              .substring(0, y)
              .toLowerCase());
        }
        widget.user.searchIndex = indexList;
        widget.user.consultName = ConsultName(
          nameAr: widget.user.name,
          nameEn: widget.user.name,
          nameFr: widget.user.name,
          nameId: widget.user.name,
          searchIndexAr: indexList,
          searchIndexEn: indexList,
          searchIndexFr: indexList,
          searchIndexId: indexList,
        );
        widget.user.profileCompleted = true;
        widget.user.userLang = getTranslated(context, 'lang');

        setState(() {
          dataSave = true;
        });
        if (selectedProfileImage != null) {
          accountBloc.add(UpdateAccountDetailsEvent(
              user: widget.user, profileImage: selectedProfileImage));
        } else {
          accountBloc.add(UpdateAccountDetailsEvent(user: widget.user));
        }
      } catch (e) {}
    } else {}
  }

  BoxDecoration decoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10.5.w),
      boxShadow: [AppShadow.primaryShadow],
    );
  }
}
