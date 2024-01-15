
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../config/paths.dart';

Future<void> storeErrorInFirebase({
  required String description,
  required String function,
  required String phone,
  required String screen,
})async{
  String id = Uuid().v4();
  await FirebaseFirestore.instance
      .collection(Paths.errorLogPath)
      .doc(id)
      .set({
    'timestamp': Timestamp.now(),
    'id': id,
    'seen': false,
    'desc': description,
    'phone': phone,
    'screen': screen,
    'function': function,
  });
}