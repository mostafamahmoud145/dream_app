import 'package:checkbox_grouped/checkbox_grouped.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/blocs/ratio_cubit/cubit.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/app/authentication/view/screens/sign_up_screen.dart';
import '../blocs/ratio_cubit/states.dart';
import '../localization/language_constants.dart';
import '../main.dart';
import '../screens/DevelopTechSupport/allDevelopSupport.dart';
import '../screens/aboutUsScreen.dart';
import '../screens/account_screen.dart';
import '../screens/allConsultReviewScreen/ActiveConsultsScreen1.dart';
import '../screens/consultPaymentHistoryScreen.dart';
import '../screens/invoice/allInvoicesScreen.dart';
import '../screens/myOrderScreen.dart';
import '../screens/promoCodesScreens/allPromoCodesScreen.dart';
import '../screens/push_notifications_screens/AllSendedNotification.dart';
import '../screens/question/questionScreens.dart';
import '../screens/reviews_screen.dart';
import '../screens/suggestionScreen.dart';
import '../screens/supervisor/allConsultantsScreen.dart';
import '../screens/techUserDetails/userDetailsScreen.dart';
import '../screens/technicalAppointment/allAppointmentScreen.dart';
import '../screens/userAccountScreen.dart';
import '../screens/walletScreen.dart';
import '../services/app_flyer_service.dart';
import 'dreamDialogsWidget.dart';
class DrawerWidget extends StatefulWidget {
  DrawerWidget();

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget>
    with SingleTickerProviderStateMixin {
  late AccountBloc accountBloc;
  GroceryUser user = GroceryUser();
  bool load = false, loadUser = true, wrongNumber = false, changeLang = false;
  late bool isSigningOut;
  TextEditingController searchController = new TextEditingController();
  String userImage = "", userName = "", lang = "ar", theme = "light";
  String selectedLang = " ";
  late Size size;
  bool avaliable = false;

  @override
  void initState() {
    super.initState();
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetLoggedUserEvent());
  }

  @override
  Widget build(BuildContext context) {
    DateTime _now = DateTime.now();
    String dayNow = _now.weekday.toString();
    int timeNow = _now.hour;
    size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");
    return Drawer(
        backgroundColor: AppColors.white,
        child: BlocBuilder(
          bloc: accountBloc,
          builder: (context, state) {
            if (state is GetLoggedUserInProgressState) {
              return Center(child: CircularProgressIndicator());
            } else if (state is GetLoggedUserCompletedState) {
              user = state.user;
              return loggedUserDrawer(size);
            } else {
              return notLoggedUserDrawer(size);
            }
          },
        ));
  }

