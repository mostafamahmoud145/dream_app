import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:grocery_store/Utils/exception.dart';
import 'package:grocery_store/core/extensions/printing_extension.dart';
import 'package:grocery_store/models/meet_model.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../blocs/web_rtc_bloc/check_call_state.dart';
import '../../blocs/web_rtc_bloc/start_call.dart';
import '../../config/constants.dart';
import 'meet_service.dart';

class JitsiMeetService implements MeetService {
  BuildContext context;
  @override
  MeetModel meetDetails;

  JitsiMeetService(this.meetDetails, this.context);

  @override
  Future<void> requestCallPermissions() async {
    if (!kIsWeb) {
      if (false) {
        // This is for Video Call
        var cameraStatus = await Permission.camera.request();
        var MicStatus = await Permission.microphone.request();

        if (cameraStatus.isGranted && MicStatus.isGranted) {
          checkCallPermissions(
              call_permission.cameraGranted, call_permission.micGranted);
        }
        if (!cameraStatus.isGranted && !MicStatus.isGranted) {
          checkCallPermissions(
              call_permission.cameraDenied, call_permission.micDenied);
        }
        if (!MicStatus.isGranted) {}
      } else {
        await Permission.microphone.request();
        var MicStatus = await Permission.microphone.status;
        if (MicStatus.isGranted) {
          checkCallPermissions(
              call_permission.micGranted, call_permission.micGranted);
        } else {
          checkCallPermissions(
              call_permission.micDenied, call_permission.micDenied);
        }
      }
    }
  }

  @override
  void checkCallPermissions(
      call_permission permission1, call_permission permission2) {
    // switch (permission1) {
    //   case call_permission.cameraGranted:
    //     // cameraGranted = true;
    //     break;
    //   case call_permission.micGranted:
    //     // micGranted = true;
    //
    //     break;
    //   case call_permission.cameraDenied:
    //     // cameraGranted = false;
    //     break;
    //   case call_permission.micDenied:
    //     // micGranted = false;
    //     break;
    // }
    //
    // switch (permission2) {
    //   case call_permission.cameraGranted:
    //     // cameraGranted = true;
    //     break;
    //   case call_permission.micGranted:
    //     // micGranted = true;
    //
    //     break;
    //   case call_permission.cameraDenied:
    //     // cameraGranted = false;
    //     break;
    //   case call_permission.micDenied:
    //     // micGranted = false;
    //     break;
    // }

    //   if (micGranted) {

    //checkIfTheReceiverNotificationBlocked(appointmentId: widget.appointment!.appointmentId);
/*
    if (context.mounted) {


      setState(() {
        fristload = false;
      });



    }
   */
  }

  @override
  Future<call_state> checkCallState(
    call_state state,
  ) async {
    switch (state) {
      case call_state.anotherCall:
        return call_state.anotherCall;

      case call_state.calling:

        // checkIfTheReceiverNotificationBlocked(
        //     appointmentId: widget.appointment!.appointmentId);

        if (!meetDetails.iscaller!) {
          if (context.mounted) {
            return call_state.calling;
          }
        }

        break;
      case call_state.refused:
        if (context.mounted) {
          return call_state.refused;
        }

        break;
      case call_state.closed:
        if (context.mounted) {
          return call_state.closed;
        }
        break;
      case call_state.inCall:
        return call_state.inCall;

      case call_state.timeOut:
      // TODO: Handle this case.
    }

    /// Default return if there is no returned values from previous cases
    return call_state.closed;
  }

