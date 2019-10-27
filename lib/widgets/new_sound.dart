import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/audio/recorder.dart';
import 'package:flutter_complete_guide/audio/speaker.dart';
import 'package:flutter_complete_guide/model/sound_type.dart';
import 'package:image_picker/image_picker.dart';
import './microphone.dart';

class NewSound extends StatefulWidget {
  final Function addSoundCallback;
  final Function cancelAddSoundCallback;
  final Function editSoundCallback;
  final String soundFileLocation;
  final String name;
  final File image;
  final SoundType soundType;

  NewSound({
    this.soundFileLocation,
    this.addSoundCallback,
    this.cancelAddSoundCallback,
    this.editSoundCallback,
    this.name = '',
    this.image,
    this.soundType,
  });

  @override
  _NewSoundState createState() => _NewSoundState(
        name,
        image: image,
        soundType: soundType,
      );
}

class _NewSoundState extends State<NewSound> {
  final Speaker speaker = Speaker();
  bool isPlayingAudio = false;
  bool preExistingSound;
  final soundNameController = TextEditingController();
  SoundType _soundType;
  Recorder recorder;
  File _image;
  String _soundFilePath;

  _NewSoundState(String name, {File image, SoundType soundType}) {
    soundNameController.text = name;
    _image = image;
    _soundType = soundType;
    preExistingSound = soundType != null;
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
              onPressed: hasSound() ? _stopThenPlayAudio : null,
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
              onPressed: hasSound() ? _confirmSound : null,
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

  bool hasSound() {
    return _soundType != null;
  }

  void _confirmSound() {
    if (preExistingSound) {
      widget.editSoundCallback();
    } else {
      widget.addSoundCallback(
        name: soundNameController.text,
        soundRecordedPath: _getSoundPath(),
        soundFilePath: widget.soundFileLocation,
        soundType: _soundType,
        image: _image,
      );
    }
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
    if (_soundType == SoundType.Recorded) {
      soundPath = widget.soundFileLocation;
    } else if (_soundType == SoundType.File) {
      soundPath = _soundFilePath;
    }

    return soundPath;
  }

  void _recordedAudioCallback() {
    setState(() {
      _soundType = SoundType.Recorded;
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
        _soundType = SoundType.File;
      });
    }
  }
}
