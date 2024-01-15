
import 'package:cloud_firestore/cloud_firestore.dart';
class SupportMessage {
  String? supportId;
  Timestamp? messageTime;
  String? messageTimeUtc;
  String? userUid;
  String? message;
  dynamic type;
  dynamic owner;
  String? ownerName;
  bool? isReceived;
  bool? isRead;

  SupportMessage({
     this.message,
     this.supportId,
     this.messageTime,
     this.messageTimeUtc,
     this.userUid,
    this.type,
    this.owner,
     this.ownerName,
     this.isReceived,
     this.isRead,


  });

  factory SupportMessage.fromMap(Map  data) {
    return SupportMessage(
      supportId: data['supportId'],
      message: data['message'],
      messageTimeUtc:data['messageTimeUtc'],
      type: data['type'],
      owner: data['owner'],
      userUid: data['userUid'],
      messageTime: data['messageTime'],
      ownerName: data['ownerName'],
      isReceived: data['isReceived'],
      isRead: data['isRead'],

    );
  }
  factory SupportMessage.fromDatabase(Map<String, dynamic> json) {
    return SupportMessage(
      supportId: json['supportId'],
      message: json['message'],
      messageTimeUtc: json['messageTimeUtc'],
      type: json['type'],
      owner: json['owner'],
      userUid: json['userUid'],
      messageTime: Timestamp.fromMillisecondsSinceEpoch(json['messageTime']),
      ownerName: json['ownerName'],
      isReceived: json['isReceived'],
      isRead: json['isRead'],
    );
  }
}

