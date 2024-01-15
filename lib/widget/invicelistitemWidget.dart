// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/screens/invoice/userInvoiceDetailsScreen.dart';
import 'package:intl/intl.dart';

import '../models/InvoiceModel.dart';
class InvoiceListItem extends StatelessWidget {
  Invoice invoice;
  InvoiceListItem({required this.invoice });

  @override

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    DateFormat dateFormat = DateFormat('dd/MM/yy');
    return  Container(
          width: size.width,
          //height:size.height*.067,
          child:  Padding(
            padding: const EdgeInsets.all(AppPadding.p8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width:size.width*AppSize.w0_40,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${invoice.user!.name}',
                            maxLines: 1,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: AppFontsSizeManager.s13,
                                fontWeight: FontWeight.w600
                            )),
                        Text('${dateFormat.format(invoice.expire!.toDate())}',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: AppFontsSizeManager.s12
                        )),
                      ],
                    ),
                  ),
                  Container(
                    width: AppSize.w50,
                    height: AppSize.h30,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor,width: .5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text('${invoice.price}',
                          style:TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: AppFontsSizeManager.s13,
                              fontWeight: FontWeight.w600
                          )),
                    ),
                  ),
                  //SizedBox(width:30),
                  InkWell(
                    onTap: (){
                    //  getPromoDetails(userId: invoice.user.uid);
                      Navigator.push(context,MaterialPageRoute(
                          builder: (context)=>UserInvoiceItem(invoice:invoice,)));
                    },
                    child: Container(
                      width: AppSize.w30,
                      height: AppSize.w30,
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).primaryColor,width: 1),
                        color: Theme.of(context).primaryColor.withOpacity(.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                          child: Icon(Icons.arrow_forward_outlined,
                            color: Theme.of(context).primaryColor,
                            size: 20,
                          )
                      ),
                    ),
                  )

                ],
              ),
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor,width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
        );
  }
}



