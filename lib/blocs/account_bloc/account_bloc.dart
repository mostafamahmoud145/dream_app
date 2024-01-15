
import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import '../../config/paths.dart';
import '../../models/consultPackage.dart';
import '../../models/consultReview.dart';
import '../../models/setting.dart';
import '../../models/user.dart';
import '../../repositories/user_data_repository.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final UserDataRepository userDataRepository;
  AccountBloc({required this.userDataRepository}) : super(AccountInitial()) {
    on<GetLoggedUserEvent>((event, emit) async {
      emit (GetLoggedUserInProgressState());
      try {
        if(FirebaseAuth.instance.currentUser!=null){
          var ref = FirebaseFirestore.instance.collection(Paths.usersPath).doc(FirebaseAuth.instance.currentUser!.uid).withConverter(
            fromFirestore: GroceryUser.fromFirestore,
            toFirestore: (GroceryUser user, _) => user.toFirestore(), );
          final docSnap = await ref.get();
          GroceryUser? user = docSnap.data();
          if (user != null) {
            emit( GetLoggedUserCompletedState(user));
          }
          else {
            emit( GetLoggedUserFailedState());
          }
        }
        else {
          emit( GetLoggedUserFailedState());
        }

      } catch (e) {
        emit( GetLoggedUserFailedState());
      }
    });
    //=========
    on<UpdateAccountDetailsEvent>((event, emit) async {
      emit (UpdateAccountDetailsInProgressState());
      try {
        bool isUpdated =await userDataRepository.updateAccountDetails(event.user, event.profileImage);
        if (isUpdated) {
          emit( UpdateAccountDetailsCompletedState());
        }
        else {
          emit( UpdateAccountDetailsFailedState());
        }


      } catch (e) {
        emit( UpdateAccountDetailsFailedState());
      }
    });
  }



  AccountState get initialState => AccountInitial();
  Stream<AccountState> mapGetAccountDetailsEventToState({required String uid}) async* {
    yield GetAccountDetailsInProgressState();
    try {
      GroceryUser? user = await userDataRepository.getAccountDetails(uid);
      if (user != null) {

        yield GetAccountDetailsCompletedState(user);
      } else {

        yield GetAccountDetailsFailedState();
      }
    } catch (e) {

      yield GetAccountDetailsFailedState();
    }
  }




  Stream<AccountState> mapUpdateAccountDetailsEventToState(
      {required GroceryUser user, File? profileImage}) async* {
    yield UpdateAccountDetailsInProgressState();
    try {
      bool isUpdated =await userDataRepository.updateAccountDetails(user, profileImage);
      if (isUpdated) {
        yield UpdateAccountDetailsCompletedState();
      } else {
        yield UpdateAccountDetailsFailedState();
      }
    } catch (e) {
      yield UpdateAccountDetailsFailedState();
    }
  }

}
