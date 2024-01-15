
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../config/colorsFile.dart';
import '../widget/back_button.dart';

class AboutUsScreen extends StatefulWidget {

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen>with SingleTickerProviderStateMixin {
  bool isLoading=true;
  final _key = UniqueKey();
String url="https://dream-app.net/?lang=ar",lang="ar";
  @override
  void initState() {
    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang=getTranslated(context,"lang");
    if(lang!="ar")url="https://dream-app.net/";
    return Scaffold(backgroundColor: AppColors.white,
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: AppPadding.p32.w,
                        left: lang=="ar"?AppPadding.p0:AppPadding.p32.w,
                        top: AppPadding.p35.h,
                        bottom: AppPadding.p20.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomBackButton(),
                        // IconButton1(
                        //   radius: AppRadius.r10_6.r,
                        //   color: AppColors.white,
                        //   shadowcolor: AppColors.warmPurple,
                        //   iconsize: AppSize.w50.r,
                        //   icon: lang=="ar"? AssetsManager.purple_right_arrowPath:AssetsManager.purple_left_arrowPath,
                        //   iconcolor: AppColors.linear2,
                        //   onPress: () {
                        //     Navigator.pop(context);
                        //   },
                        //   width: AppSize.w50.w,
                        //   height: AppSize.h50.h,
                        // ),
                        SizedBox(width: AppSize.w21_3.w),
                        Text(
                          getTranslated(context, "aboutUs"),
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
                  color: AppColors.lightGrey, height: AppSize.h2.h, width: size.width * .9)),
          Expanded(
            child: Stack(
              children: <Widget>[
                WebView(
                  key: _key,
                  initialUrl: url,
                  javascriptMode: JavascriptMode.unrestricted,
                  gestureNavigationEnabled: true,
                  initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
                  onPageFinished: (finish) {
                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
                isLoading ? Center( child: CircularProgressIndicator(),)
                    : Stack(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
