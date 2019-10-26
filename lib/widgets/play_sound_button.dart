import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_complete_guide/model/delete.dart';
import '../audio/speaker.dart';

class PlaySoundButton extends StatefulWidget {
  final String buttonText;
  final String pathToSound;
  final Function deleteSoundCallback;
  final Function editSoundCallback;
  final String imageLocation;

  PlaySoundButton(
      {@required this.buttonText,
      @required this.pathToSound,
      this.deleteSoundCallback,
      this.editSoundCallback,
      this.imageLocation});

  @override
  _PlaySoundButtonState createState() => _PlaySoundButtonState();
}

class _PlaySoundButtonState extends State<PlaySoundButton> {
  Speaker speaker = Speaker();

  @override
  Widget build(BuildContext context) {
    final delete = Provider.of<Delete>(context);
    return GestureDetector(
      child: GridTile(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).buttonColor,
            image: widget.imageLocation == null
                ? null
                : DecorationImage(
                    image: AssetImage(widget.imageLocation),
                    alignment: Alignment.topLeft,
                    repeat: ImageRepeat.noRepeat,
                    matchTextDirection: true,
                  ),
            // borderRadius: BorderRadius.circular(50.0),
          ),
          child: Text(widget.buttonText),
          alignment: Alignment.center,
        ),
      ),
      onLongPress: _editSound,
      onTap: () => _onTapped(delete),
    );
  }

  void _onTapped(Delete delete) {
    if (delete.getDeleting()) {
      _showDeleteConfirmationModal();
    } else if (delete.getEditing()) {
      _editSound();
    } else {
      _playSound();
    }
  }

  void _playSound() {
    speaker.stopThenPlayLocalAudio(widget.pathToSound);
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
          title: Text('Delete "${widget.buttonText}"?'),
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
