
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/colorsFile.dart';

import '../../config/app_values.dart';
import '../../config/assets_manager.dart';
import '../../localization/localization_methods.dart';
import '../../methods/change_user_call_state.dart';
import '../dreamDialogsWidget.dart';



showNotificationBlockedDialog({required context ,required String callerId, required String receiverId}) {
  return showDialog(
    builder: (context) => DreamDialogsWidget(
      dialogContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  AssetsManager.pink_cancel_iconPath,
                  width: 32.w,
                  height: 32.h,
                ),
              ),
              SizedBox(width: 140.w),
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: SvgPicture.asset(
                  AssetsManager.notificationImagePath,
                  color: AppColors.pink,
                  width: 53.5.r,
                  height: 53.5.r,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.h16.h),
          Text(
            getTranslated(context, "callNotArrived"),
            style: TextStyle(
              fontFamily: getTranslated(context, 'Ithra'),
              fontSize: AppFontsSizeManager.s32.sp,
              color: AppColors.linear2,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSize.h16.h),
          Text(
            getTranslated(context, "receiverBlockedNotification"),
            style: TextStyle(
              fontFamily: getTranslated(context, 'Ithralight'),
              fontSize: AppFontsSizeManager.s21_3.sp,
              color: AppColors.black4,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.normal,
            ),
          ),
          SizedBox(
            height: AppSize.h32.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              InkWell(
                onTap: () async {
                  changeUserState(userId: callerId, state: 'closed');
                  changeUserState(userId: receiverId, state: 'closed');
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
                child: Container(
                  width: 160.w,
                  height: 56.h,
                  //   alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.linear2,
                    borderRadius:
                    BorderRadius.circular(AppRadius.r10_6.r),
                  ),
                  child: Center(
                    child: Text(
                      getTranslated(context, 'endCall'),
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithra'),
                        fontSize: AppFontsSizeManager.s18_6.sp,
                        color: AppColors.white,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              Spacer(),
              //SizedBox(width: AppSize.w57_3.w),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 160.w,
                  height: 56.h,
                  //   alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                          Radius.circular(AppRadius.r10_6.r)),
                      border: Border.all(
                        color: AppColors.linear2,
                        width: 1.5.w,
                      )),
                  child: Center(
                    child: Text(
                      getTranslated(context, 'continue'),
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithra'),
                        fontSize: AppFontsSizeManager.s18_6.sp,
                        color: AppColors.linear2,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    barrierDismissible: false,
    context: context,
  );
}

