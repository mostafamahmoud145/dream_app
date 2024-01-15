import 'package:flutter/foundation.dart' show immutable;

/// AppsFlyerUser user model for AppsFlyer related data
@immutable
class AppsFlyerUser {
  const AppsFlyerUser({
    this.inviteLinkVisits,
    this.downloadsOrInstalls,
    this.balance,
    this.referrerUid,
    this.promoLinkReferrerUid,
    this.referrerLink,
    this.inviteLink,
    this.campaign,
    this.invitedUsersPurchases,
  });

  final int? inviteLinkVisits;
  final int? downloadsOrInstalls;
  final double? balance;
  final String? referrerUid;
  final String? promoLinkReferrerUid;
  final String? referrerLink;
  final String? campaign;
  final String? inviteLink;
  final int? invitedUsersPurchases;

  AppsFlyerUser copyWith({
    int? inviteLinkVisits,
    int? downloadsOrInstalls,
    double? balance,
    String? referrerUid,
    String? promoLinkReferrerUid,
    String? referrerLink,
    String? campaign,
    String? inviteLink,
    int? invitedUsersPurchases,
  }) {
    return AppsFlyerUser(
      inviteLinkVisits: inviteLinkVisits ?? this.inviteLinkVisits,
      downloadsOrInstalls: downloadsOrInstalls ?? this.downloadsOrInstalls,
      balance: balance ?? this.balance,
      referrerUid: referrerUid ?? this.referrerUid,
      promoLinkReferrerUid: promoLinkReferrerUid ?? this.promoLinkReferrerUid,
      referrerLink: referrerLink ?? this.referrerLink,
      campaign: campaign ?? this.campaign,
      inviteLink: inviteLink ?? this.inviteLink,
      invitedUsersPurchases: invitedUsersPurchases ?? this.invitedUsersPurchases,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'inviteLinkVisits': inviteLinkVisits,
      'downloadsOrInstalls': downloadsOrInstalls,
      'balance': balance,
      'referrerUid': referrerUid,
      'promoLinkReferrerUid': promoLinkReferrerUid,
      'referrerLink': referrerLink,
      'inviteLink': inviteLink,
      'campaign': campaign,
      'invitedUsersPurchases': invitedUsersPurchases,
    };
  }

  factory AppsFlyerUser.fromMap(Map<String, dynamic> map) {
    return AppsFlyerUser(
      inviteLinkVisits: map['inviteLinkVisits'] != null ? map['inviteLinkVisits'] as int : null,
      downloadsOrInstalls: map['downloadsOrInstalls'] != null ? map['downloadsOrInstalls'] as int : null,
      balance: map['balance'] != null ? (map['balance'] is int ? (map['balance'] as int).toDouble() : map['balance'] as double) : null,
      referrerUid: map['referrerUid'] != null ? map['referrerUid'] as String : null,
      promoLinkReferrerUid: map['promoLinkReferrerUid'] != null ? map['promoLinkReferrerUid'] as String : null,
      campaign: map['campaign'] != null ? map['campaign'] as String : null,
      referrerLink: map['referrerLink'] != null ? map['referrerLink'] as String : null,
      inviteLink: map['inviteLink'] != null ? map['inviteLink'] as String : null,
      invitedUsersPurchases: map['invitedUsersPurchases'] != null ? map['invitedUsersPurchases'] as int : null,
    );
  }

  @override
  String toString() {
    return 'AppsFlyerUser(inviteLinkVisits: $inviteLinkVisits, downloadsOrInstalls: $downloadsOrInstalls, balance: $balance, referrerUid: $referrerUid, referrerLink: $referrerLink, inviteLink: $inviteLink, invitedUsersPurchases: $invitedUsersPurchases, campaign: $campaign, promoLinkReferrerUid: $promoLinkReferrerUid)';
  }
}
