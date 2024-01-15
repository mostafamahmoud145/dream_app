import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/widget/tab_bar/tab_bar_button.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({
    Key? key,
    this.width = double.infinity,
    this.height = AppConstants.tabBarHeight,
    this.backgroundColor,
    required this.buttons,
    this.margin,
    this.padding,
  }) : super(key: key);

  final double width;
  final double height;

  final Color? backgroundColor;
  final List<TabBarButton> buttons;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.w509_3.w,
      height: AppSize.h72.h,
      alignment: Alignment.center,
      margin: margin,
      padding: padding ??
          EdgeInsets.symmetric(
              horizontal: AppPadding.p10_6.w, vertical: AppPadding.p10_6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.r16.r)),
        color: backgroundColor == null ? AppColors.tabColor : backgroundColor,
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: buttons),
    );
  }
}




//
// class TabBarButton extends StatelessWidget {
//   const TabBarButton({
//     Key? key,
//     required this.isSelected,
//     required this.function,
//     this.activeColor= const AppColors.linear3,
//     this.notActiveColor= const Color.fromRGBO(250, 245, 249, 1),
//     this.radius= 10.5,
//     this.height= 41,
//     this.width= 153,
//     required this.text,
//     this.activeTextColor= AppColors.white,
//     this.notActiveTextColor= AppColors.pink,
//     this.textSize= 21,
//     this.textFont,
//   }) : super(key: key);
//
//   final bool isSelected;
//   final Function function;
//   final Color? activeColor;
//   final Color? notActiveColor;
//   final Color? activeTextColor;
//   final Color? notActiveTextColor;
//   final String text;
//   final double width;
//   final double height;
//   final double radius;
//   final double textSize;
//   final String? textFont;
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return textButton(
//         onPress: (){
//           function();
//         },
//         text: text,
//         width: width.w,
//         height: height.h,
//         buttonRadius: radius.r,
//         textSize: textSize.sp,
//         textfont: textFont,
//         textcolor: isSelected ? activeColor : notActiveColor,
//         icon: null,
//         Gradient_Color: isSelected ? activeColor : notActiveColor,
//         Gradient_Color2: isSelected ? activeColor : notActiveColor,
//     );
//   }
// }
