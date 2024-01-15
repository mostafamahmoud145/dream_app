
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/promoCode.dart';
import 'package:grocery_store/screens/promoCodesScreens/editPromoCodeScreen.dart';



class PromoListItem extends StatelessWidget {
  final PromoCode code;
  PromoListItem({required this.code});
  @override
  Widget build(BuildContext context) {
    String lang=getTranslated(context, "lang");
    Size size = MediaQuery.of(context).size;
   
    return Column(
      children: [
        InkWell(
          splashColor:
          Colors.red.withOpacity(0.6),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPromoCodeScreen(promoCode:code ), ),  );
          },
          child: Container(
            padding:  EdgeInsets.all(AppPadding.p10),
            decoration: BoxDecoration(
              color:AppColors.pink,
              borderRadius: BorderRadius.circular(AppRadius.r25),
            ),
            child:   Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(onTap:(){
                          Clipboard.setData(ClipboardData(text: code.code));
                          showSnack(getTranslated(context, "copyDone"),context);
                          },
                      child: Row(mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.copy,
                            size: AppSize.w18,
                            color:code.promoCodeStatus?AppColors.green:AppColors.red,
                          ),
                          Text(
                            code.code,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                              color: AppColors.white,
                              fontSize: AppFontsSizeManager.s15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),


                        ],
                      ),
                    ),
                    Container(
                      height: 35.0,
                      child: MaterialButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: code.code));
                          showSnack(getTranslated(context, "copyDone"),context);
                        },
                        color:  code.type=="default"?AppColors.green:AppColors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.r15),
                        ),
                        child: Text(
                         code.type!,
                          style: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontSize: AppFontsSizeManager.s15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.person,
                      size: AppSize.w18,
                      color:AppColors.white,
                    ),
                    Text(
                      getTranslated(context, "owner")+": "+code.ownerName,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 1,
                      style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.white,
                        fontSize:AppFontsSizeManager.s15,
                        // fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.card_giftcard,
                      size: AppSize.w18,
                      color: AppColors.white,
                    ),
                    Text(
                      getTranslated(context, "discount")+": "+code.discount.toString()+"%",
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 1,
                      style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.white,
                        fontSize: AppFontsSizeManager.s15,
                        // fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.addchart_outlined,
                      size: AppSize.w18,
                      color: AppColors.white,
                    ),
                    Text(
                      getTranslated(context, "usedNumber")+": "+code.usedNumber.toString(),
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 1,
                      style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.white,
                        fontSize: AppFontsSizeManager.s15,
                        letterSpacing: 0.3,
                      ),
                    ),

                  ],
                ),

              ],),


          ),
        ),
        SizedBox(height: AppSize.h20,)
      ],
    );
  }
  void showSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(AppMargin.m8),
      borderRadius: BorderRadius.circular(AppRadius.r7),
      backgroundColor: Colors.green.shade500,
      animationDuration: Duration(milliseconds: AppConstants.milliseconds300),
      isDismissible: true,
      boxShadows: [
        AppShadow.primaryShadow
      ],
      shouldIconPulse: false,
      duration: Duration(milliseconds: AppConstants.milliseconds1500),
      icon: Icon(
        Icons.error,
        color: AppColors.white,
      ),
      messageText: Text(
        '$text',
        style: GoogleFonts.poppins(
          fontSize: AppFontsSizeManager.s14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: AppColors.white,
        ),
      ),
    )..show(context);
  }

}
