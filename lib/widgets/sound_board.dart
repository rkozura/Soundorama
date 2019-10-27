import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_complete_guide/io/sound_file_util.dart';
import 'package:flutter_complete_guide/widgets/new_sound.dart';

import 'play_sound_button.dart';
import '../model/delete.dart';

class SoundBoard extends StatefulWidget {
  @override
  _SoundBoardState createState() => _SoundBoardState();
}

class _SoundBoardState extends State<SoundBoard> {
  List<PlaySoundButton> playSoundButtons = [];

  @override
  Widget build(BuildContext context) {
    final delete = Provider.of<Delete>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(delete)),
        centerTitle: true,
        actions: delete.notInMode()
            ? <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    delete.toggleEditingMode();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_forever),
                  onPressed: () {
                    delete.toggleDeleteMode();
                  },
                ),
              ]
            : [],
      ),
      floatingActionButton: _getFAB(delete),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _buildGrid(),
    );
  }

  String _getTitle(Delete delete) {
    if (delete.getDeleting()) {
      return 'Tap to delete';
    } else if (delete.getEditing()) {
      return 'Tap to edit';
    } else {
      return 'My Sound Board';
    }
  }

  Widget _getFAB(Delete delete) {
    if (delete.getDeleting()) {
      return FloatingActionButton.extended(
        icon: Icon(Icons.check),
        label: Text('Finished Deleting'),
        onPressed: () {
          delete.toggleDeleteMode();
        },
      );
    } else if (delete.getEditing()) {
      return FloatingActionButton.extended(
        icon: Icon(Icons.check),
        label: Text('Finished Editing'),
        onPressed: () {
          delete.toggleEditingMode();
        },
      );
    } else {
      return FloatingActionButton(
        onPressed: () => showNewSound(context),
        child: Icon(Icons.add),
      );
    }
  }

  void showNewSound(BuildContext context) async {
    String soundFileLocation = await SoundFileUtil.createSoundFile();

    showModalBottomSheet(
      builder: (_) {
        return NewSound(
          soundFileLocation: soundFileLocation,
          addSoundCallback: _addSoundCallback,
          cancelAddSoundCallback: _cancelAddSoundCallback,
        );
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }

  void _addSoundCallback({@required buttonText, @required pathToSound, image}) {
    setState(() {
      for (PlaySoundButton button in playSoundButtons) {
        if (button.pathToSound == pathToSound) {
          playSoundButtons.remove(button);
          break;
        }
      }
      playSoundButtons.add(
        PlaySoundButton(
            buttonText: buttonText,
            pathToSound: pathToSound,
            deleteSoundCallback: _deleteSound,
            editSoundCallback: _editSound,
            imageLocation: image == null ? null : image),
      );
    });
    _hideDialogAndKeepSound();
  }

  void _deleteSound(PlaySoundButton playSoundButton) {
    SoundFileUtil.deleteSoundFile(playSoundButton.pathToSound);
    setState(() {
      playSoundButtons.remove(playSoundButton);
    });
  }

  void _editSound(PlaySoundButton playSoundButton) {
    showModalBottomSheet(
      builder: (_) {
        return NewSound(
            soundFileLocation: playSoundButton.pathToSound,
            addSoundCallback: _addSoundCallback,
            cancelAddSoundCallback: _cancelAddSoundCallback,
            existingSound: true,
            name: playSoundButton.buttonText,
            image: playSoundButton.imageLocation);
      },
      context: context,
    );
  }

  void _cancelAddSoundCallback() {
    Navigator.pop(context);
  }

  void _hideDialogAndKeepSound() {
    Navigator.pop(context, true);
  }
}
