import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart' as ap;
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/widget/playrecordWidget.dart';
import 'package:grocery_store/widget/recordingTimerWidget.dart';
import 'package:grocery_store/widget/voice_record/voice_message_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:uuid/uuid.dart';
import 'package:voice_message_package/voice_message_package.dart';

import '../blocs/network_cubit/cuibt.dart';
import '../blocs/network_cubit/states.dart';

typedef _Fn = void Function();

class AudioRecorder extends StatefulWidget {
  final onSendMessage;
  final focusNode;
  final String loggedId;
  final String? theme;

  const AudioRecorder(
      {this.onSendMessage, required this.loggedId, this.focusNode, this.theme});

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder>
    with WidgetsBindingObserver {
  bool _isMounted = false,
      isPlaying = false,
      isComplete = false,
      isShowSticker = false,
      uploadingRecord = false,
      recording = true;
  String statusText = "";
  late String recordFilePath;
  int i = 0;
  final player = AudioPlayer();
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  VoiceController? voiceController;
  ap.RecorderController controller = ap.RecorderController(); // Initialise

  int counter = 0;

  // 00:00:00 this same
  /* String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(2, '0');
  }*/

// 00:00 this same
  String formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    AudioPlaybackManager().forcePause();
    _isMounted = true;
    widget.focusNode.addListener(onFocusChange);
    startRecord();

    player.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    player.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    player.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void onFocusChange() {
    if (widget.focusNode.hasFocus) {
      if (mounted) {
        setState(() {
          isShowSticker = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NetworkCubit, NetworkStates>(
        listener: (context, state) {
      if (state is NetworkDisconnectedState) {
        if(controller.isRecording){
          controller.pause();
          RecordMp3.instance.pause();
        }
        else if (voiceController?.isPlaying ?? false) {
          voiceController!.pausePlaying();
        }
      }
      if (state is NetworkConnectedState) {
        Navigator.pop(context);
      }
    }, builder: (context, state) {
      return Padding(
        padding: EdgeInsets.only(
            right: AppPadding.p26_5.w,
            left: AppPadding.p26_5.w,
            top: AppPadding.p15.h),
        child: Column(
          children: [
            if (recording)
              Container(
                //width: AppSize.w453_3.w,
                height: AppSize.h72.h,
                decoration: BoxDecoration(
                  color: AppColors.grey9,
                  borderRadius: BorderRadius.circular(AppRadius.r66_6.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      child: RecordingTimerWidget(
                          initialTimeInSeconds: duration.inSeconds),
                      backgroundColor: AppColors.grey12,
                      // radius: 92,
                    ),
                    Spacer(),
                    ap.AudioWaveforms(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p30.w),
                      size: Size(
                          AppSize.w390.w, MediaQuery.of(context).size.height),
                      recorderController: controller,
                      enableGesture: false,
                      waveStyle: ap.WaveStyle(
                        waveColor: AppColors.pink,
                        showMiddleLine: false,
                        spacing: AppSize.w10.w,
                        showTop: true,
                        showBottom: true,
                        bottomPadding: AppPadding.p35.h,
                        waveCap: StrokeCap.round,
                        middleLineColor: Colors.redAccent,
                        middleLineThickness: 3.0,
                        waveThickness: 3.0,
                        showDurationLabel: false,
                        extendWaveform: true,
                        backgroundColor: Colors.black,
                        showHourInDuration: false,
                        durationLinesHeight: 0.0,
                        durationStyle: const TextStyle(
                          color: Colors.red,
                          fontSize: 0.0,
                        ),
                        labelSpacing: 0.0,
                        //durationTextPadding: 20.0,
                        durationLinesColor: Colors.blueAccent,
                        scaleFactor: AppSize.h55.h,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                //width: AppSize.w453_3.w,
                //height: AppSize.h72.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.r66_6.r),
                ),
                child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        VoiceMessageView2(
                          size: AppFontsSizeManager.s54.sp,
                          innerPadding: AppPadding.p16.r,
                          backgroundColor: Colors.grey.shade200,
                          activeSliderColor: AppColors.pink,
                          circlesColor: AppColors.grey,
                          circlesTextStyle: TextStyle(
                            color: AppColors.pink,
                          ),
                          counterTextStyle: TextStyle(
                            color: AppColors.grey,
                          ),
                          controller: voiceController!,
                        ),
                      ],
                    )),
              ),
            SizedBox(height: AppSize.h15.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p3.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // delete recording before send it
                  uploadingRecord
                      ? CircularProgressIndicator()
                      : new InkWell(
                          splashColor: AppColors.green,
                          child: SvgPicture.asset(
                            AssetsManager.iconDelete,
                            width: AppSize.w30.w,
                            height: AppSize.h45.h,
                          ),
                          onTap: () async {
                            setState(() {
                              uploadingRecord = true;
                            });
                            deleteRecord();
                            Navigator.pop(context);
                          },
                        ),
                  // uploadingRecord
                  new InkWell(
                    child: recording
                        ? SvgPicture.asset(
                            AssetsManager.recordPusePath1,
                            width: AppSize.w45.w,
                            height: AppSize.h50.h,
                            color: AppColors.linear2,
                          )
                        : SvgPicture.asset(
                            AssetsManager.outline_microphone_iconPath_svg,
                            width: AppSize.w50.w,
                            height: AppSize.h55.h,
                            color: AppColors.linear2,
                          ),
                    // المفترض يتم استبدال مثود الإيقاف باستئناف
                    onTap: () {
                      //   recording ? pauseRecord() : resumeRecord();
                      if (recording) {
                        pauseRecord();
                      } else {
                        resumeRecord();
                      }
                    },
                    //getRecorderFn(),
                  ),
                  // bottom send
                  uploadingRecord
                      ? CircularProgressIndicator()
                      : Container(
                          height: AppSize.h60.h,
                          width: AppSize.w60.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.linear4,
                                AppColors.linear8,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            color: AppColors.blue,
                          ),
                          child: Center(
                            child: InkWell(
                              child: SvgPicture.asset(
                                AssetsManager.sendFilled,
                                width: AppSize.w40.w,
                                height: AppSize.h40.h,
                                color: AppColors.white,
                              ),
                              onTap: () async {
                                uploadRecordNow();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Future<void> dispose() async {
    controller.stop();
    RecordMp3.instance.stop();
    controller.dispose();
    if(voiceController != null){
      voiceController!.stopPlaying();
      voiceController!.dispose();
    }
    _isMounted = false;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (controller.recorderState.isRecording) {
        pauseRecord();
      }
      if (voiceController!.isPlaying) {
        voiceController!.pausePlaying();
      }
    }
  }

  _Fn getRecorderFn() {
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

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return sdPath +
        "/test1111_${DateTime.now().millisecondsSinceEpoch.toString() + widget.loggedId}.mp3";
  }

  startRecord() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      recordFilePath = await getFilePath();
      //isComplete = false;
      /*if (_isMounted) {
        setState(() {
          recording = !recording;
        });
      }*/
      RecordMp3.instance.start(recordFilePath, (type) {});
      controller.record();
    } else {}
  }

  pauseRecord() async {
    counter++;
    RecordMp3.instance.pause();
    voiceController = VoiceController(
        audioSrc: recordFilePath,
        maxDuration: const Duration(seconds: 200),
        isFile: true,
        onComplete: () {
          print('onComplete');
        },
        onPause: () {
          print('onPause');
        },
        onPlaying: () {
          print('onPlaying');
        },
        onError: (e) {
          print("errror $e");
        });
    await player.stop();
    player.setSource(UrlSource(recordFilePath));
    controller.pause(); // Pause recording

    if (_isMounted) {
      setState(() {
        recording = !recording;
      });
    }
    await player.getDuration();
    /*  setState(() {
      duration=position;
    });*/
    print("pauseRecord $counter");
    print("ddddd 22 = ${duration.inSeconds}");
    print("ppppp 22 = ${position.inSeconds}");
  }

  resumeRecord() async {
    //player.setSource(UrlSource(recordFilePath));
    voiceController!.pausePlaying();
    print("resumeRecord $counter");
    controller.record();
    RecordMp3.instance.resume();
    //player.getDuration();
    if (_isMounted) {
      setState(() {
        recording = !recording;
      });
    }
    /* setState(() {
      position=duration;
    });*/
    print("ddddd 33 = ${duration.inSeconds}");
    print("ppppp 33 = ${position.inSeconds}");
  }

  stopRecord() async {
    if (_isMounted) {
      setState(() {
        recording = !recording;
        //uploadingRecord = true;
        RecordMp3.instance.stop();
        controller.stop();
      });
    }
  }

  void togglePlay() async {
    if (isPlaying) {
      voiceController!.pausePlaying();
      print("togglePlay--pause $counter");
      print("ddddd 44 = ${duration.inSeconds}");
      print("ppppp 44 = ${position.inSeconds}");
    } else {
      voiceController!.startPlaying(recordFilePath);
      print("togglePlay--play $counter");
      print("ddddd 55 = ${duration.inSeconds}");
      print("ppppp 55 = ${position.inSeconds}");
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  deleteRecord() {
    setState(() {
      recordFilePath = "";
      uploadingRecord = false;
    });
  }

  uploadRecordNow() async {
    bool s = RecordMp3.instance.stop();
    if (s) {
      if (File(recordFilePath).existsSync()) {
        File recordFile = new File(recordFilePath);
        if (_isMounted) {
          setState(() {
            uploadingRecord = true;
          });
        }
        await player.stop();
        uploadRecord(recordFile);
      } else {}
    }
  }

  Future uploadRecord(File voice) async {
    Size size = MediaQuery.of(context).size;
    var uuid = Uuid().v4();
    Reference storageReference =
        firebase_storage.FirebaseStorage.instance.ref().child('audio/$uuid');
    firebase_storage.SettableMetadata metadata =
    firebase_storage.SettableMetadata(contentType: 'audio/mpeg');
    await storageReference.putFile(voice, metadata);
    var url = await storageReference.getDownloadURL();
    widget.onSendMessage(url, "voice", size);
    if (_isMounted) {
      setState(() {
        uploadingRecord = false;
      });
    }
  }
}
