import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/methods/convert_pt_to_px.dart';
import 'package:grocery_store/methods/show_failed_snackbar.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/TextButton.dart';
import 'package:grocery_store/widget/custom_stepper.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../config/app_fonts.dart';
import '../config/colorsFile.dart';
import '../config/paths.dart';
import '../enums/payment_types.dart';
import '../localization/localization_methods.dart';
import '../methods/get_available_times_for_one_day.dart';
import '../models/consultDays.dart';
import '../models/consultPackage.dart';
import '../models/promoCode.dart';
import 'consaultant_details_widgets/days_button.dart';
import 'consaultant_details_widgets/days_button_shimmer.dart';
import 'consaultant_details_widgets/error_message.dart';
import 'consaultant_details_widgets/load_times_shimmer.dart';
import 'consaultant_details_widgets/order_details_line.dart';
import 'consaultant_details_widgets/payment_radio_button.dart';
import 'dialogs/costum_text_dialog.dart';

class BookingSection extends StatefulWidget {
  final GroceryUser loggedUser;
  final GroceryUser consultant;

  //final Orders order;
  final int localFrom;
  final int localTo;
  final int currentNumber;
  consultPackage package;
  final String consultType;
  late int selectedIndex = -1;
  bool isSupport;

  Function({
    required DateTime date,
    // required int currentNumber,
    required int selectedCard,
    // required String consultType,
    required String time,
    required List<dynamic> todayAppointmentList,
    required PaymentTypes paymentType,
    required double totalPrice,
  }) getData;

  Function({
    required bool backFromBooking,
  }) backFromBooking;

  BookingSection(
      {required this.loggedUser,
      required this.consultant,
      //required this.order,
      required this.localFrom,
      required this.localTo,
      required this.currentNumber,
      required this.package,
      required this.getData,
      required this.selectedIndex,
      required this.isSupport,
      required this.backFromBooking,
      required this.consultType});

  @override
  _BookingSectionState createState() => _BookingSectionState();
}

class _BookingSectionState extends State<BookingSection> {
  var pageViewController = PageController();
  final TextEditingController discountController = TextEditingController();

  int selectedCard = -1;
  bool hijri = false,
      gregorian = true,
      loadDates = false,
      dateSelected = true,
      checkPromo = false,
      valid = false,
      showPromo = false,
      dateUnSelect = false;
  PromoCode? promo;
  String? promoCodeId;
  String? selectedTime;
  dynamic price, discount = 0;
  PaymentTypes? paymentType;

  bool showBookingSection = false;
  bool showPaymentSection = false;

  /// Days buttons variables.
  bool loadDaysButton = true;
  List<String> todayTimesList = [];
  List<String> tomorrowTimesList = [];
  List<String> theDayAfterTomorrowTimesList = [];

