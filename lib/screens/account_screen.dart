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
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/TextButton.dart';
import 'package:grocery_store/widget/dreamDialogsWidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../config/paths.dart';
import '../widget/back_button.dart';
import '../widget/component/TextFormFieldWidget.dart';

class AccountScreen extends StatefulWidget {
  final GroceryUser user;
  final bool? firstLogged;

  const AccountScreen({Key? key, required this.user, this.firstLogged})
      : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late QuerySnapshot querySnapshot1;
  late AccountBloc accountBloc;
  bool profileCompleted = false, dataSave = false, showCheck = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late List<dynamic> searchAr;
  late List<dynamic> searchEn;
  late List<dynamic> searchFr;
  late List<dynamic> searchId;

  TextEditingController nameArController = TextEditingController();
  TextEditingController nameEnController = TextEditingController();
  TextEditingController nameFrController = TextEditingController();
  TextEditingController nameIdController = TextEditingController();

  TextEditingController bioArController = TextEditingController();
  TextEditingController bioEnController = TextEditingController();
  TextEditingController bioFrController = TextEditingController();
  TextEditingController bioIdController = TextEditingController();

  TextEditingController voicePriceController = TextEditingController();
  TextEditingController chatPriceController = TextEditingController();
  TextEditingController langController = TextEditingController();
  TextEditingController packagePriceController = TextEditingController();

  TextEditingController arNationality = TextEditingController();
  TextEditingController enNationality = TextEditingController();
  TextEditingController frNationality = TextEditingController();
  TextEditingController idNationality = TextEditingController();
  TextEditingController from1 = TextEditingController();

  TimeOfDay selectedTime = TimeOfDay.now();
  late String userName,
      price,
      chatPrice,
      bio2,
      workDays = "",
      lang = "",
      type = "",
      from,
      to,
      theme = "light",
      location;
  late TextEditingController daysController,
      typeController,
      fromController,
      toController;
  bool monday = false,
      tuesday = false,
      wednesday = false,
      thursday = false,
      friday = false,
      saturday = false,
      sunday = false,
      first = true;

  late ScrollController scrollController;
  late List<WorkTimes> workTimes;
  List<dynamic> daysValue = [];
  bool arabic = false, english = false, french = false, indonesian = false;
  bool allowVoice = true, allowChat = true, deleting = false, saving = false;
  WorkTimes _workTime = new WorkTimes();
  var image;
  File? selectedProfileImage;
  late Size size;
  late String nameAr;
  late String nameEn;
  late String nameFr;
  late String nameId;

  late String bioAr;
  late String bioEn;
  late String bioFr;
  late String bioId;
  late String nationalityAr;
  late String nationalityEn;
  late String nationalityFr;
  late String nationalityId;

  bool langOpen = false;
  bool packagesOpen = false;
  bool accountTypeOpen = false;
  bool workDaysOpen = false;
  bool chatPackageOpen = false;

