import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/methods/check_user_type_and_navigate_to_screen.dart';
import 'package:grocery_store/methods/get_phone_without_country_code.dart';
import 'package:grocery_store/services/firebase_authentication_service.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../../methods/check_status_code.dart';
import '../../../../methods/show_failed_snackbar.dart';
import '../../../../methods/store_error_in_firebase.dart';
import '../../repositories/authentication_repository.dart';

part 'verification_code_state.dart';


/// *************************** Verification code steps with api **********************************///
/// (with resendOtp==false) => [verifyOTP] => [verifyOTPWithApi] => [signInUserInFirebaseWithToken] => [checkUserTypeAndNavigateToScreens]
///
/// (with resendOtp ==true) => [resendOTP] => [generateOTPFromFirebase],
/// after code sent:[verifyOTP] => [signInUserInFirebaseWithCredential] => [checkUserTypeAndNavigateToScreens]


/// *************************** Verification code steps with firebase ****************************///
/// (with resendOtp==false) => [generateOTPFromFirebase] in initialization of cubit.
/// when code sent => [signInUserInFirebaseWithCredential] => [checkUserTypeAndNavigateToScreens].
///
/// (with resendOtp==true) => [generateOTPFromApi].
/// when code sent: [verifyOTPWithApi] => [signInUserInFirebaseWithToken] => [checkUserTypeAndNavigateToScreens].


class VerificationCodeCubit extends Cubit<VerificationCodeState> {

  bool load= false;         // to load text field and verification button.
  String? token;            // api token
  late String userType;
  bool? withApi;            // to check current authentication method.
  late PhoneNumber number;  // phone number that the user entered it in sign up screen.
  late BuildContext context;
  String _verificationCode= '';
  bool isResendOtp= false;

  VerificationCodeCubit() : super(VerificationCodeInitialState());

  VerificationCodeCubit get(context) => BlocProvider.of(context);


  /// initialize the data.
  /// called when creating the cubit.
  void initData({
    required String token,
    required String userType,
    required bool withApi,
    required PhoneNumber number,
    required BuildContext context,
  }){
    print('*************************************ff$withApi');
    startTimer();
    listenToOPT();
    this.token= token;
    this.userType= userType;
    this.number= number;
    this.withApi= withApi;
    this.context= context;

    /// if the current authentication method is firebase,
    /// generate otp and send it to user via [generateOTPFromFirebase].
    if(withApi== false){
      loadTextFormOnly= false;
      emit(ResendOTPLoadingState());
      generateOTPFromFirebase(context: context);
    }
  }


  listenToOPT() async {
    try {
      await SmsAutoFill().listenForCode;
    } catch (e) {}
  }

  /// **********when the current authentication method is API*******///
  /// if resend code, verify the code with firebase
  /// else verify it with API.
  ///
  /// *******when the current authentication method is Firebase*******///
  /// if resend code, verify the code with API
  /// else verify it with Firebase.
  ///
  Future<void> verifyOTP({required String otpCode}) async{
    load= true;

    if(withApi==true){

      if(isResendOtp==true){
        signInUserInFirebaseWithCredential(context: context, smsCode: otpCode);
      }else{
        verifyOTPWithApi(otpCode: otpCode);
      }

    }else{
      print('----------verify otp');

      if(isResendOtp==true){
        print('----------verify otp resend');

        verifyOTPWithApi(otpCode: otpCode);
      }else{
        print('----------verify otp not resend');
        signInUserInFirebaseWithCredential(context: context, smsCode: otpCode);
      }

    }
  }


  ///----------------------------Resend new code to user--------------------------///
  bool loadTextFormOnly= false;
  Future<void> resendOTP() async{
    loadTextFormOnly= true;
    isResendOtp = true;
    startTimer();

    /// if the current authentication method is Api, resend new code via firebase.
    /// if the current authentication method is firebase, resend it from api.
    ///
    if(withApi==true){
      print('+++++++resendOTP api');
      generateOTPFromFirebase(context: context);
    }else{
      print('----------resendOTP');
      generateOTPFromApi(context: context, userType: userType, token: token!);
    }
  }



  ///----------------------------verify OTP With Api via [AuthenticationRepo]--------------------------///
  ///used to check if the code that user entered it is correct or not,
  ///if correct => call [signInUserInFirebaseWithToken] to signing in the user in firebase.
  ///if not => check error type and display error message to user.
  ///
  Future<void> verifyOTPWithApi({required String otpCode}) async {
    emit(VerifyOTPCodeLoadingState());
    print('+++++++verifyOTPWithApi');
    print('----------verifyOTPWithApi');

    AuthenticationRepo authenticationRepo = AuthenticationRepo();
    final result = await authenticationRepo.verifyOTP(
        otpCode: otpCode,
        phoneNumber: getPhoneWithoutCountryCode(number.phoneNumber!, number.dialCode!),
        countryCode: number.dialCode!,
        token: this.token!,
    );

    result.fold(
      /// Failure model.
            (left) {
          checkStatusCode(left, context);
          load= false;
          emit(VerifyOTPCodeErrorState());
        },

        /// response map.
            (right) {
          // login success, then check user type.
              String firebaseToken = right['response']['token'];
              String userId = right['response']['id'];
              print('=========from token');
              FirebaseAuthenticationService.signInUserInFirebaseWithToken(
                  context: context,
                  firebaseToken: firebaseToken,
                  phoneNumber: number,
                  userId: userId,
                  userType: userType,
                  onNavigate: (){
                    load= false;
                    emit(NavigateToScreenState());
                  },
                  onError: (){
                    load= false;
                    emit(VerifyOTPCodeErrorState());
                  }
              );
            }
    );
  }


