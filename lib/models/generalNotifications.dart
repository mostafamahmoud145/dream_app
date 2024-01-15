
import 'package:cloud_firestore/cloud_firestore.dart';
class GeneralNotifications {
  String? id;
  String? title;
  Timestamp? notificationTimestamp;
  String? body;
  String? notificationType;
  String? notificationLang;
  String? notificationCountry;
  String? imageUrl;
  String? link;


  GeneralNotifications({
     this.id,
     this.title,
     this.body,
    this.notificationType,
    this.notificationLang,
    this.notificationCountry,
    required this.notificationTimestamp,
    this.imageUrl,
    this.link
  });

  factory GeneralNotifications.fromMap(Map  data) {
    return GeneralNotifications(
      id: data['id'],
      title: data['title'],
      body: data['body'],
      notificationType: data['notificationType'],
      notificationLang: data['notificationLang'],
      notificationCountry: data['notificationCountry'],
      notificationTimestamp: data['notificationTimestamp'],
        imageUrl:data['imageUrl'],
        link:data['link']

    );
  }
}

