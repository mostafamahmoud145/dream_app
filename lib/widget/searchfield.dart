import 'package:flutter/material.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/constants.dart';

class searchfield1 extends StatelessWidget {
  searchfield1(
      {super.key,
      required this.text,
      required this.width,
      required this.height,
      required this.textSize,
      required this.textfont,
      required this.textcolor,
      required this.icon,
      this.iconcolor,
      this.prefixIconColor,
      required this.iconwidth,
      required this.iconheight,
      required this.radius,
      required this.boxcolor,
      required this.searchController,
      required this.function,
      required this.horizontalpadding,
      required this.verticalpadding});

  final Function(String value) function;
  final double? width;
  final double? height;
  final double? horizontalpadding;
  final double? verticalpadding;
  final double? radius;
  final double? iconwidth;
  final Color? boxcolor;
  final double? iconheight;
  final String text;
  final String? textfont;
  final double? textSize;
  final Color? textcolor;
  final Widget icon;
  final Color? iconcolor;
  final TextEditingController searchController;
  final Color? prefixIconColor;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      height: height,
      width: width,
      padding: EdgeInsets.symmetric(
          horizontal: AppPadding.p5, vertical: AppPadding.p3),
      decoration: BoxDecoration(
        color: boxcolor,
        borderRadius: BorderRadius.circular(radius ?? AppRadius.r19),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: TextField(
            onChanged: function,
            keyboardType: TextInputType.text,
            controller: searchController,
            textInputAction: TextInputAction.search,
            enableInteractiveSelection: true,
            readOnly: false,
            style: TextStyle(
              fontFamily: textfont,
              fontSize: textSize,
              color: textcolor,
              letterSpacing: AppConstants.letterSpacing,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                  horizontal: AppPadding.p8, vertical: AppPadding.p8),
              prefixIcon: icon,
              prefixIconColor: prefixIconColor,
              border: InputBorder.none,
              hintText: // "Ask a question",
                  text,
              hintStyle: TextStyle(
                  color: textcolor,
                  fontWeight: FontWeight.w400,
                  fontFamily: textfont,
                  fontStyle: FontStyle.normal,
                  fontSize: textSize),
            ),
          ),
        ),
      ),
    );
  }
}
