import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';

import '../localization/localization_methods.dart';
import '../widget/playVideoWidget.dart';

// Construct Dots Indicator

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  // declare and initizlize the page controllers
  final PageController _pageController = PageController(initialPage: 0);

  // the index of the current page
  int _activePage = 0;

  // this list holds all the pages
  // all of them are constructed in the very end of this file for readability
  final List<Widget> _pages = [
    const PageOne(),
    const PageTwo(),
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.lightGrey3,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _activePage = page;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (BuildContext context, int index) {
              return _pages[index % _pages.length];
            },
          ),
          // Display the prevButton
          Visibility(
            visible: _activePage == 1,
            child: getTranslated(context, "lang") == "ar"
                ? Positioned(top: 50, right: 30, child: prevButton())
                : Positioned(top: 50, left: 30, child: prevButton()),
          ),
          // Display the nextButton
          Visibility(
            visible: _activePage == 0,
            child: getTranslated(context, "lang") == "ar"
                ? Positioned(top: 50, left: 30, child: nextButton())
                : Positioned(top: 50, right: 30, child: nextButton()),
          ),
          // Display the top login
          // Visibility(visible: _activePage==1,child:Positioned(
          //     top: 40,
          //     left: 20,
          //     child: loginAsGuestButton()
          // ),),
          // Display the bottomImage
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              color: AppColors.lightGrey3,
              child: Image.asset(
                'assets/applicationIcons/tail.png',
                fit: BoxFit.fitWidth,
                width: size.width,
                height: 100,
              ),
            ),
          ),
          // Display the dots indicator
          Positioned(
            bottom: 170,
            left: 0,
            right: 0,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                    _pages.length,
                    (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: InkWell(
                            onTap: () {
                              _pageController.animateToPage(index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn);
                            },
                            child: _activePage == index
                                ? Container(
                                    width: 22,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.pink2,
                                      borderRadius: BorderRadius.circular(7.0),
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 5,
                                    backgroundColor:
                                        Color.fromRGBO(156, 57, 129, 0.27)),
                          ),
                        )),
              ),
            ),
          ),
          Visibility(
            visible: _activePage == 1,
            child: Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 108).w,
                    child: loginButton())),
          ),
          // Display the top login
          Visibility(
            visible: _activePage == 1,
            child: Positioned(
                bottom: 60,
                right: 0,
                left: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "ــ",
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.linear3,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    loginAsGuestButton(),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "ــ",
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.linear3,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  prevButton() {
    return InkWell(
      onTap: () {
        //Navigator.pop(context);
        _pageController.animateToPage(0,
            duration: Duration(milliseconds: 400), curve: Curves.easeIn);
      },
      child: getTranslated(context, "lang") == "ar"
          ? Row(
              children: [
                Image.asset(
                  AssetsManager.purple_right_arrowPath,
                  width: 28.w,
                  height: 22.h,
                ),
                SizedBox(width: 10.w),
                Text(
                  getTranslated(context, "prev"),
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.linear3,
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Image.asset(
                  'assets/applicationIcons/arrow-left@3x.png',
                  width: 28.w,
                  height: 22.h,
                ),
                SizedBox(width: 10.w),
                Text(
                  getTranslated(context, "prev"),
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.pink2,
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }

  nextButton() {
    return InkWell(
      onTap: () {
        //Navigator.popAndPushNamed(context, '/home');
        _pageController.animateToPage(1,
            duration: Duration(milliseconds: 400), curve: Curves.easeIn);
      },
      child: getTranslated(context, "lang") == "ar"
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  getTranslated(context, "next"),
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.linear3,
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 10.w),
                Image.asset(
                  'assets/applicationIcons/arrow-left@3x.png',
                  width: 28.w,
                  height: 21.h,
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  getTranslated(context, "next"),
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.pink2,
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 10.w),
                Image.asset(
                 AssetsManager.purple_right_arrowPath,
                  width: 28.w,
                  height: 22.h,
                ),
              ],
            ),
    );
  }

  loginAsGuestButton() {
    return InkWell(
      onTap: () {
        //Navigator.popAndPushNamed(context, '/Register_Type');
        Navigator.popAndPushNamed(context, '/home');
      },
      child: Text(
        getTranslated(context, "loginAsGuest"),
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        maxLines: 1,
        style: TextStyle(
          fontFamily: getTranslated(context, "Ithra"),
          color: AppColors.linear3,
          fontSize: 21.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  loginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.linear3,
          padding: EdgeInsets.symmetric(horizontal: 107.h)),
      onPressed: () {
        Navigator.popAndPushNamed(context, '/Register_Type');
      },
      child: Text(
        getTranslated(context, "login"),
        style: TextStyle(
            fontFamily: getTranslated(context, "Ithra"),
          color: Color.fromRGBO(255, 255, 255, 1),
            fontWeight: FontWeight.w300,
            fontStyle:  FontStyle.normal,
            fontSize: 22.sp,
        ),
      ),
    );
    // InkWell(onTap: (){
    //   Navigator.popAndPushNamed(context, '/Register_Type');
    // },
    //   child:  Text(
    //     getTranslated(context, "login"),
    //     textAlign: TextAlign.start,
    //     overflow: TextOverflow.ellipsis,
    //     softWrap: false,
    //     maxLines: 1,
    //     style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
    //       color: AppColors.white,
    //       fontSize: 15.0,
    //       fontWeight: FontWeight.w600,
    //     ),
    //   ),
    //
    // );
  }
}

// Page One
class PageOne extends StatelessWidget {
  const PageOne({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36).w,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              child: PlayVideoWidget(
            url:
                "https://firebasestorage.googleapis.com/v0/b/dream-43bb8.appspot.com/o/files%2F6ac7c88a-6ef0-4a04-8ad9-dd8ec85177b6?alt=media&token=e9cd6c68-1cb5-4101-8a97-23760db14ad1",
          )),
          SizedBox(
            height: 77.h,
          ),
          Text(
            getTranslated(context, "app"),
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            maxLines: 1,
            style: TextStyle(
              fontFamily: 'bukra',
              color: AppColors.linear3,
              fontSize: 30.5.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Text(
            getTranslated(context, "appText"),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            maxLines: 15,
            style: TextStyle(
              fontFamily: getTranslated(context, "Ithra"),
              color: Color.fromRGBO(32, 32, 32, 1),
              fontSize: 21.sp,
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(
            height: 61.h,
          ),
        ],
      ),
    );
  }
}

// Page Two
class PageTwo extends StatelessWidget {
  const PageTwo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/applicationIcons/boardImage.png',
            width: 400.w,
            height: 390.h,
          ),
          SizedBox(
            height: 77.h,
          ),
          Text(
            getTranslated(context, "benefits"),
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            maxLines: 1,
            style: TextStyle(
              fontFamily: 'bukra',
              color: AppColors.linear3,
              fontSize: 30.5.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Text(
            getTranslated(context, "benefitsText"),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            maxLines: 15,
            style: TextStyle(
              fontFamily: getTranslated(context, "Ithra"),
              color: Color.fromRGBO(32, 32, 32, 1),
              fontSize: 21.sp,
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(
            height: 92.h,
          ),
        ],
      ),
    );
  }
}

// Page Three
class PageThree extends StatelessWidget {
  const PageThree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        color: Colors.blue,
        child: const Text(
          'Blue Page',
          style: TextStyle(fontSize: 50, color: AppColors.white),
        ));
  }
}
