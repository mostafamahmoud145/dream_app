
import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class SendNotificationScreen extends StatefulWidget {
  @override
  _SendNotificationScreenState createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<dynamic, dynamic> notificationMap = Map();
  TextEditingController controller = TextEditingController();
  var image;
  var selectedImage;
  String url = "noImage";
  String link = "noLink";
  bool isSending=false, sendReq = false, langReq = false, isAdding = false;
  String? selectedType = null, selectedCountry = "00", selectedLang = null,theme;
   String? lang = "language",
      langValue = "",
      done = "Save",
      title = "Please select language",
      dropdownTypeValue,
      dropdownLangValue;
  List<KeyValueModel> _langArray = [
    KeyValueModel(key: "ar", value: "العربية"),
    KeyValueModel(key: "en", value: "English"),
  ];
  List<KeyValueModel> _typeArray = [
    KeyValueModel(key: 0, value: "العربية"),
    KeyValueModel(key: 1, value: "English"),
  ];

  @override
  void initState() {
    super.initState();
    isSending = false;
  }
  @override
  void didChangeDependencies() {
    getThemeName().then((theme) {
      setState(() {
        this.theme = theme;
      });
    });
    super.didChangeDependencies();
  }
  Future cropImage(context) async {
    image = await ImagePicker().pickImage(source: ImageSource.gallery);
    File croppedFile =File(image.path);

    if (croppedFile != null) {
      setState(() {
        selectedImage = croppedFile;
      });
    } else {
      //not croppped

    }
  }

  sendNotification() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (selectedType == null || selectedLang == null) {
        if (selectedType == null)
          setState(() {
            sendReq = true;
          });
        if (selectedLang == null)
          setState(() {
            langReq = true;
          });
      } else {
        setState(() {
          isAdding = true;
        });

        if (selectedImage != null) {
          var uuid = Uuid().v4();
          Reference storageReference = FirebaseStorage.instance
              .ref()
              .child('pushNotificationImages/$uuid');
          await storageReference.putFile(selectedImage);
          url = await storageReference.getDownloadURL();
        }
        notificationMap.update(
          'imageUrl',
          (val) => url,
          ifAbsent: () => url,
        );
        notificationMap.update(
          'link',
              (val) => link,
          ifAbsent: () => link,
        );
        String id = Uuid().v4();
        await FirebaseFirestore.instance
            .collection(Paths.generalNotificationsPath)
            .doc(id)
            .set({
          'title': notificationMap['title'],
          'body': notificationMap['body'],
          'notificationType': notificationMap['notificationType'],
          'notificationLang': notificationMap['notificationLang'],
          'notificationCountry': notificationMap['notificationCountry'] +
              " - " +
              notificationMap['countryName'],
          'notificationTimestamp': Timestamp.now(),
          'imageUrl': url,
          'link': link,
        });

        //call function
        var refundRes = await http.post(
          Uri.parse(
              'https://us-central1-dream-43bb8.cloudfunctions.net/sendNewNotification'),
          body: notificationMap,
        );
        var refund = jsonDecode(refundRes.body);
        setState(() {
          isAdding = false;
        });
        if (refund['message'] != 'Success') {
          showSnack('Please fill all the details!', context);
        } else {
          setState(() {
            isAdding = false;
          });
          Navigator.pop(context);
        }
      }
    }
  }

  showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: 'Sending notification..\nPlease wait!',
        );
      },
    );
  }

  void showSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(AppMargin.m8),
      borderRadius: BorderRadius.circular(AppRadius.r7),
      backgroundColor: AppColors.redShade500,
      animationDuration: Duration(milliseconds: AppConstants.milliseconds300),
      isDismissible: true,
      boxShadows: [
        AppShadow.primaryShadow
      ],
      shouldIconPulse: false,
      duration: Duration(milliseconds: AppConstants.milliseconds2000),
      icon: Icon(
        Icons.error,
        color: AppColors.white,
      ),
      messageText: Text(
        '$text',
        style: GoogleFonts.poppins(
          fontSize: AppFontsSizeManager.s14.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: AppColors.white,
        ),
      ),
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _typeArray = [
      KeyValueModel(
          key: AppConstants.consultant, value: getTranslated(context, "consultNum")),
      KeyValueModel(key: AppConstants.user, value: getTranslated(context, "userNum")),
      KeyValueModel(
          key: "SUPPORT", value: getTranslated(context, "supportNum")),
    ];

    return Scaffold(backgroundColor: AppColors.white,
      body: Column(
        children: <Widget>[
          Container(
            width: size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0.0),
                bottomRight: Radius.circular(0.0),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: AppPadding.p16, right: AppPadding.p16, top: 0.0, bottom: AppPadding.p16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.r50),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: AppColors.white.withOpacity(0.5),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            width: AppSize.w38,
                            height: AppSize.h35,
                            child: Icon(
                              Icons.arrow_back,
                              color: theme=="light"?AppColors.white:AppColors.pureBlack,
                              size: AppSize.w24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: AppSize.w8,
                    ),
                    Text(
                      getTranslated(context, "sendNotification"),
                      style: GoogleFonts.poppins(
                        color: theme=="light"?AppColors.white:AppColors.pureBlack,
                        fontSize: AppFontsSizeManager.s19.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppPadding.p16,
                vertical: AppPadding.p16,
              ),
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Stack(
                          children: <Widget>[
                            Container(
                              height: size.width * AppSize.w0_45,
                              width: size.width *AppSize.w0_9,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppRadius.r20),
                                color: theme=="light"?AppColors.white:Colors.transparent,
                                boxShadow: [
                                  AppShadow.primaryShadow
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.r20),
                                child: selectedImage == null
                                    ? Icon(
                                        Icons.image,
                                        size: 50.0,
                                      )
                                    : ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.r20),
                                        child: Image.file(
                                          selectedImage,
                                        ),
                                      ),
                              ),
                            ),
                            selectedImage != null
                                ? Positioned(
                                    top: AppPadding.p10,
                                    right: AppPadding.p10,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(AppRadius.r10_6),
                                      child: Material(
                                        color: Theme.of(context).primaryColor,
                                        child: InkWell(
                                          splashColor:
                                              AppColors.white.withOpacity(0.5),
                                          onTap: () {
                                            cropImage(context);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(),
                                            width: 30.0,
                                            height: 30.0,
                                            child: Icon(
                                              Icons.edit,
                                              color:theme=="light"?AppColors.white:AppColors.pureBlack,
                                              size: 16.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Positioned(
                                    top: 10.0,
                                    right: 10.0,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(AppRadius.r10_6),
                                      child: Material(
                                        color: Theme.of(context).primaryColor,
                                        child: InkWell(
                                          splashColor:
                                              AppColors.white.withOpacity(0.5),
                                          onTap: () {
                                            cropImage(context);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(),
                                            width: AppSize.w30,
                                            height: AppSize.h30,
                                            child: Icon(
                                              Icons.add,
                                              color: AppColors.white,
                                              size: AppSize.w16,
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
                        height: AppSize.h25,
                      ),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, 'required');
                          }
                          return null;
                        },
                        onSaved: (val) {
                          notificationMap.update(
                            'title',
                            (val) => val.trim(),
                            ifAbsent: () => val!.trim(),
                          );
                        },
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: AppColors.pureBlack,
                          fontSize: AppFontsSizeManager.s14_5.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: AppConstants.letterSpacing,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: AppPadding.p15),
                          helperStyle: GoogleFonts.poppins(
                            color: AppColors.pureBlack.withOpacity(0.65),
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          errorStyle: GoogleFonts.poppins(
                            fontSize: AppFontsSizeManager.s13.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          hintStyle: GoogleFonts.poppins(
                            // color: AppColors.black1,
                            fontSize: AppFontsSizeManager.s14_5.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          //prefixIcon: Icon(Icons.title),
                          labelText: getTranslated(context, "title"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: AppFontsSizeManager.s14_5.sp,
                            fontWeight: FontWeight.w500,
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
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, 'required');
                          }

                          return null;
                        },
                        onSaved: (val) {
                          notificationMap.update(
                            'body',
                            (val) => val.trim(),
                            ifAbsent: () => val!.trim(),
                          );
                        },
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: AppColors.pureBlack,
                          fontSize: AppFontsSizeManager.s14_5.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: AppConstants.letterSpacing,
                        ),
                        minLines: 1,
                        maxLines: 6,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: AppPadding.p15, vertical: AppPadding.p15),
                          helperStyle: GoogleFonts.poppins(
                            color: AppColors.pureBlack.withOpacity(0.65),
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          errorStyle: GoogleFonts.poppins(
                            fontSize: AppFontsSizeManager.s13.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          hintStyle: GoogleFonts.poppins(
                            //color: AppColors.black1,
                            fontSize: AppFontsSizeManager.s14_5.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          // prefixIcon: Icon(Icons.mail),
                          labelText: getTranslated(context, "description"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: AppFontsSizeManager.s14_5.sp,
                            fontWeight: FontWeight.w500,
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
                      Container(
                          height: AppSize.h50,
                          decoration: BoxDecoration(
                              color: theme=="light"?AppColors.white:Colors.transparent,
                              border: Border.all(
                                color: Colors.grey,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(AppRadius.r10_6))),
                          child: Padding(
                            padding: const EdgeInsets.only(left: AppPadding.p10, right: AppPadding.p10),
                            child: DropdownButton<String>(
                              hint: Text(
                                getTranslated(context, "sendTo"),
                                textAlign: TextAlign.center,
                                style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                                  //color: AppColors.pureBlack,
                                  fontSize: AppFontsSizeManager.s15.sp,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                              ),
                              underline: Container(),
                              isExpanded: true,
                              value: dropdownTypeValue,
                              icon: Icon(Icons.keyboard_arrow_down,
                                  color: AppColors.pureBlack),
                              iconSize: 24,
                              elevation: 16,
                              style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.blue,
                                fontSize: AppFontsSizeManager.s13.sp,
                                letterSpacing: AppConstants.letterSpacing,
                              ),
                              items: _typeArray
                                  .map((data) => DropdownMenuItem<String>(
                                      child: Text(
                                        data.value!,
                                        style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                                          color: AppColors.pureBlack,
                                          fontSize: AppFontsSizeManager.s15.sp,
                                          letterSpacing: AppConstants.letterSpacing,
                                        ),
                                      ),
                                      value: data.key.toString() //data.key,
                                      ))
                                  .toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  selectedType = value;
                                  dropdownTypeValue = value!;
                                  notificationMap.putIfAbsent(
                                      'notificationType', () => selectedType);
                                });
                              },
                            ),
                          )),
                      sendReq
                          ? Text(
                              getTranslated(context, "required"),
                              style: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s13.sp,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                                color: AppColors.red,
                              ),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: AppSize.h15,
                      ),
                      Container(
                          height: AppSize.h50,
                          decoration: BoxDecoration(
                              color: theme=="light"?AppColors.white:Colors.transparent,
                              border: Border.all(
                                color:AppColors.grey,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(AppRadius.r10_6))),
                          child: Padding(
                            padding: const EdgeInsets.only(left: AppPadding.p10, right: AppPadding.p10),
                            child: DropdownButton<String>(
                              hint: Text(
                                getTranslated(context, "selectLanguage"),
                                textAlign: TextAlign.center,
                                style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                                  //color: AppColors.pureBlack,
                                  fontSize: AppFontsSizeManager.s15.sp,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                              ),
                              underline: Container(),
                              isExpanded: true,
                              value: dropdownLangValue,
                              icon: Icon(Icons.keyboard_arrow_down,
                                  color: AppColors.pureBlack),
                              iconSize: AppSize.w24,
                              elevation: 16,
                              style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.blue,
                                fontSize: AppFontsSizeManager.s13.sp,
                                letterSpacing: AppConstants.letterSpacing,
                              ),
                              items: _langArray
                                  .map((data) => DropdownMenuItem<String>(
                                      child: Text(
                                        data.value!,
                                        style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                                          color: AppColors.pureBlack,
                                          fontSize: AppFontsSizeManager.s15.sp,
                                          letterSpacing: AppConstants.letterSpacing,
                                        ),
                                      ),
                                      value: data.key.toString() //data.key,
                                      ))
                                  .toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  selectedLang = value;
                                  dropdownLangValue = value!;
                                  notificationMap.putIfAbsent(
                                      'notificationLang', () => selectedLang);
                                });
                              },
                            ),
                          )),
                      langReq
                          ? Text(
                              getTranslated(context, "required"),
                              style: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s13.sp,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                                color: AppColors.red,
                              ),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: AppSize.h15,
                      ),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        readOnly: true,
                        controller: controller,
                        onSaved: (val) {
                          if (val != null) {
                            notificationMap.update(
                              'notificationCountry',
                              (val) => selectedCountry,
                              ifAbsent: () => selectedCountry,
                            );
                            notificationMap.update(
                              'countryName',
                              (val) => controller.text,
                              ifAbsent: () => controller.text,
                            );
                          }
                        },
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            showPhoneCode: true,
                            onSelect: (Country country) {
                              setState(() {
                                selectedCountry = "+" + country.phoneCode;
                                controller.text = country.name;
                              });
                            },
                            // Optional. Sets the theme for the country list picker.
                            countryListTheme: CountryListThemeData(
                              // Optional. Sets the border radius for the bottomsheet.
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(AppRadius.r40),
                                topRight: Radius.circular(AppRadius.r40),
                              ),
                              // Optional. Styles the search field.
                              inputDecoration: InputDecoration(
                                labelText: 'Search',
                                hintText: 'Start typing to search',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.lightGrey1
                                        .withOpacity(0.2),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: AppColors.pureBlack,
                          fontSize: AppFontsSizeManager.s14_5.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: AppConstants.letterSpacing,
                        ),
                        minLines: 1,
                        maxLines: 6,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: AppPadding.p15, vertical: AppPadding.p15),
                          helperStyle: GoogleFonts.poppins(
                            color: AppColors.pureBlack.withOpacity(0.65),
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          errorStyle: GoogleFonts.poppins(
                            fontSize: AppFontsSizeManager.s13.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          hintStyle: GoogleFonts.poppins(
                            //color: AppColors.black1,
                            fontSize: AppFontsSizeManager.s14_5.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          // prefixIcon: Icon(Icons.mail),
                          labelText: getTranslated(context, "selectCountry"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: AppFontsSizeManager.s14_5.sp,
                            fontWeight: FontWeight.w500,
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
                        
                        onSaved: (val) {
                         setState(() {
                           link=val!;
                         });
                        },
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: AppColors.pureBlack,
                          fontSize: AppFontsSizeManager.s14_5.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: AppConstants.letterSpacing,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p15),
                          helperStyle: GoogleFonts.poppins(
                            color: AppColors.pureBlack.withOpacity(0.65),
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          errorStyle: GoogleFonts.poppins(
                            fontSize: AppFontsSizeManager.s13.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          hintStyle: GoogleFonts.poppins(
                            // color: AppColors.black1,
                            fontSize: AppFontsSizeManager.s14_5.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          //prefixIcon: Icon(Icons.title),
                          labelText: "link",
                          labelStyle: GoogleFonts.poppins(
                            fontSize: AppFontsSizeManager.s14_5.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.r12),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: AppSize.h25,
                      ),
                      isAdding
                          ? Center(child: CircularProgressIndicator())
                          : Container(
                              height: AppSize.h45,
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0.0),
                              child: MaterialButton(
                                onPressed: () {
                                  //add notificationMap
                                  sendNotification();
                                },
                                color: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r15),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.send,
                                      color: theme=="light"?AppColors.white:AppColors.pureBlack,
                                      size: AppSize.w20,
                                    ),
                                    SizedBox(
                                      width: AppSize.w10,
                                    ),
                                    Text(
                                      getTranslated(
                                          context, "sendNotification"),
                                      style: GoogleFonts.poppins(
                                        color: theme=="light"?AppColors.white:AppColors.pureBlack,
                                        fontSize: AppFontsSizeManager.s15,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      SizedBox(
                        height: AppSize.h25,
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
}
