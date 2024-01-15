part of 'verification_code_cubit.dart';

@immutable
abstract class VerificationCodeState {}

class VerificationCodeInitialState extends VerificationCodeState {}

/// verify otp states with api.
class VerifyOTPCodeLoadingState extends VerificationCodeState {}
class VerifyOTPCodeSuccessState extends VerificationCodeState {}
class VerifyOTPCodeErrorState extends VerificationCodeState {}

/// timer state
class ChangeTimerState extends VerificationCodeState {}

/// navigation states
class NavigateToScreenState extends VerificationCodeState {}
class NavigateToScreenErrorState extends VerificationCodeState {}

/// resend otp states
class ResendOTPLoadingState extends VerificationCodeState {}
class ResendOTPSuccessState extends VerificationCodeState {}
class ResendOTPErrorState extends VerificationCodeState {}

/// verify OTP with firebase.
class VerifyOTPWithFirebaseLoadingState extends VerificationCodeState {}
class VerifyOTPWithFirebaseSuccessState extends VerificationCodeState {}
class VerifyOTPWithFirebaseErrorState extends VerificationCodeState {}


/// generate otp
class GenerateOTPErrorState extends VerificationCodeState {}
class GenerateOTPSuccessState extends VerificationCodeState {}
