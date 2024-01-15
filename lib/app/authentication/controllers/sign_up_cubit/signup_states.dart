part of 'signup_cubit.dart';

@immutable
abstract class SignupStates {}

class AuthenticationInitialState extends SignupStates {}

///login states
class LoginLoadingState extends SignupStates {}
class LoginSuccessState extends SignupStates {}
class LoginErrorState extends SignupStates {}


///login states
class GenerateOTPLoadingState extends SignupStates {}
class GenerateOTPSuccessState extends SignupStates {}
class GenerateOTPErrorState extends SignupStates {}

/// change phone number
class ChangePhoneNumberState extends SignupStates {}