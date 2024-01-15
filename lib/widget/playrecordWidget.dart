import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:voice_message_package/voice_message_package.dart';

import '../blocs/network_cubit/cuibt.dart';
import '../blocs/network_cubit/states.dart';
import '../config/colorsFile.dart';

class PlayRecordWidget extends StatefulWidget {
  final String url;
  final bool owner;

  const PlayRecordWidget({Key? key, required this.url, required this.owner})
      : super(key: key);

  @override
  State<PlayRecordWidget> createState() => _PlayRecordWidgetState();
}

class _PlayRecordWidgetState extends State<PlayRecordWidget>
    with WidgetsBindingObserver {
  late VoiceController voiceController;

  @override
  void initState() {
    voiceController = VoiceController(
      audioSrc: widget.url,
      maxDuration: const Duration(seconds: 200),
      isFile: false,
      onComplete: () {
        print('onComplete');
      },
      onPause: () {
        print('onPause');
      },
      onPlaying: () {
        AudioPlaybackManager().pause(voiceController);
        print('onPlaying');
      },
    );
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    voiceController.stopPlaying();
    voiceController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      voiceController.pausePlaying();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NetworkCubit, NetworkStates>(
        listener: (context, state) {
      if (state is NetworkDisconnectedState) {
        if (voiceController.isPlaying) {
          voiceController.stopPlaying();
          voiceController.dispose();
        }
      }
    }, builder: (context, state) {
      return Align(
        alignment: (widget.owner ? Alignment.topLeft : Alignment.topRight),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
              bottomLeft: Radius.circular(widget.owner ? 0.0 : 20.0),
              bottomRight: Radius.circular(widget.owner ? 20.0 : 0.0),
            ),
            border: Border.all(
                color: widget.owner ? Colors.grey.shade200 : AppColors.pink),
            color: (widget.owner ? Colors.grey.shade200 : AppColors.pink),
          ),
          child: VoiceMessageView(
            size: AppFontsSizeManager.s54.sp,
            innerPadding: AppPadding.p16.r,
            backgroundColor:
                widget.owner ? Colors.grey.shade200 : AppColors.pink,
            activeSliderColor: widget.owner ? AppColors.pink : AppColors.white,
            circlesColor: widget.owner ? AppColors.grey : AppColors.grey4,
            circlesTextStyle: TextStyle(
              color: AppColors.pink,
            ),
            counterTextStyle: TextStyle(
              color: widget.owner ? AppColors.pink : AppColors.white ,
            ),
            controller: voiceController,
          ),
        ),
      );
    });
  }
}

class AudioPlaybackManager {
  static final AudioPlaybackManager _instance =
      AudioPlaybackManager._internal();
  factory AudioPlaybackManager() => _instance;
  AudioPlaybackManager._internal();

  VoiceController? currentPlaying;

  pause(VoiceController controller) {
    if (currentPlaying != null && currentPlaying != controller) {
      currentPlaying!.pausePlaying();
    }
    currentPlaying = controller;
  }

  forcePause() {
    if (currentPlaying != null) {
      currentPlaying!.pausePlaying();
    }
  }
}
