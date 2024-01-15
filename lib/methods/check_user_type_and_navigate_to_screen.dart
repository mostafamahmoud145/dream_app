
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_store/config/paths.dart';

import '../config/constants.dart';
import '../localization/localization_methods.dart';
import '../models/user.dart';
import '../screens/consultRules.dart';
import '../screens/home_screen.dart';
import '../screens/userAccountScreen.dart';
import '../services/app_flyer_service.dart';
import 'get_device_type.dart';
import 'navigation_method.dart';

/// check the user type.
/// after signing in, [checkUserTypeAndNavigateToScreens] method is called,
/// to check if the user is new user or old user,
/// if new user => create initial data to him in firebase,
/// and navigate to his profile to complete his information.
///
/// if old user => navigate to home screen.
/// if the user blocked => logout.
///
Future<void> checkUserTypeAndNavigateToScreens(
    {required String phoneNumber,
      required String userType,
      required String uid,
      required BuildContext context,
      required String countryCode,
      required String isoCode,
      required Function onError,
      required Function onNavigate,
    }) async {

  try {
    await FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get()
        .then((value) async {
      if (value.docs.length > 0) {
        String eventName = "af_login";
        Map eventValues = {};
        addEvent(eventName, eventValues);
        Map<String, dynamic> data = value.docs[0].data();
        await FirebaseFirestore.instance
            .collection(Paths.usersPath)
            .doc(data['uid'])
            .set({
          'userLang': getTranslated(context, 'lang'),
          'languages': data['userType'] == AppConstants.consultant
              ? data['languages']
              : [getTranslated(context, 'lang')],
          'deviceType': await getDeviceType(),
        }, SetOptions(merge: true));
        await FirebaseFirestore.instance
            .collection(Paths.supportListPath)
            .doc(data['supportListId'])
            .set({
          'userLang': getTranslated(context, 'lang'),
        }, SetOptions(merge: true));
        if (data['isBlocked'] != null && data['isBlocked']) {
          await FirebaseAuth.instance.signOut();

          onNavigate();

          // load= false;
          // emit(NavigateToScreenState());

          Navigator.popAndPushNamed(
            context,
            '/home',
            arguments: {
              'userType': userType,
            },
          );
        } else if (data['profileCompleted'] != null &&
            data['profileCompleted']) {
          await AppFlyerService()
              .initAppFlyerUser(FirebaseAuth.instance.currentUser!.uid);

          onNavigate();
          // load= false;
          // emit(NavigateToScreenState());
          navigateWithoutBack(context,  HomeScreen(),);

        } else {
          DocumentReference docRef =
          FirebaseFirestore.instance.collection(Paths.usersPath).doc(uid);
          final DocumentSnapshot documentSnapshot = await docRef.get();
          var user = GroceryUser.fromMap(documentSnapshot.data() as Map);
          if (user.userType == AppConstants.consultant) {
            onNavigate();
            // load= false;
            // emit(NavigateToScreenState());
            navigateTo(context,  consultRuleScreen(user: user),);

          } else {
            await AppFlyerService()
                .initAppFlyerUser(FirebaseAuth.instance.currentUser!.uid);

            onNavigate();
            // load= false;
            // emit(NavigateToScreenState());
            navigateTo(context, UserAccountScreen(user: user, firstLogged: true),);
          }
        }
      } else {
        //user nit found-create user and save it
        String eventName = "af_complete_registration";
        Map eventValues = {
          "af_registration_method": "phone number",
        };
        addEvent(eventName, eventValues);
        DocumentReference ref = await FirebaseFirestore.instance
            .collection(Paths.usersPath)
            .doc(uid);
        var data = {
          'accountStatus': 'NotActive',
          'userLang': getTranslated(context, 'lang'),
          'profileCompleted': false,
          'isBlocked': false,
          'uid': uid,
          'name': " ",
          'email': " ",
          'phoneNumber': phoneNumber,
          'photoUrl': '',
          'tokenId': "",
          'loggedInVia': "mobile",
          'deviceType': await getDeviceType(),
          "userType": userType,
          "languages": [getTranslated(context, 'lang')],
          "countryCode": countryCode,
          "countryISOCode": isoCode,
          "createdDate": Timestamp.now(),
          'utcTime': DateTime.now().toUtc().toString(),
          'date': {
            'day': DateTime.now().toUtc().day,
            'month': DateTime.now().toUtc().month,
            'year': DateTime.now().toUtc().year,
          },
          "createdDateValue": DateTime(DateTime.now().year,
              DateTime.now().month, DateTime.now().day)
              .millisecondsSinceEpoch,
        };
        ref.set(data, SetOptions(merge: true));
        final DocumentSnapshot currentDoc = await ref.get();
        var user = GroceryUser.fromMap(currentDoc.data() as Map);

        /**
         * DEEP LINK LOGIC
         */
        await AppFlyerService()
            .updateCurrentUserDeepLinkDataAtRegistration(uid);

        if (user.userType == AppConstants.consultant) {

          // load= false;
          // emit(NavigateToScreenState());
          onNavigate();
          navigateTo(context, consultRuleScreen(user: user),);

        } else {

          await AppFlyerService()
              .initAppFlyerUser(FirebaseAuth.instance.currentUser!.uid);

          // load= false;
          // emit(NavigateToScreenState());
          onNavigate();
          navigateTo(context, UserAccountScreen(user: user),);

        }
      }
    }).catchError((err) {});
  } catch (e) {
    // load= false;
    // emit(NavigateToScreenErrorState());
    onError();
    return null;
  }
}



addEvent(String eventName, Map eventValues) async {
  await AppFlyerService().logEvent(eventName, eventValues);
  if (eventName == "af_login") {
    await FirebaseAnalytics.instance.logLogin(
      loginMethod: "phone",
    );
  } else {
    await FirebaseAnalytics.instance.logSignUp(
      signUpMethod: "phone",
    );
  }
}