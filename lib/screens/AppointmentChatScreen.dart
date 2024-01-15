import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/blocs/user_chat/user_chat.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/methods/show_failed_snackbar.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/SupportMessage.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/AppointChatMessageItem.dart';
import 'package:grocery_store/widget/dreamDialogsWidget.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:uuid/uuid.dart';

import '../FireStorePagnation/bloc/pagination_listeners.dart';
import '../blocs/web_rtc_bloc/start_call.dart';
import '../config/assets_manager.dart';
import '../config/colorsFile.dart';
import '../methods/check_calling_system_type.dart';
import '../providers/user_data_provider.dart';
import '../services/agora_call_service.dart';
import '../services/call_services.dart';
import '../widget/audioRocordingWidget.dart';
import '../widget/back_button.dart';

var image;
File? selectedProfileImage;

class AppointmentChatScreen extends StatefulWidget {
  final AppAppointments appointment;

  final GroceryUser user;

  const AppointmentChatScreen({required this.appointment, required this.user});

  @override
  _AppointmentChatScreenState createState() => _AppointmentChatScreenState();
}

class _AppointmentChatScreenState extends State<AppointmentChatScreen> {
  PaginateRefreshedChangeListener refreshChangeListener =
      PaginateRefreshedChangeListener();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false, checkAgora = false, uploadVideo = false;
  late bool isShowSticker,
      answered = false,
      done = true,
      endingCall = false,
      haveCall = false,
      load = false;
  String lang = "";
  late String imageUrl;
  var stCollection = 'messages', theme;
  ValueNotifier<String> text = ValueNotifier("");
  late AccountBloc accountBloc;
  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  bool agoraCalling = false;
  bool callingNow = false;
  final FocusNode focusNode = new FocusNode();
  bool loadingCall = false;
  late DocumentReference reference;
  late Size size;
  late StreamSubscription? _updateReadListener;

  @override
  void initState() {
    super.initState();
    loading = false;
    reference = FirebaseFirestore.instance
        .collection('AppAppointments')
        .doc(widget.appointment.appointmentId);
    checkStatus();
    focusNode.addListener(onFocusChange);
    accountBloc = BlocProvider.of<AccountBloc>(context);
    userReadHisMessage(widget.user.userType!);
    addChatListener();
  }

  addChatListener() async {
    _updateReadListener = await UserChat().updateReadMessagesForUser(
        appointmentId: widget.appointment.appointmentId,
        userType: widget.user.userType!);
  }

