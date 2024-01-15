import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/enums/payment_types.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/methods/convert_pt_to_px.dart';
import 'package:grocery_store/models/consultPackage.dart';
import 'package:grocery_store/models/consultReview.dart';
import 'package:grocery_store/models/order.dart';
import 'package:grocery_store/models/promoCode.dart';
import 'package:grocery_store/screens/reviews_screen.dart';
import 'package:grocery_store/widget/TextButton.dart';
import 'package:grocery_store/widget/booking_order_section.dart';
import 'package:grocery_store/widget/stripe_payment_bottom_sheet.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/user.dart';
import '../models/user_notification.dart';
import '../services/app_flyer_service.dart';
import '../widget/back_button.dart';
import '../widget/consaultant_details_widgets/add_appointment_for_previous_order_dialog.dart';
import '../widget/dialogs/costum_text_dialog.dart';
import '../widget/dreamDialogsWidget.dart';
import 'bioDetailsScreen.dart';

class ConsultantDetailsScreen extends StatefulWidget {
  final GroceryUser consultant;
  final GroceryUser? loggedUser;
  final String consultType;

  const ConsultantDetailsScreen(
      {Key? key,
      required this.consultant,
      this.loggedUser,
      required this.consultType})
      : super(key: key);

  @override
  _ConsultantDetailsScreenState createState() =>
      _ConsultantDetailsScreenState();
}

