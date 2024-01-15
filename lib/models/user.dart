import 'package:cloud_firestore/cloud_firestore.dart';

import 'AppAppointments.dart';

class GroceryUser {
  String? accountStatus;
  bool? isBlocked;
  bool? isDeveloper;
  bool? isSupervisor;
  String? uid;
  String? destinationId;
  String? name;
  ConsultName? consultName;
  ConsultBio? consultBio;
  String? email;
  String? link;
  String? userType;
  String? phoneNumber;
  String? photoUrl;
  String? sliderImage;
  bool? slide;
  bool? marketplace;
  dynamic rating;
  dynamic rate;
  int? reviewsCount;
  String? tokenId;
  List<dynamic>? promoList;
  List<dynamic>? languages;
  List<dynamic>? searchIndex;
  bool? voice;
  bool? chat;
  String? bio;
  String? country;
  List<WorkTimes>? workTimes;
  List<dynamic>? workDays;
  String? userConsultIds;
  String? price;
  String? chatPrice;
  dynamic balance;
  dynamic payedBalance;
  dynamic tapBalance;
  int? ordersNumbers;
  String? loggedInVia;
  String? supportListId;
  String? customerId;
  int? order;
  AppointmentDate? date;
  dynamic answeredSupportNum;
  String? countryCode;
  String? countryISOCode;
  String? userLang;
  String? preferredPaymentMethod;
  bool? profileCompleted = false;
  Timestamp? createdDate;
  int? createdDateValue;
  String? fullName;
  String? bankName;
  String? bankAccountNumber;
  String? fullAddress;
  String? personalIdUrl;
  String? IBAN;
  String? fromUtc;
  String? toUtc;
  String? businessId;
  String? entityId;
  bool? allowEditPayinfo;
  ConsultNationality? consultNationality;
  String? nationality;
  String? toolTip;
  GroceryUser({
    this.accountStatus,
    this.userLang,
    this.isSupervisor,
    this.sliderImage,
    this.slide,
    this.isDeveloper,
    this.fullName,
    this.link,
    this.date,
    this.fullAddress,
    this.bankName,
    this.businessId,
    this.tapBalance,
    this.entityId,
    this.IBAN,
    this.destinationId,
    this.answeredSupportNum,
    this.bankAccountNumber,
    this.personalIdUrl,
    this.countryCode,
    this.countryISOCode,
    this.order,
    this.customerId,
    this.isBlocked,
    this.uid,
    this.searchIndex,
    this.email,
    this.userType,
    this.phoneNumber,
    this.rating,
    this.rate,
    this.marketplace,
    this.reviewsCount,
    this.name,
    this.consultName,
    this.consultBio,
    this.photoUrl,
    this.languages,
    this.ordersNumbers,
    this.chat,
    this.voice,
    this.bio,
    this.promoList,
    this.workDays,
    this.workTimes,
    this.country,
    this.userConsultIds,
    this.price,
    this.chatPrice,
    this.balance,
    this.payedBalance,
    this.tokenId,
    this.loggedInVia,
    this.supportListId,
    this.profileCompleted,
    this.createdDate,
    this.createdDateValue,
    this.preferredPaymentMethod,
    this.fromUtc,
    this.toUtc,
    this.allowEditPayinfo,
    this.consultNationality,
    this.nationality,
    this.toolTip,
  });

