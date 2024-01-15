import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart' as db;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/blocs/web_rtc_bloc/start_call.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/methods/parse_duration.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/pages/AppointmentsPage.dart';
import 'package:grocery_store/pages/CallHistoryPage.dart';
import 'package:grocery_store/pages/TechnicalSupportPage.dart';
import 'package:grocery_store/pages/home_page.dart';
import 'package:grocery_store/screens/noInternet.dart';
import 'package:grocery_store/screens/searchScreen.dart';
import 'package:grocery_store/screens/userAccountScreen.dart';
import 'package:grocery_store/shared%20preferences/shared_preferences.dart';
import 'package:grocery_store/tool_tip/custom_tooltip.dart';
import 'package:grocery_store/tool_tip/tooltib_model.dart';
import 'package:grocery_store/tool_tip/tooltip_manager.dart';
import 'package:grocery_store/tool_tip/tooltip_progress.dart';
import 'package:grocery_store/widget/IconButton.dart';
import 'package:grocery_store/widget/component/TextFormFieldWidget.dart';
import 'package:grocery_store/widget/searchbar.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:lottie/lottie.dart';

import '../blocs/account_bloc/account_bloc.dart';
import '../blocs/rate_bloc/cuibt/cuibt.dart';
import '../blocs/rate_bloc/cuibt/states.dart';
import '../config/colorsFile.dart';
import '../models/user_notification.dart';
import '../services/firebase_service.dart';
import '../widget/TextButton.dart';
import '../widget/drawerWidget.dart';
import '../widget/dreamDialogsWidget.dart';
import 'DevelopTechSupport/allDevelopSupport.dart';
import 'account_screen.dart';
import 'consultantDetailsScreen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  final int? notificationPage;

  const HomeScreen({Key? key, this.notificationPage}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static FirebaseDatabase database = FirebaseDatabase.instanceFor(
      app: Firebase.app(), databaseURL: AppConstants.dataBaseUrl);
  static final realtimeDbRef = database.ref();
  final InAppReview inAppReview = InAppReview.instance;
  late int _selectedPage;
  late PageController _pageController;
  late int cartCount;
  late NotificationBloc notificationBloc;
  late UserNotification userNotification;
  late AccountBloc accountBloc;

  GroceryUser user = new GroceryUser();
  String userType = "",
      theme = "light",
      userImage = "",
      lang = "",
      userName = "";

  late Size size;
  User? currentUser = FirebaseAuth.instance.currentUser;
  bool load = true, first = true;
  Map mainVal = {};
  Map secondVal = {};
  DateTime targetDate = DateTime(2023, 10, 1);
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  ToolTipKeysManager _toolTipKeysManager= ToolTipKeysManager();
  @override
  void initState() {
    super.initState();
    initConnectivity();
    FirebaseFirestore.instance.collection('Users').doc(user.uid).get();

    if (FirebaseAuth.instance.currentUser != null) {
      checkIfTheSenderCanceled();
    }

    if (widget.notificationPage != null)
      _selectedPage = widget.notificationPage!;
    else
      _selectedPage = 0;
    _pageController = PageController(initialPage: _selectedPage);
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetLoggedUserEvent());
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    notificationBloc.stream.listen((state) {});
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      print(e.toString());
      return;
    }
    return _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    _connectionStatus = result;
    if (_connectionStatus == ConnectivityResult.none) {
      // Not connected to any network, navigate to a specific screen
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => NoInternet()));
    } else {}
  }

  /// check the sender cancel the call.
  checkIfTheSenderCanceled() {
    FirebaseDatabase.instance
        .ref('userCallState')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('callState')
        .onValue
        .listen((event) {
      if (event.snapshot.value == 'closed') {
        FlutterCallkitIncoming.endAllCalls();
        //CallKeep.instance.endAllCalls();
      }
    });
  }

  DateTime specificDate = DateTime(2023, 10, 1);

  void trigerCallMethod() {
    realtimeDbRef
        .child('userCallState')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .onValue
        .listen((event) async {
      var value = Map<String, dynamic>.from(
          event.snapshot.value! as Map<Object?, Object?>);
      if (value['callState'] == 'calling') {
        if (value['roomId'] != null) {
          if (value['callerID'] != null &&
              value['callerID'] != FirebaseAuth.instance.currentUser!.uid) {
            bool acceptcall = false;

            Future(() => StartCall(
                    host: value['roomId'],
                    iscaller: false,
                    acceptNotfi: acceptcall,
                    normalCall: value['isNormal'] ?? true,
                    CallerId: value['callerID'],
                    ReciverId: value['reciverId'],
                    context: context)
                .startCall());
          }
        }
      }

      realtimeDbRef
          .child('userCallState')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .onDisconnect()
          .set({
        'callState': 'closed',
        'timeStamp': db.ServerValue.timestamp,
        'roomId': value['roomId'],
        'callerID': value['callerID'],
        'reciverId': value['reciverId']
      });
    });
  }

  @override
  void didChangeDependencies() {
    GroceryUser? loggedUser;
    super.didChangeDependencies();
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
      if (dynamicLinkData != null) {
        if (FirebaseAuth.instance.currentUser != null) {
          var __user = await FirebaseFirestore.instance
              .collection('Users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();
          loggedUser = GroceryUser.fromMap(__user.data() as Map);
        }
        String result = dynamicLinkData.link
            .toString()
            .replaceAll('https://dreamuser.page.link/consultant_id=', ' ');
        String consultantId = result.trim();
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(consultantId)
            .get()
            .then((value) async {
          GroceryUser currentUser = GroceryUser.fromMap(value.data() as Map);
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
      }
      // Navigator.pushNamed(context, dynamicLinkData.link.path);
    }).onError((error) {});
  }

  @override
  Widget build(BuildContext context) {
    if ((CashHelper.getData(key: 'rate') == null)) {
      Future.delayed(Duration(seconds: 1), () {
        Duration twoHours = Duration(hours: 2);
        Duration total = CashHelper.getData(key: 'time') != null
            ? parseDuration(CashHelper.getData(key: 'time'))
            : Duration(hours: 0);
        if ((twoHours <= total) && currentUser != null) {
          showDialog(
              context: context,
              builder: (context) {
                return rateReactionsDialog();
              });
          CashHelper.saveData(
              key: 'time', value: Duration(microseconds: 0).toString());
        }
      });
    }
    if ((CashHelper.getData(key: 'survey') == null)) {
      Future.delayed(Duration(seconds: 1), () {
        Duration halfHour = Duration(minutes: 30);
        Duration total = CashHelper.getData(key: 'surveyTime') != null
            ? parseDuration(CashHelper.getData(key: 'surveyTime'))
            : Duration(minutes: 0);
        if ((halfHour <= total) &&
            currentUser != null &&
            user.userType == "USER") {
          showDialog(
              context: context,
              builder: (context) {
                return showStartSurveyDialog();
              });
          CashHelper.saveData(
              key: 'surveyTime', value: Duration(microseconds: 0).toString());
        }
      });
    }
    size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        // floatingActionButton: FloatingActionButton(onPressed: () {
        //   // showStartSurveyDialog();

        //   showPermissionsDialog(
        //     context: context,
        //     text: getTranslated(context, 'getSettings'),
        //     buttonTitle: getTranslated(context, 'goToSettings'),
        //     function: () {
        //       Navigator.pop(context);
        //       AppSettings.openAppSettings(
        //         type: AppSettingsType.settings,
        //       );
        //     },
        //     refusedFunction: () {
        //       Navigator.pop(context);
        //     },
        //   );
        //   // showFirstStepSurvey();
        // }),
        backgroundColor: AppColors.white,
        drawer: DrawerWidget(),
        key: _scaffoldKey,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
              color: Colors.white54,
              border: Border(
                  top: BorderSide(width: AppSize.w0_5, color: AppColors.grey))),
          //height: Platform.isAndroid ? 67.h : 100.h,
          height: AppSize.h89.h,
          width: size.width,
          child: BlocBuilder(
            bloc: accountBloc,
            builder: (context, state) {
              if (state is GetLoggedUserInProgressState) {
                return Center(child: userBottomNavigation());
              } else if (state is GetLoggedUserCompletedState) {
                user = state.user;
                print('USER>>>>>>${user.userType}');

                if (mounted & first) {
                  FirebaseService.init(context, currentUser!.uid, currentUser!);
                  notificationBloc
                      .add(GetAllNotificationsEvent(currentUser!.uid));
                  first = false;
                }
                return (user!.userType != "CONSULTANT")
                    ? userBottomNavigation()
                    : consultBottomNavigation();
              } else {
                return Center(child: userBottomNavigation());
              }
            },
          ),
        ),
        body: Column(
          children: <Widget>[
            headerWidget(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  HomePage(
                    userType: userType,
                  ), //0
                  AppointmentsPage(), //1
                  TechnicalSupportPage(), //2
                  CallHistoryPage(), //3
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget userBottomNavigation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          //mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _pageController.jumpToPage(
                    0,
                  );
                  setState(() {
                    _selectedPage = 0;
                  });
                },
                child: Container(
                  key: _toolTipKeysManager.consultantTipKey,
                  width: AppSize.w40.w,
                  color: AppColors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          _selectedPage == 0
                              ? AssetsManager.dream_icon_logo1
                              : AssetsManager.dream_icon_logo2,
                          width: 40.w,
                          height: 40.h,
                        ),
                        Text(
                          getTranslated(context, "schedule"),
                          style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithralight'),
                            color: _selectedPage == 0
                                ? AppColors.linear2
                                : AppColors.grey3,
                            fontSize: AppFontsSizeManager.s16.sp,
                            fontWeight: AppFontsWeightManager.regular,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (FirebaseAuth.instance.currentUser == null) {
                    Navigator.pushNamed(context, '/Register_Type');
                  } else {
                    _pageController.jumpToPage(
                      1,
                    );
                  }

                  setState(() {
                    _selectedPage = 1;
                  });
                },

                child: Container(
                  key: _toolTipKeysManager.appointmentTip,
                  width: AppSize.w40.w,
                  color: AppColors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          _selectedPage == 1
                              ? AssetsManager.purple_calender_iconPath
                              : AssetsManager.grey_calender_iconPath,
                          width: AppSize.w40.w,
                          height: AppSize.h40.h,
                        ),
                        Text(
                          getTranslated(context, "appointments"),
                          style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithralight'),
                            color: _selectedPage == 1
                                ? AppColors.linear2
                                : AppColors.grey3,
                            fontSize: AppFontsSizeManager.s16.sp,
                            fontWeight: AppFontsWeightManager.bold300,
                            fontStyle: FontStyle.normal,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                //   ),
                // ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (FirebaseAuth.instance.currentUser == null) {
                    Navigator.pushNamed(context, '/Register_Type');
                  } else {
                    _pageController.jumpToPage(
                      2,
                    );
                  }
                  setState(() {
                    _selectedPage = 2;
                  });
                },
                child: Container(
                  key: _toolTipKeysManager.supportCenterTipKey,
                  width: 40.w,
                  color: AppColors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          _selectedPage == 2
                              ? AssetsManager.headphone_iconPath
                              : AssetsManager.support_headphone_iconPath,
                          width: AppSize.w40.w,
                          height: AppSize.h40.h,
                        ),
                        Text(
                          getTranslated(context, "support"),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithralight'),
                            color: _selectedPage == 2
                                ? AppColors.linear2
                                : AppColors.grey3,
                            fontSize: AppFontsSizeManager.s16.sp,
                            fontWeight: AppFontsWeightManager.bold300,
                            fontStyle: FontStyle.normal,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget consultBottomNavigation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Container(color: AppColors.lightGrey, height: 1, width: size.width),
        Padding(
          padding:
              const EdgeInsets.only(top: AppPadding.p1, bottom: AppPadding.p4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                key: _toolTipKeysManager.consultantAppointmentToolTipKey,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (FirebaseAuth.instance.currentUser == null) {
                      Navigator.pushNamed(context, '/Register_Type');
                    } else {
                      _pageController.jumpToPage(
                        0,
                      );
                    }

                    setState(() {
                      _selectedPage = 0;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        _selectedPage == 0
                            ? AssetsManager.purple_calender_iconPath
                            : AssetsManager.grey_calender_iconPath,
                        width: AppSize.w38.r,
                        height: AppSize.h38.r,
                      ),
                      Text(
                        getTranslated(context, "appointments"),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          color: _selectedPage == 0
                              ? Theme.of(context).primaryColor
                              : AppColors.grey,
                          fontSize: AppFontsSizeManager.s13.sp,
                          fontWeight: AppFontsWeightManager.semiBold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                key: _toolTipKeysManager.consultantCallHistoryToolTipKey,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _pageController.jumpToPage(
                      3,
                    );
                    setState(() {
                      _selectedPage = 3;
                    });
                  },
                  child: Container(
                    width: size.width * AppSize.w0_33,
                    color: AppColors.white,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AssetsManager.grey_transfer_iconPath,
                            width: AppSize.w38.r,
                            height: AppSize.h38.r,
                            color: _selectedPage == 3
                                ? AppColors.pink
                                : AppColors.grey,
                          ),
                          Text(
                            getTranslated(context, "callHistory"),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              color: _selectedPage == 3
                                  ? Theme.of(context).primaryColor
                                  : AppColors.grey,
                              fontSize: AppFontsSizeManager.s13.sp,
                              fontWeight: AppFontsWeightManager.regular,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                key: _toolTipKeysManager.consultantSupportCenterTipKey,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (FirebaseAuth.instance.currentUser == null) {
                      Navigator.pushNamed(context, '/Register_Type');
                    } else {
                      _pageController.jumpToPage(
                        2,
                      );
                    }
                    setState(() {
                      _selectedPage = 2;
                    });
                  },
                  child: Container(
                    width: size.width * AppSize.w0_33,
                    color: AppColors.white,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            _selectedPage == 2
                                ? AssetsManager.headphone_iconPath
                                : AssetsManager.support_headphone_iconPath,
                            width: AppSize.w38.r,
                            height: AppSize.h38.r,
                          ),
                          Text(
                            getTranslated(context, "support"),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              color: _selectedPage == 2
                                  ? Theme.of(context).primaryColor
                                  : AppColors.grey,
                              fontSize: AppFontsSizeManager.s13.sp,
                              fontWeight: AppFontsWeightManager.regular,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget headerWidget() {
    lang = getTranslated(context, "lang");
    return Column(
      children: [
        Container(
          width: size.width,
          decoration: BoxDecoration(
            color: AppColors.white,
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: AppPadding.p32.h),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: AppPadding.p32.w,
                    right: AppPadding.p32.w,
                    top: AppPadding.p75.h,
                    //bottom: AppPadding.p32.h
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            IconButton1(
                              radius: AppRadius.r10_6.r,
                              color: AppColors.white,
                              shadowcolor: AppColors.warmPurple,
                              iconsize: AppSize.w30,
                              icon: AssetsManager.drower_iconPath,
                              iconcolor: AppColors.linear2,
                              onPress: () {
                                if (_scaffoldKey.currentState!.isDrawerOpen) {
                                  _scaffoldKey.currentState!.openEndDrawer();
                                } else {
                                  _scaffoldKey.currentState!.openDrawer();
                                }
                              },
                              width: AppSize.w50_6.w,
                              height: AppSize.h50_6.h,
                            ),

                            user.userType == "CONSULTANT" && _selectedPage == 3
                                ? currentUser == null
                                    ? noNotificationWidget()
                                    : BlocBuilder(
                                        bloc: notificationBloc,
                                        buildWhen: (previous, current) {
                                          if (current is GetAllNotificationsInProgressState ||
                                              current
                                                  is GetAllNotificationsFailedState ||
                                              current
                                                  is GetAllNotificationsCompletedState ||
                                              current
                                                  is GetNotificationsUpdateState) {
                                            return true;
                                          }
                                          return false;
                                        },
                                        builder: (context, state) {
                                          if (state
                                              is GetAllNotificationsInProgressState) {
                                            return noNotificationWidget();
                                          }
                                          if (state
                                              is GetNotificationsUpdateState) {
                                            if (state.userNotification !=
                                                null) {
                                              if (state.userNotification
                                                      .notifications.length ==
                                                  0) {
                                                return noNotificationWidget();
                                              }
                                              userNotification =
                                                  state.userNotification;
                                              if (userNotification.notifications.length >=
                                                  200)
                                                Fluttertoast.showToast(
                                                    msg: getTranslated(context,
                                                        "removeNotification"),
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.TOP,
                                                    backgroundColor: Colors.red,
                                                    textColor: AppColors.white,
                                                    fontSize:
                                                        AppFontsSizeManager
                                                            .s16.sp);
                                              return Stack(
                                                alignment: Alignment.center,
                                                children: <Widget>[
                                                  ///**------------------>>>>>SHOW TOOL TIPS FOR USER<<<<<------------------**///
                                                  if (user.userType !=
                                                      "CONSULTANT")
                                                    CustomTooltipManager(
                                                      tooltips: [
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "notificationToolTipText"),
                                                          _toolTipKeysManager
                                                              .notificationTipKey,
                                                          Offset(
                                                              lang == "ar"
                                                                  ? 232.w
                                                                  : 67.w,
                                                              -2.h),
                                                          "save1",
                                                        ),
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "searchToolTipText"),
                                                          _toolTipKeysManager
                                                              .searchTipKey,
                                                          Offset(120.w, 0.h),
                                                          "save2",
                                                        ),
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "viewProfileToolTipText"),
                                                          _toolTipKeysManager
                                                              .viewProfileTipKey,
                                                          Offset(
                                                              170.w,
                                                              lang == "ar"
                                                                  ? 380.h
                                                                  : 365.h),
                                                          "save3",
                                                        ),
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "consultantTipText"),
                                                          _toolTipKeysManager
                                                              .consultantTipKey,
                                                          Offset(
                                                              lang == "ar"
                                                                  ? 293.w
                                                                  : -50.w,
                                                              lang == "ar"
                                                                  ? 835.h
                                                                  : 810.h),
                                                          "save4",
                                                        ),
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "appointmentToolTipText"),
                                                          _toolTipKeysManager
                                                              .appointmentTip,
                                                          Offset(
                                                              164.w,
                                                              lang == "ar"
                                                                  ? 835.h
                                                                  : 810.h),
                                                          "save5",
                                                        ),
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "supportToolTipText"),
                                                          _toolTipKeysManager
                                                              .supportCenterTipKey,
                                                          Offset(
                                                              lang == "ar"
                                                                  ? 5.w
                                                                  : 253.w,
                                                              lang == "ar"
                                                                  ? 835.h
                                                                  : 810.h),
                                                          "save6",
                                                        ),
                                                      ],
                                                      tooltipBuilder: (context,
                                                          message,
                                                          showNext,
                                                          currentIndex,
                                                          total) {
                                                        return Column(
                                                          children: [
                                                            Stack(
                                                              alignment: Alignment
                                                                  .bottomCenter,
                                                              children: [
                                                                if (currentIndex ==
                                                                        0 ||
                                                                    currentIndex ==
                                                                        1)
                                                                  Padding(
                                                                    key: _toolTipKeysManager
                                                                        .viewProfileTipKey,
                                                                    padding: EdgeInsets.only(
                                                                        left: currentIndex == 0
                                                                            ? lang == "ar"
                                                                                ? 170.w
                                                                                : 0
                                                                            : 0,
                                                                        right: currentIndex == 0
                                                                            ? lang == "ar"
                                                                                ? 0.w
                                                                                : 170.w
                                                                            : 0),
                                                                    child: Lottie.asset(
                                                                        'assets/lotifile/tool_tip_animation.json',
                                                                        width: AppSize
                                                                            .w100
                                                                            .w,
                                                                        height: AppSize
                                                                            .h100
                                                                            .h),
                                                                  ),
                                                                if (currentIndex ==
                                                                        0 ||
                                                                    currentIndex ==
                                                                        1)
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        left: currentIndex == 0
                                                                            ? lang == "ar"
                                                                                ? 170.w
                                                                                : 0
                                                                            : 0,
                                                                        right: currentIndex == 0
                                                                            ? lang == "ar"
                                                                                ? 0.w
                                                                                : 170.w
                                                                            : 0),
                                                                    child:
                                                                        ClipPath(
                                                                      clipper:
                                                                          TriangleClipper(),
                                                                      child:
                                                                          Container(
                                                                        width: AppSize
                                                                            .w21_3
                                                                            .w,
                                                                        height: AppSize
                                                                            .h10_6
                                                                            .h,
                                                                        color: AppColors
                                                                            .linear2,
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                            GestureDetector(
                                                              onTap: showNext,
                                                              child: Container(
                                                                width: lang ==
                                                                        "ar"
                                                                    ? AppSize
                                                                        .w272.w
                                                                    : AppSize
                                                                        .w277.w,
                                                                height: lang == "ar"
                                                                    ? AppSize
                                                                        .h221.h
                                                                    : AppSize
                                                                        .h255.h,
                                                                child: Theme(
                                                                  data: Theme.of(
                                                                          context)
                                                                      .copyWith(
                                                                    colorScheme:
                                                                        ColorScheme.light(
                                                                            primary:
                                                                                AppColors.white),
                                                                  ),
                                                                  child: Card(
                                                                    color: AppColors
                                                                        .white,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(AppRadius
                                                                              .r16
                                                                              .r),
                                                                      side: BorderSide(
                                                                          color: AppColors
                                                                              .linear2,
                                                                          width: AppSize
                                                                              .w1
                                                                              .w),
                                                                    ),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            IconButton(
                                                                                onPressed: () {
                                                                                  //Navigator.(context);
                                                                                },
                                                                                icon: Icon(
                                                                                  Icons.close,
                                                                                  color: AppColors.linear2,
                                                                                  size: AppSize.w21.r,
                                                                                ))
                                                                          ],
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsets.only(
                                                                              right: AppPadding.p16.w,
                                                                              left: AppPadding.p10.w,
                                                                              bottom: AppPadding.p10.h),
                                                                          child:
                                                                              Text(
                                                                            message,
                                                                            style:
                                                                                TextStyle(
                                                                              color: AppColors.linear2,
                                                                              fontFamily: lang == "ar" ? getTranslated(context, "Ithra") : getTranslated(context, "Montserrat-SemiBold"),
                                                                              fontSize: AppFontsSizeManager.s16.sp,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsets.only(
                                                                              right: AppPadding.p20.w,
                                                                              left: lang == "ar" ? 0 : AppPadding.p20.w),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Container(
                                                                                width: 70,
                                                                                height: 7,
                                                                                child: ToolTipProgressListView(
                                                                                  select: currentIndex,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: AppSize.w30.w,
                                                                              ),
                                                                              Container(
                                                                                width: AppSize.w80.w,
                                                                                height: AppSize.h40.h,
                                                                                decoration: BoxDecoration(
                                                                                  color: AppColors.linear2,
                                                                                  borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                                                                                  gradient: LinearGradient(
                                                                                    begin: Alignment(0.5, 0),
                                                                                    end: Alignment(0.5, 1),
                                                                                    colors: [
                                                                                      AppColors.linear1,
                                                                                      AppColors.linear2,
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                child: GestureDetector(
                                                                                  onTap: showNext,
                                                                                  child: Center(
                                                                                    child: Text(
                                                                                      getTranslated(context, "goNext"),
                                                                                      style: TextStyle(
                                                                                        color: AppColors.white,
                                                                                        fontFamily: getTranslated(context, "Ithra"),
                                                                                        fontSize: AppFontsSizeManager.s13_5.sp,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  boxShadow: [
                                                                    new BoxShadow(
                                                                      color: Color.fromRGBO(
                                                                          156,
                                                                          57,
                                                                          129,
                                                                          0.1),
                                                                      blurRadius:
                                                                          16.r,
                                                                      spreadRadius:
                                                                          0.0,
                                                                      offset: Offset(
                                                                          0.0,
                                                                          1.0),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            if (currentIndex == 2 ||
                                                                currentIndex ==
                                                                    3 ||
                                                                currentIndex ==
                                                                    4 ||
                                                                currentIndex ==
                                                                    5)
                                                              Stack(
                                                                alignment:
                                                                    Alignment
                                                                        .topCenter,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        left: currentIndex == 2
                                                                            ? 160.w
                                                                            : currentIndex == 3
                                                                                ? 100.w
                                                                                : currentIndex == 5
                                                                                    ? lang == "ar"
                                                                                        ? 0
                                                                                        : 110
                                                                                    : 0,
                                                                        right: currentIndex == 4
                                                                            ? 23.w
                                                                            : currentIndex == 5
                                                                                ? 90.w
                                                                                : currentIndex == 3
                                                                                    ? lang == "ar"
                                                                                        ? 0
                                                                                        : 150
                                                                                    : 0),
                                                                    child: Lottie.asset(
                                                                        'assets/lotifile/tool_tip_animation.json',
                                                                        width: AppSize
                                                                            .w100
                                                                            .w,
                                                                        height: AppSize
                                                                            .h100
                                                                            .h),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        left: currentIndex == 2
                                                                            ? 160.w
                                                                            : currentIndex == 3
                                                                                ? 100.w
                                                                                : currentIndex == 5
                                                                                    ? lang == "ar"
                                                                                        ? 0
                                                                                        : 110
                                                                                    : 0,
                                                                        right: currentIndex == 4
                                                                            ? 23.w
                                                                            : currentIndex == 5
                                                                                ? 90.w
                                                                                : currentIndex == 3
                                                                                    ? lang == "ar"
                                                                                        ? 0
                                                                                        : 150
                                                                                    : 0),
                                                                    child:
                                                                        RotationTransition(
                                                                      turns: new AlwaysStoppedAnimation(
                                                                          180 /
                                                                              360),
                                                                      child:
                                                                          ClipPath(
                                                                        clipper:
                                                                            TriangleClipper(),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              16,
                                                                          // Adjust the width as needed
                                                                          height:
                                                                              8,
                                                                          // Adjust the height as needed
                                                                          color:
                                                                              AppColors.linear2,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  if (user != null &&
                                                      user!.userType ==
                                                          "CONSULTANT" &&
                                                      first == false)
                                                    CustomTooltipManager(
                                                      tooltips: [
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "notificationToolTipText"),
                                                          _toolTipKeysManager
                                                              .notificationTipKey,
                                                          Offset(
                                                              lang == "ar"
                                                                  ? 232.w
                                                                  : 67.w,
                                                              -2.h),
                                                          "save7",
                                                        ),
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "searchToolTipText"),
                                                          _toolTipKeysManager
                                                              .searchTipKey,
                                                          Offset(120.w, 0.h),
                                                          "save8",
                                                        ),
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "consultantChatTipText"),
                                                          _toolTipKeysManager
                                                              .consultantChatToolTipKey,
                                                          Offset(
                                                              lang == "ar"
                                                                  ? 20.w
                                                                  : 240.w,
                                                              lang == "ar"
                                                                  ? -110.h
                                                                  : -160.h),
                                                          "save9",
                                                        ),
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "consultantAppointmentTipText"),
                                                          _toolTipKeysManager
                                                              .consultantAppointmentToolTipKey,
                                                          Offset(
                                                              lang == "ar"
                                                                  ? 297.w
                                                                  : -45.w,
                                                              lang == "ar"
                                                                  ? 850.h
                                                                  : 825.h),
                                                          "save10",
                                                        ),
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "consultantCallHistoryTipText"),
                                                          _toolTipKeysManager
                                                              .consultantCallHistoryToolTipKey,
                                                          Offset(
                                                              160.w,
                                                              lang == "ar"
                                                                  ? 850.h
                                                                  : 825.h),
                                                          "save11",
                                                        ),
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "supportToolTipText"),
                                                          _toolTipKeysManager
                                                              .consultantSupportCenterTipKey,
                                                          Offset(
                                                              lang == "ar"
                                                                  ? 5.w
                                                                  : 252.w,
                                                              lang == "ar"
                                                                  ? 850.h
                                                                  : 825.h),
                                                          "save12",
                                                        ),
                                                      ],
                                                      tooltipBuilder: (context,
                                                          message,
                                                          showNext,
                                                          currentIndex,
                                                          total) {
                                                        return Container(
                                                          child: Column(
                                                            children: [
                                                              if (currentIndex ==
                                                                      0 ||
                                                                  currentIndex ==
                                                                      1)
                                                                Stack(
                                                                  alignment:
                                                                      Alignment
                                                                          .bottomCenter,
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: currentIndex == 0
                                                                              ? lang == "ar"
                                                                                  ? 170.w
                                                                                  : 0
                                                                              : 0,
                                                                          right: currentIndex == 0
                                                                              ? lang == "ar"
                                                                                  ? 0.w
                                                                                  : 170.w
                                                                              : 0),
                                                                      child: Lottie.asset(
                                                                          'assets/lotifile/tool_tip_animation.json',
                                                                          width: AppSize
                                                                              .w100
                                                                              .w,
                                                                          height: AppSize
                                                                              .h100
                                                                              .h),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: currentIndex == 0
                                                                              ? lang == "ar"
                                                                                  ? 170.w
                                                                                  : 0
                                                                              : 0,
                                                                          right: currentIndex == 0
                                                                              ? lang == "ar"
                                                                                  ? 0.w
                                                                                  : 170.w
                                                                              : 0),
                                                                      child:
                                                                          ClipPath(
                                                                        clipper:
                                                                            TriangleClipper(),
                                                                        child:
                                                                            Container(
                                                                          width: AppSize
                                                                              .w21_3
                                                                              .w,
                                                                          height: AppSize
                                                                              .h10_6
                                                                              .h,
                                                                          color:
                                                                              AppColors.linear2,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              GestureDetector(
                                                                key: _toolTipKeysManager
                                                                    .consultantChatToolTipKey,
                                                                onTap: showNext,
                                                                child:
                                                                    Container(
                                                                  width: lang == "ar"
                                                                      ? AppSize
                                                                          .w272
                                                                          .w
                                                                      : AppSize
                                                                          .w277
                                                                          .w,
                                                                  height: lang == "ar"
                                                                      ? AppSize
                                                                          .h221
                                                                          .h
                                                                      : AppSize
                                                                          .h255
                                                                          .h,
                                                                  child: Theme(
                                                                    data: Theme.of(
                                                                            context)
                                                                        .copyWith(
                                                                      colorScheme:
                                                                          ColorScheme.light(
                                                                              primary: AppColors.white),
                                                                    ),
                                                                    child: Card(
                                                                      color: AppColors
                                                                          .white,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(AppRadius
                                                                            .r16
                                                                            .r),
                                                                        side: BorderSide(
                                                                            color:
                                                                                AppColors.linear2,
                                                                            width: AppSize.w1.w),
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              IconButton(
                                                                                  onPressed: () {
                                                                                    //Navigator.(context);
                                                                                  },
                                                                                  icon: Icon(
                                                                                    Icons.close,
                                                                                    color: AppColors.linear2,
                                                                                    size: AppSize.w21.r,
                                                                                  ))
                                                                            ],
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsets.only(
                                                                                right: AppPadding.p16.w,
                                                                                left: AppPadding.p10.w,
                                                                                bottom: AppPadding.p10.h),
                                                                            child:
                                                                                Text(
                                                                              message,
                                                                              style: TextStyle(
                                                                                color: AppColors.black,
                                                                                fontFamily: lang == "ar" ? getTranslated(context, "Ithra") : getTranslated(context, "Montserrat-SemiBold"),
                                                                                fontSize: AppFontsSizeManager.s16.sp,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.only(right: AppPadding.p20.w, left: lang == "ar" ? 0 : AppPadding.p20.w),
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                Container(
                                                                                  width: 70,
                                                                                  height: 7,
                                                                                  child: ToolTipProgressListView(
                                                                                    select: currentIndex,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  width: AppSize.w30.w,
                                                                                ),
                                                                                Container(
                                                                                  width: AppSize.w80.w,
                                                                                  height: AppSize.h40.h,
                                                                                  decoration: BoxDecoration(
                                                                                    color: AppColors.linear2,
                                                                                    borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                                                                                    gradient: LinearGradient(
                                                                                      begin: Alignment(0.5, 0),
                                                                                      end: Alignment(0.5, 1),
                                                                                      colors: [
                                                                                        AppColors.linear1,
                                                                                        AppColors.linear2,
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  child: GestureDetector(
                                                                                    onTap: showNext,
                                                                                    child: Center(
                                                                                      child: Text(
                                                                                        getTranslated(context, "goNext"),
                                                                                        style: TextStyle(
                                                                                          color: AppColors.white,
                                                                                          fontFamily: getTranslated(context, "Ithra"),
                                                                                          fontSize: AppFontsSizeManager.s13_5.sp,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    boxShadow: [
                                                                      new BoxShadow(
                                                                        color: Color.fromRGBO(
                                                                            156,
                                                                            57,
                                                                            129,
                                                                            0.1),
                                                                        blurRadius:
                                                                            16.r,
                                                                        spreadRadius:
                                                                            0.0,
                                                                        offset: Offset(
                                                                            0.0,
                                                                            1.0),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              if (currentIndex == 2 ||
                                                                  currentIndex ==
                                                                      3 ||
                                                                  currentIndex ==
                                                                      4 ||
                                                                  currentIndex ==
                                                                      5)
                                                                Stack(
                                                                  alignment:
                                                                      Alignment
                                                                          .topCenter,
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: currentIndex == 2
                                                                              ? 0.w
                                                                              : currentIndex == 3
                                                                                  ? 90.w
                                                                                  : currentIndex == 5
                                                                                      ? lang == "ar"
                                                                                          ? 0
                                                                                          : 110
                                                                                      : 0,
                                                                          right: currentIndex == 4
                                                                              ? 23.w
                                                                              : currentIndex == 5
                                                                                  ? 90.w
                                                                                  : currentIndex == 3
                                                                                      ? lang == "ar"
                                                                                          ? 0
                                                                                          : 150
                                                                                      : 0),
                                                                      child: Lottie.asset(
                                                                          'assets/lotifile/tool_tip_animation.json',
                                                                          width: AppSize
                                                                              .w100
                                                                              .w,
                                                                          height: AppSize
                                                                              .h100
                                                                              .h),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: currentIndex == 2
                                                                              ? 0.w
                                                                              : currentIndex == 3
                                                                                  ? 90.w
                                                                                  : currentIndex == 5
                                                                                      ? lang == "ar"
                                                                                          ? 0
                                                                                          : 110
                                                                                      : 0,
                                                                          right: currentIndex == 4
                                                                              ? 23.w
                                                                              : currentIndex == 5
                                                                                  ? 90.w
                                                                                  : currentIndex == 3
                                                                                      ? lang == "ar"
                                                                                          ? 0
                                                                                          : 150
                                                                                      : 0),
                                                                      child:
                                                                          RotationTransition(
                                                                        turns: new AlwaysStoppedAnimation(180 /
                                                                            360),
                                                                        child:
                                                                            ClipPath(
                                                                          clipper:
                                                                              TriangleClipper(),
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                16,
                                                                            // Adjust the width as needed
                                                                            height:
                                                                                8,
                                                                            // Adjust the height as needed
                                                                            color:
                                                                                AppColors.linear2,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  Container(
                                                    key: _toolTipKeysManager
                                                        .notificationTipKey,
                                                    height: AppSize.h50_5.h,
                                                    width: AppSize.w50_5.w,
                                                    decoration: decoration(),
                                                    child: Center(
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    AppRadius
                                                                        .r50),
                                                        child: Material(
                                                          color:
                                                              AppColors.white,
                                                          child: InkWell(
                                                            splashColor:
                                                                AppColors.white
                                                                    .withOpacity(
                                                                        0.6),
                                                            onTap: () {
                                                              if (userNotification
                                                                  .unread) {
                                                                notificationBloc
                                                                    .add(
                                                                  NotificationMarkReadEvent(
                                                                      currentUser!
                                                                          .uid),
                                                                );
                                                              }
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          NotificationScreen(
                                                                    userNotification:
                                                                        userNotification,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Image.asset(
                                                              theme == "light"
                                                                  ? AssetsManager
                                                                      .purple_notification_iconPath
                                                                  : AssetsManager
                                                                      .grey_notification_iconPath,
                                                              width: AppSize
                                                                  .w32_6.w,
                                                              height: AppSize
                                                                  .h36_6.h,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  userNotification.unread
                                                      ? Positioned(
                                                          right: AppPadding.p4,
                                                          top: AppPadding.p4,
                                                          child: Container(
                                                            height:
                                                                AppSize.h7_5,
                                                            width: AppSize.w7_5,
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color:
                                                                  Colors.yellow,
                                                            ),
                                                          ),
                                                        )
                                                      : SizedBox(),
                                                ],
                                              );
                                            }
                                            return noNotificationWidget();
                                          }
                                          return noNotificationWidget();
                                        },
                                      )
                                : currentUser == null
                                    ? noNotificationWidget()
                                    : BlocBuilder(
                                        bloc: notificationBloc,
                                        buildWhen: (previous, current) {
                                          if (current is GetAllNotificationsInProgressState ||
                                              current
                                                  is GetAllNotificationsFailedState ||
                                              current
                                                  is GetAllNotificationsCompletedState ||
                                              current
                                                  is GetNotificationsUpdateState) {
                                            return true;
                                          }
                                          return false;
                                        },
                                        builder: (context, state) {
                                          if (state
                                              is GetAllNotificationsInProgressState) {
                                            return noNotificationWidget();
                                          }
                                          if (state
                                              is GetNotificationsUpdateState) {
                                            if (state.userNotification !=
                                                null) {
                                              if (state.userNotification
                                                      .notifications.length ==
                                                  0) {
                                                return noNotificationWidget();
                                              }
                                              userNotification =
                                                  state.userNotification;
                                              if (userNotification.notifications.length >=
                                                  200)
                                                Fluttertoast.showToast(
                                                    msg: getTranslated(context,
                                                        "removeNotification"),
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.TOP,
                                                    backgroundColor: Colors.red,
                                                    textColor: AppColors.white,
                                                    fontSize:
                                                        AppFontsSizeManager
                                                            .s16.sp);
                                              return Stack(
                                                alignment: Alignment.center,
                                                children: <Widget>[
                                                  ///**------------------>>>>>SHOW TOOL TIPS FOR USER<<<<<------------------**///
                                                  if (user.userType !=
                                                      "CONSULTANT")
                                                    CustomTooltipManager(
                                                      tooltips: [
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "notificationToolTipText"),
                                                          _toolTipKeysManager
                                                              .notificationTipKey,
                                                          Offset(
                                                              lang == "ar"
                                                                  ? 232.w
                                                                  : 67.w,
                                                              -2.h),
                                                          "save1",
                                                        ),
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "searchToolTipText"),
                                                          _toolTipKeysManager
                                                              .searchTipKey,
                                                          Offset(120.w, 0.h),
                                                          "save2",
                                                        ),
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "viewProfileToolTipText"),
                                                          _toolTipKeysManager
                                                              .viewProfileTipKey,
                                                          Offset(
                                                              170.w,
                                                              lang == "ar"
                                                                  ? 380.h
                                                                  : 365.h),
                                                          "save3",
                                                        ),
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "consultantTipText"),
                                                          _toolTipKeysManager
                                                              .consultantTipKey,
                                                          Offset(
                                                              lang == "ar"
                                                                  ? 293.w
                                                                  : -50.w,
                                                              lang == "ar"
                                                                  ? 835.h
                                                                  : 810.h),
                                                          "save4",
                                                        ),
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "appointmentToolTipText"),
                                                          _toolTipKeysManager
                                                              .appointmentTip,
                                                          Offset(
                                                              164.w,
                                                              lang == "ar"
                                                                  ? 835.h
                                                                  : 810.h),
                                                          "save5",
                                                        ),
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "supportToolTipText"),
                                                          _toolTipKeysManager
                                                              .supportCenterTipKey,
                                                          Offset(
                                                              lang == "ar"
                                                                  ? 5.w
                                                                  : 253.w,
                                                              lang == "ar"
                                                                  ? 835.h
                                                                  : 810.h),
                                                          "save6",
                                                        ),
                                                      ],
                                                      tooltipBuilder: (context,
                                                          message,
                                                          showNext,
                                                          currentIndex,
                                                          total) {
                                                        return Column(
                                                          children: [
                                                            Stack(
                                                              alignment: Alignment
                                                                  .bottomCenter,
                                                              children: [
                                                                if (currentIndex ==
                                                                        0 ||
                                                                    currentIndex ==
                                                                        1)
                                                                  Padding(
                                                                    key: _toolTipKeysManager
                                                                        .viewProfileTipKey,
                                                                    padding: EdgeInsets.only(
                                                                        left: currentIndex == 0
                                                                            ? lang == "ar"
                                                                                ? 170.w
                                                                                : 0
                                                                            : 0,
                                                                        right: currentIndex == 0
                                                                            ? lang == "ar"
                                                                                ? 0.w
                                                                                : 170.w
                                                                            : 0),
                                                                    child: Lottie.asset(
                                                                        'assets/lotifile/tool_tip_animation.json',
                                                                        width: AppSize
                                                                            .w100
                                                                            .w,
                                                                        height: AppSize
                                                                            .h100
                                                                            .h),
                                                                  ),
                                                                if (currentIndex ==
                                                                        0 ||
                                                                    currentIndex ==
                                                                        1)
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        left: currentIndex == 0
                                                                            ? lang == "ar"
                                                                                ? 170.w
                                                                                : 0
                                                                            : 0,
                                                                        right: currentIndex == 0
                                                                            ? lang == "ar"
                                                                                ? 0.w
                                                                                : 170.w
                                                                            : 0),
                                                                    child:
                                                                        ClipPath(
                                                                      clipper:
                                                                          TriangleClipper(),
                                                                      child:
                                                                          Container(
                                                                        width: AppSize
                                                                            .w21_3
                                                                            .w,
                                                                        height: AppSize
                                                                            .h10_6
                                                                            .h,
                                                                        color: AppColors
                                                                            .linear2,
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                            GestureDetector(
                                                              // onTap: () async {
                                                              //   // print(
                                                              //   //     "////tippp${user.toolTip}");
                                                              //   //
                                                              //   // await FirebaseFirestore
                                                              //   //     .instance
                                                              //   //     .collection(
                                                              //   //         'Users')
                                                              //   //     .doc(user
                                                              //   //         .uid)
                                                              //   //     .set({
                                                              //   //   "toolTip": user
                                                              //   //       .toolTip,
                                                              //   // }, SetOptions(merge: true));
                                                              //   // print("tip2");
                                                              //   setState(() {
                                                              //     user.toolTip ==
                                                              //         "true";
                                                              //   });
                                                              // },
                                                              onTap: showNext,
                                                              child: Container(
                                                                width: lang ==
                                                                        "ar"
                                                                    ? AppSize
                                                                        .w272.w
                                                                    : AppSize
                                                                        .w277.w,
                                                                height: lang == "ar"
                                                                    ? AppSize
                                                                        .h221.h
                                                                    : AppSize
                                                                        .h255.h,
                                                                child: Theme(
                                                                  data: Theme.of(
                                                                          context)
                                                                      .copyWith(
                                                                    colorScheme:
                                                                        ColorScheme.light(
                                                                            primary:
                                                                                AppColors.white),
                                                                  ),
                                                                  child: Card(
                                                                    color: AppColors
                                                                        .white,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(AppRadius
                                                                              .r16
                                                                              .r),
                                                                      side: BorderSide(
                                                                          color: AppColors
                                                                              .linear2,
                                                                          width: AppSize
                                                                              .w1
                                                                              .w),
                                                                    ),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            IconButton(
                                                                                onPressed: () {
                                                                                  //Navigator.(context);
                                                                                },
                                                                                icon: Icon(
                                                                                  Icons.close,
                                                                                  color: AppColors.linear2,
                                                                                  size: AppSize.w21.r,
                                                                                ))
                                                                          ],
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsets.only(
                                                                              right: AppPadding.p16.w,
                                                                              left: AppPadding.p10.w,
                                                                              bottom: AppPadding.p10.h),
                                                                          child:
                                                                              Text(
                                                                            message,
                                                                            style:
                                                                                TextStyle(
                                                                              color: AppColors.linear2,
                                                                              fontFamily: lang == "ar" ? getTranslated(context, "Ithra") : getTranslated(context, "Montserrat-SemiBold"),
                                                                              fontSize: AppFontsSizeManager.s16.sp,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsets.only(
                                                                              right: AppPadding.p20.w,
                                                                              left: lang == "ar" ? 0 : AppPadding.p20.w),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Container(
                                                                                width: 70,
                                                                                height: 7,
                                                                                child: ToolTipProgressListView(
                                                                                  select: currentIndex,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: AppSize.w30.w,
                                                                              ),
                                                                              Container(
                                                                                width: AppSize.w80.w,
                                                                                height: AppSize.h40.h,
                                                                                decoration: BoxDecoration(
                                                                                  color: AppColors.linear2,
                                                                                  borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                                                                                  gradient: LinearGradient(
                                                                                    begin: Alignment(0.5, 0),
                                                                                    end: Alignment(0.5, 1),
                                                                                    colors: [
                                                                                      AppColors.linear1,
                                                                                      AppColors.linear2,
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                child: GestureDetector(
                                                                                  onTap: showNext,
                                                                                  child: Center(
                                                                                    child: Text(
                                                                                      getTranslated(context, "goNext"),
                                                                                      style: TextStyle(
                                                                                        color: AppColors.white,
                                                                                        fontFamily: getTranslated(context, "Ithra"),
                                                                                        fontSize: AppFontsSizeManager.s13_5.sp,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  boxShadow: [
                                                                    new BoxShadow(
                                                                      color: Color.fromRGBO(
                                                                          156,
                                                                          57,
                                                                          129,
                                                                          0.1),
                                                                      blurRadius:
                                                                          16.r,
                                                                      spreadRadius:
                                                                          0.0,
                                                                      offset: Offset(
                                                                          0.0,
                                                                          1.0),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            if (currentIndex == 2 ||
                                                                currentIndex ==
                                                                    3 ||
                                                                currentIndex ==
                                                                    4 ||
                                                                currentIndex ==
                                                                    5)
                                                              Stack(
                                                                alignment:
                                                                    Alignment
                                                                        .topCenter,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        left: currentIndex == 2
                                                                            ? 160.w
                                                                            : currentIndex == 3
                                                                                ? 100.w
                                                                                : currentIndex == 5
                                                                                    ? lang == "ar"
                                                                                        ? 0
                                                                                        : 110
                                                                                    : 0,
                                                                        right: currentIndex == 4
                                                                            ? 23.w
                                                                            : currentIndex == 5
                                                                                ? 90.w
                                                                                : currentIndex == 3
                                                                                    ? lang == "ar"
                                                                                        ? 0
                                                                                        : 150
                                                                                    : 0),
                                                                    child: Lottie.asset(
                                                                        'assets/lotifile/tool_tip_animation.json',
                                                                        width: AppSize
                                                                            .w100
                                                                            .w,
                                                                        height: AppSize
                                                                            .h100
                                                                            .h),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        left: currentIndex == 2
                                                                            ? 160.w
                                                                            : currentIndex == 3
                                                                                ? 100.w
                                                                                : currentIndex == 5
                                                                                    ? lang == "ar"
                                                                                        ? 0
                                                                                        : 110
                                                                                    : 0,
                                                                        right: currentIndex == 4
                                                                            ? 23.w
                                                                            : currentIndex == 5
                                                                                ? 90.w
                                                                                : currentIndex == 3
                                                                                    ? lang == "ar"
                                                                                        ? 0
                                                                                        : 150
                                                                                    : 0),
                                                                    child:
                                                                        RotationTransition(
                                                                      turns: new AlwaysStoppedAnimation(
                                                                          180 /
                                                                              360),
                                                                      child:
                                                                          ClipPath(
                                                                        clipper:
                                                                            TriangleClipper(),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              16,
                                                                          // Adjust the width as needed
                                                                          height:
                                                                              8,
                                                                          // Adjust the height as needed
                                                                          color:
                                                                              AppColors.linear2,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  if (user != null &&
                                                      user!.userType ==
                                                          "CONSULTANT" &&
                                                      first == false)
                                                    CustomTooltipManager(
                                                      tooltips: [
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "notificationToolTipText"),
                                                          _toolTipKeysManager
                                                              .notificationTipKey,
                                                          Offset(
                                                              lang == "ar"
                                                                  ? 232.w
                                                                  : 67.w,
                                                              -2.h),
                                                          "save7",
                                                        ),
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "searchToolTipText"),
                                                          _toolTipKeysManager
                                                              .searchTipKey,
                                                          Offset(120.w, 0.h),
                                                          "save8",
                                                        ),
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "consultantChatTipText"),
                                                          _toolTipKeysManager
                                                              .consultantChatToolTipKey,
                                                          Offset(
                                                              lang == "ar"
                                                                  ? 20.w
                                                                  : 240.w,
                                                              lang == "ar"
                                                                  ? -110.h
                                                                  : -160.h),
                                                          "save9",
                                                        ),
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "consultantAppointmentTipText"),
                                                          _toolTipKeysManager
                                                              .consultantAppointmentToolTipKey,
                                                          Offset(
                                                              lang == "ar"
                                                                  ? 297.w
                                                                  : -45.w,
                                                              lang == "ar"
                                                                  ? 850.h
                                                                  : 825.h),
                                                          "save10",
                                                        ),
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "consultantCallHistoryTipText"),
                                                          _toolTipKeysManager
                                                              .consultantCallHistoryToolTipKey,
                                                          Offset(
                                                              160.w,
                                                              lang == "ar"
                                                                  ? 850.h
                                                                  : 825.h),
                                                          "save11",
                                                        ),
                                                        TooltipData(
                                                          getTranslated(context,
                                                              "supportToolTipText"),
                                                          _toolTipKeysManager
                                                              .consultantSupportCenterTipKey,
                                                          Offset(
                                                              lang == "ar"
                                                                  ? 5.w
                                                                  : 252.w,
                                                              lang == "ar"
                                                                  ? 850.h
                                                                  : 825.h),
                                                          "save12",
                                                        ),
                                                      ],
                                                      tooltipBuilder: (context,
                                                          message,
                                                          showNext,
                                                          currentIndex,
                                                          total) {
                                                        return Container(
                                                          child: Column(
                                                            children: [
                                                              if (currentIndex ==
                                                                      0 ||
                                                                  currentIndex ==
                                                                      1)
                                                                Stack(
                                                                  alignment:
                                                                      Alignment
                                                                          .bottomCenter,
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: currentIndex == 0
                                                                              ? lang == "ar"
                                                                                  ? 170.w
                                                                                  : 0
                                                                              : 0,
                                                                          right: currentIndex == 0
                                                                              ? lang == "ar"
                                                                                  ? 0.w
                                                                                  : 170.w
                                                                              : 0),
                                                                      child: Lottie.asset(
                                                                          'assets/lotifile/tool_tip_animation.json',
                                                                          width: AppSize
                                                                              .w100
                                                                              .w,
                                                                          height: AppSize
                                                                              .h100
                                                                              .h),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: currentIndex == 0
                                                                              ? lang == "ar"
                                                                                  ? 170.w
                                                                                  : 0
                                                                              : 0,
                                                                          right: currentIndex == 0
                                                                              ? lang == "ar"
                                                                                  ? 0.w
                                                                                  : 170.w
                                                                              : 0),
                                                                      child:
                                                                          ClipPath(
                                                                        clipper:
                                                                            TriangleClipper(),
                                                                        child:
                                                                            Container(
                                                                          width: AppSize
                                                                              .w21_3
                                                                              .w,
                                                                          height: AppSize
                                                                              .h10_6
                                                                              .h,
                                                                          color:
                                                                              AppColors.linear2,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              GestureDetector(
                                                                key: _toolTipKeysManager
                                                                    .consultantChatToolTipKey,
                                                                onTap: showNext,
                                                                child:
                                                                    Container(
                                                                  width: lang == "ar"
                                                                      ? AppSize
                                                                          .w272
                                                                          .w
                                                                      : AppSize
                                                                          .w277
                                                                          .w,
                                                                  height: lang == "ar"
                                                                      ? AppSize
                                                                          .h221
                                                                          .h
                                                                      : AppSize
                                                                          .h255
                                                                          .h,
                                                                  child: Theme(
                                                                    data: Theme.of(
                                                                            context)
                                                                        .copyWith(
                                                                      colorScheme:
                                                                          ColorScheme.light(
                                                                              primary: AppColors.white),
                                                                    ),
                                                                    child: Card(
                                                                      color: AppColors
                                                                          .white,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(AppRadius
                                                                            .r16
                                                                            .r),
                                                                        side: BorderSide(
                                                                            color:
                                                                                AppColors.linear2,
                                                                            width: AppSize.w1.w),
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              IconButton(
                                                                                  onPressed: () {
                                                                                    //Navigator.(context);
                                                                                  },
                                                                                  icon: Icon(
                                                                                    Icons.close,
                                                                                    color: AppColors.linear2,
                                                                                    size: AppSize.w21.r,
                                                                                  ))
                                                                            ],
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsets.only(
                                                                                right: AppPadding.p16.w,
                                                                                left: AppPadding.p10.w,
                                                                                bottom: AppPadding.p10.h),
                                                                            child:
                                                                                Text(
                                                                              message,
                                                                              style: TextStyle(
                                                                                color: AppColors.black,
                                                                                fontFamily: lang == "ar" ? getTranslated(context, "Ithra") : getTranslated(context, "Montserrat-SemiBold"),
                                                                                fontSize: AppFontsSizeManager.s16.sp,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.only(right: AppPadding.p20.w, left: lang == "ar" ? 0 : AppPadding.p20.w),
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                Container(
                                                                                  width: 70,
                                                                                  height: 7,
                                                                                  child: ToolTipProgressListView(
                                                                                    select: currentIndex,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  width: AppSize.w30.w,
                                                                                ),
                                                                                Container(
                                                                                  width: AppSize.w80.w,
                                                                                  height: AppSize.h40.h,
                                                                                  decoration: BoxDecoration(
                                                                                    color: AppColors.linear2,
                                                                                    borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                                                                                    gradient: LinearGradient(
                                                                                      begin: Alignment(0.5, 0),
                                                                                      end: Alignment(0.5, 1),
                                                                                      colors: [
                                                                                        AppColors.linear1,
                                                                                        AppColors.linear2,
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  child: GestureDetector(
                                                                                    onTap: showNext,
                                                                                    child: Center(
                                                                                      child: Text(
                                                                                        getTranslated(context, "goNext"),
                                                                                        style: TextStyle(
                                                                                          color: AppColors.white,
                                                                                          fontFamily: getTranslated(context, "Ithra"),
                                                                                          fontSize: AppFontsSizeManager.s13_5.sp,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    boxShadow: [
                                                                      new BoxShadow(
                                                                        color: Color.fromRGBO(
                                                                            156,
                                                                            57,
                                                                            129,
                                                                            0.1),
                                                                        blurRadius:
                                                                            16.r,
                                                                        spreadRadius:
                                                                            0.0,
                                                                        offset: Offset(
                                                                            0.0,
                                                                            1.0),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              if (currentIndex == 2 ||
                                                                  currentIndex ==
                                                                      3 ||
                                                                  currentIndex ==
                                                                      4 ||
                                                                  currentIndex ==
                                                                      5)
                                                                Stack(
                                                                  alignment:
                                                                      Alignment
                                                                          .topCenter,
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: currentIndex == 2
                                                                              ? 0.w
                                                                              : currentIndex == 3
                                                                                  ? 90.w
                                                                                  : currentIndex == 5
                                                                                      ? lang == "ar"
                                                                                          ? 0
                                                                                          : 110
                                                                                      : 0,
                                                                          right: currentIndex == 4
                                                                              ? 23.w
                                                                              : currentIndex == 5
                                                                                  ? 90.w
                                                                                  : currentIndex == 3
                                                                                      ? lang == "ar"
                                                                                          ? 0
                                                                                          : 150
                                                                                      : 0),
                                                                      child: Lottie.asset(
                                                                          'assets/lotifile/tool_tip_animation.json',
                                                                          width: AppSize
                                                                              .w100
                                                                              .w,
                                                                          height: AppSize
                                                                              .h100
                                                                              .h),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: currentIndex == 2
                                                                              ? 0.w
                                                                              : currentIndex == 3
                                                                                  ? 90.w
                                                                                  : currentIndex == 5
                                                                                      ? lang == "ar"
                                                                                          ? 0
                                                                                          : 110
                                                                                      : 0,
                                                                          right: currentIndex == 4
                                                                              ? 23.w
                                                                              : currentIndex == 5
                                                                                  ? 90.w
                                                                                  : currentIndex == 3
                                                                                      ? lang == "ar"
                                                                                          ? 0
                                                                                          : 150
                                                                                      : 0),
                                                                      child:
                                                                          RotationTransition(
                                                                        turns: new AlwaysStoppedAnimation(180 /
                                                                            360),
                                                                        child:
                                                                            ClipPath(
                                                                          clipper:
                                                                              TriangleClipper(),
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                16,
                                                                            // Adjust the width as needed
                                                                            height:
                                                                                8,
                                                                            // Adjust the height as needed
                                                                            color:
                                                                                AppColors.linear2,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  Container(
                                                    key: _toolTipKeysManager
                                                        .notificationTipKey,
                                                    height: AppSize.h50_5.h,
                                                    width: AppSize.w50_5.w,
                                                    decoration: decoration(),
                                                    child: Center(
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    AppRadius
                                                                        .r50),
                                                        child: Material(
                                                          color:
                                                              AppColors.white,
                                                          child: InkWell(
                                                            splashColor:
                                                                AppColors.white
                                                                    .withOpacity(
                                                                        0.6),
                                                            onTap: () {
                                                              if (userNotification
                                                                  .unread) {
                                                                notificationBloc
                                                                    .add(
                                                                  NotificationMarkReadEvent(
                                                                      currentUser!
                                                                          .uid),
                                                                );
                                                              }
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          NotificationScreen(
                                                                    userNotification:
                                                                        userNotification,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Image.asset(
                                                              theme == "light"
                                                                  ? AssetsManager
                                                                      .purple_notification_iconPath
                                                                  : AssetsManager
                                                                      .grey_notification_iconPath,
                                                              width: AppSize
                                                                  .w32_6.w,
                                                              height: AppSize
                                                                  .h36_6.h,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  userNotification.unread
                                                      ? Positioned(
                                                          right: AppPadding.p4,
                                                          top: AppPadding.p4,
                                                          child: Container(
                                                            height:
                                                                AppSize.h7_5,
                                                            width: AppSize.w7_5,
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color:
                                                                  Colors.yellow,
                                                            ),
                                                          ),
                                                        )
                                                      : SizedBox(),
                                                ],
                                              );
                                            }
                                            return noNotificationWidget();
                                          }
                                          return noNotificationWidget();
                                        },
                                      ),

                            ///

                            user.userType == "CONSULTANT" && _selectedPage == 2
                                ? Text(
                                    getTranslated(context, "tecSupport"),
                                    style: TextStyle(
                                        fontSize: AppFontsSizeManager.s26_6.sp,
                                        fontFamily:
                                            getTranslated(context, "Ithra")),
                                  )
                                : searchbar1(
                                    key: _toolTipKeysManager.searchTipKey,
                                    onPress: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SearchScreen(),
                                        ),
                                      );
                                    },
                                    text: getTranslated(context, 'search'),
                                    width: AppSize.w308.w,
                                    height: AppSize.h50_5.h,
                                    textSize: AppFontsSizeManager.s18_6.sp,
                                    textfont:
                                        getTranslated(context, 'Ithralight'),
                                    textcolor: AppColors.grey3,
                                    icon: theme == "light"
                                        ? AssetsManager.search_iconPath
                                        : AssetsManager.dark_search_icon_path,
                                    iconwidth: AppSize.w20_8,
                                    iconheight: AppSize.h20_8,
                                    space: AppSize.w89.w),
                            //   ),
                            // ),
                            SizedBox(width: AppSize.w5),
                            InkWell(
                              // key: _toolTipKeysManager.viewProfileTipKey,
                              splashColor: AppColors.white.withOpacity(0.6),
                              onTap: () {
                                if (user != null && user!.isDeveloper!)
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AllDevelopTechScreen(
                                              loggedUser: user!),
                                    ),
                                  );
                                else if (user != null &&
                                    user!.userType != "CONSULTANT")
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserAccountScreen(
                                          user: user!, firstLogged: false),
                                    ),
                                  );
                                else if (user != null &&
                                    user!.userType == "CONSULTANT")
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AccountScreen(
                                          user: user!, firstLogged: false),
                                    ),
                                  );
                                else {
                                  Navigator.pushNamed(
                                      context, '/Register_Type');
                                }
                              },
                              child:
                                  user.userType == "CONSULTANT" &&
                                          _selectedPage == 2
                                      ? BlocBuilder(
                                          bloc: notificationBloc,
                                          buildWhen: (previous, current) {
                                            if (current is GetAllNotificationsInProgressState ||
                                                current
                                                    is GetAllNotificationsFailedState ||
                                                current
                                                    is GetAllNotificationsCompletedState ||
                                                current
                                                    is GetNotificationsUpdateState) {
                                              return true;
                                            }
                                            return false;
                                          },
                                          builder: (context, state) {
                                            if (state
                                                is GetAllNotificationsInProgressState) {
                                              return noNotificationWidget();
                                            }
                                            if (state
                                                is GetNotificationsUpdateState) {
                                              if (state.userNotification !=
                                                  null) {
                                                if (state.userNotification
                                                        .notifications.length ==
                                                    0) {
                                                  return noNotificationWidget();
                                                }
                                                userNotification =
                                                    state.userNotification;
                                                if (userNotification
                                                        .notifications.length >=
                                                    200)
                                                  Fluttertoast.showToast(
                                                      msg: getTranslated(
                                                          context,
                                                          "removeNotification"),
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity: ToastGravity.TOP,
                                                      backgroundColor:
                                                          Colors.red,
                                                      textColor:
                                                          AppColors.white,
                                                      fontSize:
                                                          AppFontsSizeManager
                                                              .s16.sp);
                                                return Stack(
                                                  alignment: Alignment.center,
                                                  children: <Widget>[
                                                    ///**------------------>>>>>SHOW TOOL TIPS FOR USER<<<<<------------------**///
                                                    if (user.userType !=
                                                        "CONSULTANT")
                                                      CustomTooltipManager(
                                                        tooltips: [
                                                          TooltipData(
                                                            getTranslated(
                                                                context,
                                                                "notificationToolTipText"),
                                                            _toolTipKeysManager
                                                                .notificationTipKey,
                                                            Offset(
                                                                lang == "ar"
                                                                    ? 232.w
                                                                    : 67.w,
                                                                -2.h),
                                                            "save1",
                                                          ),
                                                          TooltipData(
                                                            getTranslated(
                                                                context,
                                                                "searchToolTipText"),
                                                            _toolTipKeysManager
                                                                .searchTipKey,
                                                            Offset(120.w, 0.h),
                                                            "save2",
                                                          ),
                                                          TooltipData(
                                                            getTranslated(
                                                                context,
                                                                "viewProfileToolTipText"),
                                                            _toolTipKeysManager
                                                                .viewProfileTipKey,
                                                            Offset(
                                                                170.w,
                                                                lang == "ar"
                                                                    ? 380.h
                                                                    : 365.h),
                                                            "save3",
                                                          ),
                                                          TooltipData(
                                                            getTranslated(
                                                                context,
                                                                "consultantTipText"),
                                                            _toolTipKeysManager
                                                                .consultantTipKey,
                                                            Offset(
                                                                lang == "ar"
                                                                    ? 293.w
                                                                    : -50.w,
                                                                lang == "ar"
                                                                    ? 835.h
                                                                    : 810.h),
                                                            "save4",
                                                          ),
                                                          TooltipData(
                                                            getTranslated(
                                                                context,
                                                                "appointmentToolTipText"),
                                                            _toolTipKeysManager
                                                                .appointmentTip,
                                                            Offset(
                                                                164.w,
                                                                lang == "ar"
                                                                    ? 835.h
                                                                    : 810.h),
                                                            "save5",
                                                          ),
                                                          TooltipData(
                                                            getTranslated(
                                                                context,
                                                                "supportToolTipText"),
                                                            _toolTipKeysManager
                                                                .supportCenterTipKey,
                                                            Offset(
                                                                lang == "ar"
                                                                    ? 5.w
                                                                    : 253.w,
                                                                lang == "ar"
                                                                    ? 835.h
                                                                    : 810.h),
                                                            "save6",
                                                          ),
                                                        ],
                                                        tooltipBuilder:
                                                            (context,
                                                                message,
                                                                showNext,
                                                                currentIndex,
                                                                total) {
                                                          return Column(
                                                            children: [
                                                              Stack(
                                                                alignment: Alignment
                                                                    .bottomCenter,
                                                                children: [
                                                                  if (currentIndex ==
                                                                          0 ||
                                                                      currentIndex ==
                                                                          1)
                                                                    Padding(
                                                                      key: _toolTipKeysManager
                                                                          .viewProfileTipKey,
                                                                      padding: EdgeInsets.only(
                                                                          left: currentIndex == 0
                                                                              ? lang == "ar"
                                                                                  ? 170.w
                                                                                  : 0
                                                                              : 0,
                                                                          right: currentIndex == 0
                                                                              ? lang == "ar"
                                                                                  ? 0.w
                                                                                  : 170.w
                                                                              : 0),
                                                                      child: Lottie.asset(
                                                                          'assets/lotifile/tool_tip_animation.json',
                                                                          width: AppSize
                                                                              .w100
                                                                              .w,
                                                                          height: AppSize
                                                                              .h100
                                                                              .h),
                                                                    ),
                                                                  if (currentIndex ==
                                                                          0 ||
                                                                      currentIndex ==
                                                                          1)
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: currentIndex == 0
                                                                              ? lang == "ar"
                                                                                  ? 170.w
                                                                                  : 0
                                                                              : 0,
                                                                          right: currentIndex == 0
                                                                              ? lang == "ar"
                                                                                  ? 0.w
                                                                                  : 170.w
                                                                              : 0),
                                                                      child:
                                                                          ClipPath(
                                                                        clipper:
                                                                            TriangleClipper(),
                                                                        child:
                                                                            Container(
                                                                          width: AppSize
                                                                              .w21_3
                                                                              .w,
                                                                          height: AppSize
                                                                              .h10_6
                                                                              .h,
                                                                          color:
                                                                              AppColors.linear2,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                              GestureDetector(
                                                                onTap: showNext,
                                                                child:
                                                                    Container(
                                                                  width: lang == "ar"
                                                                      ? AppSize
                                                                          .w272
                                                                          .w
                                                                      : AppSize
                                                                          .w277
                                                                          .w,
                                                                  height: lang == "ar"
                                                                      ? AppSize
                                                                          .h221
                                                                          .h
                                                                      : AppSize
                                                                          .h255
                                                                          .h,
                                                                  child: Theme(
                                                                    data: Theme.of(
                                                                            context)
                                                                        .copyWith(
                                                                      colorScheme:
                                                                          ColorScheme.light(
                                                                              primary: AppColors.white),
                                                                    ),
                                                                    child: Card(
                                                                      color: AppColors
                                                                          .white,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(AppRadius
                                                                            .r16
                                                                            .r),
                                                                        side: BorderSide(
                                                                            color:
                                                                                AppColors.linear2,
                                                                            width: AppSize.w1.w),
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              IconButton(
                                                                                  onPressed: () {
                                                                                    //Navigator.(context);
                                                                                  },
                                                                                  icon: Icon(
                                                                                    Icons.close,
                                                                                    color: AppColors.linear2,
                                                                                    size: AppSize.w21.r,
                                                                                  ))
                                                                            ],
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsets.only(
                                                                                right: AppPadding.p16.w,
                                                                                left: AppPadding.p10.w,
                                                                                bottom: AppPadding.p10.h),
                                                                            child:
                                                                                Text(
                                                                              message,
                                                                              style: TextStyle(
                                                                                color: AppColors.linear2,
                                                                                fontFamily: lang == "ar" ? getTranslated(context, "Ithra") : getTranslated(context, "Montserrat-SemiBold"),
                                                                                fontSize: AppFontsSizeManager.s16.sp,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.only(right: AppPadding.p20.w, left: lang == "ar" ? 0 : AppPadding.p20.w),
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                Container(
                                                                                  width: 70,
                                                                                  height: 7,
                                                                                  child: ToolTipProgressListView(
                                                                                    select: currentIndex,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  width: AppSize.w30.w,
                                                                                ),
                                                                                Container(
                                                                                  width: AppSize.w80.w,
                                                                                  height: AppSize.h40.h,
                                                                                  decoration: BoxDecoration(
                                                                                    color: AppColors.linear2,
                                                                                    borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                                                                                    gradient: LinearGradient(
                                                                                      begin: Alignment(0.5, 0),
                                                                                      end: Alignment(0.5, 1),
                                                                                      colors: [
                                                                                        AppColors.linear1,
                                                                                        AppColors.linear2,
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  child: GestureDetector(
                                                                                    onTap: showNext,
                                                                                    child: Center(
                                                                                      child: Text(
                                                                                        getTranslated(context, "goNext"),
                                                                                        style: TextStyle(
                                                                                          color: AppColors.white,
                                                                                          fontFamily: getTranslated(context, "Ithra"),
                                                                                          fontSize: AppFontsSizeManager.s13_5.sp,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    boxShadow: [
                                                                      new BoxShadow(
                                                                        color: Color.fromRGBO(
                                                                            156,
                                                                            57,
                                                                            129,
                                                                            0.1),
                                                                        blurRadius:
                                                                            16.r,
                                                                        spreadRadius:
                                                                            0.0,
                                                                        offset: Offset(
                                                                            0.0,
                                                                            1.0),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              if (currentIndex == 2 ||
                                                                  currentIndex ==
                                                                      3 ||
                                                                  currentIndex ==
                                                                      4 ||
                                                                  currentIndex ==
                                                                      5)
                                                                Stack(
                                                                  alignment:
                                                                      Alignment
                                                                          .topCenter,
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: currentIndex == 2
                                                                              ? 160.w
                                                                              : currentIndex == 3
                                                                                  ? 100.w
                                                                                  : currentIndex == 5
                                                                                      ? lang == "ar"
                                                                                          ? 0
                                                                                          : 110
                                                                                      : 0,
                                                                          right: currentIndex == 4
                                                                              ? 23.w
                                                                              : currentIndex == 5
                                                                                  ? 90.w
                                                                                  : currentIndex == 3
                                                                                      ? lang == "ar"
                                                                                          ? 0
                                                                                          : 150
                                                                                      : 0),
                                                                      child: Lottie.asset(
                                                                          'assets/lotifile/tool_tip_animation.json',
                                                                          width: AppSize
                                                                              .w100
                                                                              .w,
                                                                          height: AppSize
                                                                              .h100
                                                                              .h),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: currentIndex == 2
                                                                              ? 160.w
                                                                              : currentIndex == 3
                                                                                  ? 100.w
                                                                                  : currentIndex == 5
                                                                                      ? lang == "ar"
                                                                                          ? 0
                                                                                          : 110
                                                                                      : 0,
                                                                          right: currentIndex == 4
                                                                              ? 23.w
                                                                              : currentIndex == 5
                                                                                  ? 90.w
                                                                                  : currentIndex == 3
                                                                                      ? lang == "ar"
                                                                                          ? 0
                                                                                          : 150
                                                                                      : 0),
                                                                      child:
                                                                          RotationTransition(
                                                                        turns: new AlwaysStoppedAnimation(180 /
                                                                            360),
                                                                        child:
                                                                            ClipPath(
                                                                          clipper:
                                                                              TriangleClipper(),
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                16,
                                                                            // Adjust the width as needed
                                                                            height:
                                                                                8,
                                                                            // Adjust the height as needed
                                                                            color:
                                                                                AppColors.linear2,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    if (user != null &&
                                                        user!.userType ==
                                                            "CONSULTANT" &&
                                                        first == false)
                                                      CustomTooltipManager(
                                                        tooltips: [
                                                          TooltipData(
                                                            getTranslated(
                                                                context,
                                                                "notificationToolTipText"),
                                                            _toolTipKeysManager
                                                                .notificationTipKey,
                                                            Offset(
                                                                lang == "ar"
                                                                    ? 232.w
                                                                    : 67.w,
                                                                -2.h),
                                                            "save7",
                                                          ),
                                                          TooltipData(
                                                            getTranslated(
                                                                context,
                                                                "searchToolTipText"),
                                                            _toolTipKeysManager
                                                                .searchTipKey,
                                                            Offset(120.w, 0.h),
                                                            "save8",
                                                          ),
                                                          TooltipData(
                                                            getTranslated(
                                                                context,
                                                                "consultantChatTipText"),
                                                            _toolTipKeysManager
                                                                .consultantChatToolTipKey,
                                                            Offset(
                                                                lang == "ar"
                                                                    ? 20.w
                                                                    : 240.w,
                                                                lang == "ar"
                                                                    ? -110.h
                                                                    : -160.h),
                                                            "save9",
                                                          ),
                                                          TooltipData(
                                                            getTranslated(
                                                                context,
                                                                "consultantAppointmentTipText"),
                                                            _toolTipKeysManager
                                                                .consultantAppointmentToolTipKey,
                                                            Offset(
                                                                lang == "ar"
                                                                    ? 297.w
                                                                    : -45.w,
                                                                lang == "ar"
                                                                    ? 850.h
                                                                    : 825.h),
                                                            "save10",
                                                          ),
                                                          TooltipData(
                                                            getTranslated(
                                                                context,
                                                                "consultantCallHistoryTipText"),
                                                            _toolTipKeysManager
                                                                .consultantCallHistoryToolTipKey,
                                                            Offset(
                                                                160.w,
                                                                lang == "ar"
                                                                    ? 850.h
                                                                    : 825.h),
                                                            "save11",
                                                          ),
                                                          TooltipData(
                                                            getTranslated(
                                                                context,
                                                                "supportToolTipText"),
                                                            _toolTipKeysManager
                                                                .consultantSupportCenterTipKey,
                                                            Offset(
                                                                lang == "ar"
                                                                    ? 5.w
                                                                    : 252.w,
                                                                lang == "ar"
                                                                    ? 850.h
                                                                    : 825.h),
                                                            "save12",
                                                          ),
                                                        ],
                                                        tooltipBuilder:
                                                            (context,
                                                                message,
                                                                showNext,
                                                                currentIndex,
                                                                total) {
                                                          return Container(
                                                            child: Column(
                                                              children: [
                                                                if (currentIndex ==
                                                                        0 ||
                                                                    currentIndex ==
                                                                        1)
                                                                  Stack(
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomCenter,
                                                                    children: [
                                                                      Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left: currentIndex == 0
                                                                                ? lang == "ar"
                                                                                    ? 170.w
                                                                                    : 0
                                                                                : 0,
                                                                            right: currentIndex == 0
                                                                                ? lang == "ar"
                                                                                    ? 0.w
                                                                                    : 170.w
                                                                                : 0),
                                                                        child: Lottie.asset(
                                                                            'assets/lotifile/tool_tip_animation.json',
                                                                            width:
                                                                                AppSize.w100.w,
                                                                            height: AppSize.h100.h),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left: currentIndex == 0
                                                                                ? lang == "ar"
                                                                                    ? 170.w
                                                                                    : 0
                                                                                : 0,
                                                                            right: currentIndex == 0
                                                                                ? lang == "ar"
                                                                                    ? 0.w
                                                                                    : 170.w
                                                                                : 0),
                                                                        child:
                                                                            ClipPath(
                                                                          clipper:
                                                                              TriangleClipper(),
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                AppSize.w21_3.w,
                                                                            height:
                                                                                AppSize.h10_6.h,
                                                                            color:
                                                                                AppColors.linear2,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                GestureDetector(
                                                                  key: _toolTipKeysManager
                                                                      .consultantChatToolTipKey,
                                                                  onTap:
                                                                      showNext,
                                                                  child:
                                                                      Container(
                                                                    width: lang ==
                                                                            "ar"
                                                                        ? AppSize
                                                                            .w272
                                                                            .w
                                                                        : AppSize
                                                                            .w277
                                                                            .w,
                                                                    height: lang ==
                                                                            "ar"
                                                                        ? AppSize
                                                                            .h221
                                                                            .h
                                                                        : AppSize
                                                                            .h255
                                                                            .h,
                                                                    child:
                                                                        Theme(
                                                                      data: Theme.of(
                                                                              context)
                                                                          .copyWith(
                                                                        colorScheme:
                                                                            ColorScheme.light(primary: AppColors.white),
                                                                      ),
                                                                      child:
                                                                          Card(
                                                                        color: AppColors
                                                                            .white,
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(AppRadius
                                                                              .r16
                                                                              .r),
                                                                          side: BorderSide(
                                                                              color: AppColors.linear2,
                                                                              width: AppSize.w1.w),
                                                                        ),
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                IconButton(
                                                                                    onPressed: () {
                                                                                      //Navigator.(context);
                                                                                    },
                                                                                    icon: Icon(
                                                                                      Icons.close,
                                                                                      color: AppColors.linear2,
                                                                                      size: AppSize.w21.r,
                                                                                    ))
                                                                              ],
                                                                            ),
                                                                            Padding(
                                                                              padding: EdgeInsets.only(right: AppPadding.p16.w, left: AppPadding.p10.w, bottom: AppPadding.p10.h),
                                                                              child: Text(
                                                                                message,
                                                                                style: TextStyle(
                                                                                  color: AppColors.black,
                                                                                  fontFamily: lang == "ar" ? getTranslated(context, "Ithra") : getTranslated(context, "Montserrat-SemiBold"),
                                                                                  fontSize: AppFontsSizeManager.s16.sp,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: EdgeInsets.only(right: AppPadding.p20.w, left: lang == "ar" ? 0 : AppPadding.p20.w),
                                                                              child: Row(
                                                                                children: [
                                                                                  Container(
                                                                                    width: 70,
                                                                                    height: 7,
                                                                                    child: ToolTipProgressListView(
                                                                                      select: currentIndex,
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: AppSize.w30.w,
                                                                                  ),
                                                                                  Container(
                                                                                    width: AppSize.w80.w,
                                                                                    height: AppSize.h40.h,
                                                                                    decoration: BoxDecoration(
                                                                                      color: AppColors.linear2,
                                                                                      borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                                                                                      gradient: LinearGradient(
                                                                                        begin: Alignment(0.5, 0),
                                                                                        end: Alignment(0.5, 1),
                                                                                        colors: [
                                                                                          AppColors.linear1,
                                                                                          AppColors.linear2,
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    child: GestureDetector(
                                                                                      onTap: showNext,
                                                                                      child: Center(
                                                                                        child: Text(
                                                                                          getTranslated(context, "goNext"),
                                                                                          style: TextStyle(
                                                                                            color: AppColors.white,
                                                                                            fontFamily: getTranslated(context, "Ithra"),
                                                                                            fontSize: AppFontsSizeManager.s13_5.sp,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      boxShadow: [
                                                                        new BoxShadow(
                                                                          color: Color.fromRGBO(
                                                                              156,
                                                                              57,
                                                                              129,
                                                                              0.1),
                                                                          blurRadius:
                                                                              16.r,
                                                                          spreadRadius:
                                                                              0.0,
                                                                          offset: Offset(
                                                                              0.0,
                                                                              1.0),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                if (currentIndex == 2 ||
                                                                    currentIndex ==
                                                                        3 ||
                                                                    currentIndex ==
                                                                        4 ||
                                                                    currentIndex ==
                                                                        5)
                                                                  Stack(
                                                                    alignment:
                                                                        Alignment
                                                                            .topCenter,
                                                                    children: [
                                                                      Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left: currentIndex == 2
                                                                                ? 0.w
                                                                                : currentIndex == 3
                                                                                    ? 90.w
                                                                                    : currentIndex == 5
                                                                                        ? lang == "ar"
                                                                                            ? 0
                                                                                            : 110
                                                                                        : 0,
                                                                            right: currentIndex == 4
                                                                                ? 23.w
                                                                                : currentIndex == 5
                                                                                    ? 90.w
                                                                                    : currentIndex == 3
                                                                                        ? lang == "ar"
                                                                                            ? 0
                                                                                            : 150
                                                                                        : 0),
                                                                        child: Lottie.asset(
                                                                            'assets/lotifile/tool_tip_animation.json',
                                                                            width:
                                                                                AppSize.w100.w,
                                                                            height: AppSize.h100.h),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left: currentIndex == 2
                                                                                ? 0.w
                                                                                : currentIndex == 3
                                                                                    ? 90.w
                                                                                    : currentIndex == 5
                                                                                        ? lang == "ar"
                                                                                            ? 0
                                                                                            : 110
                                                                                        : 0,
                                                                            right: currentIndex == 4
                                                                                ? 23.w
                                                                                : currentIndex == 5
                                                                                    ? 90.w
                                                                                    : currentIndex == 3
                                                                                        ? lang == "ar"
                                                                                            ? 0
                                                                                            : 150
                                                                                        : 0),
                                                                        child:
                                                                            RotationTransition(
                                                                          turns:
                                                                              new AlwaysStoppedAnimation(180 / 360),
                                                                          child:
                                                                              ClipPath(
                                                                            clipper:
                                                                                TriangleClipper(),
                                                                            child:
                                                                                Container(
                                                                              width: 16,
                                                                              // Adjust the width as needed
                                                                              height: 8,
                                                                              // Adjust the height as needed
                                                                              color: AppColors.linear2,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    Container(
                                                      key: _toolTipKeysManager
                                                          .notificationTipKey,
                                                      height: AppSize.h50_5.h,
                                                      width: AppSize.w50_5.w,
                                                      decoration: decoration(),
                                                      child: Center(
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      AppRadius
                                                                          .r50),
                                                          child: Material(
                                                            color:
                                                                AppColors.white,
                                                            child: InkWell(
                                                              splashColor:
                                                                  AppColors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.6),
                                                              onTap: () {
                                                                if (userNotification
                                                                    .unread) {
                                                                  notificationBloc
                                                                      .add(
                                                                    NotificationMarkReadEvent(
                                                                        currentUser!
                                                                            .uid),
                                                                  );
                                                                }
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            NotificationScreen(
                                                                      userNotification:
                                                                          userNotification,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child:
                                                                  Image.asset(
                                                                theme == "light"
                                                                    ? AssetsManager
                                                                        .purple_notification_iconPath
                                                                    : AssetsManager
                                                                        .grey_notification_iconPath,
                                                                width: AppSize
                                                                    .w32_6.w,
                                                                height: AppSize
                                                                    .h36_6.h,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    userNotification.unread
                                                        ? Positioned(
                                                            right:
                                                                AppPadding.p4,
                                                            top: AppPadding.p4,
                                                            child: Container(
                                                              height:
                                                                  AppSize.h7_5,
                                                              width:
                                                                  AppSize.w7_5,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .yellow,
                                                              ),
                                                            ),
                                                          )
                                                        : SizedBox(),
                                                  ],
                                                );
                                              }
                                              return noNotificationWidget();
                                            }
                                            return noNotificationWidget();
                                          },
                                        )
                                      : Container(
                                          //key: _toolTipKeysManager.consultantSearchTipKey,
                                          height: AppSize.h45.h,
                                          width: AppSize.w46.w,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: userImage == null
                                              ? Image.asset(
                                                  AssetsManager
                                                      .dreamLogoPurpleImagePath,
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppRadius.r100),
                                                  child:
                                                      FadeInImage.assetNetwork(
                                                    placeholder: AssetsManager
                                                        .purple_logo,
                                                    //placeholderScale: 0.5,
                                                    imageErrorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Image.asset(
                                                      AssetsManager
                                                          .dreamLogoPurpleImagePath,
                                                      width: AppSize.w50,
                                                      height: AppSize.h50,
                                                    ),
                                                    image: userImage,
                                                    fit: BoxFit.cover,
                                                    fadeInDuration: Duration(
                                                        milliseconds: AppConstants
                                                            .milliseconds250),
                                                    fadeInCurve:
                                                        Curves.easeInOut,
                                                    fadeOutDuration: Duration(
                                                        milliseconds: AppConstants
                                                            .milliseconds150),
                                                    fadeOutCurve:
                                                        Curves.easeInOut,
                                                  ),
                                                ),
                                        ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                user.userType == "CONSULTANT" && _selectedPage == 2
                    ? Padding(
                        padding: EdgeInsets.only(top: AppPadding.p21_3.h),
                        child: Container(
                          color: AppColors.lightGray,
                          height: AppSize.h1.h,
                          width: double.infinity,
                        ),
                      )
                    : SizedBox()
              ],
            ),
          ),
        ),
        // Center(
        //     child: Container(
        //         color: AppColors.lightGrey6,
        //         height: AppSize.h1_5.h,
        //         width: size.width)),
      ],
    );
  }

  BoxDecoration decoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
      boxShadow: [AppShadow.primaryShadow],
    );
  }

  Widget noNotificationWidget() {
    return Container(
      height: AppSize.h50_6.h,
      width: AppSize.w50_6.w,
      decoration: decoration(),
      child: Center(
        child: InkWell(
          splashColor: AppColors.white.withOpacity(0.6),
          onTap: () {
            Fluttertoast.showToast(
              msg: getTranslated(context, "noNotification"),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: AppColors.red,
              textColor: AppColors.white,
              fontSize: AppFontsSizeManager.s16.sp,
            );
          },
          child: Image.asset(
            theme == "light"
                ? AssetsManager.notificationIcon
                : AssetsManager.grey_notification_iconPath,
            width: AppSize.w22_6.w,
            height: AppSize.h26_6.h,
          ),
        ),
      ),
    );
  }

  Widget rateReactionsDialog() {
    return BlocProvider(
        create: (context) => RateCubit(RateInitialState()),
        child: BlocConsumer<RateCubit, RateStates>(
            listener: (context, state) {},
            builder: (context, state) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.r21_3.r),
                    color: Colors.white,
                  ),
                  height: AppSize.h352.h,
                  width: AppSize.w433_3.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: AppPadding.p32.w,
                            top: AppPadding.p32.w,
                            right: AppPadding.p32.w),
                        child: Align(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Image.asset(
                              AssetsManager.closeDialog2,
                              height: AppSize.h21_3.h,
                              width: AppSize.w21_3.w,
                            ),
                          ),
                          alignment: AlignmentDirectional.topStart,
                        ),
                      ),
                      SizedBox(
                        height: AppSize.h20.h,
                      ),
                      SizedBox(
                        child: Text(
                          getTranslated(context, 'rate_qs3'),
                          style: TextStyle(
                            // backgroundColor: Colors.red,
                            height: AppSize.h1_5.h,
                            fontFamily: 'Ithra',
                            color: AppColors.grey_dark,
                            fontSize: AppFontsSizeManager.s24.sp,
                            fontWeight: AppFontsWeightManager.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: AppSize.h40.h,
                      ),
                      Container(
                        height: AppSize.h67_8.h,
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(horizontal: AppPadding.p22.w),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) => InkWell(
                            onTap: () {
                              RateCubit.get(context).changeSelected(
                                  RateCubit.get(context).reactions[index]);
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      // RateCubit.get(context).reactions.length ==
                                      //         5
                                      //     ? 0
                                      //     :
                                      AppPadding.p12_7.w),
                              child: Expanded(
                                child: Container(
                                  height: AppSize.h67_8.h,
                                  width: AppSize.w67_8.w,
                                  child: CircleAvatar(
                                    radius: AppRadius.r50.r,
                                    backgroundColor:
                                        (RateCubit.get(context).selected ==
                                                RateCubit.get(context)
                                                    .reactions[index])
                                            ? AppColors.gradiant2
                                            : AppColors.grey_light,
                                    child: Image.asset(
                                      RateCubit.get(context)
                                          .reactions[index]
                                          .keys
                                          .first,
                                      height: AppSize.h45_3.h,
                                      width: AppSize.w45_3.w,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          separatorBuilder: (context, index) => SizedBox(
                            width: 0,
                          ),
                          itemCount: RateCubit.get(context).reactions.length,
                        ),
                      ),
                      SizedBox(
                        height: AppSize.h42_6.h,
                      ),
                      InkWell(
                        onTap: () async {
                          if (RateCubit.get(context).selected != null) {
                            Navigator.pop(context);
                            CashHelper.saveData(key: 'rate', value: 'true');
                            user.rate =
                                RateCubit.get(context).selected!.values.single;
                            accountBloc
                                .add(UpdateAccountDetailsEvent(user: user));
                            if (await inAppReview.isAvailable()) {
                              inAppReview.requestReview();
                            }
                          } else {
                            showSnakbar(
                                getTranslated(context, 'snakbar_msg'), true);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppPadding.p32.w),
                          child: Container(
                            height: AppSize.h64.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  end: Alignment.topCenter,
                                  begin: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.Gradient_Color2,
                                    AppColors.Gradient_Color1,
                                  ],
                                ),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r10_6.r)),
                            child: Center(
                              child: Text(
                                getTranslated(context, 'send_rating'),
                                style: TextStyle(
                                  fontSize: AppFontsSizeManager.s21_3.sp,
                                  color: AppColors.white1,
                                  fontFamily: 'Ithra',
                                  fontWeight: AppFontsWeightManager.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  Widget rateSentDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: AppSize.h330_6.h,
        width: AppSize.w433_3.w,
        padding: EdgeInsets.only(
            left: AppPadding.p32.r,
            bottom: AppPadding.p32.r,
            top: AppPadding.p32.r,
            right: AppPadding.p32.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  AssetsManager.closeDialog2,
                  height: AppSize.h21_3.h,
                  width: AppSize.w21_3.w,
                ),
              ),
              alignment: AlignmentDirectional.topStart,
            ),
            Expanded(
              child: Image.asset(
                AssetsManager.stars,
                height: AppSize.h93_8.h,
                width: AppSize.w153_7.w,
              ),
            ),
            SizedBox(
              height: AppSize.h21_3.h,
            ),
            Text(
              // textAlign: TextAlign.center,
              getTranslated(context, 'sending_rate'),
              textAlign: TextAlign.center,
              style: TextStyle(
                // overflow: TextOverflow.ellipsis,
                fontFamily: getTranslated(context, 'Ithra'),
                color: AppColors.grey_dark,
                fontSize: AppFontsSizeManager.s24.sp,
              ),
            ),
            SizedBox(
              height: AppSize.h21_3.h,
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                height: AppSize.h64.h,
                width: AppSize.w277,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      end: Alignment.topCenter,
                      begin: Alignment.bottomCenter,
                      colors: [
                        AppColors.gradiant1,
                        AppColors.gradiant2,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.r8)),
                child: Center(
                  child: Text(
                    getTranslated(context, 'continue_rating'),
                    style: TextStyle(
                      fontSize: AppFontsSizeManager.s18_6.sp,
                      color: AppColors.white1,
                      fontFamily: 'Ithra',
                      fontWeight: AppFontsWeightManager.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.r21_3.r),
          color: Colors.white,
        ),
      ),
    );
  }

  Widget rateStarDialog(size) {
    return Dialog(
      backgroundColor: Colors.red,
      child: Container(
        height: AppSize.h358_6.h,
        width: AppSize.w433_3.w,
        padding: EdgeInsets.all(AppPadding.p32.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    AssetsManager.closeDialog2,
                    height: AppSize.h24.h,
                    width: AppSize.w24.h,
                  ),
                ),
                SizedBox()
              ],
            ),
            SizedBox(
              height: AppSize.h26.h,
            ),
            Text(
              getTranslated(context, 'rate_qs1'),
              style: TextStyle(
                  fontFamily: getTranslated(context, 'Ithra'),
                  color: AppColors.grey_dark,
                  fontSize: AppFontsSizeManager.s24.sp,
                  fontWeight: AppFontsWeightManager.bold),
            ),
            SizedBox(
              height: AppSize.h21.h,
            ),
            Text(
              getTranslated(context, 'rate_qs2'),
              style: TextStyle(
                  fontFamily: getTranslated(context, 'Ithra'),
                  color: AppColors.grey_dark,
                  fontSize: AppFontsSizeManager.s18_6.sp,
                  fontWeight: AppFontsWeightManager.regular),
            ),
            SizedBox(
              height: AppSize.h24_5.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p50.w),
              child: Container(
                height: AppSize.h42_6.h,
                //color: Colors.red,
                child: Align(
                  alignment: Alignment.center,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => Image.asset(
                      AssetsManager.star_rate,
                      height: AppSize.h42_6.h,
                      width: AppSize.w42_6.w,
                    ),
                    separatorBuilder: (context, index) => SizedBox(
                      width: AppSize.w13_3.h,
                    ),
                    itemCount: 5,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: AppSize.h22.h,
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                showDialog(
                    context: context, builder: (context) => rateSentDialog());
              },
              child: Container(
                height: AppSize.h64.h,
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      end: Alignment.topCenter,
                      begin: Alignment.bottomCenter,
                      colors: [
                        AppColors.Gradient_Color2,
                        AppColors.Gradient_Color1,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.r8)),
                child: Center(
                  child: Text(
                    getTranslated(context, 'send_rate'),
                    style: TextStyle(
                      fontSize: AppFontsSizeManager.s18_6.sp,
                      color: AppColors.white1,
                      fontFamily: getTranslated(context, 'Ithra_Bold'),
                      fontWeight: AppFontsWeightManager.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.r21_3.r),
          color: Colors.white,
        ),
      ),
    );
  }

  void showSnakbar(String s, bool status) {
    Fluttertoast.showToast(
        msg: s,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: AppColors.white,
        fontSize: 16.0.sp);
  }

  showStartSurveyDialog() {
    lang = getTranslated(context, "lang");

    return showDialog(
      builder: (context) => DreamDialogsWidget(
          padBottom: 0,
          padTop: 0,
          padLeft: 0,
          padRight: 0,
          dialogContent: Container(
            //height: AppSize.h426_6.h,
            width: AppSize.w433_3.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: AppPadding.p32.h,
                      right: AppPadding.p32.w,
                      left: AppPadding.p32.w),
                  child: Row(
                    mainAxisAlignment: lang == 'ar'
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Image.asset(
                            AssetsManager.closeIcon4,
                            height: AppSize.h18_6.h,
                            width: AppSize.h18_6.w,
                            //color: AppColors.linear2,
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  height:
                      //lang == "ar" ? AppSize.h80.h :
                      AppSize.h42_6.h,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
                      child: SizedBox(
                        //  height: AppSize.h64.h,
                        // color: Colors.red,
                        child: Text(
                          getTranslated(context, "startSurveyIntro"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              height: AppSize.h2.h,
                              textBaseline: TextBaseline.ideographic,
                              fontSize: AppFontsSizeManager.s24.sp,
                              color: AppColors.black,
                              fontFamily:
                                  // lang == "ar"
                                  // ?
                                  getTranslated(context, "Ithra")
                              //: getTranslated(context, "Montserrat-SemiBold"),
                              ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height:
                          //lang == "ar" ? AppSize.h80.h :
                          AppSize.h42_6.h,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p26_6.w),
                      child: Column(
                        children: [
                          SizedBox(
                            // height: AppSize.h32.h,
                            child: Text(
                              getTranslated(context, "surveyTakeMinuteText"),
                              style: TextStyle(
                                height: 1,
                                fontSize: AppFontsSizeManager.s24.sp,
                                color: AppColors.linear2,
                                fontFamily: lang == "ar"
                                    ? getTranslated(context, "Ithra")
                                    : getTranslated(
                                        context, "Montserrat-SemiBold"),
                              ),
                            ),
                          ),
                          SizedBox(
                            height:
                                // lang == "ar" ? AppSize.h26.h :
                                AppSize.h21_3.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                AssetsManager.gift,
                                height: AppSize.h26_1.h,
                                width: AppSize.w21_3.w,
                              ),
                              SizedBox(
                                // height: AppSize.h22_6.h,
                                child: Text(
                                  getTranslated(context, "surveySurprise"),
                                  style: TextStyle(
                                      // height: 1.7,
                                      fontSize: AppFontsSizeManager.s18_6.sp,
                                      color: AppColors.black,
                                      fontFamily:
                                          getTranslated(context, "Ithralight")),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height:
                                // lang == "ar" ? AppSize.h20.h :
                                AppSize.h42_6.h,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: AppPadding.p32.w,
                        right: AppPadding.p32.w,
                        bottom: AppSize.h32.h,
                      ),
                      child: textButton(
                        onPress: () {
                          Navigator.pop(context);
                          showFirstStepSurvey();
                        },
                        text: getTranslated(context, "start"),
                        width: size.width,
                        height: AppSize.h64.h,
                        buttonRadius: AppRadius.r10_6.r,
                        textSize: AppFontsSizeManager.s18_6.sp,
                        textfont: lang == "ar"
                            ? getTranslated(context, "Ithra")
                            : getTranslated(context, "Montserrat-SemiBold"),
                        textcolor: AppColors.white,
                        icon: '',
                        padding: AppPadding.p10.w,
                        Gradient_Color: AppColors.Gradient_Color1,
                        Gradient_Color2: AppColors.Gradient_Color2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
      barrierDismissible: false,
      context: context,
    );
  }

  showFirstStepSurvey() {
    lang = getTranslated(context, "lang");

    return showDialog(
      builder: (context) => DreamDialogsWidget(
        padBottom: 0,
        padLeft: 0,
        padRight: 0,
        padTop: 0,
        dialogContent: Container(
          // color: Colors.blue,
          padding: EdgeInsets.only(
              top: AppPadding.p32.h, bottom: AppPadding.p26_6.h),
          // height: 800,
          //     ? AppSize.h1050.h
          //     : select == 1
          //         ? AppSize.h800.h
          //         : select == 2
          //             ? AppSize.h1050.h
          //             : select == 3
          //                 ? AppSize.h1050.h
          //                 : AppSize.h1050.h,
          width: AppSize.w478_6.w,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
                child: Row(
                  mainAxisAlignment: lang == 'ar'
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.close,
                          color: AppColors.linear2,
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: AppSize.h32.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
                child: Column(
                  children: [
                    Text(
                      getTranslated(context, "hearAboutUs"),
                      style: TextStyle(
                        fontSize: AppFontsSizeManager.s26_6.sp,
                        color: AppColors.linear2,
                        fontFamily: lang == "ar"
                            ? getTranslated(context, "Ithra")
                            : getTranslated(context, "Montserrat-SemiBold"),
                      ),
                    ),
                    SizedBox(
                      height: AppSize.h32.h,
                    ),
                    mainSurveyListView(
                      mainValue: mainVal,
                      secondValue: secondVal,
                    ),
                    SizedBox(
                      height: AppSize.h32.h,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p26_6.w),
                child: Text(
                  getTranslated(context, "yourAnswer"),
                  style: TextStyle(
                    fontSize: AppFontsSizeManager.s18_6.sp,
                    color: AppColors.linear2,
                    fontFamily: getTranslated(context, "Ithralight"),
                  ),
                ),
              ),
              SizedBox(
                height: AppSize.h32.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p26_6.h),
                child: textButton(
                  onPress: () async {
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(user.uid)
                        .set({
                      'survey': {
                        'mainVal': mainVal,
                        'secondVal': secondVal,
                      },
                    }, SetOptions(merge: true));
                    Navigator.pop(context);
                    CashHelper.saveData(key: 'surveyTime', value: 'true');
                    setState(() {
                      print('///////////////////////////////////');
                      print(select);
                      print('///////////////////////////////////');
                    });
                  },
                  text: getTranslated(context, "sendSurvey"),
                  width: double.infinity,
                  height: AppSize.h64.h,
                  buttonRadius: AppRadius.r10_6.r,
                  textSize: AppFontsSizeManager.s18_6.sp,
                  textfont: lang == "ar"
                      ? getTranslated(context, "Ithra")
                      : getTranslated(context, "Montserrat-SemiBold"),
                  textcolor: AppColors.white1,
                  icon: '',
                  padding: 0,
                  Gradient_Color: AppColors.Gradient_Color1,
                  Gradient_Color2: AppColors.Gradient_Color2,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }
}

int? select;

class firstStepSurveyWidget extends StatelessWidget {
  String text;
  bool surveySelect = false;
  Map mainVal = {};

  firstStepSurveyWidget({
    required this.text,
    required this.surveySelect,
    required this.mainVal,
  });

  String lang = "";

  @override
  Widget build(BuildContext context) {
    lang = getTranslated(context, "lang");

    return Padding(
      padding: EdgeInsets.only(bottom: AppPadding.p26_6.h),
      child: Row(
        children: [
          Container(
            width: AppSize.w6.w,
            height: AppSize.w6.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.r100.r),
              color: AppColors.black,
            ),
          ),
          SizedBox(
            width: AppSize.w9.w,
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppFontsSizeManager.s18_6.sp,
                color: AppColors.black,
                fontFamily: lang == "ar"
                    ? getTranslated(context, "Ithra")
                    : getTranslated(context, "Montserrat-SemiBold"),
              ),
            ),
          ),
          SvgPicture.asset(surveySelect
              ? AssetsManager.radioButtonOn
              : AssetsManager.radioButtonOff),
        ],
      ),
    );
  }
}

class mainSurveyListView extends StatefulWidget {
  Map mainValue = {};
  Map secondValue = {};

  mainSurveyListView(
      {super.key, required this.mainValue, required this.secondValue});

  @override
  State<mainSurveyListView> createState() => _mainSurveyListViewState();
}

class _mainSurveyListViewState extends State<mainSurveyListView> {
  late List<String> textList = [
    getTranslated(context, "socialMediaPosts"),
    getTranslated(context, "AdCampaigns"),
    getTranslated(context, "articles"),
    getTranslated(context, "recommendation"),
    getTranslated(context, "other"),
  ];
  int? surveySelect;
  TextEditingController antherWayController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (surveySelect == 0 || surveySelect == 1)
          ? AppSize.h683.h
          : (surveySelect == 4)
              ? AppSize.h408.h
              : AppSize.h356.h,
      //  height: AppSize.h683.h,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: textList.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
            surveySelect = index;
            setState(() {});
            widget.mainValue["mainVal"] = textList[index];
            select = index;
          },
          child: Column(
            children: [
              firstStepSurveyWidget(
                text: textList[index],
                surveySelect: surveySelect == index,
                mainVal: widget.mainValue,
              ),
              if (index == surveySelect && index == 0)
                SocialMediaSurveyListView(survey: widget.secondValue),
              if (index == surveySelect && index == 1)
                AdsSurveyListView(survey: widget.secondValue),
              if (index == surveySelect && index == 4)
                antherWayTextForm(widget.secondValue),
            ],
          ),
        ),
      ),
    );
  }

  Widget antherWayTextForm(Map survey) {
    return Column(
      children: [
        // SizedBox(
        //   height: AppSize.h44.h,
        // ),
        Container(
          height: AppSize.h66_6.h,
          width: AppSize.w383_2.w,
          padding: EdgeInsets.symmetric(horizontal: AppPadding.p5_3.w),
          decoration: BoxDecoration(
            color: AppColors.formFieldColor,
            border: Border(
              bottom: BorderSide(
                color: AppColors.greyDark, // Color of the border
                width: AppSize.h2.h, // Thickness of the border
              ),
            ),
          ),
          child: TextFormFieldWidget(
            controller: antherWayController,
            onTap: () {
              survey["secondVal"] = antherWayController.text;
            },
            context: context,
            name: getTranslated(context, "antherWay"),
            labelColor: AppColors.grey,
            fontSize1: AppFontsSizeManager.s16.sp,
            fontFamily: getTranslated(context, "Ithralight"),
            borderColor: AppColors.white,
          ),
        ),
      ],
    );
  }
}

class SocialMediaAndAdsSurveyWidget extends StatelessWidget {
  String imagePath;
  String text;
  bool select = false;

  SocialMediaAndAdsSurveyWidget({
    required this.imagePath,
    required this.text,
    required this.select,
  });

  String lang = "";

  @override
  Widget build(BuildContext context) {
    lang = getTranslated(context, "lang");

    return Container(
      width: double.infinity,
      height: AppSize.h48.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.r5_3.r),
        border: Border.all(
          color: select ? AppColors.linear2 : AppColors.grey4,
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: select ? AppColors.white : AppColors.surveyShadow,
        //     blurRadius: 18.r,
        //     spreadRadius: 0.0,
        //     offset: Offset(0.0, 9.0), // shadow direction: bottom right
        //   )
        // ]
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(
                right: AppPadding.p21_3.w,
                left: lang == "ar" ? AppPadding.p21_3.w : AppPadding.p21_3.w),
            child: SvgPicture.asset(
              imagePath,
              height: AppSize.h26_6.h,
              width: AppSize.w26_6.w,
            ),
          ),
          SizedBox(
            width: AppSize.w16.w,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: AppFontsSizeManager.s18_6.sp,
              color: AppColors.black,
              fontFamily: lang == "ar"
                  ? getTranslated(context, "Ithralight")
                  : getTranslated(context, "Montserrat-SemiBold"),
              //fontWeight: lang == "ar" ? FontWeight.w600 : FontWeight.w100,
            ),
          ),
        ],
      ),
    );
  }
}

class SocialMediaSurveyListView extends StatefulWidget {
  Map survey = {};

  SocialMediaSurveyListView({super.key, required this.survey});

  @override
  State<SocialMediaSurveyListView> createState() =>
      _SocialMediaSurveyListViewState();
}

class _SocialMediaSurveyListViewState extends State<SocialMediaSurveyListView> {
  List<String> imagePaths = [
    AssetsManager.facebookIconPath,
    AssetsManager.twitter,
    AssetsManager.instaIconPath,
    AssetsManager.youtube,
    AssetsManager.tiktok,
    AssetsManager.snapChatIconPath,
  ];
  late List<String> text = [
    lang == "ar" ? "فيسبوك" : "Facebook",
    lang == "ar" ? "تويتر" : "Twitter",
    lang == "ar" ? "إنستغرام" : "Instagram",
    lang == "ar" ? "يوتيوب" : "Youtube",
    lang == "ar" ? "تيك توك" : "TikTok",
    lang == "ar" ? "سناب شات" : "Snapchat",
  ];
  int select = 0;
  String lang = "";

  @override
  Widget build(BuildContext context) {
    lang = getTranslated(context, "lang");

    return Padding(
      padding: EdgeInsets.only(bottom: AppPadding.p32.h),
      child: SizedBox(
        height: AppSize.h368.h,
        child: ListView.builder(
          itemCount: imagePaths.length,
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(bottom: AppPadding.p16.h),
            child: GestureDetector(
              onTap: () {
                select = index;
                widget.survey["secondVal"] = text[index];
                setState(() {});
              },
              child: SocialMediaAndAdsSurveyWidget(
                imagePath: imagePaths[index],
                text: text[index],
                select: select == index,
              ),
            ),
          ),
        ),
      ),
    );
  }

  //
}

class AdsSurveyListView extends StatefulWidget {
  Map survey = {};

  AdsSurveyListView({super.key, required this.survey});

  @override
  State<AdsSurveyListView> createState() => _AdsSurveyListViewState();
}

class _AdsSurveyListViewState extends State<AdsSurveyListView> {
  List<String> imagePaths = [
    AssetsManager.googleIconsPath,
    AssetsManager.twitter,
    AssetsManager.instaIconPath,
    AssetsManager.youtube,
    AssetsManager.googlePayLogo,
    AssetsManager.appleStoreIconPath,
    ""
  ];
  late List<String> text = [
    lang == "ar" ? "جوجل" : "Google",
    lang == "ar" ? "تويتر" : "Twitter",
    lang == "ar" ? "إنستغرام" : "Instagram",
    lang == "ar" ? "يوتيوب" : "Youtube",
    lang == "ar" ? "متجر جوجل بلاي" : "Google Play store",
    lang == "ar" ? "متجر التطبيقات أبل" : "Apple App store",
    lang == "ar" ? "بطريقة أخرى" : "Other",
  ];
  int select = 0;
  String lang = "";

  @override
  Widget build(BuildContext context) {
    lang = getTranslated(context, "lang");

    return Container(
      //color: Colors.red,
      height: AppSize.h465.h,
      child: ListView.builder(
        itemCount: text.length,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(bottom: AppPadding.p16.h),
          child: GestureDetector(
            onTap: () {
              select = index;
              widget.survey["secondVal"] = text[index];
              setState(() {});
            },
            child: SocialMediaAndAdsSurveyWidget(
              imagePath: imagePaths[index],
              text: text[index],
              select: select == index,
            ),
          ),
        ),
      ),
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
