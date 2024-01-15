import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../screens/consultantDetailsScreen.dart';
import 'component/textWidget.dart';

class ConsultantListItem extends StatefulWidget {
  final GroceryUser? loggedUser;
  final GroceryUser consult;
  final String consultType;

  ConsultantListItem(
      {required this.consult, this.loggedUser, required this.consultType});

  @override
  _ConsultantListItemState createState() => _ConsultantListItemState();
}

class _ConsultantListItemState extends State<ConsultantListItem>
    with SingleTickerProviderStateMixin {
  bool sharing = false;
  String orderNum = "0";
  String lang = "";

  @override
  void initState() {
    if (widget.consult.ordersNumbers! < 100)
      orderNum = widget.consult.ordersNumbers.toString();
    else
      for (int x = 2; x < 1000000; x++) {
        if (widget.consult.ordersNumbers! < x * 100) {
          orderNum = ((x - 1) * 100).toString();
          break;
        }
      }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool avaliable = false;
    lang = getTranslated(context, "lang");
    DateTime _now = DateTime.now();
    String dayNow = _now.weekday.toString();
    int timeNow = _now.hour;

    if (widget.consult.workDays!.contains(dayNow)) {
      int localFrom = DateTime.parse(widget.consult.fromUtc!).toLocal().hour;
      int localTo = DateTime.parse(widget.consult.toUtc!).toLocal().hour;
      if (localTo == 0) localTo = 24;
      if (localFrom <= timeNow && localTo > timeNow) {
        avaliable = true;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConsultantDetailsScreen(
                consultant: widget.consult,
                loggedUser: widget.loggedUser,
                consultType: widget.consultType),
          ),
        );
      },
      child: Container(
        //height: AppSize.h300.h,
        width: AppSize.w244.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.r16.r),
          boxShadow: [AppShadow.primaryShadow],
        ),
        child: Stack(children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
                left: AppPadding.p16.w,
                right: AppPadding.p16.w,
                top: AppPadding.p16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        sharing
                            ? Container(
                                height: AppSize.h32.h,
                                width: AppSize.w32.w,
                                child: CircularProgressIndicator())
                            : InkWell(
                                onTap: () async {
                                  // Create DynamicLink
                                  share(context);
                                },
                                child: Container(
                                    height: AppSize.h32.r,
                                    width: AppSize.w32.r,
                                    decoration: BoxDecoration(
                                      color: AppColors.lightPurple,
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.r4.r),
                                    ),
                                    child: Center(
                                        child: Image.asset(
                                      AssetsManager.share_iconPath,
                                      width: AppSize.w21_3.r,
                                      height: AppSize.h21_3.r,
                                    ))),
                              ),
                      ],
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: AppSize.h81_3.r,
                          width: AppSize.w81_3.r,
                          /*decoration: BoxDecoration(
                            border: Border.all(color: AppColors.white, width: 5),
                            shape: BoxShape.circle,
                            color: AppColors.white,
                          ),*/
                          child: widget.consult.photoUrl!.isEmpty
                              ? Image.asset(
                                  AssetsManager.dreamLogoPurpleImagePath,
                                  height: AppSize.h81_3.r,
                                  width: AppSize.w81_3.r,
                                  fit: BoxFit.fill,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: FadeInImage.assetNetwork(
                                    placeholder: AssetsManager.purple_logo,
                                    placeholderScale: 0.5,
                                    imageErrorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                      AssetsManager.dreamLogoPurpleImagePath,
                                      height: AppSize.h81_3.r,
                                      width: AppSize.w81_3.r,
                                      fit: BoxFit.fill,
                                    ),
                                    image: widget.consult.photoUrl!,
                                    fit: BoxFit.cover,
                                    fadeInDuration: Duration(
                                        milliseconds:
                                            AppConstants.milliseconds250),
                                    fadeInCurve: Curves.easeInOut,
                                    fadeOutDuration: Duration(
                                        milliseconds:
                                            AppConstants.milliseconds150),
                                    fadeOutCurve: Curves.easeInOut,
                                  ),
                                ),
                        ),
                        Positioned(
                          left: AppRadius.r4.r,
                          top: AppRadius.r6_5.r,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: avaliable
                                  ? AppColors.greenButton
                                  : AppColors.pink1,
                            ),
                            width: AppSize.w10_6.r,
                            height: AppSize.h10_6.r,
                          ),
                        ),
                      ],
                    ),
                    TextWidget(
                      text: widget.consult.userType == AppConstants.consultant
                          ? widget.consult.price! + "\$"
                          : double.parse(widget.consult.balance.toString())
                                  .toStringAsFixed(2) +
                              "\$",
                      family: getTranslated(context, "Montserrat-SemiBold"),
                      color: AppColors.linear3,
                      weight: FontWeight.w600,
                      size: AppFontsSizeManager.s18_6.sp,
                      align: TextAlign.start,
                    )
                  ],
                ),
                SizedBox(height: AppSize.h10_5.h),
                //d
                Stack(children: <Widget>[
                  Text(
                    getTranslated(context, "lang") == "ar"
                        ? widget.consult.consultName!.nameAr!
                        : getTranslated(context, "lang") == "en"
                            ? widget.consult.consultName!.nameEn!
                            : getTranslated(context, "lang") == "fr"
                                ? widget.consult.consultName!.nameFr!
                                : widget.consult.consultName!.nameId!,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: getTranslated(context, 'Ithralight'),
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 0.2
                        ..color = AppColors.pureBlack,
                      fontSize: AppFontsSizeManager.s16.sp,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  Text(
                    getTranslated(context, "lang") == "ar"
                        ? widget.consult.consultName!.nameAr!
                        : getTranslated(context, "lang") == "en"
                            ? widget.consult.consultName!.nameEn!
                            : getTranslated(context, "lang") == "fr"
                                ? widget.consult.consultName!.nameFr!
                                : widget.consult.consultName!.nameId!,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: getTranslated(context, 'Ithralight'),
                      color: AppColors.pureBlack,
                      fontSize: AppFontsSizeManager.s16.sp,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ]),
                SizedBox(height: AppSize.h10_5.h),
                /*  Icon(
                  Icons.mic_none,
                  color: AppColors.pink,
                  size: 12.0,
                ),
                widget.consult.languages!.length > 1
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          langWidget(widget.consult.languages![0]),
                          SizedBox(
                            width: 5,
                          ),
                          langWidget(widget.consult.languages![1])
                        ],
                      )
                    : langWidget(widget.consult.languages![0]),*/
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      callsWidget(),
                      SizedBox(
                        width: AppSize.w36.w,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            AssetsManager.yellow_star_iconPath,
                            width: AppSize.w21.r,
                            height: AppSize.h21.r,
                          ),
                          SizedBox(
                            width: 3.w,
                          ),
                          TextWidget(
                            text: widget.consult.rating.toStringAsFixed(1),
                            color: AppColors.black4,
                            weight: FontWeight.w500,
                            size: AppFontsSizeManager.s18_6.sp,
                            align: TextAlign.start,
                            family: getTranslated(context, "Montserrat-Medium"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSize.h18_6.h),
                //pb
                Container(
                  width: lang == "ar" ? AppSize.w172.w : AppSize.w142.w,
                  height: AppSize.h35.h,
                  decoration: BoxDecoration(
                    color: AppColors.lightPurple,
                    borderRadius: BorderRadius.circular(AppRadius.r5.r),
                  ),
                  child: Center(
                    child: Text(
                      getTranslated(context, "ViewProfile"),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.linear3,
                        fontSize: AppFontsSizeManager.s13_3.sp,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        letterSpacing: AppConstants.letterSpacing,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSize.h22_6.h),
              ],
            ),
          ),
          /*Align(
            alignment: Alignment.bottomCenter,
            child:  getTranslated(context, "lang")=="ar"?Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
               priceWidget(),
               callsWidget(),
              ],
            ):Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                callsWidget(),
                priceWidget(),
              ],
            ),
          ),*/
        ]),
      ),
    );
  }

  callsWidget() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            AssetsManager.purple_phone,
            width: AppSize.w21.r,
            height: AppSize.h21.r,
          ),
          Text(
            //widget.consult.ordersNumbers==null?'0':widget.consult.ordersNumbers<100?widget.consult.ordersNumbers.toString():widget.consult.ordersNumbers<1000?"+100":"+1000",
            orderNum + "+",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: getTranslated(context, "Montserrat-Medium"),
              color: AppColors.pureBlack,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
              fontSize: AppFontsSizeManager.s18_6.sp,
            ),
          ),
        ],
      ),
    );
  }

  priceWidget() {
    return Container(
        width: 35.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: AppColors.pink,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(AppRadius.r8),
            topLeft: Radius.circular(AppRadius.r20),
          ),
        ),
        child: Center(
          child: Text(
            widget.consultType == "voice"
                ? widget.consult.price! + "\$"
                : widget.consult.chatPrice! + "\$",
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontFamily: getTranslated(context, "Ithra"),
              color: AppColors.white,
              fontSize: AppFontsSizeManager.s11.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ));
  }

  share(BuildContext context) async {
    setState(() {
      sharing = true;
    });
    String uid = widget.consult.uid!;
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse("https://dreamuser\.page\.link/consultant_id=" + uid),
      uriPrefix: "https://dreamuser\.page\.link",
      androidParameters:
          const AndroidParameters(packageName: "com.abdulazizahmed.dream"),
      iosParameters: const IOSParameters(
          bundleId: "com.abdulazizAhmed.dream",
          appStoreId: "1515745954",
          minimumVersion: "2.2.17"),
    );
    ShortDynamicLink dynamicLink =
        await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
    File file;
    if (widget.consult.photoUrl!.isEmpty) {
      final bytes = await rootBundle.load(AssetsManager.dream_icon_logo2);
      final list = bytes.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      file = await File('${tempDir.path}/image.jpg').create();
      file.writeAsBytesSync(list);
    } else {
      final directory = await getTemporaryDirectory();
      final path = directory.path;
      final response = await http.get(Uri.parse(widget.consult.photoUrl!));
      file =
          await File('$path/image_${DateTime.now().millisecondsSinceEpoch}.png')
              .writeAsBytes(response.bodyBytes);
    }
    Share.shareFiles(["${file.path}"],
        text: '(تطبيق رؤيا -Dream Application) '
            '\n ${getTranslated(context, "ilikead")} ${widget.consult.name} '
            ' ${getTranslated(context, "irecommendit")}.\n '
            '\n ${dynamicLink.shortUrl.toString()} ');
    setState(() {
      sharing = false;
    });
  }

  shareww(BuildContext context) async {
    setState(() {
      sharing = true;
    });
    // Create DynamicLink
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse(
          "https://dreamuser.page.link?consultant_id=" + widget.consult.uid!),
      uriPrefix: "https://dreamuser.page.link",
      androidParameters:
          const AndroidParameters(packageName: "com.abdulazizahmed.dream"),
      iosParameters: const IOSParameters(
          bundleId: "com.abdulazizAhmed.dream",
          appStoreId: "1515745954",
          minimumVersion: "2.2.17"),
    );
    ShortDynamicLink dynamicLink =
        await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
    File file;
    if (widget.consult.photoUrl!.isEmpty) {
      final bytes = await rootBundle.load(AssetsManager.dream_icon_logo2);
      final list = bytes.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      file = await File('${tempDir.path}/image.jpg').create();
      file.writeAsBytesSync(list);
    } else {
      final directory = await getTemporaryDirectory();
      final path = directory.path;
      final response = await http.get(Uri.parse(widget.consult.photoUrl!));
      file =
          await File('$path/image_${DateTime.now().millisecondsSinceEpoch}.png')
              .writeAsBytes(response.bodyBytes);
    }

    Share.shareFiles(["${file.path}"],
        text: '(تطبيق رؤيا -Dream Application) '
            '\n ${getTranslated(context, "ilikead")} ${widget.consult.name} '
            ' ${getTranslated(context, "irecommendit")}.\n '
            '\n ${dynamicLink.shortUrl.toString()} ');
    setState(() {
      sharing = false;
    });
  }

  Widget langWidget(String langText) {
    return Container(
      height: AppSize.h20.h,
      width: AppSize.w40.w, //size.width * .30,
      decoration: BoxDecoration(
        color: AppColors.lightPink2,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Center(
        child: Text(
          langText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: getTranslated(context, "Ithra"),
            color: AppColors.pink,
            fontSize: AppFontsSizeManager.s9.sp,
          ),
        ),
      ),
    );
  }
}
