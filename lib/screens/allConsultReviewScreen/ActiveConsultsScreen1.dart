
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/addFakeReview.dart';
import 'package:grocery_store/widget/consultantListItem1.dart';

import '../../FireStorePagnation/paginate_firestore.dart';

class ActiveConsultsScreen1 extends StatefulWidget {
   final GroceryUser loggedUser;
   const ActiveConsultsScreen1({ required this.loggedUser, });
  @override
  _ActiveConsultsScreen1State createState() => _ActiveConsultsScreen1State();
}

class _ActiveConsultsScreen1State extends State<ActiveConsultsScreen1>with SingleTickerProviderStateMixin {
  late List<GroceryUser> activeList;
  late GroceryUser user;
  final TextEditingController searchController = new TextEditingController();
  bool load=false;
  late String lang,userImage,theme;
  String name ="";
  late Query filterQuery;
  @override
  void initState() {
    super.initState();

    activeList = [];

  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
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

                  child: Container(height: 80,
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
                                  color: AppColors.white,
                                  size:AppSize.w24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          getTranslated(context, "activeConsult"),
                          style: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontSize: AppFontsSizeManager.s19.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddFakeReviewScreen(user: user),
                              ),
                            );
                          },
                          child: Icon(Icons.add_circle_outline,
                              size: AppSize.w20, color: AppColors.white),
                        ),
                        SizedBox(width: AppSize.w10)
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30,),
            name==""?Expanded(
              child: PaginateFirestore(
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: AppPadding.p16, right: AppPadding.p16, bottom: AppPadding.p16, top: AppPadding.p16),//Change types accordingly
                itemBuilder: (context, documentSnapshot,index) {
                  return  ConsultantListItem1(
                    consult: GroceryUser.fromMap(documentSnapshot[index].data() as Map ),
                      loggedUser:widget.loggedUser
                  );

                },
                query: FirebaseFirestore.instance.collection('Users')
                    .where('userType', isEqualTo: 'CONSULTANT')
                    .where('accountStatus', isEqualTo: "Active")
                    .orderBy('createdDateValue', descending: true),
                // to fetch real-time data
                isLive: true,
              ),
            ):SizedBox(),
            name!=""?Expanded(
              child: PaginateFirestore(
                key: ValueKey(filterQuery),
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: AppPadding.p16, right: AppPadding.p16, bottom: AppPadding.p16, top: AppPadding.p16),//Change types accordingly
                itemBuilder: (context, documentSnapshot,index) {
                  return  ConsultantListItem1(
                    consult: GroceryUser.fromMap(documentSnapshot[index].data() as Map),
                      loggedUser:widget.loggedUser
                  );
                },

                query:filterQuery,
                isLive: true,
              ),
            ):SizedBox(),
          ],
        ),
        Positioned(
            right: 0.0,
            top: 100.0,
            left: 0,
            child:  Center(child: Container(height: AppSize.h40,width: size.width*AppSize.w0_8,child:
            Container(
              //height: 35.0,
              //width: size.width*.45,
              padding: const EdgeInsets.symmetric( horizontal: AppPadding.p1, vertical: 0.0),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.r20),
                boxShadow: [
                  AppShadow.primaryShadow
                ],
              ),
              child: Center(
                child: TextField(
                  onChanged: (val) => initiateSearch(val),
                  keyboardType: TextInputType.text,
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  enableInteractiveSelection: true,
                  readOnly:false,
                  style: GoogleFonts.cairo(
                    fontSize: 14.5.sp,
                    color: AppColors.black1,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: AppPadding.p5, vertical: AppPadding.p8),
                    prefixIcon: Image.asset(
                      AssetsManager.search_iconPath,
                      width: AppSize.w30,
                      height: AppSize.h30,
                    ),
                    suffixIcon: InkWell(
                        child: Icon(Icons.send_rounded, size: AppSize.w16), onTap: () {
                      initiateMobileSearch(searchController.text);
                    }),
                    border: InputBorder.none,
                    hintText: getTranslated(context, "search"),
                    hintStyle: GoogleFonts.cairo(
                      fontSize: AppFontsSizeManager.s14_5.sp,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: AppConstants.letterSpacing,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            ),)
        ),
      ]),
    );
  }

  void initiateSearch(String val) {
    setState(() {
      name = val.toLowerCase().trim();
      filterQuery=FirebaseFirestore.instance.collection(Paths.usersPath)
          .where('userType', isEqualTo: "CONSULTANT" )
          .where('accountStatus', isEqualTo: "Active" )
          .where('searchIndex', arrayContains: name)
          .orderBy('createdDateValue', descending: true);
    });
  }
  void initiateMobileSearch(String val) {
    setState(() {
      name = val.toLowerCase().trim();
      filterQuery=FirebaseFirestore.instance.collection(Paths.usersPath)
          .where('userType', isEqualTo: "CONSULTANT" )
          .where('accountStatus', isEqualTo: "Active" )
      // .where('searchIndex', arrayContains: name)
          .where('phoneNumber', isEqualTo: name)
          .orderBy('createdDateValue', descending: true);
    });
  }
}