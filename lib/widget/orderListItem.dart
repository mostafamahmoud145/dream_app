import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/order.dart';
import 'package:grocery_store/screens/orderDetailsScreen.dart';
import 'package:intl/intl.dart';
import 'package:timelines/timelines.dart';

class OrderListItem extends StatelessWidget {
  final Orders? order;
  final String? type;
  final bool? fromSupport;
  String lang = "";
  OrderListItem({this.order, this.type, this.fromSupport});
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    DateFormat dateFormat = DateFormat('d / MM / yyyy');
    lang = getTranslated(context, "lang");
    return Padding(
      padding: EdgeInsets.only(right: AppPadding.p32.w, left: AppPadding.p32.w),
      child: Column(
        children: [
          // SizedBox(
          //   height: AppSize.h18_6.h,
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset(
                AssetsManager.calendar_clock_iconPath,
                width: AppSize.w21_3.w,
                height: AppSize.h21_3.h,
              ),
              SizedBox(
                width: AppSize.w10_6.w,
              ),
              Text(
                '${dateFormat.format(order!.orderTimestamp.toDate())}',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: getTranslated(context, 'Ithralight'),
                  color: AppColors.grey,
                  fontSize: AppFontsSizeManager.s18_6.sp,
                  //   fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              //SizedBox(width: 40,),
            ],
          ),
          SizedBox(
            height: AppSize.h21_3.h,
          ),
          Container(
            width: double.infinity,
            // padding: const EdgeInsets.all(AppPadding.p10),
            decoration: BoxDecoration(
                //   color: AppColors.red,
                //borderRadius: BorderRadius.circular(AppRadius.r20),
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //////
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        //"mohamed",
                        type != AppConstants.user
                            ? order!.user.name
                            : order!.consult.name,
                        // textAlign: TextAlign.start,
                        // overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: getTranslated(context, 'Ithra'),
                          color: AppColors.pink,
                          fontSize: AppFontsSizeManager.s21_3.sp,
                          fontWeight: FontWeight.w600,
                          // letterSpacing: 0.3,
                        )),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetails(
                              order: order!,
                              type: type,
                              fromSupport: fromSupport,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                              getTranslated(
                                context,
                                "Details",
                              ),
                              style: TextStyle(
                                  fontSize: AppFontsSizeManager.s16.sp,
                                  fontFamily:
                                      getTranslated(context, 'Ithralight'),
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: AppFontsWeightManager.bold600)),
                          SizedBox(
                            width: AppSize.w10_6.w,
                          ),
                          SvgPicture.asset(
                            AssetsManager.arrowLeftCricle2,
                            height: AppSize.h21_3.h,
                            width: AppSize.w21_3.w,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: AppSize.h21_3.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            DotIndicator(
                              color: AppColors.pink,
                              size: AppSize.w21_3.w,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: AppSize.w10_6.w,
                        ),
                        Text(
                          getTranslated(context, "NumberOfPackageCalls"),
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithralight'),
                            color: AppColors.pureBlack,
                            fontSize: AppFontsSizeManager.s21_3.sp,
                            //fontWeight: FontWeight.w600,
                          ),
                        ),
                        //    SizedBox(width: size.width * 0.4,),
                      ],
                    ),
                    Row(
                      children: [
                        Text(order!.packageCallNum.toString(),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithralight'),
                              color: AppColors.linear2,
                              fontSize: AppFontsSizeManager.s21_3.sp,
                              fontWeight: AppFontsWeightManager.bold600,
                              letterSpacing: 0.3,
                            )),
                        SizedBox(
                          width: AppSize.w18_6.w,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: AppSize.h2_6.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: AppSize.h26_6.h,
                      width: AppSize.w18_6.w,
                      child: SolidLineConnector(
                        color: AppColors.lightGrey,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: AppSize.h2_6.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          AssetsManager.done2,
                          height: AppSize.w21_3.w,
                          width: AppSize.h21_3.w,
                        ),
                        SizedBox(
                          width: AppSize.w10,
                        ),
                        Text(
                          getTranslated(context, "answeredCall"),
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithralight'),
                            color: AppColors.pureBlack,
                            fontSize: AppFontsSizeManager.s21_3.sp,
                            //fontWeight: FontWeight.w600,
                          ),
                        ),
                        // SizedBox(width: size.width * 0.4,),
                      ],
                    ),
                    Row(
                      children: [
                        Text(order!.answeredCallNum.toString(),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              color: AppColors.linear2,
                              fontSize: AppFontsSizeManager.s21_3.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            )),
                        SizedBox(
                          width: AppSize.w18_6.w,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: AppSize.h2_6.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: AppSize.h26_6.h,
                      width: AppSize.w18_6.w,
                      child: SolidLineConnector(
                        color: AppColors.lightGrey,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: AppSize.h2_6.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        DotIndicator(
                          color: AppColors.darkRed,
                          size: AppSize.w21_3.r,
                        ),
                        SizedBox(
                          width: AppSize.w10_6.w,
                        ),
                        Text(
                          getTranslated(context, "remainingCall"),
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithralight'),
                            color: AppColors.pureBlack,
                            fontSize: AppFontsSizeManager.s21_3.sp,
                            // fontWeight: FontWeight.w600,
                          ),
                        ),
                        //  SizedBox(width: size.width * 0.4,),
                      ],
                    ),
                    Row(
                      children: [
                        Text(order!.remainingCallNum.toString(),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              color: AppColors.linear2,
                              fontSize: AppFontsSizeManager.s21_3.sp,
                              //fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            )),
                        SizedBox(
                          width: AppSize.w18_6.w,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: AppSize.h26_6.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          getTranslated(context, "callprice"),
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithralight'),
                            color: AppColors.pink,
                            fontSize: AppFontsSizeManager.s21_3.sp,
                            // fontWeight: FontWeight.w600,
                          ),
                        ),

                        //  SizedBox(width: size.width * 0.4,),
                      ],
                    ),
                    Container(
                      width: AppSize.w112.w,
                      height: AppSize.h42_6.h,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border.all(
                          width: AppSize.w1.w,
                          color: AppColors.linear2,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.r5_3.r),
                      ),
                      child: Center(
                        child: Text(
                            (order!.callPrice * order!.packageCallNum)
                                    .toString() +
                                "\$",
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              color: AppColors.pink,
                              fontSize: AppFontsSizeManager.s21_3.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppPadding.p46_6.w),
            child: Center(
                child: Container(
                    color: AppColors.lightGrey,
                    height: AppSize.h1.h,
                    width: double.infinity)),
          ),
        ],
      ),
    );
  }
}
