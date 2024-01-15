

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/generalNotifications.dart';
import 'package:grocery_store/screens/push_notifications_screens/sendNotificationScreen.dart';
import 'package:grocery_store/widget/generalNotificationItem.dart';

import '../../FireStorePagnation/paginate_firestore.dart';

class AllSendedNotificationSreen extends StatefulWidget {
  @override
  _AllSendedNotificationSreenState createState() => _AllSendedNotificationSreenState();
}

class _AllSendedNotificationSreenState extends State<AllSendedNotificationSreen>with SingleTickerProviderStateMixin {
  final TextEditingController searchController = new TextEditingController();
  bool load=false;
   String lang="",userImage="",theme="light";
  String name ="";
  late Query filterQuery;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(backgroundColor: AppColors.white,
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: size.width,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.only(right: AppPadding.p32.w, top: AppPadding.p35.h, bottom: AppPadding.p20.h),

                  child: Container(height: AppSize.h81,
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
                                  color: theme=="light"?AppColors.white:AppColors.pureBlack,
                                  size: AppSize.w24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          getTranslated(context, "notification"),
                          style: GoogleFonts.poppins(
                            color: theme=="light"?AppColors.white:AppColors.pureBlack,
                            fontSize: AppFontsSizeManager.s19.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.r50),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: AppColors.white.withOpacity(0.5),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SendNotificationScreen(), ),);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                width: AppSize.w38,
                                height: AppSize.h35,
                                child: Icon(
                                  Icons.add_circle_outline,
                                  color: theme=="light"?AppColors.white:AppColors.pureBlack,
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
            ),
            SizedBox(height: AppSize.h10,),
            Expanded(
              child: PaginateFirestore(
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: AppPadding.p16, right: AppPadding.p16, bottom: AppPadding.p16, top: AppPadding.p16),//Change types accordingly
                itemBuilder: ( context, documentSnapshot,index) {
                  return  GeneralNotificationItem(
                    item: GeneralNotifications.fromMap(documentSnapshot[index].data() as Map),
                  );

                },
                query: FirebaseFirestore.instance.collection(Paths.generalNotificationsPath)
                    .orderBy('notificationTimestamp', descending: true),
                // to fetch real-time data
                isLive: true,
              ),
            ),

          ],
        ),

      ]),
    );
  }


}
