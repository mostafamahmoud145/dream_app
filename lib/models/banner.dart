


class banner {
  bool? status;
  String? id;
  String?  phone;
  String? name;
  String? uid;
  String? image;
  String?lang;
  banner({
    this.id,
    this.status,
    this.phone,
    this.name,
    this.image,
    this.uid,
    this.lang,

  });

  factory banner.fromMap(Map  data) {
    return banner(
      id: data['id'],
      status: data['status'],
      phone: data['phone'],
      name: data['name'],
      image: data['image'],
      uid: data['uid'],
      lang: data['lang'],
    );
  }
}
