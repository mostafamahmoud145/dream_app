import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/services/call_kit_service.dart';
import 'package:grocery_store/services/call_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/paths.dart';
import '../main.dart';
import '../models/AppAppointments.dart';
import '../models/user.dart';
import '../screens/AgoraScreen.dart';
import '../screens/AppointmentChatScreen.dart';
import '../screens/addReviewScreen.dart';
import '../screens/generalNotificationScreen.dart';
import '../screens/home_screen.dart';
import '../screens/payInfo1Screen.dart';

dynamic notificationData;
 FirebaseDatabase database =  FirebaseDatabase.instanceFor(app:Firebase.app(),databaseURL: 'https://dream-43bb8-f2c7f.europe-west1.firebasedatabase.app');
 final realtimeDbRef = database.ref();

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
RemoteNotification? value;
BuildContext? _context;
class FirebaseService {


  static init(context, uid, User currentUser) async{
    _context=context;
    initDynamicLinks(context);
    await updateFirebaseToken(currentUser);
    //initFCM(uid, context, currentUser);
    configureFirebaseListeners(context, currentUser);
  }
}

initDynamicLinks(context) async {
  // PendingDynamicLinkData? data =
  // await FirebaseDynamicLinks.instance.getInitialLink();
  // Uri? deepLink = data?.link;

  // if (deepLink != null) {







  // var tempLink = deepLink.queryParameters['${Config().urlPrefix}/'];
  // String pid = deepLink.toString().split('${Config().urlPrefix}/')[1];

  /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductScreen(
          productId: pid,
        ),
      ),
    );*/
  // }

  // FirebaseDynamicLinks.instance.onLink;
  /* FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData dynamicLink) async {
        Uri deepLink = dynamicLink?.link;

        if (deepLink != null) {

          //     .split('${Config().urlPrefix}/')[1]);

          // var tempLink = deepLink.queryParameters['${Config().urlPrefix}/'];
          String pid = deepLink.toString().split('${Config().urlPrefix}/')[1];

          *//* Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductScreen(
                productId: pid,
              ),
            ),
          );*//*
        }
      }, onError: (OnLinkErrorException e) async {
  });*/
}

//FCM
Future<void> updateFirebaseToken(User currentUser) async{
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  /// requesting permission for [alert], [badge] & [sound]. Only for iOS
  await firebaseMessaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  firebaseMessaging.getToken().then((token) async{
    await FirebaseFirestore.instance.collection('Users').doc(currentUser.uid).update({
      'tokenId': token,
    });

    await FirebaseFirestore.instance.collection('NotRegisteredUsers')
        .where('token', isEqualTo: token).get().then((value) {

      if (value.docs.length > 0){

        FirebaseFirestore.instance.collection('NotRegisteredUsers')
            .doc(value.docs[0].data()['userId']).delete();
      }
    });
  });
}

initFCM(String uid, context, User currentUser) async {
  // flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel channel = AndroidNotificationChannel(
      'call_channel', // id
      'call_channel', // title
      importance: Importance.max,
      vibrationPattern: Int64List.fromList([4]),


      playSound: true,
      sound:RawResourceAndroidNotificationSound('jeraston')
  );


  await flutterLocalNotificationsPlugin
      ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  var android = new AndroidInitializationSettings('grocery');
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String? langCode= await _prefs.getString('languageCode');//('grocery');
  var ios =  DarwinInitializationSettings(

      notificationCategories:[DarwinNotificationCategory("Call",
          actions:[
            DarwinNotificationAction.plain('Accept', langCode !=null&&langCode!=null&&langCode=='ar'?"متابعه الاتصال": "Continue Call",options:{
              DarwinNotificationActionOption.foreground,
            }),
            // DarwinNotificationAction.plain('Dicline',  langCode !=null&&langCode=='ar'?'رفض':"Dicline",options:{
            //   DarwinNotificationActionOption.destructive,
            // })

          ]

      )]
  ) ;
  var initSetting = new InitializationSettings(iOS: ios, android: android);
  flutterLocalNotificationsPlugin?.initialize(
      initSetting,
      onDidReceiveBackgroundNotificationResponse:onSelectNotification,
      onDidReceiveNotificationResponse:onSelectNotification

  );
}
@pragma('vm:entry-point')
Future<void> onSelectNotification(NotificationResponse? payload) async {

  if(payload!.actionId=='accept'){

    realtimeDbRef.child('userCallState').child(FirebaseAuth.instance.currentUser!.uid).child('acceptState').set('accepted');

  }

  if(value!=null){

    navigation(value!.title, value!.body, value!.titleLocKey, value!.bodyLocKey);
  }
}


