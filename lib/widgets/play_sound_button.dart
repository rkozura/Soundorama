import 'package:flutter/material.dart';
import '../audio/speaker.dart';

class PlaySoundButton extends StatefulWidget {
  final String buttonText;
  final String pathToSound;
  final Function editSoundCallback;

  PlaySoundButton({
    @required this.buttonText,
    @required this.pathToSound,
    this.editSoundCallback,
  });

  @override
  _PlaySoundButtonState createState() => _PlaySoundButtonState();
}

class _PlaySoundButtonState extends State<PlaySoundButton> {
  Speaker speaker = Speaker();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Theme.of(context).buttonColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Container(
            child: Text(widget.buttonText),
            alignment: Alignment.center,
          )),
      onLongPress: _editSound,
      onTap: _playSound,
    );
  }

  void _editSound() {
    widget.editSoundCallback(widget);
  }

  void _playSound() {
    speaker.stopThenPlayLocalAudio(widget.pathToSound);
  }
}
