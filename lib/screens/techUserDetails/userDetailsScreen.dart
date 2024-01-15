import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/SupportList.dart';
import 'package:grocery_store/models/consultPackage.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/techUserDetails/userAppointmentScreen.dart';
import 'package:grocery_store/widget/processing_dialog.dart';

import '../../config/app_fonts.dart';
import '../../config/assets_manager.dart';
import '../myOrderScreen.dart';
import '../supportMessagesScreen.dart';

class UserDetailsScreen extends StatefulWidget {
  final GroceryUser user;
  final GroceryUser loggedUser;

  const UserDetailsScreen(
      {Key? key, required this.user, required this.loggedUser})
      : super(key: key);

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late int localFrom, localTo;
  String languages = "",
      workDays = "",
      workDaysValue = "",
      from = "",
      to = "",
      lang = "",
      theme = "light";
  final TextEditingController callNumController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController displayController = TextEditingController();
  String dayNow = DateTime.now().weekday.toString();
  int timeNow = DateTime.now().hour;
  final TextEditingController searchController = new TextEditingController();
  List<consultPackage> packages = [];
  bool first = true,
      saving = false,
      load = false,
      activeValue = false,
      activeUser = false,
      accept = false;
  late consultPackage package;
  bool avaliable = false, delete = false, chating = false;

  @override
  void initState() {
    super.initState();
    if (widget.user.userType == AppConstants.consultant) getConsultPackages();

    if (widget.user.userType == AppConstants.consultant &&
        widget.user.languages!.length > 0)
      widget.user.languages!.forEach((element) {
        languages = languages + " " + element;
      });
  }

  @override
  void didChangeDependencies() {
    if (widget.user.userType == AppConstants.consultant &&
        first &&
        widget.user.workDays!.length > 0) {
      if (widget.user.fromUtc != null && widget.user.toUtc != null) {
        localFrom = DateTime.parse(widget.user.fromUtc!).toLocal().hour;
        localTo = DateTime.parse(widget.user.toUtc!).toLocal().hour;
        if (localFrom <= timeNow && localTo > timeNow) {
          avaliable = true;
        }
        if (widget.user.workTimes!.length > 0) {
          if (localFrom == 12)
            from = "12 PM";
          else if (localFrom == 0)
            from = "12 AM";
          else if (localFrom > 12)
            from = ((localFrom) - 12).toString() + " PM";
          else
            from = (localFrom).toString() + " AM";
        }
        if (widget.user.workTimes!.length > 0) {
          if (localTo == 12)
            to = "12 PM";
          else if (localTo == 0)
            to = "12 AM";
          else if (localTo > 12)
            to = ((localTo) - 12).toString() + " PM";
          else
            to = (localTo).toString() + " AM";
        }
      }
      //========
      workDays = "";
      if (widget.user.workDays!.contains("1")) {
        workDays = workDays + getTranslated(context, "monday") + ",";
      }
      if (widget.user.workDays!.contains("2")) {
        workDays = workDays + getTranslated(context, "tuesday") + ",";
      }
      if (widget.user.workDays!.contains("3")) {
        workDays = workDays + getTranslated(context, "wednesday") + ",";
      }
      if (widget.user.workDays!.contains("4")) {
        workDays = workDays + getTranslated(context, "thursday") + ",";
      }
      if (widget.user.workDays!.contains("5")) {
        workDays = workDays + getTranslated(context, "friday") + ",";
      }
      if (widget.user.workDays!.contains("6")) {
        workDays = workDays + getTranslated(context, "saturday") + ",";
      }
      if (widget.user.workDays!.contains("7")) {
        workDays = workDays + getTranslated(context, "sunday") + ",";
      }
      setState(() {
        workDaysValue = "";
        workDaysValue = workDays;
        first = false;
      });
    }
    super.didChangeDependencies();
  }

