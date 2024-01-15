
import 'package:cloud_firestore/cloud_firestore.dart';
class PromoCode {
  String promoCodeId;
  bool promoCodeStatus;
  Timestamp promoCodeTimestamp;
  String ownerName;
  String code;
  dynamic usedNumber;
  dynamic discount;
  String? type;
  String? consultantId;

  PromoCode({
    required this.promoCodeId,
    required this.promoCodeStatus,
    required this.promoCodeTimestamp,
    this.type,
   this.consultantId,
    required this.ownerName,
    required this.code,
    this.usedNumber,
    this.discount,



  });

  factory PromoCode.fromMap(Map  data) {
    return PromoCode(
      promoCodeId: data['promoCodeId'],
      promoCodeStatus: data['promoCodeStatus']==null?false:data['promoCodeStatus'],
      promoCodeTimestamp: data['promoCodeTimestamp'],
      type: data['type']==null?"default":data['type'],
      ownerName: data['ownerName'],
      code: data['code'],
      usedNumber: data['usedNumber']==null?0:data['usedNumber'],
      discount: data['discount'],
      consultantId: data['consultantId'],

    );
  }
}


