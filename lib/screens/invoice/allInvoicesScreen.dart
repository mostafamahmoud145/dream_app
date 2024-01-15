
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/invicelistitemWidget.dart';

import '../../FireStorePagnation/paginate_firestore.dart';
import '../../models/InvoiceModel.dart';
import 'addInvoiceScreen.dart';


class AllInvoicesScreen extends StatefulWidget {
   final GroceryUser loggedUser;
   const AllInvoicesScreen({required this.loggedUser});

   @override
  _AllInvoicesScreenState createState() => _AllInvoicesScreenState();
}
class _AllInvoicesScreenState extends State<AllInvoicesScreen>with SingleTickerProviderStateMixin {
  @override


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(backgroundColor: AppColors.white,
      body: Stack(children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top:10),
          child: Column(
            children: <Widget>[
              Container(
                width: size.width,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.only(right: AppPadding.p32.w, top: AppPadding.p35.h, bottom: AppPadding.p20.h),

                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.r50),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: AppColors.white.withOpacity(0.5),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  width: AppSize.w38,
                                  height: AppSize.h35,
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: AppColors.pink,
                                    size: AppSize.w24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                         SizedBox()

                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSize.h5,),
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: EdgeInsets.only(left: AppMargin.m80),
                  color: AppColors.black1,
                  width: AppSize.w60,
                  height: AppSize.h1,
                ),
              ),
              SizedBox(height: AppSize.h6),
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: EdgeInsets.only(left: AppMargin.m80),
                  color: AppColors.black1,
                  width: AppSize.w100,
                  height: AppSize.h1,
                ),
              ),
              Text(getTranslated(context, "invoices"),
                style: TextStyle(
                  color: Theme
                      .of(context)
                      .primaryColor,
                 fontFamily: getTranslated(context, 'Ithra'),
                  fontSize: AppFontsSizeManager.s35.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: AppConstants.letterSpacing,
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: EdgeInsets.only(right: AppMargin.m80),
                  color: AppColors.black1,
                  width: AppSize.w100,
                  height: AppSize.h1,
                ),
              ),
              SizedBox(height: AppSize.h6),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: EdgeInsets.only(right: AppMargin.m80),
                  color: AppColors.black1,
                  width: AppSize.w60,
                  height: AppSize.h1,
                ),
              ),
              SizedBox(height: AppSize.h10),
              Expanded(
                child: PaginateFirestore(separator: SizedBox(height: AppSize.h10,),
                  itemBuilderType: PaginateBuilderType.listView,
                  padding: const EdgeInsets.only(
                      left: AppPadding.p16, right: AppPadding.p16, bottom: AppPadding.p16, top: AppPadding.p16),//Change types accordingly
                  itemBuilder: ( context, documentSnapshot,index) {
                    return  InvoiceListItem(
                      invoice: Invoice.fromMap(documentSnapshot[index].data() as Map),

                    );
                  },
                  query: FirebaseFirestore.instance.collection(Paths.invoicePath)
                      .orderBy('timestamp', descending: true),
                  // to fetch real-time data
                  isLive: true,
                ),
              )
            ],
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>AddInvoiceScreen(loggedUser: widget.loggedUser,)));
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,

      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );

  }
}

