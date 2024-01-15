

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:uuid/uuid.dart';

import '../../config/colorsFile.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/consultPackage.dart';
import '../component/textWidget.dart';

class ConsultPackagesWidget extends StatefulWidget {
final String consultId;

  ConsultPackagesWidget({required this.consultId});

  @override
  _ConsultPackagesWidgetState createState() => _ConsultPackagesWidgetState();
}

class _ConsultPackagesWidgetState extends State<ConsultPackagesWidget>
    with SingleTickerProviderStateMixin {
  String selectedType="chat";
  List<consultPackage> packages = [];
  final TextEditingController callNumController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  bool activeValue=false,load=false,saving=false;
  late consultPackage package;
  @override
  void initState() {
    super.initState();
    getConsultPackages();
  }
  @override
  void dispose() {
    super.dispose();

    priceController.dispose();
    discountController.dispose();
    callNumController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
     return Container(
       padding: const EdgeInsets.all(30),
       decoration: decoration(),
       child:Column(
         mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           TextWidget(text:getTranslated(context, "allPackages"),color: AppColors.warmPurple4,weight: AppFontsWeightManager.semiBold,size: AppSize.w12,
             align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
           SizedBox(
             height: AppSize.h20,
           ),
          packages.length == 0?
           Center(
             child: TextWidget(text:getTranslated(context, "noPackages"),color: AppColors.black4,weight: AppFontsWeightManager.semiBold,size: AppSize.w12,
               align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
           ):packageListWidget(size),

           SizedBox(height: AppSize.h20,),
           Center(
             child: IconButton(
               onPressed: () {
                 package = new consultPackage(Id: Uuid().v4(), consultUid: widget.consultId, type: 'chat',
                   price:0,discount:0,active: true,callNum:0,);
                 packageDialog(size, package);
               },
               icon: Icon(
                 Icons.add_circle,
                 size: AppSize.w40,
                 color:AppColors.pink
               ),
             ),
           ),
         ],
       ),
     );
  }
  packageListWidget(Size size){
    return ListView.separated(
    itemCount: packages.length,
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.all(0),
    itemBuilder: (context, index) {
      return InkWell(
        onTap: () {
          packageDialog(size, packages[index]);
        },
        child: Container(
            height: 50,
            width: size.width,
            padding: const EdgeInsets.only( left: AppPadding.p10, right: AppPadding.p10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.r15),
            ),
            child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(text:  packages[index].type=="voice"?
                  (packages[index].callNum .toString() + getTranslated( context, "call")):
                  (packages[index].callNum .toString() + getTranslated( context, "message")),
                  color: AppColors.black4,
                  weight: AppFontsWeightManager.bold500,size: AppSize.w12,
                  align: TextAlign.start,family: getTranslated(context, 'Ithra'),),

                TextWidget(text: packages[index].discount .toString() +" %",color: Colors.red,
                  weight: AppFontsWeightManager.bold500,size: AppSize.w12,
                  align: TextAlign.start,family: getTranslated(context, 'Ithra'),),

                TextWidget(text: packages[index].price.toString() +"\$",color: Color.fromRGBO( 123 ,108 ,150,1),
                  weight: AppFontsWeightManager.bold500,size: AppSize.w15,
                  align: TextAlign.start,family: getTranslated(context, 'Ithra'),),

              ],
            )),
      );
    },
    separatorBuilder:
        (BuildContext context, int index) {
      return SizedBox(
        height:AppSize.h20,
      );
    },
  );
  }
  packageDialog(Size size, consultPackage selectedPackage) {
    callNumController.text = selectedPackage.callNum.toString();
    priceController.text = selectedPackage.price.toString();
    discountController.text = selectedPackage.discount.toString();
    activeValue = selectedPackage.active;
    selectedType=selectedPackage.type;
    return showDialog(
      builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppRadius.r15),
            ),
          ),
          elevation: 5.0,
          contentPadding: const EdgeInsets.only(
              left: AppPadding.p16, right: AppPadding.p16, top: AppPadding.p20, bottom: AppPadding.p10),
          content: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      splashColor: AppColors.white.withOpacity(0.5),
                      onTap: () async {
                        await FirebaseFirestore.instance
                            .collection(Paths.packagesPath)
                            .doc(selectedPackage.Id)
                            .delete();
                        getConsultPackages();
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.delete,
                        color: AppColors.red,
                        size: AppSize.w24,
                      ),
                    ),
                    SizedBox(width: AppSize.w10,),
                    InkWell(
                      splashColor: AppColors.white.withOpacity(0.5),
                      onTap: () async {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        color: AppColors.pureBlack,
                        size: AppSize.w24,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: AppSize.h20,
                ),
                rowData(size,getTranslated(context, "call"),callNumController),
                SizedBox(
                  height: AppSize.h20,
                ),
                rowData(size,getTranslated(context, "discount"),discountController),

                SizedBox(
                  height: AppSize.h20,
                ),
                rowData(size,getTranslated(context, "price"),priceController),
                SizedBox(
                  height: AppSize.h20,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(text:getTranslated(context, "type"),color:AppColors.black4,
                      weight: AppFontsWeightManager.bold500,size: AppSize.w15,
                      align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
                    Container(
                        width: size.width * AppSize.w0_3,
                        height: 40,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppPadding.p10, vertical: AppPadding.p10),
                        decoration: BoxDecoration(
                          color: AppColors.pureBlack.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(AppRadius.r15),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedType,
                            items:
                            <String>['voice', 'chat'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: new Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedType = value!;
                              });

                            },
                          ),
                        )),
                  ],
                ),
                SizedBox(
                  height: AppSize.h20,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: activeValue,
                      onChanged: (value) {
                        setState(() {
                          activeValue = !activeValue;
                        });
                      },
                    ),
                    TextWidget(text: getTranslated(context, "active"),color: AppColors.black4,
                      weight: AppFontsWeightManager.bold500,size: AppSize.w15,
                      align: TextAlign.start,family: getTranslated(context, 'Ithra'),),

                  ],
                ),
                SizedBox(
                  height: AppSize.h15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      width:AppSize.w50,
                      child: MaterialButton(
                        padding: const EdgeInsets.all(0.0),
                        onPressed: () {
                          setState(() {
                            load = false;
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          getTranslated(context, 'cancel'),
                          style: GoogleFonts.cairo(
                            color: AppColors.black1,
                            fontSize: AppFontsSizeManager.s13_5,
                            fontWeight: FontWeight.w500,
                            letterSpacing:AppConstants.letterSpacing,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: AppSize.w10,
                    ),
                    saving
                        ? CircularProgressIndicator()
                        : Container(
                      width: AppSize.w50,
                      child: MaterialButton(
                        padding: const EdgeInsets.all(0.0),
                        onPressed: () async {
                          selectedPackage.type=selectedType;
                          savePackage(selectedPackage);},
                        child: Text(
                          getTranslated(context, 'save'),
                          style: GoogleFonts.cairo(
                            color: Colors.red.shade700,
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
          })),
      barrierDismissible: false,
      context: context,
    );
  }
  Widget rowData(Size size,String text,TextEditingController controller){
    return   Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget(text:text,color:AppColors.black4,
          weight: AppFontsWeightManager.bold500,size: AppFontsSizeManager.s15,
          align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
        Container(
          width: size.width * AppSize.w0_3,
          height: AppSize.h40,
          padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p10, vertical:AppPadding.p10),
          decoration: BoxDecoration(
            color: AppColors.pureBlack.withOpacity(0.03),
            borderRadius: BorderRadius.circular(AppRadius.r15),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            enableInteractiveSelection: true,
            style: GoogleFonts.cairo(
              fontSize: AppFontsSizeManager.s14,
              color: AppColors.black1,
              letterSpacing: AppConstants.letterSpacing,
              fontWeight: AppFontsWeightManager.bold500,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                  horizontal: AppPadding.p5, vertical: AppPadding.p8),
              border: InputBorder.none,
              hintText: text,
              hintStyle: GoogleFonts.cairo(
                fontSize: AppFontsSizeManager.s14,
                color: AppColors.black1,
                letterSpacing:AppConstants.letterSpacing,
                fontWeight: AppFontsWeightManager.regular,
              ),
              counterStyle: GoogleFonts.cairo(
                fontSize:AppFontsSizeManager.s12_5,
                color: AppColors.black1,
                letterSpacing:AppConstants.letterSpacing,
                fontWeight: AppFontsWeightManager.regular,
              ),
            ),
          ),
        ),
      ],
    );
  }
  BoxDecoration decoration(){
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.r31),
    );
  }
  Future<void> getConsultPackages() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.packagesPath)
          .where(
        'consultUid',
        isEqualTo: widget.consultId,
      )
          .orderBy("callNum", descending: false)
          .get();
      if (querySnapshot.docs.length > 0) {
        setState(() {
          packages = List<consultPackage>.from(
            querySnapshot.docs.map(
                  (snapshot) => consultPackage.fromMap(snapshot.data() as Map),
            ),
          );
        });
      } else
        setState(() {
          packages = [];
        });
    } catch (e) {

    }
  }
  savePackage(consultPackage selectedPackage) async {
    setState(() {
      saving = true;
    });
    await FirebaseFirestore.instance
        .collection(Paths.packagesPath)
        .doc(selectedPackage.Id)
        .set({
      'price': double.parse(  priceController.text.toString()),
      'discount': int.parse(discountController.text),
      'callNum': int.parse(callNumController.text),
      'consultUid': widget.consultId,
      'Id': selectedPackage.Id,
      'active': activeValue,
      'type':selectedPackage.type,
    }, SetOptions(merge: true));
    getConsultPackages();
    setState(() {
      saving = false;
    });
    Navigator.pop(context);
  }
}
