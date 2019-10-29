import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/audio/recorder.dart';
import 'package:flutter_complete_guide/audio/speaker.dart';
import 'package:flutter_complete_guide/io/sound_file_util.dart';
import 'package:flutter_complete_guide/model/sound_type.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import './microphone.dart';

class NewSound extends StatefulWidget {
  final String id;
  final String name;
  final String soundPath;
  final File image;
  final SoundType soundType;
  final Function addSoundCallback;
  final Function cancelAddSoundCallback;

  NewSound({
    this.id,
    this.name = '',
    this.soundPath,
    this.soundType,
    this.image,
    this.addSoundCallback,
    this.cancelAddSoundCallback,
  });

  @override
  _NewSoundState createState() => _NewSoundState(
        id,
        name,
        soundPath: soundPath,
        soundType: soundType,
        image: image,
      );
}

class _NewSoundState extends State<NewSound> {
  String _id;
  final soundNameController = TextEditingController();
  final Speaker speaker = Speaker();
  bool isPlayingAudio = false;
  SoundType _soundType;
  Recorder recorder;
  File _image;
  String _soundMicrophonePath;
  String _soundPath;
  String _originalSoundPath;
  SoundType _originalSoundType;
  bool _confirmedSound = false;
  Uuid uuid = Uuid();

  _NewSoundState(String id, String name,
      {String soundPath, SoundType soundType, File image}) {
    if (id != null) {
      _id = id;
    } else {
      _id = uuid.v4();
    }

    soundNameController.text = name;
    _soundPath = soundPath;
    _soundType = soundType;
    _image = image;

    _originalSoundPath = soundPath;
    _originalSoundType = soundType;

    createSoundMicrophonePath();
  }

  createSoundMicrophonePath() async {
    String soundMicrophonePath = await SoundFileUtil.createSoundFile();
    setState(() {
      _soundMicrophonePath = soundMicrophonePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _soundMicrophonePath == null
        ? Container()
        : Column(
            children: <Widget>[
              Microphone(
                  _soundMicrophonePath, _recordedAudioCallback, isPlayingAudio),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration:
                          InputDecoration(labelText: 'Name that sound!'),
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
                    onPressed: _cancelSound,
                  ),
                ],
              ),
            ],
          );
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 80,
      maxHeight: 80,
    );

    setState(() {
      _image = image;
    });
  }

  bool hasSound() {
    return _soundType != null;
  }

  @override
  void dispose() {
    if (_soundType == SoundType.File) {
      SoundFileUtil.deleteSoundFile(_soundMicrophonePath);
    } else if (_soundType == SoundType.Recorded) {
      if (_originalSoundPath != _soundPath && !_confirmedSound) {
        SoundFileUtil.deleteSoundFile(_soundMicrophonePath);
      }
    }
    super.dispose();
  }

  void _confirmSound() {
    _confirmedSound = true;
    widget.addSoundCallback(
      id: _id,
      name: soundNameController.text,
      soundPath: _soundPath,
      soundType: _soundType,
      image: _image,
    );
  }

  void _cancelSound() {
    widget.cancelAddSoundCallback(_soundMicrophonePath);
  }

  void _stopThenPlayAudio() {
    setState(() {
      isPlayingAudio = true;
    });

    speaker.playLocalAudio(_soundPath).then((_) {
      if (this.mounted) {
        setState(() {
          isPlayingAudio = false;
        });
      }
    });
  }

  void _recordedAudioCallback() {
    setState(() {
      _soundType = SoundType.Recorded;
      _soundPath = _soundMicrophonePath;
    });
  }

  Future getFile() async {
    String filePath = await FilePicker.getFilePath(type: FileType.AUDIO);
    if (filePath != null) {
      setState(() {
        _soundType = SoundType.File;
        _soundPath = filePath;
      });
    }
  }
}
