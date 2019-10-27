import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/io/sound_file_util.dart';
import 'package:flutter_complete_guide/model/delete.dart';
import 'package:flutter_complete_guide/model/sound_type.dart';
import 'package:provider/provider.dart';

import '../audio/speaker.dart';

class PlaySoundButton extends StatefulWidget {
  final String name;
  final String soundRecordedPath;
  final String soundFilePath;
  final Function deleteSoundCallback;
  final Function editSoundCallback;
  final File imageLocation;
  final SoundType soundType;

  PlaySoundButton({
    this.name,
    this.soundRecordedPath,
    this.soundFilePath,
    this.soundType,
    this.deleteSoundCallback,
    this.editSoundCallback,
    this.imageLocation,
  });

  @override
  _PlaySoundButtonState createState() => _PlaySoundButtonState();
}

class _PlaySoundButtonState extends State<PlaySoundButton> {
  Speaker speaker = Speaker();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: GridTile(
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: widget.imageLocation == null
              ? Text(widget.name)
              : Image.file(widget.imageLocation),
        ),
      ),
      onLongPress: _editSound,
      onTap: () => _onTapped(),
    );
  }

  @override
  void dispose() {
    SoundFileUtil.deleteSoundFile(widget.soundRecordedPath);
    super.dispose();
  }

  void _onTapped() {
    final delete = Provider.of<Delete>(context);
    if (delete.getDeleting()) {
      _showDeleteConfirmationModal();
    } else if (delete.getEditing()) {
      _editSound();
    } else {
      _playSound();
    }
  }

  void _playSound() {
    String soundPath;
    if (widget.soundType == SoundType.File) {
      soundPath = widget.soundRecordedPath;
    } else {
      soundPath = widget.soundFilePath;
    }

    speaker.stopThenPlayLocalAudio(soundPath);
  }

  void _editSound() {
    widget.editSoundCallback(widget);
  }

  void _showDeleteConfirmationModal() {
    _showDeleteConfirmAlert();
  }

  Future<void> _showDeleteConfirmAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete "${widget.name}"?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                widget.deleteSoundCallback(widget);
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
