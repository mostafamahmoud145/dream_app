import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/core/extensions/size_extension.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/methods/change_user_call_state.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:permission_handler/permission_handler.dart';

import '../blocs/web_rtc_bloc/check_call_state.dart';
import '../blocs/web_rtc_bloc/start_call.dart';
import '../config/app_shadow.dart';
import '../config/colorsFile.dart';

enum CallStateResult {
  userInAntherCall,
  error,
  loading,
  calling,
  refused,
  closed,
  enteredCall
}

class AgoraScreen extends StatefulWidget {
  final AppAppointments appointment;
  final GroceryUser user;
  final String appointmentId;
  final String? receiverId;
  final String? callerId;
  final bool isCaller;
  final bool fromChatScreen;

  final String consultName;

  const AgoraScreen(
      {Key? key,
      required this.appointment,
      required this.user,
      required this.appointmentId,
      this.receiverId,
      this.callerId,
      required this.isCaller,
      required this.fromChatScreen,
      required this.consultName})
      : super(key: key);

  @override
  _AgoraScreenState createState() => _AgoraScreenState();
}

class _AgoraScreenState extends State<AgoraScreen>
    with SingleTickerProviderStateMixin {
  bool _joined = false;
  int _remoteUid = 0;
  bool callStart = false;
  String name = " ", image = "  ";
  late RtcEngine engine;
  int minutes = 0, seconds = 0;
  bool mute = false, speaker = false, done = true, firstTime = false;
  CallStateResult _callStateResult = CallStateResult.loading;

  @override
  void initState() {
    super.initState();
    if (widget.fromChatScreen == false && widget.isCaller) {
      print('start call checkUserCallState');
      checkUserCallState();
    } else {
      print('start call initPlatformState');
      _callStateResult = CallStateResult.enteredCall;
      initPlatformState();
    }
    // initPlatformState();
    if (widget.user == null) {
    } else if (widget.user.uid == widget.appointment.consult.uid) {
      image = widget.appointment.user.image!;
      name = widget.appointment.user.name;
    } else {
      image = widget.appointment.consult.image!;
      name = widget.appointment.consult.name;
    }
  }

  //p
  @override
  void dispose() {
    super.dispose();
    if (widget.user != null && widget.user.userType == AppConstants.consultant)
      account_info();

    if (widget.user != null && widget.user.userType == AppConstants.user)
      account_info();

    engine.leaveChannel();
    engine.destroy();
  }

  account_info() async {
    await FirebaseFirestore.instance
        .collection(Paths.appAppointments)
        .doc(widget.appointment.appointmentId)
        .set({
      'allowCall': false,
    }, SetOptions(merge: true));
  }

  /// get current user state to check if he in anther call, or any one calling him now.
  /// if he not in call, call him by send calling notification to him, and set his callState = calling.
  ///
  Future<Map<String, dynamic>> getUserCallState() async {
    final response = await CheckCallState(
      loggedUser: widget.user,
      receiverId: widget.receiverId!,
      appointmentId: widget.appointmentId,
      callerId: widget.callerId!,
    ).CheckState();

    return response;
  }

  /// Check the user callState of receiver after call[getUserCallState].
  /// and handle any error
  ///
  void checkUserCallState() async {
    Map<String, dynamic> callState = await getUserCallState();

    switch (callState['code']) {
      case 200: // receiver not in call, so start call with him.
        if (!callStart) {
          _triggerCallState();
        }
        break;

      case 101: // receiver in anther call.
        setState(() {
          _callStateResult = CallStateResult.userInAntherCall;
        });
        break;

      case 102: // error.
        setState(() {
          _callStateResult = CallStateResult.error;
        });
        break;
    }
  }

  /// Call [_triggerCallState] after check user call state,
  /// used to check anther user call state after ensure that he is not in anther call.
  ///
  _triggerCallState() {
    FirebaseDatabase.instance
        .ref('userCallState')
        .child(widget.receiverId!)
        .child('callState')
        .onValue
        .listen((event) {
      if (event.snapshot.value == 'calling') {
        // user calling now.
        setState(() {
          _callStateResult = CallStateResult.calling;
          initPlatformState();
        });
      } else if (event.snapshot.value == 'refused') {
        // user refused the call
        setState(() {
          _callStateResult = CallStateResult.refused;
        });
      } else if (event.snapshot.value == 'closed') {
        // the call is ended for any reason (like internet, any error)
        // if(widget.user.userType== AppConstants.consultant){
        //
        // }else {
        //
        // }
        if (callStart) {
          _endMeeting();
        } else {
          setState(() {
            _callStateResult = CallStateResult.closed;
          });
        }
      } else if (event.snapshot.value == 'oncall') {
        // user accept the call
        setState(() {
          _callStateResult = CallStateResult.enteredCall;
        });
      }
    });
  }

  // Init the app
  Future<void> initPlatformState() async {
    await [Permission.microphone].request();
    RtcEngineContext context =
        RtcEngineContext("a043844218f34404911b082cea15c57a");
    engine = await RtcEngine.createWithContext(context);
    engine.enableAudio();
    engine.disableVideo();
    engine.adjustPlaybackSignalVolume(400);
    engine.muteLocalAudioStream(mute);
    engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
      setState(() {
        _joined = true;
      });
    }, userJoined: (int uid, int elapsed) {
      setState(() {
        _joined = true;
        callStart = true;
        _remoteUid = uid;
      });
    }, userOffline: (int uid, UserOfflineReason reason) {
      setState(() {
        _remoteUid = 0;
      });
    }));
    await engine.joinChannel(null, widget.appointmentId, null, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.lightGrey, //Color(0xffECECEC),
        body: switch (_callStateResult) {
          CallStateResult.userInAntherCall => EndWidget(
              context: context,
              text: 'anotherCall',
            ),
          CallStateResult.error => EndWidget(
              context: context,
              text: 'failed',
            ),
          CallStateResult.loading => Center(
              child: CircularProgressIndicator(),
            ),
          CallStateResult.refused => EndWidget(
              context: context,
              text: 'userRefuse',
            ),
          CallStateResult.closed => EndWidget(
              context: context,
              text: 'userClose',
            ),
          (CallStateResult.enteredCall || CallStateResult.calling) => SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 139.4.h,
                              width: 139.4.w,
                              padding: EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                // border: Border.all(color: AppColors.grey, width: 1),
                                shape: BoxShape.circle,
                                //color: AppColors.grey,
                              ),
                              child: image.isEmpty && image != null
                                  ? Image.asset(
                                      AssetsManager.purple_logo,
                                      width: 139.4.w,
                                      height: 139.4.h,
                                      fit: BoxFit.fill,
                                    )
                                  : ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      child: FadeInImage.assetNetwork(
                                        placeholder: 'assets/images/load.gif',
                                        placeholderScale: 0.5,
                                        imageErrorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                                    AssetsManager.purple_logo,
                                                    width: 139.4.w,
                                                    height: 139.4.h,
                                                    fit: BoxFit.fill),
                                        image: image,
                                        fit: BoxFit.cover,
                                        fadeInDuration:
                                            Duration(milliseconds: 250),
                                        fadeInCurve: Curves.easeInOut,
                                        fadeOutDuration:
                                            Duration(milliseconds: 150),
                                        fadeOutCurve: Curves.easeInOut,
                                      ),
                                    ),
                            ),
                            /*Image.asset(
                          'assets/applicationIcons/dashBorder.png',
                          width: 82,
                          height: 82,
                        )*/
                          ],
                        ),
                        SizedBox(height: 24.5.h),
                        //name
                        Text(
                          name == null ? " " : name,
                          style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithra'),
                            fontSize: 30.0.sp,
                            fontWeight: FontWeight.normal,
                            color: AppColors.pureBlack,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        //status_call
                        (callStart == false)
                            ? Text(
                                getTranslated(context, "waitAgora") +
                                    " " +
                                    " " +
                                    getTranslated(context, "join"),
                                style: TextStyle(
                                  fontFamily: getTranslated(context, 'Ithra'),
                                  fontSize: 22.0.sp,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.pink,
                                ),
                              )
                            : SizedBox(),
                        SizedBox(height: 8),
                        callStart
                            ? TweenAnimationBuilder<Duration>(
                                duration: Duration(minutes: 10),
                                tween: Tween(
                                    begin: Duration(minutes: 10),
                                    end: Duration.zero),
                                onEnd: () {
                                  if (widget.fromChatScreen) {
                                    _endSecondarySystemMeeting();
                                  } else {
                                    _endMeeting();
                                  }
                                },
                                builder: (BuildContext context2, Duration value,
                                    Widget? child) {
                                  minutes = value.inMinutes;
                                  seconds = value.inSeconds % 60;
                                  if (minutes == 5 && seconds == 0) {
                                    firstTime = true;
                                  }
                                  return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Column(
                                        children: [
                                          Text('$minutes:$seconds',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: getTranslated(
                                                      context, 'Ithra'),
                                                  color: minutes < 5
                                                      ? Colors.red
                                                      : AppColors.white,
                                                  fontSize: 15)),
                                          firstTime
                                              ? Text(
                                                  getTranslated(context,
                                                          "fiveMinutes") +
                                                      minutes.toString() +
                                                      getTranslated(
                                                          context, "minutes"),
                                                  maxLines: 2,
                                                  textAlign: TextAlign.start,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: true,
                                                  style: TextStyle(
                                                    fontFamily: getTranslated(
                                                        context, 'Ithra'),
                                                    fontSize: 11.0,
                                                    color: AppColors.red,
                                                  ),
                                                )
                                              : SizedBox(),
                                          /* Container(color: Colors.red.withOpacity(0.5),width: size.width*.8,child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
                                      Expanded(flex:2,
                                        child: Text( getTranslated(context, "fiveMinutes")+minutes.toString()+getTranslated(context, "minutes"),
                                          maxLines: 2,
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap:true,
                                          style: TextStyle( fontFamily: getTranslated(context, 'Ithra'),
                                            fontSize: 14.0,
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: SizedBox(
                                          height: 25,
                                          child: MaterialButton(
                                            onPressed: () {
                                              setState(() {
                                                firstTime=false;
                                              });
                                            },
                                            color: AppColors.pureBlack.withOpacity(0.5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(25.0),
                                            ),
                                            child: Text(
                                              getTranslated(context, "Ok"),
                                              style: TextStyle( fontFamily: getTranslated(context, 'Ithra'),
                                                color: AppColors.white,
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],),
                                  ),):SizedBox()*/
                                        ],
                                      ));
                                })
                            : SizedBox(),
                      ],
                    ),
                    SizedBox(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FloatingActionButton(
                                heroTag: "mic",
                                backgroundColor: Color.fromRGBO(63, 63, 63, 1),
                                child: Icon(
                                  mute ? Icons.mic_off : Icons.mic,
                                  color: AppColors.white,
                                  size: 25,
                                ),
                                onPressed: () => _toggleMic()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                FloatingActionButton(
                                    heroTag: "end",
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.call_end,
                                      size: 25,
                                    ),
                                    onPressed: () {
                                      if (widget.fromChatScreen) {
                                        _endSecondarySystemMeeting();
                                      } else {
                                        _endMeeting();
                                      }
                                    }),
                                SizedBox(
                                  height: 30,
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FloatingActionButton(
                                heroTag: "speaker",
                                backgroundColor: Color.fromRGBO(63, 63, 63, 1),
                                child: Icon(
                                  speaker ? Icons.volume_up : Icons.volume_off,
                                  color: AppColors.white,
                                  size: 25,
                                ),
                                onPressed: () => _toggleSpeaker()),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        });
  }

  _toggleMic() {
    setState(() {
      mute = !mute;
    });
    engine.muteLocalAudioStream(mute);
  }

  _toggleSpeaker() {
    setState(() {
      speaker = !speaker;
    });

    if (speaker)
      engine.adjustPlaybackSignalVolume(400);
    else
      engine.adjustPlaybackSignalVolume(100);
  }

  /// End call when the current call system is agora from card (Agora as main system).
  ///
  _endMeeting() async {
    setState(() {
      _callStateResult = CallStateResult.closed;
    });

    /// change call state to closed in user and consultant.
    await changeUserState(userId: widget.appointment.user.uid, state: 'closed');
    await changeUserState(
        userId: widget.appointment.consult.uid, state: 'closed');

    /// if callStart== true, that means the anther user is entered the call
    /// then when the consultant end the call, the end dialog will displayed.
    /// if callStart== false, that means that the call not started yet,
    /// so, if the consultant end the call, the dialog will not displayed.
    ///

    if (widget.user.userType == AppConstants.consultant) {
      if (callStart) {
        confirmEndCallDialog(
            context: context,
            loggedUser: widget.user,
            appointment: widget.appointment);
      } else {
        Navigator.pop(context);
      }
    }else {
      Navigator.pop(context);
    }
  }

  /// End call when the current call system is agora from chat (Agora as secondary system).
  ///
  _endSecondarySystemMeeting() async {
    await FirebaseFirestore.instance
        .collection(Paths.appAppointments)
        .doc(widget.appointment.appointmentId)
        .set({
      'allowCall': false,
    }, SetOptions(merge: true)).then((value) {
      if (widget.user.userType == AppConstants.consultant) {
        if (callStart) {
          // show dialog to close the appointment.
          confirmEndCallDialog(
              context: context,
              loggedUser: widget.user,
              appointment: widget.appointment);
        } else {
          Navigator.pop(context);
        }
      } else {
        Navigator.pop(context);
      }
    });
  }
}

class EndWidget extends StatelessWidget {
  const EndWidget(
      {Key? key,
      required this.text,
      required this.context,
      bool withButton = true})
      : super(key: key);

  final String text;
  final BuildContext context;
  final bool withButton = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              boxShadow: [AppShadow.primaryShadow],
              color: AppColors.white,
              border: Border.all(
                width: 6,
                color: AppColors.white,
              ),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              AssetsManager.dreamLogoPath,
              width: 65,
              height: 65,
            )),
        SizedBox(
          height: context.height * .15,
        ),
        Center(
            child: Text(
          getTranslated(context, text),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: "Ithra",
              fontSize: AppFontsSizeManager.s13.sp,
              color: AppColors.lightBlack,
              fontWeight: FontWeight.w500),
        )),
        SizedBox(
          height: context.height * .15,
        ),
        withButton
            ? Center(
                child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 40,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Center(
                      child: Text(
                    getTranslated(context, "Ok"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: "Ithra",
                        fontSize: AppFontsSizeManager.s15.sp,
                        color: AppColors.white,
                        fontWeight: FontWeight.w300),
                  )),
                ),
              ))
            : SizedBox()
      ],
    );
  }
}
