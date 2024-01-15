import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user.dart';
import '../../models/user_notification.dart';

abstract class BaseProvider {
  void dispose();
}

abstract class BaseAuthenticationProvider extends BaseProvider {
  Future<String?> isLoggedIn();
  Future<bool?> signInWithphoneNumber(String phoneNumber);
  Future<String?> checkIfBlocked(String phoneNumber);
  Future<User?> signInWithSmsCode(String smsCode);
  Future<bool?> signOutUser();
  Future<User?> getCurrentUser();
}

abstract class BaseWebRtcProvider extends BaseProvider {
  Future<bool>initRenderers(bool audioEnable, bool videoEnable);
  Future<bool> setCandidateOffer(String AppAppointmentsId);
  void setCandidateAnswer(String AppAppointmentsId);
  Future<bool>createOffer(bool audioEnable,bool videoEnable,String AppAppointmentsId,String? userid,String? callerid);
  Future<bool>createAnswer(bool audioEnable,bool videoEnable,String AppAppointmentsId,String? userid,String? callerid);
  void getCandidateOffer(String AppAppointmentsId);
  void getCandidateAnswer(String AppAppointmentsId);
  void getOffer(String AppAppointmentsId,String callerid,String userid);
  void getAnswer(String AppAppointmentsId,String callerid,String userid);
  void subscribeDomcment(String AppAppointmentsId);
  Future<bool> dactiveCall(String AppAppointmentsId);
  Future<bool> cancelCall(String AppAppointmentsId);
  Stream<DocumentSnapshot<Map<String, dynamic>>> getInomingCall();
}


abstract class BaseUserDataProvider extends BaseProvider {
  Future<GroceryUser?> getUser(String uid);
  Future<GroceryUser?> getUserByphoneNumber(String phoneNumber);
  Future<GroceryUser?> saveUserDetails({
    String? uid,
    String? name,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    String? tokenId,
    String? loggedInVia,
    String? userType,
    String? countryCode,
    String? countryISOCode,
  });
  Future<GroceryUser?> getAccountDetails(String uid);
  Future<bool?> updateAccountDetails(GroceryUser user, File profileImage);
  Stream<UserNotification>? getNotifications(String uid);
  Future<void> markNotificationRead(String uid);

}

abstract class BaseStorageProvider extends BaseProvider {}