  /// listen to allowCall field of appointment.
  ///
  Future<void> checkStatus() async {
    reference.snapshots().listen((querySnapshot) async{

      setState(() {
        callingNow= querySnapshot.get("allowCall");      // if true => some one calling now.
      });

      if(await checkCallingType(context)){ // Agora is main call system.
        setState(() {
          agoraCalling= false;      // second system now is jitsi meet.
        });

      }else { // JitsiMeet is main call system.
        if (mounted)
          setState(() {
            agoraCalling = querySnapshot.get("allowCall");
          });
      }
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    if (_updateReadListener != null) {
      print('_updateReadListener cancelled');
      _updateReadListener!.cancel();
    }
    super.dispose();
  }

  Future<void> userReadHisMessage(String type) async {
    try {
      if (type == AppConstants.consultant)
        await FirebaseFirestore.instance
            .collection(Paths.appAppointments)
            .doc(widget.appointment.appointmentId)
            .set({
          'userChat': 0,
        }, SetOptions(merge: true));
      else
        await FirebaseFirestore.instance
            .collection(Paths.appAppointments)
            .doc(widget.appointment.appointmentId)
            .set({
          'consultChat': 0,
        }, SetOptions(merge: true));
    } catch (e) {}
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");

    return Scaffold(
      backgroundColor: AppColors.white,
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding(
                padding: const EdgeInsets.only(
                    left: AppPadding.p10,
                    right: AppPadding.p10,
                    bottom: AppPadding.p6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomBackButton(),

                    SizedBox(
                      width: AppSize.w16.w,
                    ),
                    Expanded(
                      child: Text(
                        widget.user.userType == AppConstants.user
                            ? widget.appointment.consult.name
                            : widget.appointment.user.name,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 1,
                        style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithra'),
                            fontSize: AppFontsSizeManager.s21_3.sp,
                            color: AppColors.pureBlack.withOpacity(0.8),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    (widget.appointment.consultType == "voice" &&
                            widget.appointment.appointmentStatus == "open")
                        ? loadingCall
                            ? CircularProgressIndicator()
                            : ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r50.r),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    splashColor:
                                        AppColors.white.withOpacity(0.5),
                                    onTap: () async {
                                      try{
                                        setState(() {
                                          loadingCall= true;
                                        });
                                        /// first, get current calling system from firebase.
                                        /// then, if the current system is agora, then the second system is jitsi meet
                                        /// so start call from jitsi meet.
                                        ///
                                        /// if the current system is jitsi meet, then the second system is agora
                                        /// so start call from agora.
                                        ///
                                        checkCallingType(context)
                                            .then((value) async {
                                          if (value == false) {

                                            await AgoraCallService.startAgoraCallFromChat(
                                                    context: context,
                                                    loggedUser: widget.user,
                                                    appointment: widget.appointment
                                            );
                                          } else {
                                            await CallServices.startJitsiCallFromChat(
                                                appointment: widget.appointment,
                                                loggedUser: widget.user,
                                                context: context);
                                          }
                                        });

                                        setState(() {
                                          loadingCall= false;
                                        });

                                      }catch(e){
                                        setState(() {
                                          loadingCall= false;
                                        });
                                        showFailedSnackBar(getTranslated(context, 'failed'));
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      width: AppSize.w81.w,
                                      height: AppSize.h81.h,
                                      child: callingNow
                                          ? Image.asset(
                                              AssetsManager.callGiftPathImage,
                                              width: AppSize.w66_6.r,
                                              height: AppSize.h66_6.r,
                                            )
                                          : Icon(
                                              Icons.wifi_calling,
                                              color: AppColors.pink,
                                              size: 24.0,
                                            ),
                                    ),
                                  ),
                                ),
                              )
                        : SizedBox(),
                    // (widget.user.userType == AppConstants.user &&
                    //         widget.appointment.consultType == "voice" &&
                    //         widget.appointment.appointmentStatus == "open")
                    //     ? ClipRRect(
                    //         borderRadius:
                    //             BorderRadius.circular(AppRadius.r50.r),
                    //         child: Material(
                    //           color: Colors.transparent,
                    //           child: InkWell(
                    //             splashColor: AppColors.white.withOpacity(0.5),
                    //             onTap: () async {
                    //               DocumentReference docRef2 = FirebaseFirestore
                    //                   .instance
                    //                   .collection(Paths.appAppointments)
                    //                   .doc(widget.appointment.appointmentId);
                    //               final DocumentSnapshot documentSnapshot2 =
                    //                   await docRef2.get();
                    //               if (AppAppointments.fromMap(
                    //                       documentSnapshot2.data() as Map)
                    //                   .allowCall)
                    //                 Navigator.push(
                    //                   context,
                    //                   MaterialPageRoute(
                    //                     builder: (context) => AgoraScreen(
                    //                       appointment: widget.appointment,
                    //                       user: widget.user,
                    //                       appointmentId:
                    //                           widget.appointment.appointmentId,
                    //                       consultName:
                    //                           widget.appointment.consult.name,
                    //                     ),
                    //                   ),
                    //                 );
                    //               else
                    //                 agoraCall();
                    //               Fluttertoast.showToast(
                    //                 msg: getTranslated(context, "callNotStart"),
                    //                 toastLength: Toast.LENGTH_LONG,
                    //                 gravity: ToastGravity.TOP,
                    //                 timeInSecForIosWeb: 5,
                    //                 backgroundColor: AppColors.red,
                    //                 textColor: AppColors.white,
                    //                 fontSize: AppFontsSizeManager.s16.sp,
                    //               );
                    //             },
                    //             child: Container(
                    //               decoration: BoxDecoration(
                    //                 color: Colors.transparent,
                    //               ),
                    //               width: AppSize.w50.w,
                    //               height: AppSize.h50.h,
                    //               child: checkCall
                    //                   ? Image.asset(
                    //                       AssetsManager.callGiftPathImage,
                    //                       width: AppSize.w50.w,
                    //                       height: AppSize.h50.h,
                    //                     )
                    //                   : Icon(
                    //                       Icons.wifi_calling,
                    //                       color: AppColors.pink,
                    //                       size: 24.0,
                    //                     ),
                    //             ),
                    //           ),
                    //         ),
                    //       )
                    //     : SizedBox(),
                  ],
                ),
              ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey,
                  height: AppSize.h2.h,
                  width: AppSize.w570.w)),
          SizedBox(
            height: AppSize.h10.h,
          ),
          widget.user.userType == AppConstants.consultant
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    endingCall
                        ? CircularProgressIndicator()
                        :
                    IconButton(
                            onPressed: () {
                              confirmEndCallDialog(
                                context: context,
                                loggedUser: widget.user,
                                appointment: widget.appointment,
                              );
                            },
                            icon: Icon(Icons.check_box_outline_blank)),
                    // Checkbox(
                    //         value: answered,
                    //         onChanged: (value) {
                    //           setState(() {
                    //             answered = !answered;
                    //             if (answered) {
                    //               callDone();
                    //               // accountBloc.add(GetLoggedUserEvent(widget.user.uid));
                    //             }
                    //           });
                    //         },
                    //       ),
                    Text(
                      getTranslated(context, "closeAppointment"),
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithra'),
                        fontSize: AppFontsSizeManager.s20.sp,
                        color: AppColors.pink,
                      ),
                    ),
                  ],
                )
              : SizedBox(),
          SizedBox(
            height: AppSize.h10,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                refreshChangeListener.refreshed = true;
              },
              child: StreamBuilder(
                stream: UserDataProvider.realtimeDbRef
                    .child(
                        'appointmentsChatMessage/${widget.appointment.appointmentId}')
                    .orderByChild('messageTime')
                    .onValue,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.data == null || !snapshot.hasData) {
                    return Center(
                      child: Text(getTranslated(context, "sendFirstMessage"),
                      style: TextStyle(
                        fontFamily:getTranslated(context, "Ithra"),
                      ),
                      ),
                    );
                  } else if ((snapshot.data! as DatabaseEvent).snapshot.value ==
                      null) {
                    return Center(
                      child: Text(getTranslated(context, "sendFirstMessage"),
                        style: TextStyle(
                          fontFamily:getTranslated(context, "Ithra"),
                        ),),
                    );
                  } else {
                    List<dynamic> messages = Map<String, dynamic>.from(
                            (snapshot.data! as DatabaseEvent).snapshot.value
                                as Map<dynamic, dynamic>)
                        .values
                        .toList()
                      ..sort((a, b) =>
                          a['messageTime'].compareTo(b['messageTime']));

                    messages = messages.reversed.toList();
                    return ListView.builder(
                      shrinkWrap: true,
                      reverse: true,
                      padding: EdgeInsets.zero,
                      controller: listScrollController,
                      itemCount: messages.length,
                      itemBuilder: (ctx, index) => AppointChatMessageItem(
                          message: SupportMessage.fromDatabase(
                            Map<String, dynamic>.from(messages[index]),
                          ),
                          user: widget.user),
                    );
                  }
                },
              ),
            ),
          ),
          widget.appointment.appointmentStatus != "closed"
              ? Container(height: AppSize.h81.h, child: buildInput(size))
              : SizedBox(),
        ],
      ),
    );
  }


  Widget buildInput(Size size) {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: AppMargin.m1),
              child: new IconButton(
                icon: new Icon(
                  Icons.image,
                  color: AppColors.pink,
                ),
                onPressed: () => cropImage(context),
                color: theme == "light"
                    ? Theme.of(context).primaryColor
                    : AppColors.pureBlack,
              ),
            ),
            color: AppColors.white,
          ),
          // Button send video
          uploadVideo
              ? Container(
                  height: AppSize.h33.h,
                  width: AppSize.w33.w,
                  child: CircularProgressIndicator(),
                )
              : Material(
                  child: new Container(
                    margin: new EdgeInsets.symmetric(horizontal: AppMargin.m1),
                    child: new IconButton(
                      icon: new Icon(
                        Icons.video_camera_front_outlined,
                        color: AppColors.pink,
                      ),
                      onPressed: () => uploadToStorage(context),
                      color: theme == "light"
                          ? Theme.of(context).primaryColor
                          : AppColors.white,
                    ),
                  ),
                  color: AppColors.white,
                ),
          // audioRecorder
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                elevation: 10,
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) => Container(
                  height: AppSize.h200.h,
                  decoration: BoxDecoration(
                    color: AppColors.grey9,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: AudioRecorder(
                    onSendMessage: onSendMessage,
                    //  theme: "light",
                    focusNode: focusNode,
                    loggedId: FirebaseAuth
                        .instance.currentUser!.uid, //widget.user.uid!
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.mic,
              color: Theme.of(context).primaryColor,
            ),
            color: Theme.of(context).primaryColor,
          ),
          // Edit text
          Flexible(
            child: Container(
              child: ValueListenableBuilder<String>(
                valueListenable: text,
                builder: (context, value, child) => Directionality(
                  textDirection: intl.Bidi.detectRtlDirectionality(text.value)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: TextField(
                    enableInteractiveSelection: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: TextStyle(
                        color: theme == "light"
                            ? Theme.of(context).primaryColor
                            : AppColors.pureBlack,
                        fontFamily: getTranslated(context, "Ithra"),
                        fontSize: AppFontsSizeManager.s20.sp),
                    controller: textEditingController,
                    decoration: InputDecoration.collapsed(
                      hintText: getTranslated(context, "typeMessage"),
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    focusNode: focusNode,
                    onChanged: (str) {
                      text.value = str;
                    },
                  ),
                ),
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: AppMargin.m8),
              child: loading
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      height: AppSize.h56.r,
                      width: AppSize.w56.r,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Center(
                        child: new IconButton(
                          icon: new Icon(
                            Icons.send,
                            color: AppColors.white,
                            size: 20,
                          ),
                          onPressed: () => onSendMessage(
                            textEditingController.text,
                            "text",
                            size,
                          ),
                          color: theme == "light"
                              ? Theme.of(context).primaryColor
                              : AppColors.pureBlack,
                        ),
                      ),
                    ),
            ),
            color: AppColors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: AppSize.h50.h,
      decoration: new BoxDecoration(
          border: new Border(
              top: new BorderSide(color: Colors.grey, width: AppSize.w0_5.w)),
          color: AppColors.white),
    );
  }

  Future cropImage(context) async {
    setState(() {
      loading = true;
    });
    image = await ImagePicker().pickImage(source: ImageSource.gallery);
    File croppedFile = File(image.path);

    if (croppedFile != null) {
      sendMassageDialoge(context, size, croppedFile);

      setState(() {
        selectedProfileImage = croppedFile;
      });
    } else {}
  }

  sendMassageDialoge(BuildContext context, Size size, File file) {
    return showDialog(
      builder: (context) => DreamDialogsWidget(
        dialogContent: Column(
          children: <Widget>[
            Padding(
              padding:
                  EdgeInsets.only(right: AppSize.w10_6.w, top: AppSize.h10_6.h),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSize.h24.h),
                    child: Container(
                      child: Image.file(
                        file,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSize.w32.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Image.asset(
                            AssetsManager.pink_cancel_iconPath,
                            width: AppSize.w50.w,
                            height: AppSize.h50.h,
                            // color: AppColors.linear2,
                          ),
                        ),
                        Spacer(),
                        load
                            ? CircularProgressIndicator(
                                color: AppColors.linear2,
                              )
                            : InkWell(
                                onTap: () async {
                                  uploadImage(file);
                                  Navigator.pop(context);
                                },
                                child: Image.asset(
                                  AssetsManager.send_iconPath,
                                  width: AppSize.w50.w,
                                  height: AppSize.h50.h,
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  Future uploadImage(File image) async {
    size = MediaQuery.of(context).size;
    setState(() {
      load = true;
    });
    var uuid = Uuid().v4();
    Reference storageReference =
        FirebaseStorage.instance.ref().child('profileImages/$uuid');
    await storageReference.putFile(image);

    var url = await storageReference.getDownloadURL();
    onSendMessage(url, "image", size);
    setState(() {
      load = false;
    });
  }

  Future uploadToStorage(context) async {
    try {
      setState(() {
        uploadVideo = true;
      });
      final pickedFile =
          await ImagePicker.platform.pickVideo(source: ImageSource.gallery);
      final file = File(pickedFile!.path);
      var uuid = Uuid().v4();
      Reference storageReference =
          FirebaseStorage.instance.ref().child('files/$uuid');
      await storageReference.putFile(file);
      var url = await storageReference.getDownloadURL();
      onSendMessage(url, "video", size);
    } catch (error) {}
  }

  Future<void> onSendMessage(String content, String type, Size size) async {
    if (content.trim() != '') {
      textEditingController.clear();
      String messageId = Uuid().v4();
      await UserDataProvider.realtimeDbRef
          .child(
              "appointmentsChatMessage/${widget.appointment.appointmentId}/$messageId")
          .set({
        'type': type,
        'owner': widget.user.userType,
        'message': content,
        'messageTime': ServerValue.timestamp,
        'messageTimeUtc': DateTime.now().toUtc().toString(),
        'ownerName': widget.user.name,
        'userUid': widget.user.uid,
        'appointmentId': widget.appointment.appointmentId,
        'isReceived': false,
        'isRead': false,
      });

      String data = getTranslated(context, "attatchment");
      if (type == "text") data = content;
      if (widget.user.userType == AppConstants.consultant) {
        await FirebaseFirestore.instance
            .collection(Paths.appAppointments)
            .doc(widget.appointment.appointmentId)
            .set({
          'consultChat': FieldValue.increment(1),
        }, SetOptions(merge: true));
        sendNotification(widget.appointment.user.uid!, data);
      } else {
        await FirebaseFirestore.instance
            .collection(Paths.appAppointments)
            .doc(widget.appointment.appointmentId)
            .set({
          'userChat': FieldValue.increment(1),
        }, SetOptions(merge: true));
        sendNotification(widget.appointment.consult.uid!, data);
      }

      //listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      setState(() {
        loading = false;
        uploadVideo = false;
      });
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Future<void> callDone() async {
    try {
      setState(() {
        endingCall = true;
      });
      //closeAppointment
      await FirebaseFirestore.instance
          .collection(Paths.appAppointments)
          .doc(widget.appointment.appointmentId)
          .update({
        'appointmentStatus': "closed",
        'allowCall': false,
        'closedUtcTime': DateTime.now().toUtc().toString(),
        'closedDate': {
          'day': DateTime.now().toUtc().day,
          'month': DateTime.now().toUtc().month,
          'year': DateTime.now().toUtc().year,
        },
      });
      //closing
      setState(() {
        endingCall = false;
      });
      Navigator.pop(context);
    } catch (e) {
      errorLog("callDone", e.toString());
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
      'phone': widget.user == null ? " " : widget.user.phoneNumber,
      'screen': "AppointmentChatScreen",
      'function': function,
    });
  }

  Future<void> sendNotification(String userId, String text) async {
    try {
      Map notifMap = Map();
      notifMap.putIfAbsent('title', () => "Chat");
      notifMap.putIfAbsent('body', () => text);
      notifMap.putIfAbsent('userId', () => userId);
      notifMap.putIfAbsent(
          'appointmentId', () => widget.appointment.appointmentId);
      var refundRes = await http.post(
        Uri.parse(
            'https://us-central1-dream-43bb8.cloudfunctions.net/sendChatNotification'),
        body: notifMap,
      );
    } catch (e) {}
  }

  // Future<void> sendNotification(String userId,String from, String text) async {
  //   try {
  //     // Map notifMap = Map();
  //     // notifMap.putIfAbsent('title', () => "Chat");
  //     // notifMap.putIfAbsent('body', () => text);
  //     // notifMap.putIfAbsent('userId', () => userId);
  //     // notifMap.putIfAbsent(
  //     //     'appointmentId', () => widget.appointment.appointmentId);
  //     // var refundRes = await http.post(
  //     //   Uri.parse(
  //     //       'https://us-central1-dream-43bb8.cloudfunctions.net/sendChatNotification'),
  //     //   body: notifMap,
  //     // );
  //     final DocumentSnapshot<Map<String, dynamic>> documentSnapshotUser =
  //     await FirebaseFirestore.instance
  //         .collection(Paths.usersPath)
  //         .doc(userId)
  //         .get();
  //     await sendFCMCallNotification(documentSnapshotUser['tokenId'],from,text);
  //   } catch (e) {}
  // }
  //
  // Future<void> sendFCMCallNotification(String fcmToken,String from,String body) async {
  //   print(fcmToken);
  //   try {
  //     var url = Uri.parse("https://fcm.googleapis.com/fcm/send");
  //     var headers = {
  //       "Content-Type": "application/json",
  //       "Authorization": "key=AAAAaxdDyuI:APA91bEFzOLnGXFJOtnz45L9b1lMeOrvt8QEzBZllY7aGKr7ui9rYHnwPRQQGEAt0awNTINr6_Z8qH036AJjzvZJTLJ5_qWZuC9Znt99dCS_B5mVmgnAcBilu6j-f2K4qdLJgrW38wCa",
  //     };
  //     var message = {
  //       "to": fcmToken,
  //       "priority": "high",
  //       "notification": {
  //         "title": "${getTranslated(context, "message")} $from",
  //         "body": body,
  //         "channel_id": "new-support_channel",
  //         "sound": "default",
  //         "vibrate_timings": [0, 1000, 500, 1000, 500],
  //         "default_vibrate_timings": true,
  //         "default_sound": true,
  //         "importance": "high",
  //         "visibility": "public",
  //         "notification_count": 1,
  //       }
  //     };
  //     var response = await http.post(url, headers: headers, body: jsonEncode(message));
  //     if (response.statusCode == 200) {
  //       print("FCM call notification sent successfully!");
  //     } else {
  //       print("Error sending FCM call notification: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("Error sending FCM call notification: $e");
  //   }
  // }

  showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: getTranslated(context, "loading"),
        );
      },
    );
  }

  Future<void> sendCallNotification(
      String consultName, String userId, String appointmentId) async {
    try {
      Map notifMap = Map();
      notifMap.putIfAbsent('consultName', () => consultName);
      notifMap.putIfAbsent('userId', () => userId);
      notifMap.putIfAbsent('appointmentId', () => appointmentId);
      var refundRes = await http.post(
        Uri.parse(
            'https://us-central1-dream-43bb8.cloudfunctions.net/sendCallingNotification'),
        body: notifMap,
      );
      var refund = jsonDecode(refundRes.body);
      if (refund['message'] != 'Success') {
      } else {}
    } catch (e) {}
  }
}
