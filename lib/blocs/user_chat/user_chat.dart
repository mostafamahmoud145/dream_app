import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';

class UserChat {
  UserChat();
  Future<void> updateReceivedMessagesForUser() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref(Paths.appointmentsChatMessage);
    final DocumentSnapshot<Map<String, dynamic>> user =
    await FirebaseFirestore.instance.collection(Paths.usersPath).doc(FirebaseAuth.instance.currentUser!.uid).get();
    QuerySnapshot querySnapshot = user.data()!['userType'] == AppConstants.consultant
        ? await FirebaseFirestore.instance
            .collection(Paths.appAppointments)
            .where('consult.uid', isEqualTo: user.data()!['uid'])
            .where('appointmentStatus', whereIn: ["open", "completed"])
            .get()
        : await FirebaseFirestore.instance
            .collection(Paths.appAppointments)
            .where('user.uid', isEqualTo: user.data()!['uid'])
            .where('appointmentStatus', whereIn: ["open", "completed"])
            .get();
    // Get documents
    List<DocumentSnapshot> documents = querySnapshot.docs;
    // Iterate
    documents.forEach((doc)  async {
      // Use doc data
      DatabaseReference refs = ref.child(doc.id);
      refs.onValue.listen((event) {
        ref.child(doc.id).once().then((snapshot) {
          if(snapshot.snapshot.exists){
            var data = snapshot.snapshot.value as Map;
            data.forEach((key, value) {
              if(value['owner'] != user.data()!['userType']&&value['isReceived'] == false){
                ref.child(doc.id).child(key).update({'isReceived':true});
              }
            });
          }
        });
      });
    });
  }

  Future<StreamSubscription> updateReadMessagesForUser({required String appointmentId,required String userType}) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref(Paths.appointmentsChatMessage).child(appointmentId);
    return ref.onValue.listen((event) {
      ref.once().then((snapshot) {
        if(snapshot.snapshot.exists){
          var data = snapshot.snapshot.value as Map;
          data.forEach((key, value) {
            if(value['owner'] != userType&&value['isRead'] == false){
              ref.child(key).update({'isRead':true});
            }
          });
        }
      });
    });
  }
}
