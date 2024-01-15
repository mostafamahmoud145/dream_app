import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/questions.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/question/addQuestionScreen.dart';
import 'package:grocery_store/widget/searchfield.dart';

import '../../FireStorePagnation/paginate_firestore.dart';
import '../../widget/back_button.dart';
import '../../widget/questionListItem.dart';

class QuestionScreen extends StatefulWidget {
  final GroceryUser user;

  const QuestionScreen({Key? key, required this.user}) : super(key: key);

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen>
    with SingleTickerProviderStateMixin {
  late List<Questions> allQuestions;

  final TextEditingController searchController = new TextEditingController();
  bool load = false;
  String text = "";
  late Query filterQuery;
  late Size size;
  late String lang;

  @override
  void initState() {
    super.initState();
    initiateSearch(text);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
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
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomBackButton(),
                      // IconButton1(
                      //   radius: AppRadius.r10_6.r,
                      //   color: AppColors.white,
                      //   shadowcolor: AppColors.warmPurple,
                      //   iconsize: 30.r,
                      //   icon: lang=="ar"? AssetsManager.purple_right_arrowPath:AssetsManager.purple_left_arrowPath,
                      //   iconcolor: AppColors.linear2,
                      //   onPress: () {
                      //     Navigator.pop(context);
                      //   },
                      //   width: AppSize.w50_6.w,
                      //   height: AppSize.h50_6.h,
                      // ),
                      SizedBox(
                        width: AppSize.w21_3.w,
                      ),
                      Text(
                        getTranslated(context, "questions"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithra'),
                            fontSize: AppFontsSizeManager.s21_3.sp,
                            color: AppColors.appbartext,
                            fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      (widget.user != null && widget.user.userType == "SUPPORT")
                          ? IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddQuestionScreen(),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.post_add_outlined,
                                color: AppColors.pink,
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                )),
            SizedBox(
              height: AppSize.h16.h,
            ),
            Container(
              height: AppSize.h0_8.h,
              width: double.infinity,
              color: AppColors.grey,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: AppPadding.p32.w,
                right: AppPadding.p32.w,
                top: AppPadding.p32.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getTranslated(context, "hello"),
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                            fontFamily: getTranslated(context, 'Ithra'),
                            fontStyle: FontStyle.normal,
                            fontSize: AppFontsSizeManager.s21_3.sp),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: AppSize.h10_6.h,
                      ),
                      Text(
                        getTranslated(context, "howCanWeHelp"),
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                            fontFamily: getTranslated(context, 'Ithra'),
                            fontStyle: FontStyle.normal,
                            fontSize: AppFontsSizeManager.s21_3.sp),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Padding(
            //     padding: EdgeInsets.only(
            //         top: AppPadding.p37_3.h,
            //         right: AppPadding.p32.w,
            //         bottom: AppPadding.p21_3.h,
            //         left: AppPadding.p32.h),
            //     child: Center(
            //         child: Container(
            //       decoration: BoxDecoration(
            //         border:
            //             Border.all(color: AppColors.grey, width: AppSize.w1.w),
            //         color: AppColors.white,
            //         borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
            //       ),
            //       height: AppSize.h70_6.h,
            //       width: double.infinity,
            //       child: Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             searchfield1(
            //               prefixIconColor: AppColors.searchIcon,
            //               text: getTranslated(context, "askQuestion"),
            //               width: double.infinity,
            //               height: AppSize.h30,
            //               textSize: AppFontsSizeManager.s18_6.sp,
            //               textfont: getTranslated(context, 'Ithralight'),
            //               textcolor: AppColors.grey,
            //               icon: Image.asset(AssetsManager.searchIcon),
            //               iconwidth: AppSize.w5.w,
            //               iconheight: AppSize.h5.h,
            //               iconcolor: AppColors.warmGrey,
            //               radius: 0,
            //               boxcolor: AppColors.white,
            //               searchController: searchController,
            //               function: (String value) {
            //                 if (value == "")
            //                   setState(() {
            //                     filterQuery = FirebaseFirestore.instance
            //                         .collection(Paths.questionPath)
            //                         .where('status', isEqualTo: true)
            //                         .orderBy('order', descending: false);
            //                   });
            //                 else {
            //                   if (lang == "ar")
            //                     setState(() {
            //                       filterQuery = FirebaseFirestore.instance
            //                           .collection(Paths.questionPath)
            //                           .where('searchIndexAr',
            //                               arrayContains: text)
            //                           .where('status', isEqualTo: true)
            //                           .orderBy('order', descending: false);
            //                     });
            //                   else if (lang == "fr")
            //                     setState(() {
            //                       filterQuery = FirebaseFirestore.instance
            //                           .collection(Paths.questionPath)
            //                           .where('searchIndexFR',
            //                               arrayContains: text)
            //                           .where('status', isEqualTo: true)
            //                           .orderBy('order', descending: false);
            //                     });
            //                   else
            //                     setState(() {
            //                       filterQuery = FirebaseFirestore.instance
            //                           .collection(Paths.questionPath)
            //                           .where('searchIndexEn',
            //                               arrayContains: text)
            //                           .where('status', isEqualTo: true)
            //                           .orderBy('order', descending: false);
            //                     });
            //                 }
            //               },
            //               horizontalpadding: AppPadding.p5,
            //               verticalpadding: AppPadding.p16.h,
            //             ),

            //             ///
            //             InkWell(
            //                 onTap: () {
            //                   initiateSearch(searchController.text);
            //                 },
            //                 child: Padding(
            //                   padding: const EdgeInsets.all(AppPadding.p5),
            //                   child: Container(
            //                     height: AppSize.h49_3.h,
            //                     width: AppSize.w112.w,
            //                     decoration: BoxDecoration(
            //                         color: AppColors.pink,
            //                         borderRadius:
            //                             BorderRadius.circular(AppRadius.r5.r)),
            //                     child: Center(
            //                       child: Text(
            //                         getTranslated(context, "ask"),
            //                         textAlign: TextAlign.center,
            //                         style: TextStyle(
            //                           fontFamily:
            //                               getTranslated(context, "Ithra"),
            //                           color: AppColors.white,
            //                           fontSize: AppFontsSizeManager.s18_6.sp,
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                 ))
            //           ]),
            //     ))),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppSize.h32.h, vertical: AppPadding.p37_3.h),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.lightGray, width: AppSize.w1.w),
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                  ),
                  // decoration: BoxDecoration(
                  //   color: AppColors.white4,
                  //   borderRadius: BorderRadius.circular(AppRadius.r7),
                  // ),
                  height: AppSize.h70_6.h,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      searchfield1(
                        prefixIconColor: AppColors.searchIcon,
                        text: getTranslated(context, "askQuestion"),
                        width: size.width * AppSize.w0_6,
                        height: AppSize.h30,
                        textSize: AppFontsSizeManager.s18_6.sp,
                        textfont: getTranslated(context, 'Ithralight'),
                        textcolor: AppColors.warmGrey,
                        icon: SvgPicture.asset(AssetsManager.searchIconPath),
                        iconwidth: AppSize.w5.w,
                        iconheight: AppSize.h5.h,
                        iconcolor: AppColors.warmGrey,
                        radius: AppRadius.r5,
                        boxcolor: AppColors.white,
                        searchController: searchController,
                        function: (String value) {
                          if (value == "")
                            setState(() {
                              filterQuery = FirebaseFirestore.instance
                                  .collection(Paths.questionPath)
                                  .where('status', isEqualTo: true)
                                  .orderBy('order', descending: false);
                            });
                          else {
                            if (lang == "ar")
                              setState(() {
                                filterQuery = FirebaseFirestore.instance
                                    .collection(Paths.questionPath)
                                    .where('searchIndexAr', arrayContains: text)
                                    .where('status', isEqualTo: true)
                                    .orderBy('order', descending: false);
                              });
                            else if (lang == "fr")
                              setState(() {
                                filterQuery = FirebaseFirestore.instance
                                    .collection(Paths.questionPath)
                                    .where('searchIndexFR', arrayContains: text)
                                    .where('status', isEqualTo: true)
                                    .orderBy('order', descending: false);
                              });
                            else
                              setState(() {
                                filterQuery = FirebaseFirestore.instance
                                    .collection(Paths.questionPath)
                                    .where('searchIndexEn', arrayContains: text)
                                    .where('status', isEqualTo: true)
                                    .orderBy('order', descending: false);
                              });
                          }
                        },
                        horizontalpadding: AppPadding.p5,
                        verticalpadding: AppPadding.p16.h,
                      ),

                      ///
                      InkWell(
                        onTap: () {
                          initiateSearch(searchController.text);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: AppPadding.p10_6.w),
                          child: Container(
                            height: AppSize.h49_3.h,
                            width: AppSize.w112.w,
                            decoration: BoxDecoration(
                                color: AppColors.linear5,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r5.r)),
                            child: Center(
                              child: Text(
                                getTranslated(context, "ask"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  color: AppColors.white,
                                  fontSize: AppFontsSizeManager.s18_6.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: PaginateFirestore(
                key: ValueKey(filterQuery),
                separator: Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: AppPadding.p32.h, top: AppPadding.p32.h),
                    child: Container(
                        color: AppColors.lightGrey,
                        height: AppSize.h1.h,
                        width: double.infinity),
                  ),
                ),
                itemBuilderType: PaginateBuilderType.listView,
                padding: EdgeInsets.only(
                  left: AppPadding.p32.w,
                  right: AppPadding.p32.w,
                  //bottom: ,
                  //top: AppPadding.p16
                ),
                //Change types accordingly
                itemBuilder: (context, documentSnapshot, index) {
                  return QuestionListItem(
                      question: Questions.fromMap(
                          documentSnapshot[index].data() as Map),
                      user: widget.user);
                },
                query: filterQuery,
                // to fetch real-time data
                isLive: true,
              ),
            )
          ],
        ),
      ),
    );
  }

  void initiateSearch(String text) {
    if (text == "")
      setState(() {
        filterQuery = FirebaseFirestore.instance
            .collection(Paths.questionPath)
            .where('status', isEqualTo: true)
            .orderBy('order', descending: false);
      });
    else {
      if (lang == "ar")
        setState(() {
          filterQuery = FirebaseFirestore.instance
              .collection(Paths.questionPath)
              .where('searchIndexAr', arrayContains: text)
              .where('status', isEqualTo: true)
              .orderBy('order', descending: false);
        });
      else if (lang == "fr")
        setState(() {
          filterQuery = FirebaseFirestore.instance
              .collection(Paths.questionPath)
              .where('searchIndexFR', arrayContains: text)
              .where('status', isEqualTo: true)
              .orderBy('order', descending: false);
        });
      else
        setState(() {
          filterQuery = FirebaseFirestore.instance
              .collection(Paths.questionPath)
              .where('searchIndexEn', arrayContains: text)
              .where('status', isEqualTo: true)
              .orderBy('order', descending: false);
        });
    }
  }
}
