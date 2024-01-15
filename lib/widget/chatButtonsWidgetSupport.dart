import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/widget/dreamDialogsWidget.dart';
import 'package:uuid/uuid.dart';

import '../localization/localization_methods.dart';
import '../models/AppAppointments.dart';
import '../models/user.dart';
import '../widget/audioRocordingWidget.dart';

class chatButtonsWidgetSupport extends StatefulWidget {
  final onSendMessage;
  AppAppointments? appointment;
  GroceryUser? user;

  chatButtonsWidgetSupport({
    Key? key,
    this.onSendMessage,
    this.appointment,
    this.user,
  }) : super(key: key);

  @override
  State<chatButtonsWidgetSupport> createState() =>
      _chatButtonsWidgetSupportState();
}

class _chatButtonsWidgetSupportState extends State<chatButtonsWidgetSupport> {
  bool loading = false, uploadVideo = false, load = false;
  ValueNotifier<String> text = ValueNotifier("");
  final TextEditingController textEditingController = TextEditingController();
  var image;
  File? selectedProfileImage;
  final FocusNode focusNode = new FocusNode();
  bool showPlayer = false;
  String? audioPath;
  String result = "recoding url";
  String lang = "";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppPadding.p32.r, vertical: AppPadding.p12.r),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: AppSize.h72.h,
                  decoration: BoxDecoration(
                    color: AppColors.white6,
                    borderRadius: BorderRadius.circular(AppRadius.r66_6.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: AppPadding.p18_1.w, left: AppPadding.p18_1.w),
                    child: Row(
                      children: <Widget>[
                        // new IconButton(
                        //     icon: new SvgPicture.asset(
                        //       AssetsManager.docs,
                        //       width: AppSize.w36.w,
                        //       height:  AppSize.h40_6.h,
                        //     ),
                        //     onPressed: () => _pickFile("file", size),
                        //     //cropImage(context), // getImage(0),
                        //     color: Theme.of(context).primaryColor),
                        // audio record

                        // Button send image
                        new InkWell(
                          child: new SvgPicture.asset(
                            AssetsManager.mdPhotos,
                            width: AppSize.w26_6.w,
                            height: AppSize.h26_6.h,
                          ),
                          onTap: () => _pickUpImage(size),
                          //cropImage(context), // getImage(0),
                        ),
                        SizedBox(
                          width: AppPadding.p16.w,
                        ),
                        // Button send video
                        uploadVideo
                            ? CircularProgressIndicator()
                            : new InkWell(
                                child: new SvgPicture.asset(
                                  AssetsManager.mdiVideoOutline,
                                  width: AppSize.w37_3.w,
                                  height: AppSize.h37_3.h,
                                ),
                                onTap: () => _pickFile("video", size),
                                //uploadToStorage(context),
                              ),
                        SizedBox(
                          width: AppPadding.p21_3.w,
                        ),
                        // Edit text
                        Flexible(
                          child: Container(
                            child: TextField(
                              enableInteractiveSelection: true,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  color: Theme.of(context).primaryColor,
                                  fontSize: AppFontsSizeManager.s17.sp),
                              controller: textEditingController,
                              decoration: InputDecoration.collapsed(
                                hintText: //getTranslated(context, "writeMessage"),
                                    getTranslated(context, "writeMessage"),
                                hintStyle: TextStyle(
                                  fontFamily:
                                      getTranslated(context, 'Ithralight'),
                                  color: AppColors.grey,
                                  fontSize: AppFontsSizeManager.s17_3.sp,
                                  fontWeight: FontWeight.w300,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                              focusNode: focusNode,
                              onChanged: (str) {
                                text.value = str;
                              },
                            ),
                          ),
                        ),
                        // Button send message
                        loading
                            ? Center(child: CircularProgressIndicator())
                            : Container(
                                width: AppSize.w41_5.w,
                                height: AppSize.h41.h,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: InkWell(
                                  child: SvgPicture.asset(
                                    AssetsManager.sendFilled,
                                    width: AppSize.w41_3.w,
                                    height: AppSize.h41_3.h,
                                  ),
                                  onTap: () async {
                                    widget.onSendMessage(
                                        textEditingController.text,
                                        "text",
                                        size);
                                    textEditingController.clear();
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSize.w21_3.w),
              // audioRecorder
              Container(
                height: AppSize.h72.h,
                width: AppSize.w72.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.Gradient_Color1,
                      AppColors.Gradient_Color2,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  color: AppColors.blue,
                ),
                child: IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      elevation: 10,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) => Container(
                        height: AppSize.h200.h,
                        decoration: BoxDecoration(
                          color: AppColors.grey9,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: AudioRecorder(
                          onSendMessage: widget.onSendMessage,
                          //  theme: "light",
                          focusNode: focusNode,
                          loggedId: FirebaseAuth
                              .instance.currentUser!.uid, //widget.user.uid!
                        ),
                      ),
                    );
                  },
                  icon: SvgPicture.asset(
                    AssetsManager.microphoneIcon,
                    color: AppColors.white,
                  ),
                  // color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  sendMassageDialoge(
      BuildContext context, Size size, FilePickerResult result, dynamic file) {
    return showDialog(
      builder: (context) => DreamDialogsWidget(
        dialogContent: Column(
          children: <Widget>[
            Padding(
              padding:
                  EdgeInsets.only(right: AppSize.w10_6.w, top: AppSize.h10_6.h),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSize.h24.h),
                    child: Container(
                      child: Image.file(
                        file,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSize.w32.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: SvgPicture.asset(
                            AssetsManager.moveCloseIconPath,
                            width: AppSize.w50.w,
                            height: AppSize.h50.h,
                          ),
                        ),
                        Spacer(),
                        load
                            ? CircularProgressIndicator(
                                color: AppColors.linear2,
                              )
                            : InkWell(
                                onTap: () async {
                                  setState(() {
                                    load = true;
                                  });
                                  String url = "";
                                  if (kIsWeb) {
                                    String fileName = result.files.first.name;
                                    Reference storageReference = FirebaseStorage
                                        .instance
                                        .ref()
                                        .child('uploads111/$fileName');
                                    await storageReference.putData(file);
                                    url =
                                        await storageReference.getDownloadURL();
                                    widget.onSendMessage(url, "image", size);
                                  } else {
                                    var uuid = Uuid().v4();
                                    Reference storageReference = FirebaseStorage
                                        .instance
                                        .ref()
                                        .child('files/$uuid');
                                    await storageReference.putFile(file);
                                    url =
                                        await storageReference.getDownloadURL();
                                    widget.onSendMessage(url, "image", size);
                                  }

                                  Navigator.pop(context);
                                },
                                child: SvgPicture.asset(
                                  AssetsManager.sendIconPath,
                                  width: AppSize.w50.w,
                                  height: AppSize.h50.h,
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  sendMassageDialoge2(BuildContext context, Size size, FilePickerResult result,
      dynamic file, String type) {
    String name2 = result.files.first.name;
    return showDialog(
      builder: (context) => DreamDialogsWidget(
        dialogContent: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.close,
                    size: 32.w,
                  ),
                ),
                SizedBox(width: 140.w),
                Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Icon(
                    Icons.insert_drive_file,
                    color: Colors.red,
                    size: AppSize.h53_3,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSize.h21_3.h),
            Text(
              name2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: getTranslated(context, 'Ithra'),
                fontSize: AppFontsSizeManager.s28.sp,
                color: AppColors.linear2,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSize.h16.h),
            load
                ? CircularProgressIndicator(
                    color: AppColors.linear2,
                  )
                : InkWell(
                    onTap: () async {
                      setState(() {
                        load = true;
                      });
                      String url = "";
                      if (kIsWeb) {
                        final fileBytes = result.files.first.bytes;
                        final fileName = result.files.first.name;
                        File file = File.fromRawPath(fileBytes!);
                        print('filename');
                        print(fileName);
                        Reference storageReference = FirebaseStorage.instance
                            .ref()
                            .child('uploads111/$fileName');
                        await storageReference.putData(fileBytes);
                        url = await storageReference.getDownloadURL();
                        print('url');
                        print(url.toString());
                        widget.onSendMessage(url, type, size);
                      } else {
                        var uuid = Uuid().v4();
                        Reference storageReference =
                            FirebaseStorage.instance.ref().child('files/$uuid');

                        await storageReference.putFile(file);
                        url = await storageReference.getDownloadURL();
                        widget.onSendMessage(url, type, size);
                      }
                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset(
                      AssetsManager.sendIconPath,
                      width: AppSize.w50.w,
                      height: AppSize.h50.h,
                    ),
                  ),
          ],
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  Future<void> _pickUpImage(Size size) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    File file;

    if (result != null) {
      if (kIsWeb) {
        Uint8List? fileBytes = result.files.first.bytes;
        sendMassageDialoge(context, size, result, fileBytes);
      } else {
        file = File(result.files.single.path.toString());
        sendMassageDialoge(context, size, result, file);
      }

      setState(() {
        load = false;
      });
    }
  }

  Future<void> _pickFile(String type, Size size) async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type == "image"
            ? FileType.custom
            : type == "voice"
                ? FileType.custom
                : type == "file"
                    ? FileType.custom
                    : FileType.custom,
        allowedExtensions: type == "image"
            ? ['png', 'jpg', 'jpeg', 'gif']
            : type == "voice"
                ? ['mp3']
                : type == "file"
                    ? [
                        'pdf',
                        'doc',
                        'docx',
                        'pages',
                        '_pdf',
                        'word',
                      ]
                    : ['mp4']);

    File file;
    if (result != null) {
      if (kIsWeb) {
        Uint8List? fileBytes = result.files.first.bytes;
        file = File.fromRawPath(fileBytes!);

        sendMassageDialoge2(context, size, result, file, type);
      } else {
        File file = File(result.files.single.path.toString());
        sendMassageDialoge2(context, size, result, file, type);
      }
    }
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }
}
