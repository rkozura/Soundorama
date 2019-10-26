import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/audio/recorder.dart';
import 'package:flutter_complete_guide/audio/speaker.dart';
import 'package:image_picker/image_picker.dart';
import './microphone.dart';

class NewSound extends StatefulWidget {
  final Function addSoundCallback;
  final Function cancelAddSoundCallback;
  final String soundFileLocation;
  final bool existingSound;
  final String name;
  final File image;

  NewSound({
    this.soundFileLocation,
    this.addSoundCallback,
    this.cancelAddSoundCallback,
    this.existingSound = false,
    this.name = '',
    this.image,
  });

  @override
  _NewSoundState createState() => _NewSoundState(name, image: image);
}

class _NewSoundState extends State<NewSound> {
  final Speaker speaker = Speaker();
  final soundNameController = TextEditingController();
  bool hasSound = false;
  bool isPlayingAudio = false;
  Recorder recorder;
  File _image;

  _NewSoundState(String name, {File image}) {
    soundNameController.text = name;
    _image = image;
  }

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
              onPressed:
                  hasSound || widget.existingSound ? _stopThenPlayAudio : null,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _image != null ? Image.file(_image) : Container(),
            IconButton(
              icon: Icon(
                Icons.add_a_photo,
                size: 50,
              ),
              onPressed: getImage,
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
              onPressed:
                  hasSound || widget.existingSound ? _confirmSound : null,
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
        pathToSound: widget.soundFileLocation,
        image: _image);
  }

  void _stopThenPlayAudio() async {
    setState(() {
      isPlayingAudio = true;
    });
    speaker.playLocalAudio(widget.soundFileLocation).then((_) {
      if (this.mounted) {
        setState(() {
          isPlayingAudio = false;
        });
      }
    });
  }

  void _recordedAudioCallback() {
    setState(() => hasSound = true);
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 80,
      maxHeight: 80,
    );

    setState(() {
      _image = image;
    });
  }
}
