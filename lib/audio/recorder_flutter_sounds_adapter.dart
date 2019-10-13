import 'dart:async';

import 'package:flutter_sound/android_encoder.dart';

import 'package:flutter_sound/flutter_sound.dart';

import 'recorder.dart';

class RecorderFlutterSoundsAdapter extends Recorder {
  FlutterSound flutterSound;

  RecorderFlutterSoundsAdapter(String audioFileLocation)
      : super(audioFileLocation) {
    flutterSound = FlutterSound();
  }

  @override
  Future recordAudio() {
    return flutterSound.startRecorder(audioFileLocation,
        androidEncoder: AndroidEncoder.AMR_WB);
  }

  @override
  Future stopRecordAudio() async {
    return await flutterSound.stopRecorder();
  }
}
