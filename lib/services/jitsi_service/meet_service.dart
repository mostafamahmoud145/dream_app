import '../../models/meet_model.dart';
import 'meet_service_impl.dart';

abstract class MeetService {
  abstract MeetModel meetDetails;
  Future<void> requestCallPermissions();
  checkCallPermissions(
      call_permission permission1, call_permission permission2);
  Future<call_state> checkCallState(
    call_state state,
  );
  Future<MeetStatesEnum> checkUserCallState();
  Future<call_state> triggerCallState();
  Future<void> updateServerWithCallState();
  WhichCallToStart(Function onEndFunction);
}

enum call_permission { cameraGranted, micGranted, cameraDenied, micDenied }

enum call_state {
  anotherCall,
  calling,
  refused,
  closed,
  inCall,
  timeOut,
}
