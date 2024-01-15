
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
class searchbar1 extends StatelessWidget {
  const searchbar1(
      {super.key,
        required this.onPress,
        required this.text,
        required this.width,
        required this.height,
        required this.textSize,
        required this.textfont,
        required this.textcolor,
        required this.icon,
        this.iconcolor,required this.iconwidth, required this.iconheight,required this.space});

  final Function() onPress;
  final double? width;
  final double? height;
  final double? iconwidth;
  final double? iconheight;
  final String text;
  final String? textfont;
  final double? textSize;
  final Color? textcolor;
  final String icon;
  final Color? iconcolor;
  final double? space;

  BoxDecoration decoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
      boxShadow: [
        AppShadow.primaryShadow
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: onPress,
      child: Center(
        child: Container(
            height: height,
            width: width,
            padding: const EdgeInsets.symmetric(
                horizontal: AppPadding.p13, vertical: 0.0),
            decoration: decoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(icon,
                   width: iconwidth,
                  height: iconheight,
                ),
                SizedBox(
                  width:10.w,
                ),
                //d
                Expanded(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: textfont,
                      color: textcolor,
                      fontSize: textSize,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}