  Future<void> getConsultPackages() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.packagesPath)
          .where(
            'consultUid',
            isEqualTo: widget.user.uid,
          )
          .orderBy("callNum", descending: false)
          .get();
      if (querySnapshot.docs.length > 0) {
        setState(() {
          packages = List<consultPackage>.from(
            querySnapshot.docs.map(
              (snapshot) => consultPackage.fromMap(snapshot.data() as Map),
            ),
          );
        });
      } else
        setState(() {
          packages = [];
        });
    } catch (e) {}
  }

  @override
  void dispose() {
    super.dispose();

    searchController.dispose();
    priceController.dispose();
    discountController.dispose();
    callNumController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    lang = getTranslated(context, "lang");

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.white,
      key: _scaffoldKey,
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: size.width,
              height: AppSize.h200,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                    right: lang == "ar" ? AppPadding.p16 : AppPadding.p10,
                    left: lang == "ar" ? AppPadding.p10 : AppPadding.p16,
                    top: AppPadding.p5,
                    bottom: AppPadding.p16),
                child: Container(
                  width: size.width,
                  height: AppSize.h100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.r50),
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
                              width: AppSize.w38,
                              height: AppSize.h35,
                              child: Icon(
                                Icons.arrow_back,
                                color: theme == "light"
                                    ? AppColors.white
                                    : AppColors.pureBlack,
                                size: AppSize.w24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        getTranslated(context, "details"),
                        style: GoogleFonts.poppins(
                          color: theme == "light"
                              ? AppColors.white
                              : AppColors.pureBlack,
                          fontSize: AppFontsSizeManager.s19.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      chating
                          ? CircularProgressIndicator()
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r50),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: AppColors.white.withOpacity(0.5),
                                  onTap: () {
                                    startChat();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    width: AppSize.w38,
                                    height: AppSize.h35,
                                    child: Icon(
                                      Icons.chat_outlined,
                                      color: theme == "light"
                                          ? AppColors.white
                                          : AppColors.pureBlack,
                                      size: AppSize.w24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppPadding.p10),
                child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: AppSize.h40,
                    ),
                    Center(
                      child: Container(
                        height: AppSize.h200,
                        width: size.width * AppSize.w0_9,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.r25),
                          border: Border.all(
                              color: AppColors.white, width: AppSize.w2),
                          boxShadow: [AppShadow.primaryShadow],
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: AppSize.h50,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r25),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: AppPadding.p10,
                                    right: AppPadding.p10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      getTranslated(context, "bio"),
                                      style: TextStyle(
                                        fontFamily:
                                            getTranslated(context, "Ithra"),
                                        color: theme == "light"
                                            ? AppColors.white
                                            : AppColors.pureBlack,
                                        fontSize: AppFontsSizeManager.s15.sp,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(AppPadding.p10),
                                child: Text(
                                  widget.user.bio == null
                                      ? "..."
                                      : widget.user.bio!,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  maxLines: 4,
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    color: theme == "light"
                                        ? Theme.of(context).primaryColor
                                        : AppColors.pureBlack,
                                    fontSize: AppFontsSizeManager.s14.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    widget.user.userType == AppConstants.user
                        ? SizedBox()
                        : Column(
                            children: [
                              SizedBox(
                                height: AppSize.h20,
                              ),
                              Center(
                                child: Container(
                                  height: AppSize.h35,
                                  width: size.width * AppSize.w0_5,
                                  padding: const EdgeInsets.all(AppPadding.p5),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.r30),
                                  ),
                                  child: Center(
                                    child: Text(
                                      getTranslated(context, "timeOfWork"),
                                      style: TextStyle(
                                        fontFamily:
                                            getTranslated(context, "Ithra"),
                                        color: theme == "light"
                                            ? AppColors.white
                                            : AppColors.pureBlack,
                                        fontSize: AppFontsSizeManager.s13.sp,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing:
                                            AppConstants.letterSpacing,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: AppSize.h20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  //Icon( Icons.calendar_today_outlined,size:30,  color: Theme.of(context).primaryColor,),
                                  Image.asset(
                                    theme == "light"
                                        ? AssetsManager.purple_calender_iconPath
                                        : AssetsManager.grey_calender_iconPath,
                                    width: AppSize.w30,
                                    height: AppSize.h30,
                                  ),
                                  SizedBox(
                                    width: AppSize.w5,
                                  ),
                                  Container(
                                    height: AppSize.h70,
                                    width: size.width * AppSize.w0_8,
                                    padding:
                                        const EdgeInsets.all(AppPadding.p5),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightGrey,
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.r30),
                                    ),
                                    child: Center(
                                      child: Text(
                                        workDaysValue,
                                        textAlign: TextAlign.center,
                                        maxLines: 3,
                                        style: TextStyle(
                                          fontFamily:
                                              getTranslated(context, "Ithra"),
                                          color: theme == "light"
                                              ? Theme.of(context).primaryColor
                                              : AppColors.pureBlack,
                                          fontSize: AppFontsSizeManager.s13.sp,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing:
                                              AppConstants.letterSpacing,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: AppRadius.r20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Icon( Icons.update,size:30,  color: Theme.of(context).primaryColor,),
                                  Image.asset(
                                    theme == "light"
                                        ? AssetsManager.time_circlePath
                                        : AssetsManager.white_time,
                                    width: AppSize.w30,
                                    height: AppSize.h30,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    height: 35,
                                    width: size.width * .3,
                                    padding:
                                        const EdgeInsets.all(AppPadding.p5),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightGrey,
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.r30),
                                    ),
                                    child: Center(
                                      child: Text(
                                        from,
                                        textAlign: TextAlign.center,
                                        maxLines: 3,
                                        style: TextStyle(
                                          fontFamily:
                                              getTranslated(context, "Ithra"),
                                          color: theme == "light"
                                              ? Theme.of(context).primaryColor
                                              : AppColors.pureBlack,
                                          fontSize: AppFontsSizeManager.s15.sp,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing:
                                              AppConstants.letterSpacing,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: AppSize.h35,
                                    width: size.width * AppSize.w0_3,
                                    padding:
                                        const EdgeInsets.all(AppPadding.p5),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightGrey,
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.r30),
                                    ),
                                    child: Center(
                                      child: Text(
                                        to,
                                        textAlign: TextAlign.center,
                                        maxLines: 3,
                                        style: TextStyle(
                                          fontFamily:
                                              getTranslated(context, "Ithra"),
                                          color: theme == "light"
                                              ? Theme.of(context).primaryColor
                                              : AppColors.pureBlack,
                                          fontSize: AppFontsSizeManager.s15.sp,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing:
                                              AppConstants.letterSpacing,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: AppSize.w5,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: AppSize.h30,
                              ),
                              Center(
                                  child: Container(
                                width: size.width * AppSize.w0_9,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.r25),
                                  border: Border.all(
                                      color: AppColors.white,
                                      width: AppSize.w2),
                                  boxShadow: [AppShadow.primaryShadow],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: AppSize.h50,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.r25),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: AppPadding.p10,
                                            right: AppPadding.p10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              getTranslated(
                                                  context, "allPackages"),
                                              style: TextStyle(
                                                fontFamily: getTranslated(
                                                    context, "Ithra"),
                                                color: theme == "light"
                                                    ? AppColors.white
                                                    : AppColors.pureBlack,
                                                fontSize:
                                                    AppFontsSizeManager.s15.sp,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                            /* IconButton(
                                              onPressed: () {
                                                package=new consultPackage();
                                                package.Id=Uuid().v4();
                                                package.price=0;
                                                package.discount=0;
                                                package.callNum=0;
                                                package.active=true;
                                                package.consultUid=widget.user.uid;
                                                packageDialog(size, package);
                                              },
                                              icon: Icon(
                                                Icons.add_circle_outline,
                                                color: theme=="light"?AppColors.white:AppColors.pureBlack,
                                              ),
                                            ),*/
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: AppSize.h10,
                                    ),
                                    Center(
                                      child: packages.length == 0
                                          ? Text(
                                              getTranslated(
                                                  context, "noPackages"),
                                              style: TextStyle(
                                                fontFamily: getTranslated(
                                                    context, "Ithra"),
                                                color: AppColors.black1,
                                                fontSize:
                                                    AppFontsSizeManager.s14,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.3,
                                              ),
                                            )
                                          : ListView.separated(
                                              itemCount: packages.length,
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              padding: const EdgeInsets.all(0),
                                              itemBuilder: (context, index) {
                                                return InkWell(
                                                  splashColor: Colors.red
                                                      .withOpacity(0.5),
                                                  onTap: () {
                                                    packageDialog(
                                                        size, packages[index]);
                                                  },
                                                  child: Container(
                                                      height: AppSize.h50,
                                                      width: size.width,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: AppPadding
                                                                  .p10,
                                                              right: AppPadding
                                                                  .p10),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppColors.lightGrey,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    AppRadius
                                                                        .r25),
                                                        border: Border.all(
                                                            color: Colors
                                                                .grey.shade300,
                                                            width: AppSize.w2),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                            width: size.width *
                                                                AppSize.w0_25,
                                                            child: Text(
                                                              packages[index]
                                                                      .callNum
                                                                      .toString() +
                                                                  packages[
                                                                          index]
                                                                      .type,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    getTranslated(
                                                                        context,
                                                                        "Ithra"),
                                                                color: theme ==
                                                                        "light"
                                                                    ? Theme.of(
                                                                            context)
                                                                        .primaryColor
                                                                    : AppColors
                                                                        .pureBlack,
                                                                fontSize:
                                                                    AppFontsSizeManager
                                                                        .s15.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            height: AppSize.h25,
                                                            width: size.width *
                                                                AppSize.w0_25,
                                                            //padding: const EdgeInsets.all(5),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .lightGreen,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          AppRadius
                                                                              .r25),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                packages[index]
                                                                        .discount
                                                                        .toString() +
                                                                    "%" +
                                                                    getTranslated(
                                                                        context,
                                                                        "discount"),
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      getTranslated(
                                                                          context,
                                                                          "Ithra"),
                                                                  color: AppColors
                                                                      .pureBlack,
                                                                  fontSize:
                                                                      AppFontsSizeManager
                                                                          .s13
                                                                          .sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  letterSpacing:
                                                                      AppConstants
                                                                          .letterSpacing,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            height: AppSize.h35,
                                                            width: size.width *
                                                                AppSize.w0_25,
                                                            padding:
                                                                const EdgeInsets
                                                                        .all(
                                                                    AppRadius
                                                                        .r5),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          AppRadius
                                                                              .r25),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                packages[index]
                                                                        .price
                                                                        .toString() +
                                                                    "\$",
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      getTranslated(
                                                                          context,
                                                                          "Ithra"),
                                                                  color: theme ==
                                                                          "light"
                                                                      ? AppColors
                                                                          .white
                                                                      : AppColors
                                                                          .pureBlack,
                                                                  fontSize:
                                                                      AppFontsSizeManager
                                                                          .s13
                                                                          .sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  letterSpacing:
                                                                      AppConstants
                                                                          .letterSpacing,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      )),
                                                );
                                              },
                                              separatorBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return SizedBox(
                                                  height: 8.0,
                                                );
                                              },
                                            ),
                                    )
                                  ],
                                ),
                              )),
                            ],
                          ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: AppSize.h50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(AppRadius.r25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: AppPadding.p10, right: AppPadding.p10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              getTranslated(context, "allOrders"),
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: theme == "light"
                                    ? AppColors.white
                                    : AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s15.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyOrdersScreen(
                                      user: widget.user,
                                      loggedType: widget.user.userType!,
                                      fromSupport: true,
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.arrow_forward,
                                color: theme == "light"
                                    ? AppColors.white
                                    : AppColors.pureBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: AppSize.h20,
                    ),
                    Container(
                      height: AppSize.h50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(AppRadius.r25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              getTranslated(context, "appointments"),
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: theme == "light"
                                    ? AppColors.white
                                    : AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s15.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UserAppointmentsScreen(
                                      user: widget.user,
                                      loggedUser: widget.loggedUser,
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.arrow_forward,
                                color: theme == "light"
                                    ? AppColors.white
                                    : AppColors.pureBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    widget.user.userType == AppConstants.user
                        ? SizedBox()
                        : Row(
                            children: [
                              Checkbox(
                                value: accept,
                                onChanged: (value) {
                                  setState(() {
                                    accept = !accept;
                                  });
                                },
                              ),
                              Text(
                                getTranslated(context, "convertToUser"),
                                style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  fontSize: AppFontsSizeManager.s18.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                    SizedBox(
                      width: 10,
                    ),
                    widget.user.userType == AppConstants.user
                        ? SizedBox()
                        : saving
                            ? CircularProgressIndicator()
                            : Container(
                                width: AppSize.w50,
                                child: MaterialButton(
                                  padding: const EdgeInsets.all(0.0),
                                  onPressed: () async {
                                    setState(() {
                                      saving = true;
                                    });
                                    if (accept)
                                      await FirebaseFirestore.instance
                                          .collection(Paths.usersPath)
                                          .doc(widget.user.uid)
                                          .update(
                                              {"userType": AppConstants.user});
                                    setState(() {
                                      saving = false;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: AppSize.h35,
                                    width: size.width * .35,
                                    padding: const EdgeInsets.all(AppRadius.r5),
                                    decoration: BoxDecoration(
                                      color: AppColors.pink,
                                      borderRadius: BorderRadius.circular(AppRadius.r30),
                                    ),
                                    child: Center(
                                      child: Text(
                                        getTranslated(context, 'save'),
                                        style: TextStyle(
                                          fontFamily:
                                              getTranslated(context, "Ithra"),
                                          color: AppColors.white,
                                          fontSize: AppFontsSizeManager.s14_5.sp,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                    SizedBox(
                      height: AppSize.h40,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        Positioned(
          right: 0.0,
          top: AppPadding.p130,
          left: 0,
          child: Center(
            child: Container(
              width: size.width * AppSize.w0_9,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                boxShadow: [AppShadow.primaryShadow],
                border: Border.all(color: AppColors.white, width: AppSize.w3),
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(AppRadius.r25),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: AppPadding.p1),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              height: AppSize.h70,
                              width: AppSize.w70,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.pureBlack, width: 3),
                                shape: BoxShape.circle,
                                color: AppColors.white,
                              ),
                              child: widget.user.photoUrl!.isEmpty
                                  ? Icon(
                                      Icons.person,
                                      color: AppColors.pureBlack,
                                      size: AppSize.w50,
                                    )
                                  : ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.r100),
                                      child: FadeInImage.assetNetwork(
                                        placeholder:
                                            AssetsManager.icon_personPath,
                                        placeholderScale: 0.5,
                                        imageErrorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                          Icons.person,
                                          color: AppColors.pureBlack,
                                          size: AppSize.w50,
                                        ),
                                        image: widget.user.photoUrl!,
                                        fit: BoxFit.cover,
                                        fadeInDuration:
                                            Duration(milliseconds: AppConstants.milliseconds250),
                                        fadeInCurve: Curves.easeInOut,
                                        fadeOutDuration:
                                            Duration(milliseconds: AppConstants.milliseconds150),
                                        fadeOutCurve: Curves.easeInOut,
                                      ),
                                    ),
                            ),
                            Positioned(
                              bottom: 5,
                              left: 5.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.r50),
                                child: Material(
                                  color: Theme.of(context).primaryColor,
                                  child: InkWell(
                                    splashColor:
                                        AppColors.white.withOpacity(0.5),
                                    onTap: () {},
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColors.pureBlack,
                                            width: AppSize.w2),
                                        shape: BoxShape.circle,
                                        color: avaliable
                                            ? AppColors.green
                                            : Colors.red,
                                      ),
                                      width: AppSize.w10,
                                      height: AppSize.h10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.user.name!,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: theme == "light"
                                    ? AppColors.white
                                    : AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s15.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.mic_none,
                                  size: AppSize.w15,
                                  color: theme == "light"
                                      ? AppColors.white
                                      : AppColors.pureBlack,
                                ),
                                Text(
                                  languages,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    color: theme == "light"
                                        ? AppColors.white
                                        : AppColors.pureBlack,
                                    fontSize: AppFontsSizeManager.s15.sp,
                                    // fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: AppSize.w13,
                                      color: AppColors.yellow,
                                    ),
                                    Text(
                                      widget.user.rating == null
                                          ? "0"
                                          : widget.user.rating
                                              .toStringAsFixed(1),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontFamily:
                                            getTranslated(context, "Ithra"),
                                        color: theme == "light"
                                            ? AppColors.white
                                            : AppColors.pureBlack,
                                        fontSize: AppFontsSizeManager.s13.sp,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: AppSize.w20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      AssetsManager.green_call_icon_path,
                                      width: AppSize.w15,
                                      height: AppSize.h15,
                                    ),
                                    Text(
                                      widget.user.ordersNumbers == null
                                          ? "0"
                                          : widget.user.ordersNumbers
                                              .toString(),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontFamily:
                                            getTranslated(context, "Ithra"),
                                        color: theme == "light"
                                            ? AppColors.white
                                            : AppColors.pureBlack,
                                        fontSize: AppFontsSizeManager.s15.sp,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            widget.user.price == null
                                ? '0'
                                : widget.user.price! + "\$",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              color: theme == "light"
                                  ? AppColors.white
                                  : AppColors.pureBlack,
                              fontSize: AppFontsSizeManager.s15.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(
                            height: AppSize.h5,
                          ),
                          Container(
                            width: AppSize.w40,
                            height: AppSize.h40,
                            decoration: BoxDecoration(
                                // border: Border.all( color: Colors.red[500],),
                                color: avaliable ? AppColors.green : Colors.red,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(AppRadius.r20))),
                            child: Center(
                              child: avaliable
                                  ? Image.asset(
                                AssetsManager.grey_calling,
                                      width: AppSize.w20,
                                      height: AppSize.h20,
                                    )
                                  : Image.asset(
                                AssetsManager.grey_calling,
                                      width: AppSize.w20,
                                      height: AppSize.h20,
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
        ),
      ]),
    );
  }

  void showNoNotifSnack(String text, bool status) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(7),
      backgroundColor: status ? Colors.green.shade500 : Colors.red.shade500,
      animationDuration: Duration(milliseconds: AppConstants.milliseconds300),
      isDismissible: true,
      boxShadows: [AppShadow.primaryShadow],
      shouldIconPulse: false,
      duration: Duration(milliseconds: AppConstants.milliseconds1500),
      icon: Icon(
        Icons.notification_important,
        color: AppColors.white,
      ),
      messageText: Text(
        '$text',
        style: TextStyle(
          fontFamily: getTranslated(context, "Ithra"),
          fontSize: AppFontsSizeManager.s14.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: AppColors.white,
        ),
      ),
    )..show(context);
  }

  showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: getTranslated(context, "loading"),
        );
      },
    );
  }

  packageDialog(Size size, consultPackage selectedPackage) {
    callNumController.text = selectedPackage.callNum.toString();
    priceController.text = selectedPackage.price.toString();
    discountController.text = selectedPackage.discount.toString();
    activeValue = selectedPackage.active;
    return showDialog(
      builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppRadius.r15),
            ),
          ),
          elevation: 5.0,
          contentPadding: const EdgeInsets.only(
              left: AppPadding.p16,
              right: AppPadding.p16,
              top: AppPadding.p20,
              bottom: AppPadding.p10),
          content: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: AppSize.w5,
                    ),
                    Text(
                      getTranslated(context, "edit"),
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        fontSize: AppFontsSizeManager.s14_5.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        color: AppColors.black1,
                      ),
                    ),
                    InkWell(
                      splashColor: AppColors.white.withOpacity(0.5),
                      onTap: () async {
                        await FirebaseFirestore.instance
                            .collection(Paths.packagesPath)
                            .doc(selectedPackage.Id)
                            .delete();
                        getConsultPackages();
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: AppSize.w24,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: AppSize.h15,
                ),
                Row(
                  children: [
                    Container(
                      width: size.width * AppSize.w0_3,
                      child: Text(
                        getTranslated(context, "call"),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: AppFontsSizeManager.s18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width * AppSize.w0_3,
                      height: AppSize.h40,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppPadding.p10, vertical: AppPadding.p10),
                      decoration: BoxDecoration(
                        color: AppColors.pureBlack.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(AppRadius.r15),
                      ),
                      child: TextFormField(
                        //initialValue: selectedPackage.callNum.toString(),
                        controller: callNumController,
                        keyboardType: TextInputType.number,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        enableInteractiveSelection: true,
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize: AppFontsSizeManager.s14.sp,
                          color: AppColors.black1,
                          letterSpacing: AppConstants.letterSpacing,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: AppPadding.p5, vertical: AppPadding.p8),
                          border: InputBorder.none,
                          hintText: getTranslated(context, "call"),
                          hintStyle: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontSize: AppFontsSizeManager.s14.sp,
                            color: AppColors.black1,
                            letterSpacing: AppConstants.letterSpacing,
                            fontWeight: FontWeight.w400,
                          ),
                          counterStyle: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontSize: AppFontsSizeManager.s12,
                            color: AppColors.black1,
                            letterSpacing: AppConstants.letterSpacing,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: AppSize.h10,
                ),
                Row(
                  children: [
                    Container(
                      width: size.width * AppSize.w0_3,
                      child: Text(
                        getTranslated(context, "discount"),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: AppFontsSizeManager.s18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width * .3,
                      height: 40,
                      padding: const EdgeInsets.symmetric(
                          horizontal:AppPadding.p10, vertical: AppPadding.p10),
                      decoration: BoxDecoration(
                        color: AppColors.pureBlack.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(AppRadius.r15),
                      ),
                      child: TextFormField(
                        //initialValue: selectedPackage.callNum.toString(),
                        controller: discountController,
                        keyboardType: TextInputType.number,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        enableInteractiveSelection: true,
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize:AppFontsSizeManager.s14.sp,
                          color: AppColors.black1,
                          letterSpacing: AppConstants.letterSpacing,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal:AppPadding.p5, vertical: AppPadding.p8),
                          border: InputBorder.none,
                          hintText: getTranslated(context, "discount"),
                          hintStyle: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontSize: AppFontsSizeManager.s14.sp,
                            color: AppColors.black1,
                            letterSpacing: AppConstants.letterSpacing,
                            fontWeight: FontWeight.w400,
                          ),
                          counterStyle: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontSize: AppFontsSizeManager.s12_5.sp,
                            color: AppColors.black1,
                            letterSpacing: AppConstants.letterSpacing,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height:AppSize.h10,
                ),
                Row(
                  children: [
                    Container(
                      width: size.width * AppSize.w0_3,
                      child: Text(
                        getTranslated(context, "price"),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: AppFontsSizeManager.s18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width * .3,
                      height: AppSize.h40,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppPadding.p10, vertical: AppPadding.p10),
                      decoration: BoxDecoration(
                        color: AppColors.pureBlack.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(AppRadius.r15),
                      ),
                      child: TextFormField(
                        //initialValue: selectedPackage.callNum.toString(),
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        enableInteractiveSelection: true,
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize: AppFontsSizeManager.s14.sp,
                          color: AppColors.black1,
                          letterSpacing: AppConstants.letterSpacing,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 5.0, vertical: 8.0),
                          border: InputBorder.none,
                          hintText: getTranslated(context, "price"),
                          hintStyle: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontSize: AppFontsSizeManager.s14_5.sp,
                            color: AppColors.black1,
                            letterSpacing: AppConstants.letterSpacing,
                            fontWeight: FontWeight.w400,
                          ),
                          counterStyle: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontSize: AppFontsSizeManager.s12_5,
                            color: AppColors.black1,
                            letterSpacing: AppConstants.letterSpacing,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: AppSize.h5,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: activeValue,
                      onChanged: (value) {
                        setState(() {
                          activeValue = !activeValue;
                        });
                      },
                    ),
                    Text(
                      getTranslated(context, "active"),
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        fontSize: AppFontsSizeManager.s15.sp,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: AppSize.h15,
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
                        onPressed: () {
                          setState(() {
                            load = false;
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          getTranslated(context, 'cancel'),
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            color: AppColors.black1,
                            fontSize: AppFontsSizeManager.s13_5.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: AppSize.w10,
                    ),
                    saving
                        ? CircularProgressIndicator()
                        : Container(
                            width: AppSize.w50,
                            child: MaterialButton(
                              padding: const EdgeInsets.all(0.0),
                              onPressed: () async {
                                setState(() {
                                  saving = true;
                                });
                                await FirebaseFirestore.instance
                                    .collection(Paths.packagesPath)
                                    .doc(selectedPackage.Id)
                                    .set({
                                  'price': int.parse(priceController.text),
                                  'discount':
                                      int.parse(discountController.text),
                                  'callNum': int.parse(callNumController.text),
                                  'consultUid': widget.user.uid,
                                  'Id': selectedPackage.Id,
                                  'active': activeValue,
                                }, SetOptions(merge: true));
                                getConsultPackages();
                                setState(() {
                                  saving = false;
                                });
                                Navigator.pop(context);
                              },
                              child: Text(
                                getTranslated(context, 'save'),
                                style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  color: Colors.red.shade700,
                                  fontSize: AppFontsSizeManager.s13_5.sp,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            );
          })),
      barrierDismissible: false,
      context: context,
    );
  }

  startChat() async {
    setState(() {
      chating = true;
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("SupportList")
        .where(
          'userUid',
          isEqualTo: widget.user.uid,
        )
        .limit(1)
        .get();
    if (querySnapshot != null && querySnapshot.docs.length != 0) {
      var item = SupportList.fromMap(querySnapshot.docs[0].data() as Map);
      setState(() {
        load = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SupportMessageScreen(item: item, user: widget.loggedUser),
        ),
      );
      setState(() {
        chating = false;
      });
    } else {
      setState(() {
        chating = false;
      });
    }
  }
}
