class PromoLink {
  PromoLink({
    this.promoLinkId,
    this.promoLink,
    this.linkVisits,
    this.downloadOrInstalls,
    this.invitedUsersPurchases,
    this.usage,
    this.createdAt,
  });

  final String? promoLinkId;
  final String? promoLink;
  final int? linkVisits;
  final int? downloadOrInstalls;
  final int? invitedUsersPurchases;
  final String? usage;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'promoLinkId': promoLinkId,
      'promoLink': promoLink,
      'linkVisits': linkVisits,
      'downloadOrInstalls': downloadOrInstalls,
      'invitedUsersPurchases': invitedUsersPurchases,
      'usage': usage,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory PromoLink.fromMap(Map<String, dynamic> map) {
    return PromoLink(
      promoLinkId: map['promoLinkId'] != null ? map['promoLinkId'] as String : null,
      promoLink: map['promoLink'] != null ? map['promoLink'] as String : null,
      linkVisits: map['linkVisits'] != null ? map['linkVisits'] as int : null,
      downloadOrInstalls: map['downloadOrInstalls'] != null ? map['downloadOrInstalls'] as int : null,
      invitedUsersPurchases: map['invitedUsersPurchases'] != null ? map['invitedUsersPurchases'] as int : null,
      usage: map['usage'] != null ? map['usage'] as String : null,
      createdAt: map['createdAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int) : null,
    );
  }

  PromoLink copyWith({
    String? promoLinkId,
    String? promoLink,
    int? linkVisits,
    int? downloadOrInstalls,
    int? invitedUsersPurchases,
    String? usage,
    DateTime? createdAt,
  }) {
    return PromoLink(
      promoLinkId: promoLinkId ?? this.promoLinkId,
      promoLink: promoLink ?? this.promoLink,
      linkVisits: linkVisits ?? this.linkVisits,
      downloadOrInstalls: downloadOrInstalls ?? this.downloadOrInstalls,
      invitedUsersPurchases: invitedUsersPurchases ?? this.invitedUsersPurchases,
      usage: usage ?? this.usage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
