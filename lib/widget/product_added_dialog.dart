

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
class ProductAddedDialog extends StatelessWidget {
  final String message;

  const ProductAddedDialog({required this.message});
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(AppRadius.r15),
        ),
      ),
      elevation: 5.0,
      contentPadding: EdgeInsets.symmetric(horizontal: AppPadding.p16, vertical:AppPadding.p20),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: AppSize.h15,
          ),
          Image.asset(
            'assets/images/order_placed.png',
            width: size.width * 0.4,
          ),
          SizedBox(
            height: AppSize.h35,
          ),
          Text(
            '$message',
            style: GoogleFonts.poppins(
              fontSize: AppFontsSizeManager.s14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: AppColors.black1,
            ),
          ),
          SizedBox(
            height: AppSize.h15,
          ),
          SizedBox(
            width: size.width * 0.5,
            child: MaterialButton(
              onPressed: () {
                Navigator.pop(context, 'ADDED');
              },
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  color: AppColors.white,
                  fontSize: AppFontsSizeManager.s15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          SizedBox(
            height: AppFontsSizeManager.s15,
          ),
        ],
      ),
    );
  }
}
