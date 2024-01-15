import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_values.dart';

import '../config/colorsFile.dart';


class IconButton1 extends StatelessWidget {
  const IconButton1(
      {super.key, required this.width, required this.radius, required this.color, this.shadowcolor, required this.iconsize, required this.icon,  required this.iconcolor, required this.onPress, this.height,
        });
  final Function() onPress;

  final double? width;
  final double? height;
  final double? iconsize;
  final double? radius;
  final String? icon;
  final Color? color;
  final Color? iconcolor;
  final Color? shadowcolor;





  @override
  Widget build(BuildContext context) {
    String shadow=shadowcolor.toString();
    return Container(
      height: height,
      width: width,
      decoration: (shadow.isNotEmpty)?BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius!),

        boxShadow: [
          BoxShadow(
            color: AppColors.purpleShadow,
            blurRadius: AppSize.h10_6.r,
            spreadRadius: 0.0,
            offset: Offset(0.0, 1.0), // shadow direction: bottom right
          )] ,
      ):BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius!),
      ),

      child: Center(
        child: IconButton(
          onPressed: onPress,
          icon:Image.asset(icon!, width: iconsize,height: iconsize,color: iconcolor,),
        ),
      ),
    );
  }
}