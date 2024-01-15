import "dart:async";
import "dart:convert";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:dio/dio.dart";
import "package:firebase_database/firebase_database.dart";
import "package:grocery_store/Utils/exception.dart";
import "package:grocery_store/config/paths.dart";
import 'package:http/http.dart' as http;

import "../../models/user.dart";

class CheckCallState {
  String callerId = "";
  String receiverId = "";
  String appointmentId = "";
  GroceryUser? loggedUser;

  CheckCallState({
    required this.callerId,
    required this.receiverId,
    required this.appointmentId,
    required this.loggedUser,
  });

  final FirebaseDatabase db = FirebaseDatabase.instance;

  /// check call state first and then create new call
  Future<Map<String, dynamic>> CheckState() async {
    final receiverState = await db
        .ref(Paths.userCallState)
        .child(receiverId)
        .child("callState")
        .once()
        .timeout(Duration(seconds: 10), onTimeout: () {
      // Handle timeout

      throw CustomException('unavailable');
    });
    // check call exists
    if (receiverState != null && receiverState.snapshot.exists) {
      print("checkCall2");

      // check call state
      if (receiverState.snapshot.value == "calling" ||
          receiverState.snapshot.value == "oncall") {
        return {
          "code": 101,
          "message": "Error cant call this person right now ",
          "data": "person in another call",
        };
      }

      print("checkCall3");

      var createNewCallState = await CreateNewCall();
      print("checkCall4");

      if (createNewCallState == "success") {
        return {
          "code": 200,
          "message": "waiting for response ",
          "data": "incoming Call",
        };
      } else {
        return {
          "code": 102,
          "message": "error create call",
          "data": "error create call",
        };
      }
    } else {
      // await db.ref(Paths.signaling).child(appointmentId).child("message").remove();
      var createNewCallState = await CreateNewCall();
      if (createNewCallState == "success") {
        return {
          "code": 200,
          "message": "waiting for response ",
          "data": "incoming Call",
        };
      } else {
        return {
          "code": 102,
          "message": "error create call",
          "data": "error create call",
        };
      }
    }
  }

  /// create new call
  Future<String> CreateNewCall() async {
    print("11");
    var notificationState = await SendCallNotification();
    if (notificationState == "success") {
      // create new collection in firebase realtime for caller
      await db.ref(Paths.userCallState).child(receiverId).set({
        "callState": "calling",
        "timeStamp": Timestamp.fromDate(DateTime.now()).toDate().toString(),
        "roomId": appointmentId,
        "callerID": callerId,
        "reciverId": receiverId
      });
      print("12");

      // create new collection in firebase realtime for receiver
      await db.ref(Paths.userCallState).child(callerId).set({
        "callState": "calling",
        "timeStamp": Timestamp.fromDate(DateTime.now()).toDate().toString(),
        "roomId": appointmentId,
        "callerID": callerId,
        "reciverId": receiverId
      });
      print("13");

      return "success";
    } else {
      print("///////////CreateNewCall failed");
      return "failed";
    }
  }

  final Dio dio = Dio();

  /// send notification to another person by firebase messaging
  Future<String> SendCallNotification() async {
    print("1");

    await FirebaseDatabase.instance
        .ref('callNotifications')
        .child(appointmentId)
        .child('notificationState')
        .set('binding');
    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshotUser =
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(receiverId)
              .get();
      GroceryUser user = await GroceryUser.fromMap(
          documentSnapshotUser.data() as Map<dynamic, dynamic>);
      print("2");

      //FirebaseFunctions functions = FirebaseFunctions.instance;
      // HttpsCallable sendCallNotification =   functions.httpsCallable("sendCallKeepDialog");
      // final response  = await sendCallNotification.call({
      //   "reciverId":receiverId,
      //   "callerId":callerId,
      //   "callerName":loggedUser?.name,
      //   "appointmentId":appointmentId,
      //   "title":user.userLang=="ar" ? "مكالمة جديدة" : "new Call",
      //   "message":user.userLang=="ar" ? "مكالمة من ${user.name}" : "Call from ${user.name}",
      // });
      var requestData = {
        "reciverId": receiverId,
        "callerId": callerId,
        "callerName": loggedUser!.name,
        "appointmentId": appointmentId,
        "title": user.userLang == "ar" ? "مكالمة جديدة" : "new Call",
        "message": user.userLang == "ar"
            ? "مكالمة من ${loggedUser!.userType == "CONSULTANT" ? loggedUser!.name : loggedUser!.name}"
            : "Call from ${loggedUser!.userType == "CONSULTANT" ? loggedUser?.name : user.name}",
      };

      var response = await http.post(
        Uri.parse(
            'https://us-central1-dream-43bb8.cloudfunctions.net/sendCallKeepRequest'),
        body: jsonEncode(requestData),
        headers: {
          'Content-Type': 'application/json'
        }, // تأكد من تعيين رأس المحتوى إلى نوع التطبيق/JSON
      );
      String responseBody = response.body;
      var res = json.decode(responseBody);
      print("///////////");
      print(res);
      print(responseBody);
      if (res == 200 || res['message'] == "Success") {
        return "success";
      } else {
        return "failed";
      }
    } catch (e) {
      print("error send notifications : $e");
      return "failed";
    }
  }
}
