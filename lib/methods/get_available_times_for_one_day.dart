

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../config/paths.dart';
import '../models/consultDays.dart';
import '../models/user.dart';

Future<List<String>> getAvailableTimesForOneDay({
  required DateTime selectedDate,
  required BuildContext context,
  required GroceryUser consultant,
  required int localFrom,
  required int localTo,
  required String loggedUserPhone,
}) async {

  List<String> todayAppointmentList= [];
  String time= DateFormat('yyyy-MM-dd').format(selectedDate);

  try {
    if (DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
        .isBefore(DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day)) ||
        (!consultant.workDays!.contains(selectedDate.weekday.toString()))) {
      todayAppointmentList = [];

    } else {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(Paths.consultDaysPath)
          .doc(time + "-" + consultant.uid!)
          .get();
      if (documentSnapshot.exists) {
        ConsultDays consultDays =
        ConsultDays.fromMap(documentSnapshot.data() as Map);
        List<String> appointmentList = [];

        for (int start = 0;
        start < consultDays.todayAppointmentList!.length;
        start++) {
          if (DateTime.parse(consultDays.todayAppointmentList![start])
              .toLocal()
              .isAfter(DateTime.now())) {
            appointmentList.add(consultDays.todayAppointmentList![start]);
          }
        }

        todayAppointmentList = appointmentList;

      } else {
        var from = DateTime(selectedDate.year, selectedDate.month,
            selectedDate.day, localFrom);
        var to = DateTime(selectedDate.year, selectedDate.month,
            selectedDate.day, localTo);
        var ttt = (to.difference(from).inHours).round();
        if (ttt <= 0) {
          to = DateTime(
              selectedDate.year, selectedDate.month, selectedDate.day, 24);
          ttt = (to.difference(from).inHours).round();
        }
        List<String> appointmentList = [];
        //var lessonTime=10;
        var lessonMintes = 10;
        for (int start = 0; start < ttt * 6; start++) {
          if (from
              .add(Duration(minutes: start * lessonMintes))
              .isAfter(DateTime.now())) {
            var value = from
                .add(Duration(minutes: start * lessonMintes))
                .toUtc()
                .toString();
            appointmentList.add(value);
          }
        }
        await FirebaseFirestore.instance
            .collection(Paths.consultDaysPath)
            .doc(time + "-" + consultant.uid!)
            .set({
          'id': time + "-" + consultant.uid!,
          'day': time,
          'date': DateTime(
              selectedDate.year, selectedDate.month, selectedDate.day)
              .millisecondsSinceEpoch,
          'consultUid': consultant.uid,
          'todayAppointmentList': appointmentList,
        });
        todayAppointmentList = appointmentList;
      }
    }

    return todayAppointmentList;
  } catch (e) {
    String id = Uuid().v4();
    await FirebaseFirestore.instance
        .collection(Paths.errorLogPath)
        .doc(id)
        .set({
      'timestamp': Timestamp.now(),
      'id': id,
      'seen': false,
      'desc': e.toString(),
      'phone': loggedUserPhone,
      'screen': "ConsultantDetailsScreen",
      'function': "getDate",
    });
    return todayAppointmentList;
  }
}
