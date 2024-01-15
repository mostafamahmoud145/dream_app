import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/SupportList.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/supportMessagesScreen.dart';
import 'package:intl/intl.dart';

import '../config/colorsFile.dart';

class SupportListItem extends StatelessWidget {
  final Size size;
  final SupportList item;
  final GroceryUser user;

  const SupportListItem({
    super.key,
    required this.size,
    required this.item,
    required this.user,
    //@required this.index,
    //@required this.notificationList,
  });

  void showSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(AppMargin.m8),
      borderRadius: BorderRadius.circular(AppRadius.r7),
      backgroundColor: Colors.green.shade500,
      animationDuration:
          const Duration(milliseconds: AppConstants.milliseconds300),
      isDismissible: true,
      boxShadows: [AppShadow.primaryShadow],
      shouldIconPulse: false,
      duration: const Duration(milliseconds: AppConstants.milliseconds2000),
      icon: const Icon(
        Icons.error,
        color: AppColors.white,
      ),
      messageText: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: AppFontsSizeManager.s14.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: AppColors.white,
        ),
      ),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('dd/MM/yy');

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppPadding.p5.h),
      child: GestureDetector(
        onTap: () {
          (item.openingStatus! && user.userType == "SUPPORT")
              ? showSnack(getTranslated(context, "otherSupport"), context)
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SupportMessageScreen(
                      item: item,
                      user: user,
                    ),
                  ),
                );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSize.w50.r,
                  height: AppSize.h50.r,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.pink),
                  child: Center(
                    child: Image.asset(
                      AssetsManager.white_head_phone_iconPath,
                      width: AppSize.w28.r,
                      height: AppSize.h28.r,
                    ),
                  ),
                ),
                Container(
                  width: size.width * AppSize.w0_5,
                  padding: const EdgeInsets.only(
                      left: AppPadding.p5, right: AppPadding.p5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        user.userType! == "SUPPORT"
                            ? item.userName == null
                                ? item.owner == AppConstants.user
                                    ? "Client"
                                    : AppConstants.consultant
                                : item.userName!
                            : '${getTranslated(context, "supportTeam")}',
                        style: TextStyle(
                          fontFamily: getTranslated(context, 'Ithra'),
                          fontSize: AppFontsSizeManager.s15.sp,
                          color: AppColors.pureBlack,
                          //fontWeight: FontWeight.bold,
                          //letterSpacing: 0.3,
                        ),
                      ),
                      item.lastMessage == null
                          ? const SizedBox()
                          : (item.lastMessage != "imageFile" &&
                                  item.lastMessage != "voiceFile")
                              ? Text(
                                  item.lastMessage!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily:
                                        getTranslated(context, 'Ithralight'),
                                    fontSize: AppFontsSizeManager.s11.sp,
                                    color: AppColors.grey,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.3,
                                  ),
                                )
                              : Row(
                                  children: [
                                    Icon(
                                      Icons.file_copy_outlined,
                                      size: AppSize.w15.r,
                                      color: AppColors.white.withOpacity(0.6),
                                    ),
                                    Text(
                                      getTranslated(context, "attatchment"),
                                      style: TextStyle(
                                        fontFamily:
                                            getTranslated(context, 'Ithra'),
                                        fontSize: AppFontsSizeManager.s13.sp,
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      height: AppSize.h30.r,
                      width: AppSize.w30.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.white,
                            AppColors.lightGrey7,
                          ],
                        ),
                        boxShadow: [AppShadow.primaryShadow],
                      ),
                      child: Center(
                        child: Image.asset(
                          AssetsManager.chat2_iconPath,
                          width: AppSize.w20.r,
                          height: AppSize.h20.r,
                        ),
                      ),
                    ),
                    ((user.userType == "SUPPORT" &&
                                item.supportMessageNum > 0) ||
                            (user.userType != "SUPPORT" &&
                                item.userMessageNum > 0))
                        ? Positioned(
                            left: 0.0,
                            top: 0.0,
                            child: Container(
                              height: AppSize.h10.r,
                              width: AppSize.w10.r,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.amber,
                              ),
                            ),
                          )
                        : const SizedBox()
                  ],
                ),
                SizedBox(
                  height: AppSize.w6.w,
                ),
                Text(
                  // date,
                  item.messageTime != null
                      ? dateFormat.format(item.messageTime!.toDate())
                      : '..',
                  style: TextStyle(
                    fontFamily: getTranslated(context, 'Montserrat-Regular'),
                    fontSize: AppFontsSizeManager.s12.sp,
                    color: AppColors.lightGrey5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
