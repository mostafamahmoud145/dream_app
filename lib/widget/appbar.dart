import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';


class Appbar1 extends StatelessWidget {
  const Appbar1(
      {super.key, this.width, this.radius, this.color, this.shadowcolor, this.iconsize, this.icon,  this.iconcolor, required this.onPress, this.height, this.text,
      });
  final Function() onPress;

  final double? width;
  final double? height;
  final double? iconsize;
  final double? radius;
  final String? text;
  final String? icon;
  final Color? color;
  final Color? iconcolor;
  final Color? shadowcolor;





  @override
  Widget build(BuildContext context) {
    return (text!.isNotEmpty)?Row(
      children: [

        SizedBox(width: 21.3.w,),
        Text(
          getTranslated(context, "consaultant_details_widgets"),
          textAlign:TextAlign.left,
          style: TextStyle( fontFamily:getTranslated(context, 'Ithralight'),fontSize: AppFontsSizeManager.s21_3.sp,color:AppColors.appbartext, fontWeight: FontWeight.bold),
        ),
      ],
    ):Row(
      children: [

        SizedBox(width: 21.3.w,),
        Text(
          getTranslated(context, "consaultant_details_widgets"),
          textAlign:TextAlign.left,
          style: TextStyle( fontFamily:getTranslated(context, 'Ithralight'),fontSize: AppFontsSizeManager.s21_3.sp,color:AppColors.appbartext, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}