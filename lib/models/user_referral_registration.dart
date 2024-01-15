import 'package:flutter/foundation.dart' show immutable;

@immutable
class UserReferralRegistration {
  const UserReferralRegistration({
    this.userId,
    this.registeredAt,
  });

  final String? userId;
  final DateTime? registeredAt;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'registeredAt': registeredAt?.millisecondsSinceEpoch,
    };
  }

  factory UserReferralRegistration.fromMap(Map<String, dynamic> map) {
    return UserReferralRegistration(
      userId: map['userId'] != null ? map['userId'] as String : null,
      registeredAt: map['registeredAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['registeredAt'] as int) : null,
    );
  }
}