// checkNotificationPermission({required String appointmentId})async{
//
//   Permission.notification.status.asStream().listen((value) async{
//     if(value.isGranted){
//       await FirebaseDatabase.instance.ref('callNotifications')
//           .child(appointmentId).child('notificationState').set('received');
//
//     }else if(value.isDenied || value.isPermanentlyDenied){
//       await FirebaseDatabase.instance.ref('callNotifications')
//           .child(appointmentId).child('notificationState').set('blocked');
//     }
//   });
// }



configureFirebaseListeners(context, User currentUser) async {

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  //app is terminated
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if(message!=null&&message.notification!=null)
      navigation(message.notification!.title, message.notification!.body,message.notification!.titleLocKey, message.notification!.bodyLocKey);
  });

  //App is in foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {

    if(message!.data['type']=='Call'){
      await Firebase.initializeApp();
      // // checkNotificationPermission(appointmentId: message.data['appointmentId']);
      callKitEvents();
      //CallServiceKeep.displayIncomingCall(message.data);
      CallKitService.displayIncomingCall(message.data);
    }

    if (message != null&&message.notification!=null && message.data['type'] != 'Call') {
      print("SHOWNOTIFI_1");
      RemoteNotification notification = message.notification!;
      String? title= message.notification!.title;
      String? body= message.notification!.body;
      //AndroidNotification? android = message.notification?.android!;
        showNotification(title: title, body: body);
      print("SHOWNOTIFI_2");

    }
  });
  // App is in background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
    print("SHOWNOTIFI_3");


    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        navigation(message.notification!.title, message.notification!.body,
            message.notification!.titleLocKey, message.notification!.bodyLocKey);
      }
    });

  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    //'This channel is used for important notifications.', // description
    importance: Importance.max,playSound: true,sound:  RawResourceAndroidNotificationSound('soundandroid'),
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =new FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);




}

/// check the sender cancel the call.
checkIfTheSenderCanceled() async{
  await Firebase.initializeApp();
  FirebaseDatabase.instance.ref('userCallState')
      .child(FirebaseAuth.instance.currentUser!.uid).child('callState').onValue
      .listen((event) {
    if(event.snapshot.value=='closed'){
      FlutterCallkitIncoming.endAllCalls();
      //CallKeep.instance.endAllCalls();
    }
  });
}

