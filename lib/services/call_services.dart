

import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/methods/convert_pt_to_px.dart';
import 'package:grocery_store/models/user.dart';
import 'package:permission_handler/permission_handler.dart';

import '../blocs/jitsi_meet/meet_cubit/meet_cubit.dart';
import '../blocs/web_rtc_bloc/start_call.dart';
import '../config/colorsFile.dart';
import '../config/paths.dart';
import '../localization/localization_methods.dart';
import '../methods/change_user_call_state.dart';
import '../methods/show_call_permissions_dialog.dart';
import '../models/AppAppointments.dart';
import '../models/meet_model.dart';
import '../screens/jitsi_meet_rining_screeen.dart';
import 'jitsi_service/meet_service_impl.dart';

class CallServices{


  /// refused the incoming calls.
  static Future <void> refuseCall({
    required bool withNavigatorBack,
    required String state,
     BuildContext ? context,
    required String callerId,

  }) async{
    // CallKeep.instance.endAllCalls().then((value) {
      ///================== change caller and user state to refused, then show dialog to current user contains (refused) ================///

      changeUserState(userId: callerId, state: state);
      changeUserState(userId: FirebaseAuth.instance.currentUser!.uid, state: state);

      if(context != null)
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.white,
          content: Container(
            //height: 200,
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.pink,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              getTranslated(context, 'userRefuse'),
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: getTranslated(context, "Ithra"),
                color: AppColors.white,
                fontSize: convertPtToPx(13.sp),
              ),
            ),
          ),
        ),
      );

    }
  // }


/// start incoming calls when the user press accept button on calling dialog.
static Future<void> startCall({
  required String appointmentId,
  required String callerId,
  required BuildContext context,
}) async{

  changeUserState(userId: FirebaseAuth.instance.currentUser!.uid, state: 'oncall')
      .then((value) {
    FirebaseFirestore.instance
        .collection(Paths.appAppointments)
        .doc(appointmentId)
        .get()
        .then((appointment) {

          getUserFromFirebase(userId: FirebaseAuth.instance.currentUser!.uid).then((user) {
            Future(() =>
            StartCall(
                host: appointmentId,
                iscaller: false,
                isVideo: false,
                loggedUser: user,
                appointment: AppAppointments.fromMap(appointment.data() as Map<dynamic, dynamic>),
                normalCall: false,
                CallerId: callerId,
                ReciverId: FirebaseAuth.instance.currentUser!.uid,
                context: context)
                .startCall());
      });

    });
  });
}



  /// get permissions from user, if permissions in denied,
  /// display dialog to user to request permissions,
  /// if permissions in granted, navigate to [JitsiMeetRiningScreen] via [webRtcCall] method.
  static Future<void> startJisiCall({
    required BuildContext context,
    required GroceryUser loggedUser,
    required AppAppointments appointment,
    required String receiverId,
  }) async{
    Permission.microphone.request().then((value) {
      if(value.isGranted==true){
        webRtcCall(
          context: context,
          appointment: appointment,
          loggedUser: loggedUser,
          receiverId: receiverId
        );
      }else if(value.isDenied== true){
        showPermissionsDialog(
          context: context,
          text: getTranslated(context, 'getPermissions'),
          buttonTitle: getTranslated(context, 'allow'),
          function: (){
            Navigator.pop(context);
          },
          refusedFunction: (){
            Navigator.pop(context);
          },
        );
      }else if(value.isPermanentlyDenied== true){
        showPermissionsDialog(
          context: context,
          text: getTranslated(context, 'getSettings'),
          buttonTitle: getTranslated(context, 'goToSettings'),
          function: (){
            Navigator.pop(context);
            AppSettings.openAppSettings(type: AppSettingsType.settings,);
          },
          refusedFunction: (){
            Navigator.pop(context);
          },
        );
      }
    });
  }


  static Future<void> webRtcCall({
    required BuildContext context,
    required GroceryUser loggedUser,
    required AppAppointments appointment,
    required String receiverId,
  }) async {
    try {

      Future(() => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (con) => BlocProvider<MeetCubit>(
                  create: (context) => MeetCubit(JitsiMeetService(
                      MeetModel(appointment.appointmentId,
                          loggedUser: loggedUser,
                          normalCall:false,
                          isVideoCall: false,
                          callerId: FirebaseAuth.instance.currentUser!.uid,
                          receiverId: receiverId,
                          appointmentId: appointment.appointmentId,
                          iscaller: true,appointment: appointment
                      ), context)),
                  child: JitsiMeetRiningScreen()
              )),
              (predict) => predict.isCurrent ? false : true));

    } catch (e) {
    }
  }



  /// Starting jitsi call.
  /// check if the current call is caller, put allowCall in firebase to true.
  /// if the current user is receiver, enter the call directly.
  ///
  static Future<void> startJitsiCallFromChat({
    required BuildContext context,
    required AppAppointments appointment,
    required GroceryUser loggedUser,
  }) async {
    DocumentReference docRef2 = FirebaseFirestore.instance
        .collection(Paths.appAppointments)
        .doc(appointment.appointmentId);
    final DocumentSnapshot documentSnapshot2 = await docRef2.get();

    if (AppAppointments.fromMap(documentSnapshot2.data() as Map).allowCall) {
      // current user is receiver now, because the caller makes the allowCall true.
      // if the current user type is user, then the caller is consultant.
      //
      String callerId;
      if(loggedUser.userType == AppConstants.user){
        callerId= appointment.consult.uid;
      }else{
        callerId= appointment.user.uid;
      }

      Future(() => StartCall(
          host: appointment.appointmentId,
          iscaller: false,
          isVideo: true,
          appointment: appointment,
          loggedUser: loggedUser,
          normalCall: false,
          CallerId: callerId,
          ReciverId: FirebaseAuth.instance.currentUser!.uid,
          fromChatScreen: true,
          context: context)
          .startCall());

    } else {
      // current user is caller now,
      // first: make the allowCall true.
      //
      await FirebaseFirestore.instance
          .collection(Paths.appAppointments)
          .doc(appointment.appointmentId)
          .set({
        'allowCall': true,
      }, SetOptions(merge: true));

      // if the current user type is user, then the receiver is consultant.
      String receiverId;
      if(loggedUser.userType == AppConstants.user){
        receiverId= appointment.consult.uid;
      }else{
        receiverId= appointment.user.uid;
      }

      Future(() => StartCall(
          host: appointment.appointmentId,
          iscaller: true,
          isVideo: true,
          fromChatScreen: true,
          appointment: appointment,
          loggedUser: loggedUser,
          normalCall: false,
          CallerId: FirebaseAuth.instance.currentUser!.uid,
          ReciverId: receiverId,
          context: context)
          .startCall());

    }
  }


}



Future<GroceryUser?> getUserFromFirebase({required String userId}) async{
  await FirebaseFirestore.instance
      .collection(Paths.usersPath)
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get().then((value) {
        return GroceryUser.fromMap(value.data() as Map<dynamic, dynamic>);
      });
  return null;
}