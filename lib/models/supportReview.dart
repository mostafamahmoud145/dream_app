
import 'package:cloud_firestore/cloud_firestore.dart';
class SupportReview {
  String? review;
  dynamic rating;
  Timestamp? reviewTime;
  String? supportListId;
  String? supportImage;
  String? supportUid;
  String? supportName;
  String? userName;
  SupportReview({
    this.review,
    this.rating,
    this.reviewTime,
    this.supportListId,
    this.supportImage,
    this.supportUid,
    this.supportName,
    this.userName,
  });
  factory SupportReview.fromMap(Map  data) {
    return SupportReview(

      rating: data['rating'],
      review: data['review'],
      reviewTime:data['reviewTime'],
      supportListId: data['supportListId'],
      supportImage: data['supportImage'],
      supportUid: data['supportUid'],
      supportName: data['supportName'],
      userName: data['userName'],

    );
  }
  factory SupportReview.fromHashMap(Map<String?, dynamic> review) {
    return SupportReview(
      rating: review['rating'],
      review: review['review'],
      reviewTime: review['reviewTime'],
      supportListId: review['supportListId'],
      supportImage: review['supportImage'],
      supportUid: review['supportUid'],
      supportName: review['supportName'],
      userName: review['userName'],
    );
  }
}