import 'package:flutter/foundation.dart' show immutable;

/// RefereePurchase model (When referee purchase a product)
@immutable
class RefereePurchase {
  RefereePurchase({
    required this.userId,
    required this.amount,
    required this.orderId,
    required this.payWith,
    required this.isFirstOrder,
    required this.purchasedAt,
    required this.percentage,
  });

  final String userId;
  final double amount;
  final String orderId;
  final String payWith;
  final bool isFirstOrder;
  final String percentage;
  final DateTime purchasedAt;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'amount': amount,
      'orderId': orderId,
      'payWith': payWith,
      'percentage': percentage,
      'isFirstOrder': isFirstOrder,
      'purchasedAt': purchasedAt.millisecondsSinceEpoch,
    };
  }

  factory RefereePurchase.fromMap(Map<String, dynamic> map) {
    return RefereePurchase(
      userId: map['userId'] as String,
      amount: map['amount'] as double,
      orderId: map['orderId'] as String,
      payWith: map['payWith'] as String,
      percentage: map['percentage'] as String,
      isFirstOrder: map['isFirstOrder'] as bool,
      purchasedAt: DateTime.fromMillisecondsSinceEpoch(map['purchasedAt'] as int),
    );
  }
}