  factory GroceryUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return GroceryUser(
      slide: data?['slide'] == null ? false : data?['slide'],
      IBAN: data?['IBAN'],
      isSupervisor:
          data?['isSupervisor'] == null ? false : data?['isSupervisor'],
      marketplace: data?['marketplace'] == null ? false : data?['marketplace'],
      businessId: data?['businessId'],
      entityId: data?['entityId'],
      sliderImage: data?['sliderImage'],
      allowEditPayinfo:
          data?['allowEditPayinfo'] == null ? true : data?['allowEditPayinfo'],
      destinationId: data?['destinationId'],
      accountStatus:
          data?['accountStatus'] == null ? "NotActive" : data?['accountStatus'],
      toolTip: data?['toolTip'] == null ? "false" : data?['true'],
      preferredPaymentMethod: data?['preferredPaymentMethod'] == null
          ? "tapCompany"
          : data?['preferredPaymentMethod'],
      profileCompleted:
          data?['profileCompleted'] == null ? false : data?['profileCompleted'],
      userLang: data?['userLang'] == null ? "ar" : data?['userLang'],
      countryCode: data?['countryCode'],
      countryISOCode: data?['countryISOCode'],
      order: data?['order'] == null ? 0 : data?['order'],
      answeredSupportNum:
          data?['answeredSupportNum'] == null ? 0 : data?['answeredSupportNum'],
      isBlocked: data?['isBlocked'],
      promoList: data?['promoList'] == null ? [] : data?['promoList'],
      uid: data?['uid'],
      link: data?['link'],
      email: data?['email'],
      customerId: data?['customerId'],
      supportListId: data?['supportListId'],
      userType: data?['userType'],
      phoneNumber: data?['phoneNumber'],
      name: data?['name'] == null ? " " : data?['name'],
      consultName: data?['consultName'] == null
          ? ConsultName(
              nameAr: ".",
              nameEn: ".",
              nameFr: ".",
              nameId: ".",
              searchIndexAr: [],
              searchIndexEn: [],
              searchIndexFr: [],
              searchIndexId: [],
            )
          : ConsultName.fromHashmap(data?['consultName']),
      consultBio: data?['consultBio'] == null
          ? ConsultBio(
              bioAr: ".",
              bioEn: ".",
              bioFr: ".",
              bioId: ".",
            )
          : ConsultBio.fromHashmap(data?['consultBio']),
      bio: data?['bio'] == null ? " " : data?['bio'],
      consultNationality: data?['consultNationality'] == null
          ? ConsultNationality(
              nationalityAr: ".",
              nationalityEn: ".",
              nationalityId: ".",
              nationalityFr: ".",
            )
          : ConsultNationality.fromHashmap(data?['consultNationality']),
      nationality: data?['nationality'] == null ? " " : data?['nationality'],
      country: data?['country'],
      date: AppointmentDate.fromHashmap(data?['date']),
      workTimes: data?['workTimes'] == null
          ? []
          : List<WorkTimes>.from(
              data?['workTimes'].map(
                (workTimes) {
                  return WorkTimes.fromHashmap(workTimes);
                },
              ),
            ),
      userConsultIds: data?['userConsultIds'],
      workDays: data?['workDays'] == null ? [] : data?['workDays'],
      reviewsCount: data?['reviewsCount'] == null ? 0 : data?['reviewsCount'],
      rating: data?['rating'] == null ? 0.0 : data?['rating'],
      languages: data?['languages'] == null ? [] : data?['languages'],
      ordersNumbers:
          data?['ordersNumbers'] == null ? 0 : data?['ordersNumbers'],
      price: data?['price'] == null ? "0" : data?['price'],
      chatPrice: data?['chatPrice'] == null ? "0" : data?['chatPrice'],
      tapBalance: data?['tapBalance'] == null ? 0.0 : data?['tapBalance'],
      balance: data?['balance'] == null ? 0.0 : data?['balance'],
      payedBalance: data?['payedBalance'] == null ? 0.0 : data?['payedBalance'],
      voice: data?['voice'] == null ? false : data?['voice'],
      chat: data?['chat'] == null ? false : data?['chat'],
      isDeveloper: data?['isDeveloper'] == null ? false : data?['isDeveloper'],
      photoUrl: data?['photoUrl'],
      tokenId: data?['tokenId'],
      searchIndex: data?['searchIndex'],
      loggedInVia: data?['loggedInVia'],
      createdDate: data?['createdDate'],
      createdDateValue: data?['createdDateValue'],
      fullName: data?['fullName'],
      fullAddress: data?['fullAddress'],
      bankName: data?['bankName'],
      bankAccountNumber: data?['bankAccountNumber'],
      personalIdUrl: data?['personalIdUrl'],
      fromUtc: data?['fromUtc'],
      toUtc: data?['toUtc'],
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "..": name,
    };
  }

  factory GroceryUser.fromMap(Map data) {
    return GroceryUser(
      slide: data['slide'] == null ? false : data['slide'],
      IBAN: data['IBAN'],
      isSupervisor: data['isSupervisor'] == null ? false : data['isSupervisor'],
      marketplace: data['marketplace'] == null ? false : data['marketplace'],
      businessId: data['businessId'],
      entityId: data['entityId'],
      sliderImage: data['sliderImage'],
      allowEditPayinfo:
          data['allowEditPayinfo'] == null ? true : data['allowEditPayinfo'],
      destinationId: data['destinationId'],
      accountStatus:
          data['accountStatus'] == null ? "NotActive" : data['accountStatus'],
      toolTip: data['toolTip'] == null ? "false" : data['true'],
      preferredPaymentMethod: data['preferredPaymentMethod'] == null
          ? "tapCompany"
          : data['preferredPaymentMethod'],
      profileCompleted:
          data['profileCompleted'] == null ? false : data['profileCompleted'],
      userLang: data['userLang'] == null ? "ar" : data['userLang'],
      countryCode: data['countryCode'],
      countryISOCode: data['countryISOCode'],
      order: data['order'] == null ? 0 : data['order'],
      answeredSupportNum:
          data['answeredSupportNum'] == null ? 0 : data['answeredSupportNum'],
      isBlocked: data['isBlocked'],
      promoList: data['promoList'] == null ? [] : data['promoList'],
      uid: data['uid'],
      link: data['link'],
      email: data['email'],
      customerId: data['customerId'],
      supportListId: data['supportListId'],
      userType: data['userType'],
      phoneNumber: data['phoneNumber'],
      name: data['name'] == null ? " " : data['name'],
      consultName: data['consultName'] == null
          ? ConsultName(
              nameAr: ".",
              nameEn: ".",
              nameFr: ".",
              nameId: ".",
              searchIndexAr: [],
              searchIndexEn: [],
              searchIndexFr: [],
              searchIndexId: [],
            )
          : ConsultName.fromHashmap(data['consultName']),
      consultBio: data['consultBio'] == null
          ? ConsultBio(
              bioAr: ".",
              bioEn: ".",
              bioFr: ".",
              bioId: ".",
            )
          : ConsultBio.fromHashmap(data['consultBio']),
      consultNationality: data['consultNationality'] == null
          ? ConsultNationality(
              nationalityAr: ".",
              nationalityEn: ".",
              nationalityFr: ".",
              nationalityId: ".",
            )
          : ConsultNationality.fromHashmap(data['consultNationality']),
      bio: data['bio'] == null ? " " : data['bio'],
      nationality: data?['nationality'] == null ? " " : data?['nationality'],
      country: data['country'],
      date: AppointmentDate.fromHashmap(data['date']),
      workTimes: data['workTimes'] == null
          ? []
          : List<WorkTimes>.from(
              data['workTimes'].map(
                (workTimes) {
                  return WorkTimes.fromHashmap(workTimes);
                },
              ),
            ),
      userConsultIds: data['userConsultIds'],
      workDays: data['workDays'] == null ? [] : data['workDays'],
      reviewsCount: data['reviewsCount'] == null ? 0 : data['reviewsCount'],
      rating: data['rating'] == null ? 0.0 : data['rating'],
      languages: data['languages'] == null ? [] : data['languages'],
      ordersNumbers: data['ordersNumbers'] == null ? 0 : data['ordersNumbers'],
      price: data['price'] == null ? "0" : data['price'],
      chatPrice: data['chatPrice'] == null ? "0" : data['chatPrice'],
      tapBalance: data['tapBalance'] == null ? 0.0 : data['tapBalance'],
      balance: data['balance'] == null ? 0.0 : data['balance'],
      payedBalance: data['payedBalance'] == null ? 0.0 : data['payedBalance'],
      voice: data['voice'] == null ? false : data['voice'],
      chat: data['chat'] == null ? false : data['chat'],
      isDeveloper: data['isDeveloper'] == null ? false : data['isDeveloper'],
      photoUrl: data['photoUrl'],
      tokenId: data['tokenId'],
      searchIndex: data['searchIndex'],
      loggedInVia: data['loggedInVia'],
      createdDate: data['createdDate'],
      createdDateValue: data['createdDateValue'],
      fullName: data['fullName'],
      fullAddress: data['fullAddress'],
      bankName: data['bankName'],
      bankAccountNumber: data['bankAccountNumber'],
      personalIdUrl: data['personalIdUrl'],
      fromUtc: data['fromUtc'],
      toUtc: data['toUtc'],
    );
  }
}

