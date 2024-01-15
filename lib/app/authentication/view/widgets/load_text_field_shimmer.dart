
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../config/app_values.dart';
import '../../../../config/colorsFile.dart';
import '../../../../config/constants.dart';

Widget loadVerificationCode() {
  return Shimmer.fromColors(
      period: Duration(milliseconds: AppConstants.milliseconds800),
      baseColor: Colors.grey.withOpacity(0.6),
      highlightColor: AppColors.pureBlack.withOpacity(0.6),
      child: Container(
        width: AppSize.w372.w,
        height: AppSize.h70.h,
        padding: EdgeInsets.all(AppPadding.p14_5.w),
        margin: const EdgeInsets.symmetric(
          horizontal: AppPadding.p20,
        ),
        decoration: BoxDecoration(
          color: AppColors.pureBlack.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
        ),
      ));
}