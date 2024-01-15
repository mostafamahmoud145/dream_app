


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:grocery_store/methods/show_failed_snackbar.dart';

import '../config/paths.dart';
import '../localization/localization_methods.dart';

/// check if the current calling system is agora or jitsimeet.
///
Future<bool> checkCallingType(BuildContext context) async{
  bool agoraIsMainSystem= false;
  await FirebaseFirestore.instance
      .collection(Paths.settingPath)
      .doc("pzBqiphy5o2kkzJgWUT7").get().then((value) {
    agoraIsMainSystem = value.data()!['agoraIsMain'];

  }).catchError((error){
    showFailedSnackBar(getTranslated(context, 'failed'));
  });

  return agoraIsMainSystem;
}