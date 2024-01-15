import 'dart:io';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:share_plus/share_plus.dart';

import '../models/apps_flyer_user.dart';
import '../models/promo_link.dart';
import '../models/referee_purchase.dart';
import '../models/user_invite_link.dart';
import '../models/user_promotion_link.dart';
import '../models/user_referral_registration.dart';
import 'firestore_service.dart';

/// Singleton service to handle all app flyer related services
class AppFlyerService {
  /* -------------------------------------------- */
  /*                 CONSTRUCTORS                 */
  /* -------------------------------------------- */
  /// Private constructor
  AppFlyerService._internal();

  /// Factory constructor to return the same instance of the service
  factory AppFlyerService() => _singleton;

  /* -------------------------------------------- */
  /*                   VARIABLES                  */
  /* -------------------------------------------- */
  /// Singleton instance of the service
  static final AppFlyerService _singleton = AppFlyerService._internal();

  /// App flyer sdk instance
  late final AppsflyerSdk _appsflyerSdk;

  /// Instance of the firestore service
  FirestoreService _firestoreService = FirestoreService.instance;

  /// Instance of the deep link if app was opened from a deep link
  UserInviteLink? userInviteLink;

  /// Instance of the promotion link if app was opened from a promotion link
  UserPromotionLink? userPromotionLink;

  /// Instance of the apps flyer user containing all the other user data related to the app flyer (referrer)
  AppsFlyerUser? appsFlyerReferrer;

  /// Instance of the apps flyer user containing all the app user data related to the app flyer (current app user)
  AppsFlyerUser? appsFlyerAppUser;

  /// Instance of the apps flyer user containing all the third person user data related to the app flyer (third person)
  AppsFlyerUser? appsFlyerThirdPerson;

  /// Instance of the promotion link if app was opened from a promotion link (referrer)
  PromoLink? promoLinkReferrer;

