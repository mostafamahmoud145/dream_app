

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/DevelopTechSupport.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/developListItem.dart';
import 'package:uuid/uuid.dart';

import '../../FireStorePagnation/paginate_firestore.dart';


class AllDevelopTechScreen extends StatefulWidget {
  final GroceryUser loggedUser;

  const AllDevelopTechScreen({Key? key, required this.loggedUser}) : super(key: key);
  @override
  _AllDevelopTechScreenState createState() => _AllDevelopTechScreenState();
}

class _AllDevelopTechScreenState extends State<AllDevelopTechScreen>with SingleTickerProviderStateMixin {
  bool load=false,_new=true,_open=false,_done=false,_closed=false,saving=false,showText=false;
  final TextEditingController titleController = new TextEditingController();
  
  @override
  void initState() {
    super.initState();


  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(backgroundColor: AppColors.white,
      body: Column(
        children: <Widget>[
          Container(
            width: size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0.0),
                bottomRight: Radius.circular(0.0),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(right: AppPadding.p32.w, top: AppPadding.p35.h, bottom: AppPadding.p20.h),

                child: Container(height: 80,
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
                              height: AppSize.w35,
                              child: Icon(
                                Icons.arrow_back,
                                color: AppColors.white,
                                size: AppSize.w24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        getTranslated(context, "development"),
                        style: GoogleFonts.poppins(
                          color:AppColors.white,
                          fontSize: AppFontsSizeManager.s19.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.r50),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: AppColors.white.withOpacity(0.5),
                            onTap: () {
                              addDialog(size);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              width: AppSize.w38,
                              height: AppSize.h35,
                              child: Icon(
                                Icons.add_circle_outline,
                                color:AppColors.white,
                                size: AppSize.w24,
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSize.h1,),
          Center(
            child:  Container(height: AppSize.h60,width: size.width,
                padding: const EdgeInsets.all(AppPadding.p10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(1.0),
                  boxShadow: [
                    AppShadow.primaryShadow
                  ],
                ),
                child:Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        splashColor: Colors.green.withOpacity(0.5),
                        onTap: () {
                          setState(() {
                            _new=true;
                            _open=false;
                            _done=false;
                            _closed=false;
                          });
                        },
                        child: Container(height: AppSize.h40,width: size.width*AppSize.w0_20,
                          padding: const EdgeInsets.all(AppPadding.p5),
                          decoration: BoxDecoration(
                            color: _new?AppColors.pink:AppColors.white,
                            borderRadius: BorderRadius.circular(AppRadius.r50),
                          ),child:Center(
                            child: Text(
                              "New",
                              textAlign: TextAlign.center,
                              style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                                color: _new?AppColors.white:Theme.of(context).primaryColor,
                                fontSize: AppFontsSizeManager.s15.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),),
                      ),
                      SizedBox(width: AppSize.w5,),
                      InkWell(
                        splashColor: Colors.green.withOpacity(0.5),
                        onTap: () {
                          setState(() {
                            _new=false;
                            _open=true;
                            _done=false;
                            _closed=false;
                          });
                        },
                        child: Container(height: AppSize.h40,width: size.width*AppSize.w0_20,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: _open?Theme.of(context).primaryColor:AppColors.white,
                            borderRadius: BorderRadius.circular(AppRadius.r20),
                          ),child:Center(
                            child: Text(
                              "Open",
                              textAlign: TextAlign.center,
                              style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                                color: _open?AppColors.white:Theme.of(context).primaryColor,
                                fontSize: AppFontsSizeManager.s15.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),),
                      ),
                      SizedBox(width: AppSize.w5,),
                      InkWell(
                        splashColor: Colors.green.withOpacity(0.5),
                        onTap: () {
                          setState(() {
                            _new=false;
                            _open=false;
                            _done=true;
                            _closed=false;
                          });
                        },
                        child: Container(height: AppSize.h40,width: size.width*AppSize.w0_20,
                          padding: const EdgeInsets.all(AppPadding.p5),
                          decoration: BoxDecoration(
                            color: _done?Theme.of(context).primaryColor:AppColors.white,
                            borderRadius: BorderRadius.circular(AppRadius.r20),
                          ),child:Center(
                            child: Text(
                            "Done",
                              textAlign: TextAlign.center,
                              style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                                color: _done?AppColors.white:Theme.of(context).primaryColor,
                                fontSize: 15.0.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),),
                      ),
                      SizedBox(width: 5,),
                      InkWell(
                        splashColor: Colors.green.withOpacity(0.5),
                        onTap: () {
                          setState(() {
                            _new=false;
                            _open=false;
                            _done=false;
                            _closed=true;
                          });
                        },
                        child: Container(height: AppSize.h40,width: size.width*AppSize.w0_20,
                          padding: const EdgeInsets.all(AppPadding.p5),
                          decoration: BoxDecoration(
                            color: _closed?Theme.of(context).primaryColor:AppColors.white,
                            borderRadius: BorderRadius.circular(AppRadius.r20),
                          ),child:Center(
                            child: Text(
                             "Closed",
                              textAlign: TextAlign.center,
                              style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                                color: _closed?AppColors.white:Theme.of(context).primaryColor,
                                fontSize:AppFontsSizeManager.s15.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),),
                      ),
                    ])
            ),
          ),
          SizedBox(height: AppSize.h10,),
          _new?Expanded(
            child: PaginateFirestore(
              itemBuilderType: PaginateBuilderType.listView,
              padding: const EdgeInsets.only(
                  left: AppPadding.p16, right: AppPadding.p16, bottom: AppPadding.p16, top: AppPadding.p16),//Change types accordingly
              itemBuilder: ( context, documentSnapshot,index) {
                return  DevelopListItem(
                    size:size,
                    item: DevelopTechSupport.fromMap(documentSnapshot[index].data() as Map),
                    user:widget.loggedUser
                );
              },
              query: FirebaseFirestore.instance.collection(Paths.developTechSupportPath)
                  .where('status', isEqualTo:"new")
                  .orderBy('sendTime', descending: true),
              // to fetch real-time data
              isLive: true,
            ),
          ):SizedBox(),
          _open?Expanded(
            child: PaginateFirestore(
              itemBuilderType: PaginateBuilderType.listView,
              padding: const EdgeInsets.only(
                  left: AppPadding.p16, right: AppPadding.p16, bottom: AppPadding.p16, top: AppPadding.p16),//Change types accordingly
              itemBuilder: ( context, documentSnapshot,index) {
                return  DevelopListItem(
                    size:size,
                    item: DevelopTechSupport.fromMap(documentSnapshot[index].data() as Map),
                    user:widget.loggedUser
                );
              },
              query: FirebaseFirestore.instance.collection(Paths.developTechSupportPath)
                  .where('status', isEqualTo:"open")
                  .orderBy('sendTime', descending: true),
              // to fetch real-time data
              isLive: true,
            ),
          ):SizedBox(),
          _done?Expanded(
            child: PaginateFirestore(
              itemBuilderType: PaginateBuilderType.listView,
              padding: const EdgeInsets.only(
                  left: AppPadding.p16, right: AppPadding.p16, bottom: AppPadding.p16, top: AppPadding.p16),//Change types accordingly
              itemBuilder: ( context, documentSnapshot,index) {
                return  DevelopListItem(
                    size:size,
                    item: DevelopTechSupport.fromMap(documentSnapshot[index].data() as Map),
                    user:widget.loggedUser
                );
              },
              query: FirebaseFirestore.instance.collection(Paths.developTechSupportPath)
                  .where('status', isEqualTo:"done")
                  .orderBy('sendTime', descending: true),
              // to fetch real-time data
              isLive: true,
            ),
          ):SizedBox(),
          _closed?Expanded(
            child: PaginateFirestore(
              itemBuilderType: PaginateBuilderType.listView,
              padding: const EdgeInsets.only(
                  left: AppPadding.p16, right: AppPadding.p16, bottom: AppPadding.p16, top: AppPadding.p16),//Change types accordingly
              itemBuilder: ( context, documentSnapshot,index) {
                return  DevelopListItem(
                    size:size,
                    item: DevelopTechSupport.fromMap(documentSnapshot[index].data() as Map),
                    user:widget.loggedUser
                );
              },
              query: FirebaseFirestore.instance.collection(Paths.developTechSupportPath)
                  .where('status', isEqualTo:"closed")
                  .orderBy('sendTime', descending: true),
              // to fetch real-time data
              isLive: true,
            ),
          ):SizedBox(),
        ],
      ),

    );
  }

  addDialog(Size size) {

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
          content:StatefulBuilder(builder: (context, setState) {
            return
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[

                  SizedBox(
                    height: AppSize.h15,
                  ),
                  Text(
                    getTranslated(context, "developNotes"),
                    style: GoogleFonts.poppins(
                      color: AppColors.pureBlack,
                      fontSize: AppFontsSizeManager.s13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h15,
                  ),
                  Container(width: size.width * AppSize.w0_6,
                    height: AppSize.h55,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppPadding.p10, vertical:AppPadding.p10),
                    decoration: BoxDecoration(
                      color: AppColors.pureBlack.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(AppRadius.r15),
                    ),
                    child: TextFormField(
                      controller: titleController,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      enableInteractiveSelection: false,
                      style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                        fontSize: AppFontsSizeManager.s14.sp,
                        color: AppColors.black1,
                        letterSpacing: AppConstants.letterSpacing,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                        border: InputBorder.none,
                        hintText: getTranslated(context, "title"),
                        hintStyle: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                          fontSize: AppFontsSizeManager.s14.sp,
                          color: AppColors.black1,
                          letterSpacing: AppConstants.letterSpacing,
                          fontWeight: FontWeight.w400,
                        ),
                        counterStyle: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                          fontSize: AppFontsSizeManager.s12_5.sp,
                          color: AppColors.black1,
                          letterSpacing: AppConstants.letterSpacing,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),

                  showText?Text(
                    getTranslated(context, "required"),
                    style: GoogleFonts.poppins(
                      color: AppColors.red,
                      fontSize: AppFontsSizeManager.s13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ):SizedBox(),
                  SizedBox(height: AppSize.h10,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        width: AppSize.w50,
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
                            style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                              color: AppColors.black1,
                              fontSize: AppFontsSizeManager.s13.sp,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSize.w10,),
                      saving ? CircularProgressIndicator() : Container(
                        width: AppSize.w50,
                        child: MaterialButton(
                          padding: const EdgeInsets.all(0.0),
                          onPressed: () async {
                            if(titleController.text==null||titleController.text=="")
                              setState(() {
                                showText = true;
                              });
                            else
                              {
                                setState(() {
                                  showText=false;
                                  saving = true;
                                });
                                String developListId=Uuid().v4();
                                await FirebaseFirestore.instance.collection(Paths.developTechSupportPath).doc(developListId).set({
                                  'developTechSupportId': developListId,
                                  'status': "new",
                                  'sendTime': FieldValue.serverTimestamp(),
                                  'owner': widget.loggedUser.userType,
                                  'userUid': widget.loggedUser.uid,
                                  'userName':widget.loggedUser.name,
                                  'title': titleController.text,
                                });
                                setState(() {
                                  saving = false;
                                });
                                Navigator.pop(context);
                              }

                          },
                          child: Text(
                            getTranslated(context, 'save'),
                            style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                              color: Colors.red.shade700,
                              fontSize: AppFontsSizeManager.s13_5.sp,
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
          })
      ), barrierDismissible: false,
      context: context,
    );
  }

}
