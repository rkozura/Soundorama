import 'dart:async';

import 'package:flutter/material.dart';

import '../audio/recorder.dart';
import '../audio/recorder_flutter_sounds_adapter.dart';

class Microphone extends StatefulWidget {
  final String fileAbsolutePath;
  final Function recordedAudioCallback;
  final bool isPlayingAudio;

  Microphone(
      this.fileAbsolutePath, this.recordedAudioCallback, this.isPlayingAudio);

  @override
  _MicrophoneState createState() => _MicrophoneState(fileAbsolutePath);
}

class _MicrophoneState extends State<Microphone> {
  Recorder _recorder;
  Future _recordingAudio;
  bool _isRecording = false;
  final maxRecordingSeconds = const Duration(seconds: 5);
  Timer recordingTimer;

  _MicrophoneState(String fileAbsolutePath) {
    _recorder = RecorderFlutterSoundsAdapter(fileAbsolutePath);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTapDown: (_) => _canRecordAudio() ? _startRecordAudio() : null,
          onTapUp: (_) => _endRecordAudio(),
          onTapCancel: () => _endRecordAudio(),
          child: IconButton(
            color: _canRecordAudio() ? Colors.green : Colors.grey,
            icon: Icon(Icons.mic),
            onPressed: () {},
          ),
          behavior: HitTestBehavior.translucent,
        ),
        Text(
          'Hold mic to record',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  _canRecordAudio() {
    return !_isRecording && !widget.isPlayingAudio;
  }

  _startRecordAudio() {
    if (!_isRecording) {
      setState(() {
        _recordingAudio = _recorder.recordAudio().then((_) {
          setState(() {
            _isRecording = true;
            recordingTimer = Timer(maxRecordingSeconds, () => _endRecordAudio());
          });
        });
      });
    }
  }

  _endRecordAudio() {
    if (_recordingAudio != null) {
      _recordingAudio.then((_) {
        _recorder.stopRecordAudio().then((_) {
          widget.recordedAudioCallback();
          setState(() {
            if (recordingTimer != null) {
              recordingTimer.cancel();
              recordingTimer = null;
            }
            _recordingAudio = null;
            _isRecording = false;
          });
        });
      });
    }
  }
}
