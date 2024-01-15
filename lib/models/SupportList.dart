
import 'package:cloud_firestore/cloud_firestore.dart';
class SupportList {
  String? supportListId;
  bool? supportListStatus;
  bool? openingStatus;
  bool? pending;
  Timestamp? messageTime;
  String? userUid;
  String? userName;
  String? owner;
  String? lastMessage;
  dynamic image;
  dynamic userMessageNum;
  dynamic supportMessageNum;

  SupportList({
    this.supportListId,
    this.supportListStatus,
    this.openingStatus,
    this.messageTime,
    this.userUid,
    this.pending,
    this.userName,
    this.owner,
    this.lastMessage,
    this.image,
    this.userMessageNum,
    this.supportMessageNum,


  });

  factory SupportList.fromMap(Map  data) {
    return SupportList(
      supportListId: data['supportListId'],
      supportListStatus: data['supportListStatus']==null?false:data['supportListStatus'],
      openingStatus:data['openingStatus']==null?false:data['openingStatus'],
      pending:data['pending']==null?false:data['pending'],
      messageTime: data['messageTime'],
      userUid: data['userUid'],
      userName: data['userName'],
      lastMessage: data['lastMessage'],
      image: data['image'],
      owner: data['owner']==null?"USER":data['owner'],
      userMessageNum: data['userMessageNum'],
      supportMessageNum: data['supportMessageNum'],
    );
  }
}

