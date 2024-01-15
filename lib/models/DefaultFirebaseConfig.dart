import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseConfig {
  static FirebaseOptions? get platformOptions {
    if (Platform.isIOS || Platform.isMacOS) {
      // iOS and MacOS
      return const FirebaseOptions(
        appId: '1:459951819490:ios:51e5345b7bbb87665b2cbb',
        apiKey: 'AIzaSyDscunyLuw7fCg95Jpgw3OHOFMQrXJkF4I',
        projectId: 'dream-43bb8',
        messagingSenderId: '459951819490',
        iosBundleId: 'com.abdulazizAhmed.dream',
        iosClientId:
        '459951819490-bs5ckj7g186d8osuqelerk3tn381imbp.apps.googleusercontent.com',
        androidClientId:
        '459951819490-2frq9mh758k2vo595560e8ttqihb8j9r.apps.googleusercontent.com',
        databaseURL: 'https://dream-43bb8.firebaseio.com',
        storageBucket: 'dream-43bb8.appspot.com',
      );
    } else {
      // Android
      log("Analytics Dart-only initializer doesn't work on Android, please make sure to add the config file.");

      return null;
    }
  }
}
