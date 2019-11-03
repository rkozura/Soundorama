import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/audio/recorder.dart';
import 'package:flutter_complete_guide/audio/speaker.dart';
import 'package:flutter_complete_guide/model/sound_type.dart';
import 'package:flutter_complete_guide/widgets/mic_player.dart';
import 'package:flutter_complete_guide/widgets/photo_picker.dart';
import 'package:uuid/uuid.dart';

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
  String _soundPath;
  Uuid uuid = Uuid();
  String _filePath;

  _NewSoundState(
    String id,
    String name, {
    String soundPath,
    SoundType soundType,
    File image,
  }) {
    if (id != null) {
      _id = id;
    } else {
      _id = uuid.v4();
    }

    soundNameController.text = name;
    _soundPath = soundPath;
    _soundType = soundType;
    _image = image;
    _filePath = soundPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (buildContext) {
          return Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                      child: PhotoPicker(_image, _selectPhotoCallback),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 30, 0),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Name that sound!',
                            hasFloatingPlaceholder: true,
                          ),
                          textAlign: TextAlign.center,
                          controller: soundNameController,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MicPlayer(_filePath, _recordedAudioCallback),
                  Container(
                    color: Colors.black45,
                    height: 50,
                    width: 2,
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: IconButton(
                          color: Colors.deepPurple,
                          padding: EdgeInsets.all(0),
                          icon: Icon(Icons.unarchive, size: 100),
                          onPressed: getFile,
                        ),
                      ),
                      Text(
                        'Tap for file',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 70,
                width: 300,
                child: RaisedButton(
                  color: Colors.green,
                  child: Text(
                    widget.soundPath == null ? 'Create Sound' : 'Confirm Edit',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  onPressed:
                      hasSound() ? () => _confirmSound(buildContext) : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _selectPhotoCallback(File image) {
    setState(() {
      _image = image;
    });
  }

  bool hasSound() {
    return _soundType != null;
  }

  void _confirmSound(BuildContext builderContext) {
    if (soundNameController.text == '' && _image == null) {
      Scaffold.of(builderContext).showSnackBar(
        SnackBar(
          content: Text('Pick an image and/or name your sound!'),
        ),
      );
    } else {
      widget.addSoundCallback(
        id: _id,
        name: soundNameController.text,
        soundPath: _soundPath,
        soundType: _soundType,
        image: _image,
      );
    }
  }

  void _recordedAudioCallback(String soundMicrophonePath) {
    setState(() {
      _soundType = SoundType.Recorded;
      _soundPath = soundMicrophonePath;
      _filePath = null;
    });
  }

  Future getFile() async {
    String filePath = await FilePicker.getFilePath(type: FileType.AUDIO);
    if (filePath != null) {
      setState(() {
        _soundType = SoundType.File;
        _soundPath = filePath;
        _filePath = filePath;
      });
    }
  }
}
