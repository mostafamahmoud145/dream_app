import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/methods/convert_pt_to_px.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/consultantDetailsScreen.dart';
import 'package:grocery_store/widget/dreamDialogsWidget.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../config/app_fonts.dart';
import '../../config/colorsFile.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../methods/get_available_times_for_one_day.dart';
import '../../models/consultDays.dart';
import '../../models/order.dart';
import '../TextButton.dart';
import '../booking_order_section.dart';
import 'days_button.dart';
import 'days_button_shimmer.dart';
import 'error_message.dart';
import 'load_times_shimmer.dart';

class AddAppointmentForPreviousOrderDialog extends StatefulWidget {
  final GroceryUser loggedUser;
  final GroceryUser consultant;
  final Orders order;
  final int localFrom;
  final int localTo;
  final int currentNumber;
  final String consultType;

  AddAppointmentForPreviousOrderDialog(
      {required this.loggedUser,
      required this.consultant,
      required this.order,
      required this.localFrom,
      required this.localTo,
      required this.currentNumber,
      required this.consultType});

  @override
  _AddAppointmentForPreviousOrderDialogState createState() =>
      _AddAppointmentForPreviousOrderDialogState();
}

class _AddAppointmentForPreviousOrderDialogState
    extends State<AddAppointmentForPreviousOrderDialog> {
  int selectedCard = -1;
  bool hijri = false,
      gregorian = true,
      loadDates = false,
      dateSelected = true,
      dateUnSelect = false;
  String time = DateFormat('yyyy-MM-dd').format(DateTime.now()), dateText = "";
  String?
      displayedTime; // = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  late DateTime selectedDate = DateTime.now(), date;
  List<String> todayAppointmentList = [];
  int? selectedDayIndex;
  String? selectedTime;
  bool isListVisible = false;
  bool showDayError = false, showTimeError = false;

  /// Days buttons variables.
  bool loadDaysButton = true;
  List<String> todayTimesList = [];
  List<String> tomorrowTimesList = [];
  List<String> theDayAfterTomorrowTimesList = [];

  @override
  void initState() {
    super.initState();
    getAllTimesForThreeDays();
    // getDate();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return DreamDialogsWidget(
      padBottom: 0,
      padLeft: 0,
      padRight: 0,
      padTop: 0,
      raduis: AppRadius.r21_3.r,
      dialogContent: Container(
        //height: AppSize.h557_3.h,
        width: AppSize.w473_3.w,
        // constraints: BoxConstraints.loose(size),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: AppPadding.p32.w, vertical: AppPadding.p32.h),
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: InkWell(
                  splashColor: AppColors.white.withOpacity(0.6),
                  onTap: () {
                    Navigator.pop(context);
                    //Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.close,
                    color: AppColors.pureBlack,
                    size: convertPtToPx(AppSize.w24).w,
                  ),
                ),
              ),
              SizedBox(
                child: Text(
                  getTranslated(context, "selectAppointment"),
                  style: TextStyle(
                    // backgroundColor: Colors.red,
                    height: AppSize.h2.h,
                    fontFamily: getTranslated(context, 'Ithra'),
                    fontSize: AppFontsSizeManager.s21_3.sp,
                    fontWeight: AppFontsWeightManager.bold,
                    letterSpacing: convertPtToPx(-0.24),
                    color: AppColors.pink,
                  ),
                ),
              ),
              SizedBox(
                height: convertPtToPx(AppSize.h32).h,
              ),

              /// Days buttons, when select any day, get times available in this day.
              ///
              Column(
                children: [
                  SizedBox(
                    child: Text(
                      getTranslated(context, "selectSuitableDay"),
                      style: TextStyle(
                          //backgroundColor: Colors.red,
                          height: AppSize.h1.h,
                          fontFamily: getTranslated(context, 'Ithra'),
                          fontSize: convertPtToPx(AppFontsSizeManager.s14).sp,
                          fontWeight: AppFontsWeightManager.bold,
                          letterSpacing: convertPtToPx(-0.41),
                          color: AppColors.grey_dark),
                    ),
                  ),
                  SizedBox(
                    height: convertPtToPx(AppSize.h24).h,
                  ),
                  ConditionalBuilder(
                    condition: loadDaysButton == true,
                    builder: (context) => DaysButtonsShimmer(),
                    fallback: (context) => Row(
                      children: [
                        Expanded(
                          child: DaysButton(
                            isSelected: selectedDayIndex == 0 ? true : false,
                            text: getTranslated(context, 'today'),
                            available: todayTimesList.isEmpty ? false : true,
                            height: convertPtToPx(AppSize.h36).h,
                            width: double.infinity,
                            raduis: AppRadius.r5_3.r,
                            fontSizeText:
                                convertPtToPx(AppFontsSizeManager.s14).sp,
                            function: () {
                              setState(() {
                                showDayError = false;
                                selectedDayIndex = 0;

                                /// Current day.
                                selectedDate = DateTime.now();
                                time = DateFormat('yyyy-MM-dd')
                                    .format(selectedDate);
                                displayedTime = time;
                                loadDates = true;
                                todayAppointmentList = [];
                                dateText = getTranslated(context, "load");
                                getDate();
                                // DateTime da2= DateTime.now().add(Duration(days: 2));
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: AppSize.w16.h,
                        ),
                        Expanded(
                          child: DaysButton(
                            isSelected: selectedDayIndex == 1 ? true : false,
                            text: getTranslated(context, 'tomorrow'),
                            available: tomorrowTimesList.isEmpty ? false : true,
                            height: convertPtToPx(AppSize.h36).h,
                            width: double.infinity,
                            raduis: AppRadius.r5_3.r,
                            fontSizeText:
                                convertPtToPx(AppFontsSizeManager.s14).sp,
                            function: () {
                              setState(() {
                                showDayError = false;
                                selectedDayIndex = 1;

                                /// Next day.
                                selectedDate =
                                    DateTime.now().add(Duration(days: 1));
                                time = DateFormat('yyyy-MM-dd')
                                    .format(selectedDate);
                                displayedTime = time;
                                loadDates = true;
                                todayAppointmentList = [];
                                dateText = getTranslated(context, "load");
                                getDate();
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: AppSize.w16.h,
                        ),
                        Expanded(
                          child: DaysButton(
                            fontFamiltType: getTranslated(context, "Ithra"),
                            isSelected: selectedDayIndex == 2 ? true : false,
                            height: convertPtToPx(AppSize.h36).h,
                            available: theDayAfterTomorrowTimesList.isEmpty
                                ? false
                                : true,
                            width: double.infinity,
                            raduis: AppRadius.r5_3.r,
                            fontSizeText:
                                convertPtToPx(AppFontsSizeManager.s14).sp,
                            text: getTranslated(context, 'theDayAfterTomorrow'),
                            function: () {
                              setState(() {
                                showDayError = false;
                                selectedDayIndex = 2;

                                /// Next day.
                                selectedDate =
                                    DateTime.now().add(Duration(days: 2));
                                time = DateFormat('yyyy-MM-dd')
                                    .format(selectedDate);
                                displayedTime = time;
                                loadDates = true;
                                todayAppointmentList = [];
                                dateText = getTranslated(context, "load");
                                getDate();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (showDayError && loadDates == false)
                ErrorMessage(
                    errorMessage:
                        getTranslated(context, 'selectSuitableDayFirst'),
                    buttomPadding: 0.0),

              AvailableHours(),

              SizedBox(
                height: convertPtToPx(AppSize.h16).h,
              ),

              textButton(
                padding: 0,
                onPress: () async {
                  if (displayedTime == null) {
                    /// show select day text.
                    setState(() {
                      showDayError = true;
                    });
                  } else if (todayAppointmentList.isEmpty || selectedCard < 0) {
                    setState(() {
                      showTimeError = true;
                    });
                  } else {
                    addAppointment(
                      date: DateTime.parse(todayAppointmentList[selectedCard]),
                      loggedUser: widget.loggedUser,
                      consultant: widget.consultant,
                      orderId: widget.order.orderId,
                      currentNumber: widget.currentNumber,
                      selectedCard: selectedCard,
                      consultType: widget.consultType,
                      callPrice: widget.order.callPrice,
                      time: time,
                      context: context,
                      todayAppointmentList: todayAppointmentList,
                    );
                  }
                },
                text: getTranslated(context, "confirmReservation"),
                width: double.infinity,
                height: convertPtToPx(AppSize.h42).h,
                buttonRadius: convertPtToPx(AppRadius.r8).r,
                textSize: convertPtToPx(AppFontsSizeManager.s14).sp,
                fontWeight: AppFontsWeightManager.bold,
                textfont: getTranslated(context, 'Ithra'),
                textcolor: AppColors.white1,
                icon: '',
                Gradient_Color: AppColors.Gradient_Color1,
                Gradient_Color2: AppColors.Gradient_Color2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget AvailableHours() => (loadDates == false)
      ? Container(
          //height: convertPtToPx(AppSize.h153).h,
          // padding: EdgeInsets.symmetric(
          //     horizontal: convertPtToPx(AppPadding.p22).w,
          //     vertical: convertPtToPx(AppPadding.p20).h),
          decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius:
            //     BorderRadius.circular(convertPtToPx(AppRadius.r12).r),
            // boxShadow: [
            //   BoxShadow(
            //     color: AppColors.pinkShadowColor2,
            //     blurRadius: convertPtToPx(AppRadius.r7).r,
            //     spreadRadius: 0,
            //     offset: Offset(
            //         0.0, convertPtToPx(1)), // shadow direction: bottom right
            //   )
            //]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: convertPtToPx(AppSize.h32).h,
              ),
              Text(
                getTranslated(context, "selectSuitableTime"),
                style: TextStyle(
                    height: AppSize.h1.h,
                    fontFamily: getTranslated(context, 'Ithra'),
                    color: AppColors.black,
                    fontSize: convertPtToPx(AppFontsSizeManager.s14).sp,
                    fontStyle: FontStyle.normal,
                    fontWeight: AppFontsWeightManager.bold,
                    letterSpacing: convertPtToPx(-0.41)),
              ),
              SizedBox(
                height: convertPtToPx(AppSize.h24).h,
              ),
              Container(
                height: convertPtToPx(AppSize.h35).h,
                padding: EdgeInsets.symmetric(
                  horizontal: convertPtToPx(AppPadding.p16).w,
                ),
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(convertPtToPx(AppRadius.r4).r),
                    color: todayAppointmentList.isEmpty
                        ? AppColors.formFieldColor
                        : AppColors.tabColor),
                child:
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text(
                    //       getTranslated(context, 'pressHere'),
                    //       style: TextStyle(
                    //           fontFamily: getTranslated(context, 'Ithra'),
                    //           color: AppColors.linear2,
                    //           fontSize: convertPtToPx(AppFontsSizeManager.s14).sp,
                    //           fontWeight: AppFontsWeightManager.bold,
                    //           letterSpacing: convertPtToPx(-0.41)),
                    //     ),
                    //     Icon(
                    //       Icons.keyboard_arrow_left_outlined,
                    //       color: AppColors.linear2,
                    //     ),
                    //   ],
                    // ),

                    DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedTime,
                    borderRadius: BorderRadius.circular(AppRadius.r16.r),
                    isExpanded: true,
                    menuMaxHeight: AppSize.h221.h,
                    hint: Text(
                      getTranslated(context, 'selectTime'),
                      style: TextStyle(
                          fontFamily: getTranslated(context, 'Ithra'),
                          color: AppColors.grey,
                          fontSize: convertPtToPx(AppFontsSizeManager.s14).sp,
                          fontWeight: AppFontsWeightManager.bold,
                          letterSpacing: convertPtToPx(-0.41)),
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_left_outlined,
                      // color: AppColors.linear2,
                      color: todayAppointmentList.isEmpty
                          ? AppColors.grey
                          : AppColors.pink,
                    ),
                    iconSize: AppSize.h24,
                    elevation: 16,
                    style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithra'),
                        color: AppColors.pink,
                        fontSize: convertPtToPx(AppFontsSizeManager.s14).sp,
                        fontWeight: AppFontsWeightManager.bold,
                        letterSpacing: convertPtToPx(-0.41)),
                    onChanged: (value) {
                      setState(() {
                        showTimeError = false;
                        selectedTime = value;
                        selectedCard = todayAppointmentList.indexOf(value!);
                      });
                    },
                    items: todayAppointmentList.map((String value) {
                      if(value == selectedTime){
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            convertTime(value, context),
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              color: AppColors.pink,
                              fontSize: convertPtToPx(AppFontsSizeManager.s14).sp,
                            ),
                          ),
                        );
                      }
                      else{
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            convertTime(value, context),
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithralight'),
                              color: AppColors.black,
                              fontSize: convertPtToPx(AppFontsSizeManager.s14).sp,
                            ),
                          ),
                        );
                      }
                    }).toList(),
                  ),
                ),
              ),
              if (showTimeError)
                ErrorMessage(
                    errorMessage: getTranslated(context, 'errorSuitableTime')),
              SizedBox(
                height: convertPtToPx(AppSize.h32).h,
              ),
              Text(
                getTranslated(context, "selectTimeNote"),
                style: TextStyle(
                  fontFamily: getTranslated(context, 'Ithra'),
                  color: AppColors.darkGrey,
                  fontSize: convertPtToPx(AppFontsSizeManager.s12).sp,
                  fontWeight: AppFontsWeightManager.bold,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ],
          ),
        )
      //     : selectedDayIndex!=null ?SizedBox(
      //   width: double.infinity,
      //       child: Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   children: [
      //       SizedBox(
      //         height: AppSize.h10,
      //       ),
      //       loadDates ? CircularProgressIndicator() : SizedBox(),
      //       Text(
      //         // selectedDayIndex==null ? getTranslated(context, 'selectSuitableDay') :
      //         dateText,
      //         style: TextStyle(
      //           fontFamily: getTranslated(context, "Ithra"),
      //           fontSize: AppFontsSizeManager.s14_5,
      //           fontWeight: FontWeight.w600,
      //           letterSpacing: 0.3,
      //           color: AppColors.grey,
      //         ),
      //       ),
      //   ],
      // ),
      //     )
      : LoadTimesShimmer();

  // TimeDialog() => DreamDialogsWidget(
  //       padBottom: 0,
  //       padLeft: 0,
  //       padRight: 0,
  //       padTop: 0,
  //       raduis: AppRadius.r21_3.r,
  //       dialogContent: Container(
  //         width: double.maxFinite,
  //         padding: EdgeInsets.all(AppPadding.p32.r),
  //         child: Column(
  //           children: [
  //             Align(
  //               alignment: AlignmentDirectional.topEnd,
  //               child: InkWell(
  //                 splashColor: AppColors.white.withOpacity(0.6),
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   //Navigator.pop(context);
  //                 },
  //                 child: Icon(
  //                   Icons.close,
  //                   color: AppColors.pureBlack,
  //                   size: convertPtToPx(AppSize.w24).w,
  //                 ),
  //               ),
  //             ),
  //             Text(
  //               getTranslated(context, "selectAppointment"),
  //               style: TextStyle(
  //                 fontFamily: getTranslated(context, 'Ithra'),
  //                 fontSize: convertPtToPx(AppFontsSizeManager.s16).sp,
  //                 fontWeight: AppFontsWeightManager.bold,
  //                 letterSpacing: convertPtToPx(-0.24),
  //                 color: AppColors.pink,
  //               ),
  //             ),
  //             SizedBox(
  //               height: convertPtToPx(AppSize.h24).h,
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  // Time() => Column(
  //       children: [
  //         ListTile(
  //           title: Text('Tap to open/close the list'),
  //           onTap: () {
  //             // Call the toggle function when the ListTile is tapped
  //             setState(() {
  //               isListVisible = !isListVisible;
  //               print("888888888888888888888888888");
  //               print(isListVisible);
  //             });
  //           },
  //         ),
  //         Visibility(
  //           visible: isListVisible,
  //           child: Container(
  //             height: 200,
  //             child: ListView.builder(
  //               shrinkWrap: true,

  //               itemCount:
  //                   todayAppointmentList.length, // Number of items in the list
  //               itemBuilder: (BuildContext context, int index) {
  //                 // Get the current item's value
  //                 String value = todayAppointmentList[index];

  //                 return ListTile(
  //                   onTap: () {
  //                     // Handle the item tap, similar to onChanged in DropdownButton
  //                     setState(() {
  //                       showTimeError = false;
  //                       selectedTime = value;
  //                       selectedCard =
  //                           index; // Since index corresponds to the list item
  //                     });
  //                   },
  //                   title: Text(
  //                     convertTime(value,
  //                         context), // Convert time as you did for dropdown
  //                     style: TextStyle(
  //                       fontFamily: getTranslated(context, 'Ithra'),
  //                       color: AppColors.pink,
  //                       fontSize: convertPtToPx(AppFontsSizeManager.s14).sp,
  //                       fontWeight: AppFontsWeightManager.bold,
  //                       letterSpacing: convertPtToPx(-0.41),
  //                     ),
  //                   ),
  //                   trailing: Icon(
  //                     Icons.keyboard_arrow_left_outlined, // Adjust as needed
  //                     color: AppColors.linear2,
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //         ),
  //       ],
  //     );

  getDate() async {
    try {
      if (DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
              .isBefore(DateTime(DateTime.now().year, DateTime.now().month,
                  DateTime.now().day)) ||
          (!widget.consultant.workDays!
              .contains(selectedDate.weekday.toString()))) {
        setState(() {
          loadDates = false;
          todayAppointmentList = [];
          showDayError = true;
          dateText = getTranslated(context, "selectData");
        });
      } else {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection(Paths.consultDaysPath)
            .doc(time + "-" + widget.consultant.uid!)
            .get();
        if (documentSnapshot.exists) {
          ConsultDays consultDays =
              ConsultDays.fromMap(documentSnapshot.data() as Map);
          List<String> appointmentList = [];

          for (int start = 0;
              start < consultDays.todayAppointmentList!.length;
              start++) {
            if (DateTime.parse(consultDays.todayAppointmentList![start])
                .toLocal()
                .isAfter(DateTime.now())) {
              appointmentList.add(consultDays.todayAppointmentList![start]);
            }
          }
          setState(() {
            loadDates = false;
            todayAppointmentList = appointmentList;
            if (todayAppointmentList.length == 0) {
              showDayError = true;
              dateText = getTranslated(context, "noAppointment");
            } else {
              selectedTime = todayAppointmentList.first;
              selectedCard = 0;
            }
          });
        } else {
          var from = DateTime(selectedDate.year, selectedDate.month,
              selectedDate.day, widget.localFrom);
          var to = DateTime(selectedDate.year, selectedDate.month,
              selectedDate.day, widget.localTo);
          var ttt = (to.difference(from).inHours).round();
          if (ttt <= 0) {
            to = DateTime(
                selectedDate.year, selectedDate.month, selectedDate.day, 24);
            ttt = (to.difference(from).inHours).round();
          }
          List<String> appointmentList = [];
          //var lessonTime=10;
          var lessonMintes = 10;
          for (int start = 0; start < ttt * 6; start++) {
            if (from
                .add(Duration(minutes: start * lessonMintes))
                .isAfter(DateTime.now())) {
              var value = from
                  .add(Duration(minutes: start * lessonMintes))
                  .toUtc()
                  .toString();
              appointmentList.add(value);
            }
          }
          await FirebaseFirestore.instance
              .collection(Paths.consultDaysPath)
              .doc(time + "-" + widget.consultant.uid!)
              .set({
            'id': time + "-" + widget.consultant.uid!,
            'day': time,
            'date': DateTime(
                    selectedDate.year, selectedDate.month, selectedDate.day)
                .millisecondsSinceEpoch,
            'consultUid': widget.consultant.uid,
            'todayAppointmentList': appointmentList,
          });
          setState(() {
            loadDates = false;
            todayAppointmentList = appointmentList;
            selectedTime = todayAppointmentList.first;
            selectedCard = 0;
          });
        }
      }
    } catch (e) {
      String id = Uuid().v4();
      await FirebaseFirestore.instance
          .collection(Paths.errorLogPath)
          .doc(id)
          .set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'phone':
            widget.loggedUser == null ? " " : widget.loggedUser.phoneNumber,
        'screen': "ConsultantDetailsScreen",
        'function': "getDate",
      });
    }
  }

  Future<void> getAllTimesForThreeDays() async {
    todayTimesList = await getAvailableTimesForOneDay(
        selectedDate: DateTime.now(),
        context: context,
        consultant: widget.consultant,
        localFrom: widget.localFrom,
        localTo: widget.localTo,
        loggedUserPhone: widget.loggedUser.phoneNumber!);

    tomorrowTimesList = await getAvailableTimesForOneDay(
        selectedDate: DateTime.now().add(Duration(days: 1)),
        context: context,
        consultant: widget.consultant,
        localFrom: widget.localFrom,
        localTo: widget.localTo,
        loggedUserPhone: widget.loggedUser.phoneNumber!);

    theDayAfterTomorrowTimesList = await getAvailableTimesForOneDay(
        selectedDate: DateTime.now().add(Duration(days: 2)),
        context: context,
        consultant: widget.consultant,
        localFrom: widget.localFrom,
        localTo: widget.localTo,
        loggedUserPhone: widget.loggedUser.phoneNumber!);

    setState(() {
      loadDaysButton = false;
    });
  }
}
