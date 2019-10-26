import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './widgets/sound_board.dart';
import './model/delete.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Delete>(
      builder: (_) => Delete(),
      child: MaterialApp(
        home: SoundBoard(),
      ),
    );
  }
}