class ConsultName {
  String? nameAr;
  String? nameEn;
  String? nameFr;
  String? nameId;
  List<dynamic>? searchIndexAr;
  List<dynamic>? searchIndexEn;
  List<dynamic>? searchIndexFr;
  List<dynamic>? searchIndexId;
  ConsultName(
      {this.nameAr,
      this.nameEn,
      this.nameFr,
      this.nameId,
      this.searchIndexAr,
      this.searchIndexEn,
      this.searchIndexFr,
      this.searchIndexId});

  factory ConsultName.fromHashmap(Map<String, dynamic> Details) {
    return ConsultName(
      nameAr: Details['nameAr'] == null ? " " : Details['nameAr'],
      nameEn: Details['nameEn'] == null ? " " : Details['nameEn'],
      nameFr: Details['nameFr'] == null ? " " : Details['nameFr'],
      nameId: Details['nameId'] == null ? " " : Details['nameId'],
      searchIndexAr:
          Details['searchIndexAr'] == null ? [] : Details['searchIndexAr'],
      searchIndexEn:
          Details['searchIndexEn'] == null ? [] : Details['searchIndexEn'],
      searchIndexFr:
          Details['searchIndexFr'] == null ? [] : Details['searchIndexFr'],
      searchIndexId:
          Details['searchIndexId'] == null ? [] : Details['searchIndexId'],
    );
  }
}

