

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/constants.dart';

import '../../config/colorsFile.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../methods/convert_pt_to_px.dart';
import '../../models/user.dart';
import '../../widget/back_button.dart';
import '../../widget/component/TextFormFieldWidget.dart';

class EditBioScreen extends StatefulWidget {
  final GroceryUser user;

  EditBioScreen({required this.user});

  @override
  State<EditBioScreen> createState() => _EditBioScreenState();
}

class _EditBioScreenState extends State<EditBioScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Size size;



  bool isAdding = false;

  TextEditingController nameArController = TextEditingController();
  TextEditingController nameEnController = TextEditingController();
  TextEditingController nameFrController = TextEditingController();
  TextEditingController nameIdController = TextEditingController();

  TextEditingController bioArController = TextEditingController();
  TextEditingController bioEnController = TextEditingController();
  TextEditingController bioFrController = TextEditingController();
  TextEditingController bioIdController = TextEditingController();


  @override
  void initState() {
    super.initState();

    nameArController.text=widget.user.consultName!.nameAr!;
    nameEnController.text=widget.user.consultName!.nameEn!;
    nameFrController.text=widget.user.consultName!.nameFr!;
    nameIdController.text=widget.user.consultName!.nameId!;

    bioArController.text=widget.user.consultBio!.bioAr!;
    bioEnController.text=widget.user.consultBio!.bioEn!;
    bioFrController.text=widget.user.consultBio!.bioFr!;
    bioIdController.text=widget.user.consultBio!.bioId!;
  }



  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          innerHeaderWidget(size),
        Container(
        color: AppColors.lightGrey,
            height: AppSize.h2.h,
        width: size.width ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppPadding.p20),
              children: [
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(AppPadding.p10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[


                        TextFormFieldWidget(name: getTranslated(context, "nameAr"),controller: nameArController,context: context, onTap:(){}, ),
                        SizedBox(height: AppSize.h40),
                        TextFormFieldWidget(name: getTranslated(context, "nameEn"),controller: nameEnController,context: context, onTap:(){}, ),
                        SizedBox(height: AppSize.h40),
                        TextFormFieldWidget(name: getTranslated(context, "nameFr"),controller: nameFrController,context: context, onTap:(){}, ),
                        SizedBox(height: AppSize.h40),
                        TextFormFieldWidget(name: getTranslated(context, "nameId"),controller: nameIdController,context: context, onTap:(){}, ),
                        SizedBox(height: AppSize.h40),
                        SizedBox(height: AppSize.h40),
                        TextFormFieldWidget(name: getTranslated(context, "bioAr"),controller: bioArController,context: context, onTap:(){}, lines: 5,),
                        SizedBox(height: AppSize.h40),
                        TextFormFieldWidget(name: getTranslated(context, "bioEn"),controller: bioEnController,context: context, onTap:(){}, lines: 5,),
                        SizedBox(height: AppSize.h40),
                        TextFormFieldWidget(name: getTranslated(context, "bioFr"),controller: bioFrController,context: context, onTap:(){}, lines: 5,),
                        SizedBox(height: AppSize.h40),
                        TextFormFieldWidget(name: getTranslated(context, "bioId"),controller: bioIdController,context: context, onTap:(){}, lines: 5,),
                        SizedBox(height: AppSize.h40),

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          isAdding
              ? Center(child: CircularProgressIndicator())
              : Center(
                  child: InkWell(
                    onTap: () async {
                      await save();
                    },
                    child: Container(
                      width: size.width * AppSize.w0_6,
                      height: AppSize.h45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.r10_6),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.linear1,
                              AppColors.linear2,
                              AppColors.linear2,
                            ],
                          )),
                      child: Center(
                        child: Text(
                          getTranslated(context, "save"),
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            color: AppColors.white,
                            fontSize: AppFontsSizeManager.s18.sp,
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          SizedBox(
            height: AppSize.h15,
          ),
        ],
      ),
    );
  }
  Widget innerHeaderWidget(Size size){
    return   Container(
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
                    getTranslated(context, "details"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithra'),
                        fontSize: AppFontsSizeManager.s21.sp,
                        color: AppColors.pureBlack.withOpacity(0.8),
                        fontWeight: AppFontsWeightManager.bold),
                  ),
                ],
              ),
            )));
  }
  save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isAdding = true;
      });

      if (widget.user.uid != null) {
        //names
        List<String>indexListAr=[],indexListEn=[],indexListFr=[],indexListIn=[];
        for(int y=1;y<=nameArController.text.trimLeft().trimRight().replaceAll('.','').length;y++)
          indexListAr.add(nameArController.text.trimLeft().trimRight().replaceAll('.','').substring(0,y).toLowerCase());

        for(int y=1;y<=nameEnController.text.trimLeft().trimRight().replaceAll('.','').length;y++)
          indexListEn.add(nameEnController.text.trimLeft().trimRight().replaceAll('.','').substring(0,y).toLowerCase());

        for(int y=1;y<=nameFrController.text.trimLeft().trimRight().replaceAll('.','').length;y++)
          indexListFr.add(nameFrController.text.trimLeft().trimRight().replaceAll('.','').substring(0,y).toLowerCase());

        for(int y=1;y<=nameIdController.text.trimLeft().trimRight().replaceAll('.','').length;y++)
          indexListIn.add(nameIdController.text.trimLeft().trimRight().replaceAll('.','').substring(0,y).toLowerCase());
        widget.user.consultName=ConsultName(
          nameAr: nameArController.text,
          nameEn: nameEnController.text,
          nameFr: nameFrController.text,
          nameId:nameIdController.text,
          searchIndexAr: indexListAr,
          searchIndexEn:  indexListEn,
          searchIndexFr: indexListFr,
          searchIndexId: indexListIn,
        );
        widget.user.consultBio=ConsultBio(
          bioAr: bioArController.text,
          bioEn: bioEnController.text,
          bioFr: bioFrController.text,
          bioId:bioIdController.text,
        );
        await FirebaseFirestore.instance
            .collection(Paths.usersPath)
            .doc(widget.user.uid)
            .set({
          "consultName": {
            'nameAr': nameArController.text,
            'nameEn': nameEnController.text,
            'nameFr': nameFrController.text,
            'nameId':nameIdController.text,
            'searchIndexAr': indexListAr,
            'searchIndexEn':  indexListEn,
            'searchIndexFr': indexListFr,
            'searchIndexId': indexListIn,
          },
          "consultBio":{
            'bioAr': bioArController.text,
            'bioEn': bioEnController.text,
            'bioFr': bioFrController.text,
            'bioId':bioIdController.text,
          }
        }, SetOptions(merge: true));

      }
      setState(() {
        isAdding = false;
      });
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
          msg: "Please fill all the details!",
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.green,
          textColor: AppColors.white);
    }
  }




}
