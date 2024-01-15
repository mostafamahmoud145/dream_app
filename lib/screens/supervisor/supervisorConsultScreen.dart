
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/constants.dart';

import '../../config/app_fonts.dart';
import '../../config/assets_manager.dart';
import '../../config/colorsFile.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../methods/convert_pt_to_px.dart';
import '../../models/SupportList.dart';
import '../../models/consultPackage.dart';
import '../../models/user.dart';
import '../../widget/back_button.dart';
import '../../widget/component/textWidget.dart';
import '../../widget/supervisorWidgets/consultPackageWidget.dart';
import '../myOrderScreen.dart';
import '../supportMessagesScreen.dart';
import '../techUserDetails/userAppointmentScreen.dart';
import 'edit_bio_screen.dart';

class ConsultSupervisorScreen extends StatefulWidget {
  final GroceryUser consultant;
  final GroceryUser loggedUser;

  const ConsultSupervisorScreen({ Key? key, required this.consultant, required this.loggedUser})
      : super(key: key);

  @override
  _ConsultSupervisorScreenState createState() =>
      _ConsultSupervisorScreenState();
}

class _ConsultSupervisorScreenState extends State<ConsultSupervisorScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late String languages = "",
      workDays = "",
      workDaysValue = "",
      from = "",
      to = "",
      lang = "",
      dropdownTypeValue;

  final TextEditingController displayController = TextEditingController();
  final TextEditingController videoController = TextEditingController();

  int localFrom = 0, localTo = 0;

  bool first = true,
      saving = false,
      load = false,
      loading = false,
      activeValue = false,
      activeUser = false,
      changeUser=false;
  late consultPackage package;
  bool avaliable = false, delete = false, chating = false;

  @override
  void initState() {
    super.initState();


    if (widget.consultant.fromUtc != null &&
        widget.consultant.workTimes!.length > 0) {
      localFrom = DateTime.parse(widget.consultant.fromUtc!).toLocal().hour;

      if (localFrom == 12)
        from = "12 PM";
      else if (localFrom == 0)
        from = "12 AM";
      else if (localFrom > 12)
        from = ((localFrom) - 12).toString() + " PM";
      else
        from = (localFrom).toString() + " AM";
    }
    if (widget.consultant.toUtc != null &&
        widget.consultant.workTimes!.length > 0) {
      localTo = DateTime.parse(widget.consultant.toUtc!).toLocal().hour;
      if (localTo == 12)
        to = "12 PM";
      else if (localTo == 0)
        to = "12 AM";
      else if (localTo > 12)
        to = ((localTo) - 12).toString() + " PM";
      else
        to = (localTo).toString() + " AM";
    }
    if (widget.consultant.accountStatus == "Active")
      setState(() {
        activeUser = true;
      });
    if (widget.consultant.order != null)
      displayController.text = widget.consultant.order.toString();
    else
      displayController.text = "0";

  }

  @override
  void didChangeDependencies() {
    if(first&&widget.consultant.workDays!.length>0) {
      workDays="";
      if(widget.consultant.workDays!.contains("1"))
      {
        workDays=workDays+getTranslated(context,"monday")+",";
      }
      if(widget.consultant.workDays!.contains("2"))
      {
        workDays=workDays+getTranslated(context,"tuesday")+",";
      }
      if(widget.consultant.workDays!.contains("3"))
      {
        workDays=workDays+getTranslated(context,"wednesday")+",";
      }
      if(widget.consultant.workDays!.contains("4"))
      {
        workDays=workDays+getTranslated(context,"thursday")+",";
      }
      if(widget.consultant.workDays!.contains("5"))
      {
        workDays=workDays+getTranslated(context,"friday")+",";
      }
      if(widget.consultant.workDays!.contains("6"))
      {
        workDays=workDays+getTranslated(context,"saturday")+",";
      }
      if(widget.consultant.workDays!.contains("7"))
      {
        workDays=workDays+getTranslated(context,"sunday")+",";
      }
      setState(() {
        workDaysValue="";
        workDaysValue=workDays;
        first=false;
      });
    }
    setState(() {
      //dropdownTypeValue = widget.consultant.consultType!;
    });
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    String dayNow = DateTime.now().weekday.toString();
    int timeNow = DateTime.now().hour;
    if (widget.consultant.workTimes!.contains(dayNow)) {
      if (localFrom <= timeNow && localTo > timeNow) {
        avaliable = true;
      }
    }
    lang = getTranslated(context, "lang");

    if (first && widget.consultant.workTimes!.length > 0) {
      workDays = "";
      if (widget.consultant.workTimes!.contains("1")) {
        workDays = workDays + getTranslated(context, "monday") + ",";
      }
      if (widget.consultant.workTimes!.contains("2")) {
        workDays = workDays + getTranslated(context, "tuesday") + ",";
      }
      if (widget.consultant.workTimes!.contains("3")) {
        workDays = workDays + getTranslated(context, "wednesday") + ",";
      }
      if (widget.consultant.workTimes!.contains("4")) {
        workDays = workDays + getTranslated(context, "thursday") + ",";
      }
      if (widget.consultant.workTimes!.contains("5")) {
        workDays = workDays + getTranslated(context, "friday") + ",";
      }
      if (widget.consultant.workTimes!.contains("6")) {
        workDays = workDays + getTranslated(context, "saturday") + ",";
      }
      if (widget.consultant.workTimes!.contains("7")) {
        workDays = workDays + getTranslated(context, "sunday") + ",";
      }
      setState(() {
        workDaysValue = "";
        workDaysValue = workDays;
        first = false;
      });
    }
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body:  Column(
        children: <Widget>[
          innerHeaderWidget(size),
          Container(
              color: AppColors.lightGrey,
              height: AppSize.h2.h,
              width: size.width ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  consultDataWidget(size),
                  SizedBox(height: 30,),
                  if(widget.consultant.userType==AppConstants.consultant)
                    consultBioWidget(size),
                  if(widget.consultant.userType==AppConstants.consultant)
                    SizedBox(height: 30,),
                  if(widget.consultant.userType==AppConstants.consultant)
                    consultTimeWidget(size),
                  if(widget.consultant.userType==AppConstants.consultant)
                    SizedBox(
                      height: 30,
                    ),
                  if(widget.consultant.userType==AppConstants.consultant)
                    ConsultPackagesWidget(consultId: widget.consultant.uid!,),
                  SizedBox(
                    height: 30,
                  ),
                  navigateRow("orders"),
                  SizedBox(
                    height: 20,
                  ),
                  navigateRow("appointments"),
                  SizedBox(
                    height: 20,
                  ),
                /*  navigateRow("paymentInfo"),
                  SizedBox(
                    height: 20,
                  ),
                  navigateRow("paymentHistory"),
                  SizedBox(
                    height: 20,
                  ),
                  navigateRow("Reviews"),*/
                  SizedBox(
                    height: 30,
                  ),
                  if(widget.consultant.userType==AppConstants.consultant)
                    consultSavingWidget(size),
                ],
              ),
            ),
          )
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Row(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [

                      chating
                          ? CircularProgressIndicator()
                          :IconButton(
                        onPressed: () async {
                          startChat();
                        },
                        icon: Icon(
                          Icons.message_outlined,
                          color: AppColors.pink,
                          size: 24.0,
                        ),
                      ),

                      SizedBox(width: 10),

                      (widget.loggedUser == null && widget.consultant.accountStatus == "NotActive")
                          ? delete
                          ? CircularProgressIndicator()
                          : IconButton(
                        onPressed: () async {
                          deleteUserDialog(size);
                        },
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 24.0,
                        ),
                      ):SizedBox(),
                    ],
                  ),

                ],
              ),
            )));
  }
  Widget  consultDataWidget(size){
    return  InkWell(
      onTap: () {
        Clipboard.setData( ClipboardData(text: widget.consultant.phoneNumber!));
        Fluttertoast.showToast(
            msg: "phone number coped ",
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.green,
            textColor: AppColors.white);
      },
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: decoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1,left: 2,right: 2),
              child: Stack(
                children: <Widget>[
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                    ),
                    child: widget.consultant.photoUrl!.isEmpty
                        ? Icon(
                      Icons.person,
                      color: Colors.grey[400],
                      size: 25.0,
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/applicationIcons/icon_person.png',
                        placeholderScale: 0.5,
                        imageErrorBuilder:
                            (context, error, stackTrace) => Icon(
                          Icons.person,
                          color: Colors.grey[400],
                          size: 25.0,
                        ),
                        image: widget.consultant.photoUrl!,
                        fit: BoxFit.cover,
                        fadeInDuration: Duration(milliseconds: 250),
                        fadeInCurve: Curves.easeInOut,
                        fadeOutDuration: Duration(milliseconds: 150),
                        fadeOutCurve: Curves.easeInOut,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 1,
                    top: 5.0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white,
                          width: 1.0,
                        ),
                        color: avaliable ? AppColors.green : Colors.red,
                      ),
                      width: 10.0,
                      height: 10.0,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextWidget(text: getTranslated(context, "lang")=="ar"?widget.consultant.consultName!.nameAr!:
                  getTranslated(context, "lang")=="en"?widget.consultant.consultName!.nameEn!:
                  getTranslated(context, "lang")=="fr"?widget.consultant.consultName!.nameFr!:
                  widget.consultant.consultName!.nameId!,
                    color: Color.fromRGBO( 32, 32 ,32,1),weight: FontWeight.w600,size: 15,
                    align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextWidget(text:widget.consultant.phoneNumber!,color: Color.fromRGBO( 147, 147 ,147,1),weight: FontWeight.w400,size: 10,
                        align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
                      SizedBox(width: 5,),
                      Image.asset(
                        'assets/applicationIcons/copy@3x.png',width: 10,height: 12,
                      ),

                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextWidget(text:  widget.consultant.ordersNumbers.toString(),color: Color.fromRGBO( 32, 32 ,32,1),
                            weight: FontWeight.w600,size: 10,
                            align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
                          SizedBox(width: 3,),
                          Image.asset(
                            'assets/applicationIcons/green_call.png',
                            width: 8,
                            height: 8,
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextWidget(text:widget.consultant.rating.toStringAsFixed(1),color: Color.fromRGBO( 32, 32 ,32,1),
                            weight: FontWeight.w600,size: 10,
                            align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
                          SizedBox(width: 3,),
                          Image.asset(
                            'assets/applicationIcons/Polygon 24.png',
                            width: 8,
                            height: 8,
                          ),
                        ],
                      ),


                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                TextWidget(text: widget.consultant.price! + "\$",color: Color.fromRGBO( 123 ,108, 150,1),
                  weight: FontWeight.w600,size: 13,
                  align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
                SizedBox(height: 20,),
               /* TextWidget(text:  widget.consultant.consultType! == null ? "..." : widget.consultant.consultType!,
                  color: Color.fromRGBO( 32 ,32, 32,1),
                  weight: FontWeight.w400,size: 11,
                  align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
*/

              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget  consultBioWidget(size){
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: decoration(),
      child:Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextWidget(text:getTranslated(context, "bio"),color: Color.fromRGBO( 158 ,58 ,130,1),weight: FontWeight.w600,size: 12,
            align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
          SizedBox(height: 10,),
          TextWidget(text:getTranslated(context, "lang")=="ar"?widget.consultant.consultBio!.bioAr!:
          getTranslated(context, "lang")=="en"?widget.consultant.consultBio!.bioEn!:
          getTranslated(context, "lang")=="fr"?widget.consultant.consultBio!.bioFr!:
          widget.consultant.consultBio!.bioId!,color: Color.fromRGBO( 32, 32 ,32,1),weight: FontWeight.w400,size: 12,
            align: TextAlign.start,family: getTranslated(context, 'Ithra'),lines: 5,),
          InkWell(onTap: (){  Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>EditBioScreen(user:widget.consultant),
            ),
          );},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextWidget(text:getTranslated(context, "readMore"),color: Color.fromRGBO( 230 ,188 ,89,1),
                  weight: FontWeight.w400,size: 12,
                  align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
                SizedBox(width: 5,),
                Image.asset(
                 getTranslated(context, "arrow2"),width: 24,height: 24,
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }
  Widget  consultTimeWidget (size){
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: decoration(),
      child:Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextWidget(text:getTranslated(context, "timeOfWork"),color: Color.fromRGBO( 158 ,58 ,130,1),weight: FontWeight.w600,size: 12,
            align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/applicationIcons/Iconly-Two-tone-Calendar-1.png',
                width: 12,
                height: 13,
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: TextWidget(text:workDaysValue,color: Color.fromRGBO( 32, 32 ,32,1),weight: FontWeight.w400,size: 12,
                  lines: 5,
                  align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
              ),

            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon( Icons.update,size:30,  color: Theme.of(context).primaryColor,),
              Image.asset(
                'assets/applicationIcons/Iconly-Two-tone-TimeCircle.png',
                width: 12,
                height: 12,
              ),
              SizedBox(
                width: 5,
              ),
              TextWidget(text:from+"  -  "+to,color: Color.fromRGBO( 32, 32 ,32,1),weight: FontWeight.w400,size: 12,
                align: TextAlign.start,family: getTranslated(context, 'Ithra'),),

            ],
          ),

        ],
      ),
    );
  }
  Widget  consultSavingWidget (size){
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: decoration(),
      child:Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextWidget(text: getTranslated(context, "active"),color: Color.fromRGBO( 32, 32 ,32,1),weight: FontWeight.w400,size: 15,
                align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
              Switch(
                value: activeUser,
                onChanged: (value) {
                  setState(() {
                    activeUser = value;
                  });
                },
                activeTrackColor: Colors.purple,
                activeColor: Colors.orangeAccent,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextWidget(text: getTranslated(context, "order"),color: Color.fromRGBO( 32, 32 ,32,1),weight: FontWeight.w400,size: 15,
                align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
              Container(
                width: size.width * .3,
                height: 40,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: AppColors.pureBlack.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: TextFormField(
                  controller: displayController,
                  keyboardType: TextInputType.number,
                  textCapitalization:
                  TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  enableInteractiveSelection: true,
                  style: GoogleFonts.cairo(
                    fontSize: 14.0,
                    color: AppColors.black1,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 8.0),
                    border: InputBorder.none,
                    hintText: getTranslated(context, "0"),
                    hintStyle: GoogleFonts.cairo(
                      fontSize: 14.0,
                      color: AppColors.black1,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w400,
                    ),
                    counterStyle: GoogleFonts.cairo(
                      fontSize: 12.5,
                      color: AppColors.black1,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextWidget(text: "convert to user",color: Color.fromRGBO( 32, 32 ,32,1),weight: FontWeight.w400,size: 15,
                align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
              Switch(
                value: changeUser,
                onChanged: (value) {
                  setState(() {
                    changeUser = value;
                  });
                },
                activeTrackColor: Colors.purple,
                activeColor: Colors.orangeAccent,
              ),
            ],
          ),
          SizedBox(height: 10,),
          Center(
            child: Container(
              width: size.width * .6,
              height: 45.0,
              child: MaterialButton(
                onPressed: () { saveConsult();},
                color: AppColors.pink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: Text(
                  getTranslated(context, "save"),
                  style: GoogleFonts.cairo(
                    color: AppColors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  BoxDecoration decoration(){
    return BoxDecoration(
      color: Color.fromRGBO(250, 250 ,250,1),
      borderRadius: BorderRadius.circular(31.0),
    );
  }
  saveConsult() async {
    String actUser = "NotActive";
    if (activeUser)
      actUser = "Active";
    await FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(widget.consultant.uid)
        .update({
      'accountStatus': actUser,
      'order': int.parse(displayController.text),
      'userType':  changeUser ? 'USER' : 'CONSULTANT'
    });
    Navigator.pop(context);
  }
  Widget navigateRow(String name){
    return   InkWell(onTap: ()
    {
      if(name=="orders")
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyOrdersScreen(user:widget.consultant,loggedType:widget.loggedUser.userType!,fromSupport: false, ), ),  );
      else if(name=="appointments")
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserAppointmentsScreen(user:widget.consultant,loggedUser: widget.loggedUser, ), ),  );

    /*  else if(name=="paymentInfo")
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => payInfoScreen(
                consult: widget.consultant),
          ),
        );
      else if(name=="paymentHistory")
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PaymentHistoryScreen(
                    user: widget.consultant),
          ),
        );
      else if(name=="Reviews")
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewScreens(
                user: widget.consultant,
                reviewLength: 1),
          ),
        );*/
    },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Color.fromRGBO(250, 250, 250,1),
          borderRadius: BorderRadius.circular(31.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextWidget(text:getTranslated(context,name),color: Color.fromRGBO( 32, 32 ,32,1),weight: FontWeight.w400,
                size: 12, align: TextAlign.start,family: getTranslated(context, 'Ithra'),),
              //Icon(Icons.arrow_forward_sharp, size: 20,color:Color.fromRGBO( 174, 156 ,206,1)),
              Image.asset(
                getTranslated(context, "arrow2"),width: 24,height: 24,
              ),

            ],
          ),
        ),
      ),
    );
  }
  startChat() async
  {
    setState(() {
      chating=true;
    });
    QuerySnapshot querySnapshot = await  FirebaseFirestore.instance.collection("SupportList")
        .where( 'userUid', isEqualTo: widget.consultant.uid, ).limit(1).get();
    if(querySnapshot!=null&&querySnapshot.docs.length!=0)
    {
      var item=SupportList.fromMap(querySnapshot.docs[0].data() as Map);
      setState(() {
        load=false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SupportMessageScreen(
              item: item,
              user:widget.loggedUser), ),);
      setState(() {
        chating=false;
      });

    }
    else
    {
      setState(() {
        chating=false;
      });
    }
  }

  deleteUserDialog(Size size) {
    return showDialog(
      builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
          ),
          elevation: 5.0,
          contentPadding: const EdgeInsets.only(
              left: AppPadding.p16, right: AppPadding.p16, top: 20.0, bottom: 10.0),
          content: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getTranslated(context, "deleteAccount"),
                      style: GoogleFonts.cairo(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        color: AppColors.black1,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: AppPadding.p10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          delete = true;
                          await FirebaseFirestore.instance
                              .collection(Paths.usersPath)
                              .doc(widget.consultant.uid)
                              .delete();
                          await FirebaseFirestore.instance
                              .collection(Paths.appAnalysisPath)
                              .doc("TgWCp3B22sbkl0Nm3wLx")
                              .set({
                            'allUsers': FieldValue.increment(-1),
                            'notActiveConsult': FieldValue.increment(-1),
                          }, SetOptions(merge: true));
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              getTranslated(context, "yes"),
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                color: Colors.lightBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 100),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              getTranslated(context, "no"),
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                color: Colors.lightBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 5, right: AppPadding.p5, top: 5, bottom: 10),
                  child: Container(
                    width: size.width,
                    height: 0.5,
                    color: AppColors.lightGrey1,
                  ),
                ),
              ],
            );
          })),
      barrierDismissible: false,
      context: context,
    );
  }
}
