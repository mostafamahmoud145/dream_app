

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:uuid/uuid.dart';

import '../config/paths.dart';
import '../methods/check_user_type_and_navigate_to_screen.dart';
import '../methods/show_failed_snackbar.dart';
import '../methods/store_error_in_firebase.dart';

class FirebaseAuthenticationService{



  static phoneVerificationFailed(FirebaseException authException, String phone) async {
    String id = Uuid().v4();
    await FirebaseFirestore.instance
        .collection(Paths.errorLogPath)
        .doc(id)
        .set({
      'timestamp': Timestamp.now(),
      'id': id,
      'seen': false,
      'desc': authException.message.toString(),
      'phone': phone,
      'screen': "otp",
      'function': authException.code.toString(),
    });

    showFailedSnackBar(authException.message.toString());
  }


  /// After signing up,
  /// if api is used, sign in in firebase with firebase token that sent from api response after verifying otp.
  ///
  static Future<void> signInUserInFirebaseWithToken({
    required String firebaseToken,
    required String userId,
    required String userType,
    required BuildContext context,
    required Function onNavigate,
    required Function onError,
    required PhoneNumber phoneNumber
  }) async {
    try {
      print('+++++++signInUserInFirebaseWithToken');
      print('----------signInUserInFirebaseWithToken');

      UserCredential authResult;

      /// the authentication method is api.
      /// API send the firebase token after verify otp.
      ///
      authResult = await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);


      if (authResult.user != null) {
        // onUserAvailable();
        checkUserTypeAndNavigateToScreens(
            phoneNumber: phoneNumber.phoneNumber!,
            userType: userType,
            context: context,
            uid: userId,
            countryCode: phoneNumber.dialCode!,
            isoCode: phoneNumber.isoCode!,
            onError: (){
              onError();
            },
            onNavigate: (){
              onNavigate();
            }
        );
      } else {
        // load= false;
        await storeErrorInFirebase(
            description: "invalid sms code",
            function: "signInUserInFirebaseWithToken",
            phone: phoneNumber.phoneNumber!,
            screen: 'otp'
        );
        showFailedSnackBar("invalid sms code");
        onError();
      }

    } catch (e) {

      await storeErrorInFirebase(
          description: e.toString(),
          function: "signInUserInFirebaseWithToken",
          phone: phoneNumber.phoneNumber!,
          screen: 'otp'
      );
      showFailedSnackBar(e.toString());
      // load= false;
      // emit(VerifyOTPCodeErrorState());
      onError();
      return null;
    }
  }




  static Future<void> signInUserInFirebaseWithCredential({
    AuthCredential? authCredential,
    String? smsCode,
    String? verificationCode,
    required Function onNavigate,
    required Function onError,
    required PhoneNumber phoneNumber,
    required String userType,
    required BuildContext context}) async {
    try {

      // load= true;
      // emit(VerifyOTPWithFirebaseSuccessState());
      UserCredential authResult;
      AuthCredential credential;

      /// authCredential sent when verification completed in [generateOTPFromFirebase()].
      ///
      if (authCredential == null) {
        credential = PhoneAuthProvider.credential(verificationId: verificationCode!, smsCode: smsCode!);
      } else {
        credential = authCredential;
      }

      authResult = await FirebaseAuth.instance.signInWithCredential(credential);

      if (authResult.user != null) {
        // onUserAvailable();

        checkUserTypeAndNavigateToScreens(
            phoneNumber: phoneNumber.phoneNumber!,
            userType: userType,
            context: context,
            uid: authResult.user!.uid,
            countryCode: phoneNumber.dialCode!,
            isoCode: phoneNumber.isoCode!,
            onError: (){
              onError();
            },
            onNavigate: (){
              onNavigate();
            }
        );
      } else {
        await storeErrorInFirebase(
            description: "invalid sms code",
            function: "signInUserInFirebaseWithCredential",
            phone: phoneNumber.phoneNumber!,
            screen: 'otp');
        showFailedSnackBar("invalid sms code");
        // load= false;
        // emit(VerifyOTPWithFirebaseErrorState());
        onError();
      }
    } catch (e) {

      await storeErrorInFirebase(
          description: e.toString(),
          function: "signInUserInFirebaseWithCredential",
          phone: phoneNumber.phoneNumber!,
          screen: 'otp'
      );
      showFailedSnackBar(e.toString());
      // load= false;
      // emit(VerifyOTPWithFirebaseErrorState());
      onError();
      return null;
    }
  }
}