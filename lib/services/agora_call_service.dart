
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/methods/change_user_call_state.dart';
import 'package:grocery_store/methods/navigation_method.dart';
import 'package:grocery_store/screens/agoraScreen.dart';

import '../config/app_fonts.dart';
import '../config/colorsFile.dart';
import '../config/paths.dart';
import '../localization/localization_methods.dart';
import '../models/AppAppointments.dart';
import '../models/user.dart';

class AgoraCallService {

  static Future<void> startAgoraCallFromChat({
    required BuildContext context,
    required AppAppointments appointment,
    required GroceryUser loggedUser,
  }) async {
    DocumentReference docRef2 = FirebaseFirestore.instance
        .collection(Paths.appAppointments)
        .doc(appointment.appointmentId);
    final DocumentSnapshot documentSnapshot2 = await docRef2.get();
    if (AppAppointments.fromMap(documentSnapshot2.data() as Map).allowCall) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AgoraScreen(
            appointment: appointment,
            user: loggedUser,
            appointmentId: appointment.appointmentId,
            consultName: appointment.consult.name,
            isCaller: false,
            fromChatScreen: true,
          ),
        ),
      );
    } else {
      await FirebaseFirestore.instance
          .collection(Paths.appAppointments)
          .doc(appointment.appointmentId)
          .set({
        'allowCall': true,
      }, SetOptions(merge: true));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AgoraScreen(
              appointment: appointment,
              user: loggedUser,
              appointmentId: appointment.appointmentId,
              isCaller: true,
              fromChatScreen: true,
              consultName: appointment.consult.name),
        ),
      );

    }
    Fluttertoast.showToast(
      msg: getTranslated(context, "callNotStart"),
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 5,
      backgroundColor: AppColors.red,
      textColor: AppColors.white,
      fontSize: AppFontsSizeManager.s16.sp,
    );
  }




  static Future<void> startAgoraCallFromCard({
    required BuildContext context,
    required AppAppointments appointment,
    required GroceryUser loggedUser,
    String? receiverId,
    String? callerId,
  }) async {

    // 1. change current user call state to calling.
    // 2.navigate to agora screen.
    await changeUserState(userId: FirebaseAuth.instance.currentUser!.uid, state: 'calling');

    navigateTo(
      context,
      AgoraScreen(
        appointment: appointment,
        user: loggedUser,
        appointmentId: appointment.appointmentId,
        consultName: appointment.consult.name,
        callerId: callerId,
        isCaller: true,
        fromChatScreen: false,
        receiverId: receiverId,
      ),
    );
    // DocumentReference docRef2 = FirebaseFirestore.instance
    //     .collection(Paths.appAppointments)
    //     .doc(appointment.appointmentId);
    // final DocumentSnapshot documentSnapshot2 = await docRef2.get();
    // if (AppAppointments.fromMap(documentSnapshot2.data() as Map).allowCall)
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => AgoraScreen(
    //         appointment: appointment,
    //         user: loggedUser,
    //         appointmentId: appointment.appointmentId,
    //         consultName: appointment.consult.name,
    //         callerId: callerId,
    //         isCaller: isCaller,
    //         fromChatScreen: fromChatScreen,
    //         receiverId: receiverId,
    //       ),
    //     ),
    //   );
    // else
    //   await agoraCall(
    //       appointment: appointment,
    //       loggedUser: loggedUser,
    //       context: context,
    //       callerId: callerId,
    //       receiverId: receiverId,
    //       fromChatScreen: fromChatScreen,
    //       isCaller: isCaller
    //   );
    // Fluttertoast.showToast(
    //   msg: getTranslated(context, "callNotStart"),
    //   toastLength: Toast.LENGTH_LONG,
    //   gravity: ToastGravity.TOP,
    //   timeInSecForIosWeb: 5,
    //   backgroundColor: AppColors.red,
    //   textColor: AppColors.white,
    //   fontSize: AppFontsSizeManager.s16.sp,
    // );
  }

}