import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/app_fonts.dart';
import '../../config/app_values.dart';
import '../../config/colorsFile.dart';
import '../../localization/localization_methods.dart';
import '../../methods/convert_pt_to_px.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({Key? key, required this.errorMessage, this.buttomPadding= AppSize.h32}) : super(key: key);
  final String errorMessage;
  final buttomPadding;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: convertPtToPx(AppSize.h16).h,
        bottom: convertPtToPx(buttomPadding).h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_outlined,
            color: AppColors.red1,
            size: convertPtToPx(AppSize.h20).h,
          ),
          SizedBox(
            width: convertPtToPx(AppSize.w8).w,
          ),
          Expanded(
            child: Text(
              errorMessage,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: getTranslated(context, 'Ithra'),
                fontSize: convertPtToPx(AppFontsSizeManager.s12).sp,
                fontWeight: AppFontsWeightManager.bold,
                letterSpacing: convertPtToPx(-0.24),
                color: AppColors.appbartext,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
