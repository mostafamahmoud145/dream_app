import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/appointmentWidget.dart';
import 'package:grocery_store/widget/consultantListItem.dart';

import '../FireStorePagnation/paginate_firestore.dart';
import '../methods/change_user_call_state.dart';
import '../models/banner.dart';
import '../screens/consultantDetailsScreen.dart';
import '../widget/tab_bar/custom_tab_bar.dart';
import '../widget/tab_bar/tab_bar_button.dart';

class HomePage extends StatefulWidget {
  final String? userType;

  const HomePage({Key? key, this.userType}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage>, WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late QuerySnapshot querySnapshot1;
  late AccountBloc accountBloc;
  GroceryUser? user;
  bool? first;
  bool voice = false,
      chat = false,
      allConsult = false,
      leadingConsult = false,
      newConsult = false;

  bool load = true, loadPageWidget = true, loadBanner = true;
  bool active = false;
  bool loadData = false;
  List<banner> bannerList = [];
  late var query, userQuery;
  late String lang;
  bool avaliable = false;
  DateTime _now = DateTime.now();

  late String userId;
  var registered = false;
  var hasPushedToCall = false;
  late AppLifecycleState state;
  bool stateIsCalling = false;

  @override
  void initState() {
    super.initState();
    first = true;
    voice = true;
    allConsult = true;
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetLoggedUserEvent());

    if (FirebaseAuth.instance.currentUser != null) {
      FirebaseDatabase.instance
          .ref('userCallState')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child('callState')
          .onValue
          .listen((event) {
        if (event.snapshot.value == 'oncall' ||
            event.snapshot.value == 'calling') {
          setState(() {
            stateIsCalling = true;
          });
        } else {
          setState(() {
            stateIsCalling = false;
          });
        }
      });
    }
  }

  // void getTest()async{
  //   QuerySnapshot querySnapshot= await FirebaseFirestore.instance
  //       .collection('Users')
  //       .where('userType', isEqualTo: 'CONSULTANT')
  //       .where('accountStatus', isEqualTo: "Active")
  //       .where('languages', arrayContains: getTranslated(context, "lang"))
  //       .orderBy('order', descending: true)
  //       .where("order", isLessThan: 1000).get();
  //
  //   print('-------------------------------------------------');
  //   for(DocumentSnapshot document in querySnapshot.docs) {
  //     GroceryUser user= GroceryUser.fromMap(document.data() as Map<String, dynamic>);
  //     Map<String, dynamic> dataFromFirebase= document.data() as Map<String, dynamic>;
  //     print(user.order.toString()+'======='+user.name.toString()+'====='+user.uid.toString()+'====='+dataFromFirebase['order'].toString());
  //   }
  // }
  @override
  void dispose() {
    first = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    query = FirebaseFirestore.instance
        .collection('Users')
        .where('userType', isEqualTo: 'CONSULTANT')
        // .where('phoneNumber', isEqualTo: '+966666666666')
        .where('accountStatus', isEqualTo: "Active")
        .where('languages', arrayContains: getTranslated(context, "lang"))
        .orderBy('order', descending: true);
    userQuery = query.where('voice', isEqualTo: true);

    getImageSlider();
    super.didChangeDependencies();
  }

  void showNoNotifSnack(String text) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(7),
      backgroundColor: Colors.green.shade500,
      animationDuration: Duration(milliseconds: 300),
      isDismissible: true,
      boxShadows: [AppShadow.primaryShadow],
      shouldIconPulse: false,
      duration: Duration(milliseconds: 1500),
      icon: Icon(
        Icons.notification_important,
        color: AppColors.white,
      ),
      messageText: Text(
        '$text',
        style: TextStyle(
          fontFamily: getTranslated(context, 'Ithra'),
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: AppColors.white,
        ),
      ),
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    lang = getTranslated(context, "lang");
    super.build(context);
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        floatingActionButton: stateIsCalling
            ? Container(
                width: AppSize.w64.w,
                height: AppSize.h64.h,
                child: FloatingActionButton(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(AppRadius.r100.r))),
                  onPressed: () {
                    EndCallDialog(MediaQuery.of(context).size);
                  },

