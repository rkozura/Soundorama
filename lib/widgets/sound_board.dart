import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/model/sound_type.dart';
import 'package:provider/provider.dart';
import 'package:flutter_complete_guide/io/sound_file_util.dart';
import 'package:flutter_complete_guide/widgets/new_sound.dart';
import 'package:uuid/uuid.dart';

import 'play_sound_button.dart';
import '../model/delete.dart';

class SoundBoard extends StatefulWidget {
  @override
  _SoundBoardState createState() => _SoundBoardState();
}

class _SoundBoardState extends State<SoundBoard> {
  List<Map<String, String>> playSoundButtons = [];
  var uuid = Uuid();

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

  GridView _buildGrid() {
    return GridView.builder(
      itemCount: playSoundButtons.length,
      itemBuilder: (context, position) {
        List<PlaySoundButton> buttons = playSoundButtons.map((map) {
          return PlaySoundButton(
            id: map["id"],
            name: map["name"],
            soundPath: map["soundPath"],
            soundType: SoundType.values
                .firstWhere((e) => e.toString() == map["soundType"]),
            deleteSoundCallback: _deleteSound,
            editSoundCallback: _editSound,
            imageLocation: map["imageLocation"] != null
                ? File(map["imageLocation"])
                : null,
          );
        }).toList();
        return buttons[position];
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }

  void _addSoundCallback({
    String id,
    String name,
    String soundPath,
    @required SoundType soundType,
    File image,
  }) {
    Map<String, String> result;

    int index = playSoundButtons.indexWhere((element) {
      return element["id"] == id;
    });

    if (index >= 0) {
      result = playSoundButtons[index];
      if (soundType == SoundType.Recorded && result["soundPath"] != soundPath) {
        SoundFileUtil.deleteSoundFile(result["soundPath"]);
      } else if (soundType == SoundType.File &&
          result["soundType"] == SoundType.Recorded.toString()) {
        SoundFileUtil.deleteSoundFile(result["soundPath"]);
      }
      setState(() {
        result["name"] = name;
        result["soundPath"] = soundPath;
        result["soundType"] = soundType.toString();
        if (image != null) {
          result["imageLocation"] = image.path;
        }
      });
    } else {
      setState(() {
        playSoundButtons.add({
          "id": id,
          "name": name,
          "soundPath": soundPath,
          "soundType": soundType.toString(),
          "imageLocation": image != null ? image.path : null
        });
      });
    }
    _hideDialog();
  }

  void _deleteSound(PlaySoundButton playSoundButton) {
    setState(() {
      int index = playSoundButtons.indexWhere((element) {
        return element["id"] == playSoundButton.id;
      });
      if (index >= 0) {
        playSoundButtons.removeAt(index);
      }
    });
  }

  void showNewSound(BuildContext context) async {
    showModalBottomSheet(
      builder: (_) {
        return NewSound(
          addSoundCallback: _addSoundCallback,
          cancelAddSoundCallback: _hideDialogAndDeleteFile,
        );
      },
      context: context,
    );
  }

  void _editSound(PlaySoundButton playSoundButton) {
    showModalBottomSheet(
      builder: (_) {
        return NewSound(
          id: playSoundButton.id,
          name: playSoundButton.name,
          soundPath: playSoundButton.soundPath,
          soundType: playSoundButton.soundType,
          image: playSoundButton.imageLocation,
          addSoundCallback: _addSoundCallback,
          cancelAddSoundCallback: _hideDialogAndDeleteFile,
        );
      },
      context: context,
    );
  }

  void _hideDialog() {
    Navigator.pop(context);
  }

  void _hideDialogAndDeleteFile(_microphonePath) {
    SoundFileUtil.deleteSoundFile(_microphonePath);
    _hideDialog();
  }
}
