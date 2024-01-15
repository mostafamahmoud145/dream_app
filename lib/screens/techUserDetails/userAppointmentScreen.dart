import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/techAppointmentWidget.dart';

import '../../FireStorePagnation/paginate_firestore.dart';
import '../../config/colorsFile.dart';
import '../../methods/convert_pt_to_px.dart';
import '../../widget/back_button.dart';

class UserAppointmentsScreen extends StatefulWidget {
  final GroceryUser user;
  final GroceryUser loggedUser;

  const UserAppointmentsScreen(
      {Key? key, required this.user, required this.loggedUser})
      : super(key: key);

  @override
  _UserAppointmentsScreenState createState() => _UserAppointmentsScreenState();
}

class _UserAppointmentsScreenState extends State<UserAppointmentsScreen>
    with SingleTickerProviderStateMixin {
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
              child: SafeArea(
                  child: Padding(
                    padding:  EdgeInsets.symmetric(horizontal: convertPtToPx(AppPadding.p24).w, vertical: convertPtToPx(AppPadding.p15).h,),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomBackButton(),

                        SizedBox(width: AppSize.w21_3.w),
                        Text(
                          getTranslated(context, "appointments"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              fontSize: AppFontsSizeManager.s21.sp,
                              color: AppColors.pureBlack.withOpacity(0.8),
                              fontWeight: AppFontsWeightManager.bold),
                        ),
                      ],
                    ),
                  ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey,
                  height: AppSize.h2.h,
                  width: size.width )),
          SizedBox(
            height: AppSize.h30,
          ),
          Expanded(
            child: PaginateFirestore(
              itemBuilderType: PaginateBuilderType.listView,
              padding: const EdgeInsets.only(
                  left: AppPadding.p16,
                  right: AppPadding.p16,
                  bottom: AppPadding.p16,
                  top: AppPadding.p16),
              //Change types accordingly
              separator: SizedBox(
                height: AppSize.h30,
              ),
              itemBuilder: (context, documentSnapshot, index) {
                return TechAppointmentWiget(
                  appointment: AppAppointments.fromMap(
                      documentSnapshot[index].data() as Map),
                  loggedUser: widget.loggedUser,
                );
              },
              query: widget.user.userType == AppConstants.user
                  ? FirebaseFirestore.instance
                      .collection(Paths.appAppointments)
                      .where('user.uid', isEqualTo: widget.user.uid)
                      .orderBy('secondValue', descending: true)
                  : FirebaseFirestore.instance
                      .collection(Paths.appAppointments)
                      .where('consult.uid', isEqualTo: widget.user.uid)
                      .orderBy('secondValue', descending: true),
              isLive: true,
            ),
          )
        ],
      ),
    );
  }
}
