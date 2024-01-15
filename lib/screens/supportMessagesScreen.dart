import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/SupportList.dart';
import 'package:grocery_store/models/SupportMessage.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/providers/user_data_provider.dart';
import 'package:grocery_store/widget/AppointChatMessageItem.dart';
import 'package:grocery_store/widget/chatButtonsWidgetSupport.dart';
import 'package:grocery_store/widget/dreamDialogsWidget.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:uuid/uuid.dart';

import '../FireStorePagnation/bloc/pagination_listeners.dart';
import '../config/colorsFile.dart';
import '../widget/audioRocordingWidget.dart';

var image;
File? selectedProfileImage;

class SupportMessageScreen extends StatefulWidget {
  final SupportList item;
  final GroceryUser user;
  final String? theme;

  const SupportMessageScreen(
      {required this.item, required this.user, this.theme});

  @override
  _SupportMessageScreenState createState() => _SupportMessageScreenState();
}

class _SupportMessageScreenState extends State<SupportMessageScreen> {
  PaginateRefreshedChangeListener refreshChangeListener =
      PaginateRefreshedChangeListener();

  bool loading = false, loadingCall = false, uploadVideo = false;
  String? imageUrl;
  var stCollection = 'messages', theme = "light";
  ValueNotifier<String> text = ValueNotifier("");
  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  bool answered = false, done = true, endingCall = false;
  bool checkAgora = false, load = false;
  final FocusNode focusNode = new FocusNode();
  String mobileNumber = '..';
  bool isRTL = false, first = true, pending = false;
  late Size size;
  String lang = "";

