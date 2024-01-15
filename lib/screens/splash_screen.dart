// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/models/setting.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/userAccountScreen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../blocs/account_bloc/account_bloc.dart';
import 'consultRules.dart';
import 'consultantDetailsScreen.dart';

class SplashScreen extends StatefulWidget {
  PendingDynamicLinkData? initialLink;

  SplashScreen(this.initialLink);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? userType;
  dynamic androidBuildNum, iosBuildNum;
  bool loading = true;
  late AccountBloc accountBloc;

  @override
  void initState() {
    super.initState();
    accountBloc = BlocProvider.of<AccountBloc>(context);
    Timer(Duration(milliseconds: 4000), () {
      checkUserAccount();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(35.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(),
                Image.asset(
                  AssetsManager.dreamLogoPurpleImagePath,
                  width: size.width * AppSize.w0_23,
                  height: size.height * AppSize.h0_10,
                ),
                SvgPicture.asset(
                 AssetsManager.dreamImagePath,
                  width: size.width * AppSize.w0_25,
                  height: size.height * AppSize.h0_3,
                ),
              ],
            ),
          ),
        )
        //Center(child: Image.asset('assets/applicationIcons/splashImage.png')),
        );
  }

  Future<void> checkUserAccount() async {
    GroceryUser? loggedUser;
    FirebaseFirestore.instance
        .collection(Paths.settingPath)
        .doc("pzBqiphy5o2kkzJgWUT7")
        .get()
        .then((value) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        androidBuildNum =
            Setting.fromMap(value.data() as Map).androidBuildNumber;
        iosBuildNum = Setting.fromMap(value.data() as Map).iosBuildNumber;
      });
      print(
          "int.parse(packageInfo.buildNumber)${int.parse(packageInfo.buildNumber)}");
      print("iosBuildNum$iosBuildNum}");
      if ((Platform.isAndroid &&
              int.parse(packageInfo.buildNumber) >= androidBuildNum) ||
          (Platform.isIOS &&
              int.parse(packageInfo.buildNumber) >= iosBuildNum)) {
        if (widget.initialLink != null) {
          if (FirebaseAuth.instance.currentUser != null) {
            var __user = await FirebaseFirestore.instance
                .collection('Users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get();
            loggedUser = GroceryUser.fromMap(__user.data() as Map);
          }
          final Uri link = widget.initialLink!.link;

          String result = link
              .toString()
              .replaceAll('https://dreamuser.page.link/consultant_id=', ' ');
          String consultantId = result.trim();
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(consultantId)
              .get()
              .then((value) async {
            GroceryUser currentUser = GroceryUser.fromMap(value.data() as Map);
            Navigator.pushNamed(context, '/home');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConsultantDetailsScreen(
                  consultant: currentUser,
                  loggedUser: loggedUser,
                  consultType: currentUser.voice! ? "voice" : "chat",
                ),
              ),
            );
          });
          return;
        } else if (FirebaseAuth.instance != null &&
            FirebaseAuth.instance.currentUser != null) {
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get()
              .then((value) async {
            GroceryUser currentUser = GroceryUser.fromMap(value.data() as Map);
            if (currentUser.isBlocked!) {
              await FirebaseAuth.instance.signOut();
              accountBloc.add(GetLoggedUserEvent());
              Navigator.popAndPushNamed(
                context,
                '/home',
                arguments: {
                  'userType': userType,
                },
              );
            } else if (currentUser.userType == AppConstants.consultant &&
                currentUser.profileCompleted == false)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => consultRuleScreen(user: currentUser),
                ),
              );
            else if (currentUser.userType != AppConstants.consultant &&
                currentUser.profileCompleted == false)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UserAccountScreen(user: currentUser, firstLogged: true),
                ),
              );
            //builder: (context) => CompleteUserProfileScreen(user:currentUser), ),);
            else
              Navigator.popAndPushNamed(
                context,
                '/home',
                arguments: {
                  'userType': userType,
                },
              );
          }).catchError((err) {
            errorLog("checkUserAccount", err.toString());
          });
        } else
          Navigator.popAndPushNamed(
            context,
            '/home',
            arguments: {
              'userType': userType,
            },
          );
      } else {
        Navigator.popAndPushNamed(context, '/ForceUpdateScreen');
      }
    }).catchError((err) {
      errorLog("checkUserAccount", err.toString());
    });
  }

  errorLog(String function, String error) async {
    String id = Uuid().v4();
    await FirebaseFirestore.instance
        .collection(Paths.errorLogPath)
        .doc(id)
        .set({
      'timestamp': Timestamp.now(),
      'id': id,
      'seen': false,
      'desc': error,
      'phone': "phone",
      'uid': "uid",
      'screen': "splash",
      'function': "checkUserAccount",
    });
  }
}
