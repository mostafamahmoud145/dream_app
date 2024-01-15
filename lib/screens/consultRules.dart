
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/UnorderedList.dart';
import 'package:grocery_store/models/user.dart';

import '../methods/convert_pt_to_px.dart';
import '../widget/back_button.dart';
import 'account_screen.dart';

class consultRuleScreen extends StatefulWidget {
  final GroceryUser user;

  const consultRuleScreen({Key? key, required this.user}) : super(key: key);

  @override
  _consultRuleScreenState createState() => _consultRuleScreenState();
}

class _consultRuleScreenState extends State<consultRuleScreen>with SingleTickerProviderStateMixin {
  bool isLoading=true,accept=false;
  String url="https://dream-app.net/dream-app/?lang=ar",lang="ar";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang=getTranslated(context,"lang");
    return Scaffold(backgroundColor: AppColors.white,
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
                          getTranslated(context, "terms"),
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
          // SizedBox(
          //   height:AppSize.h42.h,
          // ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppPadding.p20),
              child: ListView(children: [
                UnorderedList([
                  getTranslated(context, "rule1"),
                  getTranslated(context, "rule2"),
                  getTranslated(context, "rule3"),
                  getTranslated(context, "rule4"),
                  getTranslated(context, "rule5"),
                  getTranslated(context, "rule6")
                ]),
                SizedBox(height: AppSize.h10.h,),
                Row(
                  children: [
                    Checkbox(
                      value: accept,
                      onChanged: (value) {
                        setState(() {
                          accept = !accept;
                        });
                      },
                    ),
                    Text(
                      getTranslated(context, "agree"),
                      style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                        fontSize: AppFontsSizeManager.s18.sp,
                        fontWeight: AppFontsWeightManager.bold500,
                        color: AppColors.pink,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSize.h20.h,),
                accept==true?Container(
                  width: size.width*AppSize.w0_6,
                  height: AppSize.h45,
                  child: MaterialButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountScreen(user: widget.user),),);
                    },
                    color: Colors.lightGreen ,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r40.r),
                    ),
                    child: Text(
                      getTranslated(context, "saveAndContinue"),
                      style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.white,
                        fontSize: AppFontsSizeManager.s18.sp,
                        fontWeight: AppFontsWeightManager.bold700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ):SizedBox(),
              ],),
            ),
          ),
        ],
      ),
    );
  }
}
