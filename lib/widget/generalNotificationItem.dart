
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/generalNotifications.dart';
import 'package:intl/intl.dart';
import 'package:linkwell/linkwell.dart';

class GeneralNotificationItem extends StatelessWidget {
  final GeneralNotifications item;

  const GeneralNotificationItem({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    DateFormat dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    return Column(
      children: [
        Container(
          width: size.width,
          padding: const EdgeInsets.only(
              left: AppPadding.p10, right: AppPadding.p10, bottom: AppPadding.p10, top: AppPadding.p10),
          decoration: BoxDecoration(
            color: AppColors.pureBlack.withOpacity(0.04),
            borderRadius: BorderRadius.circular(AppRadius.r12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
               item.title!,
                style: GoogleFonts.poppins(
                  fontSize: AppFontsSizeManager.s14_5,
                  color: AppColors.black1,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(
                height: AppSize.h5,
              ),
              LinkWell(
                item.body!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: AppFontsSizeManager.s13_5,
                  color: AppColors.pureBlack.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
                linkStyle: GoogleFonts.poppins(
                  fontSize: AppFontsSizeManager.s13_5,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),),
             /* Text(
                item.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: AppColors.pureBlack.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),*/
              SizedBox(
                height: AppSize.h5,
              ),
              Text(
                getTranslated(context, "sendTo")+": "+item.notificationType,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: AppFontsSizeManager.s13_5,
                  color: AppColors.pureBlack.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(
                height: AppSize.h5,
              ),
              Text(
                getTranslated(context, "selectLanguage")+": "+item.notificationLang,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: AppFontsSizeManager.s13_5,
                  color: AppColors.pureBlack.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(
                height: AppSize.h5,
              ),
              Text(
                getTranslated(context, "selectCountry")+": "+item.notificationCountry,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: AppFontsSizeManager.s13_5,
                  color: AppColors.pureBlack.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(
                height:AppSize.h5,
              ),
              Text(
                '${dateFormat.format(item.notificationTimestamp!.toDate())}',
                style: GoogleFonts.poppins(
                  fontSize: AppFontsSizeManager.s13,
                  color: AppColors.pureBlack.withOpacity(0.5),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSize.h15,)
      ],
    );
  }
}
