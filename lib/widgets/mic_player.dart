import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/audio/speaker.dart';
import 'package:flutter_complete_guide/io/sound_file_util.dart';
import 'dart:async';

import '../audio/recorder.dart';
import '../audio/recorder_flutter_sounds_adapter.dart';

class MicPlayer extends StatefulWidget {
  final String preExistingSoundFilePath;
  final Function recordedAudioCallback;
  final Function recordingAudioCallback;

  MicPlayer(
    this.preExistingSoundFilePath,
    this.recordedAudioCallback,
    this.recordingAudioCallback,
  );

  @override
  _MicPlayerState createState() => _MicPlayerState();
}

class _MicPlayerState extends State<MicPlayer> with TickerProviderStateMixin {
  Recorder _recorder;
  bool _recordedSound = false;
  Future _recordingAudio;
  bool _isPlaying = false;
  final maxRecordingSeconds = const Duration(seconds: 5);
  Timer recordingTimer;
  final Speaker speaker = Speaker();
  AnimationController _animationController;
  String _soundMicrophonePath;

  _MicPlayerState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200,
      ),
    );
    _createSoundMicrophonePath();
  }

  void _createSoundMicrophonePath() async {
    _soundMicrophonePath = await SoundFileUtil.createSoundFile();
    _recorder = RecorderFlutterSoundsAdapter(_soundMicrophonePath);
  }

  @override
  Widget build(BuildContext context) {
    return _recorder == null
        ? Container()
        : Column(
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
    if (_hasAudio()) {
      return AnimatedIcon(
        icon: AnimatedIcons.play_pause,
        progress: _animationController,
        size: 100,
      );
    } else {
      return Icon(
        Icons.mic,
        size: 100,
      );
    }
  }

  bool _hasAudio() {
    return widget.preExistingSoundFilePath != null || _recordedSound;
  }

  _onTapped() {
    if (_hasAudio()) {
      if (_isPlaying) {
        _animationController.reverse();
        setState(() {
          _isPlaying = false;
        });
        if (widget.preExistingSoundFilePath != null) {
          speaker.stopLocalAudio(widget.preExistingSoundFilePath);
        } else {
          speaker.stopLocalAudio(_soundMicrophonePath);
        }
      } else {
        _animationController.forward();
        setState(() {
          _isPlaying = true;
        });
        String fileLocation;
        if (widget.preExistingSoundFilePath != null) {
          fileLocation = widget.preExistingSoundFilePath;
        } else {
          fileLocation = _soundMicrophonePath;
        }
        speaker.playLocalAudio(fileLocation).then((_) {
          _animationController.reverse();
          if (mounted) {
            setState(() {
              _isPlaying = false;
            });
          }
        });
      }
    }
  }

  _startRecordAudio() {
    setState(() {
      _recordingAudio = _recorder.recordAudio().then((_) {
        widget.recordingAudioCallback();
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
          widget.recordedAudioCallback(_soundMicrophonePath);
          setState(() {
            if (recordingTimer != null) {
              recordingTimer.cancel();
              recordingTimer = null;
            }
            _recordedSound = true;
            _recordingAudio = null;
          });
        });
      });
    }
  }
}
