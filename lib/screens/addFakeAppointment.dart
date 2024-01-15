import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart'
;
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:uuid/uuid.dart';

import '../services/app_flyer_service.dart';

class AddAppointmentScreen extends StatefulWidget {
  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool saving = false;
  String? userPhone, consultPhone, theme = "light";
  String? price, callNum, dropdownOrderTypeValue;
  List<KeyValueModel> _orderTypeArray = [
    KeyValueModel(key: "voice", value: "مكالمات"),
    KeyValueModel(key: "chat", value: "رسائل"),
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: <Widget>[
          Container(
            width: size.width,
            height: AppSize.h100.h,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(left: AppPadding.p16, right: AppPadding.p16, bottom: AppPadding.p16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.r50.r),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: AppColors.white.withOpacity(0.5),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            width: AppSize.w38.w,
                            height: AppSize.h35.h,
                            child: Icon(
                              Icons.arrow_back,
                              color: theme == "light" ? AppColors.white : AppColors.pureBlack,
                              size: AppSize.w24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: AppSize.w20.w,
                    ),
                    Expanded(
                      child: Text(
                        getTranslated(context, "addOrder"),
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 3,
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          color: theme == "light" ? AppColors.white : AppColors.pureBlack,
                          fontSize: AppFontsSizeManager.s20.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: Padding(
                padding:  EdgeInsets.all(AppPadding.p10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: AppSize.h25.h,
                    ),
                    TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      validator: (String? val) {
                        if (val!.trim().isEmpty) {
                          return getTranslated(context, 'required');
                        }
                        return null;
                      },
                      onSaved: (val) {
                        userPhone = val!;
                      },
                      enableInteractiveSelection: true,
                      style: GoogleFonts.poppins(
                        color: AppColors.pureBlack,
                        fontSize: AppFontsSizeManager.s14_5.sp,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: AppPadding.p15),
                        helperStyle: GoogleFonts.poppins(
                          color: AppColors.pureBlack.withOpacity(0.65),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        errorStyle: GoogleFonts.poppins(
                          fontSize:AppFontsSizeManager.s13.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        hintStyle: GoogleFonts.poppins(
                          fontSize:AppFontsSizeManager.s14_5.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        //prefixIcon: Icon(Icons.title),
                        labelText: getTranslated(context, "userPhone"),
                        labelStyle: GoogleFonts.poppins(
                          fontSize:AppFontsSizeManager.s14_5.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.r12.r),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: AppSize.h15.h,
                    ),
                    TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      validator: (String? val) {
                        if (val!.trim().isEmpty) {
                          return getTranslated(context, 'required');
                        }
                        return null;
                      },
                      onSaved: (val) {
                        consultPhone = val!;
                      },
                      enableInteractiveSelection: true,
                      style: GoogleFonts.poppins(
                        color: AppColors.pureBlack,
                        fontSize: AppFontsSizeManager.s14_5.sp,
                        fontWeight: AppFontsWeightManager.bold500,
                        letterSpacing: 0.5,
                      ),
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: AppPadding.p15),
                        helperStyle: GoogleFonts.poppins(
                          color: AppColors.pureBlack.withOpacity(0.65),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        errorStyle: GoogleFonts.poppins(
                          fontSize: AppFontsSizeManager.s13.sp,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: 0.5,
                        ),
                        hintStyle: GoogleFonts.poppins(
                          // color: AppColors.black1,
                          fontSize: AppFontsSizeManager.s14_5.sp,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: 0.5,
                        ),
                        //prefixIcon: Icon(Icons.title),
                        labelText: getTranslated(context, "consultPhone"),
                        labelStyle: GoogleFonts.poppins(
                          fontSize: AppFontsSizeManager.s14_5.sp,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: 0.5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.r12.r),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: AppSize.h15.h,
                    ),
                    Container(
                        height:AppSize.h50.h,
                        decoration: BoxDecoration(
                            color: theme == "light" ? AppColors.white : Colors.transparent,
                            border: Border.all(
                              color: AppColors.grey,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(AppRadius.r10_6.r))),
                        child: Padding(
                          padding:  EdgeInsets.only(left: AppPadding.p10, right: AppPadding.p10),
                          child: DropdownButton<String>(
                            hint: Text(
                              getTranslated(context, "orderType"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                //color: AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s15.sp,
                                letterSpacing: 0.5,
                              ),
                            ),
                            underline: Container(),
                            isExpanded: true,
                            value: dropdownOrderTypeValue,
                            icon: Icon(Icons.keyboard_arrow_down, color: AppColors.pureBlack),
                            iconSize: AppSize.w24,
                            elevation: 16,
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              color: AppColors.blue,
                              fontSize: AppFontsSizeManager.s13.sp,
                              letterSpacing: 0.5,
                            ),
                            items: _orderTypeArray
                                .map((data) => DropdownMenuItem<String>(
                                    child: Text(
                                      data.value!,
                                      style: TextStyle(
                                        fontFamily: getTranslated(context, "Ithra"),
                                        color: AppColors.pureBlack,
                                        fontSize: AppFontsSizeManager.s15.sp,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    value: data.key.toString() //data.key,
                                    ))
                                .toList(),
                            onChanged: (String? value) {
                              setState(() {
                                dropdownOrderTypeValue = value!;
                              });
                            },
                          ),
                        )),
                    SizedBox(
                      height: AppSize.h15.h,
                    ),
                    TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      validator: (String? val) {
                        if (val!.trim().isEmpty) {
                          return getTranslated(context, 'required');
                        }
                        return null;
                      },
                      onSaved: (val) {
                        callNum = val!;
                      },
                      enableInteractiveSelection: true,
                      style: GoogleFonts.poppins(
                        color: AppColors.pureBlack,
                        fontSize: AppFontsSizeManager.s14_5.sp,
                        fontWeight: AppFontsWeightManager.bold500,
                        letterSpacing: 0.5,
                      ),
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: AppPadding.p15),
                        helperStyle: GoogleFonts.poppins(
                          color: AppColors.pureBlack.withOpacity(0.65),
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: 0.5,
                        ),
                        errorStyle: GoogleFonts.poppins(
                          fontSize: AppFontsSizeManager.s13.sp,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: 0.5,
                        ),
                        hintStyle: GoogleFonts.poppins(
                          // color: AppColors.black1,
                          fontSize: AppFontsSizeManager.s14_5.sp,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: 0.5,
                        ),
                        //prefixIcon: Icon(Icons.title),
                        labelText: getTranslated(context, "packageCall"),
                        labelStyle: GoogleFonts.poppins(
                          fontSize: AppFontsSizeManager.s14_5.sp,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: 0.5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: AppSize.h15.h,
                    ),
                    TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      validator: (String? val) {
                        if (val!.trim().isEmpty) {
                          return getTranslated(context, 'required');
                        }
                        return null;
                      },
                      onSaved: (val) {
                        price = val!;
                      },
                      enableInteractiveSelection: true,
                      style: GoogleFonts.poppins(
                        color: AppColors.pureBlack,
                        fontSize: AppFontsSizeManager.s14_5.sp,
                        fontWeight: AppFontsWeightManager.bold500,
                        letterSpacing: 0.5,
                      ),
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
                        helperStyle: GoogleFonts.poppins(
                          color: AppColors.pureBlack.withOpacity(0.65),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        errorStyle: GoogleFonts.poppins(
                          fontSize: AppFontsSizeManager.s13.sp,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: 0.5,
                        ),
                        hintStyle: GoogleFonts.poppins(
                          // color: AppColors.black1,
                          fontSize: AppFontsSizeManager.s14_5.sp,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: 0.5,
                        ),
                        //prefixIcon: Icon(Icons.title),
                        labelText: getTranslated(context, "price"),
                        labelStyle: GoogleFonts.poppins(
                          fontSize: AppFontsSizeManager.s14_5.sp,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: 0.5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: AppSize.h25.h,
                    ),
                    Container(
                      height: 45.0,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: saving
                          ? Center(child: CircularProgressIndicator())
                          : MaterialButton(
                              onPressed: () {
                                save();
                              },
                              color: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.r15.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.send,
                                    color: theme == "light" ? AppColors.white : AppColors.pureBlack,
                                    size: 20.0,
                                  ),
                                  SizedBox(
                                    width: AppSize.w10.w,
                                  ),
                                  Text(
                                    getTranslated(context, "save"),
                                    style: GoogleFonts.poppins(
                                      color: theme == "light" ? AppColors.white : AppColors.pureBlack,
                                      fontSize: AppFontsSizeManager.s14_5.sp,
                                      fontWeight: AppFontsWeightManager.bold500,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    SizedBox(
                      height: AppSize.h25.h,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  save() async {
    GroceryUser user, consult;
    List<GroceryUser> users = [], consults = [];
    if (_formKey.currentState!.validate() && dropdownOrderTypeValue != null) {
      _formKey.currentState!.save();
      try {
        setState(() {
          saving = true;
        });
        //get userdata
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(Paths.usersPath)
            .where(
              'phoneNumber',
              isEqualTo: userPhone,
            )
            .get();
        for (var doc in querySnapshot.docs) {
          users.add(GroceryUser.fromMap(doc.data() as Map));
        }
        if (users.length > 0)
          user = users[0];
        else {}
        //get consultdata
        QuerySnapshot querySnapshot2 =
            await FirebaseFirestore.instance.collection(Paths.usersPath).where('phoneNumber', isEqualTo: consultPhone).get();
        for (var doc in querySnapshot2.docs) {
          consults.add(GroceryUser.fromMap(doc.data() as Map));
        }
        if (consults.length > 0) {
          consult = consults[0];
        }
        DateTime date = DateTime.now();
        if (users.length > 0 && consults.length > 0) {
          String orderId = Uuid().v4();
          dynamic callPrice = double.parse(price.toString()) / int.parse(callNum!);
          //add order
          await FirebaseFirestore.instance.collection(Paths.ordersPath).doc(orderId).set({
            'orderStatus': 'open',
            'orderId': orderId,
            'consultType': dropdownOrderTypeValue,
            'utcTime': date.toUtc().toString(),
            'orderTimestamp': Timestamp.now(),
            'orderTimeValue': DateTime(date.year, date.month, date.day).millisecondsSinceEpoch,
            'packageId': "",
            'promoCodeId': "",
            'remainingCallNum': int.parse(callNum!),
            'packageCallNum': int.parse(callNum!),
            'answeredCallNum': 0,
            'callPrice': callPrice,
            "payWith": "support",
            "platform": Platform.isIOS ? "iOS" : "Android",
            'price': price.toString(),
            'consult': {
              'uid': consults[0].uid,
              'name': consults[0].name,
              'image': consults[0].photoUrl,
              'phone': consults[0].phoneNumber,
            },
            'user': {
              'uid': users[0].uid,
              'name': users[0].name,
              'image': users[0].photoUrl,
              'phone': users[0].phoneNumber,
            },
            'date': {
              'day': date.toUtc().day,
              'month': date.toUtc().month,
              'year': date.toUtc().year,
            },
          });
          //add event

          String eventName = "af_purchase";
          Map eventValues = {
            "af_revenue": price.toString(),
            "af_price": price.toString(),
            "af_content_id": consults[0].uid,
            "af_order_id": orderId,
            "af_currency": "USD",
          };
          AppFlyerService().logEvent(eventName, eventValues);
          await FirebaseAnalytics.instance
              .logPurchase(currency: "USD", value: double.parse(price.toString()), affiliation: consults[0].uid, transactionId: orderId);
          await FirebaseAnalytics.instance
              .logEvent(name: "payInfo", parameters: {"success": true, "reason": "success", "userUid": users[0].uid});
          // updateFocal(double.parse(price));
          //add appointment
          int currentNumber = int.parse(callNum!);
          String appointmentId = Uuid().v4();
          await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(appointmentId).set({
            'appointmentId': appointmentId,
            'appointmentStatus': 'open',
            'consultType': dropdownOrderTypeValue,
            'remainingCallNum': (currentNumber - 1) > 0 ? (currentNumber - 1) : 0,
            'type': 'support',
            'lessonTime': 10,
            'allowCall': false,
            'callCost': 0.0,
            'timestamp': DateTime.now().toUtc(),
            'timeValue': DateTime(date.year, date.month, date.day).millisecondsSinceEpoch,
            'secondValue':
                DateTime(date.year, date.month, date.day, date.hour, date.minute, date.second, date.millisecond).millisecondsSinceEpoch,
            'appointmentTimestamp': DateTime(date.year, date.month, date.day, date.hour, date.minute, date.second, date.millisecond),
            'utcTime': date.toUtc().toString(),
            'consultChat': 0,
            'userChat': 0,
            'isUtc': true,
            'orderId': orderId,
            'callPrice': callPrice,
            'consult': {
              'uid': consults[0].uid,
              'name': consults[0].name,
              'image': consults[0].photoUrl,
              'phone': consults[0].phoneNumber,
            },
            'user': {
              'uid': users[0].uid,
              'name': users[0].name,
              'image': users[0].photoUrl,
              'phone': users[0].phoneNumber,
            },
            'date': {
              'day': date.toUtc().day,
              'month': date.toUtc().month,
              'year': date.toUtc().year,
            },
            'time': {
              'hour': date.hour,
              'minute': date.minute,
            },
          }).then((value) async {
            await FirebaseFirestore.instance.collection(Paths.ordersPath).doc(orderId).set({
              'orderStatus': (currentNumber - 1) > 0 ? "open" : "completed",
              'remainingCallNum': (currentNumber - 1) > 0 ? (currentNumber - 1) : 0,
            }, SetOptions(merge: true));
          });
          //update user order numbers
          int userOrdersNumbers = 1;
          dynamic payedBalance = double.parse(price.toString());
          if (users[0].ordersNumbers != null) userOrdersNumbers = users[0].ordersNumbers! + 1;
          if (users[0].payedBalance != null) payedBalance = users[0].payedBalance + payedBalance;

          await FirebaseFirestore.instance.collection(Paths.usersPath).doc(users[0].uid).set({
            'ordersNumbers': userOrdersNumbers,
            'payedBalance': payedBalance,
          }, SetOptions(merge: true));
          //-----------
          appointmentDialog(MediaQuery.of(context).size, date.toString(), true);
        } else {
          appointmentDialog(MediaQuery.of(context).size, getTranslated(context, 'invalidNumbers'), false);
        }
        setState(() {
          saving = false;
        });
      } catch (e) {}
    }
  }

  // Future<void> updateFocal(double value) async {
  //   try {
  //     await FirebaseFirestore.instance.collection(Paths.appAnalysisPath).doc("TgWCp3B22sbkl0Nm3wLx").set({
  //       'orderNum': FieldValue.increment(1),
  //       'totalEarn': FieldValue.increment(value),
  //     }, SetOptions(merge: true));
  //     Map notifMap = Map();
  //     notifMap.putIfAbsent('price', () => value.toString());
  //     var response = await http.post(
  //       Uri.parse('https://us-central1-focalpoint-277d2.cloudfunctions.net/updateData'),
  //       body: notifMap,
  //     );
  //   } catch (e) {}
  // }

  appointmentDialog(Size size, String data, bool status) {
    return showDialog(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(left: AppPadding.p16, right: AppPadding.p16, top:AppPadding.p20, bottom: AppPadding.p10),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              getTranslated(context, "orders"),
              style: TextStyle(
                fontFamily: getTranslated(context, "Ithra"),
                fontSize: AppFontsSizeManager.s14_5.sp,
                fontWeight: AppFontsWeightManager.semiBold,
                letterSpacing: 0.3,
                color: AppColors.black1,
              ),
            ),
            SizedBox(
              height: AppSize.h15.h,
            ),
            Text(
              status ? getTranslated(context, "orderAdded") : getTranslated(context, "error"),
              style: TextStyle(
                fontFamily: getTranslated(context, "Ithra"),
                fontSize: AppFontsSizeManager.s14.sp,
                fontWeight: AppFontsWeightManager.bold500,
                letterSpacing: 0.3,
                color: status ? AppColors.black1 : Colors.red,
              ),
            ),
            Text(
              data,
              style: TextStyle(
                fontFamily: getTranslated(context, "Ithra"),
                fontSize: AppFontsSizeManager.s15.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
                color: AppColors.black1,
              ),
            ),
            SizedBox(
              height: AppSize.h5.h,
            ),
            Center(
              child: Container(
                width: size.width * AppSize.w0_5.w,
                child: MaterialButton(
                  color: AppColors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r25.r),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    getTranslated(context, 'Ok'),
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.black1,
                      fontSize: AppFontsSizeManager.s13_5.sp,
                      fontWeight: AppFontsWeightManager.bold500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }
}
