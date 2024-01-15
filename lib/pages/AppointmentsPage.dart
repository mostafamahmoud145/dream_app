import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/userAppointmentWiget.dart';

import '../FireStorePagnation/paginate_firestore.dart';
import '../blocs/appointment_cubit/appointment_cubit.dart';
import '../config/app_fonts.dart';
import '../config/colorsFile.dart';
import '../widget/previous_order_widger.dart';
import '../widget/tab_bar/custom_tab_bar.dart';
import '../widget/tab_bar/tab_bar_button.dart';

class AppointmentsPage extends StatefulWidget {
  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with AutomaticKeepAliveClientMixin<AppointmentsPage> {
  final TextEditingController searchController = new TextEditingController();

  late AccountBloc accountBloc;
  GroceryUser? user;
  bool fixed = true, closed = false;
  bool active = false;
  List<String> ordersIds = [];

  @override
  void initState() {
    super.initState();
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetLoggedUserEvent());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocProvider(
      create: (context) => AppointmentCubit(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: BlocBuilder(
          bloc: accountBloc,
          builder: (context, state) {
            if (state is GetLoggedUserInProgressState) {
              return Center(child: CircularProgressIndicator());
            } else if (state is GetLoggedUserCompletedState) {
              user = state.user;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    // SizedBox(
                    //   height: convertPtToPx(AppSize.h24.h),
                    // ),

                    ///------------------------Tab Bar for accepted and refused appointments -------------------------///

                    Center(
                      child: user == null
                          ? SizedBox()
                          : CustomTabBar(
                              // margin: EdgeInsets.symmetric(
                              //     horizontal: AppMargin.m32.w),

                              buttons: [
                                TabBarButton(
                                  isSelected: fixed,
                                  text: getTranslated(context, "fixed"),
                                  function: () {
                                    setState(() {
                                      fixed = true;
                                      closed = false;
                                    });
                                  },
                                ),
                                TabBarButton(
                                  isSelected: closed,
                                  text: getTranslated(context, "closed"),
                                  function: () {
                                    setState(() {
                                      fixed = false;
                                      closed = true;
                                    });
                                  },
                                ),
                              ],
                            ),
                    ),
                    SizedBox(
                      height: AppSize.h32.h,
                    ),

                    /// Appointments.
                    fixed
                        ? PaginateFirestore(
                            shrinkWrap: true,
                            errorScreenHeight: 0,

                            physics: NeverScrollableScrollPhysics(),
                            itemBuilderType: PaginateBuilderType.listView,
                            onLoaded: (paginationLoaded) {
                              ordersIds.clear();
                              paginationLoaded.documentSnapshots
                                  .forEach((element) {
                                AppAppointments appointment =
                                    AppAppointments.fromMap(
                                        element.data() as Map);
                                ordersIds.add(appointment.orderId);
                              });
                              AppointmentCubit().get(context).getOrders(
                                  ordersIdsFromAppointments: ordersIds,
                                  user: user!);
                            },

                            // separator: SizedBox(
                            //   height: 42.h,
                            // ),
                            // padding:  EdgeInsets.symmetric(horizontal: 24.3.w, vertical: 21.3.h),
                            itemBuilder: (context, documentSnapshot, index) {
                              AppAppointments appointment =
                                  AppAppointments.fromMap(
                                      documentSnapshot[index].data() as Map);
                              return Padding(
                                padding: EdgeInsets.only(top: AppPadding.p32.h),
                                child: UserAppointmentWiget(
                                  appointment: appointment,
                                  loggedUser: user!,
                                ),
                              );
                            },

                            onEmpty: SizedBox(),
                            query: FirebaseFirestore.instance
                                .collection(Paths.appAppointments)
                                .where('user.uid', isEqualTo: user!.uid)
                                .where('appointmentStatus', isEqualTo: "open")
                                .orderBy('secondValue', descending: true),
                            isLive: true,
                          )
                        : SizedBox(),

                    // SizedBox(
                    //   height: convertPtToPx(AppSize.h24.h),
                    // ),

                    fixed
                        ? BlocConsumer<AppointmentCubit, AppointmentState>(
                            listener: (context, state) {},
                            builder: (context, state) {
                              AppointmentCubit cubit =
                                  AppointmentCubit().get(context);

                              if (state is AppointmentUpdateOrdersLoading) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: AppPadding.p32.h),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              } else if (cubit.orders.isEmpty &&
                                  cubit.isEmpty == true) {
                                return Padding(
                                  padding: EdgeInsets.only(top: AppSize.h251.h),
                                  child: Text(
                                    getTranslated(
                                        context, "notHaveAppointments"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, 'Ithra'),
                                      fontSize: AppFontsSizeManager.s28.sp,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                );
                              } else if (cubit.orders.isEmpty) {
                                return SizedBox();
                              } else {
                                return
                                    //Text('fdjkghjkdfhgjkdfjk');
                                    ListView.separated(
                                  padding: EdgeInsets.all(0),
                                  itemCount: cubit.orders.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return
                                        //  Text('fdjkghjkdfhgjkdfjk');
                                        PreviousOrderWidget(
                                      loggedUser: user!,
                                      order: cubit.orders[index],
                                    );
                                  },
                                  separatorBuilder: (context, index) =>
                                      SizedBox(
                                    height: 0,
                                  ),
                                );
                              }
                            },
                          )
                        : SizedBox(),

                    ///closed app
                    closed
                        ? PaginateFirestore(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            separator: SizedBox(
                              height: 42.h,
                            ),
                            itemBuilderType: PaginateBuilderType.listView,
                            // padding:  EdgeInsets.symmetric(horizontal: 24.3.w, vertical: 21.3.h),
                            itemBuilder: (context, documentSnapshot, index) {
                              return UserAppointmentWiget(
                                appointment: AppAppointments.fromMap(
                                    documentSnapshot[index].data() as Map),
                                loggedUser: user!,
                              );
                            },
                            query: FirebaseFirestore.instance
                                .collection(Paths.appAppointments)
                                .where('user.uid', isEqualTo: user!.uid)
                                .where('appointmentStatus', isEqualTo: "closed")
                                .orderBy('secondValue', descending: true),
                            isLive: true,
                          )
                        : SizedBox(),

                    SizedBox(
                      height: AppSize.h40.h,
                    ),
                  ],
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