callKitEvents(){
  /*CallKeep.instance.onEvent.listen((event) async {
    // TODO: Implement other events
    if (event == null) return;
    switch (event.type) {
      case CallKeepEventType.callIncoming:
        checkIfTheSenderCanceled();
        break;
      case CallKeepEventType.callAccept:
        mayAppCheckCall(contexts: _context);
        break;
      case CallKeepEventType.callDecline:
        // final data = event.data as CallKeepCallData;
        // print('call declined: ${data.toMap()}');
        await Firebase.initializeApp();
        final data = event.data as CallKeepCallData;
        CallKeep.instance.endAllCalls();
        CallServices.refuseCall(withNavigatorBack: false, state: 'refused', callerId: data.extra!['callerId']);
        break;
      case CallKeepEventType.callTimedOut:
      // final data = event.data as CallKeepCallData;
      // print('call declined: ${data.toMap()}');
        await Firebase.initializeApp();
        final data = event.data as CallKeepCallData;
        CallKeep.instance.endAllCalls();
        CallServices.refuseCall(withNavigatorBack: false, state: 'closed', callerId: data.extra!['callerId']);
        break;
      default:
        break;
    }
  });*/
  FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      switch (event!.event) {
        case Event.actionCallIncoming:
          checkIfTheSenderCanceled();
          break;
        case Event.actionCallStart:
        // TODO: started an outgoing call
        // TODO: show screen calling in Flutter
           break;
        case Event.actionCallAccept:
           mayAppCheckCall(contexts: _context);
           break;
        case Event.actionCallDecline:
          await Firebase.initializeApp();
          Map<String, dynamic> data = event.body;
          FlutterCallkitIncoming.endAllCalls();
          CallServices.refuseCall(withNavigatorBack: false, state: 'refused', callerId: data['extra']['callerId']);
          break;
        case Event.actionCallEnded:
        // TODO: ended an incoming/outgoing call
          break;
        case Event.actionCallTimeout:
          await Firebase.initializeApp();
          Map<String, dynamic> data = event.body;
          FlutterCallkitIncoming.endAllCalls();
          CallServices.refuseCall(
              withNavigatorBack: false,
              state: 'closed',
              callerId: data['extra']['callerId']);
          break;
        case Event.actionCallCallback:
        // TODO: only Android - click action `Call back` from missed call notification
          break;
        case Event.actionCallToggleHold:
        // TODO: only iOS
          break;
        case Event.actionCallToggleMute:
        // TODO: only iOS
          break;
        case Event.actionCallToggleDmtf:
        // TODO: only iOS
          break;
        case Event.actionCallToggleGroup:
        // TODO: only iOS
          break;
        case Event.actionCallToggleAudioSession:
        // TODO: only iOS
          break;
        case Event.actionDidUpdateDevicePushTokenVoip:
        // TODO: only iOS
          break;
        case Event.actionCallCustom:
        // TODO: for custom action
          break;
      }
    });


  /*FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async{

    switch (event!.event) {
      case Event.actionCallIncoming:
      /// received an incoming call4
      //  await Firebase.initializeApp();
        checkIfTheSenderCanceled();
        break;
      case Event.actionCallStart:
      // TODO: started an outgoing call
      // TODO: show screen calling in Flutter
        break;
      case Event.actionCallAccept:
      /// accepted an incoming call
      /// show screen calling in Flutter
      ///
        mayAppCheckCall();

        break;
      case Event.actionCallDecline:
      /// declined an incoming call

      //  await Firebase.initializeApp();
        Map<String, dynamic> data= event.body;
        FlutterCallkitIncoming.endAllCalls();
        CallServices.refuseCall(withNavigatorBack: false, state: 'refused', callerId: data['extra']['callerId']);

        break;
      case Event.actionCallEnded:
      // TODO: ended an incoming/outgoing call
        break;
      case Event.actionCallTimeout:
      /// missed an incoming call
      ///
       // await Firebase.initializeApp();
        Map<String, dynamic> data= event.body;
        FlutterCallkitIncoming.endAllCalls();
        CallServices.refuseCall(withNavigatorBack: false, state: 'closed', callerId: data['extra']['callerId']);
        break;
      case Event.actionCallCallback:
      // TODO: only Android - click action `Call back` from missed call notification
        break;
      case Event.actionCallToggleHold:
      // TODO: only iOS
        break;
      case Event.actionCallToggleMute:
      // TODO: only iOS
        break;
      case Event.actionCallToggleDmtf:
      // TODO: only iOS
        break;
      case Event.actionCallToggleGroup:
      // TODO: only iOS
        break;
      case Event.actionCallToggleAudioSession:
      // TODO: only iOS
        break;
      case Event.actionDidUpdateDevicePushTokenVoip:
      // TODO: only iOS
        break;
      case Event.actionCallCustom:
      // TODO: for custom action
        break;
    }
  });*/
}

