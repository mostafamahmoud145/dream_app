import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/consultReview.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/TextButton.dart';
import 'package:grocery_store/widget/dreamDialogsWidget.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import 'package:uuid/uuid.dart';

import '../config/assets_manager.dart';
import '../widget/back_button.dart';

class AddReviewScreen extends StatefulWidget {
  final String consultId;
  final String userId;
  final String appointmentId;

  const AddReviewScreen(
      {Key? key,
      required this.consultId,
      required this.userId,
      required this.appointmentId})
      : super(key: key);

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final TextEditingController controller = TextEditingController();
  bool load = true, adding = false;
  late GroceryUser consult, user;
  dynamic rating = 0.0, consultRating = 0.0;
  String name = "....", image = "";

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getConsultDetails();
  }

  Future<void> getConsultDetails() async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(widget.consultId);
    final DocumentSnapshot documentSnapshot = await docRef.get();

    DocumentReference docRef2 = FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(widget.userId);
    final DocumentSnapshot documentSnapshot2 = await docRef2.get();
    setState(() {
      consult = GroceryUser.fromMap(documentSnapshot.data() as Map);
      name = consult.name!;
      image = consult.photoUrl!;
      consultRating = (consult.rating == null) ? 0.0 : consult.rating;
      user = GroceryUser.fromMap(documentSnapshot2.data() as Map);
      load = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                  width: size.width,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomBackButton(),

                        // IconButton1(
                        //   radius: AppRadius.r9_3.r,
                        //   color: AppColors.white,
                        //   shadowcolor: AppColors.warmPurple,
                        //   iconsize: AppSize.w32.w,
                        //   icon: AssetsManager.purple_right_arrowPath,
                        //   iconcolor: AppColors.pink,
                        //   onPress: () {
                        //     Navigator.pop(context);
                        //   },
                        //   width: AppSize.w50_6.w,
                        //   height: AppSize.h50_6.h,
                        // ),
                        SizedBox(
                          width: AppSize.w21_3.w,
                        ),
                        Text(
                          getTranslated(
                            context,
                            "addRate",
                          ),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithra'),
                            fontSize: AppFontsSizeManager.s21_3.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  )),
              Padding(
                padding: EdgeInsets.only(top: AppPadding.p16.h),
                child: Center(
                    child: Container(
                        color: AppColors.lightGrey,
                        height: AppSize.h2.h,
                        width: double.infinity)),
              ),
              Padding(
                padding: EdgeInsets.only(top: AppPadding.p32.h),
                child: load
                    ? CircularProgressIndicator()
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: AppSize.h10.h,
                            ),
                            (consult.photoUrl == "" || consult.photoUrl == null)
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        height: AppSize.h137_3.h,
                                        width: AppSize.w137_3.w,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppColors.lightGrey,
                                              width: AppSize.w3.w),
                                          shape: BoxShape.circle,
                                          color: AppColors.white,
                                        ),
                                        child: Container(
                                          height: AppSize.h148.h,
                                          width: AppSize.w148.w,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: AppColors.white,
                                                width: AppSize.w10.w),
                                            shape: BoxShape.circle,
                                            color: AppColors.white,
                                          ),
                                          child: consult.photoUrl!.isEmpty
                                              ? Image.asset(
                                                  AssetsManager
                                                      .dreamLogoPurpleImagePath,
                                                  width: AppSize.w148.w,
                                                  height: AppSize.h148.h,
                                                  fit: BoxFit.fill,
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                  child:
                                                      FadeInImage.assetNetwork(
                                                    placeholder: AssetsManager
                                                        .purple_logo,
                                                    placeholderScale: 0.5,
                                                    imageErrorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Image.asset(
                                                            AssetsManager
                                                                .dreamLogoPurpleImagePath,
                                                            width:
                                                                AppSize.w148.w,
                                                            height:
                                                                AppSize.h148.h,
                                                            fit: BoxFit.fill),
                                                    image: consult.photoUrl!,
                                                    fit: BoxFit.cover,
                                                    fadeInDuration: Duration(
                                                        milliseconds: 250),
                                                    fadeInCurve:
                                                        Curves.easeInOut,
                                                    fadeOutDuration: Duration(
                                                        milliseconds: 150),
                                                    fadeOutCurve:
                                                        Curves.easeInOut,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      Image.asset(
                                        AssetsManager.borderConsult,
                                        width: AppSize.w148.w,
                                        height: AppSize.h148.h,
                                      )
                                    ],
                                  )

                                // Image.asset(
                                //     AssetsManager.dreamLogoPurpleImagePath,
                                //     width: AppSize.w148.w,
                                //     height: AppSize.h148.h,
                                //     fit: BoxFit.fill)
                                : Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        height: AppSize.h148.h,
                                        width: AppSize.w148.w,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppColors.grey, width: 1),
                                          shape: BoxShape.circle,
                                          color: AppColors.white,
                                        ),
                                        child: Container(
                                          height: AppSize.h148.h,
                                          width: AppSize.w148.w,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: AppColors.white,
                                                width: 5),
                                            shape: BoxShape.circle,
                                            color: AppColors.white,
                                          ),
                                          child: consult.photoUrl!.isEmpty
                                              ? Image.asset(
                                                  AssetsManager
                                                      .dreamLogoPurpleImagePath,
                                                  width: AppSize.w148.w,
                                                  height: AppSize.h148.h,
                                                  fit: BoxFit.fill,
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                  child:
                                                      FadeInImage.assetNetwork(
                                                    placeholder: AssetsManager
                                                        .purple_logo,
                                                    placeholderScale: 0.5,
                                                    imageErrorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Image.asset(
                                                            AssetsManager
                                                                .dreamLogoPurpleImagePath,
                                                            width:
                                                                AppSize.w148.w,
                                                            height:
                                                                AppSize.h148.h,
                                                            fit: BoxFit.fill),
                                                    image: consult.photoUrl!,
                                                    fit: BoxFit.cover,
                                                    fadeInDuration: Duration(
                                                        milliseconds: 250),
                                                    fadeInCurve:
                                                        Curves.easeInOut,
                                                    fadeOutDuration: Duration(
                                                        milliseconds: 150),
                                                    fadeOutCurve:
                                                        Curves.easeInOut,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      Image.asset(
                                        AssetsManager.dashBoarderImagePath,
                                        width: AppSize.w160.w,
                                        height: AppSize.h160.h,
                                      )
                                    ],
                                  ),
                            SizedBox(
                              height: AppSize.h16.h,
                            ),
                            Center(
                              child: Text(
                                consult.name!,
                                style: TextStyle(
                                  fontFamily: getTranslated(context, 'Ithra'),
                                  color: AppColors.black,
                                  fontSize: AppFontsSizeManager.s21_3.sp,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h10_6.h,
                            ),
                            SmoothStarRating(
                              allowHalfRating: true,
                              starCount: 5,
                              onRatingChanged: (v) {},
                              rating: double.parse(consult.rating.toString()),
                              size: AppSize.h21_3.r,
                              color: AppColors.yellow,
                              borderColor: AppColors.yellow,
                              spacing: AppSize.w5_3.w,
                            ),
                            SizedBox(
                              height: AppSize.h42_6.h,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: AppPadding.p32.w),
                              child: Row(
                                children: [
                                  Text(getTranslated(context, "rateConsult"),
                                      style: TextStyle(
                                        fontFamily:
                                            getTranslated(context, 'Ithra'),
                                        fontSize: AppFontsSizeManager.s21_3.sp,
                                      )),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h29_3.h,
                            ),
                            Center(
                              child: SmoothStarRating(
                                allowHalfRating: true,
                                onRatingChanged: (v) {
                                  setState(() {
                                    rating = v;
                                  });
                                },
                                starCount: 5,
                                rating: rating,
                                size: AppSize.h32.h,
                                color: AppColors.yellow,
                                borderColor: AppColors.yellow,
                                spacing: AppSize.w5_3.w,
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h26_6.h,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: AppPadding.p32.w),
                              child: TextFormField(
                                textAlignVertical: TextAlignVertical.center,
                                maxLines: 6,
                                controller: controller,
                                //enableInteractiveSelection: true,
                                style: TextStyle(
                                  color: AppColors.pureBlack,
                                  fontSize: AppFontsSizeManager.s18_6.sp,
                                  fontFamily:
                                      getTranslated(context, "Ithralight"),
                                  letterSpacing: 0.5,
                                ),

                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                  focusedBorder: new OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: AppSize.w1.w,
                                        color: AppColors.grey),
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.r10_6.r),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: AppColors.grey),
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.r10_6.r),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.white,
                                  enabledBorder: new OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: AppSize.w1.w,
                                        color: AppColors.lightGray),
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.r10_6.r),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: AppPadding.p21_3.w,
                                      vertical: AppPadding.p16.h),
                                  helperStyle: GoogleFonts.poppins(
                                    color:
                                        AppColors.pureBlack.withOpacity(0.65),
                                    letterSpacing: 0.5,
                                  ),
                                  errorStyle: GoogleFonts.poppins(
                                    fontSize: AppFontsSizeManager.s18_6.sp,
                                  ),
                                  hintStyle: TextStyle(
                                    color: AppColors.grey,
                                    fontSize: AppFontsSizeManager.s18_6.sp,
                                    fontFamily:
                                        getTranslated(context, "Ithralight"),
                                  ),
                                  hintText:
                                      getTranslated(context, 'writeUrRate'),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h42_6.h,
                            ),
                            Center(
                              child: adding
                                  ? CircularProgressIndicator()
                                  : Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: AppPadding.p32.w),
                                      child: textButton(
                                        onPress: () {
                                          //rate event
                                          if (rating > 0.0) {
                                            //proceed
                                            addReview();
                                            // showAddingReviewDialog(
                                            //     MediaQuery.of(context).size);
                                          }
                                        },
                                        text: getTranslated(context, "rate"),
                                        width: double.infinity,
                                        height: AppSize.h66_6.h,
                                        buttonRadius: AppRadius.r10_6.r,
                                        textSize: AppFontsSizeManager.s21_3.sp,
                                        textfont:
                                            getTranslated(context, "Ithra"),
                                        textcolor: AppColors.white,
                                        icon: '',
                                        Gradient_Color:
                                            AppColors.Gradient_Color1,
                                        Gradient_Color2:
                                            AppColors.Gradient_Color2,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> addReview() async {
    setState(() {
      adding = true;
    });
    String reviewId = Uuid().v4();
    try {
      await FirebaseFirestore.instance
          .collection(Paths.consultReviewsPath)
          .doc(reviewId)
          .set({
        'rating': double.parse((rating.toString())),
        'review': controller.text,
        'uid': user.uid,
        'name': user.name,
        'image': user.photoUrl,
        'consultUid': consult.uid,
        'appointmentId': widget.appointmentId,
        'reviewTime': Timestamp.now(),
        'consultName': consult.name,
        'consultImage': consult.photoUrl,
      });
      //update user review
      List<ConsultReview> reviews;
      try {
        QuerySnapshot snap = await FirebaseFirestore.instance
            .collection(Paths.consultReviewsPath)
            .where('consultUid', isEqualTo: consult.uid)
            .get();

        reviews = List<ConsultReview>.from(
          (snap.docs).map(
            (e) => ConsultReview.fromMap(e.data() as Map),
          ),
        );
        double _rating = 0;
        if (reviews.length > 0) {
          for (var review in reviews) {
            _rating = _rating + double.parse(review.rating.toString());
          }
          _rating = _rating / reviews.length;
          _rating = double.parse((_rating.toStringAsFixed(1)));
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(consult.uid)
              .set({
            'rating': _rating,
            'reviewsCount': reviews.length,
          }, SetOptions(merge: true));
        }
        setState(() {
          adding = false;
        });
        showAddingReviewDialog(MediaQuery.of(context).size);
      } catch (e) {
        return null;
      }
      return true;
    } catch (e) {}
  }

  showAddingReviewDialog(Size size) {
    String lang = getTranslated(context, "lang");
    return showDialog(
      builder: (context) => DreamDialogsWidget(
        padBottom: 0,
        padLeft: 0,
        padRight: 0,
        padTop: 0,
        dialogContent: Container(
          width: AppSize.w441_3.w,
          // height: AppSize.h282_6.h,
          padding: EdgeInsets.symmetric(
            horizontal: AppPadding.p32.w,
            vertical: AppPadding.p32.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: lang == 'ar'
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                // main
                children: [
                  Image.asset(
                    AssetsManager.black_cancel_iconPath,
                    height: AppSize.w32.w,
                    width: AppSize.w32.w,
                  )
                ],
              ),
              Center(
                child: Image.asset(
                  AssetsManager.baseline_star_iconPath,
                  width: AppSize.w46_6.r,
                  height: AppSize.h44_3.r,
                ),
              ),
              SizedBox(height: AppSize.h13_3.h),
              Column(
                children: [
                  Text(
                    getTranslated(context, "ratingAddedSuccessfully"),
                    style: TextStyle(
                      height: AppSize.h1_5.h,
                      fontFamily: getTranslated(context, 'Ithra'),
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      color: AppColors.black4,
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h42_2.h,
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
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.Gradient_Color1,
                              AppColors.Gradient_Color2,
                            ]),
                        borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                      ),
                      child: Center(
                        child: Text(
                          getTranslated(context, 'continue_rating'),
                          style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithra'),
                            fontSize: AppFontsSizeManager.s18_6.sp,
                            color: AppColors.white,
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
}