  ///----------------------------generate new otp from api via [AuthenticationRepo]--------------------------///
  /// called when the user need to resend otp code,
  /// and the current authentication method is Firebase
  ///
  Future<void> generateOTPFromApi({
    required String token,
    required String userType,
    required BuildContext context,
  }) async {

    AuthenticationRepo authenticationRepo = AuthenticationRepo();
    final result = await authenticationRepo.generateOTP(
        token: token,
        countryCode: number.dialCode!,
        phoneNumber: getPhoneWithoutCountryCode(number.phoneNumber!, number.dialCode!)
    );

    result.fold(
      /// Failure model.
            (left) {
          checkStatusCode(left, context);
          loadTextFormOnly= false;
          emit(GenerateOTPErrorState());
        },

        /// response map.
            (right) {
              loadTextFormOnly= false;
              emit(GenerateOTPSuccessState());
            }
    );
  }


  ///----------------------------Generate new otp from firebase--------------------------///
  /// called in initState of cubit when the current authentication method is Firebase.
  /// Also called when the user need to resend otp code,
  /// and the current authentication method is API
  ///
  Future<bool> generateOTPFromFirebase({required BuildContext context,}) async {
    try {
      print('+++++++generateOTPFromFirebase');
      print('----------generateOTPFromFirebase');

      int? forceResendToken;
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: number.phoneNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential authCredential) {
          showFailedSnackBar("verification completed ${authCredential.smsCode}");
          signInUserInFirebaseWithCredential(
            context: context,
            authCredential: authCredential,
          );
          loadTextFormOnly= false;
          emit(ResendOTPSuccessState());
        },
        verificationFailed: (FirebaseException authException)=>
            FirebaseAuthenticationService.phoneVerificationFailed(authException, number.phoneNumber!),
        codeSent: (String verificationId, int? resendToken) async {
          this._verificationCode = verificationId;
          loadTextFormOnly= false;
          emit(ResendOTPSuccessState());
        },
        codeAutoRetrievalTimeout: (String verificationCode) {
          this._verificationCode = verificationCode;
          loadTextFormOnly= false;
          emit(ResendOTPSuccessState());
        },
        forceResendingToken: forceResendToken,
      );
      return true;

    } catch (e) {
      await storeErrorInFirebase(
          description: e.toString(),
          function: "generateOTPFromFirebase",
          phone: number.phoneNumber!,
          screen: 'otp'
      );
      showFailedSnackBar(e.toString());
      emit(ResendOTPErrorState());
      return false;
    }
  }




  /// After signing up,
  /// if firebase is used, sign in with credential (_verificationCode, smsCodee) that sent from firebase.
  ///
  Future<void> signInUserInFirebaseWithCredential({
    AuthCredential? authCredential,
    String? smsCode,
    required BuildContext context}) async {
    try {
      print('+++++++signInUserInFirebaseWithCredential');
      print('----------signInUserInFirebaseWithCredential');

      emit(VerifyOTPWithFirebaseSuccessState());
      UserCredential authResult;
      AuthCredential credential;

      /// authCredential sent when verification completed in [generateOTPFromFirebase()].
      ///
      if (authCredential == null) {
          credential = PhoneAuthProvider.credential(verificationId: this._verificationCode, smsCode: smsCode!);
        } else {
          credential = authCredential;
        }

        authResult = await FirebaseAuth.instance.signInWithCredential(credential);

      // after signing in user in firebase, go to [checkUserTypeAndNavigateToScreens],
      // to check if the user is new user or old user.

      if (authResult.user != null) {
        checkUserTypeAndNavigateToScreens(
            phoneNumber: number.phoneNumber!,
            userType: userType,
            context: context,
            uid: authResult.user!.uid,
          countryCode: number.dialCode!,
          isoCode: number.isoCode!,
          onError: (){
            load= false;
            emit(NavigateToScreenErrorState());
          },
          onNavigate: (){
            load= false;
            stopTimer();
            emit(NavigateToScreenState());
          }
        );

      } else {
        load= false;
        await storeErrorInFirebase(
            description: "invalid sms code",
            function: "signInUserInFirebaseWithCredential",
            phone: number.phoneNumber!,
            screen: 'otp');
        showFailedSnackBar("invalid sms code");
        load= false;
        emit(VerifyOTPWithFirebaseErrorState());
      }
    } catch (e) {

      await storeErrorInFirebase(
          description: e.toString(),
          function: "signInUserInFirebaseWithCredential",
          phone: number.phoneNumber!,
          screen: 'otp'
      );
      showFailedSnackBar(e.toString());
      load= false;
      emit(VerifyOTPWithFirebaseErrorState());
      return null;
    }
  }


  ///--------------------------------------------OTP timer-------------------------------------------///
  late Timer timer;
  late int time;
  void startTimer() {
    time = 60;

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      time--;
      emit(ChangeTimerState());
      if (time == 0) {
        timer.cancel();
      }
    });
  }

  void stopTimer(){
    timer.cancel();
  }
}