// showCallnotfication(notidata,bool iscall)
// async {
//   if(iscall){
//     http.Response response = await http.get(Uri.parse(notidata['userimg']));
//
//     var _base64 = base64Encode(response.bodyBytes);
//     final Int64List vibrationPattern = Int64List(4);
//     vibrationPattern[0] = 0;
//     vibrationPattern[1] = 4000;
//     vibrationPattern[2] = 4000;
//     vibrationPattern[3] = 4000;
//     SharedPreferences _prefs = await SharedPreferences.getInstance();
//     String? langCode= await _prefs.getString('languageCode');
//     flutterLocalNotificationsPlugin =new FlutterLocalNotificationsPlugin();
//     var aNdroid = new AndroidNotificationDetails(
//         'call_channel',
//         'call_channel',
//         //'desc',
//         icon:'grocery',
//
//         autoCancel: false,
//         fullScreenIntent: true,
//         vibrationPattern: vibrationPattern,
//         largeIcon: ByteArrayAndroidBitmap.fromBase64String(_base64.toString()),
//         actions:iscall? <AndroidNotificationAction>[
//           AndroidNotificationAction('accept', langCode!=null&&langCode=='ar'?"متابعه الاتصال": "Continue Call",showsUserInterface: true),
//           // AndroidNotificationAction('accept', langCode!=null&&langCode=='ar'?"قبول": "Accept",showsUserInterface: true),
//           // AndroidNotificationAction('dissmis',    langCode!=null&&langCode=='ar'?"رفض":"Dicline",showsUserInterface: true),
//         ]:[],
//         importance: Importance.high,  priority: Priority.high,playSound: true,
//         sound: iscall? RawResourceAndroidNotificationSound('jeraston'): RawResourceAndroidNotificationSound('soundandroid'),additionalFlags: Int32List.fromList(<int>[4])
//
//     );
//     var iOS = new DarwinNotificationDetails( sound: 'jeraston.aiff',
//       presentAlert: true,
//       categoryIdentifier: 'Call',
//       presentBadge: true,
//       presentSound: true,);
//     var platform = new NotificationDetails(android: aNdroid, iOS: iOS);
//
//     // value=data;
//     await flutterLocalNotificationsPlugin!.show( 12,
//       notidata['title'],
//       notidata['body'],
//       platform,
//
//     );
//     //staticAudio.newInstance().setupAudio();
//   }else{
//     http.Response response = await http.get(Uri.parse(notidata['userimg']));
//
//     var _base64 = base64Encode(response.bodyBytes);
//     final Int64List vibrationPattern = Int64List(4);
//     vibrationPattern[0] = 0;
//     vibrationPattern[1] = 4000;
//     vibrationPattern[2] = 4000;
//     vibrationPattern[3] = 4000;
//     SharedPreferences _prefs = await SharedPreferences.getInstance();
//     flutterLocalNotificationsPlugin =new FlutterLocalNotificationsPlugin();
//     var aNdroid = new AndroidNotificationDetails(
//         'call_channel',
//         'call_channel',
//         //'desc',
//         icon:'grocery',
//
//         autoCancel: false,
//         fullScreenIntent: true,
//         vibrationPattern: vibrationPattern,
//         largeIcon: ByteArrayAndroidBitmap.fromBase64String(_base64.toString()),
//         actions:iscall? <AndroidNotificationAction>[
//           //AndroidNotificationAction('accept', langCode!=null&&langCode=='ar'?"قبول": "Accept",showsUserInterface: true),
//         //  AndroidNotificationAction('dissmis',    langCode!=null&&langCode=='ar'?"رفض":"Dicline",showsUserInterface: true),
//         ]:[],
//         importance: Importance.high,  priority: Priority.high,playSound: true,
//         sound: iscall? RawResourceAndroidNotificationSound('jeraston'): RawResourceAndroidNotificationSound('soundandroid'),additionalFlags: Int32List.fromList(<int>[4])
//
//     );
//     var iOS = new DarwinNotificationDetails( sound: 'jeraston.aiff',
//       presentAlert: true,
//       categoryIdentifier: 'Call',
//       presentBadge: true,
//       presentSound: true,);
//     var platform = new NotificationDetails(android: aNdroid, iOS: iOS);
//
//     // value=data;
//     await flutterLocalNotificationsPlugin!.show(12,
//       notidata['title'],
//       notidata['body'],
//       platform,
//
//     );
//
//   }
//
// }

