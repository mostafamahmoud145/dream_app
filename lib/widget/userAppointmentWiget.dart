import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/methods/convert_pt_to_px.dart';
import 'package:grocery_store/methods/show_failed_snackbar.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/AppointmentChatScreen.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../config/app_fonts.dart';
import '../config/paths.dart';
import '../methods/check_calling_system_type.dart';
import '../models/order.dart';
import '../services/agora_call_service.dart';
import '../services/call_services.dart';

class UserAppointmentWiget extends StatefulWidget {
  final GroceryUser loggedUser;
  final AppAppointments appointment;

  UserAppointmentWiget({required this.appointment, required this.loggedUser});

  @override
  State<UserAppointmentWiget> createState() => _UserAppointmentWigetState();
}

class _UserAppointmentWigetState extends State<UserAppointmentWiget>
    with SingleTickerProviderStateMixin {
  bool acceptLoad = false, loadingCall = false;
  bool joinMeeting = false;
  Orders? order;
  bool loadOrder = false;

  @override
  void initState() {
    super.initState();
    getNumber();
  }

  @override
  Widget build(BuildContext context) {
    String time;
    DateFormat dateFormat = DateFormat('d/M/yyyy');
    DateTime localDate;

    if (widget.appointment.utcTime != null)
      localDate = DateTime.parse(widget.appointment.utcTime).toLocal();
    else
      localDate = DateTime.parse(
              widget.appointment.appointmentTimestamp.toDate().toString())
          .toLocal();

    if (localDate.hour == 12)
      time = "12 ${getTranslated(context, 'pm')}";
    else if (localDate.hour == 0)
      time = "12 ${getTranslated(context, 'am')}";
    else if (localDate.hour > 12)
      time = (localDate.hour - 12).toString() +
          ":" +
          localDate.minute.toString() +
          "0" +
          " ${getTranslated(context, 'pm')}";
    else
      time = (localDate.hour).toString() +
          ":" +
          localDate.minute.toString() +
          "0" +
          " ${getTranslated(context, 'am')}";
    return widget.appointment.appointmentStatus == 'open'
        ? AcceptedUserAppointmentCart(
            localDate: localDate, dateFormat: dateFormat, time: time)
        : DoneUserAppointmentCart(
            localDate: localDate, dateFormat: dateFormat, time: time);
  }

  Future<void> getNumber() async {
    try {
      setState(() {
        loadOrder = true;
      });
      await FirebaseFirestore.instance
          .collection(Paths.ordersPath)
          .doc(widget.appointment.orderId)
          .get()
          .then((value) async {
        order = Orders.fromMap(value.data() as Map);
        setState(() {
          loadOrder = false;
        });
      }).catchError((err) {
        errorLog("getNumber", err.toString());
        setState(() {
          loadOrder = false;
        });
      });
    } catch (e) {
      errorLog("getNumber", e.toString());
      if (mounted) {
        setState(() {
          loadOrder = false;
          order = null;
        });
      }
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
      'phone': widget.loggedUser == null ? " " : widget.loggedUser!.phoneNumber,
      'screen': "ConsultantDetailsScreen",
      'function': function,
    });
  }

  ///Accepted User Appointment Cart Widget

  Widget AcceptedUserAppointmentCart({
    required DateTime localDate,
    required DateFormat dateFormat,
    required String time,
  }) =>
      Container(
          //height: convertPtToPx(AppSize.h156).h,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius:
                  BorderRadius.circular(convertPtToPx(AppRadius.r16).r),
              border: Border.all(
                  color: AppColors.lightGray,
                  width: convertPtToPx(AppRadius.r1).r)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: convertPtToPx(AppSize.h16).h,
              ),

              ///Consultant name.
              ///
              Text(
                widget.appointment.consult.name != null
                    ? widget.appointment.consult.name
                    : widget.appointment.consult.phone,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                    fontFamily: getTranslated(context, 'Ithra'),
                    color: AppColors.black4,
                    fontSize: convertPtToPx(AppSize.h16).sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: convertPtToPx(-0.41)),
              ),

              SizedBox(
                height: convertPtToPx(AppSize.h12).h,
              ),

              ///Date and time.
              ///
              SizedBox(
                height: convertPtToPx(AppSize.h20).h,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: convertPtToPx(AppSize.w24).w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AssetsManager.calendar_check2Path,
                            width: AppSize.w16.w,
                            color: AppColors.darkGrey,
                          ),
                          SizedBox(width: convertPtToPx(AppSize.w8).w),
                          Text(
                            '${dateFormat.format(localDate)}',
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                fontFamily: getTranslated(
                                    context, 'Montserrat-Regular'),
                                color: AppColors.darkGrey,
                                fontWeight: AppFontsWeightManager.regular,
                                fontStyle: FontStyle.normal,
                                fontSize:
                                    convertPtToPx(AppFontsSizeManager.s12).sp),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            AssetsManager.clockIcon,
                            width: AppSize.w18_6.w,
                            color: AppColors.darkGrey,
                          ),
                          SizedBox(width: convertPtToPx(AppSize.w8).w),
                          Text(
                            time,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                fontFamily:
                                    getTranslated(context, 'Ithralight'),
                                color: AppColors.darkGrey,
                                fontWeight: AppFontsWeightManager.regular,
                                fontStyle: FontStyle.normal,
                                fontSize:
                                    convertPtToPx(AppFontsSizeManager.s12).sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: convertPtToPx(AppSize.h15).h,
              ),

              SizedBox(
                height: convertPtToPx(AppSize.h20).h,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: convertPtToPx(AppSize.w24).w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${getTranslated(context, "packageCall")} : ',
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithralight'),
                              color: AppColors.pink,
                              fontSize:
                                  convertPtToPx(AppFontsSizeManager.s14).sp,
                              fontWeight: AppFontsWeightManager.regular,
                            ),
                          ),
                          Text(
                            '${order?.packageCallNum ?? ''}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily:
                                    getTranslated(context, 'Ithralight'),
                                color: AppColors.darkGrey,
                                fontSize:
                                    convertPtToPx(AppFontsSizeManager.s14).sp,
                                fontWeight: AppFontsWeightManager.regular),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '${getTranslated(context, "remainingCalls")} : ',
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithralight'),
                              color: AppColors.pink,
                              fontSize:
                                  convertPtToPx(AppFontsSizeManager.s14).sp,
                              fontWeight: AppFontsWeightManager.regular,
                            ),
                          ),
                          Text(
                            '${order?.remainingCallNum ?? ''}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily:
                                    getTranslated(context, 'Ithralight'),
                                color: AppColors.darkGrey,
                                fontSize:
                                    convertPtToPx(AppFontsSizeManager.s14).sp,
                                fontWeight: AppFontsWeightManager.regular),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: AppSize.w30_6.w),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Text(
              //         getTranslated(context, "callStatus"),
              //         textAlign: TextAlign.start,
              //         overflow: TextOverflow.ellipsis,
              //         maxLines: 1,
              //         style: TextStyle(
              //           fontFamily: getTranslated(context, 'Ithralight'),
              //           color: AppColors.darkGrey3,
              //           fontSize: AppFontsSizeManager.s18_6.sp,
              //           fontWeight: FontWeight.normal,
              //         ),
              //       ),
              //       Text(
              //         widget.appointment.appointmentStatus == "new"
              //             ? getTranslated(context, "new")
              //             : widget.appointment.appointmentStatus == "open"
              //             ? getTranslated(context, "open")
              //             : widget.appointment.appointmentStatus ==
              //             "closed"
              //             ? getTranslated(context, "closed")
              //             : getTranslated(context, "canceled"),
              //         textAlign: TextAlign.center,
              //         style: TextStyle(
              //             fontFamily: getTranslated(context, 'Ithra'),
              //             color: AppColors.pink,
              //             fontSize: AppFontsSizeManager.s18_6.sp,
              //             fontWeight: FontWeight.bold
              //         ),
              //       )
              //     ],
              //   ),
              // ),

              SizedBox(
                height: convertPtToPx(AppSize.h17).h,
              ),

              // Spacer(),

              (widget.appointment.appointmentStatus == "open")
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        widget.appointment.consultType == "voice"
                            ? Expanded(
                                flex: 1,
                                child: loadingCall
                                    ? Center(child: CircularProgressIndicator())
                                    : InkWell(
                                        splashColor:
                                            Colors.green.withOpacity(0.6),
                                        onTap: () async {
                                          try {
                                            setState(() {
                                              loadingCall = true;
                                            });

                                            /// first, get current calling system from firebase.
                                            /// then, if the current system is agora, then start call via agora.
                                            ///
                                            /// if the current system is jitsi meet, then  start call via jitsi meet.
                                            ///
                                            await checkCallingType(context)
                                                .then((value) async {
                                              if (value == true) {
                                                await AgoraCallService
                                                    .startAgoraCallFromCard(
                                                        context: context,
                                                        loggedUser:
                                                            widget.loggedUser,
                                                        callerId: widget
                                                            .appointment
                                                            .user
                                                            .uid,
                                                        receiverId: widget
                                                            .appointment
                                                            .consult
                                                            .uid,
                                                        appointment:
                                                            widget.appointment);
                                              } else {
                                                await CallServices
                                                    .startJisiCall(
                                                        appointment:
                                                            widget.appointment,
                                                        loggedUser:
                                                            widget.loggedUser,
                                                        receiverId: widget
                                                            .appointment
                                                            .consult
                                                            .uid,
                                                        context: context);
                                              }
                                            });
                                            setState(() {
                                              loadingCall = false;
                                            });
                                          } catch (e) {
                                            setState(() {
                                              loadingCall = false;
                                            });
                                            showFailedSnackBar(getTranslated(
                                                context, 'failed'));
                                          }
                                        },
                                        child: Container(
                                            height:
                                                convertPtToPx(AppSize.h52).h,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color:
                                                  AppColors.backgroundLightPink,
                                              border: BorderDirectional(
                                                top: BorderSide(
                                                    color: AppColors.lightGray,
                                                    width: convertPtToPx(
                                                            AppSize.w1)
                                                        .w),
                                                end: BorderSide(
                                                    color: AppColors.lightGray,
                                                    width: convertPtToPx(
                                                            AppSize.w1)
                                                        .w),
                                              ),
                                              borderRadius:
                                                  BorderRadiusDirectional.only(
                                                bottomStart: Radius.circular(
                                                    convertPtToPx(AppRadius.r16)
                                                        .r),
                                                //bottomEnd: Radius.circular(convertPtToPx(AppRadius.r16).r)
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  AssetsManager
                                                      .call_back_purple_icon_path,
                                                  width: AppSize.w21_3.r,
                                                  height: AppSize.h22_9.h,
                                                  color: AppColors.darkGreen,
                                                ),
                                                SizedBox(
                                                    width: convertPtToPx(
                                                            AppSize.w10)
                                                        .w),
                                                Text(
                                                  getTranslated(
                                                      context, "calling"),
                                                  textAlign: TextAlign.start,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      fontFamily: getTranslated(
                                                          context, 'Ithra'),
                                                      color:
                                                          AppColors.darkGreen,
                                                      fontSize: convertPtToPx(
                                                              AppFontsSizeManager
                                                                  .s14)
                                                          .sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      letterSpacing:
                                                          convertPtToPx(-0.5)),
                                                ),
                                              ],
                                            )),
                                      ))
                            : SizedBox(),
                        Expanded(
                            flex: 1,
                            child: InkWell(
                              splashColor: Colors.green.withOpacity(0.6),
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AppointmentChatScreen(
                                        appointment: widget.appointment,
                                        user: widget.loggedUser),
                                  ),
                                );
                              },
                              child: Container(
                                height: convertPtToPx(AppSize.h52).h,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.BackGroundLightPink,
                                  border: BorderDirectional(
                                    top: BorderSide(
                                        color: AppColors.lightGray,
                                        width: convertPtToPx(AppSize.w1).w),
                                  ),
                                  borderRadius: BorderRadiusDirectional.only(
                                      bottomEnd: Radius.circular(
                                          convertPtToPx(AppRadius.r16).r),
                                      bottomStart: widget
                                                  .appointment.consultType ==
                                              "voice"
                                          ? Radius.circular(0)
                                          : Radius.circular(
                                              convertPtToPx(AppRadius.r16).r)),
                                  // border: Border.all(color: AppColors.lightGray)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Stack(
                                        alignment: Alignment.center,
                                        children: <Widget>[
                                          Image.asset(
                                            AssetsManager.messageIcon,
                                            width:
                                                convertPtToPx(AppSize.w16_2).r,
                                            // height: convertPtToPx(AppSize.w16).r,
                                          ),
                                          SizedBox(
                                            width: convertPtToPx(AppSize.w10).w,
                                          ),
                                          widget.appointment.userChat > 0
                                              ? Positioned(
                                                  left: 0,
                                                  top: 1.0,
                                                  child: Container(
                                                    height: AppSize.h10_6.h,
                                                    width: AppSize.w10_6.w,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: AppColors.yellow2,
                                                    ),
                                                  ),
                                                )
                                              : SizedBox()
                                        ]),
                                    SizedBox(
                                      width: convertPtToPx(AppSize.w10).w,
                                    ),
                                    Text(
                                      getTranslated(context, "message"),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontFamily:
                                              getTranslated(context, 'Ithra'),
                                          color: AppColors.linear3,
                                          fontSize: convertPtToPx(
                                                  AppFontsSizeManager.s14)
                                              .sp,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                          letterSpacing: convertPtToPx(-0.5)),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    )
                  : SizedBox(),

              (widget.appointment.appointmentStatus == "closed")
                  ? Padding(
                      padding: EdgeInsets.only(
                        bottom: AppSize.h10.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            splashColor: Colors.green.withOpacity(0.6),
                            onTap: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AppointmentChatScreen(
                                      appointment: widget.appointment,
                                      user: widget.loggedUser!),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      Image.asset(
                                        AssetsManager.chat2,
                                        width: convertPtToPx(AppSize.w16_2).r,
                                      ),
                                      widget.appointment.userChat > 0
                                          ? Positioned(
                                              left: 0,
                                              top: 1.0,
                                              child: Container(
                                                height: AppSize.h10_6.h,
                                                width: AppSize.w10_6.w,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.yellow2,
                                                ),
                                              ),
                                            )
                                          : SizedBox()
                                    ]),
                                SizedBox(
                                  width: AppSize.w10_6.w,
                                ),
                                Text(
                                  getTranslated(context, "message"),
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, 'Ithra'),
                                    color: AppColors.linear1,
                                    fontSize: AppFontsSizeManager.s18_6.sp,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  : SizedBox(),
            ],
          ));

  ///Done User Appointment Cart Widget
  Widget DoneUserAppointmentCart({
    required DateTime localDate,
    required DateFormat dateFormat,
    required String time,
  }) =>
      Container(
          margin: EdgeInsets.symmetric(horizontal: AppPadding.p5),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(convertPtToPx(AppRadius.r16).r),
            //border: Border.all(color: AppColors.lightGray,width: convertPtToPx(AppRadius.r1).r)
            boxShadow: [AppShadow.primaryShadow],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// user name

              SizedBox(
                height: convertPtToPx(AppSize.h16).h,
              ),

              ///Consultant name.
              ///
              SizedBox(
                height: convertPtToPx(AppSize.h22).h,
                child: Text(
                  widget.appointment.consult.name != null
                      ? widget.appointment.consult.name
                      : widget.appointment.consult.phone,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                      fontFamily: getTranslated(context, 'Ithra'),
                      color: AppColors.black4,
                      fontSize: convertPtToPx(AppSize.h16).sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: convertPtToPx(-0.41)),
                ),
              ),

              SizedBox(
                height: convertPtToPx(AppSize.h10).h,
              ),

              /// date
              SizedBox(
                height: convertPtToPx(AppSize.h20).h,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: convertPtToPx(AppSize.w24).w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //x
                      SvgPicture.asset(
                        AssetsManager.calendar_clock_iconPath,
                        width: AppSize.w21_3.w,
                        height: AppSize.h21_3.h,
                      ),
                      SizedBox(width: convertPtToPx(AppSize.w8).w),
                      Text(
                        '${dateFormat.format(localDate)}',
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            fontFamily:
                                getTranslated(context, 'Montserrat-Regular'),
                            color: AppColors.darkGrey,
                            fontWeight: AppFontsWeightManager.regular,
                            fontStyle: FontStyle.normal,
                            fontSize:
                                convertPtToPx(AppFontsSizeManager.s14).sp),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: convertPtToPx(AppSize.h8).h,
              ),

              /// time
              SizedBox(
                height: convertPtToPx(AppSize.h20).h,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: convertPtToPx(AppSize.w24).w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: AppSize.w21_3.w,
                        color: AppColors.pink,
                      ),

                      SizedBox(width: convertPtToPx(AppSize.w8).w),

                      // SizedBox(
                      //     width: AppSize.w5.w
                      // ),

                      //x
                      Text(
                        time,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithralight'),
                            color: AppColors.darkGrey,
                            fontWeight: AppFontsWeightManager.regular,
                            fontStyle: FontStyle.normal,
                            fontSize:
                                convertPtToPx(AppFontsSizeManager.s14).sp),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: convertPtToPx(AppSize.h14).h,
              ),

              Container(
                height: convertPtToPx(AppSize.h43).h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLightPink,
                  // border: BorderDirectional(
                  //   top: BorderSide(color: AppColors.lightGray, width: convertPtToPx(AppSize.w1).w),
                  //   end: BorderSide(color: AppColors.lightGray, width: convertPtToPx(AppSize.w1).w),
                  // ),
                  borderRadius: BorderRadiusDirectional.only(
                      bottomStart:
                          Radius.circular(convertPtToPx(AppRadius.r16).r),
                      bottomEnd:
                          Radius.circular(convertPtToPx(AppRadius.r16).r)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      splashColor: Colors.green.withOpacity(0.6),
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentChatScreen(
                                appointment: widget.appointment,
                                user: widget.loggedUser!),
                          ),
                        );
                      },
                      child: SvgPicture.asset(
                        AssetsManager.pinkChatIconPath,
                        width: convertPtToPx(AppSize.w19_1).r,
                        color: AppColors.pink,
                      ),
                    ),
                    SizedBox(width: convertPtToPx(AppSize.w8).w),
                    Text(
                      getTranslated(context, "callingDone"),
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithra'),
                        color: AppColors.pink,
                        fontSize: convertPtToPx(AppFontsSizeManager.s14).sp,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
}
