import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'call_state.dart';

class CallCubit extends Cubit<CallStates> {

  static CallCubit get(context)=> BlocProvider.of(context);

  StartCallStates callState= StartCallStates.loading;

  CallCubit() : super(CallInitialState());



  Future<void>? changeCallState(StartCallStates state){
    callState= state;
    emit(CallChangeState());
  }
  void CheckIfCallerStillExist(){
      
  }
}


enum StartCallStates{
  loading,
  inCall,
  permissionsNotAllowed,
  callEnded
}