  @override
  void initState() {
    super.initState();
    loading = false;
    pending = widget.item.pending!;
    getUserMobileNumber();
    userReadHisMessage(widget.user.userType!);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  getUserMobileNumber() async {
    DocumentReference userRef = FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(widget.item.userUid);
    final DocumentSnapshot userSnapshot = await userRef.get();
    var phone = GroceryUser.fromMap(userSnapshot.data() as Map).phoneNumber;
    setState(() {
      mobileNumber = phone!;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: endSupport,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          children: <Widget>[
            widget.user.userType == "SUPPORT" ? headerWidget(size) : SizedBox(),
            Visibility(
                visible: widget.user.userType == "SUPPORT",
                child: supportWidget()),
            Visibility(
              visible: widget.user.userType != "SUPPORT",
              child: helpWidget(),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  refreshChangeListener.refreshed = true;
                },
                child: StreamBuilder<DatabaseEvent>(
                  stream: UserDataProvider.realtimeDbRef
                      .child('/SupportMessage/${widget.item.supportListId}')
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
                    } else if ((snapshot.data!).snapshot.value == null) {
                      return Center(
                        child: Text(
                          getTranslated(context, "sendFirstMessage"),
                          style: TextStyle(
                            fontFamily:getTranslated(context, "Ithra"),
                          ),
                        ),
                      );
                    } else {
                      List<dynamic> messages = Map<String, dynamic>.from(
                              (snapshot.data!).snapshot.value
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
            //   buildInput(size),
            chatButtonsWidgetSupport(
              onSendMessage: onSendMessage,
            ),
          ],
        ),
      ),
    );
  }

  /// widgets ///

  headerWidget(Size size) {
    lang = getTranslated((context), "lang");
    return Container(
        width: size.width,
        child: Padding(
          padding: EdgeInsets.only(
            right: AppPadding.p20.w,
            top: AppPadding.p71.h,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /*IconButton1(
            radius: AppRadius.r10_6.r,
            color: AppColors.white,
            shadowcolor: AppColors.warmPurple,
            iconsize: AppSize.w50.r,
            icon: lang == "ar"
                ? AssetsManager.purple_right_arrowPath
                : AssetsManager.purple_left_arrowPath,
            iconcolor: AppColors.linear2,
            onPress: () {
              Navigator.pop(context);
            },
            width: AppSize.w50.w,
            height: AppSize.h50.h,
          ),*/
              widget.user.userType != "SUPPORT"
                  ? Text(
                      getTranslated(context, "tecSupport"),
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithra'),
                        fontSize: AppFontsSizeManager.s26.sp,
                        color: AppColors.pureBlack,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : Column(
                      children: [
                        Text(
                          widget.user.userType == "SUPPORT"
                              ? widget.item.userName == null
                                  ? " "
                                  : widget.item.userName
                              : getTranslated(context, "tecSupport"),
                          style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithra'),
                            fontSize: 21.sp,
                            color: Color.fromRGBO(27, 27, 27, 1),
                            fontWeight: FontWeight.w300,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        Center(
                          child: Text(
                            mobileNumber,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              fontSize: 21.sp,
                              color: Color.fromRGBO(27, 27, 27, 1),
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        )
                      ],
                    ),
              widget.user.userType == "SUPPORT"
                  ? Padding(
                      padding: EdgeInsets.only(top: AppPadding.p20.h),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: AppColors.white.withOpacity(0.6),
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: mobileNumber));
                              showSnack(
                                  getTranslated(context, "copyDone"), context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              width: 38.0,
                              height: 35.0,
                              child: Icon(
                                Icons.copy,
                                color: AppColors.pink,
                                size: 24.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ));
  }

  supportWidget() {
    return Padding(
      padding: EdgeInsets.only(
          right: AppPadding.p20.w,
          left: AppPadding.p20.w,
          top: AppPadding.p16.h,
          bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                value: answered,
                onChanged: (value) {
                  setState(() {
                    answered = !answered;
                    callAnswered();
                  });
                },
              ),
              Text(
                getTranslated(context, "answered"),
                style: TextStyle(
                  fontFamily: getTranslated(context, 'Ithra'),
                  fontSize: 15.0,
                  color: AppColors.grey,
                ),
              ),
              Spacer(),
              OutlinedButton(
                onPressed: () {
                  rateSupport();
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  )),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 20,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 10),
                    Text(
                      getTranslated(context, 'rateUs'),
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithra'),
                        fontSize: 15.0,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                value: pending,
                onChanged: (value) {
                  setState(() {
                    pending = !pending;
                    pendChat();
                  });
                },
              ),
              Text(
                getTranslated(context, "pendChat"),
                style: TextStyle(
                  fontFamily: getTranslated(context, 'Ithra'),
                  fontSize: 15.0,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  helpWidget() {
    return Padding(
      padding: EdgeInsets.only(
          right: AppPadding.p32.w,
          left: 0,
          // top: AppPadding.p64.h,
          bottom: AppPadding.p10_6.h
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: SvgPicture.asset(
              AssetsManager.helpMe,
              width: AppSize.w34_6.w,
              height: AppSize.h34_6.h,
            ),
          ),
          SizedBox(
            width: AppSize.w16.w,
          ),
          Text(
            getTranslated(context, "helpText"),
            style: TextStyle(
              fontFamily: getTranslated(context, 'Ithra'),
              color: AppColors.linear2,
              fontSize: AppFontsSizeManager.s26_6.sp,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
            ),
          )
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
              margin: new EdgeInsets.symmetric(horizontal: 21.w),
              child: new IconButton(
                icon: new Icon(Icons.image),
                onPressed: () => cropImage(context), // getImage(0),
                color: AppColors.linear3,
              ),
            ),
            color: AppColors.white,
          ),
          uploadVideo
              ? Container(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(),
                )
              : Material(
                  child: new Container(
                    margin: new EdgeInsets.symmetric(horizontal: 1.0),
                    child: new IconButton(
                      icon: new Icon(Icons.video_camera_front_outlined),
                      onPressed: () => uploadToStorage(context),
                      color: theme == "light"
                          ? AppColors.linear3
                          : AppColors.white,
                    ),
                  ),
                  color: AppColors.white,
                ),
          //record button
          AudioRecorder(
            onSendMessage: onSendMessage,
            focusNode: focusNode,
            loggedId: widget.user.uid!,
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
                    style: TextStyle(color: AppColors.linear3, fontSize: 15.0),
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
          SizedBox(
            width: AppSize.w25.w,
          ),
          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 10.w),
              child: loading
                  ? Center(child: CircularProgressIndicator())
                  : IconButton(
                      icon: new Icon(
                        Icons.send,
                        color: AppColors.pink,
                        size: 25,
                      ),
                      onPressed: () => onSendMessage(
                          textEditingController.text, "text", size),
                      color: AppColors.linear3,
                    ),
            ),
            color: AppColors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 80.h,
      decoration: new BoxDecoration(
          border: new Border(
              top: new BorderSide(
                  color: Color.fromRGBO(112, 112, 112, 0.28), width: 1.5.w)),
          color: AppColors.white),
    );
  }

  rateSupport() {
    onSendMessage(
        getTranslated(context, "closeSupportChatText"), "closing", size);
  }

  Future cropImage(context) async {
    setState(() {
      loading = true;
    });
    image = await ImagePicker().pickImage(source: ImageSource.gallery);
    File croppedFile = File(image.path);

    sendMassageDialoge(context, size, croppedFile);
    setState(() {
      selectedProfileImage = croppedFile;
    });
    // signupBloc.add(PickedProfilePictureEvent(file: croppedFile));
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
    FocusScope.of(context).unfocus();
    if ((content.trim() != '' && type == "text") || type != "text") {
      textEditingController.clear();
      if (widget.user.userType == "SUPPORT") {
        await FirebaseFirestore.instance
            .collection("SupportList")
            .doc(widget.item.supportListId)
            .set({
          'userMessageNum': FieldValue.increment(1),
          'messageTime': FieldValue.serverTimestamp(),
          'lastMessage': type == "text"
              ? content
              : type == "image"
                  ? "imageFile"
                  : "voiceFile",
        }, SetOptions(merge: true));
      } else
        await FirebaseFirestore.instance
            .collection("SupportList")
            .doc(widget.item.supportListId)
            .set({
          'supportMessageNum': FieldValue.increment(1),
          'supportListStatus': false,
          'userName': widget.user.name,
          'userLang': getTranslated(context, 'lang'),
          'messageTime': FieldValue.serverTimestamp(),
          'lastMessage': type == "text"
              ? content
              : type == "image"
                  ? "imageFile"
                  : "voiceFile",
        }, SetOptions(merge: true));
      String data = getTranslated(context, "attatchment");
      if (type == "text") data = content;
      // send notification
      sendNotification(data, widget.user.name.toString());
      String messageId = Uuid().v4();

      await UserDataProvider.realtimeDbRef
          .child("SupportMessage/${widget.item.supportListId}/$messageId")
          .set({
        'type': type,
        'owner': widget.user.userType,
        'message': content,
        'messageTime': ServerValue.timestamp,
        'messageTimeUtc': DateTime.now().toUtc().toString(),
        'ownerName': widget.user.name,
        'userUid': widget.user.uid,
        'supportId': widget.item.supportListId,
      });

      //listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      setState(() {
        loading = false;
        uploadVideo = false;
      });
    }
  }

  Future uploadRecord(File voice) async {
    size = MediaQuery.of(context).size;

    var uuid = Uuid().v4();
    Reference storageReference =
        FirebaseStorage.instance.ref().child('profileImages/$uuid');
    await storageReference.putFile(voice);

    var url = await storageReference.getDownloadURL();
    onSendMessage(url, "voice", size);
  }

  Future<void> pendChat() async {
    showUpdatingDialog();
    await FirebaseFirestore.instance
        .collection("SupportList")
        .doc(widget.item.supportListId)
        .set({
      'pending': pending,
    }, SetOptions(merge: true));
    Navigator.pop(context);
  }

  Future<void> callAnswered() async {
    showUpdatingDialog();
    await FirebaseFirestore.instance
        .collection("SupportList")
        .doc(widget.item.supportListId)
        .set({
      'supportListStatus': false,
      'supportMessageNum': 0,
    }, SetOptions(merge: true));
    await FirebaseFirestore.instance
        .collection("SupportList")
        .doc(widget.item.supportListId)
        .set({
      'supportListStatus': true,
      'openingStatus': false,
      'supportMessageNum': 0,
    }, SetOptions(merge: true));
    await FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(widget.user.uid)
        .set({
      'answeredSupportNum':
          int.parse(widget.user.answeredSupportNum.toString()) + 1,
    }, SetOptions(merge: true));
    var date = DateTime.now();
    await FirebaseFirestore.instance
        .collection(Paths.supportAnalysisPath)
        .doc(Uuid().v4())
        .set({
      'time': DateTime(date.year, date.month, date.day).millisecondsSinceEpoch,
      'techSupportUser': widget.user.uid,
    }, SetOptions(merge: true));
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Future<void> userReadHisMessage(String type) async {
    try {
      if (type == "SUPPORT")
        await FirebaseFirestore.instance
            .collection("SupportList")
            .doc(widget.item.supportListId)
            .set({
          //'supportMessageNum': 0,
          'openingStatus': true,
        }, SetOptions(merge: true));
      else
        await FirebaseFirestore.instance
            .collection("SupportList")
            .doc(widget.item.supportListId)
            .set({
          'userMessageNum': 0,
        }, SetOptions(merge: true));
    } catch (e) {}
  }

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

  ////===============

  Future<bool> endSupport() async {
    try {
      if (widget.user.userType == "SUPPORT")
        await FirebaseFirestore.instance
            .collection("SupportList")
            .doc(widget.item.supportListId)
            .set({
          'openingStatus': false,
        }, SetOptions(merge: true));
      else
        await FirebaseFirestore.instance
            .collection("SupportList")
            .doc(widget.item.supportListId)
            .set({
          'userMessageNum': 0,
        }, SetOptions(merge: true));
      Navigator.of(context).pop(true);
      return Future.value(true);
    } catch (e) {
      return Future.value(true);
    }
  }

// send notification
  Future<void> sendNotification(
    String text,
    String from,
  ) async {
    // Get reference to collection
    final collectionRef = FirebaseFirestore.instance.collection('Users');

// Build query
    final query = collectionRef.where('userType', isEqualTo: 'SUPPORT');

// Get documents
    QuerySnapshot querySnapshot = await query.get();

// Loop through documents
    for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
      // Extract data as Map
      Map<dynamic, dynamic> data = await documentSnapshot.data() as Map;

      try {
        await sendFCMCallNotification(data['tokenId'], from, text);
      } catch (e) {}
    }
  }

  Future<void> sendFCMCallNotification(
      String fcmToken, String from, String body) async {
    print(fcmToken);
    try {
      var url = Uri.parse("https://fcm.googleapis.com/fcm/send");
      var headers = {
        "Content-Type": "application/json",
        "Authorization":
            "key=AAAAaxdDyuI:APA91bEFzOLnGXFJOtnz45L9b1lMeOrvt8QEzBZllY7aGKr7ui9rYHnwPRQQGEAt0awNTINr6_Z8qH036AJjzvZJTLJ5_qWZuC9Znt99dCS_B5mVmgnAcBilu6j-f2K4qdLJgrW38wCa",
      };
      var message = {
        "to": fcmToken,
        "priority": "high",
        "notification": {
          "title": "new message from $from",
          "body": body,
          "channel_id": "new-support_channel",
          "sound": "default",
          "vibrate_timings": [0, 1000, 500, 1000, 500],
          "default_vibrate_timings": true,
          "default_sound": true,
          "importance": "high",
          "visibility": "public",
          "notification_count": 1,
        }
      };
      var response =
          await http.post(url, headers: headers, body: jsonEncode(message));
      if (response.statusCode == 200) {
        print("FCM call notification sent successfully!");
      } else {
        print("Error sending FCM call notification: ${response.body}");
      }
    } catch (e) {
      print("Error sending FCM call notification: $e");
    }
  }

  void showSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(7),
      backgroundColor: Colors.green.shade500,
      animationDuration: Duration(milliseconds: 300),
      isDismissible: true,
      boxShadows: [AppShadow.primaryShadow],
      shouldIconPulse: false,
      duration: Duration(milliseconds: 2000),
      icon: Icon(
        Icons.error,
        color: AppColors.white,
      ),
      messageText: Text(
        '$text',
        style: GoogleFonts.poppins(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: AppColors.white,
        ),
      ),
    )..show(context);
  }
}