                  // onPressed: () async {
                  //   customTextDialog(
                  //     context: context,
                  //     text: getTranslated(context, 'resetUserInformation'),
                  //     buttonText: getTranslated(context, 'continue'),
                  //     okFunction: () async{
                  //       await updateFirebaseToken(FirebaseAuth.instance.currentUser!);
                  //       await changeUserState(userId: FirebaseAuth.instance.currentUser!.uid, state: 'closed');
                  //     },
                  //   );
                  // },
                  backgroundColor: AppColors.red8,
                  child: Image.asset(
                    AssetsManager.white_call_iconPath,
                    width: AppSize.w40.w,
                    height: AppSize.h14.h,
                  ),
                ),
              )
            : null,
        backgroundColor: AppColors.white,
        key: _scaffoldKey,
        body: BlocBuilder(
          bloc: accountBloc,
          builder: (context, state) {
            if (state is GetLoggedUserInProgressState) {
              return loadingWidget();
            } else if (state is GetLoggedUserCompletedState) {
              user = state.user;
              if (user!.userType == AppConstants.consultant) {
                checkAvaliable();
                return consultHome(size);
              } else {
                return userHome(size);
              }
            } else {
              return userHome(size);
            }
          },
        ),
      ),
    );
  }

  Widget loadingWidget() {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.pink,
      ),
    );
  }

  Widget userHome(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        // Padding(
        //   padding: EdgeInsets.only(top: 29.h, bottom: 28.h,right:64.w ),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     children: [
        //       Text.rich(
        //         TextSpan(
        //           text: getTranslated(context, "activeNow"),
        //           style: TextStyle(
        //             fontFamily: getTranslated(context, 'Ithra'),
        //             fontSize: 15.sp,
        //             color: Color.fromRGBO( 32, 32, 32, 1),
        //           ),
        //           children: <TextSpan>[
        //             TextSpan(
        //               text: ' >',
        //               style: TextStyle(
        //                 fontSize: 20.sp,
        //                 color: Color.fromRGBO( 236, 236, 236, 1),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        imageSlider(size),
        SizedBox(
          height: AppSize.h27.h,
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: lang == "ar" ? AppSize.w32.w : AppSize.w16.w),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        allConsult = true;
                        leadingConsult = false;
                        newConsult = false;
                        voice = true;
                        chat = false;

                        userQuery = query;
                      });
                    },
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            getTranslated(context, "allConsult"),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              color: allConsult
                                  ? AppColors.linear3
                                  : Color.fromRGBO(147, 147, 147, 1),
                              fontSize: AppFontsSizeManager.s18_6.sp,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                          SizedBox(
                            height: AppSize.h7_5.h,
                          ),
                          Container(
                            width: AppSize.w156.w,
                            height: AppSize.h1_5.h,
                            decoration: BoxDecoration(
                              color: allConsult
                                  ? AppColors.linear3
                                  : Color.fromRGBO(255, 255, 255, 1),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r5.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // SizedBox(
                  //   width: lang == "fr" ? 5.w : 16.w,
                  // ),
                  InkWell(
                    onTap: () async {
                      userQuery = await query
                          .where("order", isGreaterThanOrEqualTo: 1000)
                          .where('voice', isEqualTo: true);
                      setState(() {
                        allConsult = false;
                        leadingConsult = true;
                        newConsult = false;
                        voice = true;
                        chat = false;
                      });
                    },
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            getTranslated(context, "leadingConsult"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              color: leadingConsult
                                  ? AppColors.linear3
                                  : Color.fromRGBO(147, 147, 147, 1),
                              fontSize: AppFontsSizeManager.s18_6.sp,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                          SizedBox(
                            height: AppSize.h7_5.h,
                          ),
                          Container(
                            width: 133.5.w,
                            height: 1.5.h,
                            decoration: BoxDecoration(
                              color: leadingConsult
                                  ? AppColors.linear3
                                  : Color.fromRGBO(255, 255, 255, 1),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r5.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   width: lang == "fr" ? 5.w : 16.w,
                  // ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        allConsult = false;
                        leadingConsult = false;
                        newConsult = true;
                        voice = true;
                        chat = false;

                        userQuery = query
                            .where("order", isLessThan: 100)

                            ///todo
                            .where('voice', isEqualTo: true);
                      });
                    },
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            getTranslated(context, "newConsult"),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              color: newConsult
                                  ? AppColors.linear3
                                  : Color.fromRGBO(147, 147, 147, 1),
                              fontSize: AppFontsSizeManager.s18_6.sp,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                          SizedBox(
                            height: 7.5.h,
                          ),
                          Container(
                            width: 133.5.w,
                            height: 1.5.h,
                            decoration: BoxDecoration(
                              color: newConsult
                                  ? AppColors.linear3
                                  : Color.fromRGBO(255, 255, 255, 1),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r5.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
          ),
        ),
        // Container(
        //   height: 1.5.h,
        //   decoration: BoxDecoration(
        //     color: Color.fromRGBO(236, 236, 236, 1),
        //     borderRadius: BorderRadius.circular(AppRadius.r5.r),
        //   ),
        // ),
        SizedBox(height: AppSize.h21_3.h),

        ///------------------------Tab Bar for calls and chats-------------------------///
        CustomTabBar(
          margin: EdgeInsets.symmetric(horizontal: AppMargin.m32.w),
          buttons: [
            TabBarButton(
              isSelected: voice,
              text: getTranslated(context, "voice"),
              function: () async {
                if (allConsult) {
                  userQuery = await query.where('voice', isEqualTo: true);
                }
                if (leadingConsult) {
                  userQuery = await query
                      .where("order", isGreaterThanOrEqualTo: 1000)
                      .where('voice', isEqualTo: true);
                }
                if (newConsult) {
                  userQuery = await query
                      .where("order", isLessThan: 100)
                      .where('voice', isEqualTo: true);
                }
                setState(() {
                  voice = true;
                  chat = false;
                });
              },
            ),
            TabBarButton(
              isSelected: chat,
              text: getTranslated(context, "chat"),
              function: () async {
                if (allConsult) {
                  userQuery = await query.where('chat', isEqualTo: true);
                }
                if (leadingConsult) {
                  userQuery = await query
                      .where("order", isGreaterThanOrEqualTo: 1000)
                      .where('chat', isEqualTo: true);
                }
                if (newConsult) {
                  userQuery = await query
                      .where("order", isLessThan: 100)
                      .where('chat', isEqualTo: true);
                }
                setState(() {
                  chat = true;
                  voice = false;
                });
              },
            ),
          ],
        ),

        //
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 32.w),
        //   child: Container(
        //     width: 509.5.w,
        //     height: 59.h,
        //     decoration: BoxDecoration(
        //       borderRadius: BorderRadius.all(Radius.circular(10.AppRadius.r5.r)),
        //       color: Color.fromRGBO(156, 57, 129, 0.05),
        //     ),
        //     child: Center(
        //       child: Padding(
        //         padding:  EdgeInsets.symmetric(horizontal: 37.w),
        //         child: Row(
        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               InkWell(
        //                 onTap: () async {
        //                   if (allConsult) {
        //                     userQuery = await query.where('voice', isEqualTo: true);
        //                   }
        //                   if (leadingConsult) {
        //                     userQuery = await query
        //                         .where("order",
        //                         isGreaterThanOrEqualTo: 1000)
        //                         .where('voice', isEqualTo: true);
        //                   }
        //                   if (newConsult) {
        //                     userQuery = await query
        //                         .where("order", isLessThan: 100)   ///todo
        //                         .where('voice', isEqualTo: true);
        //                   }
        //                   setState(() {
        //                     voice = true;
        //                     chat = false;
        //                   });
        //                 },
        //                 child: Container(
        //                   width: 153.w,
        //                   height: 41.h,
        //                   decoration: BoxDecoration(
        //                     color: voice
        //                         ? AppColors.linear3
        //                         : Color.fromRGBO(250, 245, 249, 1),
        //                     borderRadius: BorderRadius.circular(AppRadius.r5.r),
        //                   ),
        //                   child: Center(
        //                     child: Text(
        //                       getTranslated(context, "voice"),
        //                       textAlign: TextAlign.center,
        //                       style: TextStyle(
        //                         fontFamily: getTranslated(context, "Ithra"),
        //                         color: voice
        //                             ? Color.fromRGBO(255, 255, 255, 1)
        //                             : AppColors.linear3,
        //                         fontSize: 21.sp,
        //                         fontWeight: FontWeight.w700,
        //                         fontStyle:  FontStyle.normal,
        //                       ),
        //                     ),
        //                   ),
        //                 ),
        //               ),
        //
        //               InkWell(
        //                 onTap: () async {
        //                   if (allConsult) {
        //                     userQuery =
        //                     await query.where('chat', isEqualTo: true);
        //                   }
        //                   if (leadingConsult) {
        //                     userQuery = await query
        //                         .where("order",
        //                         isGreaterThanOrEqualTo: 1000)
        //                         .where('chat', isEqualTo: true);
        //                   }
        //                   if (newConsult) {
        //                     userQuery = await query
        //                         .where("order", isLessThan: 100)    ///todo
        //                         .where('chat', isEqualTo: true);
        //                   }
        //                   setState(() {
        //                     chat = true;
        //                     voice = false;
        //                   });
        //                 },
        //                 child: Container(
        //                   width: 153.w,
        //                   height: 41.h,
        //                   decoration: BoxDecoration(
        //                     color: chat
        //                         ? AppColors.linear3
        //                         : Color.fromRGBO(250, 245, 249, 1),
        //                     borderRadius: BorderRadius.circular(AppRadius.r5.r),
        //                   ),
        //                   child: Center(
        //                     child: Text(
        //                       getTranslated(context, "chat"),
        //                       textAlign: TextAlign.center,
        //                       style: TextStyle(
        //                         fontFamily: getTranslated(context, "Ithra"),
        //                         color: chat
        //                             ? Color.fromRGBO(255, 255, 255, 1)
        //                             : AppColors.linear3,
        //                         fontSize: 21.sp,
        //                         fontWeight: FontWeight.w700,
        //                         fontStyle:  FontStyle.normal,
        //                       ),
        //                     ),
        //                   ),
        //                 ),
        //               ),
        //             ]),
        //       ),
        //     ),
        //   ),
        // ),
        //
        SizedBox(
          height: AppSize.h32.h,
        ),
        Expanded(
          child: PaginateFirestore(
            key: ValueKey(userQuery),
            itemBuilderType: PaginateBuilderType.gridView,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSize.w32.w,
              mainAxisSpacing: AppSize.h32.h,
              mainAxisExtent: AppSize.h246_6.h,
              childAspectRatio: 1.8,
            ),
            padding: EdgeInsets.symmetric(
                horizontal: AppPadding.p32.w, vertical: AppPadding.p4.w),
            itemBuilder: (context, documentSnapshot, index) {
              final data = documentSnapshot[index].data() as Map;

              ///todo
              return ConsultantListItem(
                  consult: GroceryUser.fromMap(data),
                  loggedUser: user,
                  consultType: voice ? "voice" : "chat");
            },
            query: userQuery, //userQuery,
            isLive: true,
          ),
        )
      ],
    );
  }

  Widget consultHome(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        //PB pd
        /* textButton(onPress: (){}, text: avaliable
        ? getTranslated(context, "available")
        : getTranslated(context, "notAvailable"), ButtonColor: avaliable ? Color.fromRGBO(131, 227, 57, 1) : Colors.grey,width: 110.6.w, height: 36.h, buttonRadius: 26.6.r, textSize: AppFontsSizeManager.s16.sp, textfont:  getTranslated(context, 'Ithra'), textcolor: AppColors.white, icon: '',),
*/
        // Padding(
        //   padding: EdgeInsets.only(
        //     top: AppPadding.p25.h,
        //     bottom: 0.h,
        //   ),
        //   child: Center(
        //     child: Container(
        //       width:lang=="ar" ?110.6.w:AppSize.w200.w,
        //       height: 36.h,
        //       decoration: BoxDecoration(
        //         color: avaliable ? Color.fromRGBO(131, 227, 57, 1) : Colors.grey,
        //         borderRadius: BorderRadius.circular(26.6.r),
        //       ),
        //       child: Center(
        //         child: Text(
        //           avaliable
        //               ? getTranslated(context, "available")
        //               : getTranslated(context, "notAvailable"),
        //           textAlign: TextAlign.center,
        //           style: TextStyle(
        //             fontFamily: getTranslated(context, 'Ithra'),
        //             color: AppColors.white,
        //             fontSize: AppFontsSizeManager.s16.sp,
        //             fontWeight: FontWeight.w400,
        //             fontStyle: FontStyle.normal,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        Expanded(
          child: PaginateFirestore(
            separator: SizedBox(
              height: 57.h,
            ),
            itemBuilderType: PaginateBuilderType.listView,
            padding: EdgeInsets.only(
                left: AppPadding.p32.w,
                right: AppPadding.p32.w,
                bottom: AppPadding.p25.h,
                top: 55.h),
            //Change types accordingly
            itemBuilder: (context, documentSnapshot, index) {
              return AppointmentWidget(
                appointment: AppAppointments.fromMap(
                    documentSnapshot[index].data() as Map),
                loggedUser: user!,
              );
            },
            query: FirebaseFirestore.instance
                .collection(Paths.appAppointments)
                .where('consult.uid', isEqualTo: user!.uid)
                .where('appointmentStatus', isEqualTo: "open")
                .orderBy('timestamp', descending: true),
            // to fetch real-time data
            isLive: true,
          ),
        )
      ],
    );
  }

  Widget imageSlider(Size size) {
    return Center(
        child: Stack(children: <Widget>[
      Column(
        children: [
          bannerList.length > 0
              ? Container(
                  // color: Colors.red,

                  padding: EdgeInsets.symmetric(horizontal: AppSize.w32.w),
                  child: ImageSlideshow(
                    //width: 509.3.w,
                    height: AppSize.h177_3.h,
                    initialPage: 0,
                    indicatorBottomPadding: AppSize.h5.h,
                    indicatorColor: AppColors.indicatorColor,
                    indicatorBackgroundColor:
                        AppColors.indicatorBackgroundColor,
                    autoPlayInterval: 3000,
                    isLoop: true,
                    children: [
                      for (var slideUser in bannerList)
                        InkWell(
                          onTap: () async {
                            setState(() {
                              loadData = true;
                            });
                            DocumentSnapshot documentSnapshot =
                                await FirebaseFirestore.instance
                                    .collection(Paths.usersPath)
                                    .doc(slideUser.uid)
                                    .get();
                            GroceryUser currentUser = GroceryUser.fromMap(
                                documentSnapshot.data() as Map);
                            setState(() {
                              loadData = false;
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConsultantDetailsScreen(
                                  consultant: currentUser,
                                  consultType:
                                      currentUser.voice! ? "voice" : "chat",
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: slideUser.image!,
                                width: AppSize.w509_3.w,
                                height: AppSize.h142_6.h,
                                fit: BoxFit.cover,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            AppColors.grey100, // Shadow color
                                        offset: Offset(0, 2), // Shadow position
                                        blurRadius: 10.0, // Shadow blur radius
                                        spreadRadius:
                                            .5, // Shadow spread radius
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.r10_6.r),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.lightPink2,
                                        BlendMode.colorBurn,
                                      ),
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) => Center(
                                  child: Image.asset(
                                    AssetsManager.dreamLogoPath,
                                    width: AppSize.w81.w,
                                    height: AppSize.h81.h,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Center(
                                  child: Visibility(
                                      visible: loadData,
                                      child: CircularProgressIndicator()))
                            ],
                          ),
                        ),
                    ],
                  ),
                )
              : SizedBox(),
        ],
      ),
      // Positioned(
      //   bottom: 1.5.w,
      //   left: 86.5.w,
      //   child: InkWell(
      //     onTap: () {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (context) => MoreScreen()),
      //       );
      //       // logEvent();
      //     },
      //     child: Container(
      //       height: AppSize.h32.h,
      //       width: AppSize.w100.w,
      //       decoration: BoxDecoration(
      //         color: AppColors.white,
      //         borderRadius: BorderRadius.circular(AppRadius.r5_3.r),
      //         boxShadow: [AppShadow.primaryShadow],
      //       ),
      //       child: Center(
      //         //d
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             Text(
      //               getTranslated(context, "visit"),
      //               textAlign: TextAlign.center,
      //               style: TextStyle(
      //                 fontFamily: getTranslated(context, 'Ithra'),
      //                 color: AppColors.linear3,
      //                 fontWeight: FontWeight.w700,
      //                 fontStyle: FontStyle.normal,
      //                 fontSize: AppFontsSizeManager.s13_5.sp,
      //               ),
      //             ),
      //             SizedBox(width: 3.w),
      //             Image.asset(
      //               AssetsManager.moreArrowPath,
      //               width: AppSize.w14.w,
      //               height: AppSize.h14.h,
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
    ]));
  }

  @override
  bool get wantKeepAlive => true;

  checkAvaliable() async {
    if (user != null &&
        user?.userType == AppConstants.consultant &&
        user!.profileCompleted!) {
      String dayNow = _now.weekday.toString();
      int timeNow = _now.hour;
      if (user!.workDays!.contains(dayNow)) {
        if (int.parse(user!.workTimes![0].from!) <= timeNow &&
            int.parse(user!.workTimes![0].to!) > timeNow) {
          //if(mounted)setState(() {
          avaliable = true;
          // });
        }
      }
    }
    if (user != null) {
      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(user!.uid!)
          .set({
        'userLang': getTranslated(context, "lang"),
      }, SetOptions(merge: true));
    }
  }

  getImageSlider() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.bannerPath)
          .where('lang', isEqualTo: getTranslated(context, "lang"))
          .where('status', isEqualTo: true)
          .get();
      var _bannerList = List<banner>.from(
        querySnapshot.docs.map(
          (snapshot) => banner.fromMap(snapshot.data() as Map),
        ),
      );
      setState(() {
        bannerList = _bannerList;
        loadBanner = false;
      });
    } catch (e) {
      setState(() {
        loadBanner = false;
      });
    }
  }