class _ConsultantDetailsScreenState extends State<ConsultantDetailsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var pageViewController = PageController();
  String languages = "",
      workDays = "",
      workDaysValue = "",
      from = "",
      to = "",
      lang = "";
  List<String> daysList = [];
  String? days;

  final TextEditingController controller = TextEditingController();
  final TextEditingController searchController = new TextEditingController();
  GroceryUser? user;
  int currentNumber = 0;
  late AccountBloc accountBloc;
  List<consultPackage> packages = [];
  List<ConsultReview> reviews = [];
  late int _selectedIndex = -1, reviewLength = 0, localFrom, localTo;
  bool first = true,
      showPayView = false,
      load = false,
      valid = false,
      checkPromo = false,
      loadReviews = true,
      loadPackage = true,
      fromBalance = false;
  bool showPromo = false, sharing = false;
  int _stackIndex = 1;
  String initialUrl = '',
      userImage = "",
      orderId = "",
      userName = "dreamUser",
      orderNum = "0";
  consultPackage? package;
  Orders? order;
  bool avaliable = false;
  dynamic destinationAmount = 0.0;
  PromoCode? promo;
  String? promoCodeId;
  dynamic price, discount = 0;
  late Size size;
  late NotificationBloc notificationBloc;
  late UserNotification userNotification;
  bool payIsSelected1 = false;
  bool payIsSelected2 = false;
  bool payIsSelected3 = false;
  double progress = 0.2;
  Set<int> reachedSteps = <int>{0, 2, 4, 5};
  bool showBookingSection = false;
  bool showPaymentSection = false;
  int _selectedDateCard = -1;
  String? _time;
  List<dynamic> _todayAppointmentList = [];
  DateTime? _selectedDate;
  TextEditingController userController = TextEditingController();
  List<GroceryUser> users = [];
  TextEditingValue? initialAutoCompleteValue;
  GroceryUser? selectedUserBySupport;
  DateTime? date;

  @override
  void initState() {
    super.initState();
    if (widget.loggedUser != null) user = widget.loggedUser!;

    if (widget.consultant.ordersNumbers! < 100)
      orderNum = widget.consultant.ordersNumbers.toString();
    else
      for (int x = 2; x < 1000000; x++) {
        if (widget.consultant.ordersNumbers! < x * 100) {
          orderNum = ((x - 1) * 100).toString();
          break;
        }
      }
    getConsultReviews();
    getConsultPackages();
    cleanConsultDays();
    accountBloc = BlocProvider.of<AccountBloc>(context);
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    if (user != null) {
      // getNumber();
      accountBloc.add(GetLoggedUserEvent());
    }
    localFrom = DateTime.parse(widget.consultant.fromUtc!).toLocal().hour;
    localTo = DateTime.parse(widget.consultant.toUtc!).toLocal().hour;
    if (localTo == 0) localTo = 24;
    if (widget.consultant.languages!.length > 0)
      widget.consultant.languages!.forEach((element) {
        languages = languages + " " + element;
      });
    if (widget.consultant.workTimes!.length > 0) {
      if (localFrom == 12)
        from = "12 PM";
      else if (localFrom == 0)
        from = "12 AM";
      else if (localFrom > 12)
        from = ((localFrom) - 12).toString();
      else
        from = (localFrom).toString();
    }
    if (widget.consultant.workTimes!.length > 0) {
      if (localTo == 12)
        to = "12 PM";
      else if (localTo == 0 || localTo == 24)
        to = "12 AM";
      else if (localTo > 12)
        to = ((localTo) - 12).toString();
      else
        to = (localTo).toString();
    }
    accountBloc.stream.listen((state) {
      if (state is GetLoggedUserCompletedState) {
        user = state.user;
      }
    });
    //--------add details event
    String eventName = "af_content_view";
    Map eventValues = {
      "af_price": widget.consultant.price,
      "af_content_id": widget.consultant.uid,
    };
    DateTime date2;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      addEvent(eventName, eventValues);
    });
  }

  void backFromBooking({
    required bool backFromBooking,
  }) {
    if (backFromBooking == true) {
      setState(() {
        showBookingSection = false;
        _selectedIndex = -1;
      });
    }
  }

  void getDataFromBooking({
    required DateTime date,
    required int selectedCard,
    required String time,
    required List<dynamic> todayAppointmentList,
    required PaymentTypes paymentType,
    required double totalPrice,
  }) {
    price = totalPrice;
    this.currentNumber = currentNumber;
    this._selectedDateCard = selectedCard;
    this._time = time;
    this._todayAppointmentList = todayAppointmentList;
    this._selectedDate = date;

    switch (paymentType) {
      case PaymentTypes.balance:
        customTextDialog(
          text: getTranslated(context, 'payFromBalanceNote'),
          buttonText: getTranslated(context, 'Ok'),
          context: context,
          okFunction: () async {
            Navigator.pop(context);
            try {
              payFromBalance(price: totalPrice, userAccount: user!);
            } catch (e) {
              customTextDialog(
                context: context,
                buttonText: getTranslated(context, 'Ok'),
                text: getTranslated(context, 'failed'),
                okFunction: () {
                  Navigator.pop(context);
                },
              );
              print('error from pay');
            }
          },
        );
        break;

      case PaymentTypes.stripe:
        stripePayment(amount: totalPrice.toString(), context: context);
        break;

      case PaymentTypes.tapCompany:
        pay();
        break;
      case PaymentTypes.fromSupport:
        customTextDialog(
          text: getTranslated(context, 'payFromBalanceNote'),
          buttonText: getTranslated(context, 'Ok'),
          context: context,
          okFunction: () async {
            Navigator.pop(context);

            try {
              payFromBalance(
                  price: totalPrice, userAccount: selectedUserBySupport!);
            } catch (e) {
              customTextDialog(
                context: context,
                buttonText: getTranslated(context, 'Ok'),
                text: getTranslated(context, 'failed'),
                okFunction: () {
                  Navigator.pop(context);
                },
              );
              print('error from pay');
            }
          },
        );
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
      'phone': widget.loggedUser == null ? " " : widget.loggedUser!.phoneNumber,
      'screen': "ConsultantDetailsScreen",
      'function': function,
    });
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

  getConsultPackages() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.packagesPath)
          .where('consultUid', isEqualTo: widget.consultant.uid)
          .where('active', isEqualTo: true)
          .where('type', isEqualTo: widget.consultType)
          .orderBy("callNum", descending: false)
          .get();
      var packageList = List<consultPackage>.from(
        querySnapshot.docs.map(
          (snapshot) => consultPackage.fromMap(snapshot.data() as Map),
        ),
      );
      setState(() {
        packages = packageList;
        loadPackage = false;
      });
    } catch (e) {
      setState(() {
        loadPackage = false;
      });
      errorLog("getConsultPackages", e.toString());
    }
  }

  getConsultReviews() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.consultReviewsPath)
          .where('consultUid', isEqualTo: widget.consultant.uid)
          .limit(3)
          .orderBy("reviewTime", descending: true)
          .get();
      var reviewsList = List<ConsultReview>.from(
        querySnapshot.docs.map(
          (snapshot) => ConsultReview.fromMap(snapshot.data() as Map),
        ),
      );

      setState(() {
        reviewLength = reviewsList.length;
        reviews = reviewsList;
        loadReviews = false;
      });
    } catch (e) {
      setState(() {
        loadReviews = false;
      });
      errorLog("getConsultReviews", e.toString());
    }
  }

  _onSelected(int index) {
    setState(() {
      _selectedIndex = index;
      package = packages[index];
    });

    if (_selectedIndex == 0) {
      setState(() {
        showPromo = true;
      });
      calculateDiscount();
    } else
      setState(() {
        showPromo = false;
        promo = null;
        controller.text = "";
        promoCodeId = "";
        checkPromo = false;
        valid = false;
        discount = 0;
      });
  }

  addEvent(String eventName, Map eventValues) async {
    await AppFlyerService().logEvent(eventName, eventValues);
    if (eventName == "af_content_view") {
      await FirebaseAnalytics.instance.logSelectItem(
        itemListId: widget.consultant.uid,
        itemListName: getTranslated(context, "lang") == "ar"
            ? widget.consultant.consultName!.nameAr!
            : getTranslated(context, "lang") == "en"
                ? widget.consultant.consultName!.nameEn!
                : getTranslated(context, "lang") == "fr"
                    ? widget.consultant.consultName!.nameFr!
                    : widget.consultant.consultName!.nameId!,
      );
    } else if (eventName == "af_purchase") {
      await FirebaseAnalytics.instance.logPurchase(
          currency: "USD",
          value: double.parse(price.toString()),
          affiliation: widget.consultant.uid,
          transactionId: orderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    String dayNow = DateTime.now().weekday.toString();
    int timeNow = DateTime.now().hour;
    if (widget.consultant.workDays!.contains(dayNow)) {
      if (localFrom <= timeNow && localTo > timeNow) {
        avaliable = true;
      }
    }
    lang = getTranslated(context, "lang");
    if (user != null && user!.photoUrl != null && user!.photoUrl != "")
      setState(() {
        userImage = user!.photoUrl!;
      });
    if (first && widget.consultant.workDays!.length > 0) {
      workDays = "";
      if (widget.consultant.workDays!.contains("1")) {
        workDays = workDays + getTranslated(context, "monday") + ",";
      }
      if (widget.consultant.workDays!.contains("2")) {
        workDays = workDays + getTranslated(context, "tuesday") + ",";
      }
      if (widget.consultant.workDays!.contains("3")) {
        workDays = workDays + getTranslated(context, "wednesday") + ",";
      }
      if (widget.consultant.workDays!.contains("4")) {
        workDays = workDays + getTranslated(context, "thursday") + ",";
      }
      if (widget.consultant.workDays!.contains("5")) {
        workDays = workDays + getTranslated(context, "friday") + ",";
      }
      if (widget.consultant.workDays!.contains("6")) {
        workDays = workDays + getTranslated(context, "saturday") + ",";
      }
      if (widget.consultant.workDays!.contains("7")) {
        workDays = workDays + getTranslated(context, "sunday") + ",";
      }
      setState(() {
        workDaysValue = "";
        workDaysValue = workDays;
        daysList = workDaysValue.split(',');
        first = false;
        first = false;
      });
    }
    size = MediaQuery.of(context).size;
    return Scaffold(
      // floatingActionButton: FloatingActionButton(onPressed: () {
      //   showAddedAppointmentDialog(
      //     context: context, size: size,
      //     // date: date2
      //   );
      // }),
      backgroundColor: AppColors.white,
      key: _scaffoldKey,
      body: SafeArea(
        child: Stack(children: <Widget>[
          Column(
            children: <Widget>[
              headerWidget(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    // physics: AlwaysScrollableScrollPhysics(),

                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: AppSize.h21_3.h,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppPadding.p32.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /*Column(
                                  children: [
                                    Container(
                                        width: 38.w,
                                        height: 38.w,
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(216, 250, 190, 1),
                                          borderRadius:
                                              BorderRadius.circular(8.w),
                                          boxShadow: [shadow()],
                                        ),
                                        child: Center(
                                            child: Image.asset(
                                          'assets/applicationIcons/blackCall.png',
                                          width: 19.w,
                                          height: 19.w,
                                        ))),
                                    SizedBox(
                                      height: 6.5.h,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/applicationIcons/greenCall2.png',
                                          width: 13.w,
                                          height: 13.w,
                                        ),
                                        Text(
                                          //widget.consultant.ordersNumbers==null?'0':widget.consultant.ordersNumbers<100?widget.consultant.ordersNumbers.toString():widget.consultant.ordersNumbers<1000?"+100":"+1000",
                                          "+" + orderNum,
                                          style: TextStyle(
                                            color: Color.fromRGBO(63, 63, 63, 1),
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w700,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: getTranslated(
                                                context, "Ithra"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),*/

                                Expanded(
                                  child: SizedBox(
                                    width: AppSize.w206.w,
                                  ),
                                ),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      height: AppSize.h137_4.h,
                                      width: AppSize.w137_4.w,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.white1,
                                          width: AppSize.w1.w,
                                        ),
                                        shape: BoxShape.circle,
                                        color: HexColor("#9C3981"),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: AppColors.white,
                                                width: AppSize.w6_5.w),
                                            shape: BoxShape.circle,
                                            color: HexColor("#9C3981")
                                            //AppColors.white,
                                            ),
                                        child: widget
                                                .consultant.photoUrl!.isEmpty
                                            ? Image.asset(
                                                AssetsManager
                                                    .dreamLogoPurpleImagePath,
                                                width: AppSize.h137_4.r,
                                                height: AppSize.h137_4.r,
                                                fit: BoxFit.fill,
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppRadius.r137_4.r),
                                                child: FadeInImage.assetNetwork(
                                                  placeholder:
                                                      AssetsManager.purple_logo,
                                                  placeholderScale: 0.5,
                                                  imageErrorBuilder: (context,
                                                          error, stackTrace) =>
                                                      Image.asset(
                                                          AssetsManager
                                                              .dreamLogoPurpleImagePath,
                                                          width:
                                                              AppSize.w137_4.w,
                                                          height:
                                                              AppSize.h137_4.h,
                                                          fit: BoxFit.fill),
                                                  image: widget
                                                      .consultant.photoUrl!,
                                                  fit: BoxFit.cover,
                                                  fadeInDuration: Duration(
                                                      milliseconds: 250),
                                                  fadeInCurve: Curves.easeInOut,
                                                  fadeOutDuration: Duration(
                                                      milliseconds: 150),
                                                  fadeOutCurve:
                                                      Curves.easeInOut,
                                                ),
                                              ),
                                      ),
                                    ),
                                    Image.asset(
                                      AssetsManager.borderConsult,
                                      width: AppSize.w150.w,
                                      height: AppSize.h150.h,
                                    ),
                                    Positioned(
                                      bottom: AppPadding.p10.h,
                                      left: AppPadding.p20.w,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          // border: Border.all(color: AppColors.white,width: 2),
                                          shape: BoxShape.circle,
                                          color: avaliable
                                              ? AppColors.green4
                                              : AppColors.red,
                                        ),
                                        width: AppSize.w14_1.r,
                                        height: AppSize.h14_1.r,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: AppSize.w136_6.w,
                                ),
                                InkWell(
                                  onTap: () async {
                                    share(context);
                                  },
                                  child: Column(
                                    children: [
                                      sharing
                                          ? Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : Container(
                                              height: AppSize.h50_6.r,
                                              width: AppSize.w50_6.r,
                                              decoration: BoxDecoration(
                                                color: AppColors.lightPurple,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppRadius.r5_3.r),
                                              ),
                                              child: Center(
                                                  child: Image.asset(
                                                AssetsManager.share_iconPath,
                                                width: AppSize.w32.r,
                                                height: AppSize.h32.r,
                                              ))),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: AppSize.h21_3.h,
                          ),
                          Text(
                            getTranslated(context, "lang") == "ar"
                                ? widget.consultant.consultName!.nameAr!
                                : getTranslated(context, "lang") == "en"
                                    ? widget.consultant.consultName!.nameEn!
                                    : getTranslated(context, "lang") == "fr"
                                        ? widget.consultant.consultName!.nameFr!
                                        : widget
                                            .consultant.consultName!.nameId!,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              fontSize: AppFontsSizeManager.s21_3.sp,
                              color: AppColors.pureBlack,
                            ),
                          ),
                          /** */ //rating bar
                          // SizedBox(
                          //   height: AppSize.h5_5.h,
                          // ),
                          // SmoothStarRating(
                          //   allowHalfRating: true,
                          //   starCount: 5,
                          //   onRatingChanged: (v) {},
                          //   rating:
                          //       double.parse(widget.consultant.rating.toString()),
                          //   size: 21.5.w,
                          //   color: AppColors.yellow2,
                          //   borderColor: AppColors.yellow2,
                          //   spacing: 1.0,
                          // ), **/
                          SizedBox(
                            height: AppSize.h16.h,
                          ),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: AppSize.w32.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: AppSize.h65_3.h,
                                  width: AppSize.w111_3.w,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        AssetsManager.phone_call_iconPath,
                                        width: AppSize.w32.r,
                                        height: AppSize.h32.r,
                                      ),
                                      Expanded(
                                          child:
                                              SizedBox(height: AppSize.h6_6.h)),
                                      Text(
                                        //widget.consultant.ordersNumbers==null?'0':widget.consultant.ordersNumbers<100?widget.consultant.ordersNumbers.toString():widget.consultant.ordersNumbers<1000?"+100":"+1000",
                                        orderNum + "+",
                                        style: TextStyle(
                                          color: AppColors.pureBlack,
                                          fontSize:
                                              AppFontsSizeManager.s18_6.sp,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: getTranslated(
                                              context, 'Montserrat-SemiBold'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    child: SizedBox(
                                  width: AppSize.w21_3.w,
                                )),
                                Container(
                                  height: AppSize.h65_3.h,
                                  width: AppSize.w111_3.w,
                                  child: Column(
                                    children: [
                                      SvgPicture.asset(
                                        AssetsManager.pinkMoney,
                                        width: AppSize.w32.r,
                                        height: AppSize.h32.r,
                                      ),
                                      Expanded(
                                          child:
                                              SizedBox(height: AppSize.h6_6.h)),
                                      Text(
                                        widget.consultant.price.toString() +
                                            "\$",
                                        style: TextStyle(
                                          fontFamily: getTranslated(
                                              context, 'Montserrat-SemiBold'),
                                          fontStyle: FontStyle.normal,
                                          fontSize:
                                              AppFontsSizeManager.s18_6.sp,
                                          color: AppColors.pureBlack,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    child: SizedBox(
                                  width: AppSize.w21_3.w,
                                )),
                                Container(
                                  height: AppSize.h65_3.h,
                                  width: AppSize.w111_3.w,
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        AssetsManager.star1,
                                        width: AppSize.w32.r,
                                        height: AppSize.h32.r,
                                      ),
                                      Expanded(
                                          child:
                                              SizedBox(height: AppSize.h6_6.h)),
                                      Text(
                                        widget.consultant.rating
                                            .toStringAsFixed(1),
                                        style: TextStyle(
                                          fontFamily: getTranslated(
                                              context, 'Montserrat-SemiBold'),
                                          fontStyle: FontStyle.normal,
                                          fontSize:
                                              AppFontsSizeManager.s18_6.sp,
                                          color: AppColors.pureBlack,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                widget.consultant.country != null
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                          right: AppSize.w21_3.w,
                                        ),
                                        child: Container(
                                          height: AppSize.h65_3.h,
                                          width: AppSize.w111_3.w,
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                AssetsManager.location1,
                                                width: AppSize.w32.r,
                                                height: AppSize.h32.r,
                                              ),
                                              Expanded(
                                                  child: SizedBox(
                                                      height: AppSize.h6_6.h)),
                                              Text(
                                                widget.consultant.country
                                                    .toString(),
                                                // widget.consultant.country?.toString() ??
                                                // "السعودية",
                                                style: TextStyle(
                                                  fontFamily: getTranslated(
                                                      context, 'Ithralight'),
                                                  fontSize: AppFontsSizeManager
                                                      .s18_6.sp,
                                                  color: AppColors.pureBlack,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : SizedBox()
                              ],
                            ),
                          ),
                          /* widget.consultant.languages!.length > 1
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    langWidget(widget.consultant.languages![0]),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    langWidget(widget.consultant.languages![1])
                                  ],
                                )
                              : langWidget(widget.consultant.languages![0]),*/
                        ],
                      ),
                      SizedBox(
                        height: AppSize.h60.h,
                      ),

                      if (showBookingSection == false)
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                right: AppPadding.p32.w,
                                left: AppPadding.p32.w,
                              ),
                              child: Center(
                                child: Container(
                                  width: size.width,
                                  padding: EdgeInsets.only(
                                    right: AppPadding.p42.w,
                                    left: AppPadding.p42.w,
                                    bottom: AppPadding.p21_3.w,
                                    top: AppPadding.p21_3.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.r12.r),
                                    /*border:
                                      Border.all(
                                        color: Color.fromRGBO(158, 158, 158, 0.18),
                                          width: 1,
                                      ),*/
                                    boxShadow: [AppShadow.primaryShadow],
                                  ),
                                  child: Column(
                                    children: [
                                      Center(
                                        child: Text(
                                          getTranslated(context, "bio2"),
                                          style: TextStyle(
                                              fontFamily: getTranslated(
                                                  context, 'Ithra'),
                                              color: AppColors.linear3,
                                              fontSize:
                                                  AppFontsSizeManager.s21_3.sp,
                                              fontStyle: FontStyle.normal,
                                              fontWeight:
                                                  AppFontsWeightManager.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: AppSize.h21_3.h,
                                      ),
                                      Text(
                                        overflow: TextOverflow.ellipsis,

                                        getTranslated(context, "lang") == "ar"
                                            ? widget
                                                .consultant.consultBio!.bioAr!
                                            : getTranslated(context, "lang") ==
                                                    "en"
                                                ? widget.consultant.consultBio!
                                                    .bioEn!
                                                : getTranslated(
                                                            context, "lang") ==
                                                        "fr"
                                                    ? widget.consultant
                                                        .consultBio!.bioFr!
                                                    : widget.consultant
                                                        .consultBio!.bioId!,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        //widget.consultant.bio!.length>165?widget.consultant.bio!.substring(0,165):widget.consultant.bio!,
                                        style: TextStyle(
                                          fontFamily:
                                              getTranslated(context, 'Ithra'),
                                          color: AppColors.grey7,
                                          fontSize:
                                              AppFontsSizeManager.s18_6.sp,
                                          fontWeight:
                                              AppFontsWeightManager.bold,
                                          fontStyle: FontStyle.normal,
                                        ),
                                      ),
                                      SizedBox(
                                        height: AppSize.h21_3.h,
                                      ),
                                      Row(
                                        mainAxisAlignment: lang == "ar"
                                            ? MainAxisAlignment.center
                                            : MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          //pb in button
                                          /*  textButton(onPress: (){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => BioDetailsScreen(
                                                  consult: widget.consultant,
                                                  avaliable: avaliable),
                                            ),
                                          );

                                        }, text: getTranslated(context, "readMore"), width: 97.w, height: 32.0.h,ButtonColor:  AppColors.linear3, buttonRadius: 5.5, textSize: AppFontsSizeManager.s16.sp, textfont:  getTranslated(context, 'Ithra'), textcolor: AppColors.white, icon: '',),
                              */
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      BioDetailsScreen(
                                                          consult:
                                                              widget.consultant,
                                                          avaliable: avaliable),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              height: AppSize.h32.w,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      AppPadding.p10_6.w,
                                                  vertical: AppPadding.p5_3.h),
                                              decoration: BoxDecoration(
                                                color: AppColors.linear3,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppRadius.r5_3.r),
                                              ),
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      getTranslated(
                                                          context, "readMore2"),
                                                      style: TextStyle(
                                                        fontFamily:
                                                            getTranslated(
                                                                context,
                                                                'Ithra'),
                                                        color: AppColors.white1,
                                                        fontSize:
                                                            AppFontsSizeManager
                                                                .s16.sp,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width: AppSize.w5_3.w),
                                                    lang == "ar"
                                                        ? SvgPicture.asset(
                                                            AssetsManager
                                                                .pinkReadMoreIconPath,
                                                            width:
                                                                AppSize.w21_3.r,
                                                            height:
                                                                AppSize.h21_3.r,
                                                            color:
                                                                AppColors.white,
                                                          )
                                                        : new RotationTransition(
                                                            turns:
                                                                new AlwaysStoppedAnimation(
                                                                    180 / 360),
                                                            child: Image.asset(
                                                              AssetsManager
                                                                  .white_more,
                                                              width: AppSize
                                                                  .w21_3.r,
                                                              height: AppSize
                                                                  .h21_3.r,
                                                            ),
                                                          ),
                                                  ],
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
                            SizedBox(
                              height: AppSize.h42_6.h,
                            ),

                            Padding(
                              padding: EdgeInsets.only(
                                right: AppPadding.p32.w,
                                left: AppPadding.p32.w,
                              ),
                              child: Center(
                                child: Container(
                                  width: size.width,
                                  // height: 255.h,
                                  padding: EdgeInsets.only(
                                      right: AppPadding.p21_3.w,
                                      left: AppPadding.p21_3.w,
                                      top: AppPadding.p21_3.h,
                                      bottom: AppPadding.p21_3.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.r16.r),
                                    boxShadow: [AppShadow.primaryShadow],
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                getTranslated(
                                                    context, "Reviews"),
                                                style: TextStyle(
                                                  fontFamily: getTranslated(
                                                      context, 'Ithra'),
                                                  color: AppColors.linear3,
                                                  fontSize: AppFontsSizeManager
                                                      .s21_3.sp,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                              SizedBox(width: AppSize.w10_6.w),
                                              Image.asset(
                                                AssetsManager.star1,
                                                width: AppSize.w21_3.r,
                                                height: AppSize.h21_3.r,
                                              ),
                                            ],
                                          ),
                                        ),
                                        loadReviews
                                            ? Center(
                                                child:
                                                    CircularProgressIndicator())
                                            : SizedBox(),
                                        (loadReviews == false &&
                                                reviews.length == 0)
                                            ? Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    SizedBox(
                                                      height: AppSize.h32.h,
                                                    ),
                                                    Text(
                                                      getTranslated(
                                                          context, "noReviews"),
                                                      style: TextStyle(
                                                        fontFamily:
                                                            getTranslated(
                                                                context,
                                                                "Ithra"),
                                                        color: AppColors.grey7,
                                                        fontSize:
                                                            AppFontsSizeManager
                                                                .s18.sp,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : SizedBox(height: AppSize.h32.h),
                                        (loadReviews == false &&
                                                reviews.length > 0)
                                            ? ListView.separated(
                                                itemCount: reviews.length > 2
                                                    ? 2
                                                    : reviews.length,
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                padding: EdgeInsets.only(),
                                                itemBuilder: (context, index) {
                                                  return Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        height: AppSize.h56.r,
                                                        width: AppSize.w56.r,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            color: AppColors
                                                                .lightPink3,
                                                            width:
                                                                AppSize.w1_5.w,
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                          color:
                                                              AppColors.white,
                                                        ),
                                                        child:
                                                            reviews[index]
                                                                    .image!
                                                                    .isEmpty
                                                                ? Center(
                                                                    child: Icon(
                                                                      Icons
                                                                          .person,
                                                                      color: AppColors
                                                                          .lightGrey5,
                                                                      size: AppSize
                                                                          .w48
                                                                          .r,
                                                                    ),
                                                                  )
                                                                : ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(AppRadius
                                                                            .r100
                                                                            .r),
                                                                    child: FadeInImage
                                                                        .assetNetwork(
                                                                      placeholder:
                                                                          AssetsManager
                                                                              .icon_personPath,
                                                                      placeholderScale:
                                                                          0.5,
                                                                      imageErrorBuilder: (context,
                                                                              error,
                                                                              stackTrace) =>
                                                                          Center(
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .person,
                                                                          color:
                                                                              AppColors.pink,
                                                                          size: AppSize
                                                                              .w48
                                                                              .r,
                                                                        ),
                                                                      ),
                                                                      image: reviews[
                                                                              index]
                                                                          .image!,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      fadeInDuration:
                                                                          Duration(
                                                                              milliseconds: 250),
                                                                      fadeInCurve:
                                                                          Curves
                                                                              .easeInOut,
                                                                      fadeOutDuration:
                                                                          Duration(
                                                                              milliseconds: 150),
                                                                      fadeOutCurve:
                                                                          Curves
                                                                              .easeInOut,
                                                                    ),
                                                                  ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right:
                                                                      AppPadding
                                                                          .p16
                                                                          .w,
                                                                  bottom: 0,
                                                                  top: 0),
                                                          child: Container(
                                                            width:
                                                                AppSize.w395.w,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsets.only(
                                                                      left: lang ==
                                                                              "ar"
                                                                          ? AppPadding
                                                                              .p0
                                                                          : AppPadding
                                                                              .p10
                                                                              .w),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            reviews[index].name,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: getTranslated(context, 'Ithra'),
                                                                              color: AppColors.black4,
                                                                              fontSize: AppFontsSizeManager.s21_3.sp,
                                                                              fontStyle: FontStyle.normal,
                                                                            ),
                                                                          ),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: [
                                                                              Image.asset(
                                                                                AssetsManager.star1,
                                                                                width: AppSize.w16.w,
                                                                                height: AppSize.h16.h,
                                                                              ),
                                                                              SizedBox(width: AppSize.w2_6.w),
                                                                              Text(
                                                                                reviews[index].rating.toStringAsFixed(1),
                                                                                textAlign: TextAlign.start,
                                                                                style: TextStyle(
                                                                                  fontWeight: AppFontsWeightManager.bold700,
                                                                                  fontFamily: getTranslated(context, 'Montserrat-Medium'),
                                                                                  color: AppColors.linear2,
                                                                                  fontSize: AppFontsSizeManager.s16.sp,
                                                                                  fontStyle: FontStyle.normal,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          )
                                                                        ],
                                                                      ),
                                                                      reviews[index].review ==
                                                                              null
                                                                          ? SizedBox()
                                                                          : SizedBox(
                                                                              height: AppSize.h5_3.h,
                                                                            ),
                                                                      reviews[index].review ==
                                                                              null
                                                                          ? SizedBox()
                                                                          : Text(
                                                                              reviews[index].review!.toString(),
                                                                              overflow: TextOverflow.ellipsis,
                                                                              maxLines: 4,
                                                                              style: TextStyle(
                                                                                fontFamily: getTranslated(context, 'Ithralight'),
                                                                                color: AppColors.grey,
                                                                                fontSize: AppFontsSizeManager.s16.sp,
                                                                                fontStyle: FontStyle.normal,
                                                                              ),
                                                                            ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                                separatorBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return Center(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: AppSize.h20.h,
                                                          bottom:
                                                              AppSize.h21_3.h),
                                                      child: Container(
                                                        color: AppColors.grey,
                                                        width: size.width,
                                                        height: AppSize.h0_5.h,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )
                                            : SizedBox(),
                                        SizedBox(
                                          height: AppSize.h32.h,
                                        ),
                                        Row(
                                          mainAxisAlignment: lang == "ar"
                                              ? MainAxisAlignment.center
                                              : MainAxisAlignment.start,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ReviewScreens(
                                                      consult:
                                                          widget.consultant,
                                                      reviewLength:
                                                          reviewLength,
                                                      loggedUser:
                                                          widget.loggedUser,
                                                      avaliable: avaliable,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: InkWell(
                                                // onTap: () {
                                                //   print(
                                                //       "*************************************");
                                                //   print("country" +
                                                //       widget.consultant.country
                                                //           .toString());
                                                //   print("Rate" +
                                                //       widget.consultant.rate.toString());
                                                //   print(
                                                //       "*************************************");
                                                // },
                                                child: Container(
                                                  height: AppSize.h32.w,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                          AppPadding.p10_6.w,
                                                      vertical:
                                                          AppPadding.p5_3.h),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.linear3,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            AppRadius.r5_3.r),
                                                  ),
                                                  child: Center(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          getTranslated(context,
                                                              "readMore2"),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                getTranslated(
                                                                    context,
                                                                    'Ithra'),
                                                            color: AppColors
                                                                .white1,
                                                            fontSize:
                                                                AppFontsSizeManager
                                                                    .s16.sp,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width:
                                                                AppSize.w5_3.w),
                                                        lang == "ar"
                                                            ? SvgPicture.asset(
                                                                AssetsManager
                                                                    .pinkReadMoreIconPath,
                                                                width: AppSize
                                                                    .w21_3.r,
                                                                height: AppSize
                                                                    .h21_3.r,
                                                                color: AppColors
                                                                    .white,
                                                              )
                                                            : new RotationTransition(
                                                                turns:
                                                                    new AlwaysStoppedAnimation(
                                                                        180 /
                                                                            360),
                                                                child:
                                                                    Image.asset(
                                                                  AssetsManager
                                                                      .white_more,
                                                                  width: AppSize
                                                                      .w21_3.r,
                                                                  height:
                                                                      AppSize
                                                                          .h21_3
                                                                          .r,
                                                                ),
                                                              ),
                                                      ],
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
                            ),
                            SizedBox(
                              height: AppSize.h45_3.h,
                            ),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    getTranslated(context, "timeOfWork"),
                                    style: TextStyle(
                                        fontFamily:
                                            getTranslated(context, 'Ithra'),
                                        color: AppColors.linear3,
                                        fontSize: AppFontsSizeManager.s21_3.sp,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  SizedBox(width: AppSize.w10_6.w),
                                  SvgPicture.asset(
                                    AssetsManager.calendar_clock_iconPath,
                                    width: AppSize.w21_3.w,
                                    height: AppSize.h21_3.h,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h32.h,
                            ),
                            /*Padding(
                            padding:  EdgeInsets.only(right: 56.w),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/applicationIcons/Iconly-Two-tone-Calendar-1.png',
                                  width: 27.w,
                                  height: 27.h,
                                ),
                              ],
                            ),
                          ),*/
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: AppPadding.p16.w),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: GridView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            padding: EdgeInsets.only(),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 4,
                                              childAspectRatio: 4.5,
                                              mainAxisSpacing: 0,
                                              crossAxisSpacing: 0,
                                            ),
                                            shrinkWrap: true,
                                            itemCount: daysList.length - 1,
                                            itemBuilder: (context, index) {
                                              return index <
                                                      ((daysList.length - 1) -
                                                          ((daysList.length -
                                                                  1) %
                                                              4))
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        SvgPicture.asset(
                                                          AssetsManager
                                                              .checkIconPath,
                                                          width:
                                                              AppSize.w21_3.w,
                                                          height:
                                                              AppSize.h21_3.h,
                                                        ),
                                                        SizedBox(
                                                          width: AppSize.w5_3.w,
                                                        ),
                                                        Center(
                                                          child: Text(
                                                            daysList[index],
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  getTranslated(
                                                                      context,
                                                                      'Ithra'),
                                                              color: AppColors
                                                                  .black,
                                                              fontSize: lang ==
                                                                      "ar"
                                                                  ? AppFontsSizeManager
                                                                      .s18_6.sp
                                                                  : AppFontsSizeManager
                                                                      .s16_6.sp,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .normal,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : SizedBox();
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (((daysList.length - 1) % 4) > 0)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                        ((daysList.length - 1) % 4), (index) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            right: AppPadding.p41_3.w),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              AssetsManager.checkIconPath,
                                              width: AppSize.w21_3.w,
                                              height: AppSize.h21_3.h,
                                            ),
                                            SizedBox(
                                              width: AppSize.w5_3.w,
                                            ),
                                            Center(
                                              child: Text(
                                                daysList[
                                                    (daysList.length - 1) < 4
                                                        ? index
                                                        : index + 4],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: getTranslated(
                                                      context, 'Ithra'),
                                                  color: AppColors.black,
                                                  fontSize: lang == "ar"
                                                      ? AppFontsSizeManager
                                                          .s18_6.sp
                                                      : AppFontsSizeManager
                                                          .s16_6.sp,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ); // Replace with your grid item widget
                                    }),
                                  ),
                                SizedBox(
                                  height: AppSize.h28.h,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: convertPtToPx(AppSize.w164_4).w,
                                        height: convertPtToPx(AppSize.h30).h,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.r5_3.r),
                                          border: Border.all(
                                            color: AppColors.linear3,
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Center(
                                              child: Text(
                                                getTranslated(context, "from"),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: getTranslated(
                                                      context, 'Ithralight'),
                                                  color: AppColors.linear3,
                                                  fontSize: AppFontsSizeManager
                                                      .s18_6.sp,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: AppSize.w4.w,
                                            ),
                                            Center(
                                                child: localFrom == 0
                                                    ? Text(
                                                        "12" +
                                                            ":" +
                                                            "00" +
                                                            " " +
                                                            getTranslated(
                                                                context, "AM"),
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 3,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              getTranslated(
                                                                  context,
                                                                  'Ithralight'),
                                                          color:
                                                              AppColors.linear3,
                                                          fontSize:
                                                              AppFontsSizeManager
                                                                  .s18_6.sp,
                                                          fontStyle:
                                                              FontStyle.normal,
                                                        ),
                                                      )
                                                    : localFrom == 12
                                                        ? Text(
                                                            "12" +
                                                                ":" +
                                                                "00" +
                                                                " " +
                                                                getTranslated(
                                                                    context,
                                                                    "PM"),
                                                            textAlign: TextAlign
                                                                .center,
                                                            maxLines: 3,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  getTranslated(
                                                                      context,
                                                                      'Ithralight'),
                                                              color: AppColors
                                                                  .linear3,
                                                              fontSize:
                                                                  AppFontsSizeManager
                                                                      .s18_6.sp,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .normal,
                                                            ),
                                                          )
                                                        : localFrom > 12
                                                            ? Text(
                                                                from +
                                                                    ":" +
                                                                    "00" +
                                                                    " " +
                                                                    getTranslated(
                                                                        context,
                                                                        "PM"),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLines: 3,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      getTranslated(
                                                                          context,
                                                                          'Ithralight'),
                                                                  color: AppColors
                                                                      .linear3,
                                                                  fontSize:
                                                                      AppFontsSizeManager
                                                                          .s18_6
                                                                          .sp,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .normal,
                                                                ),
                                                              )
                                                            : Text(
                                                                from +
                                                                    ":" +
                                                                    "00" +
                                                                    " " +
                                                                    getTranslated(
                                                                        context,
                                                                        "AM"),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLines: 3,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      getTranslated(
                                                                          context,
                                                                          'Ithralight'),
                                                                  color: AppColors
                                                                      .linear3,
                                                                  fontSize:
                                                                      AppFontsSizeManager
                                                                          .s18_6
                                                                          .sp,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .normal,
                                                                ),
                                                              ))
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                convertPtToPx(AppPadding.p16)
                                                    .h),
                                        child: SvgPicture.asset(
                                          AssetsManager.pinkClockIconPath,
                                          height: AppSize.h32.h,
                                          width: AppSize.w32.w,
                                        ),
                                      ),
                                      Container(
                                        width: convertPtToPx(AppSize.w164_4).w,
                                        height: convertPtToPx(AppSize.h30).h,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.r5_3.r),
                                          border: Border.all(
                                            color: AppColors.linear3,
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Center(
                                              child: Text(
                                                getTranslated(context, "to2"),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: getTranslated(
                                                      context, 'Ithralight'),
                                                  color: AppColors.linear3,
                                                  fontSize: AppFontsSizeManager
                                                      .s18_6.sp,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: AppSize.w4.w,
                                            ),
                                            Center(
                                                child: localTo == 0
                                                    ? Text(
                                                        "12" +
                                                            ":" +
                                                            "00" +
                                                            " " +
                                                            getTranslated(
                                                                context, "AM"),
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 3,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              getTranslated(
                                                                  context,
                                                                  'Ithralight'),
                                                          color:
                                                              AppColors.linear3,
                                                          fontSize:
                                                              AppFontsSizeManager
                                                                  .s18_6.sp,
                                                          fontStyle:
                                                              FontStyle.normal,
                                                        ),
                                                      )
                                                    : localTo == 12
                                                        ? Text(
                                                            "12" +
                                                                ":" +
                                                                "00" +
                                                                " " +
                                                                getTranslated(
                                                                    context,
                                                                    "PM"),
                                                            textAlign: TextAlign
                                                                .center,
                                                            maxLines: 3,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  getTranslated(
                                                                      context,
                                                                      'Ithralight'),
                                                              color: AppColors
                                                                  .linear3,
                                                              fontSize:
                                                                  AppFontsSizeManager
                                                                      .s18_6.sp,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .normal,
                                                            ),
                                                          )
                                                        : localTo > 12
                                                            ? Text(
                                                                to +
                                                                    ":" +
                                                                    "00" +
                                                                    " " +
                                                                    getTranslated(
                                                                        context,
                                                                        "PM"),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLines: 3,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      getTranslated(
                                                                          context,
                                                                          'Ithralight'),
                                                                  color: AppColors
                                                                      .linear3,
                                                                  fontSize:
                                                                      AppFontsSizeManager
                                                                          .s18_6
                                                                          .sp,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .normal,
                                                                ),
                                                              )
                                                            : Text(
                                                                to +
                                                                    ":" +
                                                                    "00" +
                                                                    " " +
                                                                    getTranslated(
                                                                        context,
                                                                        "AM"),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLines: 3,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      getTranslated(
                                                                          context,
                                                                          'Ithralight'),
                                                                  color: AppColors
                                                                      .linear3,
                                                                  fontSize:
                                                                      AppFontsSizeManager
                                                                          .s18_6
                                                                          .sp,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .normal,
                                                                ),
                                                              )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // Container(height: 2, width: double.infinity, color: Colors.red,),

                            SizedBox(
                              height: convertPtToPx(AppSize.h30_5).h,
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  getTranslated(context, "allPackages"),
                                  style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, 'Ithra'),
                                      color: AppColors.linear3,
                                      fontSize: AppFontsSizeManager.s21_3.sp,
                                      fontStyle: FontStyle.normal),
                                ),
                                SizedBox(width: AppSize.w10_6.w),
                                Image.asset(
                                  AssetsManager.check_circle_iconPath,
                                  width: AppSize.w21_3.w,
                                  height: AppSize.h21_3.h,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: convertPtToPx(AppSize.h14_5).h,
                            ),
                            loadPackage
                                ? Center(child: CircularProgressIndicator())
                                : SizedBox(),
                            (loadPackage == false && packages.length == 0)
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Image.asset(
                                            AssetsManager.creditCard,
                                            width: size.width * AppSize.w0_5.w,
                                          ),
                                          SizedBox(
                                            height: AppSize.h20.h,
                                          ),
                                          Text(
                                            getTranslated(
                                                context, "noPackages"),
                                            style: TextStyle(
                                              fontFamily: getTranslated(
                                                  context, "Ithra"),
                                              color: AppColors.grey,
                                              fontSize:
                                                  AppFontsSizeManager.s20.sp,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                            (loadPackage == false && packages.length > 0)
                                ? showBookingSection == false
                                    ? ListView.separated(
                                        itemCount: packages.length,
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return PackageWidget(
                                            selectedIndex: _selectedIndex,
                                            consultType: widget.consultType,
                                            index: index,
                                            packages: packages,
                                            function: () {
                                              _onSelected(index);
                                            },
                                          );
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                          return SizedBox(
                                            height: AppSize.h21_3.h,
                                          );
                                        },
                                      )
                                    : PackageWidget(
                                        selectedIndex: _selectedIndex,
                                        consultType: widget.consultType,
                                        index: _selectedIndex,
                                        packages: packages,
                                        function: () {
                                          // _onSelected(index);
                                        },
                                      )
                                : SizedBox(),
                          ],
                        ),

                      /// TODO: Support section
                      // if(user!.userType== AppConstants.support)
                      // Column(
                      //   children: [
                      //     Text(
                      //       getTranslated(context, "selectUser"),
                      //       style: TextStyle(
                      //           fontFamily: getTranslated(context, 'Ithra'),
                      //           color: AppColors.linear3,
                      //           fontSize: AppFontsSizeManager.s21_3.sp,
                      //           fontStyle: FontStyle.normal),
                      //     ),
                      //     SizedBox(
                      //       height: AppSize.h10.h,
                      //     ),
                      //
                      //     Autocomplete<GroceryUser>(
                      //       initialValue: initialAutoCompleteValue,
                      //       optionsBuilder: (TextEditingValue textEditingValue)async{
                      //         users.clear();
                      //
                      //         /// search in firebase for users that have this number.
                      //         ///
                      //         QuerySnapshot query= await FirebaseFirestore.instance.collection(Paths.usersPath)
                      //             .where('userType', isEqualTo: AppConstants.user)
                      //             .where('phoneNumber', isEqualTo: ('+966'+textEditingValue.text))
                      //             .get();
                      //
                      //         if(query.docs.isNotEmpty){
                      //           query.docs.forEach((element) {
                      //             users.add(GroceryUser.fromMap(query.docs.first.data() as Map));
                      //           });
                      //           // GroceryUser userr= await GroceryUser.fromMap(query.docs.first.data() as Map);
                      //           // print('==========t ${userr.uid}');
                      //           // print('==========t ${userr.phoneNumber}');
                      //         }
                      //
                      //         if(textEditingValue.text=='') {
                      //           return const Iterable<GroceryUser>.empty();
                      //         }
                      //         return users.where((GroceryUser item) {
                      //           return item.phoneNumber!.contains(textEditingValue.text.toLowerCase());
                      //         });
                      //       },
                      //       displayStringForOption: (GroceryUser user)=> user.name!,
                      //       onSelected: (item){
                      //         selectedUserBySupport= item;
                      //       },
                      //     ),
                      //
                      //     SizedBox(height: AppSize.h25.h,),
                      //   ],
                      // ),

                      load
                          ? Center(child: CircularProgressIndicator())
                          : showBookingSection
                              ? SizedBox()
                              : Padding(
                                  padding: EdgeInsets.only(
                                      right: convertPtToPx(AppSize.w24).w,
                                      left: convertPtToPx(AppSize.w24).w,
                                      bottom: convertPtToPx(AppSize.h32).h,
                                      top: convertPtToPx(AppSize.h32).h),
                                  child: textButton(
                                    onPress: () async {
                                      if (user == null) {
                                        Navigator.pushNamed(
                                            context, '/Register_Type');
                                      } else if (package == null) {
                                        showSnakbar(
                                            getTranslated(
                                                context, 'selectPackage'),
                                            false);
                                      } else if (user!.userType ==
                                              AppConstants.support &&
                                          selectedUserBySupport == null) {
                                        customTextDialog(
                                            context: context,
                                            text: getTranslated(
                                                context, 'selectUser'),
                                            buttonText:
                                                getTranslated(context, 'Ok'),
                                            okFunction: () {
                                              Navigator.pop(context);
                                            });
                                      } else {
                                        setState(() {
                                          showBookingSection = true;
                                        });

                                        ///showAddAppointmentDialog();
                                      }
                                    },
                                    text: getTranslated(
                                        context, "StartYourReservation"),
                                    width: size.width,
                                    height: AppSize.h66_6.h,
                                    ButtonColor: null,
                                    buttonRadius: AppRadius.r10_6.r,
                                    textSize: AppFontsSizeManager.s21_3.sp,
                                    textfont: getTranslated(context, 'Ithra'),
                                    textcolor: AppColors.white1,
                                    icon: '',
                                    Gradient_Color: AppColors.Gradient_Color1,
                                    Gradient_Color2: AppColors.Gradient_Color2,
                                  ),
                                ),

                      if (showBookingSection)
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: AppSize.w24).w,
                          child: BookingSection(
                            loggedUser: user!.userType == AppConstants.support
                                ? selectedUserBySupport!
                                : user!,
                            isSupport: user!.userType == AppConstants.support
                                ? true
                                : false,
                            consultant: widget.consultant,
                            localFrom: localFrom,
                            localTo: localTo,
                            package: package!,
                            getData: getDataFromBooking,
                            selectedIndex: _selectedIndex,
                            currentNumber: currentNumber - 1,
                            consultType: widget.consultType,
                            backFromBooking: backFromBooking,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          showPayView
              ? Positioned(
                  child: Scaffold(
                    backgroundColor: AppColors.white,
                    body: IndexedStack(
                      index: _stackIndex,
                      children: <Widget>[
                        WebView(
                          initialUrl: initialUrl,
                          navigationDelegate: (NavigationRequest request) {
                            if (request.url.startsWith(
                                "https://www.jeras.io/app/redirect_url")) {
                              setState(() {
                                _stackIndex = 1;
                                showPayView = false;
                                var str = request.url;
                                const start = "tap_id=";
                                final startIndex = str.indexOf(start);

                                String charge = str.substring(
                                    startIndex + start.length, str.length);
                                payStatus(charge);
                              });
                              return NavigationDecision.prevent;
                            }
                            return NavigationDecision.navigate;
                          },
                          javascriptMode: JavascriptMode.unrestricted,
                          gestureNavigationEnabled: true,
                          initialMediaPlaybackPolicy:
                              AutoMediaPlaybackPolicy.always_allow,
                          onPageFinished: (url) {
                            //showSnakbar(url, true);
                            setState(() => _stackIndex = 0);
                          },
                        ),
                        Center(child: Text('Loading  ...')),
                        Center(child: Text('order ...'))
                      ],
                    ),
                  ),
                )
              : Container()
        ]),
      ),
    );
  }

  Future<void> payFromBalance(
      {required GroceryUser userAccount, required double price}) async {
    var newBalance = double.parse(userAccount.balance.toString()) - price;

    if (newBalance >= 0) {
      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(userAccount.uid)
          .set({
        'balance': newBalance,
      }, SetOptions(merge: true));

      fromBalance = true;
      userAccount.balance = newBalance;

      updateDatabaseAfterAddingOrder(
          userAccount.customerId, "userBalance", price);
    } else {
      customTextDialog(
        text: getTranslated(context, 'payFromBalanceNote'),
        buttonText: getTranslated(context, 'Ok'),
        context: context,
        okFunction: () async {
          Navigator.pop(context);
        },
      );
    }
  }

  Widget headerWidget() {
    return Column(
      children: [
        Container(
          width: size.width,
          decoration: BoxDecoration(
            color: AppColors.white,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: convertPtToPx(AppPadding.p24).w,
              vertical: convertPtToPx(AppPadding.p12).h,
            ),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  CustomBackButton(),
                  SizedBox(
                    width: convertPtToPx(AppPadding.p16).w,
                  ),
                  Text(
                    '${widget.consultant.name}',
                    style: TextStyle(
                      fontFamily: getTranslated(context, 'Ithra'),
                      fontSize: convertPtToPx(AppFontsSizeManager.s16).sp,
                      color: AppColors.appbartext,
                      fontWeight: AppFontsWeightManager.semiBold,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Center(
            child: Container(
                color: Color.fromRGBO(236, 236, 236, 0.65),
                height: 1.5.h,
                width: size.width)),
      ],
    );
  }

  BoxDecoration decoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10.5.r),
      boxShadow: [AppShadow.primaryShadow],
    );
  }

  Widget noNotificationWidget() {
    return Container(
      width: AppSize.w50_5.w,
      height: AppSize.h50_5.h,
      decoration: decoration(),
      child: Center(
        child: InkWell(
          splashColor: AppColors.white.withOpacity(0.6),
          onTap: () {
            Fluttertoast.showToast(
                msg: getTranslated(context, "noNotification"),
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.red,
                textColor: AppColors.white,
                fontSize: AppFontsSizeManager.s16.sp);
          },
          child: Image.asset(
            AssetsManager.purple_notification_iconPath,
            width: AppSize.w31_5.w,
            height: AppSize.h36.h,
          ),
        ),
      ),
    );
  }

  calculateDiscount() async {
    setState(() {
      checkPromo = true;
    });
    if (controller.text != null && controller.text != "") {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.promoPath)
          .where('promoCodeStatus', isEqualTo: true)
          .where('code', isEqualTo: controller.text)
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
            _selectedIndex != null &&
            _selectedIndex == 0 &&
            user!.promoList != null &&
            user!.promoList!.contains(codes[0].promoCodeId) == false);
        bool isDefault = (codes[0].type == "default" &&
            codes[0].promoCodeStatus &&
            _selectedIndex != null &&
            _selectedIndex == 0);
        bool isPromition = (codes[0].type == "promotion" &&
            codes[0].promoCodeStatus &&
            codes[0].usedNumber == 0 &&
            _selectedIndex != null &&
            _selectedIndex == 0);
        if (isDefault || isPrimary || isPromition)
          setState(() {
            promo = codes[0];
            promoCodeId = promo!.promoCodeId;
            checkPromo = false;
            valid = true;
            discount = promo!.discount;
          });
        else
          setState(() {
            promo = null;
            promoCodeId = "";
            checkPromo = false;
            valid = false;
            discount = 0;
          });
      } else {
        setState(() {
          promo = null;
          promoCodeId = "";
          checkPromo = false;
          valid = false;
          discount = 0;
        });
      }
    }
  }

  pay() async {
    try {
      if (user != null && user!.name != null) userName = user!.name!; //
      String description = "السعر";
      /* if( user!.countryCode!=null&& user!.countryCode=="+966")
        description=" السعر شامل ضريبة القيمة المضافة";*/
      final uri = Uri.parse('https://api.tap.company/v2/charges');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': "Bearer sk_live_UN9kc65zvtmrX1PjnagRYhLb",
        'Connection': 'keep-alive',
        'Accept-Encoding': 'gzip, deflate, br'
      };
      var destinationBody = {};
      Map<String, dynamic> body = {
        "amount": price,
        "currency": "USD",
        "threeDSecure": true,
        "save_card": true,
        "description": description,
        "statement_descriptor": "مؤسسة  محور النقطة",
        "metadata": {
          "udf1": "مؤسسة  محور النقطة",
          "udf2": "مؤسسة  محور النقطة"
        },
        "reference": {"transaction": "txn_0001", "order": "ord_0001"},
        "receipt": {"email": false, "sms": true},
        "customer": {
          "id": user!.customerId != null ? user!.customerId : '',
          "first_name": userName,
          "middle_name": ".",
          "last_name": ".",
          "email": userName + "@dream.com",
          "phone": {"country_code": "", "number": user!.phoneNumber}
        },
        "destinations": destinationBody,
        "merchant": {"id": ""},
        "source": {"id": "src_all"},
        "post": {"url": "http://your_website.com/post_url"},
        "redirect": {"url": "https://www.jeras.io/app/redirect_url"}
      };

      String jsonBody = json.encode(body);
      final encoding = Encoding.getByName('utf-8');
      var response = await post(
        uri,
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      );

      String responseBody = response.body;
      var res = json.decode(responseBody);
      String url = res['transaction']['url'];

      // Navigator.pop(context);
      setState(() {
        initialUrl = url;
        showPayView = true;
      });
    } catch (e) {
      errorLog("pay", e.toString());
      await FirebaseAnalytics.instance.logEvent(name: "payInfo", parameters: {
        "success": 'false',
        "reason": e.toString(),
        "userUid": widget.loggedUser!.uid
      });
      setState(() {
        showPayView = false;
        //load=false;
      });
      showMessage(getTranslated(context, "failed"));
      // showDialog(
      //     context: context,
      //     builder: (context) => ShowDialog(
      //           contentText: 'otherPay',
      //           noFunction: () {
      //             setState(() {
      //               load = false;
      //             });
      //             Navigator.pop(context);
      //           },
      //           yesFunction: () async {
      //             Navigator.pop(context);
      //             setState(() {
      //               load = true;
      //               fromBalance = false;
      //             });
      //             stripePayment(
      //                 amount: price,
      //                 context: context);
      //             // pay();
      //           },
      //         ));
    }
  }

  showMessage(String message, {Color color = AppColors.red}) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: color,
        textColor: AppColors.white,
        fontSize: 16.0.sp);
  }

  payStatus(String chargeId) async {
    try {
      final uri = Uri.parse('https://api.tap.company/v2/charges/' + chargeId);
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': "Bearer sk_live_UN9kc65zvtmrX1PjnagRYhLb",
        'Connection': 'keep-alive',
        'Accept-Encoding': 'gzip, deflate, br'
      };
      var response = await get(
        uri,
        headers: headers,
      );
      String responseBody = response.body;
      var res = json.decode(responseBody);
      String? customerId = res['customer']['id'];
      customerId = customerId != null ? customerId : "";
      if (res['status'] == "CAPTURED") {
        updateDatabaseAfterAddingOrder(customerId, "tapCompany", price);
      } else {
        setState(() {
          load = true;
          showPayView = false;
        });
        //--------add details event
        await FirebaseAnalytics.instance.logEvent(name: "payInfo", parameters: {
          "success": 'false',
          "reason": res['status'],
          "userUid": widget.loggedUser!.uid
        });
        String eventName = "af_add_payment_info";
        Map eventValues = {
          "af_success": false,
          "af_achievement_id": res['status'],
        };
        addEvent(eventName, eventValues);
        String id = Uuid().v4();
        await FirebaseFirestore.instance
            .collection(Paths.errorLogPath)
            .doc(id)
            .set({
          'timestamp': Timestamp.now(),
          'id': id,
          'seen': false,
          'desc': res['status'],
          'phone':
              widget.loggedUser == null ? " " : widget.loggedUser!.phoneNumber,
          'screen': "ConsultantDetailsScreen",
          'function': "payStatus",
        });
        showMessage(getTranslated(context, "failed"));
        // showDialog(
        //     context: context,
        //     builder: (context) => ShowDialog(
        //           contentText: 'otherPay',
        //           noFunction: () {
        //             setState(() {
        //               load = false;
        //             });
        //             Navigator.pop(context);
        //           },
        //           yesFunction: () {
        //             Navigator.pop(context);
        //             setState(() {
        //               load = true;
        //               fromBalance = false;
        //             });
        //             stripePayment(
        //                 amount: price.toString(),
        //                 context: context);
        //             // pay();
        //           },
        //         ));
      }
    } catch (e) {
      errorLog("payStatus", e.toString());
      setState(() {
        showPayView = false;
        load = false;
      });
      await FirebaseAnalytics.instance.logEvent(name: "payInfo", parameters: {
        "success": 'false',
        "reason": e.toString(),
        "userUid": widget.loggedUser!.uid
      });
      String eventName = "af_add_payment_info";
      Map eventValues = {
        "af_success": false,
        "af_achievement_id": e.toString(),
      };
      addEvent(eventName, eventValues);
      showSnakbar(getTranslated(context, "failed"), true);
      // showDialog(
      //     context: context,
      //     builder: (context) => ShowDialog(
      //           contentText: 'otherPay',
      //           noFunction: () {
      //             setState(() {
      //               load = false;
      //             });
      //             Navigator.pop(context);
      //           },
      //           yesFunction: () {
      //             Navigator.pop(context);
      //             setState(() {
      //               load = true;
      //               fromBalance = false;
      //             });
      //             stripePayment(
      //                 amount: price,
      //                 context: context);
      //             // pay();
      //           },
      //         ));
    }
  }

  Future<bool> stripePayment(
      {required String amount, required BuildContext context}) async {
    try {
      print("stripePayment1");
      print(amount.toString());

      final isPaymentSuccessful = await showModalBottomSheet<bool>(
        isScrollControlled: true,
        context: context,
        backgroundColor: AppColors.white,
        elevation: 0,
        // barrierColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.r30.r),
              topRight: Radius.circular(AppRadius.r30.r)),
        ),
        builder: (context) {
          return StripePaymentBottomSheet(
            loggedUser: user!,
            price: double.parse(amount),
            productName: package!.type,
            productDesc:
                '${package!.type} -- ${package!.callNum} -- ${package!.Id}',
          );
        },
      );

      if (isPaymentSuccessful != null && isPaymentSuccessful) {
        // تم الدفع بنجاح
        showMessage("Payment is successful", color: AppColors.green);
        updateDatabaseAfterAddingOrder(
            user!.customerId, "stripe ", double.parse(amount));
        return true;
      } else {
        // لم يتم الدفع أو حدث خطأ
        print("stripeerror");
        return false;
      }
    } catch (errorr) {
      print("stripeerror");
      print("error in stripe is ${errorr.toString()}");
      showMessage('An error occured $errorr');
      setState(() {
        load = false;
      });
      return false;
    }
  }

  updateDatabaseAfterAddingOrder(
      String? customerId, String payWith, double totalPrice) async {
    try {
      String orderId = Uuid().v4();

      DateTime dateValue = DateTime.now();

      dynamic callPrice = totalPrice / package!.callNum;
      await FirebaseFirestore.instance
          .collection(Paths.ordersPath)
          .doc(orderId)
          .set({
        'orderStatus': 'open',
        'orderId': orderId,
        'date': {
          'day': dateValue.toUtc().day,
          'month': dateValue.toUtc().month,
          'year': dateValue.toUtc().year,
        },
        'utcTime': dateValue.toUtc().toString(),
        'orderTimestamp': Timestamp.now(),
        'orderTimeValue':
            DateTime(dateValue.year, dateValue.month, dateValue.day)
                .millisecondsSinceEpoch,
        "consultType": widget.consultType,
        'packageId': package!.Id,
        'promoCodeId': promoCodeId,
        'remainingCallNum': package!.callNum,
        'packageCallNum': package!.callNum,
        'answeredCallNum': 0,
        'callPrice': callPrice,
        "payWith": payWith,
        "platform": Platform.isIOS ? "iOS" : "Android",
        'price': price.toString(),
        'consult': {
          'uid': widget.consultant.uid,
          'name': widget.consultant.name,
          'image': widget.consultant.photoUrl,
          'phone': widget.consultant.phoneNumber,
          'countryCode': widget.consultant.countryCode,
          'countryISOCode': widget.consultant.countryISOCode,
          // 'country': widget.consultant.country,
        },
        'user': {
          'uid': user!.uid,
          'name': user!.name,
          'image': user!.photoUrl,
          'phone': user!.phoneNumber,
          'countryCode': user!.countryCode,
          'countryISOCode': user!.countryISOCode,
        },
      });

      currentNumber = package!.callNum;
      // getOrder(orderId);

      /// add appointment
      ///
      await addAppointment(
          date: _selectedDate!,
          loggedUser: widget.loggedUser!,
          consultant: widget.consultant,
          orderId: orderId,
          currentNumber: currentNumber,
          selectedCard: _selectedDateCard,
          consultType: widget.consultType,
          callPrice: callPrice,
          time: _time!,
          context: context,
          todayAppointmentList: _todayAppointmentList);

      //update user order numbers
      int userOrdersNumbers = 1;
      dynamic payedBalance = double.parse(price.toString());
      if (user!.ordersNumbers != null)
        userOrdersNumbers = user!.ordersNumbers! + 1;
      if (user!.payedBalance != null)
        payedBalance = user!.payedBalance + payedBalance;

      if (promo != null && promo!.type != null && promo!.type == "primary")
        user!.promoList!.add(promo!.promoCodeId);

      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(user!.uid)
          .set({
        'ordersNumbers': userOrdersNumbers,
        'payedBalance': payedBalance,
        'customerId': customerId,
        'promoList': user!.promoList,
        'preferredPaymentMethod': "tapCompany"
      }, SetOptions(merge: true));

      /**
       * APPS FLYER REWARD LOGIC
       */
      await AppFlyerService().updatePurchaseStatusOfUser(
        userId: user!.uid!,
        amount: double.parse(price.toString()),
        orderId: orderId,
        payWith: payWith,
        percentage: '10%',
        purchasedAt: dateValue,
      );
      /**
       *
       */

      accountBloc.add(GetLoggedUserEvent());
//======update number of use of promocode
      if (promo != null) {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection(Paths.promoPath)
            .doc(promo!.promoCodeId)
            .get();
        Map data = documentSnapshot.data() as Map;
        int usedNumber = data['usedNumber'];
        await FirebaseFirestore.instance
            .collection(Paths.promoPath)
            .doc(promo!.promoCodeId)
            .set({
          'usedNumber': usedNumber + 1,
        }, SetOptions(merge: true));
      }
      //---------
      /*if(widget.consultant.allowEditPayinfo==false&&widget.consultant.marketplace!&&
          widget.consultant.destinationId!=null&&widget.consultant.destinationId!="") {
        await FirebaseFirestore.instance.collection(Paths.usersPath).doc(
            widget.consultant.uid!).set({
        'tapBalance': widget.consultant.tapBalance+destinationAmount,

        }, SetOptions(merge: true));
    }*/
      //--------add details event
      String eventName = "af_add_payment_info";
      Map eventValues = {
        "af_success": true,
        "af_achievement_id": "success",
      };
      addEvent(eventName, eventValues);
      await FirebaseAnalytics.instance.logEvent(name: "payInfo", parameters: {
        "success": 'true',
        "reason": "success",
        "userUid": widget.loggedUser!.uid
      });
      //-----------
      eventName = "af_purchase";
      eventValues = {
        "af_revenue": price.toString(),
        "af_price": price.toString(),
        "af_content_id": widget.consultant.uid,
        "af_order_id": orderId,
        "af_currency": "USD",
      };
      addEvent(eventName, eventValues);

      //================
      // showAddAppointmentDialog();
    } catch (e) {
      errorLog("updateDatabaseAfterAddingOrder", e.toString());
    }
  }

  // مشكلة عدم ظهور المواعيد عند الحجز todo check this method
  showAddAppointmentDialog() async {
    if (order != null) {
      bool? isProceeded = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AddAppointmentForPreviousOrderDialog(
              loggedUser: user!,
              consultant: widget.consultant,
              // isSupport: user!.userType== AppConstants.support ? true : false,
              order: order!,
              localFrom: localFrom,
              // selectedIndex: _selectedIndex,
              // getData: getDataFromDialog,
              localTo: localTo,
              // package: package!,
              currentNumber: currentNumber,
              consultType: widget.consultType);
        },
      );

      if (isProceeded != null) {
        if (isProceeded) {
          setState(() {
            load = false;
          });
        }
      }
    }
  }

  cleanConsultDays() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.consultDaysPath)
          .where('date',
              isLessThan: DateTime(DateTime.now().year, DateTime.now().month,
                      DateTime.now().day)
                  .millisecondsSinceEpoch)
          .where('consultUid', isEqualTo: widget.consultant.uid)
          .get();
      for (var doc in querySnapshot.docs) {
        await FirebaseFirestore.instance
            .collection(Paths.consultDaysPath)
            .doc(doc.id)
            .delete();
      }
    } catch (e) {}
  }

  Widget langWidget(String langText) {
    return Container(
      width: 54.w,
      decoration: BoxDecoration(
        color: Color.fromRGBO(247, 231, 243, 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Center(
        child: Text(
          langText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: getTranslated(context, "Ithra"),
            color: AppColors.linear3,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  share(BuildContext context) async {
    setState(() {
      sharing = true;
    });
    // Create DynamicLink
    String uid = widget.consultant.uid!;
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse("https://dreamuser\.page\.link/consultant_id=" + uid),
      uriPrefix: "https://dreamuser\.page\.link",
      androidParameters:
          const AndroidParameters(packageName: "com.abdulazizahmed.dream"),
      iosParameters: const IOSParameters(
          bundleId: "com.abdulazizAhmed.dream",
          appStoreId: "1515745954",
          minimumVersion: "2.2.17"),
    );
    ShortDynamicLink dynamicLink =
        await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
    File file;
    if (widget.consultant.photoUrl!.isEmpty) {
      final bytes = await rootBundle.load(AssetsManager.dream_icon_logo2);
      final list = bytes.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      file = await File('${tempDir.path}/image.jpg').create();
      file.writeAsBytesSync(list);
    } else {
      final directory = await getTemporaryDirectory();
      final path = directory.path;
      final response = await http.get(Uri.parse(widget.consultant.photoUrl!));

      print('============================res ${response.body}');
      print('============================res ${response.statusCode}');

      file =
          await File('$path/image_${DateTime.now().millisecondsSinceEpoch}.png')
              .writeAsBytes(response.bodyBytes);
    }

    Share.shareFiles(["${file.path}"],
        text: '(تطبيق رؤيا -Dream Application) '
            '\n ${getTranslated(context, "ilikead")} ${widget.consultant.name} '
            ' ${getTranslated(context, "irecommendit")}.\n '
            '\n ${dynamicLink.shortUrl.toString()} ');
    setState(() {
      sharing = false;
    });
  }
}

enum StepEnabling { sequential, individual }

class PackageWidget extends StatelessWidget {
  PackageWidget(
      {Key? key,
      required this.selectedIndex,
      required this.index,
      required this.consultType,
      required this.packages,
      required this.function})
      : super(key: key);
  Function function;
  int selectedIndex;
  int index;
  List<consultPackage> packages;
  String consultType;

  @override
  Widget build(BuildContext context) {
    String lang;
    lang = getTranslated(context, "lang");
    return InkWell(
      onTap: () {
        function();
      },
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: convertPtToPx(AppPadding.p24).w),
        child: Container(
            //width: AppSize.w338.w,
            height: convertPtToPx(AppSize.h55).h,
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(
                width: selectedIndex != null && selectedIndex == index
                    ? AppSize.w0_9
                    : AppSize.h0_9,
                color: selectedIndex != null && selectedIndex == index
                    ? AppColors.linear3
                    : AppColors.lightPink,
              ),
              borderRadius:
                  BorderRadius.circular(convertPtToPx(AppRadius.r8).r),
              // boxShadow: [AppShadow.primaryShadow],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: convertPtToPx(AppPadding.p16).w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    consultType == "chat"
                        ? (packages[index].callNum.toString() +
                            getTranslated(context, "chat"))
                        : (packages[index].callNum == 1
                            ? getTranslated(context, "call1")
                            : packages[index].callNum.toString() +
                                getTranslated(context, "call")),
                    style: TextStyle(
                      fontFamily: getTranslated(context, 'Ithra'),
                      color: selectedIndex != null && selectedIndex == index
                          ? AppColors.linear2
                          : AppColors.grey,
                      fontSize: convertPtToPx(AppFontsSizeManager.s14).sp,
                      fontStyle: FontStyle.normal,
                      letterSpacing: 0.5,
                    ),
                  ),
                  packages[index].discount == null ||
                          packages[index].discount == 0
                      ? Center(
                          child: Row(
                            children: [
                              SizedBox(
                                width: lang == 'ar' ? 0 : AppSize.w9.w,
                              ),
                              Text(
                                "%0" + "    ",
                                style: TextStyle(
                                  fontFamily: getTranslated(context, 'Ithra'),
                                  color: selectedIndex != null &&
                                          selectedIndex == index
                                      ? AppColors.linear2
                                      : AppColors.grey,
                                  fontSize:
                                      convertPtToPx(AppFontsSizeManager.s14).sp,
                                  fontStyle: FontStyle.normal,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(
                                width: lang == 'ar' ? AppSize.w9.w : 0,
                              )
                            ],
                          ),
                        )
                      : Row(
                          children: [
                            Image.asset(
                              AssetsManager.menus,
                              color: selectedIndex != null &&
                                      selectedIndex == index
                                  ? AppColors.linear2
                                  : AppColors.grey,
                            ),
                            SizedBox(
                              width: AppSize.w2_6.w,
                            ),
                            Text(
                              "%" + packages[index].discount.toString(),
                              style: TextStyle(
                                fontFamily: getTranslated(context, 'Ithra'),
                                color: selectedIndex != null &&
                                        selectedIndex == index
                                    ? AppColors.linear2
                                    : AppColors.grey,
                                fontSize:
                                    convertPtToPx(AppFontsSizeManager.s14).sp,
                                fontStyle: FontStyle.normal,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                  Text(
                    packages[index].price.toString() + "\$",
                    style: TextStyle(
                      fontFamily: getTranslated(context, 'Ithra'),
                      color: selectedIndex != null && selectedIndex == index
                          ? AppColors.linear2
                          : AppColors.grey,
                      fontSize: convertPtToPx(AppFontsSizeManager.s14).sp,
                      fontStyle: FontStyle.normal,
                      letterSpacing: 0.5,
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }
}

/// TODO: when the order is not null [mean that there are the previous order],
/// call [addAppointment] method directly, without call any pay method or[updateDatabaseAfterAddingOrder] method.
///
Future<void> addAppointment({
  required DateTime date,
  required GroceryUser loggedUser,
  required GroceryUser consultant,
  required String orderId,
  required int currentNumber,
  required int selectedCard,
  required String consultType,
  required double callPrice,
  required String time,
  required BuildContext context,
  required List<dynamic> todayAppointmentList,
  bool autoBack = false,
}) async {
  try {
    date = date.toUtc();
    String appointmentId = Uuid().v4();

    await FirebaseFirestore.instance
        .collection(Paths.appAppointments)
        .doc(appointmentId)
        .set({
      'appointmentId': appointmentId,
      'appointmentStatus': 'open',
      'consultType': consultType,
      'remainingCallNum': currentNumber,
      'type': 'valid',
      'lessonTime': 10,
      'allowCall': false,
      'timestamp': DateTime.now().toUtc(),
      'timeValue':
          DateTime(date.year, date.month, date.day).millisecondsSinceEpoch,
      'secondValue': DateTime(date.year, date.month, date.day, date.hour,
              date.minute, date.second, date.millisecond)
          .millisecondsSinceEpoch,
      'appointmentTimestamp': DateTime(date.year, date.month, date.day,
          date.hour, date.minute, date.second, date.millisecond),
      'utcTime': date.toString(),
      'consultChat': 0,
      'userChat': 0,
      'callCost': 0.0,
      'isUtc': true,
      'orderId': orderId,
      'callPrice': callPrice,
      'consult': {
        'uid': consultant.uid,
        'name': consultant.name,
        'image': consultant.photoUrl,
        'phone': consultant.phoneNumber,
        'countryCode': consultant.countryCode,
        'countryISOCode': consultant.countryISOCode,
      },
      'user': {
        'uid': loggedUser.uid,
        'name': loggedUser.name,
        'image': loggedUser.photoUrl,
        'phone': loggedUser.phoneNumber,
        'countryCode': loggedUser.countryCode,
        'countryISOCode': loggedUser.countryISOCode,
      },
      'date': {
        'day': date.day,
        'month': date.month,
        'year': date.year,
      },
      'time': {
        'hour': date.hour,
        'minute': date.minute,
      },
    }).then((value) async {

      await FirebaseFirestore.instance
          .collection(Paths.ordersPath)
          .doc(orderId)
          .set({
        'orderStatus': currentNumber > 1 ? "open" : "completed",
        // 'remainingCallNum': currentNumber > 0 ? currentNumber : 0,
      }, SetOptions(merge: true));
    });

//========================
    todayAppointmentList.removeAt(selectedCard);
    await FirebaseFirestore.instance
        .collection(Paths.consultDaysPath)
        .doc(time + "-" + consultant.uid!)
        .set({
      'todayAppointmentList': todayAppointmentList,
    }, SetOptions(merge: true));

    selectedCard = -1;

    if (autoBack == true) {
      Navigator.pop(context);
    }
    showAddedAppointmentDialog(
        size: MediaQuery.of(context).size, date: date, context: context);
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
      'payUrl': '',
      'phone': loggedUser == null ? " " : loggedUser.phoneNumber,
      'screen': "ConsultantDetailsScreen",
      'function': "addAppointment",
    });
  }
}

showAddedAppointmentDialog(
    {required Size size,
    required DateTime date,
    required BuildContext context}) {
  // DateTime? date;
  var formatter = getTranslated(context, 'lang') == 'ar'
      ? DateFormat.yMMMd('ar_SA').add_jm()
      : DateFormat('MMM d, h:mm a');
  print(formatter.locale);
  String formattedDate =
      formatter.format(DateTime.parse(date.toString()).toLocal());

  return showDialog(
    builder: (context) => DreamDialogsWidget(
      padBottom: 0,
      padLeft: 0,
      padRight: 0,
      padTop: 0,
      raduis: AppRadius.r21_3.r,
      dialogContent: Container(
        // height: AppSize.h305_3.w,
        width: AppSize.w441_3.w,
        padding: EdgeInsets.symmetric(
            vertical: AppPadding.p32.h, horizontal: AppPadding.p32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                // SizedBox(height: AppSize.h26.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Image.asset(
                        AssetsManager.black_cancel_iconPath,
                        color: AppColors.pureBlack,
                        width: AppSize.w32.w,
                        height: AppSize.w32.w,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getTranslated(context, "appointConfirm"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: AppSize.h1_8.h,
                        fontFamily: getTranslated(context, 'Ithra'),
                        fontSize: AppFontsSizeManager.s32.sp,
                        color: AppColors.linear2,
                        fontStyle: FontStyle.normal,
                        fontWeight: AppFontsWeightManager.bold,
                      ),
                    ),
                    SizedBox(
                      height: AppSize.w13_3.w,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getTranslated(context, "appointmentRegister"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithralight'),
                        fontSize: convertPtToPx(AppFontsSizeManager.s16.sp),
                        color: AppColors.black,
                        // fontWeight: AppFontsWeightManager.bold,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSize.h13_3.h),
                Text(
                  //"10Aug -01:00",
                  formattedDate,
                  // DateTime.parse(date.toString()).toLocal().toString(),
                  // '${new DateFormat('MMM d, h:mm a').format(DateTime.parse(date.toString()).toLocal())}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: getTranslated(context, 'Montserrat-Bold'),
                    fontSize: convertPtToPx(AppFontsSizeManager.s16.sp),
                    color: AppColors.linear2,
                    fontStyle: FontStyle.normal,
                    fontWeight: AppFontsWeightManager.bold,
                  ),
                ),
                SizedBox(
                    height: convertPtToPx(
                  AppSize.h16.h,
                )),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  child: Container(
                    width: double.infinity,
                    height: convertPtToPx(AppSize.h42.h),
                    //   alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            AppColors.Gradient_Color1,
                            AppColors.Gradient_Color2
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter),
                      borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                      // border: Border.all(
                      //   color: AppColors.linear2,
                      // ),
                    ),
                    child: Center(
                      child: Text(
                        getTranslated(context, 'Ok'),
                        style: TextStyle(
                          fontFamily: getTranslated(context, 'Ithra'),
                          fontSize: AppFontsSizeManager.s18_6.sp,
                          color: AppColors.white1,
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
    barrierDismissible: false,
    context: context,
  );
}
