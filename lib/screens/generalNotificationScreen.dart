
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:linkwell/linkwell.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_fonts.dart';
import '../config/assets_manager.dart';
import '../methods/convert_pt_to_px.dart';
import '../widget/back_button.dart';

class GeneralNotificationScreen extends StatefulWidget {
final String title;
final String body;
final String? image;
final String? link;

  const GeneralNotificationScreen({ Key? key, required this.title, required this.body, this.image, this.link}) : super(key: key);
  @override
  _GeneralNotificationScreenState createState() => _GeneralNotificationScreenState();
}

class _GeneralNotificationScreenState extends State<GeneralNotificationScreen>with SingleTickerProviderStateMixin {
  bool isLoading=true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(backgroundColor: AppColors.white,
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding(
                    padding:  EdgeInsets.symmetric(horizontal: convertPtToPx(AppPadding.p24).w, vertical: convertPtToPx(AppPadding.p15).h,),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomBackButton(),

                        SizedBox(width: AppSize.w21_3.w),
                        Text(
                          getTranslated(context, "terms"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              fontSize: AppFontsSizeManager.s21.sp,
                              color: AppColors.pureBlack.withOpacity(0.8),
                              fontWeight: AppFontsWeightManager.bold),
                        ),
                      ],
                    ),
                  ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey,
                  height: AppSize.h2.h,
                  width: size.width )),

          Column(children: [
            SizedBox(height: 20,),
            (  widget.image!=null&&widget.image!="noImage")? Center(
              child: Container(
                height: size.height*.25,
                width: size.width*.9,
                decoration: BoxDecoration(
                 // border: Border.all(color: Colors.grey[200],width: 1),
                  shape: BoxShape.rectangle,
                 // color: AppColors.white,
                ),
                child: widget.image!.isEmpty ?
                Center(child: Icon( Icons.image,color:Colors.grey,size: 50.0, ))
                    :ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: FadeInImage.assetNetwork(
                      placeholder:
                      AssetsManager.loadImagePath,
                      placeholderScale: 0.5,
                      imageErrorBuilder:(context, error, stackTrace) => Icon(
                        Icons.image,color:Colors.grey,size: 50.0,
                      ),
                      image: widget.image!,
                      fit: BoxFit.cover,
                      fadeInDuration:
                      Duration(milliseconds: 250),
                      fadeInCurve: Curves.easeInOut,
                      fadeOutDuration:
                      Duration(milliseconds: 150),
                      fadeOutCurve: Curves.easeInOut,
                    ),
                  ),
              ),
            ):SizedBox(),
            widget.image!="noImage"?SizedBox(height: 20,):SizedBox(),
            Center(
              child: Text(
                widget.title,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 3,
                style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                  color: Theme.of(context).primaryColor,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            SizedBox(height: 10,),
            LinkWell(
              widget.body,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 5,
              style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                color: Theme.of(context).primaryColor,
                fontSize: 15.0,
                fontWeight: FontWeight.normal,
                letterSpacing: 0.3,
              ),
              linkStyle: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                color: Colors.blue,
                fontSize: 15.0,
                fontWeight: FontWeight.normal,
                letterSpacing: 0.3,
              ),),
            /* Text(
                widget.body,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 5,
                style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                  color: Theme.of(context).primaryColor,
                  fontSize: 15.0,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.3,
                ),
              ),*/
            SizedBox(height: 10,),
            (widget.link!=null&&widget.link!="noLink"&&widget.link!="")?  InkWell(splashColor: Colors.blue.withOpacity(0.5),
              onTap: () async {
                if (await canLaunch(widget.link!)) {
                await launch(widget.link!);
                } else {
                throw 'Could not launch link';
                }
              },
              child: Text(
                 getTranslated(context, "pressForMore"),
                  style: TextStyle( decoration: TextDecoration.underline,
                    decorationColor:Colors.blue,
                    decorationThickness: 1,
                    color: Colors.blue,
                    fontSize: 12.0,
                  )
              ),
            ):SizedBox(),
          ],)
        ],
      ),
    );
  }
}
