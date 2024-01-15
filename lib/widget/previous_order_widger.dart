import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/dialogs/costum_text_dialog.dart';

import '../config/app_fonts.dart';
import '../methods/convert_pt_to_px.dart';
import '../models/order.dart';
import 'consaultant_details_widgets/add_appointment_for_previous_order_dialog.dart';

class PreviousOrderWidget extends StatefulWidget {
  final GroceryUser loggedUser;
  final Orders? order;

  PreviousOrderWidget({required this.loggedUser, this.order});

  @override
  State<PreviousOrderWidget> createState() => _PreviousOrderWidgetState();
}

class _PreviousOrderWidgetState extends State<PreviousOrderWidget> {
  GroceryUser? consultant;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: AppPadding.p32.h),
          child: Container(
              padding: EdgeInsets.only(
                top: convertPtToPx(AppSize.h16).h,
              ),
              //height: convertPtToPx(AppSize.h154).h,
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius:
                      BorderRadius.circular(convertPtToPx(AppRadius.r16).r),
                  border: Border.all(color: AppColors.lightGray)
                  // boxShadow: [
                  //   AppShadow.primaryShadow] ,
                  ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ///Consultant name.
                  ///
                  Text(
                    widget.order!.consult.name,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithra'),
                        color: AppColors.black4,
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: convertPtToPx(-0.41)),
                  ),

                  SizedBox(
                    height: convertPtToPx(AppSize.h12).h,
                  ),

                  ///Date and time.
                  ///
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: convertPtToPx(AppSize.w24).w),
                    child: HeaderAndValueLine(
                      header: getTranslated(context, 'nextCall'),
                      value: getTranslated(context, 'callNotDetermined'),
                    ),
                  ),
                  SizedBox(
                    height: convertPtToPx(AppSize.h14).h,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: convertPtToPx(AppSize.w24.w)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        HeaderAndValueLine(
                          header: '${getTranslated(context, "packageCall")} ',
                          value: '${widget.order!.packageCallNum}',
                        ),
                        HeaderAndValueLine(
                          header:
                              '${getTranslated(context, "remainingCalls")} ',
                          value: '${widget.order!.remainingCallNum}',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: convertPtToPx(AppSize.h17).h,
                  ),
                  InkWell(
                    splashColor: Colors.green.withOpacity(0.6),
                    onTap: () async {
                      FirebaseFirestore.instance
                          .collection(Paths.usersPath)
                          .doc(widget.order!.consult.uid)
                          .get()
                          .then((value) {
                        consultant =
                            GroceryUser.fromMap(value.data() as Map);
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AddAppointmentForPreviousOrderDialog(
                              loggedUser: widget.loggedUser,
                              consultant: consultant!,
                              order: widget.order!,
                              localFrom:
                                  DateTime.parse(consultant!.fromUtc!)
                                      .toLocal()
                                      .hour,
                              localTo: DateTime.parse(consultant!.toUtc!)
                                  .toLocal()
                                  .hour,
                              currentNumber:
                                  widget.order!.remainingCallNum > 0
                                      ? (widget.order!.remainingCallNum -
                                          1)
                                      : 0,
                              consultType: widget.order!.consultType,
                            );
                          },
                        );
                      }).catchError((error) {
                        return customTextDialog(
                            context: context,
                            text: getTranslated(context, 'failed'),
                            buttonText: getTranslated(context, 'Ok'),
                            okFunction: () {
                              Navigator.pop(context);
                            });
                      });
                    },
                    child: Container(
                      height: AppSize.h69_3.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColors.backgroundLightPink,
                          border: BorderDirectional(
                            //bottom: BorderSide(color: AppColors.warmPurple, width: AppSize.w1.w),
                            top: BorderSide(
                                color: AppColors.lightGray,
                                width: convertPtToPx(AppSize.w1).w),
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(
                                convertPtToPx(AppRadius.r16.r)),
                            bottomRight: Radius.circular(
                                convertPtToPx(AppRadius.r16.r)),
                          )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AssetsManager.calendar_clock_iconPath,
                            width: AppSize.w21_3.w,
                          ),
                          SizedBox(width: AppSize.w8.w),
                          Text(
                            getTranslated(context, "determineNextCall"),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              color: AppColors.pink,
                              fontSize: AppFontsSizeManager.s18_6.sp,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )),
        ),
      ],
    );
  }
}

class HeaderAndValueLine extends StatelessWidget {
  const HeaderAndValueLine({
    Key? key,
    required this.header,
    required this.value,
  }) : super(key: key);

  final String header, value;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          header + ' : ',
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            fontFamily: getTranslated(context, 'Ithralight'),
            color: AppColors.pink,
            fontSize: convertPtToPx(AppFontsSizeManager.s14).sp,
            fontWeight: FontWeight.normal,
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: getTranslated(context, 'Ithralight'),
              color: AppColors.greyDark,
              fontSize: convertPtToPx(AppFontsSizeManager.s12).sp,
              fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}
