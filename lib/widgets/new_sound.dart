import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/audio/recorder.dart';
import 'package:flutter_complete_guide/audio/speaker.dart';
import './microphone.dart';
import '../io/sound_file_util.dart';

class NewSound extends StatefulWidget {
  final Function addSoundCallback;
  final Function cancelAddSoundCallback;
  final String soundFileLocation;

  NewSound(this.soundFileLocation, this.addSoundCallback,
      this.cancelAddSoundCallback);

  @override
  _NewSoundState createState() => _NewSoundState();
}

class _NewSoundState extends State<NewSound> {
  final Speaker speaker = Speaker();
  final soundNameController = TextEditingController();
  bool hasSound = false;
  bool isPlayingAudio = false;
  Recorder recorder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Microphone(
            widget.soundFileLocation, _recordedAudioCallback, isPlayingAudio),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: TextField(
                decoration: InputDecoration(labelText: 'Name that sound!'),
                controller: soundNameController,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.play_arrow,
                size: 50,
              ),
              onPressed: hasSound ? _stopThenPlayAudio : null,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              color: Colors.green,
              icon: Icon(
                Icons.check,
                size: 50,
              ),
              onPressed: hasSound ? _confirmSound : null,
            ),
            IconButton(
              color: Colors.red,
              icon: Icon(
                Icons.clear,
                size: 50,
              ),
              onPressed: widget.cancelAddSoundCallback,
            ),
          ],
        ),
      ],
    );
  }

  void _confirmSound() {
    widget.addSoundCallback(
        buttonText: soundNameController.text,
        pathToSound: widget.soundFileLocation);
  }

  void _stopThenPlayAudio() async {
    setState(() {
      isPlayingAudio = true;
    });
    speaker.playLocalAudio(widget.soundFileLocation).then((_) {
      setState(() {
        isPlayingAudio = false;
      });
    });
  }

  void _recordedAudioCallback() {
    setState(() => hasSound = true);
  }
}
