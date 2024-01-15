// import 'package:flutter/material.dart';
// import 'package:grocery_store/localization/localization_methods.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// Future<bool> checkNotificationPermission(BuildContext context) async {
//   final status = await Permission.notification.status;
//   if (status.isGranted) {
//     // صلاحية ممنوحة
//     return true;
//   } else if (status.isDenied || status.isPermanentlyDenied) {
//     // الصلاحية غير ممنوحة
//     final isShown = await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(getTranslated(context, "notificationPermission"),style: TextStyle(fontFamily: getTranslated(context, "fontFamily"))),
//           content: Text(getTranslated(context, "notificationPermissionBody"),style: TextStyle(fontFamily: getTranslated(context, "fontFamily"))),
//           actions: <Widget>[
//             TextButton(
//               child: Text(getTranslated(context, "cancel"),style: TextStyle(fontFamily: getTranslated(context, "fontFamily"))),
//               onPressed: () {
//                 Navigator.of(context).pop(false);
//                 checkNotificationPermission(context);
//               },
//             ),
//             ElevatedButton(
//               child: Text(getTranslated(context, "givePermission"),style: TextStyle(fontFamily: getTranslated(context, "fontFamily"))),
//               onPressed: () async {
//                 Navigator.of(context).pop(true);
//                 Permission.notification.request().then((permission) {
//                 if (permission == 'granted' || permission == 'PermissionStatus.denied' || permission == 'denied') {
//                 } else {
//                 checkNotificationPermission(context);
//                 }
//                 });
//               },
//             ),
//           ],
//         );
//       },
//     );
//     return isShown ?? false;
//   } else {
//     return false;
//   }
// }