import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/methods/convert_pt_to_px.dart';

import '../config/colorsFile.dart';
import '../localization/localization_methods.dart';
import '../models/user.dart';
import '../widget/back_button.dart';
import '../widget/youtubePlayerWidget.dart';

class BioDetailsScreen extends StatefulWidget {
  final GroceryUser consult;
  final bool avaliable;

  const BioDetailsScreen(
      {Key? key, required this.consult, required this.avaliable})
      : super(key: key);

  @override
  _BioDetailsScreenState createState() => _BioDetailsScreenState();
}

class _BioDetailsScreenState extends State<BioDetailsScreen> {
  String theme = "light";
  bool load = true;
  String lang = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding(
                padding: EdgeInsets.only(
                    right: AppPadding.p32.w,
                    left: lang == "ar" ? AppPadding.p0 : AppPadding.p32.w,
                    top: AppPadding.p35.h,
                    bottom: AppPadding.p20.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomBackButton(),
                    SizedBox(width: AppSize.w21_3.w),
                    Text(
                      getTranslated(context, "bio"),
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
                  color: AppColors.lightGrey6,
                  height: convertPtToPx(AppSize.h1).h,
                  width: size.width)),
          Expanded(
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppPadding.p20),
                  child: ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: AppSize.h148.h,
                                  width: AppSize.w148.w,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.white5,
                                        width: AppSize.w1.w),
                                    shape: BoxShape.circle,
                                    color: AppColors.white,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.white,
                                          width: AppSize.w6.w),
                                      shape: BoxShape.circle,
                                      color: AppColors.white,
                                    ),
                                    child: widget.consult.photoUrl!.isEmpty
                                        ? Image.asset(
                                            AssetsManager
                                                .dreamLogoPurpleImagePath,
                                            width: AppSize.w90_5.w,
                                            height: AppSize.h90_5.h,
                                            fit: BoxFit.fill,
                                          )
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.r100.r),
                                            child: FadeInImage.assetNetwork(
                                              placeholder:
                                                  AssetsManager.purple_logo,
                                              placeholderScale: 0.5,
                                              imageErrorBuilder: (context,
                                                      error, stackTrace) =>
                                                  Image.asset(
                                                      AssetsManager
                                                          .dreamLogoPurpleImagePath,
                                                      width: AppSize.w90_5.w,
                                                      height: AppSize.h90_5.h,
                                                      fit: BoxFit.fill),
                                              image: widget.consult.photoUrl!,
                                              fit: BoxFit.cover,
                                              fadeInDuration:
                                                  Duration(milliseconds: 250),
                                              fadeInCurve: Curves.easeInOut,
                                              fadeOutDuration:
                                                  Duration(milliseconds: 150),
                                              fadeOutCurve: Curves.easeInOut,
                                            ),
                                          ),
                                  ),
                                ),
                                Image.asset(
                                  AssetsManager.dashBoarderImagePath,
                                  height: AppSize.h160.h,
                                  width: AppSize.w160.w,
                                ),
                                Positioned(
                                  bottom: AppSize.h11.h,
                                  left: AppSize.w26_5.w,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      // border: Border.all(color: AppColors.white,width: 2),
                                      shape: BoxShape.circle,
                                      color: widget.avaliable == true
                                          ? AppColors.greenButton
                                          : AppColors.red,
                                    ),
                                    width: AppSize.w10_6.w,
                                    height: AppSize.h10_6.h,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: AppSize.h21_3.h,
                        ),
                        Center(
                          child: Text(
                            getTranslated(context, "lang") == "ar"
                                ? widget.consult.consultName!.nameAr!
                                : getTranslated(context, "lang") == "en"
                                    ? widget.consult.consultName!.nameEn!
                                    : getTranslated(context, "lang") == "fr"
                                        ? widget.consult.consultName!.nameFr!
                                        : widget.consult.consultName!.nameId!,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              color: AppColors.black,
                              fontSize: AppFontsSizeManager.s21_3.sp,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: AppSize.h32.h,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppPadding.p32.w),
                          child: Stack(children: [
                            Text(
                              textAlign: TextAlign.center,
                              getTranslated(context, "lang") == "ar"
                                  ? widget.consult.consultBio!.bioAr!
                                  : getTranslated(context, "lang") == "en"
                                      ? widget.consult.consultBio!.bioEn!
                                      : getTranslated(context, "lang") == "fr"
                                          ? widget.consult.consultBio!.bioFr!
                                          : widget.consult.consultBio!.bioId!,
                              style: TextStyle(
                                fontSize: AppFontsSizeManager.s18_6.sp,
                                fontFamily: getTranslated(context, 'Ithra'),
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 0.4
                                  ..color = AppColors.grey7,
                              ),
                            ),
                            Text(
                              textAlign: TextAlign.center,
                              getTranslated(context, "lang") == "ar"
                                  ? widget.consult.consultBio!.bioAr!
                                  : getTranslated(context, "lang") == "en"
                                      ? widget.consult.consultBio!.bioEn!
                                      : getTranslated(context, "lang") == "fr"
                                          ? widget.consult.consultBio!.bioFr!
                                          : widget.consult.consultBio!.bioId!,
                              style: TextStyle(
                                fontFamily: getTranslated(context, 'Ithra'),
                                color: AppColors.grey7,
                                fontSize: AppFontsSizeManager.s18_6.sp,
                              ),
                            ),
                          ]),
                        ),
                        SizedBox(
                          height: AppSize.h129.h,
                        ),
                        (widget.consult.link != null &&
                                widget.consult.link != "")
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child:
                                    YouTubeVideoRow(link: widget.consult.link!))
                            : SizedBox(),
                        (widget.consult.link != null &&
                                widget.consult.link != "")
                            ? SizedBox(
                                height: AppSize.h30.h,
                              )
                            : SizedBox(),
                      ]))),
          Container(
              width: AppSize.w204.w,
              height: AppSize.h9_5.h,
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.all(Radius.circular(AppRadius.r4.r)),
                  color: AppColors.lightGrey)),
          SizedBox(height: AppSize.h25.h),
        ],
      ),
    );
  }
}
