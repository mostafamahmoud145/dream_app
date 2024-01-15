
import 'package:flutter/material.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';

import '../localization/localization_methods.dart';

class ProcessingDialog extends StatelessWidget {
  final String message;
  ProcessingDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(AppRadius.r15),
        ),
      ),
      elevation: 5.0,
      contentPadding: EdgeInsets.symmetric(horizontal: AppPadding.p16, vertical: AppPadding.p20),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: AppSize.h15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: AppSize.w30,
                height: AppSize.h30,
                child: CircularProgressIndicator(),
              ),
              SizedBox(
                width: AppSize.w15,
              ),
              Text(
                message,
                style: TextStyle( fontFamily: getTranslated(context, 'Ithra'),
                  fontSize: AppFontsSizeManager.s14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: AppColors.black1,
                ),
              ),
            ],
          ),
          SizedBox(
            height: AppSize.h15,
          ),
        ],
      ),
    );
  }
}