  /// ##########################################
  /// ####### - that will trigger call - ######
  /// ##########################################
  @override
  Future<call_state> triggerCallState() async {
    var result;
    var completer = Completer<call_state>();
    Timer? timer; // Nullable to ensure we can check if it's been initialized
    StreamSubscription? subscription; // Used to enforce the timeout
    void cleanUp() {
      timer?.cancel(); // Cancel the timer if it's been initialized
      subscription?.cancel(); // Cancel the subscription
    }

    subscription = FirebaseDatabase.instance
        .ref('userCallState')
        .child(meetDetails.receiverId)
        .child('callState')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        if (event.snapshot.value == 'calling') {
          result = call_state.calling;
        } else if (event.snapshot.value == 'refused') {
          result = call_state.refused;
        } else if (event.snapshot.value == 'closed') {
          result = call_state.closed;
        } else if (event.snapshot.value == 'oncall') {
          result = call_state.inCall;
        }
        if (!completer.isCompleted &&
            event.snapshot.value != null &&
            event.snapshot.value != 'calling') {
          print('Data changed! Value: ${event.snapshot.value}');
          '${event.snapshot.value}'.logPrint();
          completer.complete(result); // Complete the future when data changes
          cleanUp();
        }
      } else {
        //TODO: First time the user call
        // storeNewInstanceInDatabase();
      }
    });

    // Set up the timer to cancel listening after 30 seconds
    timer = Timer(Duration(seconds: 30), () {
      if (!completer.isCompleted) {
        print('Timeout reached, no change detected');
        '${result}'.logPrint();
        completer.complete(call_state.timeOut);
        cleanUp();
      }
    });
    // Return the future

    'COMPELETER: ${completer.future}'.printError;
    return completer.future;
  }

  // void storeNewInstanceInDatabase() {
  //   // TODO: to be implemented
  // }

  /// ##########################################
  /// ####### - Which one to call  - ######
  /// ####### - USER,CONSULTANT,SUPPORT  - ######
  /// ##########################################
  @override
  Future<MeetStatesEnum> checkUserCallState() async {
    try {
      final res = await CheckCallState(
              appointmentId: meetDetails.appointmentId,
              receiverId: meetDetails.receiverId,
              loggedUser: meetDetails.loggedUser,
              callerId: meetDetails.callerId)
          .CheckState();
      if (res['code'] == 101) {
        return MeetStatesEnum.UserInCallState;

        // anotherCall = true;
        // errorCall = false;
      } else if (res['code'] == 102) {
        // if(res['message']['code'] == "messaging/registration-token-not-registered")

        return MeetStatesEnum.ErrorCreatingState;

        // anotherCall = false;
        // errorCall = true;
      } else if (res['code'] == 200) {
        return MeetStatesEnum.IncomingCall;

        // anotherCall = false;
        // errorCall = false;
      }
      // Dead Code
      return MeetStatesEnum.nullState;
    } catch (e) {
      'Exception is fired $e'.logPrint();
      if ((e as CustomException).exceptionMsg == 'unavailable') {
        return MeetStatesEnum.connectionError;
      }
      return MeetStatesEnum.ErrorCreatingState;
    }
  }

  /// ##########################################
  /// ####### - Which one to call  - ######
  /// ####### - USER,CONSULTANT,SUPPORT  - ######
  /// ##########################################
  @override
  WhichCallToStart(Function onEndfunction) {
    if (context.mounted) {
      if (meetDetails.loggedUser!.userType == AppConstants.consultant ||
          meetDetails.loggedUser!.userType == "SUPPORT") {
        //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (con) => CallSample(host: widget.host, iscaller: true, loggedUser: widget.loggedUser, appointment: widget.appointment, isVideo: true, normalCall: false, CallerId: FirebaseAuth.instance.currentUser!.uid!, ReciverId: widget.appointment?.user.uid,)));
        StartCall(
          host: meetDetails.host,
          iscaller: true,
          loggedUser: meetDetails.loggedUser,
          appointment: meetDetails.appointment,
          isVideo: true,
          normalCall: false,
          CallerId: FirebaseAuth.instance.currentUser!.uid,
          ReciverId: meetDetails.appointment?.user.uid,
          context: context,
          onEndFunction: onEndfunction,
        )..startCall();
      } else if (meetDetails.loggedUser!.userType == AppConstants.user) {
        //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (con) => CallSample(host: widget.host, iscaller: true, loggedUser: widget.loggedUser, appointment: widget.appointment, isVideo: true, normalCall: false, CallerId: FirebaseAuth.instance.currentUser!.uid!, ReciverId: widget.appointment?.consult.uid,)));
        StartCall(
          host: meetDetails.host,
          iscaller: true,
          loggedUser: meetDetails.loggedUser,
          appointment: meetDetails.appointment,
          isVideo: true,
          normalCall: false,
          CallerId: FirebaseAuth.instance.currentUser!.uid,
          ReciverId: meetDetails.appointment?.consult.uid,
          context: context,
          onEndFunction: onEndfunction,
        )..startCall();
      }
    }
  }

  /// ##################################################
  /// ####### - update server with onCall State - ######
  /// ##################################################
  @override
  Future<void> updateServerWithCallState() async {
    await FirebaseDatabase.instance
        .ref('userCallState')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('callState')
        .set('oncall');
  }
}

enum MeetStatesEnum {
  nullState,
  LoadingShimmerState,
  CheckedUserState,
  UserRefusedState,
  UserClosedState,
  UserInCallState,
  ErrorCreatingState,
  deleteNotification,
  IncomingCall,
  FetchingError,
  connectionError,
}
