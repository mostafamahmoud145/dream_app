
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/colorsFile.dart';
import '../methods/convert_pt_to_px.dart';
import '../widget/back_button.dart';

class MoreScreen extends StatefulWidget {
  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  final _key = UniqueKey();
  String lang = "";

  @override
  void initState() {
    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang =getTranslated(context, "lang");
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
                          getTranslated(context, "dream"),
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
          Container(
              color: AppColors.lightGrey,
              height: AppSize.h2.h,
              width: size.width ),
          Expanded(
            child: Stack(
              children: <Widget>[
                WebView(
                  key: _key,
                  initialUrl: getTranslated(context, 'lang') == "ar"
                      ? "https://dream-app.net/?lang=ar"
                      : "https://dream-app.net/search-page/",
                  javascriptMode: JavascriptMode.unrestricted,
                  gestureNavigationEnabled: true,
                  initialMediaPlaybackPolicy:
                      AutoMediaPlaybackPolicy.always_allow,
                  onPageFinished: (finish) {
                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
                isLoading == true
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Stack(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
