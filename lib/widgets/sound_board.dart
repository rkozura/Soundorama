import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/model/sound_type.dart';
import 'package:path_provider/path_provider.dart';
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
  void initState() {
    _read();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final delete = Provider.of<Delete>(context);
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Opacity(
          child: Image(
            image: AssetImage('images/speaker.jpg'),
            fit: BoxFit.cover,
          ),
          opacity: .2,
        ),
        backgroundColor: Colors.blueGrey,
        title: Text(_getTitle(delete)),
        centerTitle: true,
        actions: delete.notInMode() && playSoundButtons.length > 0
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
      return 'Soundorama';
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

  Container _buildGrid() {
    return Container(
      padding: EdgeInsets.only(bottom: 80),
      child: GridView.builder(
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
          childAspectRatio: 3 / 3,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
        ),
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
        if (image == null) {
          result.remove("imageLocation");
        } else {
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
    _save();
    _hideDialog();
  }

  void _deleteSound(PlaySoundButton playSoundButton) {
    setState(() {
      int index = playSoundButtons.indexWhere((element) {
        return element["id"] == playSoundButton.id;
      });
      if (index >= 0) {
        if (playSoundButtons[index]["soundType"] ==
            SoundType.Recorded.toString()) {
          SoundFileUtil.deleteSoundFile(playSoundButtons[index]["soundPath"]);
        }
        playSoundButtons.removeAt(index);
      }
    });
  }

  void showNewSound(BuildContext context) async {
    showModalBottomSheet(
      builder: (_) {
        return NewSound(
          addSoundCallback: _addSoundCallback,
          cancelAddSoundCallback: _hideDialog,
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
          cancelAddSoundCallback: _hideDialog,
        );
      },
      context: context,
    );
  }

  void _hideDialog() {
    Navigator.pop(context);
  }

  _read() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/my_saved_sounboard.txt');
      List<dynamic> data = jsonDecode(await file.readAsString());
      List<Map<String, dynamic>> s =
          data.map((element) => element as Map<String, dynamic>).toList();
      List<Map<String, String>> e = s.map((map) {
        return map.map((key, value) {
          return MapEntry(key, value as String);
        });
      }).toList();
      setState(() {
        playSoundButtons = e;
      });
    } catch (e) {
      print("Couldn't read file");
    }
  }

  _save() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/my_saved_sounboard.txt');
    final text = jsonEncode(playSoundButtons);
    print(text);
    await file.writeAsString(text);
    print('saved');
  }
}