//////////test functions
  updateName() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .where('userType', isEqualTo: AppConstants.user)
          // .where('accountStatus',isEqualTo: "Active")
          .get();
      if (querySnapshot.docs.length > 0) {
        for (var doc in querySnapshot.docs) {
          List<String> indexListAr = [];
          for (int y = 1; y <= doc['name'].trimLeft().trimRight().length; y++)
            indexListAr.add(doc['name']
                .trimLeft()
                .trimRight()
                .substring(0, y)
                .toLowerCase());

          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'consultName': {
              'nameAr': doc['name'],
              'nameEn': doc['name'],
              'nameFr': doc['name'],
              'nameId': doc['name'],
              'searchIndexAr': indexListAr,
              'searchIndexEn': indexListAr,
              'searchIndexFr': indexListAr,
              'searchIndexId': indexListAr,
            },
            'userLang': 'ar'
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {}
  }

  updatelang() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .where('userType', isEqualTo: AppConstants.consultant)
          .where('languages', isEqualTo: ["العربية"]).get();
      if (querySnapshot.docs.length > 0) {
        for (var doc in querySnapshot.docs) {
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'languages': ["ar"]
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {}
  }

  EndCallDialog(Size size) {
    return showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.white),
        ),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(AppRadius.r21_3.r))),
          backgroundColor: AppColors.white,
          contentPadding: EdgeInsets.all(0),
          content: Container(
            width: AppSize.w441_3.w,
            //height: AppSize.h282_6.h,
            padding: EdgeInsets.symmetric(
                horizontal: AppPadding.p32.w, vertical: AppPadding.p32.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                    mainAxisAlignment: lang == 'ar'
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      InkWell(
                        child: Image.asset(
                          AssetsManager.black_cancel_iconPath,
                          width: AppSize.w32.w,
                          height: AppSize.h32.h,
                          // color: AppColors.linear2,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      )
                    ]),
                Container(
                  width: AppSize.w260.w,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      getTranslated(context, "endCallTxt"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: lang == "ar"
                            ? getTranslated(context, "Ithra")
                            : getTranslated(context, "Montserrat-SemiBold"),
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: AppSize.h53_3.h,
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          //await updateFirebaseToken(FirebaseAuth.instance.currentUser!);
                          await changeUserState(
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              state: 'closed');
                        },
                        child: Container(
                          // width: AppSize.w151.w,
                          height: AppSize.h56.h,
                          decoration: BoxDecoration(
                              color: AppColors.darkRed2,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r10_6.r)),
                          child: Center(
                            child: Text(
                              getTranslated(context, "ending"),
                              style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: AppFontsSizeManager.s18_6.sp,
                                  fontFamily:
                                      //  lang == "ar"
                                      //     ?
                                      getTranslated(context, "Ithra")
                                  // : getTranslated(
                                  //     context, "Montserrat-SemiBold"),
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: AppSize.w21_3.w,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          // width: AppSize.w178.w,
                          height: AppSize.h56.h,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius:
                                BorderRadius.circular(AppRadius.r10_6.r),
                            border: Border.all(
                              color: AppColors.darkRed2,
                              width: AppSize.w2.w,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, "no"),
                              style: TextStyle(
                                  color: AppColors.darkRed2,
                                  fontSize: AppFontsSizeManager.s18_6.sp,
                                  fontFamily:
                                      // lang == "ar"
                                      //     ?
                                      getTranslated(context, "Ithra")
                                  // : getTranslated(
                                  //     context, "Montserrat-SemiBold"),
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
