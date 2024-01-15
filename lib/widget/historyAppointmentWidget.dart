import 'dart:developer';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:permission_handler/permission_handler.dart';

import '../blocs/jitsi_meet/meet_cubit/meet_cubit.dart';
import '../config/assets_manager.dart';
import '../methods/show_call_permissions_dialog.dart';
import '../models/meet_model.dart';
import '../screens/jitsi_meet_rining_screeen.dart';
import '../services/jitsi_service/meet_service_impl.dart';
//import 'package:twilio_voice/twilio_voice.dart';

class HistoryAppointmentWidget extends StatefulWidget {
  final GroceryUser loggedUser;
  final AppAppointments appointment;

  HistoryAppointmentWidget(
      {required this.appointment, required this.loggedUser});

  @override
  State<HistoryAppointmentWidget> createState() =>
      _HistoryAppointmentWidgetState();
}

class _HistoryAppointmentWidgetState extends State<HistoryAppointmentWidget>
    with SingleTickerProviderStateMixin {
  bool acceptLoad = false, loadingCall = false;
  bool joinMeeting = false;

  @override
  Widget build(BuildContext context) {
    String time;
    DateTime localDate = DateTime.parse(
            widget.appointment.appointmentTimestamp.toDate().toString())
        .toLocal();
    if (localDate.hour == 12)
      time = "12 Pm";
    else if (localDate.hour == 0)
      time = "12 Am";
    else if (localDate.hour > 12)
      time = (localDate.hour - 12).toString() +
          ":" +
          localDate.minute.toString() +
          "Pm";
    else
      time = (localDate.hour).toString() +
          ":" +
          localDate.minute.toString() +
          "Am";

    return Container(
      height: AppSize.h201_3.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(21.3.r),
        border: Border.all(
          width: AppSize.w1_5.w,
          color: AppColors.lightGray,
        ),
      ),
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: AppSize.h21_3.h,
          ),
          Container(
            child: Column(
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
                      color: AppColors.appbartext,
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal),
                ),
                SizedBox(
                  height: AppSize.h21_3.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppPadding.p30.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// date of appointment.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: AppPadding.p3.w),
                            child: SvgPicture.asset(
                              AssetsManager.calendar_check2Path,
                              color: AppColors.Pink2,
                              width: AppSize.w16.w,
                              height: AppSize.h16.h,
                            ),
                          ),
                          SizedBox(
                            width: AppSize.w10_6.w,
                          ),
                          Text(
                            "${localDate.year}/${localDate.month}/${localDate.day}",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithralight'),
                              color: AppColors.darkGrey,
                              fontSize: AppFontsSizeManager.s16.sp,
                            ),
                          ),
                        ],
                      ),

                      /// time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: AppPadding.p3.w),
                            child: Icon(
                              Icons.access_time,
                              color: AppColors.Pink2,
                              size: AppSize.w18_6.w,
                            ),
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
                              color: AppColors.darkGrey,
                              fontSize: AppFontsSizeManager.s16.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Row(
          //   mainAxisSize: MainAxisSize.max,
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     /// client name
          //
          //     /// price
          //     // Container(
          //     //   padding: EdgeInsets.symmetric(
          //     //       horizontal: AppPadding.p10, vertical: 2.3),
          //     //   decoration: BoxDecoration(
          //     //     border: Border.all(width: 1, color: AppColors.pink),
          //     //     borderRadius: BorderRadius.circular(AppRadius.r5_3.r),
          //     //   ),
          //     //   child: Center(
          //     //     child: Text(
          //     //       double.parse(widget.appointment.callPrice.toString())
          //     //               .toStringAsFixed(2) +
          //     //           "\$",
          //     //       textAlign: TextAlign.center,
          //     //       style: TextStyle(
          //     //         fontFamily:
          //     //             getTranslated(context, 'Montserrat-SemiBold'),
          //     //         color: AppColors.linear2,
          //     //         fontSize: AppFontsSizeManager.s18_6.sp,
          //     //         fontWeight: FontWeight.w600,
          //     //         fontStyle: FontStyle.normal,
          //     //       ),
          //     //     ),
          //     //   ),
          //     // ),
          //   ],
          // ),
          SizedBox(
            height: AppSize.h20.h,
          ),

          Container(
            width: double.infinity,
            height: AppSize.h1.h,
            color: AppColors.lightGray,
          ),
          Container(
            height: AppSize.h72.h,
            decoration: BoxDecoration(
                color: AppColors.BackGroundLightPink,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.r21_3.r),
                  bottomRight: Radius.circular(AppRadius.r21_3.r),
                )),
            child: InkWell(
              splashColor: Colors.green.withOpacity(0.5),
              onTap: () async {
                /* if (!await (TwilioVoice.instance.hasMicAccess())) {
                  TwilioVoice.instance.requestMicAccess();
                  return;
                }
                TwilioVoice.instance.call.place(to:appointment.user.uid,from: loggedUser.uid!,extraOptions:{"user":"yasmeen","consult":"ahmed"});

                Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                    fullscreenDialog: true, builder: (context) => VoiceCallScreen(loggedUser:loggedUser,appointment:appointment,from:'history')));*/
                startMeeting();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AssetsManager.call_back_purple_icon_path,
                    width: AppSize.w21_5.w,
                    height: AppSize.h23.h,
                    //color: AppColors.white,
                  ),
                  SizedBox(
                    width: AppSize.w10_6.w,
                  ),
                  Text(
                    getTranslated(context, "recall"),
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: getTranslated(context, 'Ithra'),
                      color: Theme.of(context).primaryColor,
                      fontSize: AppFontsSizeManager.s18.sp,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void startMeeting() async {
    Permission.microphone.request().then((value) {
      if (value.isGranted == true) {
        webRtcCall();
      } else if (value.isDenied == true) {
        showPermissionsDialog(
          context: context,
          text: getTranslated(context, 'getPermissions'),
          buttonTitle: getTranslated(context, 'allow'),
          function: () {
            Navigator.pop(context);
          },
          refusedFunction: () {
            Navigator.pop(context);
          },
        );
      } else if (value.isPermanentlyDenied == true) {
        showPermissionsDialog(
          context: context,
          text: getTranslated(context, 'getSettings'),
          buttonTitle: getTranslated(context, 'goToSettings'),
          function: () {
            Navigator.pop(context);
            AppSettings.openAppSettings(
              type: AppSettingsType.settings,
            );
          },
          refusedFunction: () {
            Navigator.pop(context);
          },
        );
      }
    });
  }

  webRtcCall() async {
    try {
      setState(() {
        joinMeeting = true;
      });

      if (widget.loggedUser.userType == "CONSULTANT") {
        log('JitsiMeetRiningScreen');
        Future(() => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (con) => BlocProvider<MeetCubit>(
                    create: (context) => MeetCubit(JitsiMeetService(
                        MeetModel(widget.appointment.appointmentId,
                            loggedUser: widget.loggedUser,
                            normalCall: false,
                            isVideoCall: false,
                            callerId: FirebaseAuth.instance.currentUser!.uid,
                            receiverId: widget.appointment.user.uid,
                            appointmentId: widget.appointment.appointmentId,
                            iscaller: true,
                            appointment: widget.appointment),
                        context)),
                    child: JitsiMeetRiningScreen())),
            (predict) => predict.isCurrent ? false : true));

        setState(() {
          joinMeeting = false;
        });
      }
    } catch (e) {}
  }
}
