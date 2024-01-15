import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grocery_store/config/colorsFile.dart';

class RecordingTimerWidget extends StatefulWidget {
  final int initialTimeInSeconds;

  RecordingTimerWidget({Key? key, this.initialTimeInSeconds = 0})
      : super(key: key);

  @override
  _RecordingTimerWidgetState createState() => _RecordingTimerWidgetState();
}

class _RecordingTimerWidgetState extends State<RecordingTimerWidget> {
  Timer? _timer;
  int _timeInSeconds = 0;

  @override
  void initState() {
    super.initState();
    _timeInSeconds = widget.initialTimeInSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timeInSeconds++;
      });
    });
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(_formatTime(_timeInSeconds),
        style: TextStyle(fontSize: 15, color: AppColors.white));
  }
}
