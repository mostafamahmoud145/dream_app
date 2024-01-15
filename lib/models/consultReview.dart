
import 'package:cloud_firestore/cloud_firestore.dart';
class ConsultReview {
  String? review;
  dynamic rating;
  Timestamp reviewTime;
  String uid;
  String appointmentId;
  String name;
  String? image;
  String consultUid;
  String consultName;
  String? consultImage;
  ConsultReview({
    this.rating,
    this.review,
    required this.reviewTime,
    required this.consultUid,
    required this.appointmentId,
    this.consultImage,
    required this.consultName,
    required this.uid,
    required this.name,
    this.image,
  });
  factory ConsultReview.fromMap(Map  data) {
    return ConsultReview(

      rating: data['rating'],
      review: data['review'],
      appointmentId: data['appointmentId'],
      uid: data['uid'],
      name: data['name'],
      image: data['image'],
      consultUid: data['consultUid'],
      reviewTime:data['reviewTime'],
      consultName: data['consultName'],
      consultImage: data['consultImage'],

    );
  }
  factory ConsultReview.fromHashMap(Map<String, dynamic> review) {
    return ConsultReview(
      rating: review['rating'],
      review: review['review'],
      reviewTime: review['reviewTime'],
      uid: review['uid'],
      name: review['name'],
      image: review['image'],
      consultUid: review['review'],
      consultName: review['consultName'],
      consultImage: review['consultImage'], appointmentId: review['appointmentId'],
    );
  }
}