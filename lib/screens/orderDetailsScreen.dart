import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/consultPackage.dart';
import 'package:grocery_store/models/consultReview.dart';
import 'package:grocery_store/models/order.dart';
import 'package:grocery_store/models/promoCode.dart';
import 'package:grocery_store/models/user.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../config/app_fonts.dart';
import '../config/constants.dart';
import '../widget/back_button.dart';

class OrderDetails extends StatefulWidget {
  final Orders order;
  final String? type;
  final bool? fromSupport;

  const OrderDetails(
      {Key? key, required this.order, this.type, this.fromSupport})
      : super(key: key);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  consultPackage? package;
  PromoCode? promo;
  ConsultReview? review;
  bool loadPackage = true,
      loadPromo = true,
      loadAppointments = true,
      loadReview = true;
  DateFormat dateFormat = DateFormat('d/MM/yyyy');
  List<AppAppointments> appointmentList = [];
  bool cancel = false;
  String theme = "light";
  String answerNum = "0", remainingNum = "0", status = "open";
  GroceryUser user = GroceryUser();

  @override
  void initState() {
    super.initState();
    if (widget.order.packageId != null && widget.order.packageId != "")
      getPackageDetails();
    getOrderAppointment();
    ;

    if (widget.order.promoCodeId != null && widget.order.promoCodeId != "")
      getPromoDetails();
  }

