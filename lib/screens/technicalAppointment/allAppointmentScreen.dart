

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/addFakeAppointment.dart';
import 'package:grocery_store/widget/techAppointmentWidget.dart';

import '../../FireStorePagnation/paginate_firestore.dart';


class AllAppointmentsScreen extends StatefulWidget {
  final GroceryUser loggedUser;
  const AllAppointmentsScreen({Key? key, required this.loggedUser,}) : super(key: key);
  @override
  _AllAppointmentsScreenState createState() => _AllAppointmentsScreenState();
}

class _AllAppointmentsScreenState extends State<AllAppointmentsScreen>with SingleTickerProviderStateMixin {
  bool load=false,today=true,all=false,filter=false;
  DateTime selectedFromDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();
  bool  showResult=false;
  late String from,to;
  late Query filterQuery;
  @override
  void initState() {
    super.initState();
   from="From";
   to="To";

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
                color:Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.only(right: AppPadding.p32.w, top: AppPadding.p35.h, bottom: AppPadding.p20.h),

                  child: Container(height: AppSize.h81,
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
                                  color: AppColors.white,
                                  size:AppSize.w24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          getTranslated(context, "appointments"),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddAppointmentScreen(), ),);
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
                              today=true;
                              all=false;
                              filter=false;
                              showResult=false;
                            });
                          },
                          child: Container(height: AppSize.h40,width: size.width*AppSize.w0_25,
                            padding: const EdgeInsets.all(AppPadding.p5),
                            decoration: BoxDecoration(
                              color: today?Theme.of(context).primaryColor:AppColors.white,
                              borderRadius: BorderRadius.circular(AppRadius.r20),
                            ),child:Center(
                              child: Text(
                                getTranslated(context, "today"),
                                textAlign: TextAlign.center,
                                style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                                  color: today?AppColors.white:Theme.of(context).primaryColor,
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
                              all=true;
                              today=false;
                              filter=false;
                              showResult=false;
                            });
                          },
                          child: Container(height: AppSize.h40,width: size.width*AppSize.w0_25,
                            padding: const EdgeInsets.all(AppPadding.p5),
                            decoration: BoxDecoration(
                              color: all?Theme.of(context).primaryColor:AppColors.white,
                              borderRadius: BorderRadius.circular(AppRadius.r50),
                            ),child:Center(
                              child: Text(
                                getTranslated(context, "all"),
                                textAlign: TextAlign.center,
                                style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                                  color: all?AppColors.white:Theme.of(context).primaryColor,
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
                              today=false;
                              all=false;
                              filter=true;
                              //showResult=true;
                            });
                          },
                          child: Container(height: AppSize.h40,width: size.width*AppSize.w0_25,
                            padding: const EdgeInsets.all(AppPadding.p5),
                            decoration: BoxDecoration(
                              color: filter?Theme.of(context).primaryColor:AppColors.white,
                              borderRadius: BorderRadius.circular(AppRadius.r20),
                            ),child:Center(
                              child: Text(
                                getTranslated(context, "filter"),
                                textAlign: TextAlign.center,
                                style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                                  color: filter?AppColors.white:Theme.of(context).primaryColor,
                                  fontSize: AppFontsSizeManager.s15.sp,
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
            today?Expanded(
              child: PaginateFirestore(
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: AppPadding.p16, right: AppPadding.p16, bottom: AppPadding.p16, top: AppPadding.p16),//Change types accordingly
                itemBuilder: ( context, documentSnapshot,index) {
                  return  TechAppointmentWiget(
                    appointment: AppAppointments.fromMap(documentSnapshot[index].data() as Map),
                    loggedUser:widget.loggedUser
                  );
                },
                query: FirebaseFirestore.instance.collection(Paths.appAppointments)
                    .where('date.month', isEqualTo:DateTime.now().month)
                    .where('date.day', isEqualTo:DateTime.now().day)
                    .where('date.year', isEqualTo:DateTime.now().year)
                    .orderBy('secondValue', descending: true),
                // to fetch real-time data
                isLive: true,
              ),
            ):SizedBox(),
            all?Expanded(
              child: PaginateFirestore(
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: AppPadding.p16, right: AppPadding.p16, bottom: AppPadding.p16, top: AppPadding.p16),//Change types accordingly
                itemBuilder: ( context, documentSnapshot,index) {
                  return  TechAppointmentWiget(
                    appointment: AppAppointments.fromMap(documentSnapshot[index].data() as Map),
                      loggedUser:widget.loggedUser
                  );
                },
                query: FirebaseFirestore.instance.collection(Paths.appAppointments)
                    .orderBy('secondValue', descending: true),
                // to fetch real-time data
                isLive: true,
              ),
            ):SizedBox(),
            filter?Column(children: [
              SizedBox(height: AppSize.h5,),
              Center(
                child: Text(
                  getTranslated(context, "filter"),
                  style: GoogleFonts.poppins(
                    color: AppColors.black1,
                    fontSize: AppFontsSizeManager.s18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: AppSize.h15,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    splashColor:
                    AppColors.white.withOpacity(0.5),
                    onTap: () {
                      _selectFromDate(context);
                    },
                    child: Container(height: AppSize.h40,width: size.width*.4,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.purple, //                   <--- border color
                          width: AppSize.w1,
                        ),
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.r20),
                      ),
                      child:Center(
                        child: Text(
                          from,
                          textAlign: TextAlign.center,
                          style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                            color:Colors.grey,
                            fontSize: AppFontsSizeManager.s13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSize.w5,),
                  InkWell(
                    splashColor:
                    AppColors.white.withOpacity(0.5),
                    onTap: () {
                      _selectToDate(context);
                    },
                    child: Container(height: AppSize.h40,width: size.width*.4,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.pink, //                   <--- border color
                          width: AppSize.w1,
                        ),
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.r20),
                      ),
                      child:Center(
                        child: Text(
                          to,
                          textAlign: TextAlign.center,
                          style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                            color:AppColors.grey,
                            fontSize: AppFontsSizeManager.s13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: AppSize.h25,
              ),
              Container(
                height: AppSize.h40,

                child:MaterialButton(
                  onPressed: () {
                    setState(() {
                      filterQuery=FirebaseFirestore.instance.collection(Paths.appAppointments)
                          .where('timeValue', isGreaterThanOrEqualTo:selectedFromDate.millisecondsSinceEpoch)
                          .where('timeValue', isLessThanOrEqualTo:selectedToDate.millisecondsSinceEpoch)
                          .orderBy('timeValue', descending: true);
                    });
                    showResult=true;
                  },
                  color:Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Text(
                    getTranslated(context, "results"),
                    style: GoogleFonts.poppins(
                      color: AppColors.white,
                      fontSize: AppFontsSizeManager.s15.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height:AppSize.h15,
              ),
            ],):SizedBox(),
            showResult?Expanded(
              child: PaginateFirestore(
                key: ValueKey(filterQuery),
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: AppPadding.p16, right: AppPadding.p16, bottom: AppPadding.p16, top: AppPadding.p16),//Change types accordingly
                itemBuilder: ( context, documentSnapshot,index) {
                  return  TechAppointmentWiget(
                    appointment: AppAppointments.fromMap(documentSnapshot[index].data() as Map),
                      loggedUser:widget.loggedUser
                  );
                },

                query:filterQuery,
                isLive: true,
              ),
            ):SizedBox(),
          ],
        ),

    );
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedFromDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedFromDate)
      setState(() {
        selectedFromDate = picked;
        from = selectedFromDate.toString().substring(0, 10);
      });
  }
  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedToDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedToDate)
      setState(() {
        selectedToDate = picked;
        to=selectedToDate.toString().substring(0,10);
      });
  }
}
