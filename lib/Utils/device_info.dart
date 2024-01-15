// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:io';

class DeviceInfo {
  static String get label {
    return 'Flutter ' +
        Platform.operatingSystem +
        '(' +
        Platform.localHostname +
        ")";
  }

  static String get userAgent {
    return 'flutter-webrtc/${Platform.operatingSystem}-plugin 0.0.1';
  }
}
