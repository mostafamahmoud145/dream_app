
import 'package:cloud_firestore/cloud_firestore.dart';

import 'order.dart';

class UserPaymentHistory {
  String userUid;
  String payType;
  String amount;
  Timestamp payDate;
  dynamic payDateValue;
  UserDetails? otherData;

  UserPaymentHistory({
    required this.userUid,
    required this.payType,
    required this.amount,
    required this.payDate,
    this.payDateValue,
    this.otherData,
  });

  factory UserPaymentHistory.fromMap(Map  data) {
    return UserPaymentHistory(
        userUid: data['userUid'],
        payType: data['payType'],
        amount: data['amount'],
        payDate: data['payDate'],
        payDateValue: data['payDateValue'],
        otherData: UserDetails.fromHashmap(data['otherData'])
    );
  }
}