showNotification({String? title, String? body})
async {
  print("SHOWNOTIFI_4");

  flutterLocalNotificationsPlugin =new FlutterLocalNotificationsPlugin();
  var aNdroid = new AndroidNotificationDetails(
    'channelId',
    'channel_name',
    //'desc',
    icon:'trlogo',
    autoCancel: true,
    fullScreenIntent: false,
    importance: Importance.high,  priority: Priority.high,playSound: true,sound:  null,

  );
  var iOS = new DarwinNotificationDetails( sound: 'jeraston.aiff',
    presentAlert: true,
    presentBadge: true,
    presentSound: true,);
  var platform = new NotificationDetails(android: aNdroid, iOS: iOS);

  //value=message!.data!;
  int uniqueNumber= Random().nextInt(100);
  await flutterLocalNotificationsPlugin!.show( uniqueNumber,
    title,
    body,
    platform,

  );
  //staticAudio.newInstance().audioPlayerPublic.stop();

}


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler( RemoteMessage message, ) async {
  RemoteNotification? notification = message.notification;
  Map<String,dynamic> data=message.data;



  // if (notification != null && data['type']!= 'Call')
  // {
  //   String? title= message.notification!.title;
  //   String? body= message.notification!.body;
  //   showNotification(title: title, body: body);
  // }

  if (notification == null)
  {
    String? title= data['title'];
    String? body= data['body'];
    if (title !=null ||title !="null"  ){
      //showNotification(title: title, body: body);

    }
  }

  if(data!=null){
    switch(data['type']) {
      case "Call":
        await Firebase.initializeApp();
        // checkNotificationPermission(appointmentId: message.data['appointmentId']);
        callKitEvents();
        checkIfTheSenderCanceled();
        //CallServiceKeep.displayIncomingCall(message.data);
        CallKitService.displayIncomingCall(message.data);


        // showCallnotfication(
        //
        //     message.data,
        //     true
        //
        // );
        //  setupAwosome();
        //   main();
        //    ReceivedAction? initialAction = await AwesomeNotifications()
        //        .getInitialNotificationAction(removeFromActionEvents: false);
        //    createNewNotification(data);
        break;
      case "missedCall" :
        // showCallnotfication(
        //
        //     message.data,
        //     false
        //
        // );
        // ReceivedAction? initialAction = await AwesomeNotifications()
        //     .getInitialNotificationAction(removeFromActionEvents: false);
        // createNewNotification(data);
        break;

    // default:
    //   // showNotification(
    //   //     notification!,
    //   //     false,
    //   //     message.data
    //   //
    //   // );
    //   break;

    }


  }

//   if(data!=null &&data['type']=="Call"){
//
//
//     var payload = data;
//
//    String Appointmentid=payload['appointmentId'];
//    String userId=payload['userId'];
//
//
//    //  _callKeep.displayIncomingCall(Appointmentid, userId,
//    //      localizedCallerName: "testname", hasVideo: true);
//    //  _callKeep.backToForeground();
//
//   }

}





navigation(String? title,String? body,String? titleKey,String? bodyKey) async {
  if((title=="المواعيد"||title=="Appointment")&&titleKey==AppConstants.user){
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) =>
            HomeScreen(notificationPage: 1,),
      ),
    );
  }
  else if((title=="المواعيد"||title=="Appointment")&&titleKey=="consult"){
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) =>
            HomeScreen(notificationPage: 0,),
      ),
    );
  }
  else if(title=="التقيم"||title=="Review"){
    List<String> dateParts = bodyKey!.split(",");
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) =>
            AddReviewScreen(consultId: dateParts[0],userId:titleKey!,appointmentId: dateParts[1],),
      ),
    );
  }
  else if(title=="الدعم الفني"||title=="Technical Support"){
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) =>
            HomeScreen(notificationPage: 2,),
      ),
    );
  }
  else if(title=="رسائل المحادثات"||title=="Chat messages"){
    DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(titleKey);
    final DocumentSnapshot documentSnapshot = await docRef.get();
    var user= GroceryUser.fromMap(documentSnapshot.data() as Map);

    DocumentReference docRef2 = FirebaseFirestore.instance.collection(Paths.appAppointments).doc(bodyKey);
    final DocumentSnapshot documentSnapshot2 = await docRef2.get();
    var appointment = AppAppointments.fromMap(documentSnapshot2.data() as Map);
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) => AppointmentChatScreen(
            appointment: appointment,
            user:user
        ),
      ),
    );

  }
  else if(title=="اتصال"||title=="Calling"){
    DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(titleKey);
    final DocumentSnapshot documentSnapshot = await docRef.get();
    var user= GroceryUser.fromMap(documentSnapshot.data() as Map);

    DocumentReference docRef2 = FirebaseFirestore.instance.collection(Paths.appAppointments).doc(bodyKey);
    final DocumentSnapshot documentSnapshot2 = await docRef2.get();
    var appointment = AppAppointments.fromMap(documentSnapshot2.data() as Map);

    String callerId;
    if(user.userType == AppConstants.user){
      callerId= appointment.consult.uid;
    }else{
      callerId= appointment.user.uid;
    }

    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) => AgoraScreen(
          appointment: appointment ,
          user:user,
          isCaller: false,
          fromChatScreen: true,
          receiverId: user.uid,
          callerId: callerId,
          appointmentId:bodyKey! ,
          consultName: titleKey!,
        ),
      ),
    );

  }
  else if(title=="الحساب"||title=="Account"){
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) => payInfo1Screen(
          consultId: titleKey!,
        ),
      ),
    );

  }
  else{
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) =>
            GeneralNotificationScreen(
                title:title!,
                body:body!,
                image:titleKey,
                link:bodyKey
            ),
      ),
    );
  }
}
