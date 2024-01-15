import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../config/app_fonts.dart';
import '../config/colorsFile.dart';
import '../config/paths.dart';
import '../localization/localization_methods.dart';
import '../methods/convert_pt_to_px.dart';
import '../models/payInfo.dart';
import '../models/user.dart';
import '../widget/back_button.dart';
import '../widget/processing_dialog.dart';
import '../widget/product_added_dialog.dart';

class payInfo1Screen extends StatefulWidget {
  final String consultId;

  const payInfo1Screen({Key? key, required this.consultId}) : super(key: key);

  @override
  _payInfo1ScreenState createState() => _payInfo1ScreenState();
}

class _payInfo1ScreenState extends State<payInfo1Screen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<dynamic, dynamic> adminMap = Map();
  Map<String, dynamic> bb = {};
  var image;
  var selectedImageFront, selectedImageBack;
  bool isAdding = false, load = true;
  late GroceryUser consult;
  late PayInfo consultPayInfo;
  late String personFrontUrl, personBackUrl, randomUid;

  @override
  void initState() {
    super.initState();
    getConsultPayInfoDetails();
  }

  Future<void> getConsultPayInfoDetails() async {
    DocumentSnapshot documentSnapshotConsult = await FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(widget.consultId)
        .get();

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection(Paths.payInfoPath)
        .doc(widget.consultId)
        .get();
    if (documentSnapshot.exists)
      setState(() {
        consultPayInfo = PayInfo.fromMap(documentSnapshot.data() as Map);
        consult = GroceryUser.fromMap(documentSnapshotConsult.data() as Map);
        load = false;
      });
    else
      setState(() {
        consultPayInfo = new PayInfo();
        consult = GroceryUser.fromMap(documentSnapshotConsult.data() as Map);
        load = false;
      });
  }

  showProductAddedDialog() async {
    var res = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProductAddedDialog(
          message: 'Admin added successfully!',
        );
      },
    );

    if (res == 'ADDED') {
      //added
      Navigator.pop(context, true);
    }
  }

  Future cropImage(context, type) async {
    image = await ImagePicker().pickImage(source: ImageSource.gallery);
    File croppedFile = File(image.path);
    if (croppedFile != null) {
      setState(() {
        if (type == "front")
          selectedImageFront = croppedFile;
        else
          selectedImageBack = croppedFile;
      });
    }
    //addFile(type);
  }

  save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isAdding = true;
      });
      String? urlF = consultPayInfo.personalFrontUrl;
      String? urlB = consultPayInfo.personalFrontUrl;
      if (selectedImageFront != null) {
        var uuid = Uuid().v4();
        Reference storageReference =
            FirebaseStorage.instance.ref().child('profileImages/$uuid');
        await storageReference.putFile(selectedImageFront);
        urlF = await storageReference.getDownloadURL();
        consultPayInfo.personalFrontUrl = urlF;
      }
      if (selectedImageBack != null) {
        var uuid = Uuid().v4();
        Reference storageReference =
            FirebaseStorage.instance.ref().child('profileImages/$uuid');
        await storageReference.putFile(selectedImageBack);
        urlB = await storageReference.getDownloadURL();
        consultPayInfo.personalBackUrl = urlB;
      }
      await FirebaseFirestore.instance
          .collection(Paths.payInfoPath)
          .doc(widget.consultId)
          .set({
        "id": widget.consultId,
        "consultUid": widget.consultId,

        'title': consultPayInfo.title,
        'fullNameEn': consultPayInfo.fullNameEn,
        'fullNameAr': consultPayInfo.fullNameAr,
        'phone':
            consult.phoneNumber!.replaceAll(consult.countryCode!, '').trim(),
        'countryCode': consult.countryCode,
        'countryISOCode': consult.countryISOCode,
        'email': consultPayInfo.email,

        "personalFrontUrl": consultPayInfo.personalFrontUrl,
        "personalBackUrl": consultPayInfo.personalBackUrl,
        "personalFrontUrlId": ".", //consultPayInfo.personalFrontUrlId,
        "personalBackUrlId": ".", //consultPayInfo.personalBackUrlId,
        'startDate': consultPayInfo.startDate,
        'endDate': consultPayInfo.endDate,

        "address1": consultPayInfo.address1,
        "address2": consultPayInfo.address2,
        'district': consultPayInfo.district,
        'city': consultPayInfo.city,
        'zip_code': consultPayInfo.zip_code,

        "iban": consultPayInfo.iban,
        "swift": consultPayInfo.swift,
        'bankName': consultPayInfo.bankName,
        'bankAccountNumber': consultPayInfo.bankAccountNumber,
        'siteUrl': consultPayInfo.siteUrl,
      }, SetOptions(merge: true));
      setState(() {
        isAdding = false;
      });
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
      /*  if(consult.marketplace!)
           addBusiness();
      else{
        setState(() {
          isAdding=false;
        });
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
              (route) => false,
        );
      }*/
    } else
      showSnack(getTranslated(context, "allRequired"), context);
  }

  showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: 'Adding new admin..\nPlease wait!',
        );
      },
    );
  }

  void showSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(AppMargin.m8),
      borderRadius: BorderRadius.circular(AppRadius.r7),
      backgroundColor: Colors.red.shade500,
      animationDuration: Duration(milliseconds: AppConstants.milliseconds300),
      isDismissible: true,
      boxShadows: [AppShadow.primaryShadow],
      shouldIconPulse: false,
      duration: Duration(milliseconds: AppConstants.milliseconds6000),
      icon: Icon(
        Icons.error,
        color: AppColors.white,
      ),
      messageText: Text(
        '$text',
        style: TextStyle(
          fontFamily: getTranslated(context, "Ithra"),
          fontSize: AppFontsSizeManager.s14,
          fontWeight: AppFontsWeightManager.bold500,
          letterSpacing: 0.3,
          color: AppColors.white,
        ),
      ),
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding(
                    padding:  EdgeInsets.symmetric(horizontal: convertPtToPx(AppPadding.p24).w, vertical: convertPtToPx(AppPadding.p15).h,),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomBackButton(),

                        SizedBox(width: AppSize.w21_3.w),
                        Text(
                          getTranslated(context, "paymentInfo"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              fontSize: AppFontsSizeManager.s21.sp,
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
                  width: size.width )),

          SizedBox(height: AppSize.h24.h),

          load
              ? CircularProgressIndicator()
              : Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal:AppPadding.p16,
                      vertical: AppPadding.p16,
                    ),
                    children: <Widget>[
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: AppSize.h10,
                            ),
                            Center(
                              child: Text(
                                getTranslated(context, "personInformation"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    fontSize: AppFontsSizeManager.s16,
                                    color: AppColors.pureBlack.withOpacity(0.8),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h10,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.title,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.title = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing:AppConstants.letterSpacing,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: AppPadding.p15),
                                helperStyle: GoogleFonts.poppins(
                                  color: AppColors.pureBlack.withOpacity(0.65),
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s13,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.black1,
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                                prefixIcon: Icon(Icons.title),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                                labelText: getTranslated(context, "title"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h15,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.fullNameAr,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                if (val.split(" ").length < 3) {
                                  return getTranslated(context, "third");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.fullNameAr = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: AppRadius.r15),
                                helperStyle: GoogleFonts.poppins(
                                  color: AppColors.pureBlack.withOpacity(0.65),
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.black1,
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                                prefixIcon: Icon(Icons.person),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                                labelText: getTranslated(context, "fullNameAr"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h15,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.fullNameEn,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                if (val.split(" ").length < 3) {
                                  return getTranslated(context, "third");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.fullNameEn = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: AppPadding.p15),
                                helperStyle: GoogleFonts.poppins(
                                  color: AppColors.pureBlack.withOpacity(0.65),
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: AppFontsWeightManager.bold500,
                                    letterSpacing: AppConstants.letterSpacing,
                                ),
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.black1,
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                                prefixIcon: Icon(Icons.person),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                                labelText: getTranslated(context, "fullNameEn"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height:AppSize.h15,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.email,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.email = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: AppPadding.p15),
                                helperStyle: GoogleFonts.poppins(
                                  color: AppColors.pureBlack.withOpacity(0.65),
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s13,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.black1,
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                                prefixIcon: Icon(Icons.email_outlined),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                                labelText: getTranslated(context, "email"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h15,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consult.phoneNumber,
                              readOnly: true,
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15.0),
                                helperStyle: GoogleFonts.poppins(
                                  color: AppColors.pureBlack.withOpacity(0.65),
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s13,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.black1,
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                                prefixIcon: Icon(Icons.phone),
                                labelText:
                                    getTranslated(context, "phoneNumber"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                        border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h15,
                            ),
                            Center(
                              child: Text(
                                getTranslated(context, "NationalId"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    fontSize: AppFontsSizeManager.s16,
                                    color: AppColors.pureBlack.withOpacity(0.8),
                                    fontWeight: AppFontsWeightManager.bold),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h15,
                            ),
                            Row(
                              children: [
                                Text(
                                  getTranslated(context, "personalIdFront"),
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    color: Colors.grey,
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: AppFontsWeightManager.regular,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: AppSize.h10,
                            ),
                            Center(
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    height: size.width * AppSize.h0_35,
                                    width: size.width * AppSize.w0_85,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.lightGrey,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(AppRadius.r10_6),
                                      shape: BoxShape.rectangle,
                                      color: AppColors.white,
                                      boxShadow: [AppShadow.primaryShadow],
                                    ),
                                    child: (consultPayInfo.personalFrontUrl ==
                                                    null ||
                                                consultPayInfo.personalFrontUrl!
                                                    .isEmpty) &&
                                            selectedImageFront == null
                                        ? Icon(
                                            Icons.person_pin_outlined,
                                            size: 25.0,
                                          )
                                        : selectedImageFront != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                                child: Image.file(
                                                    selectedImageFront),
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                                child: FadeInImage.assetNetwork(
                                                  placeholder:
                                                  AssetsManager.loadImagePath,
                                                  placeholderScale: 0.5,
                                                  imageErrorBuilder: (context,
                                                          error, stackTrace) =>
                                                      Icon(
                                                    Icons.person,
                                                    size: 50.0,
                                                  ),
                                                  image: consultPayInfo
                                                      .personalFrontUrl!,
                                                  fit: BoxFit.cover,
                                                  fadeInDuration: Duration(
                                                      milliseconds: 250),
                                                  fadeInCurve: Curves.easeInOut,
                                                  fadeOutDuration: Duration(
                                                      milliseconds: 150),
                                                  fadeOutCurve:
                                                      Curves.easeInOut,
                                                ),
                                              ),
                                  ),
                                  Positioned(
                                    bottom: 5.0,
                                    left: 5.0,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: Material(
                                        color: Theme.of(context).primaryColor,
                                        child: InkWell(
                                          splashColor:
                                              AppColors.white.withOpacity(0.6),
                                          onTap: () {
                                            //TODO: take user to edit
                                            cropImage(context, "front");
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(),
                                            width: 30.0,
                                            height: 30.0,
                                            child: Icon(
                                              (consultPayInfo.personalFrontUrl ==
                                                          null ||
                                                      consultPayInfo
                                                          .personalFrontUrl!
                                                          .isEmpty)
                                                  ? Icons.edit
                                                  : Icons.add,
                                              color: AppColors.white,
                                              size: 16.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            Row(
                              children: [
                                Text(
                                  getTranslated(context, "personalIdBack"),
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    color: Colors.grey,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Center(
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    height: size.width * 0.35,
                                    width: size.width * 0.85,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.lightGrey,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(10.0),
                                      shape: BoxShape.rectangle,
                                      color: AppColors.white,
                                      boxShadow: [AppShadow.primaryShadow],
                                    ),
                                    child: (consultPayInfo.personalBackUrl ==
                                                    null ||
                                                consultPayInfo.personalBackUrl!
                                                    .isEmpty) &&
                                            selectedImageBack == null
                                        ? Icon(
                                            Icons.person_pin_outlined,
                                            size: 25.0,
                                          )
                                        : selectedImageBack != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                                child: Image.file(
                                                    selectedImageBack),
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                                child: FadeInImage.assetNetwork(
                                                  placeholder:
                                                  AssetsManager.loadImagePath,
                                                  placeholderScale: 0.5,
                                                  imageErrorBuilder: (context,
                                                          error, stackTrace) =>
                                                      Icon(
                                                    Icons.person,
                                                    size: 50.0,
                                                  ),
                                                  image: consultPayInfo
                                                      .personalBackUrl!,
                                                  fit: BoxFit.cover,
                                                  fadeInDuration: Duration(
                                                      milliseconds: 250),
                                                  fadeInCurve: Curves.easeInOut,
                                                  fadeOutDuration: Duration(
                                                      milliseconds: 150),
                                                  fadeOutCurve:
                                                      Curves.easeInOut,
                                                ),
                                              ),
                                  ),
                                  Positioned(
                                    bottom: 5.0,
                                    left: 5.0,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: Material(
                                        color: Theme.of(context).primaryColor,
                                        child: InkWell(
                                          splashColor:
                                              AppColors.white.withOpacity(0.6),
                                          onTap: () {
                                            //TODO: take user to edit
                                            cropImage(context, "back");
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(),
                                            width: 30.0,
                                            height: 30.0,
                                            child: Icon(
                                              (consultPayInfo.personalBackUrl ==
                                                          null ||
                                                      consultPayInfo
                                                          .personalBackUrl!
                                                          .isEmpty)
                                                  ? Icons.edit
                                                  : Icons.add,
                                              color: AppColors.white,
                                              size: 16.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.startDate,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.startDate = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight:AppFontsWeightManager.bold500,
                                letterSpacing:AppConstants.letterSpacing ,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15.0),
                                helperStyle: GoogleFonts.poppins(
                                  color: AppColors.pureBlack.withOpacity(0.65),
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                  fontSize: 13.0,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.black1,
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                prefixIcon: Icon(Icons.date_range),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                hintText: "yyyy-mm-dd",
                                labelText: getTranslated(context, "startDate"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                        border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h15,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.endDate,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.endDate = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight:AppFontsWeightManager.bold500,
                                letterSpacing:AppConstants.letterSpacing ,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15.0),
                                helperStyle: GoogleFonts.poppins(
                                  color: AppColors.pureBlack.withOpacity(0.65),
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                  fontSize: 13.0,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.black1,
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                prefixIcon: Icon(Icons.date_range),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                hintText: "yyyy-mm-dd",
                                labelText: getTranslated(context, "endDate"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                        border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            Center(
                              child: Text(
                                getTranslated(context, "bankingInfo"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    fontSize: 16.0,
                                    color: AppColors.pureBlack.withOpacity(0.8),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.bankName,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.bankName = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight:AppFontsWeightManager.bold500,
                                letterSpacing:AppConstants.letterSpacing ,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15.0),
                                helperStyle: GoogleFonts.poppins(
                                  color: AppColors.pureBlack.withOpacity(0.65),
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                  fontSize: 13.0,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.black1,
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                prefixIcon: Icon(Icons.home),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                labelText: getTranslated(context, "bankName"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                        border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h15,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.bankAccountNumber,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.bankAccountNumber = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight:AppFontsWeightManager.bold500,
                                letterSpacing:AppConstants.letterSpacing ,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15.0),
                                helperStyle: GoogleFonts.poppins(
                                  color: AppColors.pureBlack.withOpacity(0.65),
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                  fontSize: 13.0,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.black1,
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                prefixIcon:
                                    Icon(Icons.confirmation_num_outlined),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                labelText:
                                    getTranslated(context, "bankAccountNumber"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                        border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.iban,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.iban = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight:AppFontsWeightManager.bold500,
                                letterSpacing:AppConstants.letterSpacing ,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15.0),
                                helperStyle: GoogleFonts.poppins(
                                  color: AppColors.pureBlack.withOpacity(0.65),
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                  fontSize: 13.0,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.black1,
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                prefixIcon: Icon(Icons.security_outlined),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                labelText: getTranslated(context, "iban"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                        border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.swift,
                              /*validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context,"required");
                          }
                          return null;
                        },*/
                              onSaved: (val) {
                                consultPayInfo.swift = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight:AppFontsWeightManager.bold500,
                                letterSpacing:AppConstants.letterSpacing ,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15.0),
                                helperStyle: GoogleFonts.poppins(
                                  color: AppColors.pureBlack.withOpacity(0.65),
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                  fontSize: 13.0,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.black1,
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                prefixIcon: Icon(Icons.security_outlined),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                labelText: getTranslated(context, "swift"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                        border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            Center(
                              child: Text(
                                getTranslated(context, "addressInfo"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    fontSize: 16.0,
                                    color: AppColors.pureBlack.withOpacity(0.8),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.address1,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.address1 = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight:AppFontsWeightManager.bold500,
                                letterSpacing:AppConstants.letterSpacing ,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15.0),
                                helperStyle: GoogleFonts.poppins(
                                  color: AppColors.pureBlack.withOpacity(0.65),
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                  fontSize: 13.0,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.black1,
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                prefixIcon: Icon(Icons.location_on_outlined),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                labelText: getTranslated(context, "address1"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                        border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h15,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.address2,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.address2 = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight:AppFontsWeightManager.bold500,
                                letterSpacing:AppConstants.letterSpacing ,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15.0),
                                helperStyle: GoogleFonts.poppins(
                                  color: AppColors.pureBlack.withOpacity(0.65),
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                  fontSize: 13.0,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.black1,
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                prefixIcon: Icon(Icons.location_on_outlined),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                labelText: getTranslated(context, "address2"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                        border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.district,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.district = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight:AppFontsWeightManager.bold500,
                                letterSpacing:AppConstants.letterSpacing ,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15.0),
                                helperStyle: GoogleFonts.poppins(
                                  color: AppColors.pureBlack.withOpacity(0.65),
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                  fontSize: 13.0,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.black1,
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                prefixIcon: Icon(Icons.location_on_outlined),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                labelText: getTranslated(context, "district"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                        border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.city,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.city = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight:AppFontsWeightManager.bold500,
                                letterSpacing:AppConstants.letterSpacing ,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15.0),
                                helperStyle: GoogleFonts.poppins(
                                  color: AppColors.pureBlack.withOpacity(0.65),
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                  fontSize: 13.0,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.black1,
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                prefixIcon: Icon(Icons.location_on_outlined),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                labelText: getTranslated(context, "city"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                        border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.zip_code,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.zip_code = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight:AppFontsWeightManager.bold500,
                                letterSpacing:AppConstants.letterSpacing ,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15.0),
                                helperStyle: GoogleFonts.poppins(
                                  color: AppColors.pureBlack.withOpacity(0.65),
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                  fontSize: 13.0,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.black1,
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                prefixIcon: Icon(Icons.location_on_outlined),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                labelText: getTranslated(context, "zip_code"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                        border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.siteUrl,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.siteUrl = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight:AppFontsWeightManager.bold500,
                                letterSpacing:AppConstants.letterSpacing ,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15.0),
                                helperStyle: GoogleFonts.poppins(
                                  color: AppColors.pureBlack.withOpacity(0.65),
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                  fontSize: 13.0,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.black1,
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                prefixIcon: Icon(Icons.upcoming_rounded),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                labelText: getTranslated(context, "siteUrl"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight:AppFontsWeightManager.bold500,
                                  letterSpacing:AppConstants.letterSpacing ,
                                ),
                                        border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            isAdding
                                ? Center(child: CircularProgressIndicator())
                                : Container(
                                    height: 45.0,
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0.0),
                                    child: MaterialButton(
                                      onPressed: () {
                                        //add adminMap
                                        save();
                                      },
                                      color: Theme.of(context).primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            getTranslated(
                                                context, "saveAndContinue"),
                                            style: TextStyle(
                                              fontFamily: getTranslated(
                                                  context, "Ithra"),
                                              color: AppColors.white,
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            SizedBox(
                              height: 25.0,
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

  addFile(String type) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse("https://api.tap.company/v2/files"));
      request.headers['Authorization'] =
          "Bearer sk_live_CBIu7KHLsNqljVaMpJxnQU9k";
      request.fields['purpose'] = "identity_document";
      request.fields['title'] = "fron";
      request.fields['expires_at'] = '1913743462';
      request.fields['file_link_create'] = 'true';
      request.files.add(
          await http.MultipartFile.fromPath('file', selectedImageFront.path));
      var response = await request.send();
      final res = await http.Response.fromStream(response);
      var responseBody = res.body;
      var resFile = json.decode(responseBody);
      setState(() {
        if (type == "front")
          consultPayInfo.personalFrontUrlId = resFile['id'];
        else
          consultPayInfo.personalBackUrlId = resFile['id'];
      });
    } catch (e) {}
  }

  addBusiness() async {
    String responseBody = "";
    randomUid = Uuid().v4();
    try {
      final uri = Uri.parse('https://api.tap.company/v2/business');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': "Bearer sk_live_CBIu7KHLsNqljVaMpJxnQU9k",
        //'Authorization':"Bearer sk_test_jMorGu86mITxVBR7vgcdiAnQ",
        'Connection': 'keep-alive',
        'Accept-Encoding': 'gzip, deflate, br'
      };

      Map<String, dynamic> businessBody = {
        "name": {
          "en": consultPayInfo.fullNameEn,
          "ar": consultPayInfo.fullNameAr
        },
        "type": "ind",
        "entity": {
          "legal_name": {
            "en": consultPayInfo.fullNameEn,
            "ar": consultPayInfo.fullNameAr
          },
          "license": {
            /* "type": "commercial resgistration",
        "number": "2134342SE"*/
          },
          "not_for_profit": false,
          "country": consult.countryISOCode,
          "tax_number": "",
          "documents": [
            /* {
        "type": "Commercial Registration",
        "number": "1234567890",
        "issuing_country": "SA",
        "issuing_date": "2019-07-09",
        "expiry_date": "2021-07-09",
        "files": [
        "file_638280400367906816"
        ]
        },
        {
        "type": "Commercial license",
        "number": "1234567890",
        "issuing_country": "SA",
        "issuing_date": "2019-07-09",
        "expiry_date": "2021-07-09",
        "files": [
        "file_638298626904682496"
        ]
        },
        {
        "type": "Trademark Document",
        "number": "1234567890",
        "issuing_country": "SA",
        "issuing_date": "2019-07-09",
        "expiry_date": "2021-07-09",
        "files": [
        "file_638280400367906816"
        ]
        }*/
          ],
          "bank_account": {
            "iban": consultPayInfo.iban,
            "swift_code": consultPayInfo.swift,
            "account_number": consultPayInfo.bankAccountNumber
          },
          "billing_address": {
            "recipient_name": consultPayInfo.fullNameEn,
            "address_1": consultPayInfo.address1,
            "address_2": consultPayInfo.address2,
            "po_box": "",
            "district": consultPayInfo.district,
            "city": consultPayInfo.city,
            "state": consult.countryISOCode,
            "zip_code": consultPayInfo.zip_code,
            "country": consult.countryISOCode,
          }
        },
        "contact_person": {
          "name": {
            "title": consultPayInfo.title,
            "first": consultPayInfo.fullNameEn!.split(" ")[0],
            "middle": consultPayInfo.fullNameEn!.split(" ")[1],
            "last": consultPayInfo.fullNameEn!.split(" ")[2],
          },
          "contact_info": {
            "primary": {
              "email": consultPayInfo.email,
              "phone": {
                "country_code": consult.countryCode!.replaceAll('+', '').trim(),
                "number": consult.phoneNumber!
                    .replaceAll(consult.countryCode!, '')
                    .trim(),
              }
            }
          },
          "nationality": "",
          "date_of_birth": "",
          "is_authorized": true,
          "identification": [
            {
              "type": "Civil ID",
              "issuing_country": consult.countryISOCode,
              "issuing_date": consultPayInfo.startDate,
              "expiry_date": consultPayInfo.endDate,
              "files": [
                consultPayInfo.personalFrontUrlId,
                consultPayInfo.personalBackUrlId,
              ]
            }
          ]
        },
        "brands": [
          {
            "name": {
              "en": "Interpreter of the vision",
              "ar": "مفسر للرؤيا",
            },
            "sector": [
              "Medium",
            ],
            "website": consultPayInfo.siteUrl,
            "social": [],
            "logo": "",
            "content": {
              "tag_line": {
                "en": "Interpreter of the vision",
                "ar": "مفسر للرؤيا",
              },
              "about": {
                "en": "Interpreter of the vision",
                "ar": "مفسر للرؤيا",
              }
            }
          }
        ],
        "post": {"url": "http://your_website.com/post_url"},
        "metadata": {"mtd": ""}
      };
      bb = businessBody;

      String jsonBody = json.encode(businessBody);
      printLongString(jsonBody);

      final encoding = Encoding.getByName('utf-8');
      var response = await post(
        uri,
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      );
      responseBody = response.body;
      printLongString(responseBody);
      var res = json.decode(responseBody);
      setState(() {
        consultPayInfo.businessId = res['id'];
        consultPayInfo.entityId = res['entity']['id'];
        consultPayInfo.destinationId = res['destination_id'];
      });

      await FirebaseFirestore.instance
          .collection(Paths.payInfoPath)
          .doc(widget.consultId)
          .set({
        'businessId': consultPayInfo.businessId,
        'entityId': consultPayInfo.entityId,
        'destinationId': consultPayInfo.destinationId,
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(widget.consultId)
          .set({
        'destinationId': consultPayInfo.destinationId,
      }, SetOptions(merge: true));
      setState(() {
        isAdding = false;
      });
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    } catch (e) {
      errorLog("addBusiness", responseBody);
      setState(() {
        isAdding = false;
      });
      showSnack(responseBody.toString(), context);
    }
  }

  addDestination() async {
    String responseBody = "";
    try {
      final uri = Uri.parse('https://api.tap.company/v2/destination');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': "Bearer sk_live_CBIu7KHLsNqljVaMpJxnQU9k",
        //'Authorization':"Bearer sk_test_jMorGu86mITxVBR7vgcdiAnQ",
        'Connection': 'keep-alive',
        'Accept-Encoding': 'gzip, deflate, br'
      };
      Map<String, dynamic> body = {
        "display_name": consultPayInfo.fullNameEn,
        "business_id": consultPayInfo.businessId,
        "business_entity_id": consultPayInfo.entityId,
        "bank_account": {"iban": consultPayInfo.iban}
      };
      String jsonBody = json.encode(body);
      final encoding = Encoding.getByName('utf-8');
      var response = await post(
        uri,
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      );
      responseBody = response.body;
      var res = json.decode(responseBody);

      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(widget.consultId)
          .set({
        'destinationId': res['id'],
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection(Paths.payInfoPath)
          .doc(widget.consultId)
          .set({
        'destinationId': res['id'],
      }, SetOptions(merge: true));
      setState(() {
        isAdding = false;
      });
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    } catch (e) {
      errorLog("addDestination", responseBody.toString());
      setState(() {
        isAdding = false;
      });
      showSnack(e.toString(), context);
    }
  }

  errorLog(String function, String error) async {
    String id = Uuid().v4();
    await FirebaseFirestore.instance
        .collection(Paths.errorLogPath)
        .doc(id)
        .set({
      'timestamp': Timestamp.now(),
      'id': id,
      'seen': false,
      'desc': error,
      'phone': consultPayInfo == null ? "phone" : consult.phoneNumber,
      'screen': "payInfo1",
      'function': function,
      'bb': bb
    });
  }

  void printLongString(String text) {
    final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  }
}
