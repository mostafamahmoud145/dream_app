import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:grocery_store/models/user_notification.dart';
import 'package:grocery_store/screens/AppointmentChatScreen.dart';
import 'package:grocery_store/screens/addReviewScreen.dart';
import 'package:grocery_store/screens/agoraScreen.dart';
import 'package:grocery_store/screens/generalNotificationScreen.dart';
import 'package:grocery_store/screens/home_screen.dart';
import 'package:intl/intl.dart';

import '../blocs/notification_bloc/notification_bloc.dart';
import '../models/user_notification.dart' as prefix;
import '../screens/payInfo1Screen.dart';

class NotificationItem extends StatefulWidget {
  final Size size;
  final UserNotification userNotification;
  final int index;
  final List<prefix.Notification> notificationList;
  NotificationBloc? notificationBloc;

  NotificationItem({
    required this.size,
    required this.userNotification,
    required this.index,
    required this.notificationList,
    this.notificationBloc,
  });

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  String lang = "ar";
  // dynamic getTimeAgoOrCompare(int index) {
  //   // Convert the current timestamp to a 'time ago' string.
  //   String current =
  //       timeago.format(widget.notificationList[index].timestamp!.toDate());

  //   // Check if the next index is within bounds.
  //   if (
  //     index + 1 < widget.notificationList.length
  //     ) {
  //     // Convert the next timestamp to a 'time ago' string.
  //     String next = timeago
  //         .format(widget.notificationList[index + 2].timestamp!.toDate());

  //     // Compare the current 'time ago' with the next.
  //     if (current == next) {
  //       // Return true if they are the same.
  //       return current;
  //     }
  //   }

  //   // Return the 'time ago' string for the current index if they are not the same or if it's the last item.
  //   return '';
  // }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double getTimeAgoOrCompare() {
      DateTime currentDate =
          widget.notificationList[widget.index].timestamp!.toDate();
      if ((widget.index) + 1 < widget.notificationList.length) {
        // Convert the next timestamp to a DateTime object.
        DateTime nextDate =
            widget.notificationList[(widget.index) + 1].timestamp!.toDate();

        if (currentDate.day != nextDate.day) {
          // Return a SizedBox to represent a space between the days.
          return 32; // Customize the height as needed.
        }
      }

