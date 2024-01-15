
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../../config/paths.dart';
import '../../providers/base_provider.dart';

class AuthenticationProvider extends BaseAuthenticationProvider {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String _verificationCode = '';


  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void dispose() {}

  @override
  Future<User?> getCurrentUser() async {
    return firebaseAuth.currentUser;
  }


  @override
  Future<bool> signOutUser() async {
    try {
      Future.wait([
        firebaseAuth.signOut(),
      ]);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> isLoggedIn() async {
    final user = firebaseAuth.currentUser;

    if (user != null) {
      //check if blocked

      DocumentSnapshot snapshot = await db.collection(Paths.usersPath).doc(user.uid).get();
      Map data =snapshot.data() as Map;
      //snapshot.data();

      if (snapshot.exists) {

        if (data['isBlocked']) {
          await firebaseAuth.signOut();
          return 'Your consaultant_details_widgets has been blocked';
        } else {
          return 'userType is' + data['userType'];
        }
      } else {
        await firebaseAuth.signOut();
        return 'Account does not exist';
      }
    } else {

      return null;
    }
  }

  @override
  Future<bool> signInWithphoneNumber(String phoneNumber) async {
    try {
      int? forceResendToken;
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: (authCredential) =>
            phoneVerificationCompleted(authCredential),
        verificationFailed: (authException) =>
            phoneVerificationFailed(authException, phoneNumber),
        codeSent: (verificationId, [code]) =>
            phoneCodeSent(verificationId, [code!]),
        codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout,
        forceResendingToken: forceResendToken,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  phoneVerificationCompleted(PhoneAuthCredential authCredential) {
  }

  phoneVerificationCompleted2(AuthCredential authCredential) {
  }

  phoneVerificationFailed(FirebaseException authException, String phone) async {
    String id = Uuid().v4();
    await FirebaseFirestore.instance
        .collection(Paths.errorLogPath)
        .doc(id)
        .set({
      'timestamp': Timestamp.now(),
      'id': id,
      'seen': false,
      'desc': authException.message.toString(),
      'phone': phone,
      'screen': "otp",
      'function': authException.code.toString(),
    });
  }

  phoneCodeAutoRetrievalTimeout(String verificationCode) {
    this._verificationCode = verificationCode;
  }

  phoneCodeSent(String verificationCode, List<int> code) {
    this._verificationCode = verificationCode;
  }

  @override
  Future<User?> signInWithSmsCode(String smsCode) async {
    try {
      AuthCredential authCredential = PhoneAuthProvider.credential(
          verificationId: _verificationCode, smsCode: smsCode);
      UserCredential authResult =
      await firebaseAuth.signInWithCredential(authCredential);
      if (authResult.user != null) {
        return authResult.user;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> checkIfBlocked(String phoneNumber) async {
    try {
      //check if blocked
      QuerySnapshot snapshot = await db
          .collection(Paths.usersPath)
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (snapshot.size > 0) {
        for (var item in snapshot.docs) {
          Map<String, dynamic> data = item.data() as Map<String, dynamic> ;
          if (data['isBlocked']) {
            return 'Your consaultant_details_widgets has been blocked';
          }
        }
      } else {
        return 'Account does not exist';
      }
      return '';
    } catch (e) {
      return null;
    }
  }
}
