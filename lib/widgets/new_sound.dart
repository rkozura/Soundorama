import 'dart:io';

import 'package:file_picker/file_picker.dart';
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
  bool hasRecordedSound = false;
  bool hasFileSound = false;
  bool isPlayingAudio = false;
  Recorder recorder;
  File _image;
  String _soundFilePath;

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
              onPressed: hasRecordedSound || widget.existingSound || hasFileSound
                  ? _stopThenPlayAudio
                  : null,
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
            IconButton(
              icon: Icon(
                Icons.archive,
                size: 50,
              ),
              onPressed: getFile,
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
                  hasRecordedSound || widget.existingSound || hasFileSound
                      ? _confirmSound
                      : null,
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
        pathToSound: _getSoundPath(),
        image: _image);
  }

  void _stopThenPlayAudio() async {
    setState(() {
      isPlayingAudio = true;
    });

    speaker.playLocalAudio(_getSoundPath()).then((_) {
      if (this.mounted) {
        setState(() {
          isPlayingAudio = false;
        });
      }
    });
  }

  String _getSoundPath() {
    String soundPath;
    if (hasRecordedSound) {
      soundPath = widget.soundFileLocation;
    } else if (hasFileSound) {
      soundPath = _soundFilePath;
    }

    return soundPath;
  }

  void _recordedAudioCallback() {
    setState(() {
      hasRecordedSound = true;
      hasFileSound = false;
    });
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

  Future getFile() async {
    String filePath = await FilePicker.getFilePath(type: FileType.AUDIO);
    if (filePath != null) {
      setState(() {
        _soundFilePath = filePath;
        hasRecordedSound = false;
        hasFileSound = true;
      });
    }
  }
}
