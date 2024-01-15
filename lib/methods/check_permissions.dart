
import 'package:permission_handler/permission_handler.dart';

Future<bool> checkCallPermissions(context) async {

  // if(kIsWeb){
  //
  //   // checkPermissionsWeb().getmedia();
  //   // bool cameraAccess =await checkPermissionsWeb().checkCamera();
  //   // bool micAccess =await checkPermissionsWeb().checkMic();
  //   //
  //   // if (cameraAccess&&micAccess) {
  //   //   return true;
  //   // }else{
  //   //   return false;
  //   // }
  //
  // }
  // else{
    //Navigator.pop(context);
    //var cameraStatus=  await  Permission.camera.request();
      var  MicStatus=   await  Permission.microphone.request();

      if (MicStatus.isGranted) {
          return true;
      }
      // // if(MicStatus.isGranted){
      // //
      // //   checkCallPermissions?.call(call_permision.micGranted);
      // //
      // //
      // //
      // // }
      // if(!cameraStatus.isGranted&&!MicStatus.isGranted){
      //   checkCallPermissions?.call(call_permision.cameradined,call_permision.micdined);
      //
      // }
      // if(!MicStatus.isGranted){
      //   //  checkCallPermissions?.call(call_permision.micdined);
      //
      // }
    return false;
  }
//}



Future<bool> checkCallPermissions2() async {

  var  MicStatus=   await  Permission.microphone.request();

  if (MicStatus.isGranted) {
    return true;
  }

  return false;
}
//}




