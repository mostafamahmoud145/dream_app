import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_store/config/app_fonts.dart';
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
import 'package:lottie/lottie.dart';

import '../config/paths.dart';
import '../methods/check_calling_system_type.dart';
import '../services/agora_call_service.dart';
import '../services/call_services.dart';

class AppointmentWidget extends StatefulWidget {
  final GroceryUser? loggedUser;
  final AppAppointments appointment;

  AppointmentWidget({
    required this.appointment,
    this.loggedUser,
  });

  @override
  _AppointmentWidgetState createState() => _AppointmentWidgetState();
}

class _AppointmentWidgetState extends State<AppointmentWidget>
    with SingleTickerProviderStateMixin {
  bool acceptLoad = false, loadingCall = false, loadUser= true;
  GroceryUser? user;

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(widget.appointment.user.uid)
        .get().then((value) {
      user= GroceryUser.fromMap(value.data() as Map<dynamic, dynamic>);

      setState(() {
        loadUser= false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String time;
    DateFormat dateFormat = DateFormat('dd/MM/yy');
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
          " ${getTranslated(context, 'pm')}";
    else
      time = (localDate.hour).toString() +
          ":" +
          localDate.minute.toString() +
          " ${getTranslated(context, 'am')}";

    return Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(convertPtToPx(AppRadius.r16).r),
            border: Border.all(
                color: AppColors.lightGray,
                width: convertPtToPx(AppRadius.r1).r)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: convertPtToPx(AppSize.h16).h,
            ),
            SizedBox(
              height: convertPtToPx(AppSize.h20).h,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: convertPtToPx(AppSize.w25).w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          AssetsManager.calendar_clock_iconPath,
                          width: AppSize.w21_5.w,
                        ),
                        SizedBox(
                          width: AppSize.w10_6.w,
                        ),
                        Text(
                          '${dateFormat.format(localDate)}',
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily:
                                getTranslated(context, 'Montserrat-Regular'),
                            color: AppColors.warmGrey,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            fontSize: AppFontsSizeManager.s16.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: AppSize.w184.w,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: AppSize.w21_5.w,
                          color: AppColors.pink,
                        ),
                        SizedBox(
                          width: AppSize.w10_6.w,
                        ),
                        Text(
                          time,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithralight'),
                            color: AppColors.warmGrey,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            fontSize: AppFontsSizeManager.s16.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: convertPtToPx(AppSize.h20).h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.appointment.user.name != null
                      ? widget.appointment.user.name
                      : widget.appointment.user.phone,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: getTranslated(context, 'Ithra'),
                    color: AppColors.black1,
                    fontSize: AppFontsSizeManager.s21_3.sp,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                  ),
                ),
                if(user!= null)
                Text(
                  '${user==null || user!.userLang==null || user!.userLang=='' ? '': ' (${user!.userLang!.toUpperCase()})'}',
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: getTranslated(context, 'Ithra'),
                    color: AppColors.pink,
                    fontSize: AppFontsSizeManager.s21_3.sp,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: convertPtToPx(AppSize.h37).h,
            ),
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

                                          checkCallingType(context)
                                              .then((value) async {
                                            if (value == true) {
                                              print(widget
                                                  .appointment.appointmentId);
                                              await AgoraCallService
                                                  .startAgoraCallFromCard(
                                                      context: context,
                                                      loggedUser: widget
                                                          .loggedUser!,
                                                      callerId: widget
                                                          .appointment
                                                          .consult
                                                          .uid,
                                                      receiverId: widget
                                                          .appointment.user.uid,
                                                      appointment:
                                                          widget.appointment);
                                            } else {
                                              CallServices.startJisiCall(
                                                  appointment:
                                                      widget.appointment,
                                                  loggedUser:
                                                      widget.loggedUser!,
                                                  receiverId: widget
                                                      .appointment.user.uid,
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
                                          showFailedSnackBar(
                                              getTranslated(context, 'failed'));
                                        }
                                      },
                                      child: Container(
                                        height: convertPtToPx(AppSize.h43).h,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.backgroundLightPink,
                                          border: BorderDirectional(
                                            top: BorderSide(
                                                color: AppColors.lightGray,
                                                width: convertPtToPx(AppSize.w1)
                                                    .w),
                                            end: BorderSide(
                                                color: AppColors.lightGray,
                                                width: convertPtToPx(AppSize.w1)
                                                    .w),
                                          ),
                                          borderRadius:
                                              BorderRadiusDirectional.only(
                                            bottomStart: Radius.circular(
                                                convertPtToPx(AppRadius.r16).r),
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
                                              color: AppColors.darkGreen,
                                            ),
                                            SizedBox(
                                                width:
                                                    convertPtToPx(AppSize.w10)
                                                        .w),
                                            Text(
                                              getTranslated(context, "calling"),
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontFamily: getTranslated(
                                                      context, 'Ithra'),
                                                  color: AppColors.darkGreen,
                                                  fontSize: convertPtToPx(
                                                          AppFontsSizeManager
                                                              .s14)
                                                      .sp,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.normal,
                                                  letterSpacing:
                                                      convertPtToPx(-0.5)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ))
                          : SizedBox(),

                      // widget.appointment.consultType == "voice"
                      //     ? Container(
                      //     height: convertPtToPx(AppSize.h43).h,
                      //     width: convertPtToPx(AppSize.w1).w,
                      //     color: Colors.transparent)
                      //     : SizedBox(),
                      //d
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
                                      user: widget.loggedUser!),
                                ),
                              );
                            },
                            child: Container(
                              height: convertPtToPx(AppSize.h43).h,
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
                                          AssetsManager.chat2,
                                          width: convertPtToPx(AppSize.w16_2).r,
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
                                                  height: AppSize.h8.h,
                                                  width: AppSize.w8.w,
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
  }
}

class NoInternetComponent extends StatelessWidget {
  const NoInternetComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(child: Lottie.asset('assets/lotifile/no_internet.json')),
    );
  }
}
