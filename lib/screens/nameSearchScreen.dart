
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/supervisor/supervisorConsultScreen.dart';

import '../FireStorePagnation/paginate_firestore.dart';
import '../config/app_fonts.dart';
import '../config/assets_manager.dart';
import '../config/colorsFile.dart';
import '../methods/convert_pt_to_px.dart';
import '../widget/back_button.dart';

class NameSearchScreen extends StatefulWidget {
  final GroceryUser? loggedUser;

  const NameSearchScreen({Key? key, this.loggedUser}) : super(key: key);
  @override
  _NameSearchScreenState createState() => _NameSearchScreenState();
}

class _NameSearchScreenState extends State<NameSearchScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searchController = new TextEditingController();
  bool load=false;
  String theme="light";
  String name ="";
  late Query filterQuery;late Size size;
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
     size = MediaQuery.of(context).size;
    return Scaffold(backgroundColor: AppColors.white,
      key:_scaffoldKey,
      body: Column(
          children: <Widget>[
            Container(
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
                            getTranslated(context, "nameSearch"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: getTranslated(context, 'Ithra'),
                                fontSize: AppFontsSizeManager.s21.sp,
                                color: AppColors.pureBlack.withOpacity(0.8),
                                fontWeight: AppFontsWeightManager.bold),
                          ),
                        ],
                      ),
                    ))),
            Center(
                child: Container(
                    color: AppColors.lightGrey,
                    height: AppSize.h2.h,
                    width: size.width )),
            SizedBox(height: 25,),
            Center(child: Container(height: 50,width: size.width*.9,child:
              Container(

              padding: const EdgeInsets.symmetric( horizontal: 1.0, vertical: 0.0),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(10.0),

              ),
              child: TextField(
                onChanged: (val) => initiateSearch(val),
                keyboardType: TextInputType.text,
                controller: searchController,
                textInputAction: TextInputAction.search,
                enableInteractiveSelection: true,
                readOnly:false,
                style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                  fontSize: 14.5,
                  color: AppColors.black1,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).primaryColor,
                    size: 25.0,
                  ),
                  border: InputBorder.none,
                  hintText: getTranslated(context, "nameSearch"),
                  hintStyle: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                    fontSize: 14.5,
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            ),),
            SizedBox(height: 15,),
            name==""?Expanded(
              child: Center(
                  child: SizedBox()
              ),
            ):Expanded(
              child: PaginateFirestore(
                key: ValueKey(filterQuery),
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: AppPadding.p16, right: AppPadding.p16, bottom: AppPadding.p16, top: AppPadding.p16),//Change types accordingly
                itemBuilder: ( context, documentSnapshot,index) {
                  return  NameWidget( GroceryUser.fromMap(documentSnapshot[index].data() as Map),size );
                },
                separator:Center(
                    child: Container(
                        color: AppColors.lightGrey, height: 1, width: size.width * .9)),

                query:filterQuery,
                isLive: true,
              ),
            )


          ],
        ),
    );
  }

  void initiateSearch(String val) {
    setState(() {
      name = val.toLowerCase().trim();
      filterQuery=getTranslated(context, 'lang')=="ar"?FirebaseFirestore.instance.collection(Paths.usersPath)
          .where('consultName.searchIndexAr', arrayContains: name)
          .orderBy('name', descending: true):
          getTranslated(context, 'lang')=="en"?FirebaseFirestore.instance.collection(Paths.usersPath)
          .where('consultName.searchIndexEn', arrayContains: name)
          .orderBy('name', descending: true):
          getTranslated(context, 'lang')=="fr"?FirebaseFirestore.instance.collection(Paths.usersPath)
              .where('consultName.searchIndexFr', arrayContains: name)
              .orderBy('name', descending: true):
          FirebaseFirestore.instance.collection(Paths.usersPath)
              .where('consultName.searchIndexId', arrayContains: name)
              .orderBy('name', descending: true);
    });
  }
  Widget NameWidget(GroceryUser user,size){
    return InkWell(onTap: (){

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConsultSupervisorScreen(
            consultant: user, key: null, loggedUser:widget.loggedUser! ,
          ),
        ),
      );
    },
      child: Container(
        width: size.width,
        padding: const EdgeInsets.only( left: 5.0, right: AppPadding.p5, bottom: 10.0, top: AppPadding.p10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.white,width: 0),
                shape: BoxShape.circle,
                color: AppColors.white,
              ),
              child: user.photoUrl!.isEmpty ?Image.asset(AssetsManager.dream_icon_logo2,width: 50,height: 50,fit:BoxFit.fill,)
                  :ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: FadeInImage.assetNetwork(
                  placeholder:AssetsManager.loadImagePath,
                  placeholderScale: 0.5,
                  imageErrorBuilder:(context, error, stackTrace) => Image.asset(AssetsManager.dream_icon_logo2,width: 50,height: 50,fit:BoxFit.fill),
                  image: user.photoUrl!,
                  fit: BoxFit.cover,
                  fadeInDuration:
                  Duration(milliseconds: 250),
                  fadeInCurve: Curves.easeInOut,
                  fadeOutDuration:
                  Duration(milliseconds: 150),
                  fadeOutCurve: Curves.easeInOut,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: AppPadding.p5),
              child: Text(  getTranslated(context, "lang")=="ar"?user.consultName!.nameAr!:
              getTranslated(context, "lang")=="en"?user.consultName!.nameEn!:
              getTranslated(context, "lang")=="fr"?user.consultName!.nameFr!:
              user.consultName!.nameId!,
                style: TextStyle( fontFamily: getTranslated(context, "Ithra"),fontWeight: FontWeight.w100,
                  fontSize: 12,
                  color: AppColors.pureBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }
}