class ConsultBio {
  String? bioAr;
  String? bioEn;
  String? bioFr;
  String? bioId;

  ConsultBio({
    this.bioAr,
    this.bioEn,
    this.bioFr,
    this.bioId,
  });

  factory ConsultBio.fromHashmap(Map<String, dynamic> Details) {
    return ConsultBio(
      bioAr: Details['bioAr'] == null ? " " : Details['bioAr'],
      bioEn: Details['bioEn'] == null ? " " : Details['bioEn'],
      bioFr: Details['bioFr'] == null ? " " : Details['bioFr'],
      bioId: Details['bioId'] == null ? " " : Details['bioId'],
    );
  }
}

class ConsultNationality {
  String? nationalityAr;
  String? nationalityEn;
  String? nationalityFr;
  String? nationalityId;
  ConsultNationality({
    this.nationalityAr,
    this.nationalityEn,
    this.nationalityFr,
    this.nationalityId,
  });
  factory ConsultNationality.fromHashmap(Map<String, dynamic> Details) {
    return ConsultNationality(
      nationalityAr:
          Details['nationalityAr'] == null ? " " : Details['nationalityAr'],
      nationalityEn:
          Details['nationalityEn'] == null ? " " : Details['nationalityEn'],
      nationalityFr:
          Details['nationalityFr'] == null ? " " : Details['nationalityFr'],
      nationalityId:
          Details['nationalityId'] == null ? " " : Details['nationalityId'],
    );
  }
}

class Address {
  String? city;
  String? state;
  String? pincode;
  String? landmark;
  String? addressLine1;
  String? addressLine2;
  String? country;
  String? houseNo;

  Address({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.country,
    this.houseNo,
    this.landmark,
    this.pincode,
    this.state,
  });

  factory Address.fromHashmap(Map<String?, dynamic> address) {
    return Address(
      addressLine1: address['addressLine1'],
      addressLine2: address['addressLine2'],
      city: address['city'],
      country: address['country'],
      houseNo: address['houseNo'],
      landmark: address['landmark'],
      pincode: address['pincode'],
      state: address['state'],
    );
  }
}

class KeyValueModel {
  dynamic key;
  String? value;

  KeyValueModel({this.key, this.value});
}

class WorkTimes {
  String? from;
  String? to;
  WorkTimes({
    this.from,
    this.to,
  });

  factory WorkTimes.fromHashmap(Map<String?, dynamic> ranges) {
    return WorkTimes(
      from: ranges['from'],
      to: ranges['to'],
    );
  }
}
