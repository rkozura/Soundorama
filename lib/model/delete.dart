import 'package:flutter/material.dart';

class Delete with ChangeNotifier {
  bool _isDeleting = false;
  bool _isEditing = false;

  getDeleting() => _isDeleting;
  getEditing() => _isEditing;
  notInMode() => !_isDeleting && !_isEditing;

  void toggleDeleteMode() {
    _isDeleting = !_isDeleting;
    notifyListeners();
  }

  void toggleEditingMode() {
    _isEditing = !_isEditing;
    notifyListeners();
  }
  
}
