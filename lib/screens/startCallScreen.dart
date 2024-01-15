import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:grocery_store/blocs/jitsi_meet/call_cubit/call_cubit.dart';
import 'package:grocery_store/blocs/web_rtc_bloc/start_call.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/screens/agoraScreen.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/app_shadow.dart';
import '../config/colorsFile.dart';
import '../config/paths.dart';
import '../localization/localization_methods.dart';
import '../methods/show_call_permissions_dialog.dart';
import '../models/AppAppointments.dart';
import '../models/user.dart';

class startCallScreen extends StatefulWidget {
  @override
  State<startCallScreen> createState() => _startCallScreenState();
}

class _startCallScreenState extends State<startCallScreen> {

  late var data;
  bool callEnded = false;

  initState() {
    super.initState();
    getActiveCall(context);
    //checkIfTheSenderCanceled();
  }

  /// Get the active call data from CallKit.
  /// end all calls.
  /// join the meeting.
  ///

  getActiveCall(context) async {
     await FlutterCallkitIncoming.activeCalls().then((value) {
      data = value;
      FlutterCallkitIncoming.endAllCalls();
      joinCall(context);
    });
    // await CallKeep.instance.activeCalls().then((value) async{
    //   data = value[0];
    //   await CallKeep.instance.endAllCalls();
    //   joinCall(context);
    // });
  }

  /// if the user accept permissions for mic, [startCall] will called to :
  /// 1 => change current user state to 'oncall',
  /// 2 => get current user data by uId,
  /// 3 => get appointment data bu appointmentId,
  /// 4 => enter the call.


  startCall(BuildContext context) async {
    // var data = await FlutterCallkitIncoming.activeCalls();
    FirebaseDatabase.instance
        .ref('userCallState')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('callState')
        .set('oncall')
        .then((value) => FirebaseFirestore.instance
            .collection(Paths.usersPath)
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((user) => FirebaseFirestore.instance
                    .collection(Paths.appAppointments)
                    .doc(data[0]['extra']['appointmentId'])
                    .get()
                    .then((appointment) {

                      AppAppointments appAppointment= AppAppointments.fromMap(appointment.data() as Map<dynamic, dynamic>);
                      GroceryUser groceryUser= GroceryUser.fromMap(user.data() as Map<dynamic, dynamic>);

                      detectCallTypeAndNavigateToCall(
                        appointment: appAppointment,
                        user: groceryUser,
                        data: data
                      );

                })));
  }

  /// when the user enter to the call:
  /// => request permissions of mic from him.
  /// => if the permissions if granted, call [startCall] method to go direct to the call,
  /// => if denied, change callState in bloc to permissionNotAllowed, to rebuild the screen and show joinCall button.
  /// => if he denied multiple times, show the dialog to him to go to the settings to accept permissions.

  void joinCall(context) async {
    await Permission.microphone.request().then((value) {
      if (value.isGranted == true) {
        startCall(context);
      } else if (value.isDenied == true) {
        CallCubit.get(context)
            .changeCallState(StartCallStates.permissionsNotAllowed);
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
        CallCubit.get(context)
            .changeCallState(StartCallStates.permissionsNotAllowed);
      }
    });
  }



  /// detect the call type and navigate to call screen.
  detectCallTypeAndNavigateToCall({
    required var data,
    required GroceryUser user,
    required AppAppointments appointment
  }) {
    if(data[0]['extra']['callService']== 'agora'){
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context)=> AgoraScreen(
          receiverId: FirebaseAuth.instance.currentUser!.uid,
          callerId: data[0]['extra']['callerId'],
          user: user,
          appointment: appointment,
          appointmentId: data[0]['extra']['appointmentId'],
          consultName: data[0]['extra']['callerName'],
          isCaller: false,
          fromChatScreen: false,
        )),
      );

    }else {

      Future(() => StartCall(
          host: data[0]['extra']['appointmentId'],
          iscaller: false,
          isVideo: true,
          appointment: appointment,
          loggedUser: user,
          normalCall: false,
          CallerId: data[0]['extra']['callerId'],
          ReciverId: FirebaseAuth.instance.currentUser!.uid,
          context: context)
          .startCall());
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: AppColors.pink,),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          /// app logo
          ///
          Container(
              height: AppSize.h70,
              width: AppSize.w70,
              decoration: BoxDecoration(
                boxShadow: [AppShadow.primaryShadow],
                color: AppColors.white,
                border: Border.all(
                  width: AppSize.w6,
                  color: AppColors.white,
                ),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                AssetsManager.dreamLogoPurpleImagePath,
                width: AppSize.w65,
                height: AppSize.h65,
              )),
          SizedBox(
            height: size.height * AppSize.h0_15,
          ),

          /// check for state of the call:
          /// if loading => load page.
          /// if the permission is disallowed => show joinCall button to open permission dialog, then enter call.
          /// if inCall => show (you are in the call now) page.
          /// if callEnded => show (ok) button to go to home.
          ///
          BlocBuilder<CallCubit, CallStates>(
              bloc: CallCubit.get(context),
              builder: (context, state) {
                switch (context.read<CallCubit>().callState) {
                  case StartCallStates.loading:
                    return Column(
                      children: [
                        loadingWidget(),
                        SizedBox(
                          height: (size.height * .15) + 40,
                        ),
                      ],
                    );

                  case StartCallStates.inCall:
                    return Column(
                      children: [
                        Center(
                            child: text(
                                getTranslated(context, 'userInCallNow'),
                                13,
                                Color.fromRGBO(32, 32, 32, 1),
                                FontWeight.w500)),
                        SizedBox(
                          height: (size.height * .15) + 40,
                        ),
                      ],
                    );

                  case StartCallStates.permissionsNotAllowed:
                    return Column(
                      children: [
                        loadingWidget(),
                        SizedBox(
                          height: size.height * .15,
                        ),
                        Center(
                            child: buttonWidget(
                                context: context,
                                buttonText: getTranslated(context, 'joinCall'),
                                function: () {
                                  joinCall(context);
                                })),
                      ],
                    );

                  case StartCallStates.callEnded:
                    return Column(
                      children: [
                        Center(
                            child: text(
                                getTranslated(context, 'userClose'),
                                13,
                                Color.fromRGBO(32, 32, 32, 1),
                                FontWeight.w500)),
                        SizedBox(
                          height: size.height * .15,
                        ),
                        Center(
                            child: buttonWidget(
                                context: context,
                                buttonText: getTranslated(context, 'Ok'),
                                function: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/home', (route) => false);
                                })),
                      ],
                    );
                }
              }),
        ],
      ),
    );
  }

  Widget loadingWidget() => Center(
        child: Lottie.asset(
          'assets/lotifile/loading.json',
        ),
      );

  Widget text(String text, double size, Color color, FontWeight weight) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontFamily: "Ithra", // 'Montserrat',
          fontSize: size,
          color: color,
          fontWeight: weight),
    );
  }

  Widget buttonWidget(
      {context, required String buttonText, required Function function}) {
    return InkWell(
      onTap: () {
        function();
      },
      child: Container(
        height: AppSize.h40,
        width: AppSize.w200,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(AppRadius.r20),
        ),
        child: Center(
          child: text(buttonText, 15, AppColors.white, FontWeight.w300),
        ),
      ),
    );
  }
}
