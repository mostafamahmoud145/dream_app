import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../models/user.dart';
import '../blocs/account_bloc/account_bloc.dart';
import '../config/colorsFile.dart';
import '../config/paths.dart';
import '../localization/localization_methods.dart';
import '../models/AppAppointments.dart';
import '../models/order.dart';

class EndCallDialog extends StatefulWidget {
  final AppAppointments appointment;
  final GroceryUser user;

  EndCallDialog({
    required this.appointment,
    required this.user,
  });

  @override
  _EndCallDialogState createState() => _EndCallDialogState();
}

class _EndCallDialogState extends State<EndCallDialog> {
  bool endingCall = false, done = true;
  late AccountBloc accountBloc;

  @override
  void initState() {
    super.initState();
    accountBloc = BlocProvider.of<AccountBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        elevation: 5.0,
        contentPadding: EdgeInsets.all(0),
        content: StatefulBuilder(builder: (context, setState) {
          return Container(
            // height: size.height * 0.25,
            width: double.maxFinite,
            constraints: BoxConstraints.loose(size),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    getTranslated(context, "doesCallEndWithClient"),
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                      color: AppColors.black1,
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        width: 50.0,
                        child: MaterialButton(
                          padding: const EdgeInsets.all(0.0),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection(Paths.appAppointments)
                                .doc(widget.appointment.appointmentId)
                                .set({
                              'allowCall': false,
                            }, SetOptions(merge: true));

                            Navigator.pop(context);
                            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                            //Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          child: Text(
                            getTranslated(context, 'no'),
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              color: AppColors.black1,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      endingCall
                          ? Center(child: CircularProgressIndicator())
                          : Container(
                              width: 50.0,
                              child: MaterialButton(
                                padding: const EdgeInsets.all(0.0),
                                onPressed: () {
                                  setState(() {
                                    endingCall = true;
                                  });
                                  callDone(context);

                                 /* Navigator.pop(context);
                                  confirmEndCallDialog(size, context);*/
                                },
                                child: Text(
                                  getTranslated(context, 'yes'),
                                  style: TextStyle(
                                    fontFamily:
                                        getTranslated(context, "Ithra"),
                                    color: Colors.red.shade700,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }));
  }

  //-----------
  // confirmEndCallDialog(Size size, BuildContext context) {
  //   return showDialog(
  //     builder: (context) => AlertDialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.all(
  //           Radius.circular(15.0),
  //         ),
  //       ),
  //       elevation: 5.0,
  //       contentPadding: const EdgeInsets.only(
  //           left: AppPadding.p16, right: AppPadding.p16, top: 20.0, bottom: 10.0),
  //       content: StatefulBuilder(
  //         builder: (context, setState) {
  //           return Column(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisSize: MainAxisSize.min,
  //             children: <Widget>[
  //               SizedBox(
  //                 height: 15.0,
  //               ),
  //               Text(
  //                 getTranslated(context, "areYouSureCloseAppointment"),
  //                 style: TextStyle(
  //                   fontFamily: getTranslated(context, "Ithra"),
  //                   fontSize: 14.0,
  //                   fontWeight: FontWeight.bold,
  //                   color: AppColors.pink,
  //                 ),
  //               ),
  //               SizedBox(
  //                 height: 10.0,
  //               ),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 mainAxisSize: MainAxisSize.max,
  //                 children: <Widget>[
  //                   InkWell(
  //                     onTap: () async {
  //                       await FirebaseFirestore.instance
  //                           .collection(Paths.appAppointments)
  //                           .doc(widget.appointment.appointmentId)
  //                           .set({
  //                         'allowCall': false,
  //                       }, SetOptions(merge: true));
  //                       Navigator.pop(context);
  //                       //Navigator.pop(context);
  //                       Navigator.pushNamedAndRemoveUntil(
  //                         context,
  //                         '/home',
  //                         (route) => false,
  //                       );
  //                     },
  //                     child: Container(
  //                       height: 35,
  //                       width: 50,
  //                       padding: const EdgeInsets.all(2),
  //                       decoration: BoxDecoration(
  //                         color: AppColors.lightPink,
  //                         borderRadius: BorderRadius.circular(10.0),
  //                       ),
  //                       child: Center(
  //                         child: Text(
  //                           getTranslated(context, "no"),
  //                           textAlign: TextAlign.center,
  //                           style: TextStyle(
  //                               fontFamily:
  //                                   getTranslated(context, "Ithra"),
  //                               color: AppColors.pink,
  //                               fontSize: 11.0,
  //                               fontWeight: FontWeight.bold),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   endingCall
  //                       ? Center(child: CircularProgressIndicator())
  //                       : InkWell(
  //                           onTap: () async {
  //                             setState(() {
  //                               endingCall = true;
  //                             });
  //                             callDone(context);
  //                           },
  //                           child: Container(
  //                             height: 35,
  //                             width: 50,
  //                             padding: const EdgeInsets.all(2),
  //                             decoration: BoxDecoration(
  //                               color: AppColors.pink,
  //                               borderRadius: BorderRadius.circular(10.0),
  //                             ),
  //                             child: Center(
  //                               child: Text(
  //                                 getTranslated(context, "yes"),
  //                                 textAlign: TextAlign.center,
  //                                 style: TextStyle(
  //                                   fontFamily:
  //                                       getTranslated(context, "Ithra"),
  //                                   color: AppColors.white,
  //                                   fontSize: 11.0,
  //                                   fontWeight: FontWeight.bold,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                 ],
  //               ),
  //             ],
  //           );
  //         },
  //       ),
  //     ),
  //     barrierDismissible: false,
  //     context: context,
  //   );
  // }

  Future<void> callDone(BuildContext context) async {
    try {
      //update appointment
      var answeredCallNum = 0, packageCallNum = 0, remainingCall = 0;
      var dateNow = DateTime.now();
      if (done &&
          widget.user != null &&
          widget.user.userType == AppConstants.consultant &&
          widget.appointment != null) {
        done = false;
        //close appointment
        if (widget.appointment.consultType == "vocal") {
          await FirebaseFirestore.instance
              .collection(Paths.appAppointments)
              .doc(widget.appointment.appointmentId)
              .set({
            'appointmentStatus': "closed",
            'allowCall': false,
            'closedUtcTime': dateNow.toUtc().toString(),
            'closedDate': {
              'day': dateNow.toUtc().day,
              'month': dateNow.toUtc().month,
              'year': dateNow.toUtc().year,
            },
          }, SetOptions(merge: true));
        } else {
          await FirebaseFirestore.instance
              .collection(Paths.forEverAppointmentsPath)
              .doc(Uuid().v4())
              .set({
            'appointmentId': widget.appointment.appointmentId,
            'appointmentStatus': 'closed',
            'timestamp': DateTime.now().toUtc(),
            'utcTime': DateTime.now().toUtc().toString(),
            "consultType": widget.appointment.consultType,
            'orderId': widget.appointment.orderId,
            'callPrice': widget.appointment.callPrice,
            'consult': {
              'uid': widget.appointment.consult.uid,
              'name': widget.appointment.consult.name,
              'image': widget.appointment.consult.image,
              'phone': widget.appointment.consult.phone,
              // 'countryCode': widget.appointment.consult.countryCode,
              // 'countryISOCode': widget.appointment.consult.countryISOCode,
            },
            'user': {
              'uid': widget.appointment.user.uid,
              'name': widget.appointment.user.name,
              'image': widget.appointment.user.image,
              'phone': widget.appointment.user.phone,
              // 'countryCode': widget.appointment.user.countryCode,
              // 'countryISOCode': widget.appointment.user.countryISOCode,
            },
            'date': {
              'day': DateTime.now().toUtc().day,
              'month': DateTime.now().toUtc().month,
              'year': DateTime.now().toUtc().year,
            },
            'time': {
              'hour': DateTime.now().toUtc().hour,
              'minute': DateTime.now().toUtc().minute,
            },
          });
        }





        //update order
        await FirebaseFirestore.instance
            .collection(Paths.ordersPath)
            .doc(widget.appointment.orderId)
            .get()
            .then((value) async {
          packageCallNum = Orders.fromMap(value.data() as Map).packageCallNum;
          if (widget.appointment.consultType == "glorified" ||
              widget.appointment.consultType == "vocal") {
            await FirebaseFirestore.instance
                .collection(Paths.appAppointments)
                .where(
                  'orderId',
                  isEqualTo: widget.appointment.orderId,
                )
                .get()
                .then((value) async {
              if (value.docs.length > 0) {
                remainingCall = packageCallNum - value.docs.length;
                for (var doc in value.docs) {
                  if (doc['appointmentStatus'] != null &&
                      doc['appointmentStatus'] == 'closed') answeredCallNum++;
                }
              } else {
                remainingCall = packageCallNum;
                answeredCallNum = 0;
              }
              await FirebaseFirestore.instance
                  .collection(Paths.ordersPath)
                  .doc(widget.appointment.orderId)
                  .set({
                'answeredCallNum': answeredCallNum,
                'orderStatus': packageCallNum == answeredCallNum
                    ? "closed"
                    : remainingCall == 0
                        ? 'completed'
                        : 'open',
                'remainingCallNum': remainingCall > 0 ? remainingCall : 0,
              }, SetOptions(merge: true));
            }).catchError((err) {
              errorLog("callDone", err.toString());
            });
          } else {

            await FirebaseFirestore.instance
                .collection(Paths.appAppointments)
                .doc(widget.appointment.appointmentId)
                .update({
              'appointmentStatus': "closed",
              'allowCall': false,
              'closedUtcTime': DateTime.now().toUtc().toString(),
              'closedDate': {
                'day': DateTime.now().toUtc().day,
                'month': DateTime.now().toUtc().month,
                'year': DateTime.now().toUtc().year,
              },
            });

            /*
            await FirebaseFirestore.instance
                .collection(Paths.forEverAppointmentsPath)
                .where(
                  'orderId',
                  isEqualTo: widget.appointment.orderId,
                )
                .get()
                .then((value) async {



              if (value.docs.length > 0) {
                remainingCall = (packageCallNum - value.docs.length) > 0
                    ? (packageCallNum - value.docs.length)
                    : 0;
                answeredCallNum = value.docs.length;
              } else {
                remainingCall = packageCallNum;
                answeredCallNum = 0;
              }

              await FirebaseFirestore.instance
                  .collection(Paths.ordersPath)
                  .doc(widget.appointment.orderId)
                  .set({
                'answeredCallNum': answeredCallNum,
                'orderStatus':
                    answeredCallNum >= packageCallNum ? "closed" : 'completed',
                'remainingCallNum': remainingCall
              }, SetOptions(merge: true));
              DateTime newDate = DateTime.parse(widget.appointment.utcTime);
              for (int x = 1; x < 15; x++) {
                var _now2 = newDate.add(Duration(days: x));

                if (widget.user.workDays!.contains(_now2.weekday.toString())) {
                  await FirebaseFirestore.instance
                      .collection(Paths.appAppointments)
                      .doc(widget.appointment.appointmentId)
                      .set({
                    'utcTime': _now2.toString(),
                    'date': {
                      'day': _now2.day,
                      'month': _now2.month,
                      'year': _now2.year,
                    },
                    'remainingCallNum': (packageCallNum - answeredCallNum) > 0
                        ? (packageCallNum - answeredCallNum)
                        : 0,
                    'appointmentStatus':
                        answeredCallNum >= packageCallNum ? "closed" : 'open',
                    'allowCall': false
                  }, SetOptions(merge: true));
                  break;
                } else {}
              }


            }).catchError((err) {
              errorLog("callDone", err.toString());
            });

            */
          }


          /*
          //update consultbalance
          DocumentReference docRef = FirebaseFirestore.instance
              .collection(Paths.settingPath)
              .doc("pzBqiphy5o2kkzJgWUT7");

          final DocumentSnapshot taxDocumentSnapshot = await docRef.get();
          var taxes = Setting.fromMap(taxDocumentSnapshot.data() as Map).taxes;

          DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(widget.user.uid)
              .get();

          //GroceryUser currentUser = widget.user;
          GroceryUser currentUser = GroceryUser.fromMap(documentSnapshot.data() as Map);
          dynamic taxesvalue = (widget.appointment.callPrice * taxes) / 100;
          dynamic consultBalance = widget.appointment.callPrice - taxesvalue;


          dynamic payedBalance = consultBalance;
          if (currentUser.payedBalance != null)
            payedBalance = payedBalance + currentUser.payedBalance;

          if (currentUser.balance != null)
            consultBalance = consultBalance + currentUser.balance;


          //update consult order numbers
          int consultOrdersNumbers = 1;
          int consultOrders = 1;

          if (widget.user.ordersNumbers != null)
            consultOrdersNumbers = 1 + widget.user.ordersNumbers!;//
            consultOrders = 1 + widget.user.order!;//

          // if (packageCallNum == answeredCallNum)
            // widget.user.consultOpenAppointmentDates!.removeWhere((element) => element==(widget.appointment.time.hour.toString()+":"+widget.appointment.time.minute.toString()));

            await FirebaseFirestore.instance
                .collection(Paths.usersPath)
                .doc(widget.user.uid)
                .set({
              'balance': consultBalance,
              'payedBalance': payedBalance,
              'ordersNumbers': consultOrdersNumbers,
              'order': consultOrders
              // 'openOrders':answeredCallNum>=packageCallNum?(currentUser.openOrders)-1:currentUser.openOrders,
              // 'consultOpenAppointmentDates':widget.user.consultOpenAppointmentDates
            }, SetOptions(merge: true));

          // if(widget.appointment.course!=null)
          // {
          //
          //   sendCourseReviewNotification("test Course Name", "test Course Id", "${widget.user.uid}", "${widget.appointment.appointmentId}");
          // }

          */
          if (answeredCallNum >= packageCallNum ||
              answeredCallNum == packageCallNum / 2) {
            sendReviewNotification(
                widget.appointment.consult.name,
                widget.appointment.consult.uid,
                widget.appointment.user.uid,
                widget.appointment.appointmentId);
          }

          /*  setState(() {
            endingCall=false;
          });*/
          Navigator.pop(context);
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
          accountBloc.add(GetLoggedUserEvent());
        }).catchError((err) {
          errorLog("callDone", err.toString());
        });
      }
    } catch (e) {

      errorLog("callDone", e.toString());
    }
  }


  double calculatePriceAfterTax(double price, double taxPercentage) {
    double taxAmount = (price * taxPercentage) / 100;
    double priceAfterTax = price - taxAmount;
    return priceAfterTax;
  }


  Future<void> sendReviewNotification(String consultName, String consultUid,
      String userId, String appointmentId) async {
    try {
      Map notifMap = Map(); //sendReviewNotification
      notifMap.putIfAbsent(
          'consultName', () => widget.appointment.consult.name);
      notifMap.putIfAbsent('consultUid', () => widget.appointment.consult.uid);
      notifMap.putIfAbsent('userId', () => widget.appointment.user.uid);
      notifMap.putIfAbsent(
          'appointmentId', () => widget.appointment.appointmentId);
      await http.post(
        Uri.parse(
            'https://us-central1-app-jeras.cloudfunctions.net/sendReviewNotification'),
        body: notifMap,
      );
    } catch (e) {

      /*  setState(() {
            endingCall=false;
          });*/
      Navigator.pop(context);
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
      accountBloc.add(GetLoggedUserEvent());
    }
  }

  Future<void> sendCourseReviewNotification(String courseName, String courseid,
      String userId, String appointmentId) async {
    try {
      Map notifMap = Map(); //sendReviewNotification
      // notifMap.putIfAbsent('courseName', () => widget.appointment.course!.name);
      // notifMap.putIfAbsent('courseid', () => widget.appointment.course!.id);
      notifMap.putIfAbsent('userId', () => widget.appointment.user.uid);
      notifMap.putIfAbsent(
          'appointmentId', () => widget.appointment.appointmentId);
      await http.post(
        Uri.parse(
            'https://us-central1-app-jeras.cloudfunctions.net/sendCourseReviewNotification'),
        body: notifMap,
      );
    } catch (e) {

    }
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
      'phone': widget.user == null ? " " : widget.user.phoneNumber,
      'screen': "videoScreen",
      'function': function,
    });
  }
}