  /* -------------------------------------------- */
  /*                  MAIN API'S                  */
  /* -------------------------------------------- */
  /// Method to initialize the app flyer sdk
  Future<void> init(String? userId) async {
    // Create the app flyer options
    AppsFlyerOptions appsFlyerOptions = Platform.isAndroid
        ? AppsFlyerOptions(
            afDevKey: 'mrP9nrMmbUYnkWEwtkrTmF',
            appId: 'com.abdulazizahmed.dream',
            showDebug: true,
            timeToWaitForATTUserAuthorization: 50, // for iOS 14.5
            appInviteOneLink: "8CdZ", // Optional field
            disableAdvertisingIdentifier: false, // Optional field
            disableCollectASA: false,
          )
        : AppsFlyerOptions(
            afDevKey: 'mrP9nrMmbUYnkWEwtkrTmF',
            appId: '1515745954',
            showDebug: true,
            timeToWaitForATTUserAuthorization: 50, // for iOS 14.5
            appInviteOneLink: "8CdZ", // Optional field
            disableAdvertisingIdentifier: false, // Optional field
            disableCollectASA: false,
          );
    // Initialize the app flyer sdk
    _appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
    // Init the sdk
    await _appsflyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    // Listen to the deep link events
    _appsflyerSdk.onDeepLinking(
      (DeepLinkResult dp) async {
        try {
          switch (dp.status) {
            case Status.FOUND:
              final linkData = dp.deepLink?.clickEvent;
              if (linkData == null) return;

              // Getting campaign of the link
              final campaign = _getCampaign(linkData);

              // Checking whether the link is a user invitation link or a marketing link
              if (campaign == 'User-Invitation') {
                userInviteLink = UserInviteLink.fromDeepLinkValue(
                  linkData['deep_link_value'],
                  linkData['is_deferred'],
                );
                String? referralLink = await _getReferrerUserLink();
                userInviteLink = userInviteLink!.copyWith(link: referralLink);
              } else if (campaign == 'Marketing') {
                userPromotionLink = UserPromotionLink.fromDeepLinkValue(
                  linkData['deep_link_value'],
                  linkData['is_deferred'],
                );
              }
              if (userPromotionLink == null && userInviteLink == null) return;

              await _handleInitialDeepLink(campaign);
              break;
            case Status.NOT_FOUND:
              debugPrint("deep link not found");
              break;
            case Status.ERROR:
              debugPrint("deep link error: ${dp.error}");
              break;
            case Status.PARSE_ERROR:
              debugPrint("deep link status parsing error");
              break;
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      },
    );

    if (userId != null) await initAppFlyerUser(userId);
  }

  /// Method to initialize the app flyer user data
  Future<void> initAppFlyerUser(String userId) async {
    try {
      // Fetch the app user data related to the app flyer
      final appUserData = await _firestoreService.fetchUserData(userId: userId);
      if (appUserData != null) {
        appsFlyerAppUser = AppsFlyerUser.fromMap(appUserData);
        debugPrint('App User Data: $appsFlyerAppUser');
      }
    } catch (e) {
      debugPrint('Error initializing app flyer user: $e');
    }
  }

  /// Method to log an event to the app flyer sdk
  Future<void> logEvent(String eventName, Map eventValues) async {
    await _appsflyerSdk.logEvent(eventName, eventValues);
  }

  /// Method to send an invite link to a friend
  Future<void> inviteFriends(String userId, String name) async {
    if (appsFlyerAppUser?.inviteLink != null) {
      await _shareLink(appsFlyerAppUser!.inviteLink!);
    } else {
      AppsFlyerInviteLinkParams appsFlyerInviteLinkParams = AppsFlyerInviteLinkParams(
        campaign: 'User-Invitation',
        channel: 'Invitation',
        baseDeepLink: 'https://dreamonline.oneclick.me',
        referrerName: name,
        customerID: userId,
        customParams: {
          'deep_link_value': '$userId~User-Invitation',
        },
      );

      appsflyerSdk.generateInviteLink(
        appsFlyerInviteLinkParams,
        (result) async {
          String link = result['payload']['userInviteURL'];
          await updateCurrentUserInviteLink(link, userId);
          await _shareLink(link);
        },
        (error) {
          debugPrint('Error generating invite link: $error');
        },
      );
    }
  }

  /// Method to update the current user with the deep link data
  Future<void> updateCurrentUserDeepLinkDataAtRegistration(String currentUserId) async {
    if (userInviteLink == null && userPromotionLink == null) return; // || marketingInviteLink == null) return;

    String? campaign = userInviteLink?.campaign ?? userPromotionLink?.campaign;
    if (campaign == null) return;

    /* ---- HANDLING USER-INVITATION DEEP LINK ---- */
    if (campaign == 'User-Invitation') {
      await _updateCurrentUserAtRegistrationViaUserInvitation(currentUserId);
      return;
    }

    /* ------- HANDLING MARKETING DEEP LINK ------- */
    if (campaign == 'Marketing') {
      await _updateCurrentUserAtRegistrationViaMarketing(currentUserId);
      return;
    }
  }

  /// Method to update purchase status of the user (referrer and referee rewards)
  Future<void> updatePurchaseStatusOfUser({
    required String userId,
    required double amount,
    required String percentage,
    required String orderId,
    required String payWith,
    required DateTime purchasedAt,
  }) async {
    try {
      // Checking whether the user has a referrer
      if (appsFlyerAppUser?.referrerUid == null && appsFlyerAppUser?.promoLinkReferrerUid == null) return;

      // Tracking the purchase is the user's first purchase
      bool isFirstOrder = false;

      // Checking whether the user has a referrer or a promo link referrer
      if (appsFlyerAppUser?.referrerUid != null) {
        // Fetching first purchase data from firestore if this is first purchase by user
        final firstPurchaseData = await _firestoreService.getFirstPurchasesOfReferee(
          refereeUid: userId,
          referrerUid: appsFlyerAppUser!.referrerUid!,
        );
        if (firstPurchaseData.isEmpty) isFirstOrder = true;

        // If this the user's first order, then we need gave him and referrer reward
        if (isFirstOrder) {
          // Fetch the app user data related to the app flyer
          final appUserData = await _firestoreService.fetchUserData(userId: userId);
          if (appUserData != null) {
            appsFlyerAppUser = AppsFlyerUser.fromMap(appUserData);

            // Getting X% of the amount (10%)
            double xPercent = amount * 0.1;
            double balance = appsFlyerAppUser?.balance ?? 0;

            // Adding xPercent to the current user's balance (locally)
            appsFlyerAppUser = appsFlyerAppUser?.copyWith(balance: balance + xPercent);
            // Updating the current user's balance (remotely)
            await _firestoreService.updateUserData(
              userId: userId,
              data: {'balance': balance + xPercent},
            );

            // Getting referrer user data
            final referrerUserData = await _firestoreService.fetchUserData(userId: appsFlyerAppUser!.referrerUid!);
            if (referrerUserData != null) {
              appsFlyerReferrer = AppsFlyerUser.fromMap(referrerUserData);
              double referrerBalance = appsFlyerReferrer?.balance ?? 0.0;

              // Updating the referrer user's balance (remotely)
              await _firestoreService.updateUserData(
                userId: appsFlyerAppUser!.referrerUid!,
                data: {'balance': referrerBalance + xPercent},
              );
            }
          }
        }

        // Updating referrer referee purchases count
        await _firestoreService.updateUserData(
          userId: appsFlyerAppUser!.referrerUid!,
          data: {'invitedUsersPurchases': FieldValue.increment(1)},
        );
      } else {
        // Fetching first purchase data from firestore if this is first purchase by user
        final firstPurchaseData = await _firestoreService.getFirstPurchasesOfPromoReferee(
          refereeUid: userId,
          promoReferrerUid: appsFlyerAppUser!.promoLinkReferrerUid!,
        );
        if (firstPurchaseData.isEmpty) isFirstOrder = true;

        // Updating referrer referee purchases count
        await _firestoreService.updatePromoData(
          promoLindId: appsFlyerAppUser!.promoLinkReferrerUid!,
          data: {'invitedUsersPurchases': FieldValue.increment(1)},
        );
      }

      // Creating the referee purchase object
      final RefereePurchase refereePurchase = RefereePurchase(
        amount: amount,
        orderId: orderId,
        payWith: payWith,
        userId: userId,
        isFirstOrder: isFirstOrder,
        purchasedAt: purchasedAt,
        percentage: percentage,
      );
      // Adding the purchase to the referrer user or link (remotely)
      appsFlyerAppUser?.referrerUid != null
          ? await FirestoreService.instance.addRefereePurchase(
              referrerUid: appsFlyerAppUser!.referrerUid!,
              data: refereePurchase.toMap(),
            )
          : await FirestoreService.instance.addPromoRefereePurchase(
              promoReferrerUid: appsFlyerAppUser!.promoLinkReferrerUid!,
              data: refereePurchase.toMap(),
            );
    } catch (e) {
      debugPrint('Error updating user data: $e');
    }
  }

  /* -------------------------------------------- */
  /*                 HELPER API'S                 */
  /* -------------------------------------------- */
  /// Method to share the invite link to friends
  Future<void> _shareLink(String inviteLink) async {
    try {
      await Share.share(inviteLink, subject: 'Dream App Invitation');
    } catch (e) {
      debugPrint('Error sharing link: $e');
    }
  }

  /// Method to update the current user with the invite link
  Future<void> updateCurrentUserInviteLink(String inviteLink, String userId) async {
    try {
      // Update the user data (locally)
      appsFlyerAppUser = appsFlyerAppUser?.copyWith(inviteLink: inviteLink);

      // Update the user data (remotely)
      await _firestoreService.updateUserData(
        userId: userId,
        data: {'inviteLink': inviteLink},
      );
    } catch (e) {
      debugPrint('Error updating user data: $e');
    }
  }

  /// Method to update the user with the deep link status
  /// downloads/installs, visits, etc.
  Future<void> _handleInitialDeepLink(String? campaign) async {
    try {
      if (campaign == null) return;
      if (userInviteLink == null && userPromotionLink == null) return;

      /* ---- HANDLING USER-INVITATION DEEP LINK ---- */
      if (campaign == 'User-Invitation') {
        _handleInitialUserInvitationDeepLink();
        return;
      }

      /* ------- HANDLING MARKETING DEEP LINK ------- */
      if (campaign == 'Marketing') {
        _handleInitialMarketingDeepLink();
        return;
      }
    } catch (e) {
      debugPrint('Error updating user link status: $e');
    }
  }

  /* -------- USER-INVITE CAMPAIGN API'S -------- */
  /// Method to handle initial user invitation deep link
  void _handleInitialUserInvitationDeepLink() async {
    String? referrerUid = userInviteLink?.referrerUid;
    if (referrerUid != null) {
      // Fetch User Data
      final userData = await _firestoreService.fetchUserData(userId: referrerUid);
      if (userData == null) return;

      // Creating referrer user (Not on every link click but only on the first one)
      final bool isReferrer =
          (appsFlyerReferrer == null && appsFlyerAppUser?.referrerUid == null && appsFlyerAppUser?.promoLinkReferrerUid == null) ||
              appsFlyerAppUser?.referrerUid == referrerUid;
      if (isReferrer)
        appsFlyerReferrer = AppsFlyerUser.fromMap(userData);
      else
        appsFlyerThirdPerson = AppsFlyerUser.fromMap(userData);

      await _updateReferrerVisitsAndInstallDownloadCount(referrerUid, isReferrer);
    }
  }

  /// Method to update the user with the new data
  Future<void> _updateReferrerVisitsAndInstallDownloadCount(String referrerUserId, bool isReferrer) async {
    try {
      int inviteLinkVisits = isReferrer ? appsFlyerReferrer?.inviteLinkVisits ?? 0 : appsFlyerThirdPerson?.inviteLinkVisits ?? 0;
      int downloadsOrInstalls = isReferrer ? appsFlyerReferrer?.downloadsOrInstalls ?? 0 : appsFlyerThirdPerson?.downloadsOrInstalls ?? 0;
      inviteLinkVisits++;
      downloadsOrInstalls++;

      // Checking whether the link is deferred or not (deferred means the user installed new app from stores)
      bool isDeferred = (userInviteLink?.isDeferred == true);

      if (isReferrer) {
        // Update the referrer user data (locally)
        appsFlyerReferrer = appsFlyerReferrer?.copyWith(
          inviteLinkVisits: inviteLinkVisits,
          downloadsOrInstalls: isDeferred ? downloadsOrInstalls : null,
        );
      } else {
        // Update the third person user data (locally)
        appsFlyerThirdPerson = appsFlyerThirdPerson?.copyWith(
          inviteLinkVisits: inviteLinkVisits,
          downloadsOrInstalls: (userInviteLink?.isDeferred == true) ? downloadsOrInstalls : null,
        );
      }

      // Update the user data (remotely)
      await _firestoreService.updateUserData(
        userId: referrerUserId,
        data: {
          'inviteLinkVisits': inviteLinkVisits,
          if (isDeferred) 'downloadsOrInstalls': downloadsOrInstalls,
        },
      );
    } catch (e) {
      debugPrint('Error updating user data: $e');
    }
  }

  /// Method to update the current user with the deep link data at registration via user invitation
  Future<void> _updateCurrentUserAtRegistrationViaUserInvitation(String currentUserId) async {
    try {
      if (appsFlyerAppUser == null) {
        // Creating new user data (locally)
        appsFlyerAppUser = AppsFlyerUser(
          downloadsOrInstalls: 0,
          inviteLinkVisits: 0,
          balance: 0.0,
          referrerLink: userInviteLink?.link,
          referrerUid: userInviteLink?.referrerUid,
          campaign: userInviteLink?.campaign,
          invitedUsersPurchases: 0,
        );
      }

      // Updating current user data (remotely)
      await _firestoreService.updateUserData(userId: currentUserId, data: appsFlyerAppUser!.toMap());

      // Adding registration to the referrer user
      await _firestoreService.addRegistration(
        referrerUid: userInviteLink!.referrerUid!,
        data: UserReferralRegistration(registeredAt: DateTime.now(), userId: currentUserId).toMap(),
      );
    } catch (e) {
      debugPrint('Error updating user data: $e');
    }
  }

  /* --------- MARKETING CAMPAIGN API'S --------- */
  /// Method to handle initial marketing deep link
  Future<void> _handleInitialMarketingDeepLink() async {
    String? promoLinkId = userPromotionLink?.promoLinkUid;
    if (promoLinkId != null) {
      // Fetch promo link data
      final promoLinkData = await _firestoreService.fetchPromoLinkData(promoLinkId: promoLinkId);
      if (promoLinkData != null) {
        promoLinkReferrer = PromoLink.fromMap(promoLinkData);
      } else {
        promoLinkReferrer = PromoLink(
          promoLinkId: promoLinkId,
          promoLink: userPromotionLink?.link,
          linkVisits: 0,
          downloadOrInstalls: 0,
          invitedUsersPurchases: 0,
          usage: userPromotionLink?.usage,
          createdAt: DateTime.now(),
        );
      }

      await _updatePromoLinkVisitsAndInstallDownloadCount(promoLinkId, promoLinkData == null);
    }
  }

  /// Method to update the promo link with the new data
  Future<void> _updatePromoLinkVisitsAndInstallDownloadCount(promoLinkId, [isFirstTime = false]) async {
    try {
      int promoLinkVisits = promoLinkReferrer?.linkVisits ?? 0;
      int downloadsOrInstalls = promoLinkReferrer?.downloadOrInstalls ?? 0;
      promoLinkVisits++;
      downloadsOrInstalls++;

      // Checking whether the link is deferred or not (deferred means the user installed new app from store)
      bool isDeferred = (userPromotionLink?.isDeferred == true);

      // Update the promo link data (locally)
      promoLinkReferrer = promoLinkReferrer?.copyWith(
        linkVisits: promoLinkVisits,
        downloadOrInstalls: isDeferred ? downloadsOrInstalls : null,
      );
      if (isFirstTime) {
        // Update the promo link data (remotely)
        await _firestoreService.createPromo(
          promoLindId: promoLinkId,
          data: promoLinkReferrer!.toMap(),
        );
      } else {
        // Update the promo link data (remotely)
        await _firestoreService.updatePromoData(
          promoLindId: promoLinkId,
          data: {
            'linkVisits': promoLinkVisits,
            if (isDeferred) 'downloadOrInstalls': downloadsOrInstalls,
          },
        );
      }
    } catch (e) {
      debugPrint('Error updating promo link data: $e');
    }
  }

  /// Method to update the current user with the deep link data at registration via marketing
  Future<void> _updateCurrentUserAtRegistrationViaMarketing(String currentUserId) async {
    try {
      if (appsFlyerAppUser == null) {
        // Creating new user data (locally)
        appsFlyerAppUser = AppsFlyerUser(
          downloadsOrInstalls: 0,
          inviteLinkVisits: 0,
          balance: 0.0,
          referrerLink: userPromotionLink?.link,
          promoLinkReferrerUid: userPromotionLink?.promoLinkUid,
          campaign: userPromotionLink?.campaign,
          invitedUsersPurchases: 0,
        );
      }

      // Updating current user data (remotely)
      await _firestoreService.updateUserData(userId: currentUserId, data: appsFlyerAppUser!.toMap());

      // Adding registration to the referrer user
      await _firestoreService.addPromoRegistration(
        promoReferrerUid: userPromotionLink!.promoLinkUid!,
        data: UserReferralRegistration(registeredAt: DateTime.now(), userId: currentUserId).toMap(),
      );
    } catch (e) {
      debugPrint('Error updating user data: $e');
      // Adding registration to the referrer user
      await _firestoreService.addPromoRegistration(
        promoReferrerUid: userPromotionLink!.promoLinkUid!,
        data: UserReferralRegistration(registeredAt: DateTime.now(), userId: currentUserId).toMap(),
      );
    }
  }

  /// Method to get campaign from link data
  String _getCampaign(Map<String, dynamic> linkData) {
    return linkData['deep_link_value'].toString().split('~')[1].toString();
  }

  /// Method to get referrer user link
  Future<String?> _getReferrerUserLink() async {
    final userData = await _firestoreService.fetchUserData(userId: userInviteLink!.referrerUid!);
    return userData?['inviteLink'];
  }

  /// Clear all the variables
  void clear() {
    userInviteLink = null;
    userPromotionLink = null;
    appsFlyerAppUser = null;
    appsFlyerReferrer = null;
    appsFlyerThirdPerson = null;
    promoLinkReferrer = null;
  }

  /* -------------------------------------------- */
  /*               GETTER & SETTERS               */
  /* -------------------------------------------- */
  /// Getter for the app flyer sdk
  AppsflyerSdk get appsflyerSdk => _appsflyerSdk;
}
