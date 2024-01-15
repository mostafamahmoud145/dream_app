
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/reviews_screen.dart';

class ConsultantListItem1 extends StatelessWidget {
  final GroceryUser consult;
  final GroceryUser loggedUser;

  ConsultantListItem1({required this.consult, required this.loggedUser});

  @override
  Widget build(BuildContext context) {
    String languages = "";
    bool avaliable = false;
    DateTime _now = DateTime.now();
    String dayNow = _now.weekday.toString();
    int timeNow = _now.hour;
    if (consult.workDays!.contains(dayNow)) {
      if (int.parse(consult.workTimes![0].from!) <= timeNow &&
          int.parse(consult.workTimes![0].to!) >= timeNow) {
        avaliable = true;
      }
    }
    if (consult.languages!.length > 0)
      consult.languages!.forEach((element) {
        languages = languages + " " + element;
      });
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewScreens(
              consult: consult,
              loggedUser: loggedUser,
              reviewLength:1,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppPadding.p10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(AppRadius.r25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: AppPadding.p1),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: AppSize.h70,
                        width: AppSize.w70,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.pureBlack, width: 3),
                          shape: BoxShape.circle,
                          color: AppColors.white,
                        ),
                        child: consult.photoUrl!.isEmpty
                            ? Icon(
                                Icons.person,
                                color: AppColors.pureBlack,
                                size: AppSize.w50,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.r100),
                                child: FadeInImage.assetNetwork(
                                  placeholder: AssetsManager.icon_personPath,
                                  placeholderScale: 0.5,
                                  imageErrorBuilder:
                                      (context, error, stackTrace) => Icon(
                                    Icons.person,
                                    color: AppColors.pureBlack,
                                    size: AppSize.w50,
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
                        bottom: 5,
                        left: 5.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.r50),
                          child: Material(
                            color: Theme.of(context).primaryColor,
                            child: InkWell(
                              splashColor: AppColors.white.withOpacity(0.5),
                              onTap: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: AppColors.pureBlack, width: AppSize.w2),
                                  shape: BoxShape.circle,
                                  color:
                                      avaliable ? AppColors.green : Colors.red,
                                ),
                                width: AppSize.w10,
                                height: AppSize.h10,
                              ),
                            ),
                          ),
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
                      Text(
                        consult.name!,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.mobile_screen_share,
                            size: AppSize.w15,
                            color: AppColors.white,
                          ),
                          Text(
                            consult.phoneNumber!,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.mic_none,
                            size: AppSize.w18_6,
                            color: AppColors.white,
                          ),
                          Text(
                            languages,
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
 SizedBox(height: AppSize.h2,),
                            Row( mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.mic,
                                      size: AppSize.w15,
                                      color: AppColors.white,
                                    ),
                                    Text(
                                      getTranslated(context, "voice"),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      maxLines: 1,
                                      style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                                        color: AppColors.white,
                                        fontSize: AppFontsSizeManager.s11,
                                        //fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: AppSize.w10,),
                                Row(mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: AppSize.w15,
                                      color: AppColors.white,
                                    ),

                                    Text(
                                      getTranslated(context, "chat"),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      maxLines: 1,
                                      style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                                        color: AppColors.white,
                                        fontSize: AppFontsSizeManager.s11,
                                        //fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),

                      //SizedBox(height: 2,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.star,
                                size: AppSize.w13,
                                color: AppColors.yellow,
                              ),
                              Text(
                                consult.rating.toStringAsFixed(1),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                                  color: AppColors.white,
                                  fontSize: AppFontsSizeManager.s13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: AppSize.w20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                AssetsManager.green_call_icon_path,
                                width: AppSize.w15,
                                height: AppSize.h15,
                              ),
                              Text(
                                consult.ordersNumbers.toString(),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                                  color: AppColors.white,
                                  fontSize: AppFontsSizeManager.s15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      consult.price! + "\$",
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.white,
                        fontSize: AppFontsSizeManager.s15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(
                      height: AppSize.h5,
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: consult.phoneNumber.toString()));
                        Fluttertoast.showToast(
                            msg: "phone is copped",
                            toastLength: Toast.LENGTH_SHORT,
                            backgroundColor: AppColors.red,
                            textColor: AppColors.white);
                      },
                      child: Container(
                        width: AppSize.w40,
                        height: AppSize.h40,
                        decoration: BoxDecoration(
                            // border: Border.all( color: Colors.red[500],),
                            color: avaliable ? AppColors.green : AppColors.red,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Center(
                            child: Icon(
                          Icons.copy,
                          color: AppColors.pureBlack,
                          size: AppSize.w18_6,
                        )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: AppSize.h20,
          )
        ],
      ),
    );
  }
}
