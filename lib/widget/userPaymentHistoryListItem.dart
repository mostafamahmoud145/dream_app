import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/userPaymentHistory.dart';
import 'package:intl/intl.dart';

import '../config/app_values.dart';
import '../config/colorsFile.dart';

class UserPaymentHistoryListItem extends StatelessWidget {
  final UserPaymentHistory history;

  UserPaymentHistoryListItem({required this.history});

  @override
  Widget build(BuildContext context) {
    String lang = getTranslated(context, "lang");
    Size size = MediaQuery.of(context).size;
    String languages = "";
    return Stack(children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: AppSize.h32.h,
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.r10_6),
              boxShadow: [AppShadow.primaryShadow],
            ),
            child: Padding(
              padding: lang == 'ar'
                  ? EdgeInsets.only(
                      left: AppPadding.p21_3.w, right: AppPadding.p10_6.w)
                  : EdgeInsets.only(
                      right: AppPadding.p21_3.w, left: AppPadding.p10_6.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // SizedBox(
                  //   height: AppSize.h10.h,
                  // ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: AppPadding.p23_3.h, right: AppPadding.p10_6.w),
                    child: Row(
                      mainAxisAlignment: lang == "ar"
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      children: [
                        Text(
                          // DateTime.fromMillisecondsSinceEpoch(
                          //
                          //         history.payDateValue).toString(),
                          '${new DateFormat('hh:mm' + 'a ').format((history.payDate.toDate()))}',
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithralight'),
                            color: Theme.of(context).primaryColor,
                            fontSize: AppFontsSizeManager.s16.sp,
                            // fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(width: AppSize.w6.w),
                        SvgPicture.asset(
                          AssetsManager.dateApp,
                          width: AppSize.w16.w,
                        ),
                        SizedBox(width: AppSize.w10_6.w),
                        Text(
                          // DateTime.fromMillisecondsSinceEpoch(
                          //
                          //         history.payDateValue).toString(),
                          '${new DateFormat('dd MMM ').format((history.payDate.toDate()))}',
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithralight'),
                            color: Theme.of(context).primaryColor,
                            fontSize: AppFontsSizeManager.s16.sp,
                            // fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(width: AppSize.w6.w),
                        SvgPicture.asset(
                          AssetsManager.calendarApp33,
                          width: AppSize.w16.w,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h16.h,
                  ),
                  Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: AppSize.w60.w,
                            height: AppSize.h60.h,
                            decoration: BoxDecoration(
                              color: AppColors.BackGroundLightPink,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r50.r),
                            ),
                          ),
                          Center(
                            child: Image.asset(
                              AssetsManager.dreamLogoPurpleImagePath,
                              width: AppSize.w24_8.w,
                              height: AppSize.h25_8.h,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: AppSize.w18_6.w,
                      ),
                      Text(
                        history.otherData!.name,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily:
                              getTranslated(context, 'Montserrat-Medium'),
                          color: AppColors.pureBlack,
                          fontSize: AppFontsSizeManager.s21_3.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Text(
                            "\$",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              color: Theme.of(context).primaryColor,
                              fontSize: AppFontsSizeManager.s21_3.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            double.parse(history.amount.toString())
                                .toStringAsFixed(3),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily:
                                  getTranslated(context, 'Montserrat-SemiBold'),
                              color: Theme.of(context).primaryColor,
                              fontSize: AppFontsSizeManager.s21_3.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  //pb
                  //d
                  Center(
                    child: Container(
                      height: AppSize.h40.h,
                      width: AppSize.w133_3.w,
                      decoration: BoxDecoration(
                        color: history.payType != "send"
                            ? AppColors.BackGroundLightPink2
                            : AppColors.red,
                        borderRadius: BorderRadius.circular(AppRadius.r5_3.r),
                      ),
                      child: Center(
                        child: Text(
                          history.payType == "send"
                              ? getTranslated(context, "send")
                              : history.payType == "retrieved"
                                  ? getTranslated(context, "retrieved")
                                  : getTranslated(context, "retrieved"),
                          style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithra'),
                            color: AppColors.green3,
                            fontSize: AppFontsSizeManager.s18_6.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h20.h,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ]);
  }
}