  @override
  void initState() {
    super.initState();
    // defualtLangUser();

    print(widget.user.workDays);
    userName = widget.user.name!;
    price = widget.user.price!;
    chatPrice = widget.user.chatPrice!;
    daysController = TextEditingController();
    typeController = TextEditingController();
    fromController = TextEditingController();
    toController = TextEditingController();

    searchAr = widget.user.consultName!.searchIndexAr!;
    searchEn = widget.user.consultName!.searchIndexEn!;
    searchFr = widget.user.consultName!.searchIndexFr!;
    searchId = widget.user.consultName!.searchIndexId!;

    nameAr = widget.user.consultName!.nameAr!;
    nameEn = widget.user.consultName!.nameEn!;
    nameFr = widget.user.consultName!.nameFr!;
    nameId = widget.user.consultName!.nameId!;

    bioAr = widget.user.consultBio!.bioAr!;
    bioEn = widget.user.consultBio!.bioEn!;
    bioFr = widget.user.consultBio!.bioFr!;
    bioId = widget.user.consultBio!.bioId!;

    nationalityAr = widget.user.consultNationality!.nationalityAr!;
    nationalityEn = widget.user.consultNationality!.nationalityEn!;
    nationalityFr = widget.user.consultNationality!.nationalityFr!;
    nationalityId = widget.user.consultNationality!.nationalityId!;

    nameArController.text = nameAr;
    nameEnController.text = nameEn;
    nameFrController.text = nameFr;
    nameIdController.text = nameId;

    bioArController.text = bioAr;
    bioEnController.text = bioEn;
    bioFrController.text = bioFr;
    bioIdController.text = bioId;

    arNationality.text = nationalityAr;
    enNationality.text = nationalityEn;
    frNationality.text = nationalityFr;
    idNationality.text = nationalityId;
    daysValue = widget.user.workDays!;

    allowVoice = widget.user.voice!;
    allowChat = widget.user.chat!;

    chatPriceController.text = widget.user.chatPrice!;
    voicePriceController.text = widget.user.price!;

    //update worktime

    WidgetsBinding.instance.addPostFrameCallback((_) => getHours());

    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.stream.listen((state) {
      if (state is GetLoggedUserCompletedState) {
        if (mounted && dataSave) {
          dataSave = false;
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
          showSnack(getTranslated(context, "updateDetailsProfile"), context);
        }
      }
      if (state is UpdateAccountDetailsInProgressState) {
        //show dialog
        //   if (mounted)
        //     //showSnack(getTranslated(context, "updateDetailsProfile"), context);
      }
      if (state is UpdateAccountDetailsFailedState) {
        //show error
        showSnack(getTranslated(context, "error"), context);
      }
      if (state is UpdateAccountDetailsCompletedState) {
        if (mounted) {
          accountBloc.add(GetLoggedUserEvent());
          selectedProfileImage = null;
          //Navigator.pop(context);
          // accountBloc.add(GetLoggedUserEvent(widget.user.uid));
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => change());
  }

  getHours() {
    if (widget.user.workTimes!.length > 0) {
      _workTime = widget.user.workTimes![0];
      if (_workTime.from != null) {
        from = _workTime.from!;
        int fromvalue = int.parse(_workTime.from!);
        if (fromvalue == 12)
          fromController.text = "12 " + getTranslated(context, "PM");
        else if (fromvalue == 0)
          fromController.text = "12 " + getTranslated(context, "AM");
        else if (fromvalue > 12)
          fromController.text =
              (fromvalue - 12).toString() + " " + getTranslated(context, "PM");
        else
          fromController.text =
              fromvalue.toString() + " " + getTranslated(context, "AM");
      }
      if (_workTime.to != null) {
        to = _workTime.to!;
        int toValue = int.parse(_workTime.to!);
        if (toValue == 12)
          toController.text = "12 " + getTranslated(context, "PM");
        else if (toValue == 0)
          toController.text = "12 " + getTranslated(context, "AM");
        else if (toValue > 12)
          toController.text =
              (toValue - 12).toString() + " " + getTranslated(context, "PM");
        else
          toController.text =
              toValue.toString() + " " + getTranslated(context, "AM");
      }
    }
  }

  /*defualtLangUser() {
    if (widget.user.userLang == "ar" &&
        widget.user.languages!.contains("ar") == false) {
      widget.user.languages!.add("ar");
      arabic = true;
    } else if (widget.user.userLang == "en" &&
        widget.user.languages!.contains("en") == false) {
      widget.user.languages!.add("en");
      english = true;
    } else if (widget.user.userLang == "fr" &&
        widget.user.languages!.contains("fr") == false) {
      widget.user.languages!.add("fr");
      french = true;
    } else if (widget.user.userLang == "id" &&
        widget.user.languages!.contains("id") == false) {
      widget.user.languages!.add("id");
      indonesian = true;
    }
  }*/

  change() {
    if (widget.user.languages!.length > 0) {
      if (widget.user.languages!.contains("ar")) {
        arabic = true;
        lang = lang + " / " + getTranslated(context, 'ar');
      }
      if (widget.user.languages!.contains("en")) {
        english = true;
        lang = lang + " / " + getTranslated(context, 'en');
      }
      if (widget.user.languages!.contains("fr")) {
        french = true;
        lang = lang + " / " + getTranslated(context, 'fr');
      }
      if (widget.user.languages!.contains("id")) {
        indonesian = true;
        lang = lang + " / " + getTranslated(context, 'id');
      }
    }
    if (widget.user.workDays!.length > 0) {
      if (widget.user.workDays!.contains("1")) {
        workDays = workDays + getTranslated(context, "monday") + " / ";
        monday = true;
      }
      if (widget.user.workDays!.contains("2")) {
        workDays = workDays + getTranslated(context, "tuesday") + " / ";
        tuesday = true;
      }
      if (widget.user.workDays!.contains("3")) {
        workDays = workDays + getTranslated(context, "wednesday") + " / ";
        wednesday = true;
      }
      if (widget.user.workDays!.contains("4")) {
        workDays = workDays + getTranslated(context, "thursday") + " / ";
        thursday = true;
      }
      if (widget.user.workDays!.contains("5")) {
        workDays = workDays + getTranslated(context, "friday") + " / ";
        friday = true;
      }
      if (widget.user.workDays!.contains("6")) {
        workDays = workDays + getTranslated(context, "saturday") + " / ";
        saturday = true;
      }
      if (widget.user.workDays!.contains("7")) {
        workDays = workDays + getTranslated(context, "sunday") + " / ";
        sunday = true;
      }
    }
    if (widget.user.voice == true) {
      type = type + getTranslated(context, "allowVoice") + " / ";
      allowVoice = true;
      if (widget.user.chat == true) {
        type = type + getTranslated(context, "allowChat") + "";
        allowChat = true;
      }
    }

    setState(() {
      langController = TextEditingController(text: lang);
      daysController = TextEditingController(text: workDays);
      typeController = TextEditingController(text: type);
    });
  }

  showDeleteConfimationDialog(Size size) {
    return showDialog(
      builder: (context) => DreamDialogsWidget(
        padBottom: 0,
        padLeft: 0,
        padRight: 0,
        padTop: 0,
        dialogContent: Container(
          width: AppSize.w441_3.w,
          // height: AppSize.h339.h,
          padding: EdgeInsets.symmetric(
              horizontal: AppPadding.p32.w, vertical: AppPadding.p32.w),
          child: Column(
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
                      //fontStyle: FontStyle.normal,
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
                                  setState(() {
                                    deleting = true;
                                  });
                                  await FirebaseFirestore.instance
                                      .collection(Paths.supportListPath)
                                      .doc(widget.user.supportListId)
                                      .delete();

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
                                    '/RegisterTypeScreen',
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

  void showSnack(String text, BuildContext context) {
    Container(
      width: AppSize.w509.w,
      height: AppSize.h72.h,
      child: Flushbar(
        margin: EdgeInsets.all(AppSize.w20).w,
        borderRadius: BorderRadius.circular(AppRadius.r5_3.r),
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        animationDuration: Duration(milliseconds: 300),
        isDismissible: true,
        boxShadows: [AppShadow.primaryShadow],
        shouldIconPulse: false,
        duration: Duration(milliseconds: 6000),
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
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                fontFamily: getTranslated(context, 'Ithra'),
                fontSize: AppFontsSizeManager.s21_3.sp,
                fontWeight: FontWeight.w700,
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
    size = MediaQuery.of(context).size;
    lang = getTranslated((context), "lang");

    return Scaffold(
      backgroundColor: AppColors.white,
      key: _scaffoldKey,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                width: size.width,
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
                      //   icon: lang == "ar"
                      //       ? AssetsManager.purple_right_arrowPath
                      //       : AssetsManager.purple_left_arrowPath,
                      //   iconcolor: AppColors.linear2,
                      //   onPress: () {
                      //     Navigator.pop(context);
                      //   },
                      //   width: AppSize.w50.w,
                      //   height: AppSize.h50.h,
                      // ),
                      SizedBox(width: AppSize.w21_3.w),
                      Text(
                        getTranslated(context, "account"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: getTranslated(context, 'Ithra'),
                          fontSize: AppFontsSizeManager.s21_3.sp,
                          color: AppColors.pureBlack.withOpacity(0.8),
                          //fontWeight: AppFontsWeightManager.bold
                        ),
                      ),
                    ],
                  ),
                )),
            Center(
                child: Container(
                    color: AppColors.grey,
                    height: AppSize.h0_5.h,
                    width: double.infinity)),
            SizedBox(
              height: AppSize.h32.h,
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.p32.w,
                ),
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
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
                                color: AppColors.grey6,
                              ),
                              child: widget.user.photoUrl == null &&
                                      selectedProfileImage == null
                                  ? Image.asset(
                                      AssetsManager.dreamLogoPurpleImagePath,
                                      fit: BoxFit.fill,
                                      height: AppSize.h70.h,
                                      width: AppSize.w70.w,
                                    )
                                  : selectedProfileImage != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.r35.r),
                                          child: Image.file(
                                              selectedProfileImage!,
                                              fit: BoxFit.fill,
                                              height: 70,
                                              width: 70))
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(35.0),
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
                                            fadeInDuration:
                                                Duration(milliseconds: 250),
                                            fadeInCurve: Curves.easeInOut,
                                            fadeOutDuration:
                                                Duration(milliseconds: 150),
                                            fadeOutCurve: Curves.easeInOut,
                                          ),
                                        ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: AppSize.h10_6.h,
                        ),

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
                                color: AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s26_6.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: AppSize.h10_6.h,
                        ),
                        Center(
                          child: Text(
                            getTranslated(context, "welcomeBack"),
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              color: AppColors.pink,
                              fontSize: AppFontsSizeManager.s24.sp,
                              //fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: AppSize.h24.h,
                        ),
                        Container(
                          padding: EdgeInsets.zero,
                          //height:langOpen?320.h:AppSize.h72.h ,
                          child: InputDecorator(
                            expands: false,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: AppSize.w21_3.w,
                                  vertical: AppSize.h21_3.h), // <-- SEE HERE

                              labelText: getTranslated(context, "languages"),
                              labelStyle: TextStyle(
                                fontFamily: getTranslated(context, 'Ithra'),
                                fontSize: AppFontsSizeManager.s21_3.sp,
                                color: AppColors.pink,
                                // fontWeight: FontWeight.bold,
                              ),
                              enabledBorder: new OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: AppSize.w0_5.w,
                                    color: AppColors.warmGrey),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r10_6.r),
                              ),
                            ),
                            child: Column(
                              children: [
                                // TextFormField(
                                //   controller: langController,
                                //   onTap: () {
                                //     setState(() {
                                //       langOpen = !langOpen;
                                //       //langController = TextEditingController(text: lang);
                                //     });
                                //   },
                                //   textAlignVertical: TextAlignVertical.center,
                                //   validator: (String? val) {
                                //     if (val!.trim().isEmpty) {
                                //       return 'This field is required';
                                //     }
                                //     return null;
                                //   },
                                //   readOnly: true,
                                //   enableInteractiveSelection: true,
                                //   style: style(size),
                                //   maxLines: 1,
                                //   textInputAction: TextInputAction.newline,
                                //   keyboardType: TextInputType.multiline,
                                //   decoration: InputDecoration(
                                //     suffixIcon: Icon(
                                //       langOpen
                                //           ? Icons.keyboard_arrow_up
                                //           : Icons.keyboard_arrow_down,
                                //       color: AppColors.linear2,
                                //     ),
                                //     contentPadding: EdgeInsets.all(AppPadding.p10),
                                //     errorStyle: style(size),
                                //     hintStyle: style(size),
                                //     labelText: getTranslated(context, "languages"),
                                //     labelStyle: TextStyle(
                                //       fontFamily: getTranslated(context, 'Ithra'),
                                //       fontSize: AppFontsSizeManager.s21_3.sp,
                                //       color: AppColors.pink,
                                //       fontWeight: FontWeight.bold,
                                //     ),
                                //     enabledBorder: new OutlineInputBorder(
                                //       borderSide: BorderSide(
                                //           width: AppSize.w0_5.w,
                                //           color: AppColors.warmGrey),
                                //       borderRadius:
                                //           BorderRadius.circular(AppRadius.r10_6.r),
                                //     ),
                                //     focusedBorder: new OutlineInputBorder(
                                //       borderSide: BorderSide(
                                //           width: AppSize.w0_5.w,
                                //           color: AppColors.warmPurple4),
                                //       borderRadius:
                                //           BorderRadius.circular(AppRadius.r10_6.r),
                                //     ),
                                //     border: OutlineInputBorder(
                                //       borderSide:
                                //           BorderSide(color: AppColors.greyDark),
                                //       borderRadius:
                                //           BorderRadius.circular(AppRadius.r10_6.r),
                                //     ),
                                //   ),
                                // ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      langController.text,
                                      style: TextStyle(
                                        fontFamily: getTranslated(
                                            context, 'Ithralight'),
                                        fontSize: AppFontsSizeManager.s21_3.sp,
                                        color: AppColors.darkGrey,
                                        // fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    InkWell(
                                        onTap: () {
                                          setState(() {
                                            langOpen = !langOpen;
                                          });
                                        },
                                        child: Icon(
                                          langOpen
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: AppColors.linear2,
                                        )),
                                  ],
                                ),
                                langOpen
                                    ? _showLang(context, size)
                                    : SizedBox(),
                              ],
                            ),
                          ),
                        ),
                        // tabbedText("lang", getTranslated(context, "languages"),
                        //     langController),

                        SizedBox(
                          height: AppSize.h29_3.h,
                        ),
                        arabic
                            ? Column(
                                children: [
                                  TextFormFieldWidget(
                                    name: getTranslated(
                                      context,
                                      "nameAr",
                                    ),
                                    colorInput: AppColors.grey,
                                    controller: nameArController,
                                    context: context,
                                    onTap: () {},
                                  ),
                                  SizedBox(height: AppSize.h29_3.h),
                                ],
                              )
                            : SizedBox(),
                        english
                            ? Column(
                                children: [
                                  TextFormFieldWidget(
                                      colorInput: AppColors.grey,
                                      name: getTranslated(context, "nameEn"),
                                      controller: nameEnController,
                                      context: context,
                                      onTap: () {}),
                                  SizedBox(height: AppSize.h29_3.h),
                                ],
                              )
                            : SizedBox(),
                        french
                            ? Column(
                                children: [
                                  TextFormFieldWidget(
                                      colorInput: AppColors.grey,
                                      name: getTranslated(context, "nameFr"),
                                      controller: nameFrController,
                                      context: context,
                                      onTap: () {}),
                                  SizedBox(height: AppSize.h29_3.h),
                                ],
                              )
                            : SizedBox(),
                        indonesian
                            ? Column(
                                children: [
                                  TextFormFieldWidget(
                                      colorInput: AppColors.grey,
                                      name: getTranslated(context, "nameId"),
                                      controller: nameIdController,
                                      context: context,
                                      onTap: () {}),
                                  SizedBox(height: AppSize.h29_3.h),
                                ],
                              )
                            : SizedBox(),
                        arabic
                            ? Column(
                                children: [
                                  TextFormFieldWidget(
                                    name: getTranslated(
                                      context,
                                      "arNationality",
                                    ),
                                    colorInput: AppColors.grey,
                                    controller: arNationality,
                                    context: context,
                                    onTap: () {},
                                  ),
                                  SizedBox(height: AppSize.h29_3.h),
                                ],
                              )
                            : SizedBox(),
                        english
                            ? Column(
                                children: [
                                  TextFormFieldWidget(
                                      colorInput: AppColors.grey,
                                      name: getTranslated(
                                          context, "enNationality"),
                                      controller: enNationality,
                                      context: context,
                                      onTap: () {}),
                                  SizedBox(height: AppSize.h29_3.h),
                                ],
                              )
                            : SizedBox(),
                        french
                            ? Column(
                                children: [
                                  TextFormFieldWidget(
                                      colorInput: AppColors.grey,
                                      name: getTranslated(
                                          context, "frNationality"),
                                      controller: frNationality,
                                      context: context,
                                      onTap: () {}),
                                  SizedBox(height: AppSize.h29_3.h),
                                ],
                              )
                            : SizedBox(),
                        indonesian
                            ? Column(
                                children: [
                                  TextFormFieldWidget(
                                      colorInput: AppColors.grey,
                                      name: getTranslated(
                                          context, "idNationality"),
                                      controller: idNationality,
                                      context: context,
                                      onTap: () {}),
                                  SizedBox(height: AppSize.h29_3.h),
                                ],
                              )
                            : SizedBox(),

                        // arabic
                        //     ? Column(
                        //         children: [
                        //           TextFormFieldWidget(
                        //             name:
                        //                 getTranslated(context, "arNationality"),
                        //             controller: arNationality,
                        //             context: context,
                        //             onTap: () {},
                        //           ),
                        //           SizedBox(
                        //             height: AppSize.h42_6.h,
                        //           ),
                        //         ],
                        //       )
                        //     : SizedBox(),
                        //
                        // english
                        //     ? Column(
                        //         children: [
                        //           TextFormFieldWidget(
                        //             name:
                        //                 getTranslated(context, "enNationality"),
                        //             controller: enNationality,
                        //             context: context,
                        //             onTap: () {},
                        //           ),
                        //           SizedBox(
                        //             height: AppSize.h42_6.h,
                        //           ),
                        //         ],
                        //       )
                        //     : SizedBox(),
                        // french
                        //     ? Column(
                        //         children: [
                        //           TextFormFieldWidget(
                        //             name:
                        //                 getTranslated(context, "frNationality"),
                        //             controller: frNationality,
                        //             context: context,
                        //             onTap: () {},
                        //           ),
                        //           SizedBox(
                        //             height: AppSize.h42_6.h,
                        //           ),
                        //         ],
                        //       )
                        //     : SizedBox(),
                        // indonesian
                        //     ? Column(
                        //         children: [
                        //           TextFormFieldWidget(
                        //             name:
                        //                 getTranslated(context, "idNationality"),
                        //             controller: idNationality,
                        //             context: context,
                        //             onTap: () {},
                        //           ),
                        //           SizedBox(
                        //             height: AppSize.h42_6.h,
                        //           ),
                        //         ],
                        //       )
                        //     : SizedBox(),
                        // TextFormFieldWidget(
                        //     name: getTranslated(context, "voicePrice"),
                        //     controller: voicePriceController,
                        //     context: context,
                        //     onTap: () {},
                        //     isNumber: true),
                        // SizedBox(
                        //   height: AppSize.h42_6.h,
                        // ),
                        // TextFormFieldWidget(
                        //   name: getTranslated(context, "chatPrice"),
                        //   controller: chatPriceController,
                        //   context: context,
                        //   onTap: () {},
                        //   isNumber: true,
                        // ),
                        //SizedBox(height: AppSize.h42.h),
                        arabic
                            ? Column(
                                children: [
                                  TextFormFieldWidget(
                                      heightTextFieled: AppSize.h153_3.h,
                                      name: getTranslated(context, "bioAr"),
                                      controller: bioArController,
                                      context: context,
                                      colorInput: AppColors.grey,
                                      onTap: () {},
                                      lines: 5),
                                  SizedBox(height: AppSize.h29_3.h),
                                ],
                              )
                            : SizedBox(),
                        english
                            ? Column(
                                children: [
                                  TextFormFieldWidget(
                                      name: getTranslated(context, "bioEn"),
                                      heightTextFieled: AppSize.h153_3.h,
                                      controller: bioEnController,
                                      context: context,
                                      onTap: () {},
                                      lines: 5),
                                  SizedBox(height: AppSize.h29_3.h),
                                ],
                              )
                            : SizedBox(),
                        french
                            ? Column(
                                children: [
                                  TextFormFieldWidget(
                                      heightTextFieled: AppSize.h153_3.h,
                                      name: getTranslated(context, "bioFr"),
                                      controller: bioFrController,
                                      context: context,
                                      onTap: () {},
                                      lines: 5),
                                  SizedBox(height: AppSize.h29_3.h),
                                ],
                              )
                            : SizedBox(),
                        indonesian
                            ? Column(
                                children: [
                                  TextFormFieldWidget(
                                      heightTextFieled: AppSize.h153_3.h,
                                      name: getTranslated(context, "bioId"),
                                      controller: bioIdController,
                                      context: context,
                                      onTap: () {},
                                      lines: 5),
                                  SizedBox(height: AppSize.h29_3.h),
                                ],
                              )
                            : SizedBox(),

                        Container(
                          width: double.infinity,
                          // padding: const EdgeInsets.symmetric(
                          //   horizontal: AppPadding.p15,
                          // ),
                          height: accountTypeOpen ? null : AppSize.h75.h,

                          decoration: BoxDecoration(
                              color: AppColors.white,
                              //border: Border(color: AppColors.darkGrey, width: 1.w),

                              borderRadius: new BorderRadius.circular(15.r)),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              contentPadding: accountTypeOpen
                                  ? EdgeInsets.symmetric(
                                      horizontal: AppSize.w21_3.w,
                                      vertical: AppSize.h21_3.h)
                                  : EdgeInsets.only(
                                      right: AppSize.w21_3.w,
                                      left: AppSize.h21_3.h,
                                      top: AppSize.h32.h),
                              // <-- SEE HERE

                              labelText: getTranslated(context, "accountType"),
                              labelStyle: TextStyle(
                                fontFamily: lang == "ar"
                                    ? getTranslated(context, "Ithra")
                                    : getTranslated(context, "Montserratbold"),
                                fontSize: AppFontsSizeManager.s21_3.sp,
                                color: AppColors.pink,
                                // fontWeight: FontWeight.bold,
                              ),

                              enabledBorder: new OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: AppSize.w0_5.w,
                                    color: AppColors.warmGrey),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r10_6.r),
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        accountTypeOpen = !accountTypeOpen;
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          typeController.text,
                                          style: TextStyle(
                                            fontFamily: getTranslated(
                                                context, 'Ithralight'),
                                            fontSize:
                                                AppFontsSizeManager.s21_3.sp,
                                            color: AppColors.darkGrey,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        InkWell(
                                            onTap: () {
                                              setState(() {
                                                accountTypeOpen =
                                                    !accountTypeOpen;
                                              });
                                            },
                                            child: Icon(
                                              accountTypeOpen
                                                  ? Icons.keyboard_arrow_up
                                                  : Icons.keyboard_arrow_down,
                                              color: AppColors.linear2,
                                              //size: AppSize.w32.r,
                                            )),
                                      ],
                                    ),
                                  ),
                                  height: AppSize.h32.h,
                                ),

                                // TextFormField(
                                //   controller: typeController,
                                //   onTap: () {
                                //     setState(() {
                                //       accountTypeOpen = !accountTypeOpen;
                                //     });
                                //   },
                                //   textAlignVertical: TextAlignVertical.center,
                                //   validator: (String? val) {
                                //     if (val!.trim().isEmpty) {
                                //       return 'This field is required';
                                //     }
                                //     return null;
                                //   },
                                //   readOnly: true,
                                //   enableInteractiveSelection: true,
                                //   style: style(size),
                                //   maxLines: 1,
                                //   textInputAction: TextInputAction.newline,
                                //   keyboardType: TextInputType.multiline,
                                //   decoration: InputDecoration(
                                //     suffixIcon: Icon(
                                //       accountTypeOpen
                                //           ? Icons.keyboard_arrow_up
                                //           : Icons.keyboard_arrow_down,
                                //       color: AppColors.linear2,
                                //     ),
                                //     contentPadding: EdgeInsets.all(AppPadding.p10),
                                //     errorStyle: style(size),
                                //     hintStyle: style(size),
                                //     labelText:
                                //         getTranslated(context, "accountType"),
                                //     labelStyle: TextStyle(
                                //       fontFamily: getTranslated(context, 'Ithra'),
                                //       fontSize: AppFontsSizeManager.s21_3.sp,
                                //       color: AppColors.pink,
                                //       fontWeight: FontWeight.bold,
                                //     ),
                                //     enabledBorder: new OutlineInputBorder(
                                //       borderSide: BorderSide(
                                //           width: AppSize.w0_5.w,
                                //           color: AppColors.warmGrey),
                                //       borderRadius:
                                //           BorderRadius.circular(AppRadius.r10_6.r),
                                //     ),
                                //     focusedBorder: new OutlineInputBorder(
                                //       borderSide: BorderSide(
                                //           width: AppSize.w0_5.w,
                                //           color: AppColors.warmPurple4),
                                //       borderRadius:
                                //           BorderRadius.circular(AppRadius.r10_6.r),
                                //     ),
                                //     border: OutlineInputBorder(
                                //       borderSide:
                                //           BorderSide(color: AppColors.greyDark),
                                //       borderRadius:
                                //           BorderRadius.circular(AppRadius.r10_6.r),
                                //     ),
                                //   ),
                                // ),
                                SizedBox(
                                  height: AppSize.h10.h,
                                ),
                                accountTypeOpen
                                    ? _showTypes(context, size)
                                    : SizedBox(),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: AppSize.h29_3.h,
                        ),
                        Container(
                          width: double.infinity,
                          // padding: const EdgeInsets.symmetric(
                          //   horizontal: AppPadding.p15,
                          // ),
                          height: packagesOpen ? null : AppSize.h75.h,

                          decoration: BoxDecoration(
                              color: AppColors.white,
                              //border: Border(color: AppColors.darkGrey, width: 1.w),

                              borderRadius: new BorderRadius.circular(15.r)),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              contentPadding: packagesOpen
                                  ? EdgeInsets.symmetric(
                                      horizontal: AppSize.w21_3.w,
                                      vertical: AppSize.h21_3.h)
                                  : EdgeInsets.only(
                                      right: AppSize.w21_3.w,
                                      left: AppSize.h21_3.h,
                                      top: AppSize.h32.h), // <-- SEE HERE

                              labelText: getTranslated(context, "allPackages"),
                              labelStyle: TextStyle(
                                fontFamily: lang == "ar"
                                    ? getTranslated(context, "Ithra")
                                    : getTranslated(context, "Montserratbold"),
                                fontSize: AppFontsSizeManager.s21_3.sp,
                                color: AppColors.pink,
                                //fontWeight: FontWeight.bold,
                              ),
                              enabledBorder: new OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: AppSize.w0_5.w,
                                    color: AppColors.warmGrey),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r10_6.r),
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        packagesOpen = !packagesOpen;
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          getTranslated(
                                              context, "selectPackagePriceTxt"),
                                          style: TextStyle(
                                            fontFamily: getTranslated(
                                                context, 'Ithralight'),
                                            fontSize:
                                                AppFontsSizeManager.s21_3.sp,
                                            color: AppColors.darkGrey,
                                            //fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        InkWell(
                                            onTap: () {
                                              setState(() {
                                                packagesOpen = !packagesOpen;
                                              });
                                            },
                                            child: Icon(
                                              packagesOpen
                                                  ? Icons.keyboard_arrow_up
                                                  : Icons.keyboard_arrow_down,
                                              color: AppColors.linear2,
                                            )),
                                      ],
                                    ),
                                  ),
                                  height: AppSize.h32.h,
                                ),
                                // TextFormField(
                                //   controller: packagePriceController,
                                //   onTap: () {
                                //     setState(() {
                                //       packagesOpen = !packagesOpen;
                                //     });
                                //   },
                                //   textAlignVertical: TextAlignVertical.center,
                                //   validator: (String? val) {
                                //     if (val!.trim().isEmpty) {
                                //       return 'This field is required';
                                //     }
                                //     return null;
                                //   },
                                //   readOnly: true,
                                //   enableInteractiveSelection: true,
                                //   style: style(size),
                                //   maxLines: 1,
                                //   textInputAction: TextInputAction.newline,
                                //   keyboardType: TextInputType.multiline,
                                //   decoration: InputDecoration(
                                //     suffixIcon: Icon(
                                //       packagesOpen
                                //           ? Icons.keyboard_arrow_up
                                //           : Icons.keyboard_arrow_down,
                                //       color: AppColors.linear2,
                                //     ),
                                //     contentPadding: EdgeInsets.all(AppPadding.p10),
                                //     errorStyle: style(size),
                                //     hintStyle: style(size),
                                //     labelText: "الباقات",
                                //     labelStyle: TextStyle(
                                //       fontFamily: getTranslated(context, 'Ithra'),
                                //       fontSize: AppFontsSizeManager.s21_3.sp,
                                //       color: AppColors.pink,
                                //       fontWeight: FontWeight.bold,
                                //     ),
                                //     enabledBorder: new OutlineInputBorder(
                                //       borderSide: BorderSide(
                                //           width: AppSize.w0_5.w,
                                //           color: AppColors.warmGrey),
                                //       borderRadius:
                                //           BorderRadius.circular(AppRadius.r10_6.r),
                                //     ),
                                //     focusedBorder: new OutlineInputBorder(
                                //       borderSide: BorderSide(
                                //           width: AppSize.w0_5.w,
                                //           color: AppColors.warmPurple4),
                                //       borderRadius:
                                //           BorderRadius.circular(AppRadius.r10_6.r),
                                //     ),
                                //     border: OutlineInputBorder(
                                //       borderSide:
                                //           BorderSide(color: AppColors.greyDark),
                                //       borderRadius:
                                //           BorderRadius.circular(AppRadius.r10_6.r),
                                //     ),
                                //   ),
                                // ),

                                packagesOpen
                                    ? selectPackagesPrice(context, size)
                                    : SizedBox(),
                              ],
                            ),
                          ),
                        ),

                        // tabbedText(
                        //     "consaultant_details_widgets",
                        //     getTranslated(context, "accountType"),
                        //     typeController),
                        SizedBox(
                          height: AppSize.h29_3.h,
                        ),
                        Container(
                          width: double.infinity,
                          // padding: const EdgeInsets.symmetric(
                          //   horizontal: AppPadding.p15,
                          // ),
                          height: workDaysOpen ? null : AppSize.h75.h,

                          decoration: BoxDecoration(
                              color: AppColors.white,
                              //border: Border(color: AppColors.darkGrey, width: 1.w),

                              borderRadius: new BorderRadius.circular(15.r)),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              contentPadding: workDaysOpen
                                  ? EdgeInsets.symmetric(
                                      horizontal: AppSize.w21_3.w,
                                      vertical: AppSize.h21_3.h)
                                  : EdgeInsets.only(
                                      right: AppSize.w21_3.w,
                                      left: AppSize.h21_3.h,
                                      top: AppSize.h32.h), // <-- SEE HERE

                              labelText: getTranslated(context, "daysOfWork"),
                              labelStyle: TextStyle(
                                fontFamily: lang == "ar"
                                    ? getTranslated(context, "Ithra")
                                    : getTranslated(context, "Montserratbold"),
                                fontSize: AppFontsSizeManager.s21_3.sp,
                                color: AppColors.pink,
                                fontWeight: FontWeight.bold,
                              ),
                              enabledBorder: new OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: AppSize.w0_5.w,
                                    color: AppColors.warmGrey),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r10_6.r),
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        workDaysOpen = !workDaysOpen;
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            daysController.text,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: getTranslated(
                                                  context, 'Ithralight'),
                                              fontSize:
                                                  AppFontsSizeManager.s21_3.sp,
                                              color: AppColors.darkGrey,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                            onTap: () {
                                              setState(() {
                                                workDaysOpen = !workDaysOpen;
                                              });
                                            },
                                            child: Icon(
                                              workDaysOpen
                                                  ? Icons.keyboard_arrow_up
                                                  : Icons.keyboard_arrow_down,
                                              color: AppColors.linear2,
                                            )),
                                      ],
                                    ),
                                  ),
                                  height: AppSize.h32.h,
                                ),

                                // TextFormField(
                                //   controller: daysController,
                                //   onTap: () {
                                //     setState(() {
                                //       workDaysOpen = !workDaysOpen;
                                //     });
                                //   },
                                //   textAlignVertical: TextAlignVertical.center,
                                //   validator: (String? val) {
                                //     if (val!.trim().isEmpty) {
                                //       return 'This field is required';
                                //     }
                                //     return null;
                                //   },
                                //   readOnly: true,
                                //   enableInteractiveSelection: true,
                                //   style: style(size),
                                //   maxLines: 1,
                                //   textInputAction: TextInputAction.newline,
                                //   keyboardType: TextInputType.multiline,
                                //   decoration: InputDecoration(
                                //     suffixIcon: Icon(
                                //       workDaysOpen
                                //           ? Icons.keyboard_arrow_up
                                //           : Icons.keyboard_arrow_down,
                                //       color: AppColors.linear2,
                                //     ),
                                //     contentPadding: EdgeInsets.all(AppPadding.p10),
                                //     errorStyle: style(size),
                                //     hintStyle: style(size),
                                //     labelText: getTranslated(context, "timeOfWork"),
                                //     labelStyle: TextStyle(
                                //       fontFamily: getTranslated(context, 'Ithra'),
                                //       fontSize: AppFontsSizeManager.s21_3.sp,
                                //       color: AppColors.pink,
                                //       fontWeight: FontWeight.bold,
                                //     ),
                                //     enabledBorder: new OutlineInputBorder(
                                //       borderSide: BorderSide(
                                //           width: AppSize.w0_5.w,
                                //           color: AppColors.warmGrey),
                                //       borderRadius:
                                //           BorderRadius.circular(AppRadius.r10_6.r),
                                //     ),
                                //     focusedBorder: new OutlineInputBorder(
                                //       borderSide: BorderSide(
                                //           width: AppSize.w0_5.w,
                                //           color: AppColors.warmPurple4),
                                //       borderRadius:
                                //           BorderRadius.circular(AppRadius.r10_6.r),
                                //     ),
                                //     border: OutlineInputBorder(
                                //       borderSide:
                                //           BorderSide(color: AppColors.greyDark),
                                //       borderRadius:
                                //           BorderRadius.circular(AppRadius.r10_6.r),
                                //     ),
                                //   ),
                                // ),
                                SizedBox(
                                  height: AppSize.h10.h,
                                ),
                                workDaysOpen
                                    ? _show(context, size)
                                    : SizedBox(),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: AppSize.h42_6.h,
                        ),
                        // tabbedText("time", getTranslated(context, "timeOfWork"),
                        //     daysController),
                        Center(
                          child: Text(
                            getTranslated(context, "worksHoursTxt"),
                            style: TextStyle(
                                color: AppColors.linear2,
                                fontSize: AppFontsSizeManager.s21_3.sp,
                                fontFamily: lang == "ar"
                                    ? getTranslated(context, "Ithra")
                                    : getTranslated(context, "Montserratbold")),
                          ),
                        ),

                        SizedBox(
                          height: AppSize.h21_3.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getTranslated(context, "from"),
                              style: TextStyle(
                                fontFamily: getTranslated(context, 'Ithra'),
                                fontSize: AppFontsSizeManager.s21_3.sp,
                                color: AppColors.pink,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                            //SizedBox(width: AppSize.w21_3.w,),
                            SizedBox(
                              width: AppSize.w21_3.w,
                            ),
                            Expanded(
                              child: SizedBox(
                                  height: AppSize.h53_3.h,
                                  child: TextFormField(
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: AppFontsSizeManager.s18.sp,
                                      fontFamily: lang == "ar"
                                          ? getTranslated(context, "Ithralight")
                                          : getTranslated(
                                              context, "Montserratmedium"),
                                      color: AppColors.linear8,
                                    ),
                                    controller: fromController,
                                    onTap: () {
                                      _selectTimeFrom(context);
                                    },
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: AppSize.h10.h,
                                      ),
                                      enabledBorder: new OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: AppSize.w0_5,
                                            color: AppColors.grey3),
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.r5_3.r),
                                      ),
                                      focusedBorder: new OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: AppSize.w0_5,
                                            color: AppColors.warmPurple4),
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.r5_3.r),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: AppColors.grey3),
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.r5_3.r),
                                      ),
                                    ),
                                  )
                                  // TextFormFieldWidget(
                                  //   textAlign: TextAlign.center,
                                  //
                                  //   onTap: () {
                                  //     _selectTimeFrom(context);
                                  //   },
                                  //   isReadOnly: true,
                                  //   controller: fromController,
                                  //   context: context,
                                  //   radius: AppRadius.r5_3.r,
                                  //   name: '',
                                  //   fontSize: AppFontsSizeManager.s18_6,
                                  //   fontColor: AppColors.pink,
                                  //   horizontalPadding: AppPadding.p0.h,
                                  //   verticalPadding: 0.h,
                                  // ),
                                  ),
                            ),
                            //SizedBox(width: AppSize.w21_3.w,),
                            SizedBox(
                              width: AppSize.w21_3.w,
                            ),
                            Text(
                              getTranslated(context, "to"),
                              style: TextStyle(
                                fontFamily: getTranslated(context, 'Ithra'),
                                fontSize: AppFontsSizeManager.s21_3.sp,
                                color: AppColors.pink,
                                // fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            //SizedBox(width: AppSize.w21_3.w,),
                            SizedBox(
                              width: AppSize.w21_3.w,
                            ),
                            Expanded(
                              child: SizedBox(
                                  height: AppSize.h53_3.h,
                                  child: TextFormField(
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: AppFontsSizeManager.s18.sp,
                                      fontFamily: lang == "ar"
                                          ? getTranslated(context, "Ithralight")
                                          : getTranslated(
                                              context, "Montserratmedium"),
                                      color: AppColors.linear8,
                                    ),
                                    controller: toController,
                                    onTap: () {
                                      _selectTimeTo(context);
                                    },
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: AppSize.h10.h,
                                      ),
                                      enabledBorder: new OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: AppSize.w0_5,
                                            color: AppColors.grey3),
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.r5_3.r),
                                      ),
                                      focusedBorder: new OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: AppSize.w0_5,
                                            color: AppColors.warmPurple4),
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.r5_3.r),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: AppColors.grey3),
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.r5_3.r),
                                      ),
                                    ),
                                  )
                                  // TextFormFieldWidget(
                                  //   textAlign: TextAlign.center,
                                  //   onTap: () {
                                  //     _selectTimeTo(context);
                                  //   },
                                  //   isReadOnly: true,
                                  //   controller: toController,
                                  //   context: context,
                                  //   name: '',
                                  //
                                  //   fontSize: AppFontsSizeManager.s18_6,
                                  //   radius: AppRadius.r5_3.r,
                                  //   fontColor: AppColors.pink,
                                  // ),
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: AppSize.h42_6.h,
                        ),
                        Row(
                          children: [
                            InkWell(
                                onTap: () {
                                  showDeleteConfimationDialog(size);
                                },
                                child: Image.asset(
                                  AssetsManager.deleteRed,
                                  // color: Colors.red,
                                  width: AppSize.w32.w,
                                  height: AppSize.h32.h,
                                )),
                            SizedBox(width: AppSize.w5_3.w),
                            Padding(
                              padding: EdgeInsets.only(top: AppPadding.p6.h),
                              child: Text(
                                getTranslated(context, "deleteAccount"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: getTranslated(context, 'Ithra'),
                                    fontSize: AppFontsSizeManager.s21_3.sp,
                                    color: AppColors.appbartext,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: AppSize.h21_3.h,
                        ),
                        Center(
                          child: saving
                              ? CircularProgressIndicator()
                              : textButton(
                                  onPress: () {
                                    save();
                                  },
                                  text:
                                      getTranslated(context, "saveAndContinue"),
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
                        ),
                        SizedBox(
                          height: AppSize.h42_6.h,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  tabbedText(String type, String name, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      onTap: () {
        if (type == "lang")
          _showLang(context, size);
        else if (type == "consaultant_details_widgets")
          _showTypes(context, size);
        else
          _show(context, size);
      },
      textAlignVertical: TextAlignVertical.center,
      validator: (String? val) {
        if (val!.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      readOnly: true,
      enableInteractiveSelection: true,
      style: style(size),
      maxLines: 1,
      textInputAction: TextInputAction.newline,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(AppPadding.p10),
        errorStyle: style(size),
        hintStyle: style(size),
        labelText: name,
        labelStyle: TextStyle(
          fontFamily: getTranslated(context, 'Ithra'),
          fontSize: AppFontsSizeManager.s21_3.sp,
          color: AppColors.pink,
          fontWeight: FontWeight.bold,
        ),
        enabledBorder: new OutlineInputBorder(
          borderSide:
              BorderSide(width: AppSize.w0_5.w, color: AppColors.warmGrey),
          borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
        ),
        focusedBorder: new OutlineInputBorder(
          borderSide:
              BorderSide(width: AppSize.w0_5.w, color: AppColors.warmPurple4),
          borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.greyDark),
          borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
        ),
      ),
    );
  }

  TextStyle style(Size size) {
    return TextStyle(
        fontFamily: getTranslated(context, 'Ithralight'),
        fontSize: AppFontsSizeManager.s21_3.sp,
        color: AppColors.darkGrey,
        fontWeight: FontWeight.normal);
  }

  Widget getTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: AppPadding.p5),
      child: Center(
        child: Container(
          height: AppSize.h30.h,
          width: size.width * .30,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.r15.r),
            boxShadow: [AppShadow.primaryShadow],
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: getTranslated(context, 'Ithra'),
                  fontSize: AppFontsSizeManager.s13.sp,
                  color: AppColors.pink,
                  fontWeight: FontWeight.normal),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration() {
    return InputDecoration(
        fillColor: AppColors.white,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r15.r),
          borderSide: BorderSide(
            color: AppColors.grey6,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r15.r),
          borderSide: BorderSide(
            color: AppColors.grey6,
            width: AppSize.w1.w,
          ),
        ));
  }

  nameCutting(String name, String langName) async {
    // print("Method 1");
    List<String> indexList = [];
    for (int y = 1;
        y <= name.replaceAll('.', '').trimLeft().trimRight().length;
        y++) {
      indexList.add(name
          .replaceAll('.', '')
          .trimLeft()
          .trimRight()
          .substring(0, y)
          .toLowerCase());
    }

    List<String> splitName = name.split(' ');

    List<String> nameList = [];

    for (int i = 1; i < splitName.length; i++) {
      String name1 = splitName[i];

      for (int x = i + 1; x < splitName.length; x++) {
        name1 = name1 + " " + splitName[x];
        indexList.add(name1);
      }
      nameList.add(name1);
    }

    for (int v = 0; v < nameList.length; v++) {
      for (int z = 1;
          z <= nameList[v].replaceAll('.', '').trimLeft().trimRight().length;
          z++) {
        indexList.add(nameList[v]
            .replaceAll('.', '')
            .trimLeft()
            .trimRight()
            .substring(0, z)
            .toLowerCase());
      }
    }

    if (langName == "ar")
      setState(() {
        searchAr = indexList;
      });
    else if (langName == "en")
      setState(() {
        searchEn = indexList;
      });
    else if (langName == "fr")
      setState(() {
        searchFr = indexList;
      });
    else if (langName == "id")
      setState(() {
        searchId = indexList;
      });

    /*  print("nameee ${langName} = ${indexList}");
    print("name  ${langName} = $name");*/
  }

  save() async {
    setState(() {
      saving = true;
    });
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (arabic) {
        setState(() {
          nameAr = nameArController.text;
          bioAr = bioArController.text;
          nationalityAr = arNationality.text;
        });
      } else {
        setState(() {
          nameAr = "";
          bioAr = "";
          //nationalityAr = "";
        });
      }

      if (english) {
        setState(() {
          nameEn = nameEnController.text;
          bioEn = bioEnController.text;
          //nationalityEn = enNationality.text;
        });
      } else {
        setState(() {
          nameEn = "";
          bioEn = "";
          //nationalityEn = "";
        });
      }

      if (french) {
        setState(() {
          nameFr = nameFrController.text;
          bioFr = bioFrController.text;
          //nationalityFr = frNationality.text;
        });
      } else {
        setState(() {
          nameFr = "";
          bioFr = "";
          //nationalityFr = "";
        });
      }

      if (indonesian) {
        setState(() {
          nameId = nameIdController.text;
          bioId = bioIdController.text;
          //nationalityId = idNationality.text;
        });
      } else {
        setState(() {
          nameId = "";
          bioId = "";
          //nationalityId = "";
        });
      }

      await nameCutting(nameAr, "ar");
      await nameCutting(nameEn, "en");
      await nameCutting(nameFr, "fr");
      await nameCutting(nameId, "id");

      widget.user.consultName = ConsultName(
        nameAr: nameAr,
        nameEn: nameEn,
        nameFr: nameFr,
        nameId: nameId,
        searchIndexAr: searchAr,
        searchIndexEn: searchEn,
        searchIndexFr: searchFr,
        searchIndexId: searchId,
      );
      widget.user.consultBio = ConsultBio(
        bioAr: bioAr,
        bioEn: bioEn,
        bioFr: bioFr,
        bioId: bioId,
      );
      // widget.user.consultNationality = ConsultNationality(
      //   nationalityAr: nationalityAr,
      //   nationalityEn: nationalityEn,
      //   nationalityFr: nationalityFr,
      //   nationalityId: nationalityId,
      // );
      //============voice packages
      if (voicePriceController.text != price && allowVoice) {
        widget.user.price = voicePriceController.text;
        var querySnapshot = await FirebaseFirestore.instance
            .collection(Paths.packagesPath)
            .where('consultUid', isEqualTo: widget.user.uid)
            .where('type', isEqualTo: "voice")
            .get();

        if (querySnapshot.docs.length > 0) {
          for (var doc in querySnapshot.docs) {
            var discount = ((doc['callNum'] * int.parse(widget.user.price!)) *
                    doc['discount']) /
                100;
            double price =
                (doc['callNum'] * int.parse(widget.user.price!)) - discount;
            FirebaseFirestore.instance
                .collection(Paths.packagesPath)
                .doc(doc.id)
                .update({
              'price': price,
            });
          }
        } else {
          var discount = 0.0;
          var packageId0 = Uuid().v4();
          await FirebaseFirestore.instance
              .collection(Paths.packagesPath)
              .doc(packageId0)
              .set({
            'price': double.parse(widget.user.price.toString()),
            'discount': 0,
            'callNum': 1,
            'type': "voice",
            'consultUid': widget.user.uid,
            'Id': packageId0,
            'active': true,
          }, SetOptions(merge: true));

          var packageId1 = Uuid().v4();
          discount = (3 * double.parse(widget.user.price!) * 5) / 100;
          await FirebaseFirestore.instance
              .collection(Paths.packagesPath)
              .doc(packageId1)
              .set({
            'price': 3 * double.parse(widget.user.price!) - discount,
            'discount': 5,
            'callNum': 3,
            "type": "voice",
            'consultUid': widget.user.uid,
            'Id': packageId1,
            'active': true,
          }, SetOptions(merge: true));

          var packageId2 = Uuid().v4();
          discount = (5 * double.parse(widget.user.price!) * 10) / 100;
          await FirebaseFirestore.instance
              .collection(Paths.packagesPath)
              .doc(packageId2)
              .set({
            'price': 5 * double.parse(widget.user.price!) - discount,
            'discount': 10,
            'callNum': 5,
            'type': "voice",
            'consultUid': widget.user.uid,
            'Id': packageId2,
            'active': true,
          }, SetOptions(merge: true));

          var packageId3 = Uuid().v4();
          discount = (20 * double.parse(widget.user.price!) * 25) / 100;
          await FirebaseFirestore.instance
              .collection(Paths.packagesPath)
              .doc(packageId3)
              .set({
            'price': 20 * double.parse(widget.user.price!) - discount,
            'discount': 25,
            'callNum': 20,
            "type": "voice",
            'consultUid': widget.user.uid,
            'Id': packageId3,
            'active': true,
          }, SetOptions(merge: true));
        }
      }
      //=============chat packages
      if (chatPriceController.text != chatPrice && allowChat) {
        widget.user.chatPrice = chatPriceController.text;
        var querySnapshot = await FirebaseFirestore.instance
            .collection(Paths.packagesPath)
            .where('consultUid', isEqualTo: widget.user.uid)
            .where('type', isEqualTo: "chat")
            .get();

        if (querySnapshot.docs.length > 0) {
          for (var doc in querySnapshot.docs) {
            var discount =
                ((doc['callNum'] * int.parse(widget.user.chatPrice!)) *
                        doc['discount']) /
                    100;
            double price =
                (doc['callNum'] * int.parse(widget.user.chatPrice!)) - discount;
            FirebaseFirestore.instance
                .collection(Paths.packagesPath)
                .doc(doc.id)
                .update({
              'price': price,
            });
          }
        } else {
          var discount = 0.0;
          var packageId0 = Uuid().v4();
          await FirebaseFirestore.instance
              .collection(Paths.packagesPath)
              .doc(packageId0)
              .set({
            'price': double.parse(widget.user.chatPrice.toString()),
            'discount': 0,
            'callNum': 1,
            'type': "chat",
            'consultUid': widget.user.uid,
            'Id': packageId0,
            'active': true,
          }, SetOptions(merge: true));

          var packageId1 = Uuid().v4();
          discount = (3 * double.parse(widget.user.chatPrice!) * 5) / 100;
          await FirebaseFirestore.instance
              .collection(Paths.packagesPath)
              .doc(packageId1)
              .set({
            'price': 3 * double.parse(widget.user.chatPrice!) - discount,
            'discount': 5,
            'callNum': 3,
            "type": "chat",
            'consultUid': widget.user.uid,
            'Id': packageId1,
            'active': true,
          }, SetOptions(merge: true));

          var packageId2 = Uuid().v4();
          discount = (5 * double.parse(widget.user.chatPrice!) * 10) / 100;
          await FirebaseFirestore.instance
              .collection(Paths.packagesPath)
              .doc(packageId2)
              .set({
            'price': 5 * double.parse(widget.user.chatPrice!) - discount,
            'discount': 10,
            'callNum': 5,
            'type': "chat",
            'consultUid': widget.user.uid,
            'Id': packageId2,
            'active': true,
          }, SetOptions(merge: true));

          var packageId3 = Uuid().v4();
          discount = (20 * double.parse(widget.user.chatPrice!) * 25) / 100;
          await FirebaseFirestore.instance
              .collection(Paths.packagesPath)
              .doc(packageId3)
              .set({
            'price': 20 * double.parse(widget.user.chatPrice!) - discount,
            'discount': 25,
            'callNum': 20,
            "type": "chat",
            'consultUid': widget.user.uid,
            'Id': packageId3,
            'active': true,
          }, SetOptions(merge: true));
        }
      }
      var datenow = DateTime.now();
      _workTime.from = from;
      _workTime.to = to;
      widget.user.voice = allowVoice;
      widget.user.chat = allowChat;
      widget.user.workTimes!.clear();
      widget.user.workTimes!.add(_workTime);
      widget.user.name = nameArController.text;
      widget.user.bio = bioArController.text;
      widget.user.nationality = arNationality.text;

      widget.user.workDays = daysValue;

      widget.user.profileCompleted = true;
      widget.user.userLang = getTranslated(context, 'lang');
      if (widget.user.order == null) widget.user.order = 0;
      //=============
      widget.user.fromUtc = DateTime(
              datenow.year, datenow.month, datenow.day, int.parse(from), 0, 0)
          .toUtc()
          .toString();
      widget.user.toUtc = DateTime(
              datenow.year, datenow.month, datenow.day, int.parse(to), 0, 0)
          .toUtc()
          .toString();
      setState(() {
        dataSave = true;
      });
      print(widget.user.consultNationality!.nationalityAr);
      if (selectedProfileImage != null) {
        accountBloc.add(UpdateAccountDetailsEvent(
            user: widget.user, profileImage: selectedProfileImage));
      } else {
        accountBloc.add(UpdateAccountDetailsEvent(user: widget.user));
      }
    }
    setState(() {
      saving = false;
    });
  }

  _selectTimeFrom(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: _workTime.from == null
          ? selectedTime
          : TimeOfDay(
              hour: int.parse(widget.user.workTimes![0].from!), minute: 0),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeOfDay != null) {
      setState(() {
        from = timeOfDay.hour.toString();
        if (timeOfDay.hour == 12)
          fromController.text = "12 ${getTranslated(context, 'pm')}";
        else if (timeOfDay.hour == 0)
          fromController.text = "12 ${getTranslated(context, 'am')}";
        else if (timeOfDay.hour > 12)
          fromController.text = (timeOfDay.hour - 12).toString() +
              " ${getTranslated(context, 'pm')}";
        else
          fromController.text =
              timeOfDay.hour.toString() + " ${getTranslated(context, 'am')}";
      });
    }
  }

  _selectTimeTo(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: _workTime.to == null
          ? selectedTime
          : TimeOfDay(
              hour: int.parse(widget.user.workTimes![0].to!), minute: 0),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeOfDay != null) {
      setState(() {
        to = timeOfDay.hour.toString();
        if (timeOfDay.hour == 12)
          toController.text = "12 ${getTranslated(context, 'pm')}";
        else if (timeOfDay.hour == 0)
          toController.text = "12 ${getTranslated(context, 'am')}";
        else if (timeOfDay.hour > 12)
          toController.text = (timeOfDay.hour - 12).toString() +
              " ${getTranslated(context, 'pm')}";
        else
          toController.text =
              timeOfDay.hour.toString() + " ${getTranslated(context, 'am')}";
      });
    }
  }

  Widget _show(BuildContext ctx, size) {
    return StatefulBuilder(builder: (context, setState) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: AppSize.h16.h,
            ),
            Container(
              width: AppSize.w473.w,
              height: AppSize.h1_5.h,
              color: AppColors.lightGray,
            ),
            SizedBox(
              height: AppSize.h22.h,
            ),
            // Text(
            //   getTranslated(context, "workDays"),
            //   style: TextStyle(
            //     fontFamily: getTranslated(context, 'Ithra'),
            //     fontSize: AppFontsSizeManager.s18.sp,
            //     fontWeight: FontWeight.bold,
            //     letterSpacing: 0.3,
            //     color: theme == "light"
            //         ? Theme.of(context).primaryColor
            //         : AppColors.pureBlack,
            //   ),
            // ),
            // SizedBox(
            //   height: AppSize.h5,
            // ),
            Container(
              height: AppSize.h32.h,
              child: Row(
                children: [
                  Checkbox(
                    side: MaterialStateBorderSide.resolveWith(
                      (states) => BorderSide(
                          width: AppSize.w3.w, color: AppColors.linear2),
                    ),
                    checkColor: AppColors.linear2,
                    activeColor: AppColors.white,
                    value: monday,
                    onChanged: (value) {
                      setState(() {
                        monday = !monday;
                        updateDays();
                      });
                      if (!isDaysEmpty()) {
                        setState(() {
                          monday = !monday;
                          updateDays();
                        });
                        showSnack(getTranslated(context, "chooseWorkDaysTxt"),
                            context);
                      }
                    },
                  ),
                  Text(
                    getTranslated(context, "monday"),
                    style: TextStyle(
                      fontFamily: getTranslated(context, 'Ithralight'),
                      fontWeight: FontWeight.w500,
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      color: theme == "light"
                          ? AppColors.darkGrey
                          : AppColors.pureBlack,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: AppSize.h21_3.h,
            ),
            Container(
              height: AppSize.h32.h,
              child: Row(
                children: [
                  Checkbox(
                    side: MaterialStateBorderSide.resolveWith(
                      (states) => BorderSide(
                          width: AppSize.w3.w, color: AppColors.linear2),
                    ),
                    checkColor: AppColors.linear2,
                    activeColor: AppColors.white,
                    value: tuesday,
                    onChanged: (value) {
                      setState(() {
                        tuesday = !tuesday;
                        updateDays();
                      });
                      if (!isDaysEmpty()) {
                        setState(() {
                          tuesday = !tuesday;
                          updateDays();
                        });
                        showSnack(getTranslated(context, "chooseWorkDaysTxt"),
                            context);
                      }
                    },
                  ),
                  Text(getTranslated(context, "tuesday"),
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithralight'),
                        fontWeight: FontWeight.w500,
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        color: theme == "light"
                            ? AppColors.darkGrey
                            : AppColors.pureBlack,
                      )),
                ],
              ),
            ),
            SizedBox(
              height: AppSize.h21_3.h,
            ),
            Container(
              height: AppSize.h32.h,
              child: Row(
                children: [
                  Checkbox(
                    side: MaterialStateBorderSide.resolveWith(
                      (states) => BorderSide(
                          width: AppSize.w3.w, color: AppColors.linear2),
                    ),
                    checkColor: AppColors.linear2,
                    activeColor: AppColors.white,
                    value: wednesday,
                    onChanged: (value) {
                      setState(() {
                        wednesday = !wednesday;
                        updateDays();
                      });
                      if (!isDaysEmpty()) {
                        setState(() {
                          wednesday = !wednesday;
                          updateDays();
                        });
                        showSnack(getTranslated(context, "chooseWorkDaysTxt"),
                            context);
                      }
                    },
                  ),
                  Text(getTranslated(context, "wednesday"),
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithralight'),
                        fontWeight: FontWeight.w500,
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        color: theme == "light"
                            ? AppColors.darkGrey
                            : AppColors.pureBlack,
                      )),
                ],
              ),
            ),
            SizedBox(
              height: AppSize.h21_3.h,
            ),
            Container(
              height: AppSize.h32.h,
              child: Row(
                children: [
                  Checkbox(
                    side: MaterialStateBorderSide.resolveWith(
                      (states) => BorderSide(
                          width: AppSize.w3.w, color: AppColors.linear2),
                    ),
                    checkColor: AppColors.linear2,
                    activeColor: AppColors.white,
                    value: thursday,
                    onChanged: (value) {
                      setState(() {
                        thursday = !thursday;
                        updateDays();
                      });
                      if (!isDaysEmpty()) {
                        setState(() {
                          thursday = !thursday;
                          updateDays();
                        });
                        showSnack(getTranslated(context, "chooseWorkDaysTxt"),
                            context);
                      }
                    },
                  ),
                  Text(getTranslated(context, "thursday"),
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithralight'),
                        fontWeight: FontWeight.w500,
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        color: theme == "light"
                            ? AppColors.darkGrey
                            : AppColors.pureBlack,
                      )),
                ],
              ),
            ),
            SizedBox(
              height: AppSize.h21_3.h,
            ),
            Container(
              height: AppSize.h32.h,
              child: Row(
                children: [
                  Checkbox(
                    side: MaterialStateBorderSide.resolveWith(
                      (states) => BorderSide(
                          width: AppSize.w3.w, color: AppColors.linear2),
                    ),
                    checkColor: AppColors.linear2,
                    activeColor: AppColors.white,
                    value: friday,
                    onChanged: (value) {
                      setState(() {
                        friday = !friday;
                        updateDays();
                      });
                      if (!isDaysEmpty()) {
                        setState(() {
                          friday = !friday;
                          updateDays();
                        });
                        showSnack(getTranslated(context, "chooseWorkDaysTxt"),
                            context);
                      }
                    },
                  ),
                  Text(getTranslated(context, "friday"),
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithralight'),
                        fontWeight: FontWeight.w500,
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        color: theme == "light"
                            ? AppColors.darkGrey
                            : AppColors.pureBlack,
                      )),
                ],
              ),
            ),
            SizedBox(
              height: AppSize.h21_3.h,
            ),
            Container(
              height: AppSize.h32.h,
              child: Row(
                children: [
                  Checkbox(
                    side: MaterialStateBorderSide.resolveWith(
                      (states) => BorderSide(
                          width: AppSize.w3.w, color: AppColors.linear2),
                    ),
                    checkColor: AppColors.linear2,
                    activeColor: AppColors.white,
                    value: saturday,
                    onChanged: (value) {
                      setState(() {
                        saturday = !saturday;
                        updateDays();
                      });
                      if (!isDaysEmpty()) {
                        setState(() {
                          saturday = !saturday;
                          updateDays();
                        });
                        showSnack(getTranslated(context, "chooseWorkDaysTxt"),
                            context);
                      }
                    },
                  ),
                  Text(getTranslated(context, "saturday"),
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithralight'),
                        fontWeight: FontWeight.w500,
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        color: theme == "light"
                            ? AppColors.darkGrey
                            : AppColors.pureBlack,
                      )),
                ],
              ),
            ),
            SizedBox(
              height: AppSize.h21_3.h,
            ),
            Container(
              height: AppSize.h32.h,
              child: Row(
                children: [
                  Checkbox(
                    side: MaterialStateBorderSide.resolveWith(
                      (states) => BorderSide(
                          width: AppSize.w3.w, color: AppColors.linear2),
                    ),
                    checkColor: AppColors.linear2,
                    activeColor: AppColors.white,
                    value: sunday,
                    onChanged: (value) {
                      setState(() {
                        sunday = !sunday;
                        updateDays();
                      });
                      if (!isDaysEmpty()) {
                        setState(() {
                          sunday = !sunday;
                          updateDays();
                        });
                        showSnack(getTranslated(context, "chooseWorkDaysTxt"),
                            context);
                      }
                    },
                  ),
                  Text(getTranslated(context, "sunday"),
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithralight'),
                        fontWeight: FontWeight.w500,
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        color: theme == "light"
                            ? AppColors.darkGrey
                            : AppColors.pureBlack,
                      )),
                ],
              ),
            ),
            // Center(
            //   child: SizedBox(
            //     height: AppSize.h35.h,
            //     width: size.width * AppSize.w0_5.w,
            //     child: MaterialButton(
            //       onPressed: () {
            //         workDays = "";
            //         daysValue.clear;
            //         widget.user.workDays!.clear();
            //         if (monday) {
            //           workDays = workDays +
            //               getTranslated(context, "monday") +
            //               ",";
            //           daysValue.add("1");
            //         }
            //         if (tuesday) {
            //           workDays = workDays +
            //               getTranslated(context, "tuesday") +
            //               ",";
            //           daysValue.add("2");
            //         }
            //         if (wednesday) {
            //           workDays = workDays +
            //               getTranslated(context, "wednesday") +
            //               ",";
            //           daysValue.add("3");
            //         }
            //         if (thursday) {
            //           workDays = workDays +
            //               getTranslated(context, "thursday") +
            //               ",";
            //           daysValue.add("4");
            //         }
            //         if (friday) {
            //           workDays = workDays +
            //               getTranslated(context, "friday") +
            //               ",";
            //           daysValue.add("5");
            //         }
            //         if (saturday) {
            //           workDays = workDays +
            //               getTranslated(context, "saturday") +
            //               ",";
            //           daysValue.add("6");
            //         }
            //         if (sunday) {
            //           workDays = workDays +
            //               getTranslated(context, "sunday") +
            //               ",";
            //           daysValue.add("7");
            //         }
            //         setState(() {
            //           daysController.text = workDays;
            //           widget.user.workDays = daysValue;
            //         });
            //         Navigator.pop(context);
            //       },
            //       color: Theme.of(context).primaryColor,
            //       shape: RoundedRectangleBorder(
            //         borderRadius:
            //             BorderRadius.circular(AppRadius.r25.r),
            //       ),
            //       child: Text(
            //         getTranslated(context, "done"),
            //         style: TextStyle(
            //           fontFamily: getTranslated(context, "Ithra"),
            //           color: AppColors.white,
            //           fontSize: AppFontsSizeManager.s14_5.sp,
            //           letterSpacing: 0.3,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    });
  }

  Widget _showTypes(BuildContext ctx, size) {
    return StatefulBuilder(builder: (context, setState) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: AppSize.h16.h,
            ),
            Container(
              width: AppSize.w473.w,
              height: AppSize.h1_5.h,
              color: AppColors.lightGray,
            ),
            SizedBox(
              height: AppSize.h22.h,
            ),
            Container(
              height: AppSize.h32.h,
              child: Row(
                children: [
                  Checkbox(
                    side: MaterialStateBorderSide.resolveWith(
                      (states) => BorderSide(
                          width: AppSize.w3.w, color: AppColors.linear2),
                    ),
                    checkColor: AppColors.linear2,
                    activeColor: AppColors.white,
                    value: allowChat,
                    onChanged: (value) {
                      setState(() {
                        allowChat = !allowChat;
                        updateType();
                      });
                      if (!isTypeEmpty()) {
                        setState(() {
                          allowChat = !allowChat;
                          updateType();
                        });
                        showSnack(
                            getTranslated(context, "chooseAccountTypeTxt"),
                            context);
                      }
                    },
                  ),
                  Text(getTranslated(context, "allowChat"),
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithralight'),
                        fontWeight: FontWeight.w500,
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        color: theme == "light"
                            ? AppColors.darkGrey
                            : AppColors.pureBlack,
                      )),
                ],
              ),
            ),
            SizedBox(
              height: AppSize.h21_3.h,
            ),
            Container(
              height: AppSize.h32.h,
              child: Row(
                children: [
                  Checkbox(
                    side: MaterialStateBorderSide.resolveWith(
                      (states) => BorderSide(
                          width: AppSize.w3.w, color: AppColors.linear2),
                    ),
                    checkColor: AppColors.linear2,
                    activeColor: AppColors.white,
                    value: allowVoice,
                    onChanged: (value) {
                      setState(() {
                        allowVoice = !allowVoice;
                        updateType();
                      });
                      if (!isTypeEmpty()) {
                        setState(() {
                          allowVoice = !allowVoice;
                          updateType();
                        });
                        showSnack(
                            getTranslated(context, "chooseAccountTypeTxt"),
                            context);
                      }
                    },
                  ),
                  Text(getTranslated(context, "allowVoice"),
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithralight'),
                        fontWeight: FontWeight.w500,
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        color: theme == "light"
                            ? AppColors.darkGrey
                            : AppColors.pureBlack,
                      )),
                ],
              ),
            ),
            // Center(
            //   child: SizedBox(
            //     height: AppSize.h35.h,
            //     width: size.width * AppSize.h0_5.h,
            //     child: MaterialButton(
            //       onPressed: () {
            //         type = "";
            //         if (allowVoice) {
            //           type = type + "Voice";
            //           widget.user.voice = true;
            //         }
            //         if (allowChat) {
            //           type = type + "- Chat";
            //           widget.user.chat = true;
            //         }
            //
            //         setState(() {
            //           typeController.text = type;
            //         });
            //         Navigator.pop(context);
            //       },
            //       color: Theme.of(context).primaryColor,
            //       shape: RoundedRectangleBorder(
            //         borderRadius:
            //             BorderRadius.circular(AppRadius.r25.r),
            //       ),
            //       child: Text(
            //         getTranslated(context, "done"),
            //         style: TextStyle(
            //           fontFamily: getTranslated(context, "Ithra"),
            //           color: AppColors.white,
            //           fontSize: AppFontsSizeManager.s14_5.sp,
            //           fontWeight: FontWeight.w500,
            //           letterSpacing: 0.3,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    });
  }

  Widget _showLang(BuildContext ctx, size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: AppSize.h16.h,
        ),
        Container(
          width: AppSize.w473.w,
          height: AppSize.h1_5.h,
          color: AppColors.lightGray,
        ),
        SizedBox(
          height: AppSize.h22.h,
        ),
        Container(
          height: AppSize.h32.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                side: MaterialStateBorderSide.resolveWith(
                  (states) =>
                      BorderSide(width: AppSize.w3.w, color: AppColors.linear2),
                ),
                checkColor: AppColors.linear2,
                activeColor: AppColors.white,
                value: arabic,
                onChanged: (value) {
                  setState(() {
                    arabic = !arabic;
                    updateLang();
                  });
                  if (!isLangEmpty()) {
                    setState(() {
                      arabic = !arabic;
                      updateLang();
                    });
                    showSnack(getTranslated(context, "chooseLangTxt"), context);
                  }
                },
              ),
              Text(
                getTranslated(context, "ar"),
                style: TextStyle(
                  fontFamily: getTranslated(context, "Ithralight"),
                  fontSize: AppFontsSizeManager.s21_3.sp,
                  fontWeight: FontWeight.w200,
                  color: theme == "light"
                      ? AppColors.darkGrey
                      : AppColors.pureBlack,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: AppSize.h21_3.h,
        ),
        Container(
          height: AppSize.h32.h,
          child: Row(
            children: [
              Checkbox(
                side: MaterialStateBorderSide.resolveWith(
                  (states) =>
                      BorderSide(width: AppSize.w3.w, color: AppColors.linear2),
                ),
                checkColor: AppColors.linear2,
                activeColor: AppColors.white,
                value: english,
                onChanged: (value) {
                  setState(() {
                    english = !english;
                    updateLang();
                  });
                  if (!isLangEmpty()) {
                    setState(() {
                      english = !english;
                      updateLang();
                    });
                    showSnack(getTranslated(context, "chooseLangTxt"), context);
                  }
                },
              ),
              Text(
                getTranslated(context, "en"),
                style: TextStyle(
                  fontFamily: getTranslated(context, "Montserrat"),
                  fontSize: AppFontsSizeManager.s21_3.sp,
                  fontWeight: FontWeight.w200,
                  color: theme == "light"
                      ? AppColors.darkGrey
                      : AppColors.pureBlack,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: AppSize.h21_3.h,
        ),
        Container(
          height: AppSize.h32.h,
          child: Row(
            children: [
              Checkbox(
                side: MaterialStateBorderSide.resolveWith(
                  (states) =>
                      BorderSide(width: AppSize.w3.w, color: AppColors.linear2),
                ),
                checkColor: AppColors.linear2,
                activeColor: AppColors.white,
                value: french,
                onChanged: (value) {
                  setState(() {
                    french = !french;
                    updateLang();
                  });
                  if (!isLangEmpty()) {
                    setState(() {
                      french = !french;
                      updateLang();
                    });
                    showSnack(getTranslated(context, "chooseLangTxt"), context);
                  }
                },
              ),
              Text(
                getTranslated(context, "fr"),
                style: TextStyle(
                  fontFamily: getTranslated(context, "Montserrat"),
                  fontSize: AppFontsSizeManager.s21_3.sp,
                  fontWeight: FontWeight.w200,
                  color: theme == "light"
                      ? AppColors.darkGrey
                      : AppColors.pureBlack,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: AppSize.h21_3.h,
        ),
        Container(
          height: AppSize.h32.h,
          child: Row(
            children: [
              Checkbox(
                side: MaterialStateBorderSide.resolveWith(
                  (states) =>
                      BorderSide(width: AppSize.w3.w, color: AppColors.linear2),
                ),
                checkColor: AppColors.linear2,
                activeColor: AppColors.white,
                value: indonesian,
                onChanged: (value) {
                  setState(() {
                    indonesian = !indonesian;
                    updateLang();
                  });
                  if (!isLangEmpty()) {
                    setState(() {
                      indonesian = !indonesian;
                      updateLang();
                    });
                    showSnack(getTranslated(context, "chooseLangTxt"), context);
                  }
                },
              ),
              Text(
                getTranslated(context, "id"),
                style: TextStyle(
                  fontFamily: getTranslated(context, "Montserrat"),
                  fontSize: AppFontsSizeManager.s21_3.sp,
                  fontWeight: FontWeight.w200,
                  color: theme == "light"
                      ? AppColors.darkGrey
                      : AppColors.pureBlack,
                ),
              ),
            ],
          ),
        ),
        // Center(
        //   child: SizedBox(
        //     height: AppSize.h35.h,
        //     width: size.width * AppSize.w0_5.w,
        //     child: MaterialButton(
        //       onPressed: () {
        //         lang = "";
        //         widget.user.languages!.clear();
        //         if (arabic) {
        //           lang = lang + " " + getTranslated(context, 'ar');
        //           widget.user.languages!.add("ar");
        //         }
        //         if (english) {
        //           lang = lang + " " + getTranslated(context, 'en');
        //           widget.user.languages!.add("en");
        //         }
        //          if (french) {
        //           lang = lang + " " + getTranslated(context, 'fr');
        //           widget.user.languages!.add("fr");
        //         }
        //          if (indonesian) {
        //           lang = lang + " " + getTranslated(context, 'id');
        //           widget.user.languages!.add("id");
        //         }
        //
        //        if(arabic || english || indonesian || french){
        //          setState(() {
        //            langController.text = lang;
        //          });
        //          Navigator.pushReplacement(
        //              context,
        //              MaterialPageRoute(
        //                  builder: (BuildContext context) =>
        //                  super.widget));
        //        }else{
        //          showSnack(getTranslated(context, "chooseLanguage"), context);
        //        }
        //
        //       },
        //       color: Theme.of(context).primaryColor,
        //       shape: RoundedRectangleBorder(
        //         borderRadius:
        //             BorderRadius.circular(AppRadius.r25.r),
        //       ),
        //       child: Text(
        //         getTranslated(context, "done"),
        //         style: TextStyle(
        //           fontFamily: getTranslated(context, "Ithra"),
        //           color: AppColors.white,
        //           fontSize: AppFontsSizeManager.s14_5.sp,
        //           fontWeight: FontWeight.w500,
        //           letterSpacing: 0.3,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget selectPackagesPrice(BuildContext ctx, size) {
    return Column(
      children: [
        SizedBox(
          height: AppSize.h21_3.h,
        ),
        Container(
          width: AppSize.w473.w,
          height: AppSize.h1_5.h,
          color: AppColors.lightGray,
        ),
        SizedBox(
          height: AppSize.h21_3.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(right: AppPadding.p35.w),
              child: Text(
                getTranslated(context, "packageSelectTxt"),
                style: TextStyle(
                    color: AppColors.linear2,
                    fontSize: AppFontsSizeManager.s21_3.sp,
                    fontFamily: getTranslated(context, "Ithralight"),
                    fontWeight: AppFontsWeightManager.bold600),
              ),
            ),
            SizedBox(
              width: lang == "ar" ? AppSize.w46.w : 0,
            ),
            Container(
              width: AppSize.w1_5.h,
              height: AppSize.h26_6.h,
              color: AppColors.lightGray,
            ),
            SizedBox(
              width: AppSize.w45.w,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getTranslated(context, "packagePriceTxt") + " \$",
                    style: TextStyle(
                        color: AppColors.linear2,
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        fontFamily: getTranslated(context, "Ithralight"),
                        fontWeight: AppFontsWeightManager.bold600),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: AppSize.h21_3.h,
        ),
        allowVoice
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated(context, "oneCallTxt"),
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      fontFamily: getTranslated(context, "Ithralight"),
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: AppSize.w1_5.h,
                    height: AppSize.h26_6.h,
                    color: AppColors.lightGray,
                  ),
                  SizedBox(
                    width: AppSize.w45.w,
                  ),
                  Container(
                      height: AppSize.h42_6.h,
                      width: lang == "ar" ? AppSize.w212.w : AppSize.w190.w,
                      color: AppColors.formFieldColor,
                      child: TextFormField(
                        style: TextStyle(
                          fontFamily: getTranslated(context, 'Ithra'),
                          fontSize: AppFontsSizeManager.s21_3.sp,
                          color: AppColors.darkGrey,
                          fontWeight: FontWeight.w200,
                        ),
                        controller: voicePriceController,
                        cursorHeight: AppSize.h16.h,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(AppPadding.p10),
                          errorStyle: style(size),
                          hintStyle: style(size),
                          labelText:
                              getTranslated(context, "priceSelectionTxt"),
                          labelStyle: TextStyle(
                            fontFamily: getTranslated(context, 'Ithralight'),
                            fontSize: AppFontsSizeManager.s21_3.sp,
                            color: AppColors.darkGrey,
                            fontWeight: FontWeight.w200,
                          ),
                          enabledBorder: new OutlineInputBorder(
                            borderSide: BorderSide(
                                width: AppSize.w0_5.w,
                                color: AppColors.warmGrey),
                            borderRadius:
                                BorderRadius.circular(AppRadius.r5_3.r),
                          ),
                          focusedBorder: new OutlineInputBorder(
                            borderSide: BorderSide(
                                width: AppSize.w0_5.w,
                                color: AppColors.warmPurple4),
                            borderRadius:
                                BorderRadius.circular(AppRadius.r5_3.r),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.greyDark),
                            borderRadius:
                                BorderRadius.circular(AppRadius.r5_3.r),
                          ),
                        ),
                      )),
                ],
              )
            : SizedBox(),
        SizedBox(
          height: AppSize.h21_3.h,
        ),
        allowChat
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated(context, "oneMessageTxt"),
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      fontFamily: getTranslated(context, "Ithralight"),
                    ),
                  ),
                 Spacer(),
                 Container(
                      width: AppSize.w1_5.h,
                      height: AppSize.h26_6.h,
                      color: AppColors.lightGray,
                    ),
                  SizedBox(
                    width: AppSize.w45.w,
                  ),
                  Container(
                      height: AppSize.h42_6.h,
                      width: lang == "ar" ? AppSize.w212.w : 188.w,
                      color: AppColors.formFieldColor,
                      child: TextFormField(
                        style: TextStyle(
                          fontFamily: getTranslated(context, 'Ithra'),
                          fontSize: AppFontsSizeManager.s21_3.sp,
                          color: AppColors.darkGrey,
                          fontWeight: FontWeight.w200,
                        ),
                        controller: chatPriceController,
                        cursorHeight: AppSize.h16.h,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(AppPadding.p10),
                          errorStyle: style(size),
                          hintStyle: style(size),
                          labelText:
                              getTranslated(context, "priceSelectionTxt"),
                          labelStyle: TextStyle(
                            fontFamily: getTranslated(context, 'Ithralight'),
                            fontSize: AppFontsSizeManager.s21_3.sp,
                            color: AppColors.darkGrey,
                            fontWeight: FontWeight.w200,
                          ),
                          enabledBorder: new OutlineInputBorder(
                            borderSide: BorderSide(
                                width: AppSize.w0_5.w,
                                color: AppColors.warmGrey),
                            borderRadius:
                                BorderRadius.circular(AppRadius.r5_3.r),
                          ),
                          focusedBorder: new OutlineInputBorder(
                            borderSide: BorderSide(
                                width: AppSize.w0_5.w,
                                color: AppColors.warmPurple4),
                            borderRadius:
                                BorderRadius.circular(AppRadius.r5_3.r),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.greyDark),
                            borderRadius:
                                BorderRadius.circular(AppRadius.r5_3.r),
                          ),
                        ),
                      )),
                ],
              )
            : SizedBox(),
      ],
    );
  }

  bool isLangEmpty() {
    if (arabic || english || indonesian || french) {
      return true;
    } else {
      return false;
    }
  }

  updateLang() {
    lang = "";
    widget.user.languages!.clear();
    if (arabic) {
      lang = lang + " " + getTranslated(context, 'ar');
      widget.user.languages!.add("ar");
    }
    if (english) {
      lang = lang + " / " + getTranslated(context, 'en');
      widget.user.languages!.add("en");
    }
    if (french) {
      lang = lang + " / " + getTranslated(context, 'fr');
      widget.user.languages!.add("fr");
    }
    if (indonesian) {
      lang = lang + " / " + getTranslated(context, 'id');
      widget.user.languages!.add("id");
    }

    setState(() {
      langController.text = lang;
    });
  }

  updateType() {
    type = "";
    if (allowVoice) {
      type = type + "Voice";
      widget.user.voice = true;
    }
    if (allowChat) {
      type = type + "/ Chat";
      widget.user.chat = true;
    }
    setState(() {
      typeController.text = type;
      widget.user.voice = allowVoice;
      widget.user.chat = allowChat;
    });
  }

  bool isTypeEmpty() {
    if (allowVoice || allowChat) {
      return true;
    } else {
      return false;
    }
  }

  updateDays() {
    workDays = "";
    daysValue.clear;
    widget.user.workDays!.clear();
    if (monday) {
      workDays = workDays + getTranslated(context, "monday") + "/";
      daysValue.add("1");
    }
    if (tuesday) {
      workDays = workDays + getTranslated(context, "tuesday") + "/";
      daysValue.add("2");
    }
    if (wednesday) {
      workDays = workDays + getTranslated(context, "wednesday") + "/";
      daysValue.add("3");
    }
    if (thursday) {
      workDays = workDays + getTranslated(context, "thursday") + "/";
      daysValue.add("4");
    }
    if (friday) {
      workDays = workDays + getTranslated(context, "friday") + "/";
      daysValue.add("5");
    }
    if (saturday) {
      workDays = workDays + getTranslated(context, "saturday") + "/";
      daysValue.add("6");
    }
    if (sunday) {
      workDays = workDays + getTranslated(context, "sunday") + "/";
      daysValue.add("7");
    }
    setState(() {
      daysController.text = workDays;
      widget.user.workDays = daysValue;
    });
  }

  bool isDaysEmpty() {
    if (monday ||
        tuesday ||
        wednesday ||
        thursday ||
        friday ||
        saturday ||
        sunday) {
      return true;
    } else {
      return false;
    }
  }
}
