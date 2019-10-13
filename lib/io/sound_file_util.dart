import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SoundFileUtil {
  static Future<String> createSoundFile() async => _getApplicationDirectory().then((Directory directory) {
      return '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
    });

  static void deleteSoundFile(String pathToSound) {
    File file = File(pathToSound);
    file.deleteSync();
  }

  static bool doesFileExist(String pathToSound) {
    File file = File(pathToSound);
    return file.existsSync();
  }

  static Future<Directory> _getApplicationDirectory() async {
    return await getApplicationDocumentsDirectory();
  }
}
