import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;

/// Singleton class to manage Firestore database queries.
class FirestoreService {
  /* -------------------------------------------- */
  /*                 CONSTRUCTORS                 */
  /* -------------------------------------------- */
  /// Private constructor.
  FirestoreService._();

  /// Factory getter to return the same instance of the class.
  static FirestoreService get instance => _firestoreService ??= FirestoreService._();

  /* -------------------------------------------- */
  /*                   VARIABLES                  */
  /* -------------------------------------------- */
  /// Singleton instance of the class.
  static FirestoreService? _firestoreService;

  /// Singleton instance of the Firestore database.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /* -------------------------------------------- */
  /*                  MAIN API'S                  */
  /* -------------------------------------------- */
  /// Fetches the user data from Firestore.
  Future<Map<String, dynamic>?> fetchUserData({
    required String userId,
  }) async {
    try {
      final documentSnapshot = await _firestore.collection('Users').doc(userId).get();
      if (!documentSnapshot.exists) return null;
      return documentSnapshot.data();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
    return null;
  }

  /// Updates the user data in Firestore.
  Future<void> updateUserData({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('Users').doc(userId).update(data);
    } catch (e) {
      debugPrint('Error updating user data: $e');
    }
  }

  /// Creates the promotion data in Firestore.
  Future<void> createPromo({
    required String promoLindId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('promotions').doc(promoLindId).set(data);
    } catch (e) {
      debugPrint('Error creating promo data: $e');
    }
  }

  /// Updates the promotion data in Firestore.
  Future<void> updatePromoData({
    required String promoLindId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('promotions').doc(promoLindId).update(data);
    } catch (e) {
      debugPrint('Error updating promo data: $e');
    }
  }

  /// Add a new referral registration to a referrer document.
  Future<void> addRegistration({
    required String referrerUid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('Users').doc(referrerUid).collection('referralRegistrations').add(data);
    } catch (e) {
      debugPrint('Error adding registration: $e');
    }
  }

  /// Add a new referral registration to a promo referrer document.
  Future<void> addPromoRegistration({
    required String promoReferrerUid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('promotions').doc(promoReferrerUid).collection('referralRegistrations').add(data);
    } catch (e) {
      debugPrint('Error adding registration: $e');
    }
  }

  /// Add referee purchase to a referrer document.
  Future<void> addRefereePurchase({
    required String referrerUid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('Users').doc(referrerUid).collection('refereePurchases').add(data);
    } catch (e) {
      debugPrint('Error adding registration: $e');
    }
  }

  /// Add referee purchase to a promo referrer document.
  Future<void> addPromoRefereePurchase({
    required String promoReferrerUid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('promotions').doc(promoReferrerUid).collection('refereePurchases').add(data);
    } catch (e) {
      debugPrint('Error adding registration: $e');
    }
  }

  /// Fetches the first purchases of a referee. (users collection)
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getFirstPurchasesOfReferee({
    required String refereeUid,
    required String referrerUid,
  }) async {
    try {
      final res = await _firestore
          .collection('Users')
          .doc(referrerUid)
          .collection('refereePurchases')
          .where('userId', isEqualTo: refereeUid)
          .where('isFirstOrder', isEqualTo: true)
          .get();

      return res.docs;
    } catch (e) {
      debugPrint('Error getting first purchases of referee: $e');
    }
    return [];
  }

  /// Fetches the first purchases of a referee. ( collection)
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getFirstPurchasesOfPromoReferee({
    required String refereeUid,
    required String promoReferrerUid,
  }) async {
    try {
      final res = await _firestore
          .collection('promotions')
          .doc(promoReferrerUid)
          .collection('refereePurchases')
          .where('userId', isEqualTo: refereeUid)
          .where('isFirstOrder', isEqualTo: true)
          .get();

      return res.docs;
    } catch (e) {
      debugPrint('Error getting first purchases of referee: $e');
    }
    return [];
  }

  /// Fetches the promo link data from Firestore.
  Future<Map<String, dynamic>?> fetchPromoLinkData({
    required String promoLinkId,
  }) async {
    try {
      final documentSnapshot = await _firestore.collection('promotions').doc(promoLinkId).get();
      if (!documentSnapshot.exists) return null;
      return documentSnapshot.data();
    } catch (e) {
      debugPrint('Error fetching promo link data: $e');
    }
    return null;
  }
}
