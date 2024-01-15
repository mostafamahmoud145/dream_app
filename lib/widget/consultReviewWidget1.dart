import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/consultReview.dart';
import 'package:grocery_store/models/user.dart';
import 'package:readmore/readmore.dart';

class ConsultReviewWidget1 extends StatefulWidget {
  final ConsultReview review;
  final GroceryUser? loggedUser;
  final String id;
  ConsultReviewWidget1({
    required this.review,
    required this.id,
    this.loggedUser,
  });

  @override
  State<ConsultReviewWidget1> createState() => _ConsultReviewWidget1State();
}

class _ConsultReviewWidget1State extends State<ConsultReviewWidget1> {
  bool delete = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
        color: Colors.transparent,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: AppSize.h69_3.r,
                  width: AppSize.w69_3.r,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey5,
                    //border: Border.all(color: AppColors.pink, width: 1),
                    shape: BoxShape.circle,
                  ),
                  child: widget.review.image!.isEmpty
                      ? Icon(
                          Icons.person,
                          color: AppColors.white,
                          size: AppSize.w45.w,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.r100.r),
                          child: FadeInImage.assetNetwork(
                            placeholder: AssetsManager.icon_personPath,
                            placeholderScale: 0.5,
                            imageErrorBuilder: (context, error, stackTrace) =>
                                Icon(
                              Icons.person,
                              color: AppColors.grey,
                              size: AppSize.w45.w,
                            ),
                            image: widget.review.image!,
                            fit: BoxFit.cover,
                            fadeInDuration: Duration(
                                milliseconds: AppConstants.milliseconds250),
                            fadeInCurve: Curves.easeInOut,
                            fadeOutDuration: Duration(
                                milliseconds: AppConstants.milliseconds150),
                            fadeOutCurve: Curves.easeInOut,
                          ),
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppPadding.p10_6.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.review.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: getTranslated(context, 'Ithra'),
                                color: AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s21_3.sp,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                (widget.loggedUser != null &&
                                        widget.loggedUser!.userType ==
                                            "SUPPORT")
                                    ? InkWell(
                                        onTap: () {
                                          deleteDialog(size);
                                        },
                                        child: Icon(
                                          Icons.delete_forever_outlined,
                                          size: AppSize.w18_6,
                                          color: AppColors.red,
                                        ),
                                      )
                                    : SizedBox(
                                        width: 0,
                                      ),
                                Text(
                                  widget.review.rating.toStringAsFixed(1),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: getTranslated(
                                        context, 'Montserrat-Medium'),
                                    color: AppColors.black,
                                    fontSize: AppFontsSizeManager.s16.sp,
                                    fontWeight: AppFontsWeightManager.bold600,
                                    // fontStyle: FontStyle.normal,
                                  ),
                                ),
                                SizedBox(
                                  width: AppSize.w8.w,
                                ),
                                Image.asset(
                                  AssetsManager.star3,

                                  // Icons.star,
                                  width: AppSize.w18_6.r,
                                  height: AppSize.h18_6.r,
                                  //color: AppColors.yellow3,
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: AppSize.h5_3.h,
                        ),
                        Container(
                          child: ReadMoreText(
                            // "dklgjskdfgklashfvjklsdgchjadcfkghadJ;LFGAIYUFGOV[ALEHFGVYUPA'SKFLKVHAOPDKVMNBDCHKLN DSBJCVJIJAPOF;SKVOAKFG]",
                            widget.review.review!,
                            trimLines: 2,
                            textAlign: TextAlign.start,
                            colorClickableText: AppColors.grey,
                            trimMode: TrimMode.Line,
                            trimCollapsedText:
                                getTranslated(context, "pressForMore"),
                            trimExpandedText:
                                getTranslated(context, "pressForLess"),
                            moreStyle: TextStyle(
                              fontFamily: getTranslated(context, 'Ithralight'),
                              color: AppColors.linear2,
                              fontSize: AppFontsSizeManager.s16.sp,
                              fontWeight: FontWeight.normal,
                              letterSpacing: AppConstants.letterSpacing,
                            ),
                            lessStyle: TextStyle(
                              fontFamily: getTranslated(context, 'Ithralight'),
                              color: AppColors.linear2,
                              fontSize: AppFontsSizeManager.s16.sp,
                              fontWeight: FontWeight.normal,
                              letterSpacing: AppConstants.letterSpacing,
                            ),
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithralight'),
                              color: AppColors.darkGrey3,
                              fontSize: AppFontsSizeManager.s16.sp,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppPadding.p32.h),
              child: Center(
                  child: Container(
                      color: AppColors.lightGrey,
                      height: AppSize.h2.h,
                      width: double.infinity)),
            )
          ],
        ));
  }

  deleteDialog(Size size) {
    return showDialog(
      builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppRadius.r20),
            ),
          ),
          elevation: 5.0,
          contentPadding: const EdgeInsets.only(
              left: AppPadding.p16,
              right: AppPadding.p16,
              top: AppPadding.p20,
              bottom: AppPadding.p10),
          content: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getTranslated(context, "deleteReview"),
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithra'),
                        fontSize: AppFontsSizeManager.s14_5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        color: AppColors.black1,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: AppPadding.p20,
                      right: AppPadding.p20,
                      top: AppPadding.p10,
                      bottom: AppPadding.p10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          delete = true;
                          await FirebaseFirestore.instance
                              .collection(Paths.consultReviewsPath)
                              .doc(widget.id)
                              .delete();
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              getTranslated(context, "yes"),
                              style: TextStyle(
                                fontFamily: getTranslated(context, 'Ithra'),
                                fontSize: AppFontsSizeManager.s13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                color: Colors.lightBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppSize.w100),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              getTranslated(context, "no"),
                              style: TextStyle(
                                fontFamily: getTranslated(context, 'Ithra'),
                                fontSize: AppFontsSizeManager.s13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                color: Colors.lightBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 5,
                      right: AppPadding.p5,
                      top: AppPadding.p5,
                      bottom: AppPadding.p10),
                  child: Container(
                    width: size.width,
                    height: AppSize.h5,
                    color: AppColors.lightGrey1,
                  ),
                ),
              ],
            );
          })),
      barrierDismissible: false,
      context: context,
    );
  }
}