  String time = DateFormat('yyyy-MM-dd').format(DateTime.now()), dateText = "";
  String?
      displayedTime; //= 'Select day';//DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  late DateTime date;
  DateTime selectedDate = DateTime.now();
  List<String> todayAppointmentList = [];
  int currentPage = 0;
  int? selectedDayIndex;
  bool showDayError = false;
  @override
  void initState() {
    super.initState();
    getAllTimesForThreeDays();
    // getDate();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomStepper(
          progress: currentPage,
          width: size.width,
        ),
        SizedBox(
          height: convertPtToPx(AppSize.h24).h,
        ),
        pages()[currentPage],
        SizedBox(
          height: currentPage == pages().length - 1
              ? convertPtToPx(AppSize.h32).h
              : convertPtToPx(AppSize.h65).h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                if (currentPage > 0) {
                  setState(() {
                    currentPage--;
                  });
                } else {
                  widget.backFromBooking(backFromBooking: true);
                }
              },
              child: Container(
                height: convertPtToPx(AppSize.h44).h,
                width: convertPtToPx(AppSize.h44).h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                  border:
                      Border.all(color: AppColors.pink, width: AppRadius.r1.r),
                ),
                child: Icon(
                  Icons.arrow_back_sharp,
                  size: AppSize.w40.r,
                  color: AppColors.pink,
                ),
              ),
            ),
            textButton(
              onPress: () async {
                if (currentPage == 0) {
                  if (displayedTime == null) {
                    /// show select day text.
                    setState(() {
                      showDayError = true;
                    });
                  } else if (todayAppointmentList.isEmpty || selectedCard < 0) {
                    customTextDialog(
                        context: context,
                        okFunction: () {
                          Navigator.pop(context);
                        },
                        buttonText: getTranslated(context, 'Ok'),

                        /// change this text
                        text: getTranslated(context, 'timeNotSelected'),
                        textSize: AppFontsSizeManager.s24);
                  } else {
                    setState(() {
                      currentPage++;
                    });
                  }
                } else {
                  if (currentPage < (pages().length - 1)) {
                    setState(() {
                      currentPage++;
                    });
                  } else {
                    if (paymentType == null && !widget.isSupport) {
                      customTextDialog(
                          context: context,
                          text: getTranslated(context, 'chosePaymentMethod'),
                          buttonText: getTranslated(context, 'Ok'),
                          okFunction: () {
                            Navigator.pop(context);
                          });
                    } else {
                      widget.getData(
                        date:
                            DateTime.parse(todayAppointmentList[selectedCard]),
                        selectedCard: selectedCard,
                        time: time,
                        todayAppointmentList: todayAppointmentList,
                        paymentType: paymentType!,
                        totalPrice: widget.package.price -
                            ((discount * widget.package.price) / 100),
                      );
                    }
                  }
                }
              },
              text: currentPage == pages().length - 1
                  ? getTranslated(context, 'next')
                  : getTranslated(context, "next"),
              width: convertPtToPx(AppSize.w183).w,
              height: convertPtToPx(AppSize.h44).h,
              // ButtonColor: AppColors.linear3,
              buttonRadius: AppRadius.r10_6.r,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              textSize: AppFontsSizeManager.s21_3.sp,
              textfont: getTranslated(context, 'Ithra'),
              textcolor: AppColors.white,
              icon: '',
              Gradient_Color: AppColors.Gradient_Color2,
              Gradient_Color2: AppColors.Gradient_Color1,
            ),
          ],
        ),
        SizedBox(
          height: convertPtToPx(AppSize.h30_8).h,
        ),
      ],
    );
  }

  List<Widget> pages() => [
        CalenderView(),
        orderDetailsWidget(),
      ];

  Widget CalenderView() => ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          Container(
            //height: convertPtToPx(AppSize.h150).h,
            padding: EdgeInsets.only(
                left: convertPtToPx(AppPadding.p12_5).w,
                right: convertPtToPx(AppPadding.p12_5).w,
                top: convertPtToPx(AppPadding.p24).h,
                bottom: convertPtToPx(AppPadding.p38).h),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(convertPtToPx(AppRadius.r12).r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pinkShadowColor2,
                    blurRadius: convertPtToPx(AppRadius.r7).r,
                    spreadRadius: 0,
                    offset: Offset(0.0,
                        convertPtToPx(1)), // shadow direction: bottom right
                  )
                ]),
            child: Column(
              children: [
                Text(
                  getTranslated(context, "selectSuitableDay"),
                  style: TextStyle(
                    fontFamily: getTranslated(context, 'Ithra'),
                    fontSize: convertPtToPx(AppFontsSizeManager.s16).sp,
                    fontWeight: AppFontsWeightManager.bold,
                    letterSpacing: convertPtToPx(-0.41),
                    color: AppColors.grey_dark,
                  ),
                ),
                SizedBox(
                  height: convertPtToPx(AppSize.h24).h,
                ),

                /// Days buttons, when select any day, get times available in this day.
                ///
                ConditionalBuilder(
                  condition: loadDaysButton == true,
                  builder: (context) => DaysButtonsShimmer(),
                  fallback: (context) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DaysButton(
                        isSelected: selectedDayIndex == 0 ? true : false,
                        text: getTranslated(context, 'today'),
                        available: todayTimesList.isEmpty ? false : true,
                        function: () {
                          setState(() {
                            selectedDayIndex = 0;

                            /// Current day.
                            selectedDate = DateTime.now();
                            time =
                                DateFormat('yyyy-MM-dd').format(selectedDate);
                            displayedTime = time;
                            loadDates = true;
                            showDayError = false;
                            todayAppointmentList = [];
                            dateText = getTranslated(context, "load");
                            getDate();
                            // DateTime da2= DateTime.now().add(Duration(days: 2));
                          });
                        },
                      ),
                      SizedBox(
                        width: convertPtToPx(AppSize.w12).w,
                      ),
                      DaysButton(
                        isSelected: selectedDayIndex == 1 ? true : false,
                        available: tomorrowTimesList.isEmpty ? false : true,
                        text: getTranslated(context, 'tomorrow'),
                        function: () {
                          setState(() {
                            selectedDayIndex = 1;

                            /// Next day.
                            selectedDate =
                                DateTime.now().add(Duration(days: 1));
                            showDayError = false;
                            time =
                                DateFormat('yyyy-MM-dd').format(selectedDate);
                            displayedTime = time;
                            loadDates = true;
                            todayAppointmentList = [];
                            dateText = getTranslated(context, "load");
                            getDate();
                          });
                        },
                      ),
                      SizedBox(
                        width: convertPtToPx(AppSize.w12).w,
                      ),
                      DaysButton(
                        isSelected: selectedDayIndex == 2 ? true : false,
                        available:
                            theDayAfterTomorrowTimesList.isEmpty ? false : true,
                        text: getTranslated(context, 'theDayAfterTomorrow'),
                        function: () {
                          setState(() {
                            selectedDayIndex = 2;

                            /// Next day.
                            selectedDate =
                                DateTime.now().add(Duration(days: 2));
                            time =
                                DateFormat('yyyy-MM-dd').format(selectedDate);
                            showDayError = false;
                            displayedTime = time;
                            loadDates = true;
                            todayAppointmentList = [];
                            dateText = getTranslated(context, "load");
                            getDate();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// error message when the user does not select the day.
          ///
          if (showDayError && loadDates == false)
            ErrorMessage(
              errorMessage: getTranslated(context, 'selectSuitableDay'),
              buttomPadding: 0.0,
            ),

          //
          // SizedBox(
          //   height: convertPtToPx(AppSize.h42).h,
          // ),

          AvailableHours(),
          SizedBox(
            height: convertPtToPx(AppSize.h24).h,
          ),
          Text(
            getTranslated(context, "selectTimeNote"),
            style: TextStyle(
                fontFamily: getTranslated(context, 'Ithra'),
                color: AppColors.darkGrey,
                fontSize: convertPtToPx(AppFontsSizeManager.s12).sp,
                fontStyle: FontStyle.normal,
                fontWeight: AppFontsWeightManager.bold),
          ),
        ],
      );

  Widget AvailableHours() => (loadDates == false)
      ? Padding(
          padding: EdgeInsets.only(
            top: convertPtToPx(AppSize.h32).h,
          ),
          child: Container(
            //height: convertPtToPx(AppSize.h182).h,
            padding: EdgeInsets.symmetric(
                horizontal: convertPtToPx(AppPadding.p24).w,
                vertical: convertPtToPx(AppPadding.p24).h),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(convertPtToPx(AppRadius.r16).r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pinkShadowColor2,
                    blurRadius: convertPtToPx(AppRadius.r7).r,
                    spreadRadius: 0,
                    offset: Offset(0.0,
                        convertPtToPx(1)), // shadow direction: bottom right
                  )
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getTranslated(context, "selectSuitableTime"),
                  style: TextStyle(
                      fontFamily: getTranslated(context, 'Ithra'),
                      color: AppColors.grey_dark,
                      fontWeight: AppFontsWeightManager.bold,
                      fontSize: convertPtToPx(AppFontsSizeManager.s16).sp,
                      fontStyle: FontStyle.normal,
                      letterSpacing: convertPtToPx(-0.41)),
                ),
                SizedBox(
                  height: convertPtToPx(AppSize.h24).h,
                ),
                Container(
                  height: convertPtToPx(AppSize.h35).h,
                  padding: EdgeInsets.symmetric(
                    horizontal: convertPtToPx(AppSize.w16).w,
                  ),
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(convertPtToPx(AppRadius.r8).r),
                      color: todayAppointmentList.isEmpty
                          ? AppColors.formFieldColor
                          : AppColors.tabColor),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedTime,
                      borderRadius: BorderRadius.circular(AppRadius.r16.r),
                      isExpanded: true,
                      menuMaxHeight: AppSize.h250.h,
                      hint: Text(
                        getTranslated(context, 'selectTime'),
                        style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithra'),
                            color: AppColors.grey,
                            fontSize: convertPtToPx(AppFontsSizeManager.s14).sp,
                            fontWeight: AppFontsWeightManager.bold),
                      ),
                      icon: Image.asset(
                        AssetsManager.arrowLeft,
                        height: AppSize.h21_3.h,
                        width: AppSize.w21_3.w,
                        color: todayAppointmentList.isEmpty
                            ? AppColors.grey
                            : AppColors.pink,
                      ),
                      elevation: 16,
                      style: TextStyle(
                          fontFamily: getTranslated(context, 'Ithra'),
                          color: AppColors.pink,
                          fontSize: convertPtToPx(AppFontsSizeManager.s16).sp,
                          fontWeight: AppFontsWeightManager.bold),
                      onChanged: (value) {
                        setState(() {
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
              ],
            ),
          ),
        )
      : LoadTimesShimmer(
          height: AppSize.h181_3,
        );

  Widget orderDetailsWidget() {
    return Container(
      padding: EdgeInsets.all(convertPtToPx(AppPadding.p16).w),
      decoration: BoxDecoration(
          color: AppColors.lightGrey8,
          borderRadius: BorderRadius.circular(convertPtToPx(AppRadius.r12).r)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.package.discount == null || widget.package.discount == 0)
            Column(
              children: [
                Container(
                  height: convertPtToPx(AppSize.h52).h,
                  padding: EdgeInsets.all(
                    convertPtToPx(AppPadding.p8).w,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius:
                        BorderRadius.circular(convertPtToPx(AppRadius.r4).r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        AssetsManager.coupon_iconPath,
                        width: convertPtToPx(AppSize.w24).w,
                        height: convertPtToPx(AppSize.h24).w,
                      ),
                      SizedBox(
                        width: convertPtToPx(AppSize.w16).w,
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: convertPtToPx(AppSize.h16).h),
                          child: TextFormField(
                            controller: discountController,
                            keyboardType: TextInputType.text,
                            // textAlign: TextAlign.center,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.done,
                            enableInteractiveSelection: true,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithralight'),
                              color: AppColors.darkGrey,
                              fontStyle: FontStyle.normal,
                              fontSize:
                                  convertPtToPx(AppFontsSizeManager.s14).sp,
                              letterSpacing: convertPtToPx(-0.24),
                            ),
                            decoration: InputDecoration(
                              // contentPadding: EdgeInsets.only(
                              //     top: 0.0,//AppPadding.p1.h,
                              //     // bottom: AppPadding.p13.h,
                              //     // left: AppPadding.p35.w
                              // ),
                              border: InputBorder.none,
                              hintText:
                                  getTranslated(context, "enterPromoCode"),
                              hintStyle: TextStyle(
                                fontFamily:
                                    getTranslated(context, 'Ithralight'),
                                color: AppColors.darkGrey,
                                fontStyle: FontStyle.normal,
                                fontSize:
                                    convertPtToPx(AppFontsSizeManager.s14).sp,
                                letterSpacing: convertPtToPx(-0.24),
                              ),
                              counterStyle: TextStyle(
                                fontFamily:
                                    getTranslated(context, 'Ithralight'),
                                fontSize: AppFontsSizeManager.s12_5.sp,
                                color: AppColors.black1,
                                letterSpacing: 0.5,
                              ),
                            ),
                            onChanged: (text) {
                              if (text.length < 5) {
                                setState(() {
                                  promo = null;
                                  promoCodeId = "";
                                  checkPromo = false;
                                  valid = false;
                                  discount = 0;
                                });
                              }
                              if (text.length == 0) {
                                setState(() {
                                  promo = null;
                                  promoCodeId = "";
                                  checkPromo = false;
                                  valid = false;
                                  discount = 0;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      // Spacer(),
                      InkWell(
                        onTap: () {
                          if(discountController.text.trim().isEmpty || discountController.text.trim()==''){
                            showFailedSnackBar(getTranslated(context, 'enterCode'));
                          }else{
                            calculateDiscount();
                          }
                        },
                        child: Container(
                          width: convertPtToPx(AppSize.w159).w,
                          height: convertPtToPx(AppSize.h36).h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: discount > 0
                                ? AppColors.lightGreen
                                : AppColors.pink,
                            borderRadius: BorderRadius.circular(
                                convertPtToPx(AppRadius.r4).r),
                          ),
                          child: Text(
                            discount > 0
                                ? getTranslated(context, 'activated3')
                                : getTranslated(context, "activated2"),
                            // getTranslated(context, "Verify"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra_Bold'),
                              color: discount > 0
                                  ? AppColors.darkGreen
                                  : AppColors.white,
                              fontSize:
                                  convertPtToPx(AppFontsSizeManager.s14).sp,
                              fontWeight: AppFontsWeightManager.bold,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: convertPtToPx(AppSize.h12).h,
                ),

                /// the result of the discount code.
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      '${getTranslated(context, "promoCodeText2")} ${discount==0 ? '' : (discount.toString() + "%")}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithra'),
                        color: AppColors.darkGrey,
                        fontSize: convertPtToPx(AppFontsSizeManager.s12).sp,
                        fontWeight: AppFontsWeightManager.regular,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
              ],
            ),

          SizedBox(
            height: convertPtToPx(AppSize.h24).h,
          ),

          Container(
            // height: convertPtToPx(219).h,
            padding: EdgeInsets.only(
                bottom: convertPtToPx(AppPadding.p16).h,
                top: convertPtToPx(AppPadding.p16).h,
                left: convertPtToPx(AppPadding.p16).w,
                right: convertPtToPx(AppPadding.p16).w),
            decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius:
                    BorderRadius.circular(convertPtToPx(AppRadius.r13).r),
                border: Border.all(
                    color: AppColors.lightGray,
                    width: convertPtToPx(AppSize.h1.h))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTranslated(context, "orderDetails"),
                  style: TextStyle(
                    height: AppSize.h1_3.h,
                    color: AppColors.linear2,
                    fontSize: AppFontsSizeManager.s18_6.sp,
                    fontWeight: AppFontsWeightManager.bold,
                    fontFamily: getTranslated(context, "Ithra"),
                  ),
                ),
                SizedBox(
                  height: convertPtToPx(AppSize.h7).h,
                ),
                Container(
                    color: AppColors.dividerGrey,
                    height: convertPtToPx(AppSize.h1).h,
                    width: convertPtToPx(AppSize.w318).w),
                SizedBox(
                  height: convertPtToPx(AppSize.h8).h,
                ),

                /// Call numbers.
                ///
                OrderDetailsLine(
                  header: getTranslated(context, "packageLesson"),
                  value: '${widget.package.callNum}',
                ),

                /// The appointment.
                ///
                OrderDetailsLine(
                  header: getTranslated(context, "theAppointment"),
                  value:
                      '$displayedTime   ${selectedTime == null ? '' : convertTime(selectedTime!, context)}',
                ),

                /// Package price.
                ///
                OrderDetailsLine(
                  header: getTranslated(context, "packagePrice"),
                  value:
                      '${((widget.package.price * 100) / (100 - widget.package.discount)).toStringAsFixed(2)}\$', //'${widget.package.price} \$',
                ),

                /// discount.
                ///
                OrderDetailsLine(
                  header: getTranslated(context, "discount2"),
                  value: widget.package.discount == null ||
                          widget.package.discount == 0.00
                      ? '${((discount * widget.package.price) / 100).toStringAsFixed(2)}\$'
                      : '${(widget.package.discount).toStringAsFixed(2)}\$ -',
                ),

                /// package price after discount.
                ///
                OrderDetailsLine(
                  header: getTranslated(context, "packagePriceAfter"),
                  withPadding: false,
                  value:
                      '${(widget.package.price - ((discount * widget.package.price) / 100)).toStringAsFixed(2)}\$',
                ),

                SizedBox(
                  height: convertPtToPx(AppSize.h7).h,
                ),
                Container(
                    color: AppColors.lightGray,
                    height: convertPtToPx(AppSize.h1).h,
                    width: convertPtToPx(AppSize.w318).w),
                SizedBox(
                  height: convertPtToPx(AppSize.h8).h,
                ),

                OrderDetailsLine(
                  withPadding: false,
                  header: getTranslated(context, "totalAmount"),
                  value:
                      '${(widget.package.price - ((discount * widget.package.price) / 100)).toStringAsFixed(2)}\$',
                  headerColor: AppColors.linear2,
                  valueColor: AppColors.linear2,
                ),
              ],
            ),
          ),
          // if (!widget.isSupport)
          Column(
            children: [
              SizedBox(
                height: convertPtToPx(AppSize.h24).h,
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  getTranslated(context, 'paymentWay'),
                  style: TextStyle(
                    color: AppColors.linear2,
                    fontSize: AppFontsSizeManager.s21_3.sp,
                    fontFamily: getTranslated(context, "Ithra"),
                    fontWeight: AppFontsWeightManager.bold,
                  ),
                ),
              ),
              SizedBox(
                height: convertPtToPx(AppSize.h24).h,
              ),
              if (checkBalance())
              PaymentRadioButton(
                icons: [],
                text: getTranslated(context, 'payFromBalance'),
                isSelected: paymentType == PaymentTypes.balance ? true : false,
                endIcon: AssetsManager.walletIcon,
                endIconWidth: AppSize.w42_6.w,
                function: () {
                  setState(() {
                    paymentType = PaymentTypes.balance;
                  });
                },
              ),
              SizedBox(
                height: convertPtToPx(AppSize.h16).h,
              ),
              PaymentRadioButton(
                icons: [
                  Platform.isAndroid
                      ? AssetsManager.googlePayLogo
                      : AssetsManager.applePayLogo,
                  AssetsManager.kareemPaymentLogo,
                  AssetsManager.mastercard,
                  AssetsManager.visaCard,
                  AssetsManager.amPay,
                ],
                endPadding: convertPtToPx(AppSize.w8),
                isSelected:
                    paymentType == PaymentTypes.tapCompany ? true : false,
                endIcon: AssetsManager.oTap,
                function: () {
                  setState(() {
                    paymentType = PaymentTypes.tapCompany;
                  });
                },
              ),
              SizedBox(
                height: convertPtToPx(AppSize.h16).h,
              ),
              PaymentRadioButton(
                icons: [
                  AssetsManager.mastercard,
                  AssetsManager.visaCard,
                ],
                endPadding: convertPtToPx(AppSize.w10),
                isSelected: paymentType == PaymentTypes.stripe ? true : false,
                endIcon: AssetsManager.stripeLogo,
                endIconWidth: AppSize.w96.w,
                function: () {
                  setState(() {
                    paymentType = PaymentTypes.stripe;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool checkBalance() {
    if (double.parse(widget.loggedUser.balance.toString()) >=
        widget.package.price - ((discount * widget.package.price) / 100)) {
      return true;
    }
    return false;
  }

  calculateDiscount() async {
    setState(() {
      checkPromo = true;
    });
    if (discountController != null && discountController.text != "") {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.promoPath)
          .where('promoCodeStatus', isEqualTo: true)
          .where('code', isEqualTo: discountController.text)
          .limit(1)
          .get();
      var codes = List<PromoCode>.from(
        querySnapshot.docs.map(
          (snapshot) => PromoCode.fromMap(snapshot.data() as Map),
        ),
      );
      if (codes.length > 0) {

        bool isPrimary = (codes[0].type == "primary" &&
            codes[0].promoCodeStatus &&
            widget.package.discount != null &&
            widget.package.discount == 0 &&
            widget.loggedUser.promoList != null &&
            widget.loggedUser.promoList!.contains(codes[0].promoCodeId) ==
                false);
        bool isDefault = (codes[0].type == "default" &&
            codes[0].promoCodeStatus &&
            widget.package.discount != null &&
            widget.package.discount == 0);
        bool isPromition = (codes[0].type == "promotion" &&
            codes[0].promoCodeStatus &&
            codes[0].usedNumber == 0 &&
            widget.package.discount != null &&
            widget.package.discount == 0);

        /// check if the promo code for a specific consultant.
        ///
        bool isConsultant = (codes[0].type == "consultant" &&
            codes[0].promoCodeStatus &&
            widget.package.discount != null &&
            widget.package.discount == 0);


        if(isConsultant && widget.consultant.uid== codes[0].consultantId){

          setState(() {
            promo = codes[0];
            promoCodeId = promo!.promoCodeId;
            checkPromo = false;
            valid = true;
            discount = promo!.discount;
          });

        }else if (isDefault || isPrimary || isPromition) {
          setState(() {
            promo = codes[0];
            promoCodeId = promo!.promoCodeId;
            checkPromo = false;
            valid = true;
            discount = promo!.discount;
          });

        } else {
          setState(() {
            promo = null;
            promoCodeId = "";
            checkPromo = false;
            valid = false;
            discount = 0;
          });
          showFailedSnackBar(getTranslated(context, 'invalidCode'));
        }
      } else {
        setState(() {
          promo = null;
          promoCodeId = "";
          checkPromo = false;
          valid = false;
          discount = 0;
        });
        showFailedSnackBar(getTranslated(context, 'invalidCode'));
      }
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

  getDate() async {
    setState(() {
      todayAppointmentList = [];
      selectedCard = -1;
      selectedTime = null;
      loadDates = true;
    });

    try {
      if (DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
              .isBefore(DateTime(DateTime.now().year, DateTime.now().month,
                  DateTime.now().day)) ||
          (!widget.consultant.workDays!
              .contains(selectedDate.weekday.toString()))) {
        setState(() {
          loadDates = false;
          todayAppointmentList = [];
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
}

String convertTime(String value, BuildContext context) {
  String minues = "00";
  String? finalTime;

  if (DateTime.parse(value).toLocal().minute != 0)
    minues = DateTime.parse(value).toLocal().minute.toString();
  if (DateTime.parse(value).toLocal().hour > 12)
    finalTime = ((DateTime.parse(value).toLocal().hour) - 12).toString() +
        ":" +
        minues +
        ' ' +
        getTranslated(context, 'pm');
  else if (DateTime.parse(value).toLocal().hour == 12)
    finalTime = ((DateTime.parse(value).toLocal().hour)).toString() +
        ":" +
        minues +
        ' ' +
        getTranslated(context, 'pm');
  else
    finalTime = DateTime.parse(value).toLocal().hour.toString() +
        ":" +
        minues +
        ' ' +
        getTranslated(context, 'am');

  return finalTime;
}
