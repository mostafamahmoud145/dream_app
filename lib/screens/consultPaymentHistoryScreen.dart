import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grocery_store/api/pdf_api.dart';
import 'package:grocery_store/api/pdf_paragraph_api.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/payHistory.dart';
import 'package:grocery_store/models/user.dart';
import 'package:intl/intl.dart';

import '../config/colorsFile.dart';
import '../widget/back_button.dart';
import 'invoice_service.dart';

class ConsultPaymentHistoryScreen extends StatefulWidget {
  final GroceryUser user;

  const ConsultPaymentHistoryScreen({Key? key, required this.user})
      : super(key: key);

  @override
  _ConsultPaymentHistoryScreenState createState() =>
      _ConsultPaymentHistoryScreenState();
}

class _ConsultPaymentHistoryScreenState
    extends State<ConsultPaymentHistoryScreen>
    with SingleTickerProviderStateMixin {
  List<PayHistory> PayHistoryList = [];
  bool load = false;
  String lang = "";
  final PdfInvoiceService service = PdfInvoiceService();

  @override
  void initState() {
    super.initState();
    getPaymentHistory();
  }

  getPaymentHistory() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.payHistoryPath)
          .where('consultUid', isEqualTo: widget.user.uid)
          .orderBy("payDate", descending: true)
          .get();
      var payList = List<PayHistory>.from(
        querySnapshot.docs.map(
          (snapshot) => PayHistory.fromMap(snapshot.data() as Map),
        ),
      );
      setState(() {
        PayHistoryList = payList;
        load = false;
      });
    } catch (e) {
      setState(() {
        load = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int numItems = 10;
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding(
                padding: EdgeInsets.only(
                    right: AppPadding.p32.w,
                    left: lang == "ar" ? AppPadding.p0 : AppPadding.p32.w,
                    top: AppPadding.p16.h,
                    bottom: AppPadding.p16.h),
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
                      getTranslated(context, "paymentHistory2"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithra'),
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        color: AppColors.pureBlack.withOpacity(0.8),
                        //  fontWeight: AppFontsWeightManager.bold
                      ),
                    ),
                  ],
                ),
              ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey,
                  height: AppSize.h2.h,
                  width: size.width * 1)),
          SizedBox(
            height: AppSize.h32.h,
          ),
          SizedBox(
              height: AppSize.w166_6.h,
              width: AppSize.w124.w,
              child: SvgPicture.asset(
                AssetsManager.walletImagePath,
              )),
          SizedBox(
            height: AppSize.h32.h,
          ),
          load
              ? CircularProgressIndicator()
              : Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: AppSize.w34.w),
                    children: [
                      for (int x = 0; x < PayHistoryList.length; x++)
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: AppPadding.p10_6.h,
                                  bottom: AppPadding.p10_6.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    // '${new DateFormat('dd MMM yyyy, hh:mm a').format((PayHistoryList[x].payTime.toDate()))}',
                                    //'${new DateFormat('d' + 'MMM' + " " + 'yyyy').format((PayHistoryList[x].payTime.toDate()))}',
                                    '${new DateFormat('d' + 'MMM ' + 'yyyy').format((PayHistoryList[x].payTime.toDate()))}',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontFamily: getTranslated(
                                            context, "Ithralight"),
                                        fontSize: AppFontsSizeManager.s18_6.sp,
                                        color: AppColors.pink,
                                        fontWeight:
                                            AppFontsWeightManager.regular),
                                  ),
                                  Spacer(),
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: AppSize.h15.h,
                                        child: Text(
                                          "\$",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              //backgroundColor: Colors.red,
                                              height: AppSize.h0_8.h,
                                              fontFamily: getTranslated(
                                                  context, "Ithra"),
                                              fontSize:
                                                  AppFontsSizeManager.s21_3.sp,
                                              color: AppColors.appbartext,
                                              fontWeight: AppFontsWeightManager
                                                  .bold500),
                                        ),
                                      ),
                                      Text(
                                        double.parse(PayHistoryList[x]
                                                .balance
                                                .toString())
                                            .toStringAsFixed(1),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontFamily: getTranslated(
                                                context, "Montserrat-SemiBold"),
                                            fontSize:
                                                AppFontsSizeManager.s21_3.sp,
                                            color: AppColors.appbartext,
                                            fontWeight:
                                                AppFontsWeightManager.bold500),
                                      ),
                                    ],
                                  ),
                                  Spacer(
                                    flex: 2,
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      final String date =
                                          '${new DateFormat('dd MMM yyyy').format(PayHistoryList[x].payTime.toDate())}';
                                      final pdfFile =
                                          await PdfParagraphApi.generate(
                                              widget.user,
                                              PayHistoryList[x],
                                              date,
                                              size);
                                      PdfApi.openFile(pdfFile);
                                    },
                                    child:
                                        //  Icon(
                                        //   Icons.arrow_circle_down,
                                        //   color: AppColors.pink,
                                        //   size: AppSize.w32.w,
                                        // ),
                                        SvgPicture.asset(
                                      'assets/Dream_Icons/gg_arrow-up-o.svg',
                                      // AssetsManager.arrowDownCricle2,
                                      height: AppSize.h32.h,
                                      width: AppSize.w32.w,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: AppPadding.p20.h),
                              child: Container(
                                height: AppSize.h1,
                                width: double.infinity,
                                color: AppColors.linea,
                              ),
                            )
                          ],
                        ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
