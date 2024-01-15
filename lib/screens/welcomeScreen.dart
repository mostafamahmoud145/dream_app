

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(backgroundColor: AppColors.white,
      key: _scaffoldKey,
      body:  Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: size.height*AppSize.h0_20,),
          SvgPicture.asset(AssetsManager.searchImagePath,width: AppSize.w200,height: AppSize.h200,),
          Padding(
            padding: const EdgeInsets.all(AppPadding.p20),
            child: Text(
              getTranslated(context, "firstApp"),
              textAlign: TextAlign.center,
              style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                color: AppColors.pink,
                fontSize: AppFontsSizeManager.s15,
              ),
            ),
          ),
          SizedBox(height: size.height*AppSize.h0_10,),
          Center(
            child: InkWell(onTap: (){
              Navigator.popAndPushNamed(context, '/home');
            },
              child: Container(
                width: size.width*AppSize.w0_8,
                height: AppSize.h45,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.r5),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.linear1,
                        AppColors.linear2,
                        AppColors.linear2,
                      ],
                    )
                ),
                child: Center(
                  child: Text(
                    getTranslated(context, "yourDream"),
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.white,
                      fontSize: AppFontsSizeManager.s18,
                      letterSpacing:AppConstants.letterSpacing,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSize.h20,),
        ],
      ),
    );
  }

}
