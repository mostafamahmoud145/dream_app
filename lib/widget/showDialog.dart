import 'package:flutter/material.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';

import '../localization/localization_methods.dart';

class ShowDialog extends StatefulWidget {

  final String contentText;
  final VoidCallback noFunction;
  final VoidCallback yesFunction;

  const ShowDialog({Key? key, required this.contentText, required this.noFunction, required this.yesFunction}) : super(key: key);

  @override
  State<ShowDialog> createState() => _ShowDialogState();
}

class _ShowDialogState extends State<ShowDialog> {
  @override
  Widget build(BuildContext context) {
    return  AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppRadius.r15),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(
            left: AppPadding.p16, right: AppPadding.p16, top: AppPadding.p20, bottom: AppPadding.p10),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: AppSize.h15,
                ),
                Text(
                  getTranslated(context, widget.contentText),
                  style: TextStyle(
                   fontFamily: getTranslated(context, "Ithra"),
                    fontSize: AppFontsSizeManager.s14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                    color: AppColors.black1,
                  ),
                ),
                SizedBox(
                  height: AppSize.h5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      width:AppSize.w50,
                      child: MaterialButton(
                        padding: const EdgeInsets.all(0.0),
                        onPressed: widget.noFunction,
                        child: Text(
                          getTranslated(context, 'no'),
                          style: TextStyle(
                           fontFamily: getTranslated(context, "Ithra"),
                            color: AppColors.black1,
                            fontSize: AppFontsSizeManager.s13_5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                     Container(
                      width: AppSize.w50,
                      child: MaterialButton(
                        padding: const EdgeInsets.all(0.0),
                        onPressed: widget.yesFunction,
                        child: Text(
                          getTranslated(context, 'yes'),
                          style: TextStyle(
                           fontFamily: getTranslated(context, "Ithra"),
                            color:AppColors.redShade700,
                            fontSize: AppFontsSizeManager.s13_5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
  }
}