  Widget loggedUserDrawer(Size size) {
    return Container(
      color: AppColors.white,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
                top: AppPadding.p20.h,
                right: AppPadding.p32.w,
                left: AppPadding.p28.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    showLangDialog(size);
                  },
                  child: Icon(
                    Icons.language,
                    size: AppSize.w32.r,
                    color: AppColors.linear2,
                  ),
                ),
                SizedBox(
                  width: AppSize.w10_6.w,
                ),
                Text(
                  getTranslated(context, "lang"),
                  style: TextStyle(
                      color: AppColors.grey,
                      fontSize: AppFontsSizeManager.s16.sp,
                      fontFamily: getTranslated(context, "Montserrat-Bold")),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.all(0),
                  height: AppSize.h50_6.h,
                  width: AppSize.w50_6.w,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.grey, width: AppSize.w0_5.w),
                      borderRadius: BorderRadius.circular(AppRadius.r10_6.r)),
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        size: AppSize.w32.r,
                        color: AppColors.linear2,
                      ),
                    ),
                  ),

                  // icon: Image.asset(

                  //   // lang == "ar"
                  //   //     ? AssetsManager.purple_left_arrowPath
                  //   //     : AssetsManager.purple_right_arrowPath,
                  //   width: AppSize.w32.r,
                  //   height: AppSize.h32.r,
                  // ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: AppSize.h41_3.h,
          ),
          Padding(
            padding: EdgeInsets.only(
                right: AppPadding.p32.w,
                left: lang == "ar" ? 0 : AppSize.w25.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(alignment: Alignment.center, children: [
                  Container(
                    height: AppSize.h66_6.r,
                    width: AppSize.w66_6.r,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white,
                          width: AppSize.w2,
                        ),
                        boxShadow: [AppShadow.primaryShadow]),
                    child: Center(
                      child: InkWell(
                        splashColor: AppColors.white.withOpacity(0.6),
                        onTap: () {
                          if (user != null && user.isDeveloper!)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AllDevelopTechScreen(loggedUser: user),
                              ),
                            );
                          else if (user != null &&
                              user.userType != AppConstants.consultant)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserAccountScreen(
                                    user: user, firstLogged: false),
                              ),
                            );
                          else if (user != null &&
                              user.userType == AppConstants.consultant)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AccountScreen(
                                    user: user, firstLogged: false),
                              ),
                            );
                          else {
                            Navigator.pushNamed(context, '/Register_Type');
                          }
                        },
                        child: user.photoUrl!.isEmpty
                            ? Image.asset(
                                AssetsManager.dreamLogoPurpleImagePath,
                                height: AppSize.h70.h,
                                width: AppSize.w70.r,
                                fit: BoxFit.fill,
                              )
                            : Container(
                                height: AppSize.h70.h,
                                width: AppSize.w70.r,
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.r100.r),
                                  child: FadeInImage.assetNetwork(
                                    placeholder: AssetsManager.purple_logo,
                                    placeholderScale: 0.5,
                                    imageErrorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                      AssetsManager.dreamLogoPurpleImagePath,
                                      height: AppSize.h70.h,
                                      width: AppSize.w70.r,
                                      fit: BoxFit.fill,
                                    ),
                                    image: user.photoUrl!,
                                    fit: BoxFit.cover,
                                    fadeInDuration: Duration(
                                        milliseconds:
                                            AppConstants.milliseconds250),
                                    fadeInCurve: Curves.easeInOut,
                                    fadeOutDuration: Duration(
                                        milliseconds:
                                            AppConstants.milliseconds150),
                                    fadeOutCurve: Curves.easeInOut,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: AppPadding.p5.w,
                    top: 7.h,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            avaliable ? AppColors.greenButton : AppColors.pink1,
                      ),
                      width: AppSize.w8.w,
                      height: AppSize.h8.h,
                    ),
                  ),
                ]),
              ],
            ),
          ),
          SizedBox(
            height: AppSize.h16.h,
          ),
          Padding(
            padding: EdgeInsets.only(right: AppPadding.p32.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: lang == "ar" ? AppPadding.p0 : AppPadding.p10.w),
                  child: Text(
                    getTranslated(context, "lang") == "ar"
                        ? user.consultName!.nameAr!
                        : getTranslated(context, "lang") == "en"
                            ? user.consultName!.nameEn!
                            : getTranslated(context, "lang") == "fr"
                                ? user.consultName!.nameFr!
                                : user.consultName!.nameId!,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: getTranslated(context, 'Ithra'),
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      color: AppColors.black4,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: AppPadding.p32.h,
              bottom: AppPadding.p30_5.h,
              right: AppPadding.p32.w,
              left: AppPadding.p32.w,
            ),
            child: (user.userType != null && user.userType == "SUPPORT")
                ? Column(
                    children: [
                      SizedBox(
                        height: AppSize.h5.h,
                      ),
                      Text(
                        getTranslated(context, "searchByMobile"),
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize: AppFontsSizeManager.s18.sp,
                          color: AppColors.pink,
                        ),
                      ),
                      SizedBox(
                        height: AppSize.h5.h,
                      ),
                      TextField(
                        textAlignVertical: TextAlignVertical.center,
                        controller: searchController,
                        enableInteractiveSelection: true,
                        onChanged: (text) {
                          setState(() {
                            wrongNumber = false;
                          });
                        },
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize: AppFontsSizeManager.s14.sp,
                          color: AppColors.pureBlack,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          fillColor: theme == "light"
                              ? AppColors.white
                              : AppColors.grey5,
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: AppPadding.p15.w),
                          helperStyle: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            color: AppColors.pureBlack.withOpacity(0.65),
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          errorStyle: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontSize: AppFontsSizeManager.s13.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          hintStyle: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            color: AppColors.black1,
                            fontSize: AppFontsSizeManager.s14_5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          prefixIcon: Icon(Icons.search),
                          prefixStyle: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontSize: AppFontsSizeManager.s14_5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          suffixIcon: InkWell(
                              child: Icon(Icons.send_rounded, size: 18),
                              onTap: () {
                                initiateSearch(searchController.text);
                              }),
                          // labelText: getTranslated(context, "phoneNumber"),
                          labelStyle: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontSize: AppFontsSizeManager.s14_5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.r20.r),
                          ),
                          /*
                                      border: InputBorder.none,
      */
                        ),
                      ),
                      SizedBox(
                        height: AppSize.h5.h,
                      ),
                      load ? CircularProgressIndicator() : SizedBox(),
                      SizedBox(
                        height: AppSize.h5.h,
                      ),
                      wrongNumber
                          ? Text(
                              getTranslated(context, "invalidNumbers"),
                              style: GoogleFonts.elMessiri(
                                color: AppColors.red,
                                fontSize: AppFontsSizeManager.s14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : SizedBox(),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          //
                          Text(
                            getTranslated(context, "balance"),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              fontSize: AppFontsSizeManager.s18_6.sp,
                              color: AppColors.grey,
                              // foreground: Paint()
                              //   ..style = PaintingStyle.stroke
                              //   ..strokeWidth = 0.2
                              //   ..color = AppColors.grey,
                              fontStyle: FontStyle.normal,
                            ),
                          ),

                          SizedBox(width: AppSize.w10_6.w),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 24.h,
                                child: Text(
                                  "\$",
                                  // textAlign: TextAlign.center,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                    //  backgroundColor: Colors.blue,
                                    height: 1.5.h,
                                    fontFamily: getTranslated(context, 'Ithra'),
                                    //fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.normal,
                                    color: AppColors.linear2,
                                    fontSize: AppFontsSizeManager.s18_6.sp,
                                  ),
                                ),
                              ),
                              Text(
                                double.parse(user.balance.toString())
                                    .toStringAsFixed(2),
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontFamily: getTranslated(context, 'Ithra'),
                                  // fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                                  color: AppColors.linear2,
                                  fontSize: AppFontsSizeManager.s18_6.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            getTranslated(context, "orderNum"),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              fontSize: AppFontsSizeManager.s18_6.sp,
                              color: AppColors.grey,
                              // foreground: Paint()
                              //   ..style = PaintingStyle.stroke
                              //   ..strokeWidth = 0.2
                              //   ..color = AppColors.grey,
                              // fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                          SizedBox(width: AppSize.w10_6.w),
                          Text(
                            user.ordersNumbers.toString(),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontFamily:
                                  getTranslated(context, 'Montserrat-Bold'),
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                              color: AppColors.linear2,
                              fontSize: AppFontsSizeManager.s18_6.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          Container(
              width: AppSize.w324,
              height: AppSize.h0_5,
              decoration: BoxDecoration(color: AppColors.lightGrey)),
          SizedBox(height: AppSize.h10.h),
          InkWell(
            onTap: () {
              if (user != null && user.userType != AppConstants.consultant)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserAccountScreen(user: user, firstLogged: false),
                  ),
                );
              else if (user != null && user.userType == AppConstants.consultant)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AccountScreen(user: user, firstLogged: false),
                  ),
                );
              else {
                Navigator.pushNamed(context, '/Register_Type');
              }
            },
            child: DrawerItem(
              title: getTranslated(context, "account"),
              size: AppSize.w32,
              image: AssetsManager.outline_person_iconPath,
            ),
          ),
          user.isSupervisor == true
              ? InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllConsultantScreen(
                          loggedUser: user,
                        ),
                      ),
                    );
                  },
                  child: DrawerItem(
                    title: getTranslated(context, "consultNum"),
                    size: AppSize.w32.w,
                    image: AssetsManager.wallet_iconPath,
                  ),
                )
              : SizedBox(),
          user.userType == AppConstants.user
              ? InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WalletScreen(
                          loggedUser: user,
                        ),
                      ),
                    );
                  },
                  child: DrawerItem(
                    title: getTranslated(
                      context,
                      "wallet",
                    ),
                    size: AppSize.w32,
                    image: AssetsManager.wallet3,
                  ),
                )
              : SizedBox(),
          user.userType == AppConstants.consultant
              ? InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConsultPaymentHistoryScreen(
                          user: user,
                        ),
                      ),
                    );
                  },
                  child: DrawerItem(
                    title: getTranslated(context, "paymentHistory2"),
                    size: AppSize.w32,
                    image: AssetsManager.wallet_iconPath,
                  ),
                )
              : SizedBox(),
          user.userType == AppConstants.consultant
              ? InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyOrdersScreen(
                          user: user,
                          loggedType: user.userType,
                          fromSupport: false,
                        ),
                      ),
                    );
                  },
                  child: DrawerItem(
                    title: getTranslated(context, "orders"),
                    size: AppSize.w32,
                    icon: Icons.list_alt_rounded,
                  ),
                )
              : SizedBox(),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SuggestionScreen(loggedUser: user),
                ),
              );
            },
            child: DrawerItem(
              title: getTranslated(context, "suggestions2"),
              size: AppSize.w32,
              image: AssetsManager.purple_lump,
            ),
          ),
          user.userType == AppConstants.consultant
              ? InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewScreens(
                          consult: user,
                          reviewLength: 1,
                        ),
                      ),
                    );
                  },
                  child: DrawerItem(
                    title: getTranslated(context, "Reviews"),
                    size: AppSize.w32,
                    icon: Icons.star_border,
                  ),
                )
              : SizedBox(),
          user.userType == "SUPPORT"
              ? InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllInvoicesScreen(
                          loggedUser: user,
                        ),
                      ),
                    );
                  },
                  child: DrawerItem(
                    title: getTranslated(context, "invoices"),
                    size: AppSize.w32,
                    icon: Icons.wysiwyg_rounded,
                  ),
                )
              : SizedBox(),
          user.userType == "SUPPORT"
              ? InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AllDevelopTechScreen(loggedUser: user),
                      ),
                    );
                  },
                  child: DrawerItem(
                    title: getTranslated(context, "developNotes"),
                    size: AppSize.w32,
                    icon: Icons.check,
                  ),
                )
              : SizedBox(),
          user.userType == "SUPPORT"
              ? InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllAppointmentsScreen(
                          loggedUser: user,
                        ),
                      ),
                    );
                  },
                  child: DrawerItem(
                    title: getTranslated(context, "appointments"),
                    size: AppSize.w32,
                    icon: Icons.calendar_today_rounded,
                  ),
                )
              : SizedBox(),
          user.userType == "SUPPORT"
              ? InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllPromoCodeScreen(),
                      ),
                    );
                  },
                  child: DrawerItem(
                    title: getTranslated(context, "proCodes"),
                    size: AppSize.w32,
                    icon: Icons.card_giftcard,
                  ),
                )
              : SizedBox(),
          user.userType == "SUPPORT"
              ? InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllSendedNotificationSreen(),
                      ),
                    );
                  },
                  child: DrawerItem(
                    title: getTranslated(context, "notification"),
                    size: AppSize.w32,
                    icon: Icons.notifications_none_sharp,
                  ),
                )
              : SizedBox(),
          user.userType == "SUPPORT"
              ? InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ActiveConsultsScreen1(loggedUser: user),
                      ),
                    );
                  },
                  child: DrawerItem(
                    title: getTranslated(context, "Reviews"),
                    size: AppSize.w32,
                    icon: Icons.note_add_outlined,
                  ),
                )
              : SizedBox(),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionScreen(user: user),
                ),
              );
            },
            child: DrawerItem(
              title: getTranslated(context, "questions"),
              size: AppSize.w32,
              image: AssetsManager.help_iconPath,
            ),
          ),
          InkWell(
            onTap: () {
              showLangDialog(size);
            },
            child: DrawerItem(
              title: getTranslated(context, "languages"),
              size: AppSize.w32,
              icon: Icons.language,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AboutUsScreen(),
                ),
              );
            },
            child: DrawerItem(
              title: getTranslated(context, "aboutUs"),
              size: AppSize.w32,
              icon: Icons.info_outline,
            ),
          ),
          InkWell(
            onTap: () {
              inviteAFriend();
            },
            child: DrawerItem(
              title: getTranslated(context, "share"),
              size: AppSize.w30,
              image: AssetsManager.share_iconPath,
            ),
          ),
          InkWell(
            onTap: () {
              showSignoutConfimationDialog(size);
            },
            child: DrawerItem(
              title: getTranslated(context, "logout"),
              size: AppSize.w32,
              image: AssetsManager.logout_iconPath,
            ),
          ),
          SizedBox(
            height: AppSize.h50.h,
          ),
        ],
      ),
    );
  }

  Widget text(
    String text,
  ) {
    return Stack(
      children: <Widget>[
        Text(
          text,
          style: TextStyle(
            fontFamily: getTranslated(context, "Ithra"),
            fontSize: AppFontsSizeManager.s18.sp,
            fontWeight: FontWeight.w300,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.5
              ..color = Color.fromRGBO(32, 32, 32, 1),
          ),
        ),
        // Solid text as fill.
        Text(
          text,
          style: TextStyle(
            fontFamily: getTranslated(context, "Ithra"),
            color: Color.fromRGBO(32, 32, 32, 1),
            fontSize: AppFontsSizeManager.s18.sp,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget notLoggedUserDrawer(Size size) {
    return Container(
      color: AppColors.white,
      child: ListView(
        shrinkWrap: true,
        // padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
                top: AppPadding.p26_6.h,
                right: AppPadding.p32.w,
                left: AppPadding.p32.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.all(0),
                  height: AppSize.h50_6.h,
                  width: AppSize.w50_6.w,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.grey, width: AppSize.w0_5.w),
                      borderRadius: BorderRadius.circular(AppRadius.r10_6.r)),
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        size: AppSize.w32.r,
                        color: AppColors.linear2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: AppSize.h32.h,
          ),
          Padding(
            padding: EdgeInsets.only(
                left: lang == "ar" ? AppPadding.p298.w : AppPadding.p0,
                right: lang == "ar" ? AppPadding.p32.w : AppPadding.p298.w),
            child: InkWell(
              splashColor: AppColors.white.withOpacity(0.6),
              onTap: () {
                Navigator.pushNamed(context, '/Register_Type');
              },
              child: Container(
                  height: AppSize.h27_7.w,
                  width: AppSize.w106_6.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    AssetsManager.dreamImagePath,
                  )),
            ),
          ),
          SizedBox(
            height: AppSize.h16.h,
          ),
          Padding(
            padding: EdgeInsets.only(right: AppSize.w32.w),
            child: Text(
              getTranslated(context, "welcomeBack"),
              style: TextStyle(
                fontFamily: getTranslated(context, "Ithra_Bold"),
                fontSize: AppFontsSizeManager.s21_3.sp,
                fontWeight: FontWeight.normal,
                color: AppColors.black,
              ),
            ),
          ),
          SizedBox(
            height: AppSize.h32.h,
          ),
          Container(
            color: AppColors.lightGrey7,
            width: double.infinity,
            height: AppSize.h1.h,
          ),
          SizedBox(
            height: AppSize.h16.h,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SuggestionScreen(loggedUser: user),
                ),
              );
            },
            child: DrawerItem(
              title: getTranslated(context, "suggestions2"),
              size: AppSize.w32,
              image: AssetsManager.purple_lump,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionScreen(
                    user: user,
                  ),
                ),
              );
            },
            child: DrawerItem(
              title: getTranslated(context, "questions"),
              size: AppSize.w32,
              image: AssetsManager.help_iconPath,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  //CONSULTANT
                  builder: (context) =>
                      SignUpScreen(userType: AppConstants.consultant),
                ),
              );
            },
            child: DrawerItem(
              title: getTranslated(context, "BecomeConsultant"),
              size: AppSize.w32,
              image: AssetsManager.help3,
            ),
          ),
          InkWell(
            onTap: () {
              showLangDialog(size);
            },
            child: DrawerItem(
              title: getTranslated(context, "languages"),
              size: AppSize.w32,
              icon: Icons.language,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AboutUsScreen(),
                ),
              );
            },
            child: DrawerItem(
              title: getTranslated(context, "aboutUs"),
              size: 32,
              icon: Icons.info_outline,
            ),
          ),
          InkWell(
            onTap: () async {
              inviteAFriend();
            },
            child: DrawerItem(
                title: getTranslated(context, "share"),
                size: AppSize.w32,
                image: AssetsManager.share_iconPath),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/Register_Type');
            },
            child: DrawerItem(
                title: getTranslated(context, "login"),
                size: AppSize.w32,
                image: AssetsManager.logout_iconPath),
          ),
          SizedBox(
            height: AppSize.h90_5.h,
          ),
          // Center(
          //   child: Container(
          //     width: size.width * AppSize.w0_8.w,
          //     height: AppSize.h45.h,
          //     child: MaterialButton(
          //       onPressed: () async {
          //         inviteAFriend();
          //       },
          //       //color: AppColors.white,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(AppRadius.r40.r),
          //       ),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Icon(
          //             Icons.share,
          //             color: AppColors.pink,
          //           ),
          //           SizedBox(
          //             width: AppSize.w5,
          //           ),
          //           text(
          //             getTranslated(context, "share"),
          //           )
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  changelanguage(String lang, String code) async {
    setState(() {
      changeLang = true;
    });
    await setLocaleLang(lang);
    Locale _temp = Locale(lang, code);
    if (FirebaseAuth.instance != null &&
        FirebaseAuth.instance.currentUser != null) {
      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(user.uid)
          .set({
        'userLang': lang,
        'languages':
            user.userType == AppConstants.consultant ? user.languages : [lang],
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection(Paths.supportListPath)
          .doc(user.supportListId)
          .set({
        'userLang': lang,
      }, SetOptions(merge: true));
      accountBloc.add(GetLoggedUserEvent());
    }
    MyApp.setLocale(context, _temp);
    setState(() {
      changeLang = false;
    });
    Navigator.pop(context);
  }

  initiateSearch(String text) async {
    setState(() {
      load = true;
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .where(
          'phoneNumber',
          isEqualTo: text,
        )
        .limit(1)
        .get();
    if (querySnapshot != null && querySnapshot.docs.length != 0) {
      var userSearch = GroceryUser.fromMap(querySnapshot.docs[0].data() as Map);
      setState(() {
        load = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserDetailsScreen(
            user: userSearch,
            loggedUser: user,
          ),
        ),
      );
    } else {
      setState(() {
        load = false;
        wrongNumber = true;
      });
    }
  }

  showSignoutConfimationDialog(Size size) {
    return showDialog(
      builder: (context) => DreamDialogsWidget(
        padBottom: 0,
        padLeft: 0,
        padRight: 0,
        padTop: 0,
        dialogContent: Container(
          width: AppSize.w441_3.w,
          // height: AppSize.h326_6.h,
          padding: EdgeInsets.symmetric(
              horizontal: AppPadding.p32.w, vertical: AppPadding.p32.h),
          child: Column(
            /*mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,*/
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
                      width: AppSize.w32.w,
                      height: AppSize.h32.h,
                    ),
                  ),
                ],
              ),
              Center(
                child: Image.asset(
                  AssetsManager.logoutcurve_iconPath,
                  width: AppSize.w53_5.r,
                  height: AppSize.h53_5.r,
                ),
              ),
              SizedBox(height: AppSize.h13_3.h),
              Column(
                children: [
                  Text(
                    getTranslated(context, "logout"),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      height: AppSize.h1_8.h,
                      //backgroundColor: Colors.red,
                      fontFamily: getTranslated(context, 'Ithra'),
                      fontSize: AppFontsSizeManager.s32.sp,
                      color: AppColors.linear2,
                      wordSpacing: 0,
                      letterSpacing: 0,

                      // fontStyle: FontStyle.normal,
                      //fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppSize.h13_3.h),
                  Text(
                    getTranslated(context, "doYouNeedToLogout"),
                    style: TextStyle(
                      fontFamily: getTranslated(context, 'Ithralight'),
                      height: AppSize.h2.h,
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      color: AppColors.black4,
                      //fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h21_3.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            AppFlyerService().clear();
                            await FirebaseFirestore.instance
                                .collection(Paths.usersPath)
                                .doc(user.uid)
                                .set({
                              'tokenId': "",
                            }, SetOptions(merge: true));
                            FirebaseAuth.instance.signOut();
                            accountBloc.add(GetLoggedUserEvent());
                            Navigator.pop(context);
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/Register_Type',
                              (route) => false,
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: AppSize.h56.h,
                            //   alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.red8,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r10_6.r),
                            ),
                            child: Center(
                              child: Text(
                                getTranslated(context, 'yes'),
                                style: TextStyle(
                                  fontFamily:
                                      getTranslated(context, 'Ithra_Bold'),
                                  fontSize: AppFontsSizeManager.s18_6.sp,
                                  color: AppColors.white,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: AppSize.h21_3.h,
                      ),
                      //SizedBox(width: AppSize.w57_3.w),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: AppSize.h56.h,
                            //   alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(AppRadius.r10_6.r)),
                                border: Border.all(
                                  color: AppColors.red8,
                                  width: 1.5.w,
                                )),
                            child: Center(
                              child: Text(
                                getTranslated(context, 'no'),
                                style: TextStyle(
                                  fontFamily:
                                      getTranslated(context, 'Ithra_Bold'),
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

  showLangDialog(Size size) {
    String langVal = getTranslated(context, "lang");
    return showDialog(
      builder: (context) => BlocProvider(
        create: (BuildContext context) => RatioCubit(RatioInitialState()),
        child: BlocConsumer<RatioCubit, RatioStates>(
          listener: (context, state){},
          builder: (context, state){
            return Container(
              child: DreamDialogsWidget(
                padBottom: 0,
                padLeft: 0,
                padRight: 0,
                padTop: AppPadding.p42_6.h,
                dialogContent: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
                        child: Row(
                          mainAxisAlignment: lang == 'ar'
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.close,
                                size: AppSize.w32.w,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: AppSize.h17_3.h,
                      ),
                      Text(
                        getTranslated(context, "chooseLang"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: getTranslated(context, 'Ithralight'),
                          fontSize: AppFontsSizeManager.s32.sp,
                          color: AppColors.pureBlack,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                      SizedBox(
                        height: AppSize.h32.h,
                      ),
                      Padding(
                        padding: lang == 'ar'
                            ? EdgeInsets.only(
                          right: AppPadding.p50.w,
                          left: AppPadding.p40.w,
                        ) : EdgeInsets.only(left: AppPadding.p50.w, right: AppPadding.p40.w),
                        child: Container(
                          width: size.width,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    getTranslated(context, 'ar'),
                                    style:TextStyle(
                                      color: langVal == "ar" ? AppColors.linear2: AppColors.appbartext,
                                      fontSize: AppFontsSizeManager.s24.sp,
                                      fontWeight: AppFontsWeightManager.bold600,
                                      fontFamily: getTranslated(context, 'Ithra'),
                                    ),
                                  ),
                                  Spacer(),
                                  Radio(
                                    value: "ar",
                                    activeColor: AppColors.linear2,
                                    groupValue: RatioCubit.get(context).selectedOption != null ? RatioCubit.get(context).selectedOption : getTranslated(context, "lang").toString(),
                                    onChanged: (value) {
                                      RatioCubit.get(context)..changeRadio(value);
                                      selectedLang = value!;
                                      langVal = value;
                                    },
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    getTranslated(context, 'en'),
                                    style:TextStyle(
                                      color: langVal == "en" ? AppColors.linear2: AppColors.appbartext,
                                      fontSize: AppFontsSizeManager.s24.sp,
                                      fontWeight: AppFontsWeightManager.bold600,
                                      fontFamily: getTranslated(context, 'Ithra'),
                                    ),
                                  ),
                                  Spacer(),
                                  Radio(
                                    value: "en",
                                    activeColor: AppColors.linear2,
                                    groupValue: RatioCubit.get(context).selectedOption != null ? RatioCubit.get(context).selectedOption : getTranslated(context, "lang").toString(),
                                    onChanged: (value) {
                                      RatioCubit.get(context)..changeRadio(value);
                                      selectedLang = value!;
                                      langVal = value;
                                    },
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    getTranslated(context, 'fr'),
                                    style:TextStyle(
                                      color: langVal == "fr" ? AppColors.linear2: AppColors.appbartext,
                                      fontSize: AppFontsSizeManager.s24.sp,
                                      fontWeight: AppFontsWeightManager.bold600,
                                      fontFamily: getTranslated(context, 'Ithra'),
                                    ),
                                  ),
                                  Spacer(),
                                  Radio(
                                    value: "fr",
                                    activeColor: AppColors.linear2,
                                    groupValue: RatioCubit.get(context).selectedOption != null ? RatioCubit.get(context).selectedOption : getTranslated(context, "lang").toString(),
                                    onChanged: (value) {
                                      RatioCubit.get(context)..changeRadio(value);
                                      selectedLang = value!;
                                      langVal = value;
                                    },
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    getTranslated(context, 'id'),
                                    style:TextStyle(
                                      color: langVal == "id" ? AppColors.linear2: AppColors.appbartext,
                                      fontSize: AppFontsSizeManager.s24.sp,
                                      fontWeight: AppFontsWeightManager.bold600,
                                      fontFamily: getTranslated(context, 'Ithra'),
                                    ),
                                  ),
                                  Spacer(),
                                  Radio(
                                    value: "id",
                                    activeColor: AppColors.linear2,
                                    groupValue: RatioCubit.get(context).selectedOption != null ? RatioCubit.get(context).selectedOption : getTranslated(context, "lang").toString(),
                                    onChanged: (value) {
                                      RatioCubit.get(context)..changeRadio(value);
                                      selectedLang = value!;
                                      langVal = value;
                                    },
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: AppSize.h20.h,
                      ),
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: AppPadding.p30.w),
                          height: AppSize.h48.h,
                          width: lang == "lang" ? size.width : AppSize.w390.w,
                          child: MaterialButton(
                            height: AppSize.h48.h,
                            onPressed: () {
                              if (selectedLang == " ") {
                                selectedLang = getTranslated(context, "lang");
                              }
                              if (selectedLang == 'ar') {
                                changelanguage("ar", "AR");
                              } else if (selectedLang == 'en')
                                changelanguage("en", "US");
                              else if (selectedLang == 'fr')
                                changelanguage("fr", "FR");
                              else if (selectedLang == "id")
                                changelanguage("id", "ARB");
                              else
                                Navigator.pop(context);
                            },
                            color: AppColors.linear2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                            ),
                            child: Text(
                              getTranslated(context, "changeLang"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.white,
                                fontSize: AppFontsSizeManager.s21_3.sp,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: AppSize.h42_6.h,
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  Future inviteAFriend() async {
    await FlutterShare.share(
        title: 'رؤيا  - Dream',
        text:
            'رؤيا  - Dream \n يمكنك تحميل تطبيق رؤيا من خلال موقعنا الرسمي You can get Dream app from our website ',
        linkUrl: 'https://dream-app.net/',
        chooserTitle: 'رؤيا  - Dream');
  }

  Widget DrawerItem({
    String? image,
    IconData? icon,
    required String title,
    isIcon,
    double? size,
  }) {
    return ListTile(
      leading: icon != null
          ? Icon(
              icon,
              color: AppColors.pink,
              size: size!.r,
            )
          : Image.asset(
              image!,
              width: size?.w,
              height: size?.h,
              color: AppColors.pink,
            ),
      title: Stack(
        children: <Widget>[
          // Padding(
          //   padding: EdgeInsets.only(left: lang == "ar" ? 0 : AppPadding.p16.w),
          //   child: Text(
          //     title,
          //     textAlign: TextAlign.start,
          //     style: TextStyle(
          //       fontFamily: lang == 'ar'
          //           ? getTranslated(context, 'Ithralight')
          //           : getTranslated(context, "Montserrat-Light"),
          //       fontSize: AppFontsSizeManager.s21_3.sp,
          //       fontWeight: FontWeight.w300,
          //       foreground: Paint()
          //         ..style = PaintingStyle.stroke
          //         ..strokeWidth = 0.4
          //         ..color = AppColors.black4,
          //     ),
          //   ),
          // ),
          // Solid text as fill.
          Padding(
            padding: EdgeInsets.only(left: AppPadding.p16.w),
            child: Text(
              title,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: getTranslated(context, 'Ithralight'),
                color: AppColors.appbartext,
                fontSize: AppFontsSizeManager.s21_3.sp,
                // fontWeight: AppFontsWeightManager.bold600,
                fontStyle: FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Color.fromRGBO(211, 211, 211, 1),
        size: AppFontsSizeManager.s21_3.sp,
      ),
    );
  }
}
