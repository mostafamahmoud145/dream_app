
import 'package:cloud_firestore/cloud_firestore.dart';

import 'order.dart';

class AppAppointments {
  String appointmentId;
  String appointmentStatus;
  Timestamp appointmentTimestamp;
  Timestamp timestamp;
  dynamic timeValue;
  dynamic secondValue;
  UserDetails consult;
  UserDetails user;
  AppointmentDate date;
  AppointmentDate? closedDate;
  String? closedUtcTime;
  AppointmentTime time;
  String orderId;
  String type;
  dynamic callPrice;
  dynamic userChat;
  dynamic consultChat;
  String utcTime;
  bool? isUtc;
  bool allowCall;
  String consultType;
  dynamic callCost;
  int remainingCallNum;

  AppAppointments({
    required this.appointmentId,
    required this.appointmentStatus,
    this.isUtc,
    this.closedDate,
    this.closedUtcTime,
    required this.appointmentTimestamp,
    required this.orderId,
    required this.timestamp,
    this.secondValue,
    this.timeValue,
    required this.remainingCallNum,
    required this.utcTime,
    required this.callCost,
    required this.type,
    required this.date,
    required this.time,
    required this.consult,
    required this.user,
    this.callPrice,
    this.consultChat,
    this.userChat,
    required this.allowCall,
    required this.consultType,



  });

  factory AppAppointments.fromMap(Map  data) {
    return AppAppointments(
      appointmentId: data['appointmentId'],
      appointmentStatus: data['appointmentStatus'],
      appointmentTimestamp: data['appointmentTimestamp'],
      orderId: data['orderId'],
      isUtc: data['isUtc'],
      utcTime:data['utcTime'],
      timeValue: data['timeValue'],
      type:data['type']==null?"voice":data['type'],
      callCost: data['callCost']==null?0.0:data['callCost'],
      consultType:data['consultType']==null?"voice":data['consultType'],
      closedDate: data['closedDate']==null?null:AppointmentDate.fromHashmap(data['closedDate']),
      closedUtcTime:data['closedUtcTime'],
      date: AppointmentDate.fromHashmap(data['date']),
      time: AppointmentTime.fromHashmap(data['time']),
      consult: UserDetails.fromHashmap(data['consult']),
      user: UserDetails.fromHashmap(data['user']),
      timestamp: data['timestamp'],
      allowCall: data['allowCall']==null?false:data['allowCall'],
      secondValue: data['secondValue'],
      callPrice:data['callPrice'],
        consultChat:data['consultChat'],
        userChat:data['userChat'],
        remainingCallNum:data['remainingCallNum']

    );
  }
}
class AppointmentDate {
  int day;
  int month;
  int year;

  AppointmentDate({
    required this.day,
    required this.month,
    required this.year,
  });

  factory AppointmentDate.fromHashmap(Map<String, dynamic> Details) {
    return AppointmentDate(
        day: Details['day'],
        month: Details['month'],
        year: Details['year'],
    );
  }
}
class AppointmentTime {
  int hour;
  int minute;

  AppointmentTime({
    required this.hour,
    required this.minute,
  });

  factory AppointmentTime.fromHashmap(Map<String, dynamic> Details) {
    return AppointmentTime(
      hour: Details['hour'],
      minute: Details['minute'],
    );
  }
}


