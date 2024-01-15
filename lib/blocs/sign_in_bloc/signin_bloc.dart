
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import '../../repositories/authentication_repository.dart';

part 'signin_event.dart';
part 'signin_state.dart';

class SigninBloc extends Bloc<SigninEvent, SigninState> {
  SigninBloc({required this.authenticationRepository}) : super(SigninInitial()) {
    on<GetCurrentUser>((event, emit) async {
      try {
        User ?currentUser = await authenticationRepository.getCurrentUser();
        if (currentUser != null) {
          emit(GetCurrentUserCompleted(currentUser));
        }
        else {
          emit(GetCurrentUserFailed());
        }
      } catch (e) {

        emit(GetCurrentUserFailed());
      }
    });

  }
  final AuthenticationRepository authenticationRepository;


  SigninState get initialState => SigninInitial();

  Stream<SigninState> mapEventToState(
    SigninEvent event,
  ) async* {

    if (event is SignInWithphoneNumber) {
      yield* mapSignInWithphoneNumberToState(event.phoneNumber);
    }
    if (event is CheckIfBlocked) {
      yield* mapCheckIfBlockedToState(event.phoneNumber);
    }
    if (event is CheckIfSignedIn) {
      yield* mapCheckIfSignedInToState();
    }
    if (event is GetCurrentUser) {
      yield* mapGetCurrentUserToState();
    }
    if (event is SignoutEvent) {
      yield* mapSignoutEventToState();
    }
    if (event is VerifyphoneNumber) {
      yield* mapVerifyphoneNumberToState(event.otp);
    }
  }


  Stream<SigninState> mapSignInWithphoneNumberToState(String phoneNumber) async* {
    yield SignInWithphoneNumberInProgress();

    try {
      bool? isSent = await authenticationRepository.signInWithphoneNumber(phoneNumber);
      if (isSent!) {
        yield SigninWithphoneNumberCompleted();
      } else {
        yield SigninWithphoneNumberFailed();
      }
    } catch (e) {
      yield SigninWithphoneNumberFailed();
    }
  }

  Stream<SigninState> mapCheckIfBlockedToState(String phoneNumber) async* {
    yield CheckIfBlockedInProgress();

    try {
      String? res = await authenticationRepository.checkIfBlocked(phoneNumber);
      if (res != null) {
        yield CheckIfBlockedCompleted(res);
      } else {
        yield CheckIfBlockedFailed();
      }
    } catch (e) {
      yield CheckIfBlockedFailed();
    }
  }

  Stream<SigninState> mapCheckIfSignedInToState() async* {
    try {
      String? res = await authenticationRepository.isLoggedIn();
      if (res != null) {
        yield CheckIfSignedInCompleted(res);
      } else {
        yield FailedToCheckLoggedIn();
      }
    } catch (e) {

      yield FailedToCheckLoggedIn();
    }
  }

  Stream<SigninState> mapGetCurrentUserToState() async* {
    try {
      User ?currentUser = await authenticationRepository.getCurrentUser();
      if (currentUser != null) {
        emit(GetCurrentUserCompleted(currentUser));
      } else {
        emit(GetCurrentUserFailed());
      }
    } catch (e) {

      emit(GetCurrentUserFailed());
    }
  }

  Stream<SigninState> mapSignoutEventToState() async* {
    yield SignoutInProgress();
    try {
      bool? isSignedOut = await authenticationRepository.signOutUser();
      if (isSignedOut!) {
        yield SignoutCompleted();
      } else {
        yield SignoutFailed();
      }
    } catch (e) {
      yield SignoutFailed();
    }
  }

  Stream<SigninState> mapVerifyphoneNumberToState(String otp) async* {
    yield VerifyphoneNumberInProgress();
    try {
      User? user = await authenticationRepository.signInWithSmsCode(otp);
      if (user != null) {
        yield VerifyphoneNumberCompleted(user);
      } else {
        yield VerifyphoneNumberFailed();
      }
    } catch (e) {
      yield VerifyphoneNumberFailed();
    }
  }
}
