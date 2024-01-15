// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/InvoiceModel.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../config/colorsFile.dart';

class UserInvoiceItem extends StatefulWidget {
Invoice invoice;
UserInvoiceItem({required this.invoice});

  @override
  State<UserInvoiceItem> createState() => _UserInvoiceItemState();
}

class _UserInvoiceItemState extends State<UserInvoiceItem> {
String status="..";
bool load=true;
  void initState() {
    if(widget.invoice.platform == 'Stripe')
      checksStripeStatus();
      else checkStatus();
    super.initState();

  }
  checkStatus() async {
    try{

      final uri = Uri.parse('https://api.tap.company/v2/invoices/'+widget.invoice.id!);
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization':"Bearer sk_live_UN9kc65zvtmrX1PjnagRYhLb",
        'Connection':'keep-alive',
        'Accept-Encoding':'gzip, deflate, br'
      };
      var response = await http.get(
        uri,
        headers: headers,

      );
      if(response.body.contains("errors"))
        { setState(() {
          status="...";
          load=false;
        });}
      else{
        String responseBody = response.body;
        var res = json.decode(responseBody);
        setState(() {
          status=res['status'];
          load=false;
        });
      }

    }catch(e){
      setState(() {
        status="...";
        load=false;
      });
    }
  }

  checksStripeStatus() async {
  try{

    var response = await http.post( Uri.parse(
        'https://us-central1-dream-43bb8.cloudfunctions.net/getInvoice'),
      body: {
        'id' : widget.invoice.invoiceId,
      },
    );

    String responseBody = response.body;
    var res = json.decode(responseBody);
    setState(() {
      status=res['status'];
      load=false;
    });
  }catch(e){

  }
}


  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size;


    DateFormat dateFormat = DateFormat('dd/MM/yy');
    return  Scaffold(backgroundColor: AppColors.white,
      body: Padding(
        padding: const EdgeInsets.only(top:50,left: 20,right:20),
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: (){
                          Clipboard.setData(ClipboardData(text: widget.invoice.invoice.toString()));
                          Fluttertoast.showToast(
                            msg: getTranslated(context, "textCopy"),
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.TOP,
                            timeInSecForIosWeb: 5,
                            backgroundColor: Colors.green,
                            textColor: AppColors.white,
                            fontSize: 16.0.sp,
                          );

                        },
                        icon:Icon(Icons.copy,color: Theme.of(context).primaryColor,)),
                    Spacer(),
                    Row(
                      children: [
                        Text(getTranslated(context, "invoices"),
                          style: TextStyle(
                            color: Theme
                                .of(context)
                                .primaryColor,
                           fontFamily: getTranslated(context, 'Ithra'),
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        IconButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            icon:Icon(Icons.arrow_forward_outlined,color: Theme.of(context).primaryColor,)),
                      ],
                    )
                  ],
                ),
                SizedBox(height:40),
                Stack(alignment: Alignment.center,children: [
                  Container(
                    height: 81,
                    width: 81,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey,width: 1),
                      shape: BoxShape.circle,
                      color: AppColors.white,
                    ),
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.white,width: 5),
                        shape: BoxShape.circle,
                        color: AppColors.white,
                      ),
                      child: widget.invoice.user!.image!.isEmpty ?Image.asset(AssetsManager.dreamLogoPurpleImagePath,width: AppSize.w40,height: AppSize.w40,fit:BoxFit.fill,)
                          :ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: FadeInImage.assetNetwork(
                          placeholder:AssetsManager.loadImagePath,
                          placeholderScale: 0.5,
                          imageErrorBuilder:(context, error, stackTrace) => Image.asset(AssetsManager.dreamLogoPurpleImagePath,width: AppSize.w81,height: AppSize.h81,fit:BoxFit.fill,),
                          image: widget.invoice.user!.image!,
                          fit: BoxFit.cover,
                          fadeInDuration:
                          Duration(milliseconds: AppConstants.milliseconds250),
                          fadeInCurve: Curves.easeInOut,
                          fadeOutDuration:
                          Duration(milliseconds: AppConstants.milliseconds150),
                          fadeOutCurve: Curves.easeInOut,
                        ),
                      ),
                    ),
                  ),
                  Image.asset(AssetsManager.dashBoarderImagePath,width: AppSize.w86,height: AppSize.h86,)
                ], ),
                SizedBox(height:AppSize.h15),
                Text(widget.invoice.user!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                   fontFamily: getTranslated(context, 'Ithra'),
                        color: Theme.of(context).primaryColor,
                        fontSize: AppFontsSizeManager.s13.sp,
                        fontWeight: FontWeight.w600
                    )),
                SizedBox(height:AppSize.h50),
                Card(
                  shape:RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r15),),
                  elevation:2,
                  shadowColor: Theme.of(context).primaryColor,
                  color: AppColors.white,
                  child: Container(
                    width: size.width*AppSize.w8,
                    //height: size.height*.39,
                    child: Padding(
                      padding: const EdgeInsets.all(AppRadius.r20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(getTranslated(context, "clientName"),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                  fontFamily: getTranslated(context, 'Ithra'),
                                      color: Theme.of(context).primaryColor,
                                      fontSize: AppFontsSizeManager.s13.sp,
                                      fontWeight: FontWeight.w600
                                  )),
                              Spacer(),
                              Text(widget.invoice.user!.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                  fontFamily: getTranslated(context, 'Ithra'),
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600
                                  )),
                            ],
                          ),
                          SizedBox(height:20),
                          Row(
                            children: [
                              Text(getTranslated(context, "clientaccount"),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                  fontFamily: getTranslated(context, 'Ithra'),
                                      color: Theme.of(context).primaryColor,
                                      fontSize: AppFontsSizeManager.s13.sp,
                                      fontWeight: FontWeight.w600
                                  )),
                              Spacer(),
                              Text(widget.invoice.email!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                  fontFamily: getTranslated(context, 'Ithra'),
                                      color: Theme.of(context).primaryColor,
                                      fontSize: AppFontsSizeManager.s13,
                                      fontWeight: FontWeight.w600
                                  )),
                            ],
                          ),
                          SizedBox(height:AppSize.h20),
                          Row(
                            children: [
                              Text(getTranslated(context, "phoneNumber"),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                  fontFamily: getTranslated(context, 'Ithra'),
                                      color: Theme.of(context).primaryColor,
                                      fontSize: AppFontsSizeManager.s13,
                                      fontWeight: FontWeight.w600
                                  )),
                              Spacer(),
                              Text(widget.invoice.user!.phone,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: getTranslated(context, 'Ithra'),
                                      color: Theme.of(context).primaryColor,
                                      fontSize: AppFontsSizeManager.s13,
                                      fontWeight: FontWeight.w600
                                  )),
                            ],
                          ),
                          SizedBox(height:20),
                          Row(
                            children: [
                              Text(getTranslated(context, "due"),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: getTranslated(context, 'Ithra'),
                                      color: Theme.of(context).primaryColor,
                                      fontSize: AppFontsSizeManager.s13,
                                      fontWeight: FontWeight.w600
                                  )),
                              Spacer(),
                              Text('${dateFormat.format(widget.invoice.timestamp!.toDate())}',
                                  //'${dateFormat.format(widget.invoice.due.toDate())}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: getTranslated(context, 'Ithra'),
                                      color: Theme.of(context).primaryColor,
                                      fontSize: AppFontsSizeManager.s13,
                                      fontWeight: FontWeight.w600
                                  )),
                            ],
                          ),
                          SizedBox(height:20),
                          Row(
                            children: [
                              Text(getTranslated(context, "expireDate"),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: getTranslated(context, 'Ithra'),
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600
                                  )),
                              Spacer(),
                              Text('${dateFormat.format(widget.invoice.expire!.toDate())}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: getTranslated(context, 'Ithra'),
                                      color: Theme.of(context).primaryColor,
                                      fontSize: AppFontsSizeManager.s13,
                                      fontWeight: FontWeight.w600
                                  )),
                            ],
                          ),
                          SizedBox(height:20),
                          Row(
                            children: [
                              Text(getTranslated(context, "price"),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: getTranslated(context, 'Ithra'),
                                      color: Theme.of(context).primaryColor,
                                      fontSize: AppFontsSizeManager.s13,
                                      fontWeight: FontWeight.w600
                                  )),
                              Spacer(),
                              Text(widget.invoice.price,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: getTranslated(context, 'Ithra'),
                                      color: Theme.of(context).primaryColor,
                                      fontSize: AppFontsSizeManager.s13,
                                      fontWeight: FontWeight.w600
                                  )),
                            ],
                          ),
                          SizedBox(height:AppSize.h20),
                          Row(
                            children: [
                              Text(getTranslated(context, "status"),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: getTranslated(context, 'Ithra'),
                                      color: Theme.of(context).primaryColor,
                                      fontSize: AppFontsSizeManager.s13,
                                      fontWeight: FontWeight.w600
                                  )),
                              Spacer(),
                              //Icon(Icons.check_circle_outline,color: Colors.green,)
                              load?CircularProgressIndicator(): Text(status,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: getTranslated(context, 'Ithra'),
                                      color: Theme.of(context).primaryColor,
                                      fontSize: AppFontsSizeManager.s13,
                                      fontWeight: FontWeight.w600
                                  )),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

