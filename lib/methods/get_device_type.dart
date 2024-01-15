

import 'dart:io';

import 'package:flutter/services.dart';

Future<String> getDeviceType() async {
  String deviceType = 'Unknown';
  // final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
  try {
    if (Platform.isAndroid) {
      deviceType = 'Android';
    } else if (Platform.isIOS) {
      deviceType = 'iOS';
    }
  } on PlatformException {
    deviceType = 'Unknown';
  }
  return deviceType;
}