import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/io/sound_file_util.dart';
import 'package:flutter_complete_guide/widgets/new_sound.dart';

import 'play_sound_button.dart';

class SoundBoard extends StatefulWidget {
  @override
  _SoundBoardState createState() => _SoundBoardState();
}

class _SoundBoardState extends State<SoundBoard> {
  List<PlaySoundButton> playSoundButtons = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Sound Board'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showNewSound(context),
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _buildGrid(),
    );
  }

  void showNewSound(BuildContext context) async {
    String soundFileLocation = await SoundFileUtil.createSoundFile();

    showModalBottomSheet(
      builder: (_) {
        return NewSound(
            soundFileLocation, _addSoundCallback, _cancelAddSoundCallback);
      },
      context: context,
    ).then((keepSound) {
      if ((keepSound == null || !keepSound) &&
          SoundFileUtil.doesFileExist(soundFileLocation)) {
        SoundFileUtil.deleteSoundFile(soundFileLocation);
      }
    });
  }

  GridView _buildGrid() {
    return GridView.builder(
      itemCount: playSoundButtons.length,
      itemBuilder: (context, position) {
        return playSoundButtons[position];
      },
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
    );
  }

  void _addSoundCallback({@required buttonText, @required pathToSound}) {
    setState(() {
      playSoundButtons.add(PlaySoundButton(
        buttonText: buttonText,
        pathToSound: pathToSound,
        editSoundCallback: _editSoundCallback,
      ));
    });
    _hideDialogAndKeepSound();
  }

  void _editSoundCallback(PlaySoundButton playSoundButton) {
    showDialog(
      context: context,
      builder: (_) {
        return NewSound('', _addSoundCallback, _cancelAddSoundCallback);
      },
    );
  }

  void _deleteSound(PlaySoundButton playSoundButton) {
    SoundFileUtil.deleteSoundFile(playSoundButton.pathToSound);
    setState(() {
      playSoundButtons.remove(playSoundButton);
    });
  }

  void _cancelAddSoundCallback() {
    Navigator.pop(context);
  }

  void _hideDialogAndKeepSound() {
    Navigator.pop(context, true);
  }
}
