
import 'package:cloud_firestore/cloud_firestore.dart';
class DevelopMessage {
  String? developMessageId;
  Timestamp? messageTime;
  String? messageTimeUtc;
  String? userUid;
  String? message;
  dynamic type;
  dynamic owner;
  String? ownerName;

  DevelopMessage({
     this.message,
     this.developMessageId,
     this.messageTime,
     this.messageTimeUtc,
     this.userUid,
    this.type,
    this.owner,
     this.ownerName,


  });

  factory DevelopMessage.fromMap(Map  data) {
    return DevelopMessage(
      developMessageId: data['developMessageId'],
      message: data['message'],
      messageTimeUtc:data['messageTimeUtc'],
      type: data['type'],
      owner: data['owner'],
      userUid: data['userUid'],
      messageTime: data['messageTime'],
      ownerName: data['ownerName'],

    );
  }
}

