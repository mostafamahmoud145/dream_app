// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart' show immutable;

@immutable
class UserInviteLink {
  UserInviteLink({
    this.link,
    this.campaign,
    this.referrerUid,
    this.isDeferred,
  });

  final String? link;
  final String? campaign;
  final String? referrerUid;
  final bool? isDeferred;

  factory UserInviteLink.fromDeepLinkValue(
    String deepLinkValue,
    bool isDeferred,
  ) {
    List<String> values = deepLinkValue.split('~');
    if (values.length != 2) throw Exception('No deeplink value found');
    return UserInviteLink(
      campaign: values.last,
      referrerUid: values.first,
      isDeferred: isDeferred,
    );
  }

  UserInviteLink copyWith({
    String? link,
    String? campaign,
    String? referrerUid,
    bool? isDeferred,
  }) {
    return UserInviteLink(
      link: link ?? this.link,
      campaign: campaign ?? this.campaign,
      referrerUid: referrerUid ?? this.referrerUid,
      isDeferred: isDeferred ?? this.isDeferred,
    );
  }
}
