import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/consultReview.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/consultReviewWidget1.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import '../FireStorePagnation/paginate_firestore.dart';
import '../config/assets_manager.dart';
import '../widget/back_button.dart';

class ReviewScreens extends StatefulWidget {
  final GroceryUser consult;
  final GroceryUser? loggedUser;
  final int? reviewLength;
  final bool? avaliable;

  const ReviewScreens(
      {Key? key,
      required this.consult,
      this.reviewLength,
      this.loggedUser,
      this.avaliable})
      : super(key: key);

  @override
  _ReviewScreensState createState() => _ReviewScreensState();
}

class _ReviewScreensState extends State<ReviewScreens> {
  late List<ConsultReview> reviews;
  String lang = "";

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dynamic rating = 0.0;
    rating = (widget.consult.rating == null) ? 0.0 : widget.consult.rating;
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
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
                          getTranslated(context, "Reviews"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              fontSize: AppFontsSizeManager.s21_3.sp,
                              color: AppColors.pureBlack.withOpacity(0.8),
                              fontWeight: AppFontsWeightManager.bold),
                        ),
                      ],
                    ),
                  )),
              Center(
                  child: Container(
                      color: AppColors.grey,
                      height: AppSize.h0_8.h,
                      width: size.width)),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: AppSize.h32.h,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Stack(
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
                                child: widget.consult.photoUrl!.isEmpty
                                    ? Image.asset(
                                        AssetsManager.dreamLogoPurpleImagePath,
                                        width: AppSize.w148.w,
                                        height: AppSize.h148.h,
                                        fit: BoxFit.fill,
                                      )
                                    : ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        child: FadeInImage.assetNetwork(
                                          placeholder:
                                              AssetsManager.purple_logo,
                                          placeholderScale: 0.5,
                                          imageErrorBuilder: (context, error,
                                                  stackTrace) =>
                                              Image.asset(
                                                  AssetsManager
                                                      .dreamLogoPurpleImagePath,
                                                  width: AppSize.w148.w,
                                                  height: AppSize.h148.h,
                                                  fit: BoxFit.fill),
                                          image: widget.consult.photoUrl!,
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
                            // Container(
                            //   height: AppSize.h104.h,
                            //   width: AppSize.w104.w,
                            //   decoration: BoxDecoration(
                            //     border: Border.all(
                            //         color: AppColors.white5, width: 1),
                            //     shape: BoxShape.circle,
                            //     color: AppColors.white,
                            //   ),
                            //   child: Container(
                            //     decoration: BoxDecoration(
                            //       border: Border.all(
                            //           color: AppColors.white,
                            //           width: AppSize.w6_5.w),
                            //       shape: BoxShape.circle,
                            //       color: AppColors.white,
                            //     ),
                            //     child: widget.consult.photoUrl!.isEmpty
                            //         ? Image.asset(
                            //             AssetsManager.dreamLogoPurpleImagePath,
                            //             width: AppSize.w90_5.r,
                            //             height: AppSize.h90_5.r,
                            //             fit: BoxFit.fill,
                            //           )
                            //         : ClipRRect(
                            //             borderRadius:
                            //                 BorderRadius.circular(100.0),
                            //             child: FadeInImage.assetNetwork(
                            //               placeholder:
                            //                   AssetsManager.purple_logo,
                            //               placeholderScale: 0.5,
                            //               imageErrorBuilder: (context, error,
                            //                       stackTrace) =>
                            //                   Image.asset(
                            //                       AssetsManager
                            //                           .dreamLogoPurpleImagePath,
                            //                       width: AppSize.w90_5.r,
                            //                       height: AppSize.h90_5.r,
                            //                       fit: BoxFit.fill),
                            //               image: widget.consult.photoUrl!,
                            //               fit: BoxFit.cover,
                            //               fadeInDuration: Duration(
                            //                   milliseconds:
                            //                       AppConstants.milliseconds250),
                            //               fadeInCurve: Curves.easeInOut,
                            //               fadeOutDuration: Duration(
                            //                   milliseconds:
                            //                       AppConstants.milliseconds150),
                            //               fadeOutCurve: Curves.easeInOut,
                            //             ),
                            //           ),
                            //   ),
                            // ),
                            Image.asset(
                              AssetsManager.borderConsult,
                              width: AppSize.w148.w,
                              height: AppSize.h148.h,
                            ),
                            Positioned(
                              bottom: AppSize.h11_5.h,
                              left: AppSize.w26_6.w,
                              child: Container(
                                decoration: BoxDecoration(
                                  // border: Border.all(color: AppColors.white,width: 2),
                                  shape: BoxShape.circle,
                                  color: widget.avaliable == true
                                      ? AppColors.green2
                                      : AppColors.red,
                                ),
                                width: AppSize.w10_6.w,
                                height: AppSize.h10_6.h,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSize.h16.h),
                      ],
                    ),
                    Center(
                      child: Text(
                        widget.consult.name!,
                        style: TextStyle(
                          fontFamily: getTranslated(context, 'Ithra'),
                          color: AppColors.pureBlack,
                          fontSize: AppFontsSizeManager.s21_3.sp,
                          //fontWeight: AppFontsWeightManager.regular,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: AppSize.h10_6.h,
                    ),
                    widget.consult.userType == AppConstants.consultant
                        ? SmoothStarRating(
                            allowHalfRating: true,
                            starCount: 5,
                            onRatingChanged: (v) {},
                            rating: double.parse(rating.toString()),
                            size: AppSize.w21_3.w,
                            color: AppColors.yellow3,
                            borderColor: AppColors.yellow3,
                            spacing: AppSize.w5_3.w,
                          )
                        : SizedBox(),
                  ],
                ),
              ),
              widget.reviewLength != 0
                  ? Expanded(
                      child: PaginateFirestore(
                        itemBuilderType: PaginateBuilderType.listView,
                        padding: EdgeInsets.only(
                            left: AppPadding.p32.w,
                            right: AppPadding.p32.w,
                            top: AppPadding.p32.h),
                        //Change types accordingly
                        itemBuilder: (context, documentSnapshot, index) {
                          return ConsultReviewWidget1(
                            id: documentSnapshot[index].id,
                            loggedUser: widget.loggedUser,
                            review: ConsultReview.fromMap(
                                documentSnapshot[index].data() as Map),
                          );
                        },
                        separator: SizedBox(
                          height: 0,
                        ),
                        query:
                            widget.consult.userType == AppConstants.consultant
                                ? FirebaseFirestore.instance
                                    .collection('ConsultReview')
                                    .where('consultUid',
                                        isEqualTo: widget.consult.uid)
                                    .orderBy("reviewTime", descending: true)
                                : FirebaseFirestore.instance
                                    .collection('ConsultReview')
                                    .where('uid', isEqualTo: widget.consult.uid)
                                    .orderBy("reviewTime", descending: true),
                        // to fetch real-time data
                        isLive: true,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSize.w8),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: AppSize.h15,
                            ),
                            Text(
                              getTranslated(context, "noReviews"),
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.lightGrey7,
                                fontSize: AppFontsSizeManager.s20.sp,
                                fontWeight: AppFontsWeightManager.regular,
                                letterSpacing: 0.3,
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
}
