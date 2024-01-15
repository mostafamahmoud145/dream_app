import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../config/app_values.dart';
import '../../config/colorsFile.dart';
import '../../methods/convert_pt_to_px.dart';

class DaysButtonsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DayButtonShimmer(),
        SizedBox(
          width: convertPtToPx(AppSize.w12).w,
        ),
        DayButtonShimmer(),
        SizedBox(
          width: convertPtToPx(AppSize.w12).w,
        ),
        DayButtonShimmer(),
      ],
    );
  }
}

class DayButtonShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Shimmer.fromColors(
          period: Duration(milliseconds: 800),
          baseColor: Colors.grey.withOpacity(0.6),
          highlightColor: AppColors.pureBlack.withOpacity(0.6),
          child: Container(
            height: convertPtToPx(AppSize.h40).h,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColors.pureBlack.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
            ),
          )),
    );
  }
}