      // Return the 'time ago' string for the current index if they are not the same or if it's the last item.
      return 0;
    }

    // bool hideTimeDublicateours() {
    //   DateTime currentDate =
    //       widget.notificationList[widget.index].timestamp!.toDate();

    //   // Convert the next timestamp to a DateTime object.
    //   DateTime nextDate =
    //       widget.notificationList[(widget.index) + 1].timestamp!.toDate();

    //   if (nextDate.hour == currentDate.hour) {
    //     // Return a SizedBox to represent a space between the days.
    //     return false; // Customize the height as needed.
    //   }

    //   // Return the 'time ago' string for the current index if they are not the same or if it's the last item.
    //   return true;
    // }

    String getTimeAgoByHours(DateTime timestamp) {
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      if (difference.inDays > 0) {
        // For durations longer than a day, show in days.
        return '${getTranslated(context, "since")}${difference.inDays == 1 && lang == 'ar' ? '' : difference.inDays == 2 && lang == 'ar' ? "": " "+difference.inDays.toString()} ${difference.inDays == 1 ? getTranslated(context, "day") : difference.inDays > 2 && difference.inDays < 12 && lang != 'ar' ? getTranslated(context, "days") : difference.inDays == 2 && lang == 'ar' ? getTranslated(context, "twoDays") : difference.inDays > 2 && difference.inDays < 12 ? getTranslated(context, "days") : getTranslated(context, "day")}  ';
      } else if (difference.inHours > 0) {
        // For durations less than a day but more than an hour, show in hours.
        return '${getTranslated(context, "since")}${difference.inHours == 1 && lang == 'ar' ? '' : difference.inHours == 2 && lang == 'ar' ? getTranslated(context, "twohours") : " "+difference.inHours.toString()} ${difference.inHours == 1 ? getTranslated(context, "hour") : difference.inHours > 2 && difference.inHours < 12 && lang != 'ar' ? getTranslated(context, "hours") : difference.inHours == 2 && lang == 'ar' ? getTranslated(context, "twohours") : difference.inHours > 2 && difference.inHours < 12 ? getTranslated(context, "hours") : getTranslated(context, "hour")}';
      } else if (difference.inMinutes > 0) {
        // For durations less than an hour, show in minutes.
        return '${getTranslated(context, "since")} ${difference.inMinutes == 1 && lang == 'ar' ? '' : difference.inMinutes} ${difference.inMinutes == 1 ? getTranslated(context, "minute") : difference.inMinutes > 2 && difference.inMinutes < 12 && lang == 'ar' ? getTranslated(context, "minute") : getTranslated(context, "minutes")} ';
      } else {
        // For durations less than a minute, show just now.
        return '${getTranslated(context, "justNow")} ';
      }
    }

    DateTime timestamp =
        widget.notificationList[widget.index].timestamp!.toDate();
    // var time = timeago
    //     .format(widget.notificationList[widget.index].timestamp!.toDate());
    String timeAgo = getTimeAgoByHours(timestamp);
    lang = getTranslated(context, "lang");
    final Key key = UniqueKey();
    DateFormat dateFormat = DateFormat('MMM dd yyyy hh:mm a');
    return InkWell(
      splashColor: AppColors.white.withOpacity(0.5),
      onTap: () async {
        try {
          bool review = true;
          if (review &&
              widget.notificationList[widget.index].notificationType ==
                  "Review_Notification") {
            review = false;
            QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                .collection(Paths.consultReviewsPath)
                .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .where('appointmentId',
                    isEqualTo:
                        widget.notificationList[widget.index].appointmentId)
                .get();
            if (querySnapshot.size > 0) {
              showSnack(getTranslated(context, "ratedbefor"), context);
            } else
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddReviewScreen(
                      consultId:
                          widget.notificationList[widget.index].consultUid!,
                      userId: widget.notificationList[widget.index].userUid!,
                      appointmentId:
                          widget.notificationList[widget.index].appointmentId!),
                ),
              );
          } else if (widget.notificationList[widget.index].notificationType ==
                  "Appointment_Notification" &&
              widget.notificationList[widget.index].type == "consult")
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  notificationPage: 0,
                ),
              ),
            );
          else if (widget.notificationList[widget.index].notificationType ==
                  "Appointment_Notification" &&
              widget.notificationList[widget.index].type == AppConstants.user)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  notificationPage: 1,
                ),
              ),
            );
          else if (widget.notificationList[widget.index].notificationType ==
              "TechnicalSupport")
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  notificationPage: 2,
                ),
              ),
            );
          else if (widget.notificationList[widget.index].notificationType ==
              "Chat") {
            DocumentReference docRef = FirebaseFirestore.instance
                .collection(Paths.usersPath)
                .doc(widget.notificationList[widget.index].userUid);
            final DocumentSnapshot documentSnapshot = await docRef.get();
            var user = GroceryUser.fromMap(documentSnapshot.data() as Map);

            DocumentReference docRef2 = FirebaseFirestore.instance
                .collection(Paths.appAppointments)
                .doc(widget.notificationList[widget.index].appointmentId);
            final DocumentSnapshot documentSnapshot2 = await docRef2.get();
            var appointment =
                AppAppointments.fromMap(documentSnapshot2.data() as Map);
            if (appointment.appointmentStatus != "closed" &&
                appointment.appointmentStatus != "cancel")
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentChatScreen(
                      appointment: appointment, user: user),
                ),
              );
            else if (appointment.appointmentStatus != "closed")
              showSnack(getTranslated(context, "appointmentClosed"), context);
            else
              showSnack(getTranslated(context, "appointmentCanceled"), context);
          } else if (widget.notificationList[widget.index].notificationType ==
              "Calling") {
            DocumentReference docRef = FirebaseFirestore.instance
                .collection(Paths.usersPath)
                .doc(widget.notificationList[widget.index].userUid);
            final DocumentSnapshot documentSnapshot = await docRef.get();
            var user = GroceryUser.fromMap(documentSnapshot.data() as Map);

            DocumentReference docRef2 = FirebaseFirestore.instance
                .collection(Paths.appAppointments)
                .doc(widget.notificationList[widget.index].appointmentId);
            final DocumentSnapshot documentSnapshot2 = await docRef2.get();
            var appointment =
                AppAppointments.fromMap(documentSnapshot2.data() as Map);
            if (appointment.appointmentStatus != "closed" &&
                appointment.appointmentStatus != "cancel" &&
                appointment.allowCall) {
              String callerId;
              if (user.userType == AppConstants.user) {
                callerId = appointment.consult.uid;
              } else {
                callerId = appointment.user.uid;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AgoraScreen(
                      appointment: appointment,
                      user: user,
                      callerId: callerId,
                      receiverId: user.uid,
                      fromChatScreen: true,
                      isCaller: false,
                      appointmentId: appointment.appointmentId,
                      consultName: appointment.consult.name),
                ),
              );
            } else if (appointment.appointmentStatus != "closed")
              showSnack(getTranslated(context, "appointmentClosed"), context);
            else
              showSnack(getTranslated(context, "appointmentCanceled"), context);
          } else if (widget.notificationList[widget.index].notificationType ==
              "Account") {
            DocumentReference docRef = FirebaseFirestore.instance
                .collection(Paths.usersPath)
                .doc(widget.notificationList[widget.index].userUid);
            final DocumentSnapshot documentSnapshot = await docRef.get();
            var user = GroceryUser.fromMap(documentSnapshot.data() as Map);

            if (user.allowEditPayinfo!)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => payInfo1Screen(
                    consultId: widget.notificationList[widget.index].userUid!,
                  ),
                ),
              );
            else
              showSnack(getTranslated(context, "contactSupport"), context);
          } else
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GeneralNotificationScreen(
                    title: widget
                        .notificationList[widget.index].notificationTitle!,
                    body:
                        widget.notificationList[widget.index].notificationBody!,
                    image: widget.notificationList[widget.index].image,
                    link: widget.notificationList[widget.index].link),
              ),
            );
        } catch (e) {}
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
              child:
                  // timeago
                  //             .format(widget
                  //                 .notificationList[widget.index + 1].timestamp!
                  //                 .toDate())
                  //             .toString() ==
                  //         timeago
                  //             .format(widget
                  //                 .notificationList[widget.index].timestamp!
                  //                 .toDate())
                  //             .toString()
                  //     ?
                  // hideTimeDublicateours()
                  // ?
                  Text(
                timeAgo,
                //  getTimeAgoOrCompare(widget.index).toString(),
                // '${dateFormat.format(widget.notificationList[widget.index].timestamp!.toDate())}',
                style: TextStyle(
                  fontFamily: getTranslated(context, 'Ithra'),
                  fontSize: AppFontsSizeManager.s18_6.sp,
                  color: Theme.of(context).primaryColor,
                ),
              )
              //: SizedBox()
              ),
          SizedBox(height: AppSize.h21_3.h),
          Dismissible(
            background: Container(
              color: AppColors.red1,
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p36_6.w),
              alignment: AlignmentDirectional.centerStart,
              child: Icon(Icons.delete_outline_outlined,
                  size: AppSize.h32.r, color: AppColors.white),
            ),
            direction: lang == 'ar'
                ? DismissDirection.startToEnd
                : DismissDirection
                    .endToStart, // Only allows the user to swipe from right to left
            onDismissed: (direction) {
              // Handle the dismissed action (e.g., delete the item)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(getTranslated(context, 'ItemDeleted'))),
              );
            },
            key: key,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
              width: double.infinity,
              height: AppSize.h90_6.h,
              decoration: BoxDecoration(
                  //  color: Colors.blue.shade100,
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      // height: 10.6.h,
                      ),
                  Row(
                    children: [
                      Text(
                        widget
                            .notificationList[widget.index].notificationTitle!,
                        // '${notificationList[index].notificationTitle}',
                        style: TextStyle(
                          fontFamily: getTranslated(context, 'Ithra'),
                          fontSize: AppFontsSizeManager.s21_3.sp,
                          color: AppColors.pureBlack,
                        ),
                      ),
                      Spacer(),
                      Image.asset(AssetsManager.arrowLeft)
                    ],
                  ),
                  SizedBox(
                    height: AppSize.h10_6.h,
                  ),
                  Expanded(
                    child: Text(
                      '${widget.notificationList[widget.index].notificationBody}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppFontsSizeManager.s18_6.sp,
                        fontFamily: getTranslated(context, 'Ithralight'),
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: 10.h,
                  // )
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: AppPadding.p14_6.h, bottom: getTimeAgoOrCompare().h),
            child: Container(
              width: double.infinity,
              height: AppSize.h1.h,
              color: AppColors.lightGray,
            ),
          )
        ],
      ),
    );
  }

  void showSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(7),
      backgroundColor: Colors.green.shade500,
      animationDuration: Duration(milliseconds: 300),
      isDismissible: true,
      boxShadows: [AppShadow.primaryShadow],
      shouldIconPulse: false,
      duration: Duration(milliseconds: 2000),
      icon: Icon(
        Icons.error,
        color: AppColors.white,
      ),
      messageText: Text(
        '$text',
        style: GoogleFonts.poppins(
          fontSize: AppFontsSizeManager.s14.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: AppColors.white,
        ),
      ),
    )..show(context);
  }

  Future<void> deleteUser() async {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('UserNotifications')
        .doc(userUid)
        .delete();
    widget.notificationBloc!.add(GetAllNotificationsEvent(userUid));
  }
}
