import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/models/userPaymentHistory.dart';
import 'package:grocery_store/widget/TextButton.dart';
import 'package:grocery_store/widget/dreamDialogsWidget.dart';
import 'package:grocery_store/widget/userPaymentHistoryListItem.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../FireStorePagnation/paginate_firestore.dart';
import '../config/colorsFile.dart';
import '../widget/back_button.dart';
import '../widget/tab_bar/custom_tab_bar.dart';
import '../widget/tab_bar/tab_bar_button.dart';

class WalletScreen extends StatefulWidget {
  final GroceryUser loggedUser;

  const WalletScreen({Key? key, required this.loggedUser}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late AccountBloc accountBloc;
  late GroceryUser user;

  bool load = false, showBalance = true, showHistory = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool saving = false, showPayView = false;
  late GroceryUser searchUser;
  late Size size;
  List<GroceryUser> users = [];
  late String to, amount, balance;
  int? _stackIndex = 1;
  String initialUrl = '';
  String lang = "";

  @override
  void initState() {
    super.initState();
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetLoggedUserEvent());
    accountBloc.stream.listen((state) {
      if (state is GetLoggedUserCompletedState) {
        user = state.user;
        if (mounted)
          setState(() {
            load = false;
          });
        if (user != null &&
            user.photoUrl != null &&
            user.photoUrl != "") if (mounted)
          setState(() {
            balance = user.balance.toString();
          });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            Container(
                width: size.width,
                child: SafeArea(
                    child: Padding(
                  padding: EdgeInsets.only(
                      right: AppPadding.p32.w,
                      left: lang == "ar" ? AppPadding.p0 : AppPadding.p32.w,
                      top: AppPadding.p35.h,
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
                        getTranslated(context, "wallet"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithra'),
                            fontSize: AppFontsSizeManager.s21_3.sp,
                            color: AppColors.pureBlack.withOpacity(0.8),
                            fontWeight: AppFontsWeightManager.bold),
                      ),
                    ],
                  ),
                ))),

            Center(
                child: Container(
                    color: AppColors.lightGrey,
                    height: AppSize.h2_3.h,
                    width: size.width)),

            //
            //SizedBox(height: 32.5.h,),
            Padding(
              padding: EdgeInsets.only(top: AppPadding.p32.h),
              child: Container(
                  height: AppSize.h167_2.h,
                  width: AppSize.w124_6.w,
                  child: SvgPicture.asset(
                    AssetsManager.walletImagePath,
                  )),
            ),
            //SizedBox(height: 42.h,),
            Container(
              width: size.width,
              padding: EdgeInsets.only(
                  left: AppPadding.p68.w,
                  right: AppPadding.p68.w,
                  bottom: AppPadding.p45_3.h,
                  top: AppPadding.p32.h),
              child: Text(
                getTranslated(context, "addBalanceText"),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 3,
                style: TextStyle(
                  fontFamily: getTranslated(context, 'Ithralight'),
                  fontSize: AppFontsSizeManager.s21_3.sp,
                  color: AppColors.greyWallet,
                ),
              ),
            ),

            ///------------------------Tab Bar for add balance & history of balance -------------------------///

            CustomTabBar(
              margin: EdgeInsets.symmetric(horizontal: AppMargin.m32.w),
              buttons: [
                TabBarButton(
                  isSelected: showBalance,
                  text: getTranslated(context, "addBalance"),
                  function: () {
                    setState(() {
                      showBalance = true;
                      showHistory = false;
                    });
                  },
                ),
                TabBarButton(
                  isSelected: showHistory,
                  text: getTranslated(
                    context,
                    "paymentHistory",
                  ),
                  function: () {
                    setState(() {
                      showHistory = true;
                      showBalance = false;
                    });
                  },
                ),
              ],
            ),

            // Center(
            //   child:  Container(height: 75.6.h,width: 509.3.w,
            //
            //       decoration: BoxDecoration(
            //         color: HexColor('faf5f9'),
            //         borderRadius: BorderRadius.circular(12.0.r),
            //
            //       ),
            //       child:Padding(
            //         padding: const EdgeInsets.only(left: 13.3,right: 13.3,bottom: 5.3,top: 5.3),
            //         child: Row(//mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //
            //             children: [
            //               InkWell(
            //                 splashColor: Colors.green.withOpacity(0.6),
            //                 onTap: () {
            //                   setState(() {
            //                     showBalance=true;
            //                     showHistory=false;
            //                   });
            //                 },
            //                 child: Container(height: 41.3.h,width: 148.w,
            //                   decoration: BoxDecoration(
            //                     color: showBalance?Theme.of(context).primaryColor:HexColor('faf5f9'),
            //
            //                   borderRadius: BorderRadius.circular(AppRadius.r5_3.r),
            //                   ),child:Center(
            //                     child: Text(
            //                       getTranslated(context, "addBalance"),
            //                       textAlign: TextAlign.center,
            //                       style: TextStyle( fontFamily: getTranslated(context, "Ithra"), color: showBalance?AppColors.white:Theme.of(context).primaryColor,
            //                         fontSize: AppFontsSizeManager.s21_3.sp,),
            //
            //                     ),
            //                   ),),
            //               ),
            //               SizedBox(width: 116.w,),
            //               InkWell(
            //                 splashColor: Colors.green.withOpacity(0.6),
            //                 onTap: () {
            //                   setState(() {
            //                     showHistory=true;
            //                     showBalance=false;
            //                   });
            //                 },
            //                 child:Container(height: 41.3.h,width: 200.3.w,
            //
            //                   decoration: BoxDecoration(
            //                     color: showHistory?Theme.of(context).primaryColor:HexColor('faf5f9'),
            //                     borderRadius: BorderRadius.circular(AppRadius.r5_3.r),
            //                   ),child:Center(
            //                     child: Text(
            //                       getTranslated(context, "paymentHistory"),
            //                       textAlign: TextAlign.center,
            //                       style: TextStyle( fontFamily: getTranslated(context, "Ithra"), color: showHistory?AppColors.white:Theme.of(context).primaryColor,
            //                         fontSize: AppFontsSizeManager.s21_3.sp,),
            //
            //                     ),
            //                   ),),
            //               ),
            //
            //
            //             ]),
            //       )
            //   ),
            // ),
            /*SizedBox(
              height: 20.0.h,
            ),*/
            showBalance
                ? Expanded(
                    child: ListView(
                        padding: EdgeInsets.only(
                            left: AppPadding.p32.w, right: AppPadding.p32.w),
                        children: <Widget>[
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: AppSize.h45_3.h,
                                ),
                                Text(
                                  getTranslated(
                                    context,
                                    "to",
                                  ),
                                  style: TextStyle(
                                      fontSize: AppFontsSizeManager.s21_3.sp,
                                      fontFamily:
                                          getTranslated(context, 'Ithra'),
                                      color: Theme.of(context).primaryColor),
                                ),
                                SizedBox(
                                  height: AppSize.h21_3.h,
                                ),
                                Container(
                                  width: AppSize.w509_3.w,
                                  height: AppSize.h72.h,
                                  child: Center(
                                    child: TextFormField(
                                        textAlign: TextAlign.start,
                                        enableInteractiveSelection: true,
                                        textAlignVertical:
                                            TextAlignVertical.bottom,
                                        style: TextStyle(
                                          fontFamily: getTranslated(
                                              context, 'Ithralight'),
                                          fontSize:
                                              AppFontsSizeManager.s21_3.sp,
                                          color: AppColors.grey,
                                        ),
                                        cursorColor: AppColors.pink,
                                        keyboardType: TextInputType.phone,
                                        validator: (String? val) {
                                          if (val!.trim().isEmpty) {
                                            return getTranslated(
                                                context, 'required');
                                          }
                                          return null;
                                        },
                                        onSaved: (val) {
                                          to = val!;
                                        },
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: AppPadding.p21_3.h,
                                              horizontal: AppPadding.p22_6.w),
                                          constraints: BoxConstraints(
                                              minHeight: AppSize.h70.h,
                                              maxHeight: AppSize.h70.h),
                                          errorStyle: TextStyle(
                                              fontFamily: getTranslated(
                                                  context, "Ithra"),
                                              // 'Montserrat',
                                              fontSize:
                                                  AppFontsSizeManager.s21_3.sp,
                                              color: AppColors.red,
                                              height: 0.1.w,
                                              fontWeight: FontWeight.normal),
                                          prefixIcon: Padding(
                                            padding: EdgeInsets.all(
                                                AppPadding.p16.r),
                                            child: SvgPicture.asset(
                                              AssetsManager.pinkPhoneIconPath,
                                              height: AppSize.h26_6.h,
                                              width: AppSize.h26_6.h,
                                            ),
                                          ),
                                          hintText: getTranslated(
                                            context,
                                            "enterPhoneNumber",
                                          ),
                                          hintStyle: TextStyle(
                                            color: AppColors.greyWallet2,
                                            fontSize:
                                                AppFontsSizeManager.s21_3.sp,
                                            fontFamily: getTranslated(
                                                context, 'Ithralight'),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.r10_6.r),
                                            borderSide: BorderSide(
                                              color: AppColors.primaryWallet,
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                    158, 158, 158, 1)),
                                            borderRadius:
                                                BorderRadius.circular(7.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.r12.r),
                                            borderSide: BorderSide(
                                              color: AppColors.primaryWallet,
                                              width: AppSize.w1.w,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0.r),
                                            borderSide: BorderSide(
                                              color: AppColors.red,
                                              width: 1.0.w,
                                              //style: BorderStyle.solid,
                                            ),
                                          ),
                                        )),
                                  ),
                                ),
                                SizedBox(
                                  height: AppSize.h32.h,
                                ),
                                Text(
                                  getTranslated(
                                    context,
                                    "amount",
                                  ),
                                  style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, 'Ithra'),
                                      color: Theme.of(context).primaryColor),
                                ),
                                SizedBox(
                                  height: AppSize.h21_3.h,
                                ),
                                Container(
                                  width: AppSize.w509_3.w,
                                  height: AppSize.h72.h,
                                  child: Center(
                                    child: TextFormField(
                                        textAlignVertical:
                                            TextAlignVertical.bottom,
                                        style: TextStyle(
                                          fontFamily: getTranslated(
                                              context, 'Ithralight'),
                                          fontSize:
                                              AppFontsSizeManager.s21_3.sp,
                                          color: AppColors.grey,
                                        ),
                                        cursorColor: AppColors.pink,
                                        keyboardType: TextInputType.number,
                                        validator: (String? val) {
                                          if (val!.trim().isEmpty) {
                                            return getTranslated(
                                                context, 'required');
                                          }
                                          return null;
                                        },
                                        onSaved: (val) {
                                          amount = val!;
                                        },
                                        enableInteractiveSelection: true,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: AppPadding.p21_3.h,
                                              horizontal: AppPadding.p22_6.w),
                                          errorStyle: TextStyle(
                                              fontFamily: getTranslated(
                                                  context, "Ithra"),
                                              // 'Montserrat',
                                              fontSize:
                                                  AppFontsSizeManager.s21_3.sp,
                                              color: AppColors.red,
                                              height: 0.1,
                                              fontWeight: FontWeight.normal),
                                          prefixIcon: Icon(
                                            Icons.attach_money,
                                            color: AppColors.pink,
                                            size: AppSize.w26_6.r,
                                          ),
                                          hintStyle: TextStyle(
                                            color: AppColors.greyWallet2,
                                            fontSize:
                                                AppFontsSizeManager.s21_3.sp,
                                            fontFamily: getTranslated(
                                                context, 'Ithralight'),
                                          ),
                                          hintText: getTranslated(
                                              context, "enterAmaunt"),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.r10_6.r),
                                            borderSide: BorderSide(
                                              color: AppColors.grey,
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                    158, 158, 158, 1)),
                                            borderRadius:
                                                BorderRadius.circular(7.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.r10_6.r),
                                            borderSide: BorderSide(
                                              color: AppColors.primaryWallet,
                                              width: AppSize.w1.w,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0.r),
                                            borderSide: BorderSide(
                                              color: AppColors.red,
                                              width: 1.0.w,
                                              //style: BorderStyle.solid,
                                            ),
                                          ),
                                        )),
                                  ),
                                ),
                                SizedBox(
                                  height: AppSize.h44.h,
                                ),
                                Center(
                                  child: textButton(
                                    onPress: () {
                                      save();
                                      // showSuccessAddingDialog(
                                      //   size,
                                      //   // widget.loggedUser.phoneNumber == to
                                      //   //     ? getTranslated(context, "addBalance")
                                      //   //     : getTranslated(context, "balanceTransfer"),
                                      //   // widget.loggedUser.phoneNumber == to
                                      //   //     ? getTranslated(context, "balanceAdded")
                                      //   //     : getTranslated(context, "balanceTransferred"),
                                      // );

                                      // showAddingBalanceDialoge(size
                                      //     // getTranslated(context, "balanceTransfer"),
                                      //     // getTranslated(context, "SureTransferAmount")
                                      //     );

                                      // showSuccessAddingDialog(
                                      //     // size,
                                      //     // widget.loggedUser.phoneNumber == to
                                      //     //     ?
                                      //     // getTranslated(context, "addBalance"),
                                      //     // // : getTranslated(
                                      //     // //     context, "balanceTransfer"),
                                      //     // widget.loggedUser.phoneNumber == to
                                      //     //     ? getTranslated(
                                      //     //         context, "balanceAdded")
                                      //     //     : getTranslated(
                                      //     //         context, "balanceTransferred"),
                                      //     );
                                    },
                                    text: getTranslated(context, "addCredit"),
                                    width: null,
                                    height: AppSize.h66_6.h,
                                    buttonRadius: AppRadius.r10_6.r,
                                    textSize: AppFontsSizeManager.s21_3.sp,
                                    textfont: getTranslated(context, 'Ithra'),
                                    textcolor: AppColors.white,
                                    Gradient_Color: AppColors.linear12,
                                    Gradient_Color2: AppColors.linear2,
                                    sizeWidth: AppSize.w16.w,
                                    icon: AssetsManager.white_download_iconPath,
                                  ),
                                ),
                                SizedBox(
                                  height: AppSize.h104.h,
                                ),
                              ],
                            ),
                          ),
                        ]),
                  )
                : SizedBox(),
            showHistory
                ? Expanded(
                    child: PaginateFirestore(
                      onEmpty: Text(
                        getTranslated(context, "notFoundPayment"),
                        style: TextStyle(
                          fontFamily: lang == "ar"
                              ? getTranslated(context, "Ithra")
                              : getTranslated(context, "Montserratbold"),
                          fontSize: AppFontsSizeManager.s21_3.sp,
                        ),
                      ),
                      itemBuilderType: PaginateBuilderType.listView,
                      padding: EdgeInsets.only(
                        left: AppPadding.p32.w,
                        right: AppPadding.p32.w,
                        bottom: AppPadding.p6,
                      ),
                      //Change types accordingly
                      itemBuilder: (context, documentSnapshot, index) {
                        return UserPaymentHistoryListItem(
                          history: UserPaymentHistory.fromMap(
                              documentSnapshot[index].data() as Map),
                        );
                      },
                      query: FirebaseFirestore.instance
                          .collection(Paths.userPaymentHistory)
                          .where('userUid', isEqualTo: widget.loggedUser.uid)
                          .orderBy('payDateValue', descending: true),
                      isLive: true,
                    ),
                  )
                : SizedBox(),
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
                          if (request.url
                              .startsWith(AppConstants.startsWithJeras)) {
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
    );
  }

  save() async {
    if (_formKey.currentState!.validate()) {
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
              isEqualTo: to,
            )
            .where(
              'userType',
              isEqualTo: AppConstants.user,
            )
            .get();

        for (var doc in querySnapshot.docs) {
          users.add(GroceryUser.fromMap(doc.data() as Map));
        }
        if (users.length > 0) {
          setState(() {
            searchUser = users[0];
          });
          showAddingBalanceDialoge(
              size,
              getTranslated(context, "balanceTransfer"),
              getTranslated(context, "SureTransferAmount"));
        } else {
          cantAddingDialog(MediaQuery.of(context).size,
              getTranslated(context, "invalidNumbers"), false);
          setState(() {
            saving = false;
          });
        }
      } catch (e) {}
    }
  }

  showAddingBalanceDialoge(Size size, String title, String msg) {
    return showDialog(
      builder: (context) => DreamDialogsWidget(
        padBottom: 0,
        padLeft: 0,
        padRight: 0,
        padTop: 0,
        dialogContent: Container(
          width: AppSize.w441_3.w,
          // height: AppSize.h292.h,
          padding: EdgeInsets.symmetric(
              horizontal: AppPadding.p32.w, vertical: AppPadding.p32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            /*mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,*/
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      AssetsManager.black_cancel_iconPath,
                      width: AppSize.w32.w,
                      height: AppSize.h32.h,
                    ),
                  )
                ],
              ),
              Text(
                title,

                // getTranslated(context, "balanceTransfer"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: AppSize.h1_5.h,
                  fontFamily: getTranslated(context, 'Ithra'),
                  fontSize: AppFontsSizeManager.s32.sp,
                  color: AppColors.linear2,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: AppSize.h13_3.h,
              ),
              Text(
                //  getTranslated(context, "SureTransferAmount") + " 10\$ ",
                msg + " ${amount}\$ ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: getTranslated(context, 'Ithralight'),
                  fontSize: AppFontsSizeManager.s21_3.sp,
                  height: AppSize.h1_5.h,
                  color: AppColors.black4,
                  //fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.normal,
                ),
              ),
              Text(
                getTranslated(context, "toPhone") + " 01144313832 ",
                // getTranslated(context, "toPhone") + " ${to} ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: getTranslated(context, 'Ithralight'),
                  fontSize: AppFontsSizeManager.s21_3.sp,
                  color: AppColors.black4,
                  //fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.normal,
                ),
              ),
              SizedBox(
                height: AppSize.h21_3.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        pay();
                      },
                      child: Container(
                        height: AppSize.h56.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.Gradient_Color1,
                                AppColors.Gradient_Color2,
                              ]),
                          borderRadius:
                              BorderRadius.circular(AppRadius.r10_6.r),
                        ),
                        child: Center(
                          child: Text(
                            getTranslated(context, 'sure'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              fontSize: AppFontsSizeManager.s18_6.sp,
                              color: AppColors.white1,
                              fontStyle: FontStyle.normal,
                              // fontWeight: FontWeight.w700,
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
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(AppRadius.r10_6.r)),
                            border: Border.all(
                              color: AppColors.linear2,
                              width: 1.5.w,
                            )),
                        child: Center(
                          child: Text(
                            getTranslated(context, 'cancel'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              fontSize: AppFontsSizeManager.s18_6.sp,
                              color: AppColors.linear2,
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
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  cantAddingDialog(Size size, String data, bool status) {
    return showDialog(
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.white),
          ),
          child: AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(AppRadius.r21_3.r),
              ),
            ),
            elevation: 5.0,
            contentPadding: EdgeInsets.all(0),
            content: Container(
              padding: EdgeInsets.only(
                  left: AppPadding.p32.w,
                  right: AppPadding.p32.w,
                  top: AppPadding.p32.h,
                  bottom: AppPadding.p32.h),
              width: AppSize.w441_3.w,
              height: AppSize.h282_6.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
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
                    ],
                  ),
                  SvgPicture.asset(
                    AssetsManager.error,
                    width: AppSize.w56.w,
                    height: AppSize.h56.h,
                  ),
                  SizedBox(
                    height: AppSize.h13_3.h,
                  ),
                  Text(
                    data,
                    style: TextStyle(
                      fontFamily: getTranslated(context, 'Ithra'),
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      color: AppColors.black,
                      letterSpacing: 0.3,
                      // fontWeight: FontWeight.w300,
                      // fontStyle: FontStyle.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: AppSize.h30_6.h,
                  ),
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: AppSize.h56.h,

                      //   alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              AppColors.Gradient_Color1,
                              AppColors.Gradient_Color2
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter),
                        // color: AppColors.linear2,

                        borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Center(
                          child: Text(
                            getTranslated(context, 'againTxt'),
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              fontSize: AppFontsSizeManager.s18_6.sp,
                              color: AppColors.white1,
                              //fontWeight: FontWeight.w700,
                              // fontStyle: FontStyle.normal,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      barrierDismissible: false,
      context: context,
    );
  }

  pay() async {
    final uri = Uri.parse('https://api.tap.company/v2/charges');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      //'Authorization':"Bearer sk_test_Opnge3LNhdkXJaCbMwmoy9BS",
      'Authorization': "Bearer sk_live_UN9kc65zvtmrX1PjnagRYhLb",
      'Connection': 'keep-alive',
      'Accept-Encoding': 'gzip, deflate, br'
    };
    Map<String, dynamic> body = {
      "amount": amount,
      "currency": "USD",
      "threeDSecure": true,
      "save_card": true,
      "description": "Test Description",
      "statement_descriptor": "Sample",
      "metadata": {"udf1": "test 1", "udf2": "test 2"},
      "reference": {"transaction": "txn_0001", "order": "ord_0001"},
      "receipt": {"email": false, "sms": true},
      "customer": {
        "id": widget.loggedUser.customerId != null
            ? widget.loggedUser.customerId
            : '',
        "first_name": widget.loggedUser.name,
        "middle_name": ".",
        "last_name": ".",
        "email": widget.loggedUser.name! + "@dream.com",
        "phone": {"country_code": "", "number": widget.loggedUser.phoneNumber}
      },
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
    setState(() {
      initialUrl = url;
      showPayView = true;
    });
  }

  payStatus(String chargeId) async {
    final uri = Uri.parse('https://api.tap.company/v2/charges/' + chargeId);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      //'Authorization':"Bearer sk_test_Opnge3LNhdkXJaCbMwmoy9BS",
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

    String customerId = res['customer']['id'];
    customerId = customerId != null ? customerId : "";
    if (res['status'] == "CAPTURED") {
      //update userBalance
      dynamic balance = double.parse(amount.toString());
      if (searchUser.balance != null) {
        balance = searchUser.balance + balance;
        searchUser.balance = balance;
      }
      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(widget.loggedUser.uid)
          .set({
        'customerId': customerId,
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection(Paths.userPaymentHistory)
          .doc(Uuid().v4())
          .set({
        'userUid': widget.loggedUser.uid,
        'payType': "send",
        'payDate': Timestamp.now(), //FieldValue.serverTimestamp(),
        'payDateValue': DateTime.now().millisecondsSinceEpoch,
        'amount': amount,
        'otherData': {
          'uid': searchUser.uid,
          'name': searchUser.name,
          'image': searchUser.photoUrl,
          'phone': searchUser.phoneNumber,
        },
      });

      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(searchUser.uid)
          .set({
        'balance': balance,
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection(Paths.userPaymentHistory)
          .doc(Uuid().v4())
          .set({
        'userUid': searchUser.uid,
        'payType': "receive",
        'payDate': Timestamp.now(), //FieldValue.serverTimestamp(),
        'payDateValue': Timestamp.now().millisecondsSinceEpoch,
        'amount': amount,
        'otherData': {
          'uid': widget.loggedUser.uid,
          'name': widget.loggedUser.name,
          'image': widget.loggedUser.photoUrl,
          'phone': widget.loggedUser.phoneNumber,
        },
      });
      if (widget.loggedUser.phoneNumber == to)
        accountBloc.add(GetLoggedUserEvent());
      setState(() {
        showPayView = false;
        saving = false;
      });
      showSuccessAddingDialog(
        size,
        widget.loggedUser.phoneNumber == to
            ? getTranslated(context, "addBalance")
            : getTranslated(context, "balanceTransfer"),
        widget.loggedUser.phoneNumber == to
            ? getTranslated(context, "balanceAdded")
            : getTranslated(context, "balanceTransferred"),
      );
    } else {
      setState(() {
        showPayView = false;
        saving = false;
      });
      showSnakbar(getTranslated(context, "failed"), true);
    }
  }

  showSuccessAddingDialog(Size size, String title, String msg) {
    return showDialog(
      builder: (context) => DreamDialogsWidget(
        padBottom: 0,
        padLeft: 0,
        padRight: 0,
        padTop: 0,
        dialogContent: Container(
          //height: AppSize.h292.h,
          width: AppSize.w441_3.w,
          padding: EdgeInsets.symmetric(
              horizontal: AppPadding.p32.w, vertical: AppPadding.p32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      AssetsManager.black_cancel_iconPath,
                      width: AppSize.w32.w,
                      height: AppSize.h32.h,
                    ),
                  )
                ],
              ),
              Text(
                //getTranslated(context, "addBalance"),
                title,
                style: TextStyle(
                  height: AppSize.h1_6.h,
                  fontFamily: getTranslated(context, 'Ithra'),
                  fontSize: AppFontsSizeManager.s32.sp,
                  color: AppColors.linear2,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: AppSize.h13_3.h),
              Text(
                msg +
                            " ${amount}\$ " +
                            widget.loggedUser.phoneNumber.toString() ==
                        to
                    ? getTranslated(context, "balanceTransferred")
                    : (getTranslated(context, "toPhone") +
                        " ${to} " +
                        getTranslated(context, "successfully")),
                // getTranslated(context, "balanceTransferred") +
                //     " 10\$ " +
                //     (getTranslated(context, "toPhone") +
                //         " 01144313832 " +
                //         getTranslated(context, "successfully")

                textAlign: TextAlign.center,
                style: TextStyle(
                  height: AppSize.h2_1.h,
                  fontFamily: getTranslated(context, 'Ithralight'),
                  fontSize: AppFontsSizeManager.s21_3.sp,
                  color: AppColors.black4,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                ),
              ),
              // Text(
              //   (getTranslated(context, "toPhone") +
              //       " 01144313832 " +
              //       getTranslated(context, "successfully")),
              //   // widget.loggedUser.phoneNumber == to
              //   //     ? getTranslated(context, "toBalance")
              //   //     : (getTranslated(context, "toPhone") +
              //   //         " ${to} " +
              //   //         getTranslated(context, "successfully")
              //   //         ),

              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     fontFamily: getTranslated(context, 'Ithralight'),
              //     fontSize: AppFontsSizeManager.s21_3.sp,
              //     color: AppColors.black4,
              //     fontWeight: FontWeight.w500,
              //     fontStyle: FontStyle.normal,
              //   ),
              // ),
              SizedBox(
                height: AppSize.h21_3.h,
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: AppSize.h56.h,
                  //   alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.Gradient_Color1,
                          AppColors.Gradient_Color2,
                        ]),
                    borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                  ),
                  child: Center(
                    child: Text(
                      getTranslated(context, 'Ok'),
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithra'),
                        fontSize: AppFontsSizeManager.s18_6.sp,
                        color: AppColors.white1,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  InputDecoration inputDecoration(Icon icon) {
    return InputDecoration(
        prefixIcon: Icon(
          Icons.call,
          color: AppColors.pink,
          size: 15,
        ),
        hintText: getTranslated(context, 'title'),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: AppColors.grey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: AppColors.lightGrey,
            width: 1.0,
          ),
        ));
  }

  void showSnakbar(String s, bool status) {
    Fluttertoast.showToast(
        msg: s,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: status ? Colors.lightGreen : Colors.red,
        textColor: AppColors.white,
        fontSize: 16.0);
  }
}

class errorPAdding extends StatefulWidget {
  const errorPAdding({super.key});

  @override
  State<errorPAdding> createState() => _errorPAddingState();
}

class _errorPAddingState extends State<errorPAdding> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppPadding.p15.h),
      child: Text(
        getTranslated(context, 'required'),
      ),
    );
  }
}
