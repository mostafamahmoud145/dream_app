

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class AddInvoiceScreen extends StatefulWidget {
  final GroceryUser loggedUser;
  AddInvoiceScreen({
    required this.loggedUser,
  });
  @override

  _AddInvoiceScreenState createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  late String owner,
      code,
      discount,
      theme = "light";
  bool createInvoiceDone = false, showEmail = true;


  @override
  void initState() {
    super.initState();
    createInvoiceDone = false;
  }


  TextEditingController nameController = TextEditingController();
  TextEditingController consultantNameController = TextEditingController();
  TextEditingController dueDateController = TextEditingController();
  TextEditingController expireDateController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  var due, expire;
  late GroceryUser user;
  List<GroceryUser> users = [];
  List<String> paymentGatewayList = <String>['Tap Company', 'Stripe'];
  String gateWayValue = "Tap Company";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Scaffold(backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.only(top: AppPadding.p60, left: AppPadding.p30, right: AppPadding.p30),
            child: Column(
              //  crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
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
                Text(getTranslated(context, "createInvoice"),
                  style: TextStyle(
                    color: Theme
                        .of(context)
                        .primaryColor,
                   fontFamily: getTranslated(context, "Ithra"),
                    fontSize: AppFontsSizeManager.s35,
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
                SizedBox(height: AppSize.h30),
                TextFormField(
                  controller: nameController,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return getTranslated(context, "plsEnterClientName");
                    }
                    return null;
                  },
                  onSaved: (val) {},
                  enableInteractiveSelection: true,
                  style: TextStyle(
                   fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.pureBlack,
                    fontSize: AppFontsSizeManager.s14_5,
                    fontWeight: FontWeight.w500,
                      letterSpacing:AppConstants.letterSpacing,
                  ),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: AppPadding.p15),
                    helperStyle: TextStyle(
                     fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.pureBlack.withOpacity(0.65),
                      fontWeight: FontWeight.w500,
                      letterSpacing:AppConstants.letterSpacing,
                    ),
                    errorStyle: TextStyle(
                     fontFamily: getTranslated(context, "Ithra"),
                      fontSize: AppFontsSizeManager.s13,
                      fontWeight: FontWeight.w500,
                        letterSpacing:AppConstants.letterSpacing,
                    ),
                    hintStyle: TextStyle(
                     fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.black1,
                      fontSize: AppFontsSizeManager.s14_5,
                      fontWeight: FontWeight.w500,
                        letterSpacing:AppConstants.letterSpacing,
                    ),
                    labelText: getTranslated(context, "clientName"),
                    labelStyle: TextStyle(
                       fontFamily: getTranslated(context, "Ithra"),
                        fontSize: AppFontsSizeManager.s14_5,
                        fontWeight: FontWeight.w500,
                          letterSpacing:AppConstants.letterSpacing,
                        color: Theme
                            .of(context)
                            .primaryColor
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r5),
                    ),
                  ),
                ),
               SizedBox(
                  height: AppSize.h30,
                ),
                 TextFormField(
                  controller: emailController,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return getTranslated(context, "plsEnterClientEmail");
                    }
                    return null;
                  },
                  onSaved: (val) {},
                  enableInteractiveSelection: true,
                  style: TextStyle(
                   fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.pureBlack,
                    fontSize: AppFontsSizeManager.s14_5,
                    fontWeight: FontWeight.w500,
                      letterSpacing:AppConstants.letterSpacing,
                  ),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 15.0),
                    helperStyle: TextStyle(
                     fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.pureBlack.withOpacity(0.65),
                      fontWeight: FontWeight.w500,
                        letterSpacing:AppConstants.letterSpacing,
                    ),
                    errorStyle: TextStyle(
                     fontFamily: getTranslated(context, "Ithra"),
                      fontSize: AppFontsSizeManager.s13,
                      fontWeight: FontWeight.w500,
                        letterSpacing:AppConstants.letterSpacing,
                    ),
                    hintStyle: TextStyle(
                     fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.black1,
                      fontSize: AppFontsSizeManager.s14_5,
                      fontWeight: FontWeight.w500,
                        letterSpacing:AppConstants.letterSpacing,
                    ),
                    labelText: getTranslated(context, "clientaccount"),
                    labelStyle: TextStyle(
                       fontFamily: getTranslated(context, "Ithra"),
                        fontSize: AppFontsSizeManager.s14_5,
                        fontWeight: FontWeight.w500,
                          letterSpacing:AppConstants.letterSpacing,
                        color: Theme
                            .of(context)
                            .primaryColor
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r5),
                    ),
                  ),
                ),
                SizedBox(
                  height: AppSize.h30,
                ),
                TextFormField(
                  controller: phoneController,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return getTranslated(context, "plsEnterClientPhone");
                    }
                    return null;
                  },
                  onSaved: (val) {},
                  enableInteractiveSelection: true,
                  style: TextStyle(
                   fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.pureBlack,
                    fontSize: AppFontsSizeManager.s14_5,
                    fontWeight: FontWeight.w500,
                      letterSpacing:AppConstants.letterSpacing,
                  ),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.phone,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 15.0),
                    helperStyle: TextStyle(
                     fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.pureBlack.withOpacity(0.65),
                      fontWeight: FontWeight.w500,
                        letterSpacing:AppConstants.letterSpacing,
                    ),
                    errorStyle: TextStyle(
                     fontFamily: getTranslated(context, "Ithra"),
                      fontSize: AppFontsSizeManager.s13,
                      fontWeight: FontWeight.w500,
                        letterSpacing:AppConstants.letterSpacing,
                    ),
                    hintStyle: TextStyle(
                     fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.black1,
                      fontSize: AppFontsSizeManager.s14_5,
                      fontWeight: FontWeight.w500,
                        letterSpacing:AppConstants.letterSpacing,
                    ),
                    labelText: getTranslated(context, "phoneNumber"),
                    labelStyle: TextStyle(
                       fontFamily: getTranslated(context, "Ithra"),
                        fontSize: AppFontsSizeManager.s14_5,
                        fontWeight: FontWeight.w500,
                          letterSpacing:AppConstants.letterSpacing,
                        color: Theme
                            .of(context)
                            .primaryColor
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r5),
                    ),
                  ),
                ),
                /* SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: expireDateController,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return getTranslated(context, "plsEnterExpireDate");
                    }
                  },
                  onSaved: (val) {},
                  onTap: () {
                    showDatePicker(context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 3)),
                    ).then((value) {
                      expireDateController.text = value.toString();
                      expire = value?.millisecondsSinceEpoch;
                    });
                  },
                  enableInteractiveSelection: true,
                  style: TextStyle(
                   fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.pureBlack,
                    fontSize: AppFontsSizeManager.s14_5,
                    fontWeight: FontWeight.w500,
                      letterSpacing:AppConstants.letterSpacing,
                  ),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.datetime,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 15.0),
                    helperStyle: TextStyle(
                     fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.pureBlack.withOpacity(0.65),
                      fontWeight: FontWeight.w500,
                        letterSpacing:AppConstants.letterSpacing,
                    ),
                    errorStyle: TextStyle(
                     fontFamily: getTranslated(context, "Ithra"),
                      fontSize: AppFontsSizeManager.s13,
                      fontWeight: FontWeight.w500,
                        letterSpacing:AppConstants.letterSpacing,
                    ),
                    hintStyle: TextStyle(
                     fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.black1,
                      fontSize: AppFontsSizeManager.s14_5,
                      fontWeight: FontWeight.w500,
                        letterSpacing:AppConstants.letterSpacing,
                    ),
                    labelText: getTranslated(context, "expireDate"),
                    labelStyle: TextStyle(
                       fontFamily: getTranslated(context, "Ithra"),
                        fontSize: AppFontsSizeManager.s14_5,
                        fontWeight: FontWeight.w500,
                          letterSpacing:AppConstants.letterSpacing,
                        color: Theme
                            .of(context)
                            .primaryColor
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r5),
                    ),
                  ),
                ),*/
               SizedBox(
                  height: AppSize.h30,
                ),
                TextFormField(
                  controller: priceController,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return getTranslated(context, "plsEnterPrice");
                    }
                    return null;
                  },
                  onSaved: (val) {},
                  enableInteractiveSelection: true,
                  style: TextStyle(
                   fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.pureBlack,
                    fontSize: AppFontsSizeManager.s14_5,
                    fontWeight: FontWeight.w500,
                      letterSpacing:AppConstants.letterSpacing,
                  ),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 15.0),
                    helperStyle: TextStyle(
                     fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.pureBlack.withOpacity(0.65),
                      fontWeight: FontWeight.w500,
                        letterSpacing:AppConstants.letterSpacing,
                    ),
                    errorStyle: TextStyle(
                     fontFamily: getTranslated(context, "Ithra"),
                      fontSize: AppFontsSizeManager.s13,
                      fontWeight: FontWeight.w500,
                        letterSpacing:AppConstants.letterSpacing,
                    ),
                    hintStyle: TextStyle(
                     fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.black1,
                      fontSize: AppFontsSizeManager.s14_5,
                      fontWeight: FontWeight.w500,
                        letterSpacing:AppConstants.letterSpacing,
                    ),
                    labelText: getTranslated(context, "invoiceprice"),
                    labelStyle: TextStyle(
                       fontFamily: getTranslated(context, "Ithra"),
                        fontSize: AppFontsSizeManager.s14_5,
                        fontWeight: FontWeight.w500,
                          letterSpacing:AppConstants.letterSpacing,
                        color: Theme
                            .of(context)
                            .primaryColor
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r5),
                    ),
                  ),
                ),
               SizedBox(
                  height: AppSize.h30,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(getTranslated(context, 'gateway'), style: TextStyle(
                        color: AppColors.pink,
                       fontFamily: getTranslated(context, "Ithra"),
                        fontSize: 15
                    ),),
                    Container(
                        height: 40.0, width: size.width * .5,
                        decoration: BoxDecoration(
                            color: theme == "light" ? AppColors.white : Colors
                                .transparent,
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            borderRadius:
                            BorderRadius.all(Radius.circular(10))),
                        child: Padding(
                          padding: const EdgeInsets.only(left: AppPadding.p10, right: AppPadding.p10),
                          child: DropdownButton<String>(
                            hint: Text(
                              getTranslated(context, "selectStatus"),
                              textAlign: TextAlign.center,
                              style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                                //color: AppColors.pureBlack,
                                fontSize: AppFontsSizeManager.s15,
                                  letterSpacing:AppConstants.letterSpacing,
                              ),
                            ),
                            underline: Container(),
                            isExpanded: true,
                            value: gateWayValue,
                            icon: Icon(Icons.keyboard_arrow_down,
                                color: AppColors.pureBlack),
                            iconSize: AppSize.w24,
                            elevation: 16,
                            style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                              color: AppColors.blue,
                              fontSize: AppFontsSizeManager.s13,
                                letterSpacing:AppConstants.letterSpacing,
                            ),
                            items: paymentGatewayList
                                .map((data) =>
                                DropdownMenuItem<String>(
                                    child: Text(
                                      data.toString(),
                                      style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                                        color: AppColors.pureBlack,
                                        fontSize: AppFontsSizeManager.s15,
                                          letterSpacing:AppConstants.letterSpacing,
                                      ),
                                    ),
                                    value: data.toString() //data.key,
                                ))
                                .toList(),
                            onChanged: (String? value) {
                              setState(() {
                                gateWayValue = value!;
                              });
                            },
                          ),
                        )),
                  ],
                ),
                SizedBox(
                  height: AppSize.h50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState?.save();
                          setState(() {
                            createInvoiceDone = true;
                          });
                        }

                       if (gateWayValue == "Tap Company") {
                          postTapInvoice(
                              email: emailController.text,
                              // expiry: expireDateController.text,
                              phone: phoneController.text,
                              price: priceController.text,
                              userName: nameController.text
                          );
                       }

                       else
                         {
                            setState(() {
                              showEmail = false;
                            });
                        postStripeInvoice(
                          // email: emailController.text,
                          // expiry: expireDateController.text,
                            phone: phoneController.text,
                            userName: nameController.text,
                            price: priceController.text
                        );
                      }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: AppPadding.p10, right: AppPadding.p10),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            createInvoiceDone == true
                                ? CircularProgressIndicator()
                                : Container(
                              width: size.width * AppSize.w0_3,
                              height: size.height * AppSize.w0_06,
                              decoration: BoxDecoration(
                                color: Theme
                                    .of(context)
                                    .primaryColor,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(AppRadius.r5)),
                              ),
                              child: Center(
                                child: Text(
                                  getTranslated(context, "createInvoice"),
                                  style: TextStyle(
                                   fontFamily: getTranslated(context, "Ithra"),
                                    color: AppColors.white,
                                    fontSize: AppFontsSizeManager.s15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * AppSize.w0_05,),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: AppPadding.p10, right: AppPadding.p10),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: size.width * AppSize.w0_3,
                              height: size.height * AppSize.w0_06,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                border: Border.all(color: Theme
                                    .of(context)
                                    .primaryColor),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(AppRadius.r5)),
                              ),
                              child: Center(
                                child: Text(
                                  getTranslated(context, "endInvoice"),
                                  style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                                    color: Theme
                                        .of(context)
                                        .primaryColor,
                                    fontSize: AppFontsSizeManager.s15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: AppSize.h15,
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }



  postStripeInvoice({
    required String userName,
    required var phone,
    required var price
  }) async {

    String phones = phone + "@gmail.com";

    var res;

    try{
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(Paths.usersPath)
          .where( 'phoneNumber', isEqualTo: phoneController.text, ).get();

      for (var doc in querySnapshot.docs) {
        users.add(GroceryUser.fromMap(doc.data() as Map));
      }
      if(users.length>0)
      {
        user=users[0];
        var expireDate=DateTime.now().add(Duration(days: 3));

        try {
          var response = await http.post( Uri.parse(
              'https://us-central1-dream-43bb8.cloudfunctions.net/postInvoice'),
            body: {
              'name' :userName,
              'email':phones,
              'price': (double.parse(priceController.text) * 100).round().toString()
              //(double.parse(price) * 100).toString()
            },
          );

          String responseBody = response.body;
          res = json.decode(responseBody);

        } catch (e) {
        }

        String invoiceId = res['messageData']['id'];
        await FirebaseFirestore.instance.collection(Paths.invoicePath) .doc(invoiceId).set({
          'user': {
            'uid': user.uid,
            'name': userName,
            'image': user.photoUrl,
            'phone': phone,
            'countryCode': user.countryCode,
            'countryISOCode': user.countryISOCode,
          },
          'id':res['id'],
          'expiry':expireDate,
          'email':phone + "@gmail.com",
          'price':priceController.text,
          'invoice':res['messageData']['hosted_invoice_url'],
          'timestamp':DateTime.now(),
          'platform':'Stripe',
          'invoiceId':invoiceId,
        }).then((value){
          Fluttertoast.showToast(
            msg: getTranslated(context, "invoiceCreatedDone"),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.green,
            textColor: AppColors.white,
            fontSize: 16.0,
          );
          Navigator.pop(context);
        }).catchError((error){
          Fluttertoast.showToast(
            msg: getTranslated(context, "invoiceDataError"),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: AppColors.white,
            fontSize: 16.0,
          );
          setState(() {
            createInvoiceDone=false;
          });
        });

      }
      else{
        //flutter toast
        Fluttertoast.showToast(
          msg: getTranslated(context, "invoiceDataError"),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: AppColors.white,
          fontSize: 16.0,
        );
        setState(() {
          createInvoiceDone=false;
        });
      }

    }catch(e){
      Fluttertoast.showToast(
        msg: getTranslated(context, "invoiceCreatedError"),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.red,
        textColor: AppColors.white,
        fontSize: 16.0,
      );
    }
  }



  postTapInvoice({
    required String userName,
    required var phone,
    required var email,
    required var price,
  }) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(
          Paths.usersPath)
          .where('phoneNumber', isEqualTo: phoneController.text,).get();

      for (var doc in querySnapshot.docs) {
        users.add(GroceryUser.fromMap(doc.data() as Map));
      }
      if (users.length > 0) {
        user = users[0];
        var dueDate = DateTime.now().add(Duration(minutes: 10));
        var expireDate = DateTime.now().add(Duration(days: 3));
        final uri = Uri.parse('https://api.tap.company/v2/invoices');
        final headers = {
          'Content-Type': 'application/json',
          'Authorization': "Bearer sk_live_UN9kc65zvtmrX1PjnagRYhLb",
          'Connection': 'keep-alive',
          'Accept-Encoding': 'gzip, deflate, br'
        };
        String description = "فاتورة حجز طلب";
       // if (user.countryCode != null && user.countryCode == "+966")
         // description = " السعر شامل ضريبة القيمة المضافة";
        Map<String, dynamic> body = {
          "draft": false,
          "due": dueDate.microsecondsSinceEpoch,
          "expiry": expireDate.microsecondsSinceEpoch,
          "description": "فاتورة حجز طلب",
          "mode": "INVOICE",
          "note": description,
          "notifications": {
            "channels": [
              "SMS",
              "EMAIL"
            ],
            "dispatch": true
          },
          "currencies": [
            "USD"
          ],
          "metadata": {
            "udf1": "1",
            "udf2": "2",
            "udf3": "3"
          },
          "charge": {
            "receipt": {
              "email": true,
              "sms": true
            },
            "statement_descriptor": description
          },
          "customer": {
            "email": "$email",
            "first_name": userName,
            "last_name": ".",
            "middle_name": ".",
            "phone": {
              "country_code": " ",
              "number": "$phone"
            }
          },
          "order": {
            "amount": price,
            "currency": "USD",
            "items": [
              {
                "amount": price,
                "currency": "USD",
                "description": "order ",
                "discount": {
                  "type": "P",
                  "value": 0
                },
                "image": "",
                "name": "order ",
                "quantity": 1
              }
            ],
            /*  "shipping": {
              "amount": 1,
              "currency": "USD",
              "description": "test",
              "provider": "ARAMEX",
              "service": "test"
            },
            "tax": [
              {
                "description": "test",
                "name": "VAT",
                "rate": {
                  "type": "F",
                  "value": 1
                }
              }
            ]*/
          },
          "payment_methods": [
            ""
          ],
          "post": {
            "url": "http://your_website.com/post_url"
          },
          "redirect": {
            "url": "http://your_website.com/redirect_url"
          },
          "reference": {
            "invoice": "INV_00001",
            "order": "ORD_00001"
          }
        };
        String jsonBody = json.encode(body);
        final encoding = Encoding.getByName('utf-8');
        var response = await http.post(
          uri,
          headers: headers,
          body: jsonBody,
          encoding: encoding,
        );
        String responseBody = response.body;
        var res = json.decode(responseBody);
        String url = res['url'];
        String invoiceId = Uuid().v4();
        await FirebaseFirestore.instance.collection(Paths.invoicePath).doc(
            invoiceId).set({
          'user': {
            'uid': user.uid,
            'name': userName,
            'image': user.photoUrl,
            'phone': phone,
            'countryCode': user.countryCode,
            'countryISOCode': user.countryISOCode,
          },
          'id': res['id'],
          'expiry': expireDate,
          'email': email,
          'price': priceController.text,
          'invoice': url,
          'timestamp': DateTime.now(),
          'platform':'Tap',
          "invoiceId": invoiceId,
        }).then((value) {
          Fluttertoast.showToast(
            msg: getTranslated(context, "invoiceCreatedDone"),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.green,
            textColor: AppColors.white,
            fontSize: 16.0,
          );
          Navigator.pop(context);
        }).catchError((error) {
          Fluttertoast.showToast(
            msg: getTranslated(context, "invoiceDataError"),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: AppColors.white,
            fontSize: 16.0,
          );
          setState(() {
            createInvoiceDone = false;
          });
        });
      }
      else {
        //flutter toast
        Fluttertoast.showToast(
          msg: getTranslated(context, "invoiceDataError"),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: AppColors.white,
          fontSize: 16.0,
        );
        setState(() {
          createInvoiceDone = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: getTranslated(context, "invoiceCreatedError"),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.red,
        textColor: AppColors.white,
        fontSize: 16.0,
      );
    }
  }

}
