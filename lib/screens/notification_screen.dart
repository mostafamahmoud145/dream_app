import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user_notification.dart';
import 'package:grocery_store/widget/dreamDialogsWidget.dart';
import 'package:grocery_store/widget/notification_item.dart';

import '../config/colorsFile.dart';
import '../models/user_notification.dart' as prefix;
import '../widget/back_button.dart';

class NotificationScreen extends StatefulWidget {
  final UserNotification userNotification;

  const NotificationScreen({Key? key, required this.userNotification})
      : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late NotificationBloc notificationBloc;
  bool isLoading = true;
  String lang = "ar";

  @override
  void initState() {
    super.initState();
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang = getTranslated((context), "lang");

    List<prefix.Notification> notificationList =
        widget.userNotification.notifications.reversed.toList();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding(
                padding: EdgeInsets.only(
                    left: lang == "ar" ? AppPadding.p0 : AppPadding.p32.w,
                    right: AppPadding.p32.w,
                    top: AppPadding.p16.h,
                    bottom: AppPadding.p16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CustomBackButton(),
                        // IconButton1(
                        //   radius: AppRadius.r10_6.r,
                        //   color: AppColors.white,
                        //   shadowcolor: AppColors.warmPurple,
                        //   iconsize: AppSize.w32_6,
                        //   icon: lang=="ar"? AssetsManager.purple_right_arrowPath:AssetsManager.purple_left_arrowPath,
                        //   iconcolor:AppColors.linear2,
                        //   onPress: () {
                        //     Navigator.pop(context);
                        //   },
                        //   width: AppSize.w50_6.r,
                        //   height:AppSize.h50_6.r,
                        // ),
                        SizedBox(
                          width: AppSize.w16.w,
                        ),
                        Text(
                          getTranslated(context, "notification"),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              fontSize: AppFontsSizeManager.s21_3.sp,
                              color: AppColors.pureBlack.withOpacity(0.8),
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey,
                  height: AppSize.h1.h,
                  width: size.width)),
          Padding(
            padding: EdgeInsets.only(
                top: AppPadding.p37_3.h,
                right: AppPadding.p32.w,
                left: AppPadding.p32.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTranslated(context, "deleteAll"),
                  style: TextStyle(
                      color: AppColors.black,
                      fontFamily: getTranslated(context, "Ithra"),
                      fontSize: AppFontsSizeManager.s18_6.sp),
                ),
                InkWell(
                  splashColor: AppColors.white.withOpacity(0.6),
                  onTap: () {
                    deleteAllNotificaton(size);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    width: AppSize.w38.w,
                    height: AppSize.h35.h,
                    child: Image.asset(
                      AssetsManager.deleteRed,
                      height: AppPadding.p32.h,
                      width: AppPadding.p32.w,
                      //size: AppSize.w24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                // horizontal: AppSize.w32.w,
                vertical: AppSize.h32.h,
              ),
              itemBuilder: (context, index) {
                return NotificationItem(
                  size: size,
                  userNotification: widget.userNotification,
                  notificationList: notificationList,
                  index: index,
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: AppSize.h16.h,
                );
                // Center(
                //     child: Container(
                //         color: AppColors.lightGrey, height: 1, width: size.width * .9));
              },
              itemCount: notificationList.length,
            ),
          ),
        ],
      ),
    );
  }

  deleteAllNotificaton(Size size) {
    return showDialog(
      builder: (context) => DreamDialogsWidget(
        padBottom: 0,
        padLeft: 0,
        padRight: 0,
        padTop: 0,
        dialogContent: Container(
          width: AppSize.w441_3.w,
          //height: AppSize.h282_6.h,
          padding: EdgeInsets.symmetric(
              horizontal: AppPadding.p32.w, vertical: AppPadding.p32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      AssetsManager.pink_cancel_iconPath,
                      width: AppSize.w32.r,
                      height: AppSize.h32.r,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    getTranslated(context, "DoYouWantDeleteAllNotifi"),
                    style: TextStyle(
                      height: AppSize.h2_5.h,
                      fontFamily: getTranslated(context, 'Ithra'),
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      color: AppColors.black4,
                      fontWeight: AppFontsWeightManager.bold500,
                      fontStyle: FontStyle.normal,
                      wordSpacing: 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: AppSize.h53_3.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            String userUid =
                                FirebaseAuth.instance.currentUser!.uid;
                            FirebaseFirestore.instance
                                .collection('UserNotifications')
                                .doc(userUid)
                                .delete();
                            notificationBloc
                                .add(GetAllNotificationsEvent(userUid));
                            // setState(() {
                            //   widget.userNotification.notifications=[];
                            Navigator.pop(context);
                            // });
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/home', (route) => false);
                          },
                          child: Container(
                            // width: AppSize.w160.w,
                            height: AppSize.h56.h,
                            //   alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.red8,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r10_6.r),
                            ),
                            child: Center(
                              child: Text(
                                getTranslated(context, 'delete'),
                                style: TextStyle(
                                  fontFamily: getTranslated(context, 'Ithra'),
                                  fontSize: AppFontsSizeManager.s18_6.sp,
                                  color: AppColors.white1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: AppSize.w21_3.w,
                      ),
                      //SizedBox(width: AppSize.w57_3.w),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            // width: AppSize.w160.w,
                            height: AppSize.h56.h,
                            //   alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(AppRadius.r10_6.r)),
                                border: Border.all(
                                  color: AppColors.red8,
                                  width: AppSize.w1_5.w,
                                )),
                            child: Center(
                              child: Text(
                                getTranslated(context, 'cancel'),
                                style: TextStyle(
                                  fontFamily: getTranslated(context, 'Ithra'),
                                  fontSize: AppFontsSizeManager.s18_6.sp,
                                  color: AppColors.red8,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
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
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }
}
