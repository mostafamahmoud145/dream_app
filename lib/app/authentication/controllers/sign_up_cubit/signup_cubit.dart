
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/app/authentication/repositories/authentication_repository.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/methods/get_phone_without_country_code.dart';
import 'package:grocery_store/methods/show_failed_snackbar.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../methods/check_status_code.dart';
import '../../view/screens/verification_screen.dart';

part 'signup_states.dart';

class SignupCubit extends Cubit<SignupStates> {
  SignupCubit({required this.authenticationRepo}) : super(AuthenticationInitialState());

  BaseAuthenticationRepository authenticationRepo;

  SignupCubit get(context) => BlocProvider.of(context);


  PhoneNumber number= PhoneNumber(isoCode: 'SA'); // phone number that the entered.


  /// login to API to get the token that used to generate otp or verify it.
  ///
  Future<void> login({required BuildContext context, required String userType}) async {
    emit(LoginLoadingState());


    final result = await authenticationRepo.login();

    result.fold(
      /// Failure model.
      (left) {
              checkStatusCode(left, context);
              emit(LoginErrorState());
        },

        /// response map.
        (right) {
              // login success, then generate otp.
              String token = right['token'];
              checkAuthenticationMethod(token: token, userType: userType, context: context);
              // generateOTP(token: token, context: context, userType: userType);
            }
    );
  }



  /// used to know the authentication method (API or Firebase).
  ///
  Future<void> checkAuthenticationMethod({
    required String token,
    required String userType,
    required BuildContext context
  })async{

    FirebaseFirestore.instance
        .collection(Paths.settingPath)
        .doc("pzBqiphy5o2kkzJgWUT7").get().then((value) {
      bool withApi = value.data()!['otpAPI'];
      print('+++++++with api:   $withApi');
      if(withApi==true){
        generateOTP(token: token, userType: userType, context: context, withApi: withApi);
      }else{
        emit(LoginSuccessState());
        navigateToOtpScreen(token: token, userType: userType, context: context, withApi: withApi);
      }

    }).catchError((error) {
      showFailedSnackBar(getTranslated(context, 'failed'));
    });
  }



  ///----------------------------generate new otp from api via [AuthenticationRepo]--------------------------///
  /// called when the user enter his phone number,
  ///
  Future<void> generateOTP({
    required String token,
    required String userType,
    required BuildContext context,
    required bool withApi,
  }) async {

    final result = await authenticationRepo.generateOTP(
        token: token,
        countryCode: number.dialCode!,
        phoneNumber: getPhoneWithoutCountryCode(number.phoneNumber!, number.dialCode!)
    );

    result.fold(
      /// Failure model.
            (left) {
          checkStatusCode(left, context);
          emit(GenerateOTPErrorState());
        },

        /// response map.
            (right) {
          // generate otp success, then go to otp screen.
              navigateToOtpScreen(token: token, userType: userType, context: context, withApi: withApi);
              emit(GenerateOTPSuccessState());
        }
    );
  }




  navigateToOtpScreen({
    required String token,
    required String userType,
    required BuildContext context,
    required bool withApi
  }) async {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationScreen(
          userType: userType,
          token: token,
          number: number,
          withApi: withApi
        ),
      ),
    );
  }


  /// called when the user enter new phone number in sign up screen to store new number.
  void onChangePhoneNumber(PhoneNumber phoneNumber){
    if(number.phoneNumber==phoneNumber.phoneNumber &&
        number.dialCode==phoneNumber.dialCode &&
        number.isoCode==phoneNumber.isoCode
    ){
      number= phoneNumber;
    }else{
      number= phoneNumber;
      emit(ChangePhoneNumberState());
    }
    print(number);
  }
}