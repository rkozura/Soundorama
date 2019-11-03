import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPicker extends StatefulWidget {
  final File photoFilePath;
  final Function selectPhotoCallback;

  PhotoPicker(
    this.photoFilePath,
    this.selectPhotoCallback,
  );

  @override
  _PhotoPickerState createState() => _PhotoPickerState(photoFilePath);
}

class _PhotoPickerState extends State<PhotoPicker> {
  File _image;

  _PhotoPickerState(File photoFilePath) {
    this._image = photoFilePath;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: 70,
      child: widget.photoFilePath == null || _image == null
          ? IconButton(
              padding: EdgeInsets.all(0),
              icon: Icon(Icons.add_a_photo, size: 70, color: Colors.blueAccent),
              onPressed: pressedPhoto,
            )
          : GestureDetector(
              onTap: pressedPhoto,
              child: Container(
                width: 190.0,
                height: 190.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: _image != null
                      ? DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(_image),
                        )
                      : null,
                ),
              ),
            ),
    );
  }

  void pressedPhoto() async {
    if (widget.photoFilePath == null) {
      getImage();
    } else {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('New image or delete existing one?'),
            actions: <Widget>[
              FlatButton(
                child: Text('New'),
                onPressed: () {
                  Navigator.of(context).pop();
                  getImage();
                },
              ),
              FlatButton(
                child: Text('Remove'),
                onPressed: () {
                  setState(() {
                    _image = null;
                  });
                  widget.selectPhotoCallback(null);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void getImage() async {
    File image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _image = image;
      });
      widget.selectPhotoCallback(image);
    }
  }
}
