
import 'dart:io';

import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/models/user_notification.dart';
import 'package:grocery_store/providers/user_data_provider.dart';
import 'package:grocery_store/repositories/base_repository.dart';

import '../models/appAnalysis.dart';

class UserDataRepository extends BaseRepository {
  UserDataProvider userDataProvider = UserDataProvider();

  Future<GroceryUser> getUser(String uid) => userDataProvider.getUser(uid);

  Future<GroceryUser> getUserByphoneNumber(String phoneNumber) =>
      userDataProvider.getUserByphoneNumber(phoneNumber);

  Future<GroceryUser?> saveUserDetails(
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
      ) =>
      userDataProvider.saveUserDetails(
          email: email,
          phoneNumber: phoneNumber,
          name: name,
          photoUrl: photoUrl,
          tokenId: tokenId,
          uid: uid,
          loggedInVia: loggedInVia,
          userType:userType,
          countryCode:countryCode,
          countryISOCode:countryISOCode
      );
  Stream<AppAnalysis>? getAppAnalysis() => userDataProvider.getAppAnalysis();

  Stream<UserNotification>? getNotifications(String uid) =>
      userDataProvider.getNotifications(uid);


  Future<bool> updateAccountDetails(GroceryUser user, File? profileImage) =>
      userDataProvider.updateAccountDetails(user, profileImage);
  Future<GroceryUser?> getAccountDetails(String uid)=>
      userDataProvider.getAccountDetails(uid);
  Future<void> markNotificationRead(String uid)=>
      userDataProvider.markNotificationRead(uid);
  @override
  void dispose() {
    userDataProvider.dispose();
  }
}
