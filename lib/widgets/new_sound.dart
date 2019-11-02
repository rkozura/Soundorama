import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/audio/recorder.dart';
import 'package:flutter_complete_guide/audio/speaker.dart';
import 'package:flutter_complete_guide/model/sound_type.dart';
import 'package:flutter_complete_guide/widgets/mic_player.dart';
import 'package:image_picker/image_picker.dart';
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
    return Column(
      children: <Widget>[
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // _image != null ? Image.file(_image) : Container(),
              SizedBox(
                height: 50,
                width: 50,
                child: IconButton(
                  icon: Icon(
                    Icons.add_a_photo,
                    size: 50,
                  ),
                  onPressed: getImage,
                ),
              ),
              MicPlayer(
                _filePath,
                _recordedAudioCallback,
              ),
              SizedBox(
                height: 50,
                width: 50,
                child: IconButton(
                  icon: Icon(
                    Icons.unarchive,
                    size: 50,
                  ),
                  onPressed: getFile,
                ),
              ),
            ]),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Name that sound!',
              hasFloatingPlaceholder: true,
            ),
            textAlign: TextAlign.center,
            controller: soundNameController,
          ),
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
            onPressed: hasSound() ? _confirmSound : null,
          ),
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

  void _confirmSound() {
    widget.addSoundCallback(
      id: _id,
      name: soundNameController.text,
      soundPath: _soundPath,
      soundType: _soundType,
      image: _image,
    );
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
