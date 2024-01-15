import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/core/extensions/printing_extension.dart';
import 'package:grocery_store/methods/change_user_call_state.dart';
import 'package:grocery_store/services/jitsi_service/meet_service.dart';

import '../../../services/jitsi_service/meet_service_impl.dart';

part 'meet_state.dart';

class MeetCubit extends Cubit<MeetStates> {
  static MeetCubit get(context) => BlocProvider.of(context);

  MeetCubit(this.meetService) : super(MeetInitialState());
  MeetService meetService;

  AudioPlayer _audioPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
  Future<void> GoToCall() async {
    if (meetService.meetDetails.iscaller ?? false) {
      emit(MeetLoadingState());
      meetService.requestCallPermissions();
      emit(MeetRequestedPermissionState());
      MeetStatesEnum state = await meetService.checkUserCallState();
      if (state case MeetStatesEnum.connectionError) {
        emit(MeetConnectionErrorState());
      } else if (state case MeetStatesEnum.UserInCallState) {
        emit(MeetUserInAnotherState());
      } else if (state case MeetStatesEnum.ErrorCreatingState) {
        emit(MeetErrorState());
      } else if (state case MeetStatesEnum.IncomingCall) {
        emit(MeetUserIncomingCallState());
        _setupAudio();
        var callState = await meetService.triggerCallState();
        switch (callState) {
          case call_state.anotherCall:
            'TRIGGER: another call'.printError;
            emit(MeetUserInAnotherState());
            break;
          case call_state.calling:
            emit(MeetUserCallingState());
            'TRIGGER: Calling'.printError();
            deActivateAudio();
            break;
          case call_state.refused:
            'TRIGGER: Refused'.printError();
            emit(MeetUserRefusedState());
            deActivateAudio();
            break;
          case call_state.closed:
            'TRIGGER: Closed'.printError();
            emit(MeetUserClosedState());
            deActivateAudio();
            break;
          case call_state.timeOut:
            // ################################################################
            // #### This is not Refusing the call but it updates the server ###
            // ####     to notify the receiver that the call has ended      ###
            // ################################################################
            refuse();
            emit(MeetUserTimeOutState());

            break;
          case call_state.inCall:
            'TRIGGER: InCall'.printInfo();
            emit(MeetUserInCallState());
            deActivateAudio();
            // if  the current user canceled the call it will not navigate to Meeting room
            await meetService.updateServerWithCallState();
            await meetService.WhichCallToStart(EndingCall);
            break;
        }
      }
    } else {
      deActivateAudio();
    }
  }

  _setupAudio() {
    _audioPlayer.play(AssetSource('sound/jeraston.mp3'));
  }

  deActivateAudio() {
    if (_audioPlayer.state == PlayerState.playing) _audioPlayer.release();
  }

  pauseAudio() {
    _audioPlayer.pause();
  }

  resumeAudio() {
    _audioPlayer.resume();
  }

  void EndingCall() {
    'ENDED THE CALL'.printError();
    emit(MeetEndingCallState());
  }

  Future<void> refuse() async {
    deActivateAudio();

    await changeUserState(
        userId: meetService.meetDetails.callerId, state: 'closed');
    await changeUserState(
        userId: meetService.meetDetails.receiverId, state: 'closed');
  }

  @override
  void onChange(Change<MeetStates> change) {
    'Change State: ${change.currentState} ====>  ${change.nextState} '
        .logPrint();
    super.onChange(change);
  }
}
