


class PayInfo {
  String? id;
  String? consultUid;
  String? title;
  String? fullNameEn;
  String? fullNameAr;
  String? email;
  String? phone;
  String? countryCode;
  String? countryISOCode;
  String? dateOfBirth;

  String? personalFrontUrl;
  String? personalBackUrl;
  String? personalFrontUrlId;
  String? personalBackUrlId;
  String? startDate;
  String? endDate;

  String? bankName;
  String? bankAccountNumber;
  String? iban;
  String? swift;

  String? address1;
  String? address2;
  String? district;
  String? city;
  String? zip_code;
  String? siteUrl;


  String? businessId;
  String? entityId;
  String? destinationId;

  PayInfo({
    this.id,
    this.consultUid,
    this.title,
    this.fullNameAr,
    this.fullNameEn,
    this.email,
    this.phone,
    this.countryCode,
    this.countryISOCode,
    this.dateOfBirth,

    this.personalFrontUrl,
    this.personalBackUrl,
    this.personalFrontUrlId,
    this.personalBackUrlId,
    this.startDate,
    this.endDate,

    this.bankName,
    this.bankAccountNumber,
    this.swift,
    this.iban,

    this.address1,
    this.address2,
    this.district,
    this.city,
    this.zip_code,

    this.siteUrl,
    this.businessId,
    this. entityId,
    this.destinationId,

  });
  factory PayInfo.fromMap(Map  data) {
    return PayInfo(
        id:data['id'],
        consultUid: data['consultUid'],
        title:data['title'],
        fullNameEn: data['fullNameEn'],
        fullNameAr: data['fullNameAr'],
        email: data['email'],
        phone: data['phone'],
        countryCode: data['countryCode'],
        countryISOCode:data['countryISOCode'],
        dateOfBirth: data['dateOfBirth'],
        personalFrontUrl: data['personalFrontUrl'],
        personalBackUrl:data['personalBackUrl'],
        personalFrontUrlId:data['personalFrontUrlId'],
        personalBackUrlId:data['personalBackUrlId'],
        startDate: data['startDate'],
        endDate: data['endDate'],
        bankAccountNumber:data['bankAccountNumber'],
        bankName:data['bankName'],
        iban: data['iban'],
        swift: data['swift'],
        address1:data['address1'],
        address2:data['address2'],
        district:data['district'],
        city: data['city'],
        zip_code: data['zip_code'],
        siteUrl:data['siteUrl'],
        businessId:data['businessId'],
        entityId:data['entityId'],
        destinationId: data['destinationId'],
    );
  }
}