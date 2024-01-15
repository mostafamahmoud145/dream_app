import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/promoCode.dart';

import '../../models/user.dart';

class EditPromoCodeScreen extends StatefulWidget {
  final PromoCode promoCode;

  const EditPromoCodeScreen({Key? key, required this.promoCode})
      : super(key: key);

  @override
  _EditPromoCodeScreenState createState() => _EditPromoCodeScreenState();
}

class _EditPromoCodeScreenState extends State<EditPromoCodeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String owner, code, discount, usedNumber, id, theme;
  bool isAdding = false, activeCode = false;
  late String dropdownLangValue;
  List<KeyValueModel> _langArray = [
    KeyValueModel(key: "primary", value: "primary"),
    KeyValueModel(key: "promotion", value: "promotion"),
    KeyValueModel(key: "default", value: "default"),
  ];

  @override
  void initState() {
    super.initState();
    isAdding = false;
    dropdownLangValue =
        widget.promoCode.type == null ? "default" : widget.promoCode.type!;
    id = widget.promoCode.promoCodeId;
    owner = widget.promoCode.ownerName;
    code = widget.promoCode.code;
    discount = widget.promoCode.discount.toString();
    usedNumber = widget.promoCode.usedNumber.toString();
    activeCode = widget.promoCode.promoCodeStatus;
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

  addCategory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isAdding = true;
      });
      await FirebaseFirestore.instance.collection(Paths.promoPath).doc(id).set({
        'discount': int.parse(discount),
        'code': code,
        'ownerName': owner,
        'usedNumber': int.parse(usedNumber),
        'promoCodeId': id,
        'promoCodeStatus': activeCode,
        'promoCodeTimestamp': Timestamp.now(),
        'type': dropdownLangValue
      }, SetOptions(merge: true));
      if (activeCode != widget.promoCode.promoCodeStatus) {
        if (activeCode == true)
          await FirebaseFirestore.instance
              .collection(Paths.appAnalysisPath)
              .doc("TgWCp3B22sbkl0Nm3wLx")
              .set({
            'activePromoCodes': FieldValue.increment(1),
            'notActivePromoCodes': FieldValue.increment(-1),
          }, SetOptions(merge: true));
        else
          await FirebaseFirestore.instance
              .collection(Paths.appAnalysisPath)
              .doc("TgWCp3B22sbkl0Nm3wLx")
              .set({
            'activePromoCodes': FieldValue.increment(-1),
            'notActivePromoCodes': FieldValue.increment(1),
          }, SetOptions(merge: true));
      }

      setState(() {
        isAdding = false;
      });
      Navigator.pop(context);
    } else {
      showSnack('Please fill all the details!', context);
    }
  }

  void showSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(AppMargin.m8),
      borderRadius: BorderRadius.circular(AppRadius.r7),
      backgroundColor: AppColors.redShade500,
      animationDuration: Duration(milliseconds: AppConstants.milliseconds300),
      isDismissible: true,
      boxShadows: [AppShadow.primaryShadow],
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
    return Scaffold(
      key: _scaffoldKey,
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
                    left: AppPadding.p16,
                    right: AppPadding.p16,
                    top: 0.0,
                    bottom: AppPadding.p16),
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
                          splashColor: AppColors.white.withOpacity(0.6),
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
                              color: theme == "light"
                                  ? AppColors.white
                                  : AppColors.pureBlack,
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
                      getTranslated(context, "editPromo"),
                      style: GoogleFonts.poppins(
                        color: theme == "light"
                            ? AppColors.white
                            : AppColors.pureBlack,
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
                  horizontal: AppPadding.p16, vertical: AppPadding.p16),
              children: <Widget>[
                SizedBox(
                  height: AppSize.h20,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        initialValue: code,
                        /* validator: (String val) {
                          if (val.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },*/
                        onSaved: (val) {
                          code = val!;
                        },
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: AppColors.pureBlack,
                          fontSize: AppFontsSizeManager.s14_5.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: AppConstants.letterSpacing,
                        ),
                        readOnly: true,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 15.0),
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
                            color: AppColors.black1,
                            fontSize: AppFontsSizeManager.s14_5.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          labelText: getTranslated(context, "promoCodes"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: AppFontsSizeManager.s14_5.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        initialValue: owner,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          owner = val!;
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
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 15.0),
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
                            color: AppColors.black1,
                            fontSize: AppFontsSizeManager.s14_5.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          labelText: getTranslated(context, "owner"),
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
                        height: AppSize.w15,
                      ),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        initialValue: discount,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          discount = val!;
                        },
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: AppColors.pureBlack,
                          fontSize: AppFontsSizeManager.s14_5.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: AppConstants.letterSpacing,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: AppSize.w15),
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
                            color: AppColors.black1,
                            fontSize: AppFontsSizeManager.s14_5.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          labelText: getTranslated(context, "discount"),
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
                        height: AppSize.w15,
                      ),
                      Container(
                          height: AppSize.h50,
                          decoration: BoxDecoration(
                              color: theme == "light"
                                  ? AppColors.white
                                  : Colors.transparent,
                              border: Border.all(
                                color: Colors.grey,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(AppRadius.r10_6))),
                          child: Padding(
                            padding: const EdgeInsets.only(left: AppPadding.p10, right: AppPadding.p10),
                            child: DropdownButton<String>(
                              hint: Text(
                                getTranslated(context, "type"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
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
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.blue,
                                fontSize: AppFontsSizeManager.s13.sp,
                                letterSpacing: AppConstants.letterSpacing,
                              ),
                              items: _langArray
                                  .map((data) => DropdownMenuItem<String>(
                                      child: Text(
                                        data.value!,
                                        style: TextStyle(
                                          fontFamily:
                                              getTranslated(context, "Ithra"),
                                          color: AppColors.pureBlack,
                                          fontSize: AppFontsSizeManager.s15.sp,
                                          letterSpacing:
                                              AppConstants.letterSpacing,
                                        ),
                                      ),
                                      value: data.key.toString() //data.key,
                                      ))
                                  .toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  dropdownLangValue = value!;
                                });
                              },
                            ),
                          )),
                      SizedBox(
                        height: AppSize.h15,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: AppPadding.p10, right: AppPadding.p10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              getTranslated(context, "active"),
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: Theme.of(context).primaryColor,
                                fontSize: AppFontsSizeManager.s15.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Switch(
                              value: activeCode,
                              onChanged: (value) {
                                setState(() {
                                  activeCode = value;
                                });
                              },
                              activeTrackColor: AppColors.pink,
                              activeColor: AppColors.orangeAccent,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: AppSize.h15,
                      ),
                      isAdding
                          ? Center(child: CircularProgressIndicator())
                          : Center(
                              child: Container(
                                height: AppSize.h45,
                                width: double.infinity,
                                child: MaterialButton(
                                  onPressed: () {
                                    addCategory();
                                  },
                                  color: Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.r15),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      FaIcon(
                                        FontAwesomeIcons.atom,
                                        color: theme == "light"
                                            ? AppColors.white
                                            : AppColors.pureBlack,
                                        size: AppSize.w20,
                                      ),
                                      SizedBox(
                                        width: AppSize.w10,
                                      ),
                                      Text(
                                        getTranslated(context, "save"),
                                        style: GoogleFonts.poppins(
                                          color: theme == "light"
                                              ? AppColors.white
                                              : AppColors.pureBlack,
                                          fontSize: AppFontsSizeManager.s15.sp,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(
                        height: AppSize.h15,
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
