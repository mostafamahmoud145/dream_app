import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/network_manager.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/core/extensions/printing_extension.dart';
import 'package:grocery_store/methods/change_user_call_state.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/endCallDialog.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';

import '../../methods/stop_foreground_service.dart';
import '../jitsi_meet/call_cubit/call_cubit.dart';

class StartCall {
  StartCall(
      {required this.host,
      required this.context,
      this.iscaller,
      this.acceptNotfi,
      this.appointment,
      this.loggedUser,
      this.isVideo,
      this.normalCall,
      this.CallerId,
      this.ReciverId,
      this.fromChatScreen = false,
      this.onEndFunction});
  Function? onEndFunction;
  final String host;
  bool? iscaller = false;
  bool? acceptNotfi = false;
  AppAppointments? appointment;
  GroceryUser? loggedUser;
  String? CallerId = "";
  String? ReciverId = "";
  bool? isVideo = true;
  bool? normalCall = true;
  String? _reciverId = '';
  GroceryUser? peerInfo;
  BuildContext context;
  Timer? _timer;
  bool fromChatScreen = false;

  Future startCall() async {
    print('====caller id $CallerId');
    print('====receiver id $ReciverId');

    if (CallerId == FirebaseAuth.instance.currentUser!.uid) {
      _reciverId = CallerId;
    } else {
      _reciverId = ReciverId;
    }
    Map<String, Object> featureFlags = {};
    Map<String, Object> configOverrides = {};
    var ref = await FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(_reciverId)
        .withConverter(
          fromFirestore: GroceryUser.fromFirestore,
          toFirestore: (GroceryUser user, _) => user.toFirestore(),
        );
    final docSnap = await ref.get();
    peerInfo = await docSnap.data();
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshotServer =
        await FirebaseFirestore.instance
            .collection('servers')
            .doc('settings')
            .get();
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshotFeatureFlags =
        await FirebaseFirestore.instance
            .collection('servers')
            .doc('featureFlags')
            .get();
    final DocumentSnapshot<Map<String, dynamic>>
        documentSnapshotConfigOverrides = await FirebaseFirestore.instance
            .collection('servers')
            .doc('configOverrides')
            .get();

    documentSnapshotFeatureFlags.data()!.forEach((key, value) {
      featureFlags[key] = value;
    });

    documentSnapshotConfigOverrides.data()!.forEach((key, value) {
      configOverrides[key] = value;
    });

    var options = JitsiMeetingOptions(
      roomNameOrUrl: CallerId!,
      serverUrl: documentSnapshotServer.data()!["jitsiServer"],
      subject: peerInfo!.name,
      token: documentSnapshotServer.data()!["jitsiToken"],
      isAudioMuted: false,
      isAudioOnly: true,
      isVideoMuted: true,
      userDisplayName: peerInfo!.name,
      userEmail: '',
      featureFlags: featureFlags,
      userAvatarUrl: NetworkManager.appLogo,
      configOverrides: configOverrides,
    );
    debugPrint("JitsiMeetingOptions: $options");
    try {
      await JitsiMeetWrapper.joinMeeting(
        options: options,
        listener: JitsiMeetingListener(
          onOpened: () {
            'on opened'.logPrint();
          },
          onConferenceWillJoin: (url) {
            'onConference Will Join'.logPrint();
            if (!fromChatScreen) {
              checkCallerState();
            }
          },
          onConferenceJoined: (url) {
            'INF: onConferenceJoined'.logPrint();
            if (!fromChatScreen) {
              CallCubit.get(context).changeCallState(StartCallStates.inCall);
              checkCallerState();
            }
          },
          onConferenceTerminated: (url, error) {
            'ERROR: OnConferenceTerminated ${error.toString()}'.logPrint();
          },
          onAudioMutedChanged: (isMuted) {},
          onVideoMutedChanged: (isMuted) {},
          onScreenShareToggled: (participantId, isSharing) {},
          onParticipantJoined: (email, name, role, participantId) {
            'onParticipantJoined  Joined'.logPrint();
            startTimer();
          },
          onParticipantLeft: (participantId) {
            'onParticipantLeft'.logPrint();
            JitsiMeetWrapper.hangUp();
            if (fromChatScreen) {
              _hangUpChatMeeting();
            } else {
              _hangUp();
            }
          },
          onParticipantsInfoRetrieved: (participantsInfo, requestId) {},
          onChatMessageReceived: (senderId, message, isPrivate) {},
          onChatToggled: (isOpen) {},
          onClosed: () {
            if (fromChatScreen) {
              _hangUpChatMeeting();
            } else {
              _hangUp();
            }
          },
        ),
      );
    } catch (e) {
      'ERROR: START CALL'.logPrint();
      print(e);
    }
  }

  void startTimer() {
    Duration duration = Duration(minutes: AppConstants.callDurationToEnd);
    _timer = Timer(duration, () {
      JitsiMeetWrapper.hangUp();
      _hangUp();
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  _hangUp() {
    /// This function is passed and executed in on end call if exist
    if (onEndFunction != null) {
      onEndFunction!();
    }

    stopTimer();
    if (loggedUser!.userType != AppConstants.consultant) {
      CallCubit.get(context).changeCallState(StartCallStates.callEnded);

      bye();
      if (Platform.isAndroid) {
        stopForegroundService();
      }
    } else {
      confirmEndCallDialog(
          context: context, loggedUser: loggedUser!, appointment: appointment!);
      bye();
      if (Platform.isAndroid) {
        stopForegroundService();
      }
    }
  }

  /// End call when the current call system is jitsi from chat screen (jitsi as secondary system).
  ///
  _hangUpChatMeeting() async {
    await FirebaseFirestore.instance
        .collection(Paths.appAppointments)
        .doc(appointment!.appointmentId)
        .set({
      'allowCall': false,
    }, SetOptions(merge: true)).then((value) {
      if (loggedUser!.userType == AppConstants.consultant) {
        // show dialog to close the appointment.
        confirmEndCallDialog(
            context: context,
            loggedUser: loggedUser!,
            appointment: appointment!);
      } else {
        Navigator.pop(context);
      }
    });
  }

  void bye() {
    changeUserState(userId: CallerId!, state: 'closed');
    changeUserState(userId: ReciverId!, state: 'closed');
  }

  void checkCallerState() async {
    final FirebaseDatabase db = FirebaseDatabase.instance;
    final receiverState = await db
        .ref(Paths.userCallState)
        .child(_reciverId!)
        .child("callState")
        .once();
    final callerState = await db
        .ref(Paths.userCallState)
        .child(CallerId!)
        .child("callState")
        .once();
    // check call exists
    if (receiverState.snapshot.exists && callerState.snapshot.exists) {
      // check call state
      receiverState.snapshot.value.toString().logPrint();
      if (receiverState.snapshot.value == 'closed' ||
          receiverState.snapshot.value == 'refused' ||
          receiverState.snapshot.value == 'calling' ||
          callerState.snapshot.value == 'closed' ||
          callerState.snapshot.value == 'refused' ||
          callerState.snapshot.value == 'calling') {
        'HangUp is Processing'.logPrint();
        JitsiMeetWrapper.hangUp();
        _hangUp();
      }
      //calling
      //refused
    }
  }
}

confirmEndCallDialog({
  required BuildContext context,
  required GroceryUser loggedUser,
  required AppAppointments appointment,
}) async {
  await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return EndCallDialog(
        user: loggedUser,
        appointment: appointment,
      );
    },
  );
}
