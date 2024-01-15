
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:uuid/uuid.dart';

import '../../FireStorePagnation/paginate_firestore.dart';
import '../../blocs/account_bloc/account_bloc.dart';
import '../../config/paths.dart';
import '../../localization/language_constants.dart';
import '../../localization/localization_methods.dart';
import '../../models/DevelopTechSupport.dart';
import '../../models/developMessage.dart';
import '../../models/user.dart';
import '../../widget/audioRocordingWidget.dart';
import '../../widget/developItem.dart';
import '../../widget/processing_dialog.dart';
var image;
File? selectedProfileImage;
typedef _Fn = void Function();
class DevelopMessageScreen extends StatefulWidget {
  final DevelopTechSupport develop ;
  final GroceryUser user;

  const DevelopMessageScreen({required this.develop, required this.user});

  @override
  _DevelopMessageScreenState createState() => _DevelopMessageScreenState();
}

class _DevelopMessageScreenState extends State<DevelopMessageScreen> {
  bool loading=false;
  late bool isShowSticker,answered=false,loadStatus=false;
  late String imageUrl;
  var stCollection = 'messages',theme;
  String text = "";
  late Size size;
  late AccountBloc accountBloc;
  final TextEditingController textEditingController =
  new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  String? dropdownTypeValue;
  final FocusNode focusNode = new FocusNode();
  bool recording = false,uploadingRecord=false;
  late String recordFilePath;int i=0;
  List<KeyValueModel> _typeArray = [
    KeyValueModel(key: "new", value: "New"),
    KeyValueModel(key: "open", value: "Open"),
    KeyValueModel(key: "done", value: "Done"),
    KeyValueModel(key: "closed", value: "Closed"),
  ];
  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    accountBloc = BlocProvider.of<AccountBloc>(context);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
  @override
  void didChangeDependencies() {
    getThemeName().then((theme) {
      setState(() {
        this.theme = theme;
      });
    });
    super.didChangeDependencies();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      if(mounted){
        setState(() {
          isShowSticker = false;
        });
      }

    }
  }
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
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
                padding: const EdgeInsets.only(
                    left: AppPadding.p16, right: AppPadding.p16, top: 0.0, bottom: AppPadding.p16),
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
                          splashColor: AppColors.white.withOpacity(0.6),
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
                              color: theme=="light"?AppColors.white:AppColors.pureBlack,
                              size: AppSize.w24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: AppSize.w8,
                    ),
                    Expanded(
                      child: Text(
                        widget.develop.userName,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 1,
                        style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                          color: theme=="light"?AppColors.white:AppColors.pureBlack,
                          fontSize: AppFontsSizeManager.s18.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppPadding.p20),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
              Text(
                getTranslated(context, "selectStatus"),
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 1,
                style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                  color:AppColors.pureBlack,
                  fontSize: AppFontsSizeManager.s18.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                  height: AppSize.h40,width: size.width*AppSize.w0_5,
                  decoration: BoxDecoration(
                      color: theme=="light"?AppColors.white:Colors.transparent,
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius:
                      BorderRadius.all(Radius.circular(AppRadius.r10_6))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p10, right: AppPadding.p10),
                    child: DropdownButton<String>(
                      hint: Text(
                        getTranslated(context, "selectStatus"),
                        textAlign: TextAlign.center,
                        style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                          //color: AppColors.pureBlack,
                          fontSize: AppFontsSizeManager.s15.sp,
                          letterSpacing:AppConstants.letterSpacing,
                        ),
                      ),
                      underline: Container(),
                      isExpanded: true,
                      value: dropdownTypeValue,
                      icon: Icon(Icons.keyboard_arrow_down,
                          color: AppColors.pureBlack),
                      iconSize: AppSize.w24,
                      elevation: 16,
                      style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.blue,
                        fontSize: AppFontsSizeManager.s13.sp,
                        letterSpacing: AppConstants.letterSpacing,
                      ),
                      items: _typeArray
                          .map((data) => DropdownMenuItem<String>(
                          child: Text(
                            data.value.toString(),
                            style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
                              color: AppColors.pureBlack,
                              fontSize:AppFontsSizeManager.s15.sp,
                              letterSpacing:AppConstants.letterSpacing,
                            ),
                          ),
                          value: data.key.toString() //data.key,
                      ))
                          .toList(),
                      onChanged: (String? value) {
                        setState(() {
                          dropdownTypeValue = value!;

                        });
                      },
                    ),
                  )),
            ],),
          ),
          loadStatus
              ? Center(child: CircularProgressIndicator())
              : Container(
            height: AppSize.h45,
            width: size.width*AppSize.w0_5,
            padding:
            const EdgeInsets.symmetric(horizontal: 0.0),
            child: MaterialButton(
              onPressed: () {
                //add notificationMap
                changeStatus(dropdownTypeValue!);
              },
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.r15),
              ),
              child: Text(
                getTranslated(
                    context, "save"),
                style: GoogleFonts.poppins(
                  color: theme=="light"?AppColors.white:AppColors.pureBlack,
                  fontSize: AppFontsSizeManager.s15.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          Expanded(
            child: PaginateFirestore(
              scrollController: listScrollController,
              reverse: true,
              itemBuilderType: PaginateBuilderType.listView,
              padding: const EdgeInsets.only(
                  left: AppPadding.p16, right: AppPadding.p16, bottom: AppPadding.p16, top: AppPadding.p16),//Change types accordingly
              itemBuilder: ( context, documentSnapshot,index) {
                return  DevelopItem(
                    message: DevelopMessage.fromMap(documentSnapshot[index].data() as Map),
                    user:widget.user
                );

              },
              query: FirebaseFirestore.instance.collection(Paths.dvelopChat)
                  .where('developTechSupportId', isEqualTo: widget.develop.developTechSupportId)
                  .orderBy('messageTime', descending: true),
              isLive: true,
            ),
          ),
          buildInput(size),
        ],
      ),
    );
  }
  Widget buildInput(Size size) {
    return Container(
      child: Row(
        children: <Widget>[
          // image Button
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: AppPadding.p1),
              child: new IconButton(
                icon: new Icon(Icons.image),
                onPressed: () =>cropImage(context),
                color: theme=="light"?Theme.of(context).primaryColor:AppColors.pureBlack,
              ),
            ),
            color: AppColors.white,
          ),
          //record button
          AudioRecorder(
              onSendMessage: onSendMessage,
              focusNode: focusNode,
              loggedId:widget.user.uid.toString()
          ),

          // Edit text
          Flexible(
            child: Container(
              child:TextField( enableInteractiveSelection: true,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                    color: theme=="light"?Theme.of(context).primaryColor:AppColors.pureBlack, fontSize: 15.0.sp),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: getTranslated(context, "typeMessage"),
                  hintStyle: TextStyle(fontFamily: getTranslated(context, "Ithra"),color: Colors.grey),
                ),
                focusNode: focusNode,
                onChanged: (str){
                  setState(() {
                    text = str;
                  });
                },
              ),
            ),
          ),
          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: AppPadding.p8),
              child: loading?Center(child: CircularProgressIndicator()): Container(
                height: AppSize.h30,
                width: AppSize.w30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme=="light"?Theme.of(context).primaryColor:AppColors.pureBlack,
                ),
                child: Center(
                  child: new IconButton(
                    icon: new Icon(Icons.send,color:AppColors.white,size: 15,),
                    onPressed: () => onSendMessage(textEditingController.text, "text",size),
                    color: theme=="light"?Theme.of(context).primaryColor:AppColors.pureBlack,
                  ),
                ),
              ),
            ),
            color: AppColors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: AppSize.h50,
      decoration: new BoxDecoration(
          border:
          new Border(top: new BorderSide(color: Colors.grey, width: 0.5)),
          color: AppColors.white),
    );
  }
  Future<void> changeStatus(String status) async {
    //update appointment
    await FirebaseFirestore.instance.collection(Paths.developTechSupportPath).doc(widget.develop.developTechSupportId).set({
      'status': status,
    }, SetOptions(merge: true));

    Navigator.pop(context);
  }

  Future<void> onSendMessage(String content, String type,Size size) async {
    if (content.trim() != '') {
      textEditingController.clear();
      String messageId=Uuid().v4();
      String data=getTranslated(context, "attatchment");
      if(type=="text")
        data=content;
      await FirebaseFirestore.instance.collection(Paths.dvelopChat).doc(messageId).set({
        'type': type,
        'owner': widget.user.userType,
        'message': content,
        'messageTime': FieldValue.serverTimestamp(),
        'messageTimeUtc':DateTime.now().toUtc().toString(),
        'ownerName': widget.user.name,
        'userUid': widget.user.uid,
        'developTechSupportId': widget.develop.developTechSupportId,

      });


      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: AppConstants.milliseconds300), curve: Curves.easeOut);
      setState(() {
        loading = false;
      });
      if(type=="voice")
      {
        setState(() {
          uploadingRecord=false;
        });
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DevelopMessageScreen(
              develop: widget.develop,
              user:widget.user,
            ),
          ),
        );
      }

    } else {
      // Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: getTranslated(context, "loading"),
        );
      },
    );
  }
  Future cropImage(context) async{
    setState(() {
      loading = true;
    });

    image = await ImagePicker().pickImage(source: ImageSource.gallery);
    File croppedFile = File(image.path);

    if (croppedFile != null) {
      uploadImage(croppedFile);
      setState(() {
        selectedProfileImage = croppedFile;
      });
    }
  }

  Future uploadImage(File image) async {

    Size size = MediaQuery
        .of(context)
        .size;

    var uuid = Uuid().v4();
    Reference storageReference =
    FirebaseStorage.instance.ref().child('profileImages/$uuid');
    await storageReference.putFile(image);

    var url = await storageReference.getDownloadURL();
    onSendMessage(url, "image",size);
  }

