// // import 'package:flutter_callkeep/flutter_callkeep.dart';
// import 'package:flutter_callkeep/flutter_callkeep.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class CallServiceKeep {
//
// static Future<void> displayIncomingCall( Map <String, dynamic> data) async {
//   SharedPreferences _prefs = await SharedPreferences.getInstance();
//   String? langCode= await _prefs.getString('languageCode');
//
//   var backgroundurl="https://firebasestorage.googleapis.com/v0/b/app-jeras.appspot.com/o/nouserphoto.png?alt=media&token=8e71818d-9c67-4352-81c8-2c27872d32c6";
//   var defulatavater="https://firebasestorage.googleapis.com/v0/b/app-jeras.appspot.com/o/nouserphoto.png?alt=media&token=8e71818d-9c67-4352-81c8-2c27872d32c6";
//   final config = CallKeepIncomingConfig(
//
//     uuid: data['appointmentId'],
//     callerName: data['callerName'],
//     appName: 'Dream',
//     avatar: (data['callerImg']!=null&&data['callerImg'].toString().isNotEmpty)?data['callerImg'].toString():defulatavater,
//     handle: langCode!=null&&langCode=='ar'?"مكالمة صوتية":langCode == "en"?"Voice Call":langCode =="fr"?"Appel vocal":"Panggilan suara",
//     hasVideo: false,
//     duration: 30000,
//     acceptText:langCode!=null&&langCode=='ar'?"قبول":langCode=="en"? 'Accept':langCode=="fr"?"Accepter":"terima",
//     declineText:langCode!=null&&langCode=='ar'?"رفض":langCode=="en"? 'Decline':langCode=="fr"?"Déclin":"Tolak",
//     missedCallText: langCode!=null&&langCode=='ar'?" مكالمة فائتة":langCode=="en"? 'Missed Calls':langCode=="fr"?"Appels manqués":"Panggilan tidak dijawab",
//     callBackText: 'Call back',
//
//     extra: data,
//     headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
//
//     androidConfig: CallKeepAndroidConfig(
//
//
//
//
//       logo: 'trlogo',
//       showCallBackAction: false,
//       showMissedCallNotification: true,
//
//       notificationIcon: 'trlogo',
//       ringtoneFileName: 'system_ringtone_default',
//       accentColor: '#453B5D',
//       // backgroundUrl: data['callerImg']!=null&& data['callerImg'].toString().isNotEmpty?data['callerImg']: backgroundurl,
//       backgroundUrl: defulatavater,
//       incomingCallNotificationChannelName:langCode!=null&&langCode=='ar'?" مكالمة جديدة": langCode =="en"?'Incoming Calls':langCode=="fr"?"Nouvel appel":"Panggilan baharu",
//       missedCallNotificationChannelName:langCode!=null&&langCode=='ar'?" مكالمة فائتة":langCode=="en"? 'Missed Calls':langCode=="fr"?"Appels manqués":"Panggilan tidak dijawab",
//     ),
//
//     iosConfig: CallKeepIosConfig(
//       iconName: 'callKit_icon',
//       handleType: CallKitHandleType.generic,
//       isVideoSupported: true,
//       maximumCallGroups: 2,
//       maximumCallsPerCallGroup: 1,
//       audioSessionActive: true,
//       audioSessionPreferredSampleRate: 44100.0,
//       audioSessionPreferredIOBufferDuration: 0.005,
//       supportsDTMF: true,
//       supportsHolding: true,
//       supportsGrouping: false,
//       supportsUngrouping: false,
//       ringtoneFileName: 'system_ringtone_default',
//
//     ),
//   );
//   print("////////////////");
//   print(data);
//   print("////////////////");
//     await CallKeep.instance.displayIncomingCall(config);
//
//     // config and uuid are the only required parameters
//     // final config2 = CallKeepOutgoingConfig.fromBaseConfig(
//     //   config: CallKeepBaseConfig(
//     //     appName: 'Jeras',
//     //
//     //     acceptText: 'Accept',
//     //     declineText: 'Decline',
//     //     missedCallText: 'Missed call',
//     //     callBackText: 'Call back',
//     //     headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
//     //     androidConfig: CallKeepAndroidConfig(
//     //       logo: "logo",
//     //       showCallBackAction: false,
//     //       showMissedCallNotification: true,
//     //       notificationIcon: 'ic_stat_name',
//     //       ringtoneFileName: 'system_ringtone_default',
//     //       accentColor: '#ffffff',
//     //       backgroundUrl: data['callerImg']!=null&& data['callerImg'].toString().isNotEmpty?data['callerImg']: 'assets/images/appLogo.png',
//     //       incomingCallNotificationChannelName: 'Incoming Calls',
//     //       missedCallNotificationChannelName: 'Missed Calls',
//     //     ),
//     //     iosConfig: CallKeepIosConfig(
//     //       iconName: 'CallKitLogo',
//     //       handleType: CallKitHandleType.generic,
//     //       isVideoSupported: true,
//     //       maximumCallGroups: 2,
//     //       maximumCallsPerCallGroup: 1,
//     //       audioSessionActive: true,
//     //       audioSessionPreferredSampleRate: 44100.0,
//     //       audioSessionPreferredIOBufferDuration: 0.005,
//     //       supportsDTMF: true,
//     //       supportsHolding: true,
//     //       supportsGrouping: false,
//     //       supportsUngrouping: false,
//     //       ringtoneFileName: 'system_ringtone_default',
//     //     )),
//     //   uuid: data['appointmentId'],
//     //   handle: "handle",
//     //   hasVideo:true,
//     // );
//     //
//     // CallKeep.instance.startCall(config2);
//   // Config and uuid are the only required parameters
// // Config and uuid are the only required parameters
//
//   await CallKeep.instance.displayIncomingCall(config);
//
//   }
// }