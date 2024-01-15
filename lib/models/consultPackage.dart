


class consultPackage {
  String Id;
  dynamic price;
  dynamic discount;
  String consultUid;
  String type;
  bool active;
  dynamic callNum;


  consultPackage({
    required this.Id,
    this.price,
    required this.consultUid,
    required this.type,
    this.discount,
    required this.active,
    this.callNum,
  });
  factory consultPackage.fromMap(Map  data) {
    return consultPackage(
        Id: data['Id'],
        price: data['price'],
        type: data['type']==null?"voice":data['type'],
        discount: data['discount'],
        consultUid: data['consultUid'],
        active: data['active'],
        callNum: data['callNum']
    );
  }
  factory consultPackage.fromHashMap(Map<String, dynamic> review) {
    return consultPackage(
        Id: review['Id'],
        discount: review['discount'],
        price: review['price'],
        consultUid: review['consultUid'],
        active: review['active'],
        callNum: review['callNum'], type: review['type']
    );
  }
}