  Future<void> getPackageDetails() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(Paths.packagesPath)
          .doc(widget.order.packageId)
          .get();
      setState(() {
        package = consultPackage.fromMap(documentSnapshot.data() as Map);
        loadPackage = false;
      });
    } catch (e) {}
  }

  Future<void> getPromoDetails() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(Paths.promoPath)
          .doc(widget.order.promoCodeId)
          .get();
      setState(() {
        promo = PromoCode.fromMap(documentSnapshot.data() as Map);
        loadPromo = false;
      });
    } catch (e) {}
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showSnakbar(String s, bool status) {
    Fluttertoast.showToast(
        msg: s,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: AppColors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.white,
      key: _scaffoldKey,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  right: AppPadding.p32.w,
                  top: AppPadding.p25_3.h,
                  bottom: AppPadding.p16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomBackButton(),
                  SizedBox(
                    width: AppSize.w21_3.w,
                  ),
                  Text(
                    getTranslated(context, "details"),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: getTranslated(context, 'Ithra'),
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      color: AppColors.pureBlack.withOpacity(0.8),
                      fontWeight: AppFontsWeightManager.bold),
                ),
                Spacer(),
                (widget.fromSupport == true &&
                        widget.order.orderStatus != "closed" &&
                        widget.order.orderStatus != "cancel")
                    ? cancel
                        ? CircularProgressIndicator()
                        : Padding(
                          padding:  EdgeInsets.only(left: AppPadding.p16.w),
                          child: InkWell(
                              splashColor: AppColors.white.withOpacity(0.5),
                              onTap: () async {
                                cancelDialog(size);
                              },
                              child: Container(
                                height: AppSize.h35,
                                width: size.width * AppSize.w0_3,
                                padding: const EdgeInsets.all(AppPadding.p5),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(AppRadius.r35),
                                ),
                                child: Center(
                                  child: Text(
                                    getTranslated(context, "cancel"),
                                    style: GoogleFonts.elMessiri(
                                      color: theme == "light"
                                          ? AppColors.white
                                          : AppColors.pureBlack,
                                      fontSize: AppFontsSizeManager.s13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: AppConstants.letterSpacing,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        )
                    : SizedBox(),
              ],
            ),
            ),
            Center(
                child: Container(
                    color: AppColors.lightGray,
                    height: AppSize.h1.h,
                    width: double.infinity)),
            Expanded(
              child: ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppPadding.p32.w,
                        vertical: AppPadding.p32.h),
                    child: Container(
                      width: size.width,
                      padding: EdgeInsets.symmetric(
                          horizontal: AppPadding.p21_3.w,
                          vertical: AppPadding.p21_3.h),
                      //height: AppSize.h408.h,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.lightGrey, width: AppSize.w1_5.w),
                        color: theme == "light"
                            ? AppColors.white
                            : AppColors.greyShade400,
                        borderRadius: BorderRadius.circular(AppRadius.r21_3.r),
                        // boxShadow: [AppShadow.primaryShadow],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.only(bottom: AppPadding.p10_6.h),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                getTranslated(context, "orderDetails"),
                                style: TextStyle(
                                  fontFamily:
                                      getTranslated(context, 'Ithra_Bold'),
                                  color: theme == "light"
                                      ? AppColors.pink
                                      : AppColors.white,
                                  fontSize: AppFontsSizeManager.s21_3.sp,
                                  fontWeight: AppFontsWeightManager.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, "date"),
                                    style: TextStyle(
                                      color: AppColors.darkPink2,
                                      fontFamily: 'Ithralight',
                                      fontWeight: AppFontsWeightManager.bold600,
                                      fontSize: AppFontsSizeManager.s21_3.sp,
                                    ),
                                  ),
                                  Text(
                                    '${dateFormat.format(widget.order.orderTimestamp.toDate()).toString()}',
                                    style: TextStyle(
                                      color: AppColors.pureBlack,
                                      fontFamily:
                                          getTranslated(context, 'Ithralight'),
                                      fontSize: AppFontsSizeManager.s21_3.sp,
                                      // fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: AppSize.h10_6.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, "price"),
                                    style: TextStyle(
                                      color: AppColors.darkPink2,
                                      fontWeight: AppFontsWeightManager.bold600,
                                      fontFamily: 'Ithralight',
                                      fontSize: AppFontsSizeManager.s21_3.sp,
                                    ),
                                  ),
                                  Text(
                                    widget.order.price == null
                                        ? "0"
                                        : widget.order.price.toString() + "\$",
                                    style: TextStyle(
                                      color: AppColors.pureBlack,
                                      fontFamily:
                                          getTranslated(context, 'Ithralight'),
                                      fontSize: AppFontsSizeManager.s21_3.sp,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: AppSize.h10_6.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, "callprice"),
                                    style: TextStyle(
                                      color: AppColors.darkPink2,
                                      fontFamily: 'Ithralight',
                                      fontWeight: AppFontsWeightManager.bold600,
                                      fontSize: AppFontsSizeManager.s21_3.sp,
                                    ),
                                  ),
                                  Text(
                                    double.parse(widget.order.callPrice
                                                .toString())
                                            .toStringAsFixed(3) +
                                        "\$",
                                    style: TextStyle(
                                      color: AppColors.pureBlack,
                                      fontFamily:
                                          getTranslated(context, 'Ithralight'),
                                      fontSize: AppFontsSizeManager.s21_3.sp,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: AppSize.h10_6.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(
                                        context, "NumberOfPackageCalls"),
                                    style: TextStyle(
                                      color: AppColors.darkPink2,
                                      fontWeight: AppFontsWeightManager.bold600,
                                      fontFamily: 'Ithralight',
                                      fontSize: AppFontsSizeManager.s21_3.sp,
                                    ),
                                  ),
                                  Text(
                                    widget.order.packageCallNum.toString(),
                                    style: TextStyle(
                                      color: AppColors.pureBlack,
                                      fontFamily:
                                          getTranslated(context, 'Ithralight'),
                                      fontSize: AppFontsSizeManager.s21_3.sp,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: AppSize.h10_6.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, "answeredCall"),
                                    style: TextStyle(
                                      color: AppColors.darkPink2,
                                      fontWeight: AppFontsWeightManager.bold600,
                                      fontFamily: 'Ithralight',
                                      fontSize: AppFontsSizeManager.s21_3.sp,
                                    ),
                                  ),
                                  loadAppointments
                                      ? CircularProgressIndicator()
                                      : Text(
                                          answerNum,
                                          style: TextStyle(
                                            color: AppColors.pureBlack,
                                            fontFamily: getTranslated(
                                                context, 'Ithralight'),
                                            fontSize:
                                                AppFontsSizeManager.s21_3.sp,
                                          ),
                                        ),
                                ],
                              ),
                              SizedBox(
                                height: AppSize.h10_6.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, "remainingCall"),
                                    style: TextStyle(
                                      color: AppColors.darkPink2,
                                      fontWeight: AppFontsWeightManager.bold600,
                                      fontFamily: 'Ithralight',
                                      fontSize: AppFontsSizeManager.s21_3.sp,
                                    ),
                                  ),
                                  loadAppointments
                                      ? CircularProgressIndicator()
                                      : Text(
                                          remainingNum,
                                          style: TextStyle(
                                            color: AppColors.pureBlack,
                                            fontFamily: getTranslated(
                                                context, 'Ithralight'),
                                            fontSize:
                                                AppFontsSizeManager.s21_3.sp,
                                          ),
                                        ),
                                ],
                              ),
                              SizedBox(
                                height: AppSize.h10_6.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, "orderType"),
                                    style: TextStyle(
                                      color: AppColors.darkPink2,
                                      fontWeight: AppFontsWeightManager.bold600,
                                      fontFamily: 'Ithralight',
                                      fontSize: AppFontsSizeManager.s21_3.sp,
                                    ),
                                  ),
                                  Text(
                                    widget.order.consultType == "chat"
                                        ? getTranslated(context, "chat")
                                        : getTranslated(context, "voice"),
                                    style: TextStyle(
                                      color: AppColors.black,
                                      fontWeight: AppFontsWeightManager.bold600,
                                      fontFamily: 'Ithralight',
                                      fontSize: AppFontsSizeManager.s21_3.sp,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: AppSize.h10.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, "status"),
                                    style: TextStyle(
                                      color: AppColors.darkPink2,
                                      fontWeight: AppFontsWeightManager.bold600,
                                      fontFamily: 'Ithralight',
                                      fontSize: AppFontsSizeManager.s21_3.sp,
                                    ),
                                  ),
                                  loadAppointments
                                      ? CircularProgressIndicator()
                                      : Text(
                                          status, //widget.order.orderStatus,
                                          style: TextStyle(
                                            color: AppColors.pureBlack,
                                            fontFamily: 'Ithralight',
                                            fontSize:
                                                AppFontsSizeManager.s21_3.sp,
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

                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.greylight5,
                          blurRadius: 40.r,
                          spreadRadius: 0.0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: AppPadding.p32.w),
                          child: Container(
                            // height: 150,
                            width: AppSize.w244.w,
                            // width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: 35.h, vertical: AppPadding.p21_3.h),
                            decoration: BoxDecoration(
                              color: theme == "light"
                                  ? AppColors.white
                                  : AppColors.greyShade400,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r10_6.r),
                              border: Border.all(
                                  color: AppColors.lightGray,
                                  width: AppSize.w1_5.w),
                              boxShadow: [AppShadow.primaryShadow],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  getTranslated(context, "consultDetails"),
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, 'Ithra'),
                                    color: theme == "light"
                                        ? AppColors.pink
                                        : AppColors.white,
                                    fontSize: AppFontsSizeManager.s21_3.sp,
                                    fontWeight: AppFontsWeightManager.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(
                                  height: AppSize.h21_3.h,
                                ),
                                Column(
                                  children: [
                                    Container(
                                      height: AppSize.h60.r,
                                      width: AppSize.w60.r,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColors.white,
                                            width: AppSize.w1),
                                        shape: BoxShape.circle,
                                        color: theme == "light"
                                            ? AppColors.pink
                                            : AppColors.white,
                                      ),
                                      child: widget.order.consult.image!.isEmpty
                                          ? Icon(
                                              Icons.person,
                                              color: AppColors.white,
                                              size: AppSize.w40.r,
                                            )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppRadius.r100.r),
                                              child: FadeInImage.assetNetwork(
                                                placeholder: AssetsManager
                                                    .icon_personPath,
                                                placeholderScale: 0.5,
                                                imageErrorBuilder: (context,
                                                        error, stackTrace) =>
                                                    Icon(
                                                  Icons.person,
                                                  color: AppColors.pureBlack,
                                                  size: AppSize.w65.r,
                                                ),
                                                image:
                                                    widget.order.consult.image!,
                                                fit: BoxFit.cover,
                                                fadeInDuration: Duration(
                                                    milliseconds: AppConstants
                                                        .milliseconds250),
                                                fadeInCurve: Curves.easeInOut,
                                                fadeOutDuration: Duration(
                                                    milliseconds: AppConstants
                                                        .milliseconds150),
                                                fadeOutCurve: Curves.easeInOut,
                                              ),
                                            ),
                                    ),
                                    SizedBox(
                                      height: AppSize.h10_6.h,
                                    ),
                                    Text(
                                      widget.order.consult.name,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: AppConstants.maxLines1,
                                      style: TextStyle(
                                        fontFamily:
                                            getTranslated(context, 'Ithra'),
                                        color: AppColors.pureBlack,
                                        fontSize: AppFontsSizeManager.s18_6.sp,
                                        fontWeight:
                                            AppFontsWeightManager.semiBold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    // Text(
                                    //   widget.order.consult.phone,
                                    //   textAlign: TextAlign.start,
                                    //   overflow: TextOverflow.ellipsis,
                                    //   maxLines: 1,
                                    //   style: TextStyle(
                                    //     fontFamily:
                                    //         getTranslated(context, "Ithra"),
                                    //     color: AppColors.greydark,
                                    //     fontSize: 15.0,
                                    //     //  fontWeight: FontWeight.w600,
                                    //     letterSpacing: 0.3,
                                    //   ),
                                    // ),
                                    // SizedBox(
                                    //   height: AppSize.h18_6.h,
                                    // ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            width: AppSize.w21_3.w,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: AppPadding.p32.w),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: AppPadding.p21_3.h,
                                horizontal: AppPadding.p41_3.w),
                            //  height: 150,
                            width: AppSize.w244.w,
                            decoration: BoxDecoration(
                              color: theme == "light"
                                  ? AppColors.white
                                  : AppColors.greyShade400,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r10_6.r),
                              border: Border.all(
                                  color: AppColors.lightGray,
                                  width: AppSize.w1_5.w),
                              boxShadow: [AppShadow.primaryShadow],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  getTranslated(context, "clientDetails"),
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, 'Ithra'),
                                    color: theme == "light"
                                        ? AppColors.pink
                                        : AppColors.white,
                                    fontSize: AppFontsSizeManager.s21_3.sp,
                                    fontWeight: AppFontsWeightManager.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(
                                  height: AppSize.h21_3.h,
                                ),
                                Column(
                                  children: [
                                    Container(
                                      height: AppSize.h60.r,
                                      width: AppSize.w60.r,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColors.white,
                                            width: AppSize.w1),
                                        shape: BoxShape.circle,
                                        color: theme == "light"
                                            ? AppColors.pink
                                            : AppColors.white,
                                      ),
                                      child: widget.order.user.image!.isEmpty
                                          ? Icon(Icons.person,
                                              color: AppColors.white,
                                              size: AppSize.w40.r)
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppRadius.r100.r),
                                              child: FadeInImage.assetNetwork(
                                                placeholder: AssetsManager
                                                    .icon_personPath,
                                                placeholderScale: 0.5,
                                                imageErrorBuilder: (context,
                                                        error, stackTrace) =>
                                                    Icon(
                                                  Icons.person,
                                                  color: AppColors.pureBlack,
                                                  size: AppSize.w65.r,
                                                ),
                                                image:
                                                    widget.order.consult.image!,
                                                fit: BoxFit.cover,
                                                fadeInDuration: Duration(
                                                    milliseconds: AppConstants
                                                        .milliseconds250),
                                                fadeInCurve: Curves.easeInOut,
                                                fadeOutDuration: Duration(
                                                    milliseconds: AppConstants
                                                        .milliseconds150),
                                                fadeOutCurve: Curves.easeInOut,
                                              ),
                                            ),
                                    ),
                                    SizedBox(
                                      height: AppSize.h10_6.h,
                                    ),
                                    Text(
                                      widget.order.user.name,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontFamily:
                                            getTranslated(context, 'Ithra'),
                                        color: AppColors.pureBlack,
                                        fontSize: AppFontsSizeManager.s18_6.sp,
                                        fontWeight:
                                            AppFontsWeightManager.semiBold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    // Text(
                                    //   widget.order.user.phone,
                                    //   textAlign: TextAlign.start,
                                    //   overflow: TextOverflow.ellipsis,
                                    //   maxLines: 1,
                                    //   style: TextStyle(
                                    //     fontFamily:
                                    //         getTranslated(context, "Ithra"),
                                    //     color: AppColors.greydark,
                                    //     fontSize: 15.0,
                                    //     //  fontWeight: FontWeight.w600,
                                    //     letterSpacing: 0.3,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: AppSize.h32.h,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
                    child: Container(
                      height: AppSize.h157_3.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme == "light"
                            ? AppColors.white
                            : AppColors.greyShade400,
                        borderRadius: BorderRadius.circular(AppRadius.r16.r),
                        border: Border.all(
                            color: AppColors.lightGray, width: AppSize.w1.w),
                        boxShadow: [AppShadow.primaryShadow],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppSize.w45.w,
                                vertical: AppSize.h21_3.h),
                            child: Column(
                              children: [
                                Center(
                                  child: Text(
                                    getTranslated(context, "package"),
                                    style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, 'Ithra'),
                                      color: theme == "light"
                                          ? AppColors.linear2
                                          : AppColors.white,
                                      fontSize: AppFontsSizeManager.s21_3.sp,
                                      fontWeight: AppFontsWeightManager.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: AppSize.h10_6.h),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            getTranslated(context, "call"),
                                            style: TextStyle(
                                              color: theme == "light"
                                                  ? AppColors.pink
                                                  : AppColors.white,
                                              fontSize:
                                                  AppFontsSizeManager.s21_3.sp,
                                              fontFamily: getTranslated(
                                                  context, 'Ithra'),
                                            ),
                                          ),
                                          SizedBox(height: AppSize.h10_6.h),
                                          Center(
                                            child: Text(
                                              (package == null ||
                                                      package!.callNum == null)
                                                  ? "0"
                                                  : package!.callNum.toString(),
                                              style: TextStyle(
                                                height: AppSize.h1_5.h,
                                                color: theme == "light"
                                                    ? AppColors.pureBlack
                                                    : AppColors.white,
                                                fontSize: AppFontsSizeManager
                                                    .s21_3.sp,
                                                fontFamily: getTranslated(
                                                    context, 'Ithra'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            getTranslated(context, "discount"),
                                            style: TextStyle(
                                              fontFamily: getTranslated(
                                                  context, 'Ithra'),
                                              color: theme == "light"
                                                  ? AppColors.pink
                                                  : AppColors.white,
                                              fontSize:
                                                  AppFontsSizeManager.s21_3.sp,
                                            ),
                                          ),
                                          SizedBox(height: AppSize.h10_6.h),
                                          Text(
                                            (package == null ||
                                                    package!.discount == null)
                                                ? "%0"
                                                : "%" +
                                                    package!.discount
                                                        .toString(),
                                            style: TextStyle(
                                              height: AppSize.h1_5.h,
                                              fontFamily: getTranslated(
                                                  context, 'Ithra'),
                                              color: theme == "light"
                                                  ? AppColors.pureBlack
                                                  : AppColors.white,
                                              fontSize:
                                                  AppFontsSizeManager.s21_3.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            getTranslated(context, "price"),
                                            style: TextStyle(
                                              fontFamily: getTranslated(
                                                  context, 'Ithra'),
                                              color: theme == "light"
                                                  ? AppColors.pink
                                                  : AppColors.white,
                                              fontSize:
                                                  AppFontsSizeManager.s21_3.sp,
                                            ),
                                          ),
                                          SizedBox(
                                            height: AppSize.h10_6.h,
                                          ),
                                          Text(
                                            (package == null ||
                                                    package!.price == null)
                                                ? "\$0"
                                                : "\$" +
                                                    package!.price.toString(),
                                            style: TextStyle(
                                              height: AppSize.h1_5.h,
                                              fontFamily: getTranslated(
                                                  context, 'Ithra'),
                                              color: theme == "light"
                                                  ? AppColors.pureBlack
                                                  : AppColors.white,
                                              fontSize:
                                                  AppFontsSizeManager.s21_3.sp,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h32.h,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
                    child: Container(
                      width: double.infinity,
                      height: AppSize.h101_3.h,
                      decoration: BoxDecoration(
                        color: theme == "light"
                            ? AppColors.white
                            : AppColors.greyShade400,
                        borderRadius: BorderRadius.circular(AppRadius.r16.r),
                        border: Border.all(
                            color: AppColors.lightGray, width: AppSize.w1.w),
                        boxShadow: [AppShadow.primaryShadow],
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              AssetsManager.coupon_iconPath,
                              width: AppSize.w32.r,
                              height: AppSize.h32.r,
                            ),
                            SizedBox(
                              width: AppSize.w16.w,
                            ),
                            Text(
                              getTranslated(context, "promoTxt"),
                              style: TextStyle(
                                fontFamily: getTranslated(context, 'Ithra'),
                                color: theme == "light"
                                    ? AppColors.pink
                                    : AppColors.white,
                                fontSize: AppFontsSizeManager.s21_3.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSize.w22_6.w,
                                ),
                                child: widget.order.promoCodeId != null
                                    ? loadPromo
                                        ? Center(
                                            child: CircularProgressIndicator())
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                promo!.code.toString(),
                                                style: TextStyle(
                                                  fontWeight:
                                                      AppFontsWeightManager
                                                          .bold600,
                                                  fontFamily: 'Ithralight',
                                                  color: theme == "light"
                                                      ? AppColors.pink
                                                      : AppColors.white,
                                                  fontSize: AppFontsSizeManager
                                                      .s21.sp,
                                                ),
                                              ),
                                            ],
                                          )
                                    : Center(
                                        child: Text(
                                          getTranslated(context, "noCode"),
                                          style: TextStyle(
                                            fontFamily: 'Ithralight',
                                            color: AppColors.black,
                                            fontSize:
                                                AppFontsSizeManager.s21_3.sp,
                                            fontWeight:
                                                AppFontsWeightManager.bold600,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h32.h,
                  ),

                  // here code of listview ................
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
                    child: Container(
                      height: AppSize.h113_3.h,
                      width: double.infinity,
                      padding: EdgeInsets.all(AppPadding.p21_3.r),
                      decoration: BoxDecoration(
                        color: theme == "light"
                            ? AppColors.white
                            : AppColors.greyShade400,
                        borderRadius: BorderRadius.circular(AppRadius.r16.r),
                        border: Border.all(
                            color: AppColors.lightGray, width: AppSize.w1.w),
                        boxShadow: [AppShadow.primaryShadow],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                getTranslated(context, "appointments"),
                                style: TextStyle(
                                  fontFamily: getTranslated(context, 'Ithra'),
                                  color: theme == "light"
                                      ? AppColors.linear2
                                      : AppColors.white,
                                  height: AppSize.h1_5.h,
                                  fontSize: AppFontsSizeManager.s21_3.sp,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              //SizedBox(),
                            ],
                          ),
                          SizedBox(
                            height: AppSize.h12.h,
                          ),
                          if (loadAppointments == false &&
                              appointmentList.length == 0)
                            Center(
                              child: Text(
                                getTranslated(context, "noData"),
                                style: TextStyle(
                                  fontFamily: getTranslated(context, 'Ithra'),
                                  color: AppColors.pureBlack,
                                  fontSize: AppFontsSizeManager.s24.sp,
                                  // fontWeight: FontWeight.normal,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              itemCount: appointmentList.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(0),
                              itemBuilder: (context, index) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        (appointmentList[index]
                                                        .appointmentStatus ==
                                                    "closed" ||
                                                widget.fromSupport == false)
                                            ? SvgPicture.asset(
                                                AssetsManager
                                                    .calendar_clock_iconPath,
                                                width: AppSize.w21_3.r,
                                                height: AppSize.h21_3.r,
                                              )
                                            : loadAppointments
                                                ? CircularProgressIndicator()
                                                : InkWell(
                                                    splashColor: Colors.white
                                                        .withOpacity(0.6),
                                                    onTap: () async {
                                                      loadAppointments = true;
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(Paths
                                                              .appAppointments)
                                                          .doc(appointmentList[
                                                                  index]
                                                              .appointmentId)
                                                          .delete();
                                                      getOrderAppointment();
                                                    },
                                                    child: Icon(
                                                      Icons.delete_outline,
                                                      color: AppColors.red,
                                                    ),
                                                  ),
                                        SizedBox(
                                          width: AppSize.w10_6.w,
                                        ),
                                        Text(
                                          '${dateFormat.format(appointmentList[index].appointmentTimestamp.toDate())}',

                                          //appointmentList[index].appointmentTimestamp.toString().replaceAll("UTC+2", ""),
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            // height: AppSize.h1_5.h,
                                            fontFamily: getTranslated(
                                                context, "Ithralight"),
                                            color: theme == "light"
                                                ? AppColors.black
                                                : AppColors.white,
                                            // backgroundColor: Colors.red,
                                            fontSize:
                                                AppFontsSizeManager.s18_6.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Image.asset(
                                          AssetsManager.clockIcon,
                                          // color: AppColors.pink,
                                          width: AppSize.w21_3.w,
                                          height: AppSize.h21_3.h,
                                        ),
                                        SizedBox(
                                          width: AppSize.w10_6.w,
                                        ),
                                        Text(
                                          appointmentList[index]
                                                  .time
                                                  .hour
                                                  .toString() +
                                              ":" +
                                              appointmentList[index]
                                                  .time
                                                  .minute
                                                  .toString() +
                                              "${appointmentList[index].time.hour > 12 ? " " + getTranslated(context, "PM") : " " + getTranslated(context, "AM")}",
                                          style: TextStyle(
                                            // height: AppSize.h1.h,
                                            fontFamily: getTranslated(
                                                context, "Ithralight"),
                                            color: AppColors.pureBlack,

                                            fontSize:
                                                AppFontsSizeManager.s18_6.sp,
                                            //fontWeight: AppFontsWeightManager.bold500.bold500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: AppSize.w65_3.w,
                                      height: AppSize.h28.h,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: AppPadding.p2),
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.r5_3.r),
                                          border: Border.all(
                                              color: AppColors.pink)),
                                      child: Text(
                                        appointmentList[index]
                                                    .appointmentStatus ==
                                                "open"
                                            ? getTranslated(context, "open2")
                                            : getTranslated(context, "closed2"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily:
                                              getTranslated(context, "Ithra"),
                                          color: AppColors.pink,
                                          fontSize: AppFontsSizeManager.s16.sp,
                                          //fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // appointmentList[index].appointmentStatus ==
                                    //         "closed"
                                    //     ? InkWell(
                                    //         splashColor:
                                    //             AppColors.white.withOpacity(0.6),
                                    //         onTap: () {
                                    //           showReview(
                                    //               size,
                                    //               appointmentList[index]
                                    //                   .appointmentId);
                                    //         },
                                    //         // child: Icon(
                                    //         //   Icons.star,
                                    //         //   col or: AppColors.yellow,
                                    //         // ),
                                    //       )
                                    //     : SizedBox(),
                                  ],
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return SizedBox(
                                  height: 0,
                                );
                              },
                            ),
                          // SizedBox(
                          //   height: AppSize.h20.h,
                          // ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h40,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  cancelDialog(Size size) {
    return showDialog(
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppRadius.r15),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(
            left: AppPadding.p16,
            right: AppPadding.p16,
            top: AppPadding.p20,
            bottom: AppPadding.p10),
        content: Container(
          color: AppColors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                getTranslated(context, "cancel"),
                style: TextStyle(
                  fontFamily: getTranslated(context, "Ithra"),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: AppColors.black1,
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              Text(
                getTranslated(context, "cancelOrder"),
                style: TextStyle(
                  fontFamily: getTranslated(context, "Ithra"),
                  fontSize: AppFontsSizeManager.s14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  color: AppColors.black1,
                ),
              ),
              SizedBox(
                height: AppSize.h5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    width: AppSize.w50,
                    child: MaterialButton(
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        getTranslated(context, 'no'),
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          color: AppColors.black1,
                          fontSize: AppFontsSizeManager.s13_5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: AppSize.w50,
                    child: MaterialButton(
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () async {
                        Navigator.pop(context);
                        setState(() {
                          cancel = true;
                        });
                        QuerySnapshot querySnapshot =
                            await FirebaseFirestore.instance
                                .collection(Paths.usersPath)
                                .where(
                                  'uid',
                                  isEqualTo: widget.order.user.uid,
                                )
                                .limit(1)
                                .get();
                        if (querySnapshot != null &&
                            querySnapshot.docs.length != 0 &&
                            status != "cancel") {
                          var userSearch = GroceryUser.fromMap(
                              querySnapshot.docs[0].data() as Map);
                          var price = 0.0;
                          await FirebaseFirestore.instance
                              .collection(Paths.appAppointments)
                              .where('orderId', isEqualTo: widget.order.orderId)
                              .where('appointmentStatus', isEqualTo: "closed")
                              .get()
                              .then((value) async {
                            if (value.docs.length > 0) {
                              price = (widget.order.packageCallNum -
                                      value.docs.length) *
                                  widget.order.callPrice;
                            } else {
                              price = (widget.order.packageCallNum) *
                                  widget.order.callPrice;
                            }
                          }).catchError((err) {
                            errorLog("cancelOrder", err.toString());
                          });
                          dynamic balance = double.parse(price.toString());
                          if (userSearch.balance != null) {
                            balance = userSearch.balance + balance;
                            userSearch.balance = balance;
                          }
                          await FirebaseFirestore.instance
                              .collection(Paths.usersPath)
                              .doc(userSearch.uid)
                              .set({
                            'balance': balance,
                          }, SetOptions(merge: true));
                          //update payment history
                          await FirebaseFirestore.instance
                              .collection(Paths.userPaymentHistory)
                              .doc(Uuid().v4())
                              .set({
                            'userUid': userSearch.uid,
                            'payType': "refund",
                            'payDate': Timestamp.now(),
                            //FieldValue.serverTimestamp(),
                            'payDateValue':
                                Timestamp.now().millisecondsSinceEpoch,
                            'amount': price.toString(),
                            'otherData': {
                              'uid': "fuHfYYjTmRf7rjkyIhxrqp1pPJ32",
                              'name': "Dream Application",
                              'image': "",
                              'phone': "..",
                            },
                          });
                          //cancel order
                          await FirebaseFirestore.instance
                              .collection(Paths.ordersPath)
                              .doc(widget.order.orderId)
                              .set({
                            'orderStatus': "cancel",
                          }, SetOptions(merge: true));
                          //cancel allAppontment
                          var querySnapshot2 = await FirebaseFirestore.instance
                              .collection(Paths.appAppointments)
                              .where('orderId', isEqualTo: widget.order.orderId)
                              .where('appointmentStatus',
                                  whereIn: ['new', 'open']).get();
                          for (var doc in querySnapshot2.docs) {
                            await FirebaseFirestore.instance
                                .collection(Paths.appAppointments)
                                .doc(doc.id)
                                .set({
                              'appointmentStatus': 'cancel',
                            }, SetOptions(merge: true));
                          }
                        }
                        setState(() {
                          cancel = false;
                          status = "cancel";
                          widget.order.orderStatus = "cancel";
                        });
                        //
                      },
                      child: Text(
                        getTranslated(context, 'yes'),
                        style: GoogleFonts.cairo(
                          color: Colors.red.shade700,
                          fontSize: AppFontsSizeManager.s13_5,
                          fontWeight: AppFontsWeightManager.bold,
                          letterSpacing: 0.3,
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

  void showNoNotifSnack(String text, bool status) {
    Flushbar(
      margin: const EdgeInsets.all(AppPadding.p80),
      borderRadius: BorderRadius.circular(7),
      backgroundColor: status ? AppColors.greenShade500 : AppColors.redShade500,
      animationDuration: Duration(milliseconds: 300),
      isDismissible: true,
      boxShadows: [AppShadow.primaryShadow],
      shouldIconPulse: false,
      duration: Duration(milliseconds: AppConstants.milliseconds1500),
      icon: Icon(
        Icons.notification_important,
        color: theme == "light" ? AppColors.white : AppColors.pureBlack,
      ),
      messageText: Text(
        '$text',
        style: TextStyle(
          fontFamily: getTranslated(context, "Ithra"),
          fontSize: AppFontsSizeManager.s14,
          fontWeight: AppFontsWeightManager.bold500,
          letterSpacing: 0.3,
          color: theme == "light" ? AppColors.white : AppColors.pureBlack,
        ),
      ),
    )..show(context);
  }

  Future<void> getOrderAppointment() async {
    try {
      int answer = 0, remain = 0;
      loadAppointments = true;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.appAppointments)
          .where('orderId', isEqualTo: widget.order.orderId)
          .get();

      QuerySnapshot querySnapshotClosed = await FirebaseFirestore.instance
          .collection(Paths.appAppointments)
          .where('orderId', isEqualTo: widget.order.orderId)
          .where('appointmentStatus', isEqualTo: "closed")
          .get();

      if (querySnapshot.docs.length > 0) {
        var list = List<AppAppointments>.from(
          querySnapshot.docs.map(
            (snapshot) => AppAppointments.fromMap(snapshot.data() as Map),
          ),
        );

        setState(() {
          remainingNum =
              (widget.order.packageCallNum - querySnapshot.docs.length) > 0
                  ? (widget.order.packageCallNum - querySnapshot.docs.length)
                      .toString()
                  : "0";
          appointmentList = list;
          answerNum = querySnapshotClosed.docs.length.toString();
          status =
              querySnapshotClosed.docs.length >= widget.order.packageCallNum
                  ? "closed"
                  : querySnapshot.docs.length >= widget.order.packageCallNum
                      ? "completed"
                      : "open";
          loadAppointments = false;
        });
      } else {
        setState(() {
          appointmentList = [];
          remainingNum = widget.order.packageCallNum.toString();
          answerNum = "0";
          status = "open";
          loadAppointments = false;
        });
      }
      await FirebaseFirestore.instance
          .collection(Paths.ordersPath)
          .doc(widget.order.orderId)
          .update({
        'answeredCallNum': querySnapshotClosed.docs.length,
        'remainingCallNum': int.parse(remainingNum),
        'orderStatus': status,
      });
    } catch (e) {}
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
      'phone': "support",
      'screen': "orderDetailsScreen",
      'function': function,
    });
  }

  showReview(Size size, String appointmentId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Paths.consultReviewsPath)
        .where('appointmentId', isEqualTo: appointmentId)
        .get();
    if (querySnapshot.docs.length > 0) {
      setState(() {
        review = List<ConsultReview>.from(
          querySnapshot.docs.map(
            (snapshot) => ConsultReview.fromMap(snapshot.data() as Map),
          ),
        )[0];
        loadReview = false;
      });
    } else
      setState(() {
        review = null;
        loadReview = false;
      });

    return showDialog(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(
            left: AppPadding.p16,
            right: AppPadding.p16,
            top: 20.0,
            bottom: 10.0),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              getTranslated(context, "Reviews"),
              style: TextStyle(
                fontFamily: getTranslated(context, "Ithra"),
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
                color: AppColors.black1,
              ),
            ),
            (loadReview == true)
                ? Center(child: CircularProgressIndicator())
                : (loadReview == false && review != null)
                    ? Container(
                        //height: 90,width: size.width,
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: AppPadding.p10),
                        color: theme == "light"
                            ? AppColors.white
                            : AppColors.pureBlack,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.pureBlack, width: 2),
                                shape: BoxShape.circle,
                                color: theme == "light"
                                    ? AppColors.white
                                    : AppColors.pureBlack,
                              ),
                              child: review!.image!.isEmpty
                                  ? Icon(
                                      Icons.person,
                                      color: AppColors.pureBlack,
                                      size: 45.0,
                                    )
                                  : ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      child: FadeInImage.assetNetwork(
                                        placeholder:
                                            'assets/icons/icon_person.png',
                                        placeholderScale: 0.5,
                                        imageErrorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                          Icons.person,
                                          color: AppColors.pureBlack,
                                          size: 45.0,
                                        ),
                                        image: review!.image!,
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
                            Padding(
                              padding: const EdgeInsets.only(left: 2, right: 2),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review!.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 13,
                                        color: Colors.orange,
                                      ),
                                      Text(
                                        review!.rating.toStringAsFixed(1),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily:
                                              getTranslated(context, "Ithra"),
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    review!.review!,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.normal,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ))
                    : Center(
                        child: Text(
                          getTranslated(context, "noReviews"),
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            color: AppColors.black1,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
            SizedBox(
              height: 15.0,
            ),
            Center(
              child: Container(
                width: size.width * .5,
                child: MaterialButton(
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  padding: const EdgeInsets.all(0.0),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    getTranslated(context, 'Ok'),
                    style: TextStyle(
                      fontFamily: getTranslated(context, 'Ithra'),
                      color: AppColors.black1,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }
}
