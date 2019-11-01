import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/audio/speaker.dart';
import 'dart:async';

import '../audio/recorder.dart';
import '../audio/recorder_flutter_sounds_adapter.dart';

class MicPlayer extends StatefulWidget {
  final String fileAbsolutePath;
  final String soundFilePath;
  final Function recordedAudioCallback;

  MicPlayer(
    this.fileAbsolutePath,
    this.soundFilePath,
    this.recordedAudioCallback,
  );

  @override
  _MicPlayerState createState() => _MicPlayerState(fileAbsolutePath);
}

class _MicPlayerState extends State<MicPlayer> with TickerProviderStateMixin {
  Recorder _recorder;
  bool _hasAudio = false;
  Future _recordingAudio;
  bool _isPlaying = false;
  final maxRecordingSeconds = const Duration(seconds: 5);
  Timer recordingTimer;
  final Speaker speaker = Speaker();
  AnimationController _animationController;

  _MicPlayerState(String fileAbsolutePath) {
    _recorder = RecorderFlutterSoundsAdapter(fileAbsolutePath);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onLongPress: _startRecordAudio,
          onLongPressUp: _endRecordAudio,
          child: SizedBox(
            height: 100,
            width: 100,
            child: IconButton(
              color: Colors.green,
              padding: EdgeInsets.all(0),
              icon: _getMicPlayerIcon(),
              onPressed: _onTapped,
            ),
          ),
          behavior: HitTestBehavior.translucent,
        ),
        Text(
          'Hold to record',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  _getMicPlayerIcon() {
    if (widget.soundFilePath == null &&
        (!_hasAudio || _recordingAudio != null)) {
      return Icon(Icons.mic, size: 100);
    } else {
      return AnimatedIcon(
        icon: AnimatedIcons.play_pause,
        progress: _animationController,
        size: 100,
      );
    }
  }

  _onTapped() {
    if (_hasAudio || widget.soundFilePath != null) {
      if (_isPlaying) {
        setState(() {
          _animationController.reverse();
          _isPlaying = false;
        });
        if (widget.soundFilePath == null) {
          speaker.stopLocalAudio(widget.fileAbsolutePath);
        } else {
          speaker.stopLocalAudio(widget.soundFilePath);
        }
      } else {
        setState(() {
          _animationController.forward();
          _isPlaying = true;
        });
        String fileLocation;
        if (widget.soundFilePath == null) {
          fileLocation = widget.fileAbsolutePath;
        } else {
          fileLocation = widget.soundFilePath;
        }
        speaker.playLocalAudio(fileLocation).then((_) {
          setState(() {
            _animationController.reverse();
            _isPlaying = false;
          });
        });
      }
    }
  }

  _startRecordAudio() {
    setState(() {
      _recordingAudio = _recorder.recordAudio().then((_) {
        setState(() {
          recordingTimer = Timer(maxRecordingSeconds, () => _endRecordAudio());
        });
      });
    });
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
            _hasAudio = true;
            _recordingAudio = null;
          });
        });
      });
    }
  }
}
