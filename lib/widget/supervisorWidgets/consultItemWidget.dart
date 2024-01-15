

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/constants.dart';

import '../../config/app_fonts.dart';
import '../../config/colorsFile.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../../screens/supervisor/supervisorConsultScreen.dart';
import '../component/textWidget.dart';

class consultItemWidget extends StatelessWidget {
  final GroceryUser consult;
  final GroceryUser loggedUser;
  consultItemWidget({required this.consult, required this.loggedUser});

  @override
  Widget build(BuildContext context) {
    bool avaliable = false;
    DateTime _now = DateTime.now();
    String dayNow = _now.weekday.toString();
    int timeNow = _now.hour;

    if (consult.fromUtc!=null&&consult.toUtc!=null&&consult.workDays!=null&&consult.workDays!.contains(dayNow)) {
      int localFrom = DateTime.parse(consult.fromUtc!).toLocal().hour;
      int localTo = DateTime.parse(consult.toUtc!).toLocal().hour;
      if (localTo == 0) localTo = 24;
      if (localFrom <= timeNow && localTo > timeNow) {
        avaliable = true;
      }
    }
    return    InkWell(
      onTap: () {
        Clipboard.setData(
            ClipboardData(text: consult.phoneNumber!));
        Fluttertoast.showToast(
            msg: "phone number coped ",
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.green,
            textColor: AppColors.white);
      },
      child: Container(
        padding: const EdgeInsets.all(AppPadding.p20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.r31),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: AppPadding.p1,left: AppPadding.p2,right: AppPadding.p2),
              child: Stack(
                children: <Widget>[
                  Container(
                    height: AppSize.h50,
                    width: AppSize.w50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                    ),
                    child: consult.photoUrl!.isEmpty
                        ? Icon(
                      Icons.person,
                      color: AppColors.greyShade400,
                      size: AppSize.w25,
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.r100),
                      child: FadeInImage.assetNetwork(
                        placeholder: AssetsManager.purple_logo,
                        placeholderScale: 0.5,
                        imageErrorBuilder:
                            (context, error, stackTrace) => Icon(
                          Icons.person,
                              color: AppColors.greyShade400,
                              size: AppSize.w25,
                        ),
                        image: consult.photoUrl!,
                        fit: BoxFit.cover,
                        fadeInDuration: Duration(milliseconds: AppConstants.milliseconds250),
                        fadeInCurve: Curves.easeInOut,
                        fadeOutDuration: Duration(milliseconds: AppConstants.milliseconds150),
                        fadeOutCurve: Curves.easeInOut,
                      ),
                    ),
                  ),
                  Positioned(
                    left: AppPadding.p1,
                    top: AppPadding.p5,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white,
                          width: AppSize.w1,
                        ),
                        color: avaliable ? AppColors.green : Colors.red,
                      ),
                      width: AppSize.w10,
                      height: AppSize.h10,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextWidget(text: getTranslated(context, "lang")=="ar"?consult.consultName!.nameAr!:
                  getTranslated(context, "lang")=="en"?consult.consultName!.nameEn!:
                  getTranslated(context, "lang")=="fr"?consult.consultName!.nameFr!:
                  consult.consultName!.nameId!,color: Color.fromRGBO( 32, 32 ,32,1),weight: FontWeight.w600,size: 15,
                    align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextWidget(text:consult.phoneNumber!,color: AppColors.darkGrey,weight: FontWeight.normal,size: 10,
                        align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
                      SizedBox(width: 5,),
                      Image.asset(
                        'assets/applicationIcons/copy@3x.png',width: AppSize.w10,height: AppSize.h12,
                      ),

                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextWidget(text:  consult.ordersNumbers.toString(),color:AppColors.black4,
                            weight:AppFontsWeightManager.semiBold,size: AppSize.w10,
                            align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
                          SizedBox(width: AppSize.w3,),
                          Image.asset(
                            AssetsManager.green_call_icon_path,
                            width: AppSize.w8,
                            height: AppSize.h8,
                          ),
                        ],
                      ),
                      SizedBox(
                        width: AppSize.w20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextWidget(text:consult.rating.toStringAsFixed(1),color:AppColors.black4,
                            weight:AppFontsWeightManager.semiBold,size: AppSize.w10,
                            align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
                          SizedBox(width: AppSize.w3,),
                          Image.asset(
                            AssetsManager.yellow_star_iconPath,width: AppSize.w8,height: AppSize.h8,
                          ),
                        ],
                      ),


                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                TextWidget(text:consult.userType==AppConstants.consultant? consult.price! + "\$":
                double.parse(consult.balance.toString()).toStringAsFixed(2) + "\$",
                  color: AppColors.warmPurple4,
                  weight: AppFontsWeightManager.semiBold,size: AppSize.w13,
                  align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
                SizedBox(height: 20,),
                /* TextWidget(text:  consult.consultType == null ? "..." : consult.consultType,
                    color: Color.fromRGBO( 32 ,32, 32,1),
                    weight: FontWeight.normal,size: 11,
                    align: TextAlign.start,family: getTranslated(context, 'Ithra'),),*/

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConsultSupervisorScreen(
                          consultant: consult, key: null, loggedUser:loggedUser ,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppPadding.p20,vertical: AppPadding.p5),
                    decoration: BoxDecoration(
                      color: AppColors.pink,
                      borderRadius: BorderRadius.circular(AppRadius.r16),
                    ),child: Image.asset(
                         getTranslated(context, "arrow3"),width: AppSize.w24,height: AppSize.h24,
                        ),),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  }
}
