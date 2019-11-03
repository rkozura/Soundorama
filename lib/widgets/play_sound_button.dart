import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/model/delete.dart';
import 'package:flutter_complete_guide/model/sound_type.dart';
import 'package:provider/provider.dart';

import '../audio/speaker.dart';
import 'bordered_text.dart';

class PlaySoundButton extends StatefulWidget {
  final String id;
  final String name;
  final String soundPath;
  final Function deleteSoundCallback;
  final Function editSoundCallback;
  final File imageLocation;
  final SoundType soundType;

  PlaySoundButton({
    this.id,
    this.name,
    this.soundPath,
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
              : Container(
                  margin: EdgeInsets.all(10),
                  alignment: Alignment.bottomCenter,
                  child: BorderedText(
                    widget.name,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        spreadRadius: .1,
                      ),
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(10, 10),
                        blurRadius: 5,
                      )
                    ],
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(widget.imageLocation),
                    ),
                  ),
                ),
        ),
      ),
      onLongPress: _editSound,
      onTap: () => _onTapped(),
    );
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
    speaker.stopThenPlayLocalAudio(widget.soundPath);
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
