import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/question/editQuestionScreen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/questions.dart';

class QuestionListItem extends StatefulWidget {
  final Questions question;
  final GroceryUser user;

  QuestionListItem({required this.question, required this.user});

  @override
  _QuestionListItemState createState() => _QuestionListItemState();
}

class _QuestionListItemState extends State<QuestionListItem>
    with SingleTickerProviderStateMixin {
  bool open = false;
  String lang = "ar";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");
    return Container(
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                open = !open;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: AppSize.w10_6.w,
                      decoration: BoxDecoration(
                        color: AppColors.linear2,
                        borderRadius: BorderRadius.circular(AppRadius.r20.r),
                      ),
                      height: AppSize.h7,
                    ),
                    SizedBox(
                      width: AppSize.w16.w,
                    ),
                    Container(
                      width: size.width * AppSize.w0_75,
                      child: InkWell(
                        onTap: () {
                          (widget.user != null &&
                                  widget.user.userType == "SUPPORT")
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditQuestionScreen(
                                        questions: widget.question),
                                  ),
                                )
                              : SizedBox();
                        },
                        child: Text(
                          lang == "ar"
                              ? widget.question.arQuestion
                              : (lang == "fr")
                                  ? widget.question.frQuestion
                                  : widget.question.enQuestion,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              color: AppColors.black2,
                              fontWeight: FontWeight.w600,
                              //fontFamily: "Montserrat",
                              fontStyle: FontStyle.normal,
                              fontSize: AppFontsSizeManager.s21_3.sp),
                        ),
                      ),
                    ),
                  ],
                ),
                InkWell(
                  splashColor: AppColors.white.withOpacity(0.5),
                  onTap: () {
                    setState(() {
                      open = !open;
                    });
                  },
                  child: Image.asset(
                    open
                        ? AssetsManager.ios_purple_down_iconPath
                        : AssetsManager.ios_purple_left_iconPath,
                    width: AppSize.w21_3.w,
                    height: AppSize.h21_3.h,
                    //color: AppColors.pureBlack.withOpacity(0.5),
                    //size: AppSize.w20,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0),
          open
              ? Column(
                  children: [
                    SizedBox(height: AppSize.h24.h),
                    IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            color: AppColors.pink,
                            width: AppSize.w3,
                          ),
                          SizedBox(
                            width: AppSize.w16.w,
                          ),
                          Expanded(
                            child: Text(
                              lang == "ar"
                                  ? widget.question.arAnswer
                                  : (lang == "fr")
                                      ? widget.question.frAnswer
                                      : widget.question.enAnswer,
                              textAlign: TextAlign.start,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                              style: TextStyle(
                                color: AppColors.grey5,
                                wordSpacing: 0,
                                //  fontWeight: FontWeight.w300,
                                fontFamily:
                                    getTranslated(context, 'Ithralight'),
                                fontStyle: FontStyle.normal,
                                fontSize: AppFontsSizeManager.s18_6.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    widget.question.link == null
                        ? SizedBox()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: AppSize.w30,
                                width: AppSize.w30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.white,
                                  boxShadow: [AppShadow.primaryShadow],
                                ),
                                child: Center(
                                  child: InkWell(
                                    onTap: () async {
                                      var url = widget.question.link;
                                      if (widget.question.link != null) {
                                        if (!url!.contains('http')) {
                                          url = 'https://$url';
                                        }
                                        await launch(url);
                                      }
                                    },
                                    child: Icon(
                                      Icons.play_circle_outline,
                                      color: Theme.of(context).primaryColor,
                                      size: AppSize.w20,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: AppSize.w5,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getTranslated(context, "watch"),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, 'Ithra'),
                                      color: AppColors.pink,
                                      fontSize: AppFontsSizeManager.s10,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    getTranslated(context, "explain"),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, 'Ithra'),
                                      color: AppColors.pink,
                                      fontSize: AppFontsSizeManager.s10,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ],
                )
              : SizedBox(),
          // SizedBox(
          //   height: AppSize.h20_6.h,
          // ),
        ],
      ),
    );
  }
}
