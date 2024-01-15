import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/historyAppointmentWidget.dart';
import 'package:shimmer/shimmer.dart';

import '../FireStorePagnation/paginate_firestore.dart';

class CallHistoryPage extends StatefulWidget {
  @override
  _CallHistoryPageState createState() => _CallHistoryPageState();
}

class _CallHistoryPageState extends State<CallHistoryPage>
    with AutomaticKeepAliveClientMixin<CallHistoryPage> {
  late AccountBloc accountBloc;
  GroceryUser? user;

  DateTime selectedDate = DateTime.now();
  bool avaliable = true;
  DateTime _now = DateTime.now();
  bool filter = false;
  late String time;
  late Query filterQuery;
  String lang = "";

  @override
  void initState() {
    super.initState();
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetLoggedUserEvent());
    filterQuery = FirebaseFirestore.instance
        .collection(Paths.appAppointments)
        .where('consult.uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('appointmentStatus', isEqualTo: "closed")
        .orderBy('secondValue', descending: true);
    time = "التصفية بحسب التاريخ";
  }

  @override
  Widget build(BuildContext context) {
    lang = getTranslated(context, "lang");
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocBuilder(
        bloc: accountBloc,
        builder: (context, state) {
          if (state is GetLoggedUserInProgressState) {
            return Center(child: loadWidget());
          } else if (state is GetLoggedUserCompletedState) {
            user = state.user;
            checkAvaliable();
            return Column(
              children: <Widget>[
                // Container(
                //   height: AppSize.h1,
                //   width: double.infinity,
                //   color: AppColors.lightGray,
                // ),
                SizedBox(
                  height: AppSize.h24.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // /// available or not
                      // Container(
                      //   width: AppSize.w110.w,
                      //   height: AppSize.h36.h,
                      //   decoration: BoxDecoration(
                      //     color: avaliable
                      //         ? Color.fromRGBO(131, 227, 57, 1)
                      //         : HexColor('FAF5F9'),
                      //     borderRadius:
                      //         BorderRadius.circular(AppRadius.r26_5.r),
                      //   ),
                      //   child: Center(
                      //     child: Text(
                      //       avaliable
                      //           ? getTranslated(context, "available")
                      //           : getTranslated(context, "notAvailable"),
                      //       textAlign: TextAlign.center,
                      //       overflow: TextOverflow.ellipsis,
                      //       maxLines: 1,
                      //       style: TextStyle(
                      //         fontFamily: getTranslated(context, 'Ithra'),
                      //         color:
                      //             avaliable ? AppColors.white : AppColors.pink,
                      //         fontSize: AppFontsSizeManager.s16.sp,
                      //         fontWeight: FontWeight.bold,
                      //         fontStyle: FontStyle.normal,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Text(
                        getTranslated(context, "allAppointment"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: getTranslated(context, 'Ithra'),
                          color: AppColors.black,
                          fontSize: AppFontsSizeManager.s21_3.sp,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),

                      /// filtering container
                      Container(
                        height: AppSize.h53_3.h,
                        width: AppSize.w337_3.w,
                        padding: EdgeInsetsDirectional.symmetric(
                            horizontal: AppPadding.p21_3.w),
                        decoration: BoxDecoration(
                          color: AppColors.tabColor,
                          borderRadius:
                              BorderRadius.circular(AppRadius.r10_6.r),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                time,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily:
                                      getTranslated(context, 'Ithralight'),
                                  color: AppColors.dateColor,
                                  fontSize: AppFontsSizeManager.s18.sp,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                              InkWell(
                                splashColor: AppColors.white.withOpacity(0.6),
                                onTap: () {
                                  _selectDate(context);
                                },
                                child: SvgPicture.asset(
                                  AssetsManager.pinkFilter,
                                  width: AppSize.w32.w,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 43.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AssetsManager.calenderCheckIcon,
                        height: AppSize.h21_3.h,
                        width: AppSize.w21_3.w,
                      ),
                      SizedBox(
                        width: AppSize.w5.w,
                      ),
                      Text(
                        getTranslated(context, 'todayTxt'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: getTranslated(context, 'Ithralight'),
                          color: AppColors.dateColor,
                          fontSize: AppFontsSizeManager.s18.sp,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                // InkWell(
                //   splashColor: AppColors.white.withOpacity(0.6),
                //   onTap: () {
                //     setState(() {
                //       filterQuery = FirebaseFirestore.instance
                //           .collection(Paths.appAppointments)
                //           .where('consult.uid', isEqualTo: user!.uid)
                //           .where('appointmentStatus', isEqualTo: "closed")
                //           .orderBy('secondValue', descending: true);
                //       time = getTranslated(context, "filter");
                //     });
                //   },
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [],
                //   ),
                // ),
                Expanded(
                  child: PaginateFirestore(
                    onEmpty: Text(
                      getTranslated(context, "notFoundAppointmentTxt"),
                      style: TextStyle(
                        fontFamily: lang == "ar"
                            ? getTranslated(context, "Ithra")
                            : getTranslated(context, "Montserratbold"),
                      ),
                    ),
                    separator: SizedBox(
                      height: 32.h,
                    ),
                    key: ValueKey(filterQuery),
                    itemBuilderType: PaginateBuilderType.listView,
                    padding: EdgeInsets.only(
                        left: AppPadding.p32.w,
                        right: AppPadding.p32.w,
                        top: AppPadding.p35.h,
                        bottom: 46.h),
                    //Change types accordingly
                    itemBuilder: (context, documentSnapshot, index) {
                      return HistoryAppointmentWidget(
                        appointment: AppAppointments.fromMap(
                            documentSnapshot[index].data() as Map),
                        loggedUser: user!,
                      );
                    },
                    query: filterQuery,
                    isLive: true,
                  ),
                )
              ],
            );
          } else {
            return Center(child: loadWidget());
          }
        },
      ),
    );
  }

  Widget loadWidget() {
    return Shimmer.fromColors(
        period: Duration(milliseconds: 800),
        baseColor: Colors.grey.withOpacity(0.6),
        highlightColor: AppColors.pureBlack.withOpacity(0.6),
        child: Container(
          height: 60,
          width: MediaQuery.of(context).size.width * .9,
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          decoration: BoxDecoration(
            color: AppColors.pureBlack.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30.0),
          ),
        ));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        int month = selectedDate.month;
        int day = selectedDate.day;
        filterQuery = FirebaseFirestore.instance
            .collection(Paths.appAppointments)
            .where('consult.uid', isEqualTo: user!.uid)
            .where('appointmentStatus', isEqualTo: "closed")
            .where('date.month', isEqualTo: month)
            .where('date.day', isEqualTo: day)
            .orderBy('secondValue', descending: true);
        time = selectedDate.toString().substring(0, 10);
        filter = true;
      });
  }

  checkAvaliable() async {
    if (user != null &&
        user!.userType == AppConstants.consultant &&
        user!.profileCompleted == true) {
      String dayNow = _now.weekday.toString();
      int timeNow = _now.hour;
      if (user!.workDays!.contains(dayNow)) {
        if (int.parse(user!.workTimes![0].from!) <= timeNow &&
            int.parse(user!.workTimes![0].to!) > timeNow) {
          avaliable = false;
        }
      }
    }
  }

  @override
  bool get wantKeepAlive => true;
}
