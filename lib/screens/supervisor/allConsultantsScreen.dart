

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';

import '../../FireStorePagnation/paginate_firestore.dart';
import '../../config/assets_manager.dart';
import '../../config/colorsFile.dart';
import '../../widget/supervisorWidgets/consultItemWidget.dart';


class AllConsultantScreen extends StatefulWidget {
  final GroceryUser loggedUser;

  const AllConsultantScreen({Key? key, required this.loggedUser}) : super(key: key);
  @override
  _AllConsultantScreenState createState() => _AllConsultantScreenState();
}

class _AllConsultantScreenState extends State<AllConsultantScreen>with SingleTickerProviderStateMixin {
  final TextEditingController searchController = new TextEditingController();
  bool load=false,active=true,notActive=false;
  late Query filterQuery;
  @override
  void initState() {
    super.initState();
  }
  @override
  void didChangeDependencies() {
     filterQuery=FirebaseFirestore.instance.collection(Paths.usersPath)
        .where('userType', isEqualTo: 'CONSULTANT')
        .where('accountStatus', isEqualTo: "Active")
        .where('languages', arrayContains:getTranslated(context, "lang"))
        .orderBy('order', descending: true);
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(backgroundColor: AppColors.white,
      body: Column(
        children: <Widget>[
          Container( width: size.width,
              child: SafeArea(
                  child: Padding(                     padding: EdgeInsets.only(right: AppPadding.p32.w, top: AppPadding.p35.h, bottom: AppPadding.p20.h),

                    child: Row(mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: AppSize.h35,
                          width: AppSize.w35,
                          child: Center(
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Image.asset(
                                AssetsManager.purple_left_arrowPath,

                                width: AppSize.w30,
                                height: AppSize.h30,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          getTranslated(context, "consultNum"),
                          textAlign:TextAlign.left,
                          style: TextStyle( fontFamily: getTranslated(context, "Ithra"),fontSize: AppFontsSizeManager.s15.sp,color:AppColors.pureBlack.withOpacity(0.6),fontWeight: FontWeight.bold ),
                        ),
                      ],
                    ),
                  ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey, height: AppSize.h2, width: size.width * AppSize.w0_9)),
          Padding(
            padding: const EdgeInsets.only(top: AppPadding.p20,right: AppPadding.p25,left: AppPadding.p25,bottom: AppPadding.p20),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    splashColor: Colors.green.withOpacity(0.6),
                    onTap: () {
                      setState(() {
                        active=true;
                        notActive=false;
                        filterQuery=FirebaseFirestore.instance.collection(Paths.usersPath)
                            .where('userType', isEqualTo: 'CONSULTANT')
                            .where('accountStatus', isEqualTo: "Active")
                            .where('languages', arrayContains:getTranslated(context, "lang"))
                            .orderBy('order', descending: true);
                      });
                    },
                    child: Container(height: AppSize.h40,width: size.width*AppSize.w0_35,
                      padding: const EdgeInsets.all(AppPadding.p5),
                      decoration: BoxDecoration(
                        color: active?Theme.of(context).primaryColor:AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(AppRadius.r10_6),
                      ),child:Center(
                        child: Text(
                          getTranslated(context, "active"),
                          textAlign: TextAlign.center,
                          style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                            color: active?AppColors.white:Theme.of(context).primaryColor,
                            fontSize: AppFontsSizeManager.s15.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),),
                  ),
                  SizedBox(width: AppSize.w5,),
                  InkWell(
                    splashColor: Colors.green.withOpacity(0.6),
                    onTap: () {
                      setState(() {
                        active=false;
                        notActive=true;
                        filterQuery=FirebaseFirestore.instance.collection(Paths.usersPath)
                            .where('userType', isEqualTo: 'CONSULTANT')
                            .where('accountStatus', isEqualTo: "NotActive")
                            .where('userLang', isEqualTo:getTranslated(context, "lang"))
                            .orderBy('utcTime', descending: true);
                      });
                    },
                    child: Container(height: AppSize.h40,width: size.width*AppSize.w0_35,
                      padding: const EdgeInsets.all(AppPadding.p5),
                      decoration: BoxDecoration(
                        color: notActive?AppColors.pink:AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(AppRadius.r10_6),
                      ),child:Center(
                        child: Text(
                          getTranslated(context, "notActive"),
                          textAlign: TextAlign.center,
                          style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                            color: notActive?AppColors.white:Theme.of(context).primaryColor,
                            fontSize: AppFontsSizeManager.s15.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),),
                  ),
                ]),
          ),
          Expanded(
            child: PaginateFirestore(
              key: ValueKey(filterQuery),
              separator: SizedBox(height: AppSize.h30,),
              itemBuilderType: PaginateBuilderType.listView,
              padding: const EdgeInsets.only(
                  left: AppPadding.p16, right: AppPadding.p16, bottom: AppPadding.p16, top: AppPadding.p16),//Change types accordingly
              itemBuilder: ( context, documentSnapshot,index) {
                return  consultItemWidget(
                  consult: GroceryUser.fromMap(documentSnapshot[index].data() as Map), loggedUser: widget.loggedUser,
                );

              },
              query:filterQuery,
              isLive: true,
            ),
          )

        ],
      ),
    );
  }

}