//======================
  _Fn getRecorderFn() {
    /* if (!_mRecorderIsInited || !_mPlayer.isStopped) {
    }*/
      return () {};
    return recording ? stopRecord : startRecord;
  }
  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }
  startRecord() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      ////statusText = "Recording...";
      recordFilePath = await getFilePath();
      //isComplete = false;
      if(mounted){
        setState(() {
          recording=true;
        });
      }

      RecordMp3.instance.start(recordFilePath, (type) {
        //statusText = "Record error--->$type";

      });
    } else {
      //statusText = "No microphone permission";
    }

  }
  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return sdPath + "/test1111_${i++}.mp3";
  }
  stopRecord() async {
    if(mounted){
      setState(() {
        recording=false;
        uploadingRecord=true;
      });
    }

    bool s = RecordMp3.instance.stop();
    if (s) {
      if (recordFilePath != null && File(recordFilePath).existsSync()) {
        File recordFile = new File(recordFilePath);
        uploadRecord(recordFile);
      }
      else
      {
      }
    }
  }
  Future uploadRecord(File voice) async {
    var uuid = Uuid().v4();
    Reference storageReference =firebase_storage.FirebaseStorage.instance.ref().child('audio/$uuid');
    await storageReference.putFile(voice);
    var url = await storageReference.getDownloadURL();
    onSendMessage(url,"voice",size);
    if(mounted){
      setState(() {
        uploadingRecord=false;
      });
    }

  }
}
