import 'package:flutter/foundation.dart' show immutable;

@immutable
class UserPromotionLink {
  UserPromotionLink({
    this.link,
    this.campaign,
    this.usage,
    this.promoLinkUid,
    this.isDeferred,
  });

  final String? link;
  final String? campaign;
  final String? usage;
  final String? promoLinkUid;
  final bool? isDeferred;

  factory UserPromotionLink.fromDeepLinkValue(
    String deepLinkValue,
    bool isDeferred,
  ) {
    List<String> values = deepLinkValue.split('~');
    if (values.length != 4) throw Exception('No deeplink value found');
    return UserPromotionLink(
      link: values[0],
      campaign: values[1],
      usage: values[2],
      promoLinkUid: values[3],
      isDeferred: isDeferred,
    );
  }
}
