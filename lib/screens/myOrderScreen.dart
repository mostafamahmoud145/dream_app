import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/order.dart';
import 'package:grocery_store/models/setting.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/orderListItem.dart';

import '../FireStorePagnation/paginate_firestore.dart';
import '../config/colorsFile.dart';
import '../widget/back_button.dart';
import '../widget/tab_bar/custom_tab_bar.dart';
import '../widget/tab_bar/tab_bar_button.dart';

class MyOrdersScreen extends StatefulWidget {
  final GroceryUser user;
  final String? loggedType;
  final bool? fromSupport;

  const MyOrdersScreen(
      {Key? key, required this.user, this.loggedType, this.fromSupport})
      : super(key: key);

  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController searchController = new TextEditingController();
  bool load = false, open = true, closed = false, summary = false;
  late String lang, userImage, theme;
  String name = "";
  late Query filterQuery;
  late String from, to;
  DateTime selectedFromDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();
  bool loadingNumber = false, loadingEarn = false;
  late String filterEarn, filterOrders;

  @override
  void initState() {
    super.initState();
    from = "From";
    to = "To";
    filterEarn = "0";
    filterOrders = "0";
    theme = "";
  }

  @override
  void didChangeDependencies() {
    getThemeName().then((theme) {
      setState(() {
        this.theme = theme;
      });
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
                width: size.width,
                child: Padding(
                  padding: EdgeInsets.only(
                      right: AppPadding.p32.w,
                      left: lang == "ar" ? AppPadding.p0 : AppPadding.p32.w,
                      top: AppPadding.p16.h,
                      bottom: AppPadding.p16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomBackButton(),

                      // IconButton1(
                      //   radius: AppRadius.r10_6.r,
                      //   color: AppColors.white,
                      //   shadowcolor: AppColors.warmPurple,
                      //   iconsize: AppSize.w50.r,
                      //   icon: lang=="ar"? AssetsManager.purple_right_arrowPath:AssetsManager.purple_left_arrowPath,
                      //   iconcolor: AppColors.linear2,
                      //   onPress: () {
                      //     Navigator.pop(context);
                      //   },
                      //   width: AppSize.w50.w,
                      //   height: AppSize.h50.h,
                      // ),
                      SizedBox(width: AppSize.w21_3.w),
                      Text(
                        getTranslated(context, "orders"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithra'),
                            fontSize: AppFontsSizeManager.s21_3.sp,
                            color: AppColors.pureBlack.withOpacity(0.8),
                            fontWeight: AppFontsWeightManager.bold),
                      ),
                    ],
                  ),
                )),
            Container(
              color: AppColors.lightGray,
              height: AppSize.h1.h,
              width: double.infinity,
            ),
            SizedBox(
              height: AppSize.h32.h,
            ),

            ///------------------------Tab Bar for orders -------------------------///

            CustomTabBar(
              // margin: EdgeInsets.symmetric(horizontal: AppMargin.m21.w),
              buttons: [
                TabBarButton(
                  width: AppSize.w162_6.w,
                  isSelected: open,
                  text: getTranslated(context, "openOrders"),
                  function: () {
                    setState(() {
                      open = true;
                      closed = false;
                      summary = false;
                    });
                  },
                ),
                TabBarButton(
                  width: AppSize.w162_6.w,
                  isSelected: closed,
                  text: getTranslated(context, "closedOrders"),
                  function: () {
                    setState(() {
                      closed = true;
                      open = false;
                      summary = false;
                    });
                  },
                ),
                TabBarButton(
                  width: AppSize.w162_6.w,
                  isSelected: summary,
                  text: getTranslated(context, "summary"),
                  function: () {
                    setState(() {
                      closed = false;
                      open = false;
                      summary = true;
                    });
                  },
                ),
              ],
            ),

            SizedBox(
              height: AppSize.h32.h,
            ),

            // Padding(
            //   padding:
            //       const EdgeInsets.only(top: 20, right:10, left: 10, bottom: AppPadding.p20),
            //   child: Container(
            //     width: 509.3.w,
            //     height: 58.6.h,
            //     decoration: BoxDecoration(
            //       color: HexColor('faf5f9'),
            //       borderRadius: BorderRadius.circular(10.6),
            //     ),
            //     child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         children: [
            //           InkWell(
            //             splashColor: Colors.green.withOpacity(0.6),
            //             onTap: () {
            //               setState(() {
            //                 open = true;
            //                 closed = false;
            //                 summary = false;
            //               });
            //             },
            //             child: Container(
            //               height: 41.h,
            //               width: 153.w,
            //               decoration: BoxDecoration(
            //                 color: open
            //                     ? theme == "light"
            //                         ? Theme.of(context).primaryColor
            //                         : HexColor('faf5f9')
            //                     : HexColor('faf5f9'),
            //                 borderRadius: BorderRadius.circular(5.0),
            //               ),
            //               child: Center(
            //                 child: Text(
            //                   getTranslated(context, "openOrders"),
            //                   textAlign: TextAlign.center,
            //                   style: TextStyle(
            //                     fontFamily: getTranslated(context, "Ithra"),
            //                     color: open
            //                         ? theme == "light"
            //                             ? AppColors.white
            //                             : AppColors.white
            //                         : theme == "light"
            //                             ? Theme.of(context).primaryColor
            //                             : AppColors.pureBlack,
            //                     fontSize: 21.0.sp,
            //                     fontWeight: FontWeight.bold,
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //           InkWell(
            //             splashColor: Colors.green.withOpacity(0.6),
            //             onTap: () {
            //               setState(() {
            //                 closed = true;
            //                 open = false;
            //                 summary = false;
            //               });
            //             },
            //             child: Container(
            //               height: 41.h,
            //               width: 153.w,
            //               decoration: BoxDecoration(
            //                 color: closed
            //                     ? theme == "light"
            //                         ? AppColors.pink
            //                         : HexColor('faf5f9')
            //                     : HexColor('faf5f9'),
            //                 borderRadius: BorderRadius.circular(5.0),
            //               ),
            //               child: Center(
            //                 child: Text(
            //                   getTranslated(context, "closedOrders"),
            //                   textAlign: TextAlign.center,
            //                   style: TextStyle(
            //                     fontFamily: getTranslated(context, "Ithra"),
            //                     color: closed
            //                         ? theme == "light"
            //                             ? AppColors.white
            //                             : AppColors.white
            //                         : theme == "light"
            //                             ? Theme.of(context).primaryColor
            //                             : AppColors.pureBlack,
            //                     fontSize: 21.0.sp,
            //                     fontWeight: FontWeight.bold,
            //                     letterSpacing: 0.3,
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //           InkWell(
            //             splashColor: Colors.green.withOpacity(0.6),
            //             onTap: () {
            //               setState(() {
            //                 closed = false;
            //                 open = false;
            //                 summary = true;
            //               });
            //             },
            //             child: Container(
            //               height: 41.h,
            //               width: 153.w,
            //               decoration: BoxDecoration(
            //                 color: summary
            //                     ? theme == "light"
            //                         ? Theme.of(context).primaryColor
            //                         : HexColor('faf5f9')
            //                     : HexColor('faf5f9'),
            //                 borderRadius: BorderRadius.circular(5.0),
            //               ),
            //               child: Center(
            //                 child: Text(
            //                   getTranslated(context, "summary"),
            //                   textAlign: TextAlign.center,
            //                   style: TextStyle(
            //                     fontFamily: getTranslated(context, "Ithra"),
            //                     color: summary
            //                         ? theme == "light"
            //                             ? AppColors.white
            //                             : AppColors.white
            //                         : theme == "light"
            //                             ? Theme.of(context).primaryColor
            //                             : AppColors.pureBlack,
            //                     fontSize: 21.0.sp,
            //                     fontWeight: FontWeight.bold,
            //                     letterSpacing: 0.3,
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ]),
            //   ),
            // ),

            open
                ? Expanded(
                    child: PaginateFirestore(
                      itemBuilderType: PaginateBuilderType.listView,
                      //padding: const EdgeInsets.only( left: 16.0, right: 16.0, bottom: 16.0, top: AppPadding.p16),//Change types accordingly
                      itemBuilder: (context, documentSnapshot, index) {
                        return OrderListItem(
                          order: Orders.fromMap(
                              documentSnapshot[index].data() as Map),
                          type: widget.loggedType!,
                          //widget.user.userType,//.user.userType
                          fromSupport: widget.fromSupport!,
                        );
                      },
                      query: widget.user.userType == AppConstants.consultant
                          ? FirebaseFirestore.instance
                              .collection(Paths.ordersPath)
                              .where('consult.uid', isEqualTo: widget.user.uid)
                              .where('orderStatus', whereIn: [
                              "open",
                              "completed"
                            ]).orderBy('orderTimestamp', descending: true)
                          : FirebaseFirestore.instance
                              .collection(Paths.ordersPath)
                              .where('user.uid', isEqualTo: widget.user.uid)
                              .where('orderStatus', whereIn: [
                              "open",
                              "completed"
                            ]).orderBy('orderTimestamp', descending: true),
                      isLive: true,
                    ),
                  )
                : SizedBox(),
            closed
                ? Expanded(
                    child: PaginateFirestore(
                      itemBuilderType: PaginateBuilderType.listView,
                      //padding: const EdgeInsets.only( left: 16.0, right: 16.0, bottom: 16.0, top: AppPadding.p16),//Change types accordingly
                      itemBuilder: (context, documentSnapshot, index) {
                        return OrderListItem(
                          order: Orders.fromMap(
                              documentSnapshot[index].data() as Map),
                          type: widget.loggedType!, //widget.user.userType,
                          fromSupport: widget.fromSupport!,
                        );
                      },
                      query: widget.user.userType == AppConstants.consultant
                          ? FirebaseFirestore.instance
                              .collection(Paths.ordersPath)
                              .where('consult.uid', isEqualTo: widget.user.uid)
                              .where('orderStatus', isEqualTo: "closed")
                              .orderBy('orderTimestamp', descending: true)
                          : FirebaseFirestore.instance
                              .collection(Paths.ordersPath)
                              .where('user.uid', isEqualTo: widget.user.uid)
                              .where('orderStatus', isEqualTo: "closed")
                              .orderBy('orderTimestamp', descending: true),
                      isLive: true,
                    ),
                  )
                : SizedBox(),
            summary
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      AssetsManager.dollerSvg,
                                      width: AppSize.w26_6.r,
                                      height: AppSize.h26_6.r,
                                    ),
                                    SizedBox(
                                      width: AppSize.w16.w,
                                    ),
                                    Text(
                                      getTranslated(context, "balance"),
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                          fontFamily: getTranslated(
                                              context, 'Ithralight'),
                                          fontWeight: FontWeight.normal,
                                          color: AppColors.pureBlack,
                                          fontSize:
                                              AppFontsSizeManager.s21_3.sp),
                                    ),
                                  ],
                                ),
                                Text(
                                  widget.user.balance == null
                                      ? '0'
                                      : double.parse(widget.user.balance
                                                  .toString())
                                              .toStringAsFixed(3) +
                                          "\$",
                                  style: TextStyle(
                                    fontFamily:
                                        getTranslated(context, 'Ithralight'),
                                    color: theme == "light"
                                        ? AppColors.black1
                                        : AppColors.white,
                                    fontSize: AppFontsSizeManager.s21_3.sp,
                                    // fontWeight: AppFontsWeightManager.bold600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: AppSize.h28.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    Image.asset(
                                        AssetsManager.write_note_iconPath,
                                        width: AppSize.w26_6.r,
                                        height: AppSize.h26_6.r),
                                    SizedBox(
                                      width: AppSize.w16.w,
                                    ),
                                    Text(
                                      getTranslated(context, "ordersNum"),
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                        color: theme == "light"
                                            ? AppColors.pureBlack
                                            : AppColors.white,
                                        fontSize: AppFontsSizeManager.s21_3.sp,
                                        // fontWeight:
                                        //     AppFontsWeightManager.bold500,
                                        fontFamily: getTranslated(
                                            context, 'Ithralight'),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  widget.user.ordersNumbers == null
                                      ? '0'
                                      : widget.user.ordersNumbers.toString(),
                                  style: TextStyle(
                                    color: theme == "light"
                                        ? AppColors.black1
                                        : AppColors.white,
                                    fontFamily:
                                        getTranslated(context, 'Ithralight'),
                                    fontSize: AppFontsSizeManager.s21_3.sp,
                                    //fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: AppSize.h28.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    Image.asset(
                                        AssetsManager.solar_hand_money_iconPath,
                                        width: AppSize.w26_6.r,
                                        height: AppSize.h26_6.r),
                                    SizedBox(
                                      width: AppSize.w16.w,
                                    ),
                                    Text(
                                      widget.user.userType == AppConstants.user
                                          ? getTranslated(context, "payed")
                                          : getTranslated(context, "totalEarn"),
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                        color: theme == "light"
                                            ? AppColors.black1
                                            : AppColors.white,
                                        fontSize: AppFontsSizeManager.s21_3.sp,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: getTranslated(
                                            context, 'Ithralight'),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  widget.user.payedBalance == null
                                      ? "0"
                                      : double.parse(widget.user.payedBalance
                                                  .toString())
                                              .toStringAsFixed(2) +
                                          "\$",
                                  style: TextStyle(
                                    fontFamily:
                                        getTranslated(context, 'Ithralight'),
                                    color: theme == "light"
                                        ? AppColors.black1
                                        : AppColors.white,
                                    fontSize: AppFontsSizeManager.s21_3.sp,
                                    //fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: AppPadding.p42_6.h),
                          child: Center(
                              child: Container(
                                  color: AppColors.lightGrey,
                                  height: AppSize.h2_3.h,
                                  width: size.width * AppSize.w0_9)),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AssetsManager.event_note_iconPath,
                              width: AppSize.w26_6.r,
                              height: AppSize.h26_6.r,
                            ),
                            SizedBox(
                              width: AppSize.w10_6.w,
                            ),
                            Text(
                              getTranslated(context, "filterByDate"),
                              style: TextStyle(
                                color: theme == "light"
                                    ? Theme.of(context).primaryColor
                                    : AppColors.white,
                                fontSize: AppFontsSizeManager.s21_3.sp,
                                //fontWeight: AppFontsWeightManager.bold700,
                                fontFamily: getTranslated(context, 'Ithra'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: AppSize.h30_6.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              getTranslated(context, "from"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: getTranslated(context, 'Ithra'),
                                color: Theme.of(context).primaryColor,
                                fontSize: AppFontsSizeManager.s21_3.sp,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: AppSize.w10_6.w,
                            ),
                            Expanded(
                              child: InkWell(
                                splashColor: AppColors.white.withOpacity(0.6),
                                onTap: () {
                                  _selectFromDate(context);
                                },
                                child: Container(
                                  height: AppSize.h46_6.h,
                                  // width: size.width,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.grey,
                                      //                   <--- border color
                                      width: AppSize.w1.w,
                                    ),
                                    color: AppColors.white,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.r5_3.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      from,
                                      style: TextStyle(
                                          fontFamily: getTranslated(
                                              context, 'Ithralight'),
                                          fontSize:
                                              AppFontsSizeManager.s18_6.sp),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: AppSize.w21_3.w,
                            ),
                            Text(
                              getTranslated(context, "to"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: getTranslated(context, 'Ithra'),
                                color: Theme.of(context).primaryColor,
                                fontSize: AppFontsSizeManager.s21_3.sp,
                                fontWeight: AppFontsWeightManager.bold700,
                              ),
                            ),
                            SizedBox(
                              width: AppSize.w10_6.w,
                            ),
                            Expanded(
                              child: InkWell(
                                splashColor: AppColors.white.withOpacity(0.6),
                                onTap: () {
                                  _selectToDate(context);
                                },
                                child: Container(
                                  height: AppSize.h46.h,
                                  // width: ,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.grey,
                                      //                   <--- border color
                                      width: AppSize.w1.w,
                                    ),
                                    color: AppColors.white,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.r5_3.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      to,
                                      style: TextStyle(
                                          fontFamily: getTranslated(
                                              context, 'Ithralight'),
                                          fontSize:
                                              AppFontsSizeManager.s18_6.sp),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: AppSize.h32.h,
                        ),
                        //pb
                        Container(
                          height: AppSize.h58_6.h,
                          width: lang == "ar" ? AppSize.w244.w : AppSize.w244.w,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    AppColors.Gradient_Color1,
                                    AppColors.Gradient_Color2
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r10_6.r)),
                          child: InkWell(
                            onTap: () {
                              calculateOrderNumbers();
                              if (widget.user.userType == AppConstants.user)
                                setState(() {
                                  loadingEarn = false;
                                });
                              else
                                calculateTotalEarn();
                            },

                            // color: theme == "light"
                            //     ? Theme.of(context).primaryColor
                            //     : AppColors.pureBlack,

                            child: Center(
                              child: Text(
                                getTranslated(context, "results"),
                                style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  color: AppColors.white1,
                                  fontSize: AppFontsSizeManager.s21_3.sp,
                                  //fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: AppSize.h42_6.h,
                        ),
                        (loadingNumber == false && loadingEarn == false)
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Expanded(
                                    child: InkWell(
                                      splashColor: Colors.blue.withOpacity(0.3),
                                      onTap: () {},
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: AppPadding.p32.w,
                                            vertical: AppPadding.p32.h),
                                        // width: AppSize.w170.r,
                                        height: AppSize.h149_3.h,
                                        decoration: BoxDecoration(
                                          color: AppColors.lightGreyBlue,
                                          // boxShadow: [
                                          //   AppShadow.primaryShadow
                                          // ],
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.r21_3.r),
                                        ),
                                        child: Center(
                                          child: Column(
                                            children: <Widget>[
                                              Text(
                                                getTranslated(
                                                    context, "ordersNum"),
                                                overflow: TextOverflow.clip,
                                                style: TextStyle(
                                                  fontFamily: getTranslated(
                                                      context, 'Ithra'),
                                                  color: AppColors.linear2,
                                                  fontSize: AppFontsSizeManager
                                                      .s21_3.sp,
                                                  // fontWeight:
                                                  //     AppFontsWeightManager
                                                  //         .bold500,
                                                ),
                                              ),
                                              SizedBox(
                                                height: AppSize.h21_3.h,
                                              ),
                                              Text(
                                                filterOrders,
                                                style: TextStyle(
                                                  height: AppSize.h1_5.h,
                                                  fontFamily: getTranslated(
                                                      context, 'Ithra'),
                                                  color: AppColors.black1,
                                                  fontSize: AppFontsSizeManager
                                                      .s24.sp,
                                                  fontWeight:
                                                      AppFontsWeightManager
                                                          .bold,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: AppSize.w21_3.w,
                                  ),
                                  Expanded(
                                    child: Material(
                                      child: InkWell(
                                        // splashColor:
                                        //     Colors.blue.withOpacity(0.3),
                                        onTap: () {},
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: AppPadding.p32.w,
                                              vertical: AppPadding.p32.h),
                                          //  width: AppSize.w359.r,
                                          height: AppSize.h149_3.h,
                                          decoration: BoxDecoration(
                                            color: AppColors.lightGreyBlue,
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.r21_3.r),
                                            // boxShadow: [
                                            //   AppShadow.primaryShadow
                                            // ],
                                          ),
                                          child: Center(
                                            child: Column(
                                              children: <Widget>[
                                                Text(
                                                  getTranslated(
                                                      context, "totalEarn"),
                                                  overflow: TextOverflow.clip,
                                                  style: TextStyle(
                                                    fontFamily: getTranslated(
                                                        context, 'Ithra'),
                                                    color: AppColors.linear2,
                                                    fontSize:
                                                        AppFontsSizeManager
                                                            .s21_3.sp,
                                                    // fontWeight:
                                                    //     AppFontsWeightManager
                                                    //         .bold500,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: AppSize.h21_3.h,
                                                ),
                                                Text(
                                                  "\$" + filterEarn,
                                                  style: TextStyle(
                                                    height: AppSize.h1_5.h,
                                                    fontFamily: getTranslated(
                                                        context, 'Ithra'),
                                                    color: AppColors.black1,
                                                    fontSize:
                                                        AppFontsSizeManager
                                                            .s24.sp,
                                                    fontWeight:
                                                        AppFontsWeightManager
                                                            .bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Center(child: CircularProgressIndicator()),
                        SizedBox(
                          height: AppSize.h15,
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  calculateOrderNumbers() async {
    setState(() {
      loadingNumber = true;
    });
    QuerySnapshot querySnapshot;
    if (widget.user.userType == AppConstants.user)
      querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.ordersPath)
          .where('user.uid', isEqualTo: widget.user.uid)
          .where('orderTimeValue',
              isGreaterThanOrEqualTo: selectedFromDate.millisecondsSinceEpoch)
          .where('orderTimeValue',
              isLessThanOrEqualTo: selectedToDate.millisecondsSinceEpoch)
          .get();
    else
      querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.ordersPath)
          .where('consult.uid', isEqualTo: widget.user.uid)
          .where('orderTimeValue',
              isGreaterThanOrEqualTo: selectedFromDate.millisecondsSinceEpoch)
          .where('orderTimeValue',
              isLessThanOrEqualTo: selectedToDate.millisecondsSinceEpoch)
          .get();

    if (querySnapshot.docs.length > 0) {
      if (widget.user.userType == AppConstants.user) {
        double total = 0;
        for (var item in querySnapshot.docs) {
          total = total + double.parse(item['price'].toString());
        }
        setState(() {
          filterEarn = double.parse(total.toString()).toStringAsFixed(3);
          loadingEarn = false;
        });
      }
      setState(() {
        filterOrders = querySnapshot.docs.length.toString();
        loadingNumber = false;
      });
    } else {
      setState(() {
        filterOrders = "0";
        loadingNumber = false;
      });
    }
  }

  calculateTotalEarn() async {
    setState(() {
      loadingEarn = true;
    });

    //update consultbalance
    DocumentReference docRef = FirebaseFirestore.instance
        .collection(Paths.settingPath)
        .doc("pzBqiphy5o2kkzJgWUT7");

    final DocumentSnapshot taxDocumentSnapshot = await docRef.get();
    var taxes = Setting.fromMap(taxDocumentSnapshot.data() as Map).taxes;
    dynamic taxesvalue = (100 - taxes) / 100;

    dynamic totalPrice = 0;
    QuerySnapshot querySnapshotOfOrder = await FirebaseFirestore.instance
        .collection(Paths.ordersPath)
        .where('consult.uid', isEqualTo: widget.user.uid)
        .where('orderTimeValue',
            isGreaterThanOrEqualTo: selectedFromDate.millisecondsSinceEpoch)
        .where('orderTimeValue',
            isLessThanOrEqualTo: selectedToDate.millisecondsSinceEpoch)
        .get();

    if (querySnapshotOfOrder.docs.length > 0) {
      for (var item in querySnapshotOfOrder.docs) {
        totalPrice = totalPrice + double.parse(item['callPrice'].toString());
      }
      setState(() {
        filterEarn = double.parse((totalPrice * taxesvalue).toString())
            .toStringAsFixed(3);
        loadingEarn = false;
      });
    } else {
      setState(() {
        filterEarn = "0";
        loadingEarn = false;
      });
    }

    /*   double total = 0;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Paths.payHistoryPath)
        .where('consultUid', isEqualTo: widget.user.uid)
        .where('payDate', isGreaterThanOrEqualTo: selectedFromDate.millisecondsSinceEpoch)
        .where('payDate', isLessThanOrEqualTo: selectedToDate.millisecondsSinceEpoch)
        .get();
    if (querySnapshot.docs.length > 0) {
      for (var item in querySnapshot.docs) {
        total = total + double.parse(item['balance'].toString());
      }
      setState(() {
        filterEarn = total.toString() + "\$";
        loadingEarn = false;
      });
    } else {
      setState(() {
        filterEarn = "0";
        loadingEarn = false;
      });
    }*/
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedFromDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedFromDate)
      setState(() {
        selectedFromDate = picked;
        from = selectedFromDate.toString().substring(0, 10);
      });
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedToDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedToDate)
      setState(() {
        selectedToDate = picked;
        to = selectedToDate.toString().substring(0, 10);
      });
  }
}
